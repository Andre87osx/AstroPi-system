# 📊 TECHNICAL DATASHEET — Scheduler & Align (AstroPi)

## Scopo

Documento operativo unico, leggibile “per moduli”, con:
- azioni principali
- tempi/timeout
- tentativi/retry
- esito su fallimento persistente

---

## Parametri Globali

| Parametro | Valore | Significato |
|----------|--------|-------------|
| `MAX_FAILURE_ATTEMPTS` | `3` | Retry standard per modulo/stage |
| `UPDATE_PERIOD_MS` | `1000 ms` | Ciclo monitor scheduler/job |
| `RESTART_GUIDING_DELAY_MS` | `5000 ms` | Delay base quick retry guida |
| Policy error handling UI | `ERROR_DONT_RESTART`, `RescheduleErrors=false`, `Delay=0` | No reschedule globale automatico |

---

## Moduli Scheduler (azioni, tempi, tentativi)

### 1) Startup & Connessioni

| Azione | Tempo | Tentativi | Esito fail persistente |
|-------|-------|-----------|------------------------|
| Startup script | stage-driven | fino a `3` | transizione a stato errore/safe |
| Connect Ekos/INDI | monitor periodico `1s` | fino a `3` | fallback: next job / shutdown |
| Unpark mount/dome/cap | stage-driven | fino a `3` | stop preparazione, stato sicuro |

### 2) Slew & Tracking

| Azione | Tempo | Tentativi | Esito fail persistente |
|-------|-------|-----------|------------------------|
| Slew target + tracking verify | dipende setup | retry controllato | abort job corrente |

### 3) ALIGN

| Azione | Timeout/Tempo | Tentativi | Esito fail persistente |
|-------|----------------|-----------|------------------------|
| Plate solve / align stage | `ALIGN_ATTEMPT_HARD_TIMEOUT_MS` + inactivity | `3` | job aborted → `findNextJob()` |

### 4) FOCUS

| Azione | Timeout/Tempo | Tentativi | Esito fail persistente |
|-------|----------------|-----------|------------------------|
| Focus stage | `FOCUS_ATTEMPT_HARD_TIMEOUT_MS` + inactivity | `3` | job aborted → `findNextJob()` |

### 5) GUIDE (logica a due livelli)

| Livello | Azione | Tempo | Tentativi | Esito |
|--------|--------|-------|-----------|-------|
| Quick | retry guide-only | delay 5s/10s/15s | `3` | se ok: resume; se no: deep |
| Deep | `focus → align → guide` | ~2-3 min per ciclo | `3` | se fallisce: next job/shutdown |

Nota operativa:
- Se focus/align falliscono durante deep recovery guida, il flusso passa direttamente a next job (niente loop estesi).

### 6) CAPTURE

| Azione | Timeout/Tempo | Tentativi | Esito fail persistente |
|-------|----------------|-----------|------------------------|
| Capture stage monitor | `CAPTURE_INACTIVITY_TIMEOUT` | `3` | abort job → next job/shutdown |

Gestione extra:
- Se guide cade durante capture: capture viene abortita e si entra in recovery guida.

### 7) Meridian Flip

| Azione | Tempo | Tentativi | Esito fail persistente |
|-------|-------|-----------|------------------------|
| Flip + reacquire align/guide | dipende mount | retry per stage | fallback su stato errore controllato |

### 8) Shutdown & Parking

| Azione | Tempo | Tentativi | Esito fail persistente |
|-------|-------|-----------|------------------------|
| Park mount/dome/cap | stage-driven | `3` | stato safe + log errore |
| Shutdown script | stage-driven | `3` | stato errore finale controllato |

---

## Eventi Chiave (modello rapido)

| Evento | Azione Scheduler |
|-------|-------------------|
| Meteo unsafe | sospensione/stop acquisizioni, eventuale park |
| Finestra target non valida | skip job, `findNextJob()` |
| Guide fail temporaneo | quick retry guida-only |
| Guide fail persistente | deep recovery + next job |
| Nessun job residuo | chiusura sessione + park/shutdown |

---

## Modulo ALIGN — Gestione OOM/RAM Migliorata

### Variabili e segnali usati

| Variabile | Ruolo |
|----------|-------|
| `m_CaptureErrorCounter` | Conta errori acquisizione frame in Align |
| `Options::solverBinningIndex()` | Binning solver corrente |
| `KSUtils::getAvailableRAM()` | RAM disponibile runtime |
| `ccd_width`, `ccd_height` | Dimensione frame |
| `estimatedColorFrameBytes` | Stima RAM frame (`w*h*4`) |
| `ratio` | Rapporto frame/RAM disponibile |

### Adattamento binning anti-OOM

| Condizione | Azione |
|-----------|--------|
| `ratio > 0.08` | almeno binning `2x2` |
| `ratio > 0.15` | almeno binning `3x3` |
| `ratio > 0.25` | almeno binning `4x4` |

Clamping finale:
- limitato da `getMaxBin()` del chip
- bounded con `qBound()`

Log atteso:
- `Low available memory detected. Increasing capture binning to NxN.`

### Frame null / low-memory flow

Quando `data.isNull()` in Align:
1. log low-memory condition
2. incremento `m_CaptureErrorCounter`
3. aumento progressivo `solverBinningIndex` (fino al limite)
4. retry capture
5. al 3° errore (fuori `PAH_REFRESH`) → abort

### Retention immagini in RAM (miglioria)

Policy:
- modalità normale: mantenere solo frame corrente
- modalità PAA specifica: corrente + riferimento (max 2)

Dettaglio:
- fuori stage `PAH_STAR_SELECT`, `PAH_PRE_REFRESH`, `PAH_REFRESH` viene chiamato `releaseImage()`
- `m_ImageData` viene resettata prima di caricare la nuova frame

Log debug:
- `Align image retention: N (current: x, kept: y, stage: z)`

---

## Timeline Operative (indicative)

### Guida: cloud temporanea

- 0s: guide fail
- 5s: quick retry #1
- 10s: quick retry #2
- 20s: quick retry #3
- ~25-30s: resume capture (se recupero)

### Guida: problema reale

- quick x3 fallisce (~30s)
- deep recovery #1/#2/#3 (~2-3 min ciascuno)
- se persiste: next job

---

## Note Operative Finali

- Lo scheduler privilegia continuità: se il target corrente è instabile, passa al prossimo.
- I retry sono limitati per evitare loop infiniti.
- Le procedure di sicurezza (meteo/park/shutdown) hanno priorità sull’acquisizione.

---

## Versione Documento

| Campo | Valore |
|------|--------|
| Documento | Technical Datasheet modulare |
| Data | 18 Febbraio 2026 |
| Stato | ✅ Aggiornato (moduli + tempi + tentativi) |
