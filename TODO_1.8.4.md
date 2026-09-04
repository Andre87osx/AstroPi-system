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

---

## 3. [DA DEFINIRE] Altri punti aperti

Aggiungere qui altri interventi individuati per la 1.8.4 (finora non ne sono
emersi altri oltre ai due punti sopra).
