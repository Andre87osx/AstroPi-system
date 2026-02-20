# ✨ SUMMARY V2 — Scheduler Recovery (Formato Modulare)

## 📌 Registro Unico Progressi

Questo file è la fonte unica e ufficiale per:
- avanzamento integrazione recovery scheduler
- logica operativa per moduli
- tempi, tentativi e comportamento su failure

---

## Parametri Globali

| Parametro | Valore | Significato |
|----------|--------|-------------|
| `MAX_FAILURE_ATTEMPTS` | `3` | Retry standard per modulo/stage |
| `UPDATE_PERIOD_MS` | `1000 ms` | Ciclo monitor scheduler/job |
| `RESTART_GUIDING_DELAY_MS` | `5000 ms` | Delay base quick retry guida |
| Policy UI | `ERROR_DONT_RESTART`, `RescheduleErrors=false`, `Delay=0` | No reschedule globale |

---

## Strategia Guida a Due Livelli

### Livello 1 — Quick Recovery (guide-only)

| Step | Azione | Tempo |
|------|--------|-------|
| 1 | Retry guida #1 | 5s |
| 2 | Retry guida #2 | 10s |
| 3 | Retry guida #3 | 15s |

Totale tipico: ~25–30s.

### Livello 2 — Deep Recovery (focus→align→guide)

| Attempt | Catena | Tempo indicativo |
|---------|--------|------------------|
| #1 | focus → align → guide | ~2-3 min |
| #2 | focus → align → guide | ~2-3 min |
| #3 | focus → align → guide | ~2-3 min |

### Livello 3 — Failover

- Se falliscono 3 quick + 3 deep:
  - reset contatori
  - `findNextJob()`
  - se nessun job valido: shutdown/parcheggio

Contatore operativo:

```cpp
guideFailureCount = 0..3   // quick
guideFailureCount = 4..6   // deep
>6 -> next job / shutdown
```

---

## Moduli Scheduler (azioni, tempi, tentativi)

### 1) Startup & Connessioni

| Azione | Tempo | Tentativi | Esito fail persistente |
|-------|-------|-----------|------------------------|
| Startup script | stage-driven | fino a `3` | stato errore/safe |
| Connect Ekos/INDI | monitor `1s` | fino a `3` | fallback operativo |
| Unpark mount/dome/cap | stage-driven | fino a `3` | stop preparazione |

### 2) Slew & Tracking

| Azione | Tempo | Tentativi | Esito fail persistente |
|-------|-------|-----------|------------------------|
| Slew target + tracking verify | dipende setup | retry controllato | abort job |

### 3) ALIGN

| Azione | Timeout | Tentativi | Esito fail persistente |
|-------|---------|-----------|------------------------|
| Plate solve / align stage | `ALIGN_ATTEMPT_HARD_TIMEOUT_MS` + inactivity | `3` | job aborted → `findNextJob()` |

### 4) FOCUS

| Azione | Timeout | Tentativi | Esito fail persistente |
|-------|---------|-----------|------------------------|
| Focus stage | `FOCUS_ATTEMPT_HARD_TIMEOUT_MS` + inactivity | `3` | job aborted → `findNextJob()` |

### 5) GUIDE

| Modalità | Azione | Tempo | Tentativi | Esito |
|----------|--------|-------|-----------|-------|
| Quick | guide-only retry | 5/10/15s | `3` | se ok: resume |
| Deep | focus→align→guide | ~2-3 min/ciclo | `3` | se KO: next job/shutdown |

### 6) CAPTURE

| Azione | Timeout | Tentativi | Esito fail persistente |
|-------|---------|-----------|------------------------|
| Capture monitor | `CAPTURE_INACTIVITY_TIMEOUT` | `3` | abort job → next job/shutdown |

Nota:
- Se guida cade durante capture, capture viene abortita e parte recovery guida.

### 7) Meridian Flip

| Azione | Tempo | Tentativi | Esito fail persistente |
|-------|-------|-----------|------------------------|
| Flip + reacquire align/guide | dipende mount | retry per stage | fallback controllato |

### 8) Shutdown & Parking

| Azione | Tempo | Tentativi | Esito fail persistente |
|-------|-------|-----------|------------------------|
| Park mount/dome/cap | stage-driven | `3` | safe-state + log errore |
| Shutdown script | stage-driven | `3` | stato errore finale |

---

## Eventi Chiave (tabella operativa)

| Evento | Azione Scheduler |
|-------|-------------------|
| Meteo unsafe | sospensione/stop acquisizioni, eventuale park |
| Finestra target non valida | skip job, `findNextJob()` |
| Guide fail temporaneo | quick retry guida-only |
| Guide fail persistente | deep recovery + next job |
| Nessun job residuo | chiusura sessione + park/shutdown |

---

## ALIGN — OOM/RAM e gestione migliorata

### Variabili usate

| Variabile | Ruolo |
|----------|-------|
| `m_CaptureErrorCounter` | Conta errori acquisizione frame |
| `Options::solverBinningIndex()` | Binning solver corrente |
| `KSUtils::getAvailableRAM()` | RAM disponibile runtime |
| `ccd_width`, `ccd_height` | Dimensione frame |
| `estimatedColorFrameBytes` | Stima frame (`w*h*4`) |
| `ratio` | Rapporto frame/RAM |

### Binning adattivo anti-OOM

| Condizione | Azione |
|-----------|--------|
| `ratio > 0.08` | almeno `2x2` |
| `ratio > 0.15` | almeno `3x3` |
| `ratio > 0.25` | almeno `4x4` |

Clamping finale con `getMaxBin()` + `qBound()`.

Log atteso:
- `Low available memory detected. Increasing capture binning to NxN.`

### Flow su frame null (low-memory)

1. Log low-memory condition
2. Incrementa `m_CaptureErrorCounter`
3. Aumenta `solverBinningIndex` progressivamente
4. Retry capture
5. Al 3° errore (fuori `PAH_REFRESH`) → abort

### Retention immagini RAM (fix applicata)

- Normale: tenere solo frame corrente
- PAA: corrente + riferimento (max 2)
- Fuori da stage PAA: `releaseImage()`
- `m_ImageData` reset prima di nuova assegnazione

Log debug:
- `Align image retention: N (current: x, kept: y, stage: z)`

---

## Timeline rapide

### Cloud temporanea
- 0s fail guida
- 5s/10s/15s quick retry
- ~25–30s resume

### Problema reale
- quick x3 fallisce (~30s)
- deep #1/#2/#3 (~2-3 min ciascuno)
- se persiste: next job

---

## Esito

✅ Documento allineato al formato modulare del datasheet.
✅ Recovery descritta per moduli con azioni/tempi/tentativi.
✅ Sezione Align OOM/RAM integrata con variabili e soglie reali.
