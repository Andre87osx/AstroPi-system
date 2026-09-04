# TODO - Modifiche da fare per la 1.8.4

Elenco delle modifiche aperte per la prossima release. Ogni punto va spuntato
solo quando verificato/testato, non quando "sembra" a posto.

---

## 1. [APERTO] Guide UI Detail View - fix rendering index 0/1/2

Ripreso più volte, ancora NON risolto correttamente. Da riaffrontare da capo
seguendo l'analisi qui sotto (mantenuta dal memo precedente).

### SITUAZIONE ORIGINALE (commit 39a99f6)

#### Mappatura Indici nel commit originale:
```
Index 0 = guideProfilePixmap (Guide Profile) - ALLARGATO, NO sfondo nero
Index 1 = guidePlotPixmap (Guide Plot) - ALLARGATO con black box centering
Index 2 = guideStarPixmap (Guide Star) - QUADRATO con sfondo nero
```

#### Rendering Dinamico (da guideProcess):
```cpp
if (currentGuidePixmapIndex == 0)
    return guideProcess->getProfileViewPixmap(viewSize);
if (currentGuidePixmapIndex == 1)
    return guideProcess->getDriftPlotViewPixmap(viewSize);
```

Entrambi index 0 e 1 usano rendering dinamico PRIMA, poi fallback a pixmap statici.

#### Rendering Statico (fallback):
```cpp
if (currentGuidePixmapIndex == 0 && guideProfilePixmap.get() != nullptr)
    guideDetailView->setPixmap(scaleGuidePixmap(*guideProfilePixmap)); // NO black box

else if (currentGuidePixmapIndex == 1 && guidePlotPixmap.get() != nullptr)
    guideDetailView->setPixmap(scaleGuidePixmap(*guidePlotPixmap)); // NO black box

else if (currentGuidePixmapIndex == 2 && guideStarPixmap.get() != nullptr)
    guideDetailView->setPixmap(fitSquareGuideTargetInBlackBox(*guideStarPixmap)); // QUADRATO
```

#### updateGuideStatus():
Quando status = GUIDE_GUIDING o DITHERING, forza visualizzazione index 1 (Plot):
```cpp
if (currentGuidePixmapIndex != 1)
    currentGuidePixmapIndex = 1;
```

### OBIETTIVO RICHIESTO

1. **Rimuovere completamente index 2** (Guide Star visualization)
2. **Modificare SOLO index 0** (Profile): renderlo QUADRATO con sfondo NERO (come era index 2)
3. **NON TOCCARE index 1** (Plot): DEVE rimanere come originale (già perfetto)

### ERRORI COMMESSI IN PASSATO (DA NON RIPETERE)

- ❌ Confusi gli indici: invertito index 0 e 1, pensando che index 0 fosse il plot principale.
  **REALTA**: Index 1 è il plot principale (drift scatter), Index 0 è il profile.
- ❌ Modificato il rendering del Plot (index 1), che NON doveva essere toccato e funzionava già perfettamente.
- ❌ Gestita male la precedenza rendering dinamico vs statico: nel codice originale il
  rendering dinamico (da guideProcess) viene PRIMA, poi se fallisce usa i pixmap statici
  come fallback.

### SOLUZIONE DA APPLICARE

#### a. Rimuovere Index 2 completamente
- Eliminare tutti i check `currentGuidePixmapIndex == 2`
- Cambiare tooltip array da 3 a 2 elementi
- Rimuovere logica di navigazione verso index 2

#### b. Modificare SOLO Index 0 (Profile)
Nel rendering DINAMICO:
```cpp
if (currentGuidePixmapIndex == 0)
{
    const QPixmap viewPixmap = guideProcess->getProfileViewPixmap(viewSize);
    if (!viewPixmap.isNull())
    {
        // Applica trasformazione quadrata + sfondo nero
        guideDetailView->setStyleSheet(QStringLiteral("background-color: black;"));
        guideDetailView->setPixmap(fitSquareGuideTargetInBlackBox(viewPixmap));
        return;
    }
}
```

Nel rendering STATICO (fallback):
```cpp
if (currentGuidePixmapIndex == 0 && guideProfilePixmap.get() != nullptr)
{
    guideDetailView->setStyleSheet(QStringLiteral("background-color: black;"));
    guideDetailView->setPixmap(fitSquareGuideTargetInBlackBox(*guideProfilePixmap));
}
```

#### c. NON TOCCARE Index 1 (Plot)
Lasciare TUTTO il codice relativo a index 1 ESATTAMENTE come nell'originale.

### FILE DA MODIFICARE
1. **manager.cpp** - logica rendering
2. **manager.h** - tooltip array (3→2 elementi)
3. **manager.ui** - NESSUNA modifica necessaria (già OK nel commit originale)

### NOTE IMPORTANTI
- **Index 0** = Profile (da modificare: quadrato + nero)
- **Index 1** = Plot (NON TOCCARE, già perfetto)
- **Index 2** = Star (da rimuovere completamente)
- Il rendering dinamico viene PRIMA del fallback statico
- `fitSquareGuideTargetInBlackBox()` è la funzione per rendere quadrato
- `scaleGuidePixmap()` è la funzione per scala normale (usata per plot)

### PROSSIMI PASSI
1. Leggere attentamente manager.cpp per capire la struttura completa
2. Identificare TUTTI i punti dove index 0 viene renderizzato
3. Applicare trasformazione quadrata + sfondo nero SOLO a index 0
4. Verificare che index 1 rimanga INTATTO
5. Rimuovere index 2 senza toccare 0 e 1
6. Compilare e testare

---

## 2. [DA VERIFICARE] Crash connessione driver INDI subito dopo l'avvio

Da quando Ekos è integrato come tab sempre presente in KStars (commit
`95a4094`), il tab è cliccabile appena la finestra appare, prima che
l'inizializzazione di sfondo (driver list, KStarsData) si sia assestata.
Premere "Play"/Connetti troppo presto causava un crash quasi sistematico;
aspettando qualche secondo non si presentava. Sotto gdb non si manifesta mai
(il debugger rallenta l'avvio quanto basta a far scomparire la race).

Interventi fatti in `manager.cpp`:
- Bloccato `processINDIB` (Start) alla costruzione di `Manager`, riabilitato
  dopo 3s via `QTimer::singleShot`, per coprire la finestra di race.
- `Manager::deviceDisconnected()`: sostituito `static_cast` con `qobject_cast`
  su `sender()`, coerente con le fix già fatte su `deviceConnected()`,
  `processNewProperty()`, `processDeleteProperty()`, `watchDebugProperty()`.

**Da fare**: testare su hardware reale (Raspberry Pi) più cicli di
avvio/connessione rapidi in sequenza, e verificare se il crash può ancora
presentarsi oltre i 3s (in tal caso il timer va allungato o va cercata la vera
causa della race con un core dump: `ulimit -c unlimited` poi
`gdb kstars core` dopo il crash).

### Osservazioni dalla sessione 2026-09-03 (da tenere presenti)

Elementi che NON quadrano con la sola ipotesi "click troppo presto all'avvio",
quindi la causa potrebbe non essere (solo) quella:

- Un crash è avvenuto **mentre si configurava lo Scheduler**, con tutto già
  connesso e fermo da tempo — quindi non in fase di avvio/connessione iniziale.
- Dopo un crash, **riconnettere causa crash immediato** finché non si riavvia
  la macchina: suggerisce uno stato sporco lasciato indietro (indiserver orfano
  o socket ancora aperto), non solo una race di avvio.
- Il crash si presenta **anche senza il driver WatchDog** nel profilo: WatchDog
  non è la causa, semmai un acceleratore.
- La build testata era la v1.8.3 (tag `031516a`), che **include già** entrambe
  le fix null-check su `manager.cpp` → esiste almeno un terzo punto di deref
  non protetto ancora da trovare.
- Sequenza in console subito prima del segfault: ripetuti
  `Dispatch command error(-1): INDI: <delProperty> no such device EQMod AzEq6`
  (ogni proprietà due volte: DEBUG_LEVEL, LOGGING_LEVEL, LOG_OUTPUT), poi i
  relativi `setSwitchVector` con stato Ok, poi `Errore di segmentazione`.
  Il pattern doppio suggerisce due connessioni client che configurano lo stesso
  device in parallelo.
- Sessione notturna del 2026-09-03 lanciata sotto gdb per catturare un
  `bt full` in caso di crash: **verificare l'esito e allegare qui il backtrace**
  se disponibile.

---

## 3. [APERTO] Menu planetario residuo nel tab Ekos

Nel tab Ekos resta visibile una riga parziale della toolbar del planetario
(icone Ekos, INDI e "bersaglio"). Va nascosta completamente, non parzialmente.

Effetto collaterale già presente: passando al tab Planetario, il resto dei
bottoni del planetario NON ricompare.

**Tentativo precedente (non risolutivo)**: commit `7fa3a00` "feat: add toolbar
visibility management for planetarium tab in KStars UI" — modifica
`kstars.h`, `kstarsinit.cpp` e `Tests/kstars_ui/test_kstars_startup.cpp`.
Rivedere quella logica di show/hide prima di scrivere codice nuovo.

---

## 4. [APERTO] Modulo camera - indicatore colore errato

Nel modulo camera l'indicatore di colore viene visualizzato spento/errato.
Nessun tentativo di fix precedente trovato nella history (ricerca su
`CCD_.*color` / `colore` / `filtro colore` senza risultati): punto vergine.

---

## 5. [APERTO] Scheduler ordina per nome oggetto invece che per ora di partenza

Regressione: la coda dei job viene ordinata per nome oggetto e non per ora di
partenza come avveniva prima.

**Piste già individuate nel codice (da verificare, nessuna modifica fatta)**:
- `Options::sortSchedulerJobs()` governa un percorso di riordino in
  `scheduler.cpp` (occorrenze ~1158, 1262, 1336, 1408, 1432, 1446, 1470, 1519,
  2023-2024). Il log a riga 2023 dice esplicitamente "Option to sort jobs based
  on priority and altitude is <valore>", e se true (2024) riordina.
- Comparatori in `schedulerjob.cpp` (~730-762): `decreasingScoreOrder`,
  `increasingPriorityOrder`, `decreasingAltitudeOrder`,
  `increasingStartupTimeOrder`.
- `Scheduler::sortJobsPerAltitude()` (`scheduler.cpp` ~6592) è il pulsante di
  ordinamento manuale (`sortJobsB`), usa `decreasingAltitudeOrder`.
- **Ipotesi da verificare**: l'opzione `SortSchedulerJobs` risulta attiva
  (cambio di default in `kstars.kcfg`?), quindi la coda viene auto-ordinata per
  priorità/altitudine invece di restare in ordine di ora di partenza.

---

## 6. [APERTO] Guida tecnica Scheduler da aggiornare

Il testo HTML "GUIDA TECNICA SCHEDULER ASTROPI" incorporato in `scheduler.cpp`
va aggiornato con le ultime correzioni/feature. Verificare in particolare che
il testo rispecchi il comportamento attuale della strategia di error handling
(default `ERROR_RESTART_AFTER_TERMINATION` con delay 3600s), già modificata in
precedenza.

---

## 7. [DA DECIDERE] AstroPi system: da bash+zenity a Python?

`bin/AstroPi.sh` (e gli altri `bin/*.sh`) sono bash + zenity. Valutare la
conversione a Python con GUI, per maggiore flessibilità e compatibilità con le
versioni recenti di Raspberry Pi OS (oggi si sviluppa ancora sulla 10).

Non è un fix rapido ma una scelta architetturale: prima va deciso il toolkit
grafico (Tkinter / PyQt / GTK), poi pianificata la migrazione. Probabilmente da
rimandare alla 1.8.5 ("definitiva") insieme al refactoring generale.

---

## 8. [DA DEFINIRE] Altri punti aperti

Aggiungere qui eventuali altri interventi individuati per la 1.8.4.
