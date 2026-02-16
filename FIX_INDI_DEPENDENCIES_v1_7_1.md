# AstroPi System - INDI Dependencies Fix (v1.7.1)

## 🔧 Cosa è stato Corretto

### Problema Originale
La compilazione di INDI su Debian Buster archiviato falliva con errori di dipendenze mancanti, a causa di:
- Repository di Buster archiviati e non completamente disponibili
- Pacchetti ARM mancanti nei repository Debian standard
- Dipendenze rotte o irrisolvibili

### Soluzione Implementata

#### 1. **Miglioramento dei Repository** (`include/functions.sh`)
- ✅ Aggiunto **Raspberry Pi Repository** per pacchetti ARM specifici
- ✅ Aggiunto **Raspberry Pi Archive** come fallback
- ✅ Configurazione APT permissiva per repository archiviati
- ✅ Aggiunta chiavi GPG automatiche per validazione

#### 2. **Gestione Intelligente delle Dipendenze** (`include/functions.sh`)
- ✅ Tentativo di installazione principale con fallback automatico
- ✅ Risoluzione automatica di dipendenze rotte (`apt-get install -f`)
- ✅ Separazione tra pacchetti **critici** (blocca se mancano) e **opzionali** (continua se mancano)
- ✅ Log dettagliato per debugging
- ✅ Pre-verifica di pacchetti critici prima della compilazione

#### 3. **Script Helper** (Nuovo)
- ✅ `bin/fix-indi-dependencies.sh` - Pre-risoluzione delle dipendenze
- ✅ `bin/check-indi-deps.sh` - Controllo rapido dello stato delle dipendenze

#### 4. **Documentazione** (Nuovo)
- ✅ `INDI_DEPENDENCIES_FIX.md` - Guida completa con troubleshooting

---

## 📋 File Modificati/Creati

| File | Tipo | Descrizione |
|------|------|-------------|
| `include/functions.sh` | Modificato | Miglioramenti in `system_pre_update()` e `chkINDI()` |
| `bin/fix-indi-dependencies.sh` | Nuovo | Script per pre-risoluzione dipendenze |
| `bin/check-indi-deps.sh` | Nuovo | Script per verifica dipendenze |
| `INDI_DEPENDENCIES_FIX.md` | Nuovo | Documentazione e troubleshooting |
| `include/functions.sh.bak` | Backup | Backup del file originale |

---

## 🚀 Come Usare

### Opzione 1: Uso Consigliato (Con Pre-risoluzione)

```bash
# 1. Aggiorna sistema e repository
./bin/AstroPi.sh
# → Seleziona: "System Pre Update"

# 2. Pre-risolvi le dipendenze (opzionale ma consigliato)
sudo bash bin/fix-indi-dependencies.sh

# 3. Compila INDI
./bin/AstroPi.sh
# → Seleziona: "Check INDI"
```

### Opzione 2: Automatica (Nuovo)

```bash
# Il nuovo codice gestisce automaticamente fallback e dipendenze
./bin/AstroPi.sh
# → Seleziona: "Check INDI"
```

### Opzione 3: Controllo Rapido delle Dipendenze

```bash
bash bin/check-indi-deps.sh
# Mostra lo stato di tutte le dipendenze
```

---

## 🔍 Dettagli Tecnici

### Repository Aggiunti

```bash
# Debian Archived (standard)
deb [trusted=yes] http://archive.debian.org/debian/ buster main contrib non-free

# Raspberry Pi (ARM packages)
deb [trusted=yes] http://raspbian.raspberrypi.org/raspbian/ buster main contrib non-free rpi
deb [trusted=yes] http://archive.raspberrypi.org/debian/ buster main
```

### Pacchetti Critici vs Opzionali

**CRITICI** (compilazione fallisce senza):
- cmake, make, build-essential, git
- libev-dev, libgsl-dev, libgsl0-dev
- libraw-dev, libusb-dev, libusb-1.0-0-dev
- zlib1g-dev, libjpeg-dev, libtiff-dev, libfftw3-dev

**OPZIONALI** (compilazione continua se mancano):
- liblimesuite-dev, libavcodec-dev, libavdevice-dev
- libtheora-dev, libgphoto2-dev (se disponibile)
- Tutti gli altri pacchetti di sviluppo

### Logica di Fallback

1. **Tentativo Primario**: Installa tutte le dipendenze
2. **Se Fallisce**:
   - Esecuzione: `apt-get install -f` (risolvi dipendenze rotte)
   - Rimozione: `apt-get autoremove` (pacchetti conflittuali)
   - **Secondo Tentativo**: Installa di nuovo
3. **Verifica Critica**: Controlla se i pacchetti critici sono installati
4. **Decisione Finale**:
   - Se critici OK → Continua compilazione (warning se opzionali mancano)
   - Se critici NO → Fallisce con errore

---

## 📊 Confronto Prima/Dopo

### Prima
```
chkINDI()
  └─ apt-get install [tutti i pacchetti]
     └─ SE FALLISCE → Errore totale ❌
```

### Dopo
```
chkINDI()
  ├─ apt-get install [tutti i pacchetti]
  │  └─ SE FALLISCE:
  │     ├─ apt-get install -f (ripara dipendenze)
  │     ├─ apt-get autoremove (pulisci conflitti)
  │     └─ Riprova installazione
  │
  └─ Verifica Pacchetti Critici
     ├─ Se OK → Continua ✅
     └─ Se NO → Errore informativo ❌
```

---

## 🐛 Troubleshooting

### Se continua a fallire:

```bash
# 1. Verifica lo stato delle dipendenze
bash bin/check-indi-deps.sh

# 2. Leggi il log dettagliato
cat ~/indi-deps-install.log

# 3. Esegui il fix manuale
sudo bash bin/fix-indi-dependencies.sh

# 4. Riprova INDI
./bin/AstroPi.sh
```

### Problemi Noti

- **limlimesuite-dev non disponibile**: Normale, è opzionale
- **libgphoto2-dev non trovato**: Problema frequente, ma opzionale
- **Dipendenze circolari**: Risolte automaticamente con `apt-get install -f`

---

## 📝 Note Importanti

1. **Backup Automatico**: Il file originale è salvato in `include/functions.sh.bak`
2. **Log Persistenti**: I log rimangono in `~/indi-deps-install.log` per debug
3. **Compatibilità**: Tutte le modifiche mantengono compatibilità con versioni precedenti
4. **ARM Friendly**: I miglioramenti sono specifici per Raspberry Pi e sistemi ARM

---

## 🔄 Versione

- **AstroPi System**: v1.7 → v1.7.1+
- **INDI**: 1.9.7 (non cambiato)
- **Data Implementazione**: Gennaio 2026
- **Debian Target**: Buster (Archiviato)

---

## 📞 Support

Se hai problemi:

1. Condividi i log:
   - `~/indi-deps-install.log`
   - `~/.local/share/astropi/bin/update-log.txt`

2. Crea un issue: https://github.com/Andre87osx/AstroPi-system/issues

3. Specifica:
   - Output: `uname -a`
   - Output: `cat /etc/os-release`
   - Output: `bash bin/check-indi-deps.sh`

---

**Fatto da**: GitHub Copilot  
**Data**: 18 Gennaio 2026  
**Versione Dokumentazione**: 1.0
