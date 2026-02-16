# Soluzione: Problemi di Dipendenze Mancanti con INDI su Debian Buster Archiviato

## Problema
Quando si usa la funzione `chkINDI()` su Debian Buster, INDI fallisce perché alcuni pacchetti non hanno dipendenze soddisfatte e non li trova nei repository archiviati.

## Cause Radice

1. **Repository Archiviati**: Debian Buster è stata archiviata (EOL = 30 Giugno 2024) e molti pacchetti hanno dipendenze complesse che potrebbero non essere risolte automaticamente
2. **ARM Specifici**: Su Raspberry Pi (ARM), alcuni pacchetti potrebbero non essere disponibili nei repository Debian standard
3. **Versioni Incompatibili**: Alcuni pacchetti opzionali (come `liblimesuite-dev`, `libavcodec-dev`) potrebbero non essere disponibili in Buster
4. **Dipendenze Rotte**: Il sistema APT potrebbe trovare pacchetti con dipendenze circolari o non soddisfatte

## Soluzione Implementata

### 1. Miglioramenti ai Repository (in `system_pre_update()`)

**Cosa è stato aggiunto:**
- ✅ Aggiunto repository Raspberry Pi: `http://raspbian.raspberrypi.org/raspbian/ buster`
- ✅ Aggiunto archivio Raspberry Pi ufficiale: `http://archive.raspberrypi.org/debian/`
- ✅ Chiavi GPG per Raspberry Pi per validare i pacchetti
- ✅ Configurazione permissiva di APT per repository archiviati

**Benefici:**
- Permette di trovare pacchetti ARM-specifici con dipendenze corrette
- Fornisce fallback per pacchetti Debian standard non disponibili

### 2. Gestione Intelligente delle Dipendenze (in `chkINDI()`)

**Cosa è stato aggiunto:**
- ✅ Tentativo di installazione principale di tutte le dipendenze
- ✅ Se fallisce, esecuzione di `apt-get install -f` per risolvere dipendenze rotte
- ✅ Installazione permissiva di pacchetti opzionali (continua se mancano)
- ✅ Verifica che i pacchetti **critici** siano installati:
  - cmake, make, build-essential, git, libev-dev, libgsl-dev
- ✅ Se i pacchetti critici sono ok, consente di continuare anche se alcuni pacchetti opzionali mancano

**Benefici:**
- Non interrompe la compilazione per pacchetti opzionali mancanti
- Risolve automaticamente dipendenze rotte
- Log dettagliato per debugging

### 3. Script Helper per Pre-risoluzione delle Dipendenze

**File Creato:** `bin/fix-indi-dependencies.sh`

Questo script deve essere eseguito **prima** di `chkINDI()`:

```bash
sudo bash bin/fix-indi-dependencies.sh
```

**Cosa fa:**
1. Aggiorna cache APT
2. Installa pacchetti critici di compilazione
3. Installa header di sviluppo
4. Tenta di installare pacchetti opzionali
5. Risolve dipendenze rotte con `apt-get install -f`
6. Pulisce pacchetti non necessari
7. Verifica che i pacchetti critici siano presenti

## Istruzioni di Utilizzo

### Opzione 1: Uso Consigliato (Completo)

```bash
# Step 1: Preparazione sistema e repository
sudo bash bin/AstroPi.sh
# → Scegli "System Pre Update" dal menu

# Step 2: Pre-risolvi le dipendenze
sudo bash bin/fix-indi-dependencies.sh

# Step 3: Compila e installa INDI
sudo bash bin/AstroPi.sh
# → Scegli "Check INDI" dal menu
```

### Opzione 2: Automatica (Nuova)

Se hai già aggiornato i file:

```bash
# Compila direttamente - il nuovo codice gestisce tutto automaticamente
sudo bash bin/AstroPi.sh
# → Scegli "Check INDI" dal menu
```

## Dettagli Tecnici

### Repository Configurati

```
# Debian Archived (standard)
http://archive.debian.org/debian/ buster

# Raspberry Pi (ARM packages)
http://raspbian.raspberrypi.org/raspbian/ buster
http://archive.raspberrypi.org/debian/ buster
```

### Configurazione APT per Buster Archiviato

```
Acquire::Check-Valid-Until "false";
Acquire::AllowInsecureRepositories "true";
Acquire::AllowDowngradeToInsecureRepositories "true";
```

Questo consente di usare repository non firmati (necessario per archivi).

### Pacchetti Critici vs Opzionali

**Critici** (compilazione fallisce senza questi):
- cmake, make, build-essential, git
- libev-dev, libgsl-dev

**Opzionali** (compilazione continua se mancano):
- liblimesuite-dev, libavcodec-dev, libavdevice-dev, libtheora-dev
- libgphoto2-dev (se non disponibile)

## Se il Problema Persiste

### Debug: Verifica i Log

```bash
# Log installazione dipendenze INDI
cat ~/indi-deps-install.log

# Log aggiornamento sistema
cat ~/.local/share/astropi/bin/update-log.txt
```

### Risoluzione Manuale

Se `chkINDI()` continua a fallire:

```bash
# 1. Pulisci pacchetti non necessari
sudo apt-get autoremove -y
sudo apt-get autoclean -y

# 2. Risolvi dipendenze rotte manualmente
sudo apt-get install -f -y

# 3. Reinstalla pacchetti critici
sudo apt-get install -y --no-install-recommends \
    build-essential cmake make git \
    libev-dev libgsl-dev libgsl0-dev

# 4. Prova di nuovo
sudo bash bin/AstroPi.sh
```

### Se le Dipendenze di Buster Sono Irrecuperabili

Considera di aggiornare a una versione di Debian più recente (Bullseye o successivo):

```bash
# ⚠️ IMPORTANTE: Fai backup prima!
sudo apt-get dist-upgrade  # Se decidi di aggiornare
```

## Cambiamenti ai File

### 1. `include/functions.sh`

**Funzione `system_pre_update()`:**
- Aggiunto repository Raspberry Pi
- Aggiunto installazione chiavi GPG Raspberry Pi
- Migliorata configurazione APT per repository archiviati

**Funzione `chkINDI()`:**
- Aggiunta logica di fallback per dipendenze mancanti
- Aggiunta verifica di pacchetti critici vs opzionali
- Migliorato sistema di logging e reporting errori
- Aggiunta pre-verifica di pacchetti critici prima della compilazione

### 2. `bin/fix-indi-dependencies.sh` (Nuovo)

Script standalone per pre-risoluzione delle dipendenze prima di compilare INDI.

## Riferimenti

- [Debian Buster End of Life](https://www.debian.org/releases/buster/)
- [Debian Archived Repositories](http://archive.debian.org/)
- [INDI Library](https://indilib.org/)
- [Raspberry Pi OS Repositories](https://www.raspberrypi.org/)

## Supporto

Se hai ancora problemi:

1. Condividi i log:
   - `~/indi-deps-install.log`
   - `~/.local/share/astropi/bin/update-log.txt`

2. Crea un issue su: https://github.com/Andre87osx/AstroPi-system/issues

3. Specifica:
   - Output di: `uname -a` (versione kernel)
   - Output di: `cat /etc/os-release` (versione Debian)
   - Modello di Raspberry Pi (se applicabile)
