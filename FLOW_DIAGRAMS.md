# Ekos Scheduler Guide Failure Recovery - Flow Diagrams

## BEFORE FIX: Broken Flow

```
┌─────────────────────────────────────────────────────────────┐
│ SCHEDULER JOB STARTS                                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  FOCUS → ALIGN → GUIDE (Calibrating) ❌ FAILS              │
│                                                              │
│              │                                               │
│              └──→ Retry GUIDE ONLY (wrong!)                │
│                   └─→ FAILS AGAIN (focus/align still bad)  │
│                       │                                     │
│                       └──→ CAPTURE STARTS ANYWAY ❌          │
│                           (mount unstable, no guiding)      │
│                           │                                 │
│                           └──→ Mount uncontrolled motion   │
│                               └──→ CRASH 💥                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Problems:
- ❌ Guide retry WITHOUT focus/align recalibration
- ❌ Focus and alignment errors not corrected
- ❌ Mount position remains unstable  
- ❌ Capture proceeds without proper guidance
- ❌ Large guide errors cause physical collision
- ❌ No maximum attempt limit

---

## AFTER FIX: Proper Recovery Sequence

```
┌──────────────────────────────────────────────────────────┐
│ SCHEDULER JOB STARTS                                     │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  STAGE 1: FOCUSING                                       │
│  ────────────────                                        │
│  Focus → Complete ✓                                      │
│                    │                                     │
│                    └──→ STAGE 2: ALIGNING                │
│                         ────────────────                 │
│                         Align → Complete ✓               │
│                                    │                     │
│                                    └──→ STAGE 3: GUIDING │
│                                         ──────────────   │
│                                         Guide (Cal.) ✓   │
│                                                          │
│  STAGE 4: CAPTURING ← Only reached after all pass ✓     │
│  ────────────────────                                    │
│  Capture → Image 1 ✓ Image 2 ✓ Image 3 ✓                │
│                                                          │
│  ❌ GUIDE FAILS during capture                           │
│     │                                                    │
│     └──→ Capture ABORTS IMMEDIATELY                      │
│          │                                               │
│          └──→ RECOVERY SEQUENCE TRIGGERED:               │
│              Focus (attempt #1) → Align → Guide         │
│              │                                           │
│              ❌ GUIDE STILL FAILS (attempt #1 of 3)      │
│              │                                           │
│              └──→ RECOVERY SEQUENCE TRIGGERED:           │
│                  Focus (attempt #2) → Align → Guide     │
│                  │                                       │
│                  ❌ GUIDE STILL FAILS (attempt #2 of 3)  │
│                  │                                       │
│                  └──→ RECOVERY SEQUENCE TRIGGERED:       │
│                      Focus (attempt #3) → Align → Guide │
│                      │                                   │
│                      ❌ GUIDE STILL FAILS (attempt #3)   │
│                      │                                   │
│                      └──→ JOB ABORTED                    │
│                          "Mount may be physically        │
│                           misaligned. Aborting job."     │
│                                                          │
│  ✓ NO CRASH (capture was stopped, mount not forced)    │
│  ✓ CLEAR DIAGNOSIS (user knows mount has issues)        │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Improvements:
- ✅ Full focus-align-guide recovery sequence
- ✅ Focus errors corrected
- ✅ Mount alignment refreshed
- ✅ Guide calibrated with accurate positions
- ✅ Capture only proceeds if guide succeeds
- ✅ Capture aborts if guide fails during run
- ✅ Maximum 3 retry attempts prevents infinite loops
- ✅ Clear error messages help diagnose issues

---

## State Machine Flow

### BEFORE (Incomplete):
```
STAGE_FOCUSING
    ↓
STAGE_FOCUS_COMPLETE
    ↓
STAGE_ALIGNING
    ↓
STAGE_ALIGN_COMPLETE
    ↓
STAGE_RESLEWING
    ↓
STAGE_RESLEWING_COMPLETE
    ↓
STAGE_GUIDING ←─────────┐
    ↓                   │
    ├─→ GUIDE_GUIDING ──┤
    │   ↓               │
    │   STAGE_GUIDING_COMPLETE
    │   ↓
    │   STAGE_CAPTURING
    │   ↓
    │   [CRASH if guide fails] ❌
    │
    └─→ GUIDE_ABORTED ──┘
        ↓
        Retry GUIDE only (WRONG!)
        └─→ Fails again
            └─→ Capture starts anyway
```

### AFTER (Complete Recovery):
```
STAGE_FOCUSING
    ↓
STAGE_FOCUS_COMPLETE
    ↓
STAGE_ALIGNING
    ↓
STAGE_ALIGN_COMPLETE
    ↓
STAGE_RESLEWING
    ↓
STAGE_RESLEWING_COMPLETE
    ↓
STAGE_GUIDING
    ├─→ GUIDE_GUIDING ──────────────┐
    │   ↓                           │
    │   STAGE_GUIDING_COMPLETE      │
    │   ↓                           │
    │   STAGE_CAPTURING             │
    │   ├─→ Capture running ✓        │
    │   │   ├─→ GUIDE_GUIDING ✓      │ (Health monitored)
    │   │   └─→ Complete ✓           │
    │   │                           │
    │   └─→ ❌ GUIDE_ABORTED/ERROR   │
    │       ↓                        │
    │       Capture ABORTS           │
    │       ↓                        │
    │       RECOVERY #1: Focus       │
    │           → Align → Guide      │
    │       ├─→ GUIDE_GUIDING ✓      │
    │       │   ↓ Resume Capture ✓  │
    │       └─→ ❌ Still fails       │
    │           ↓                    │
    │           RECOVERY #2: Focus   │
    │               → Align → Guide  │
    │           ├─→ GUIDE_GUIDING ✓  │
    │           │   ↓ Resume Capture │
    │           └─→ ❌ Still fails   │
    │               ↓                │
    │               RECOVERY #3: Focus
    │                   → Align → Guide
    │               ├─→ GUIDE_GUIDING ✓
    │               │   ↓ Resume Capture
    │               └─→ ❌ Still fails (3/3)
    │                   ↓
    │                   JOB_ABORTED
    │
    └─→ ❌ GUIDE_ABORTED (before capture)
        ↓
        RECOVERY #1: Focus → Align
        ├─→ GUIDE_GUIDING ✓
        │   ↓ Proceed to Capture
        └─→ ❌ Still fails
            ↓
            [Up to 3 attempts...]
```

---

## Recovery Decision Tree

```
Guide Module Reports Error (GUIDE_ABORTED or GUIDE_CALIBRATION_ERROR)
│
├─ Is Stage = STAGE_GUIDING?
│  │
│  ├─ YES → During calibration
│  │  │
│  │  ├─ Retry Count < MAX_FAILURE_ATTEMPTS (3)?
│  │  │  │
│  │  │  ├─ YES → Attempt Recovery
│  │  │  │  │
│  │  │  │  ├─ USE_FOCUS in pipeline?
│  │  │  │  │  ├─ YES → Start FOCUSING
│  │  │  │  │  └─ NO → Check next
│  │  │  │  │
│  │  │  │  ├─ USE_ALIGN in pipeline?
│  │  │  │  │  ├─ YES → Start ALIGNING  
│  │  │  │  │  └─ NO → Check next
│  │  │  │  │
│  │  │  │  └─ USE_GUIDE in pipeline?
│  │  │  │     ├─ YES → Retry GUIDE (with delay)
│  │  │  │     └─ NO → Error (guide must be enabled)
│  │  │  │
│  │  │  └─ NO (3/3 retries done) → JOB_ABORTED
│  │  │                               "Mount may be physically misaligned"
│  │  │
│  │  └─ Recovery Attempt in Progress?
│  │     ├─ YES → Wait (don't trigger multiple retries)
│  │     └─ NO → Proceed with recovery
│  │
│  └─ NO → Not in guiding stage (shouldn't happen)
│
└─ Is Stage = STAGE_CAPTURING?
   │
   ├─ YES → Guide failed during capture
   │  │
   │  ├─ USE_GUIDE in pipeline?
   │  │  │
   │  │  ├─ YES → ABORT Capture immediately
   │  │  │         Trigger recovery (same as above)
   │  │  │
   │  │  └─ NO → Capture continues (guide not required)
   │  │
   │  └─ Log: "guide failed during capture"
   │
   └─ NO → Different stage (ignore)
```

---

## Timing Diagram

### Scenario: Guide Failure → Recovery Cycle

```
Time    Module              Action                          Log Message
────    ──────              ──────                          ───────────
t=0     Scheduler           Start GUIDING_COMPLETE
t=5     Guide               Calibration starts
t=15    Guide               ❌ Calibration FAILS
        │
t=15    Scheduler(GUIDING)  Receive GUIDE_ABORTED
        │                   Increment guideFailureCount=1
        │
t=15+   Scheduler           Begin RECOVERY #1
        │                   Start FOCUSING
        │                   "restarting focus-align-guide recovery (1/3)"
        │
t=45    Focus               ✓ Focus complete
        │
t=45+   Scheduler           Start ALIGNING
        │
t=75    Align               ✓ Align complete  
        │
t=75+   Scheduler           Start GUIDING
        │
t=85    Guide               Calibration starts
t=100   Guide               ❌ Calibration FAILS AGAIN
        │
t=100   Scheduler(GUIDING)  Receive GUIDE_ABORTED again
        │                   Increment guideFailureCount=2
        │
t=100+  Scheduler           Begin RECOVERY #2
        │                   (Delay 10 seconds before retry)
        │                   "restarting focus-align-guide recovery (2/3)"
        │
t=110   [10 sec delay]
t=110+  Scheduler           Start FOCUSING
        │
t=140   Focus               ✓ Focus complete
        │
t=140+  Scheduler           Start ALIGNING
        │
t=170   Align               ✓ Align complete
        │
t=170+  Scheduler           Start GUIDING
        │
t=180   Guide               Calibration starts
t=195   Guide               ❌ FAILS THIRD TIME
        │
t=195   Scheduler(GUIDING)  guideFailureCount = 3 (reached MAX)
        │
t=195+  Scheduler           ABORT JOB
        │                   setState = JOB_ABORTED
        │                   findNextJob()
        │
        Job Aborted         "guiding procedure failed after 3 attempts.
                             Mount may be physically misaligned."
```

**Total Time:** ~210 seconds (~3.5 minutes) from first failure to final abort

---

## Capture Safety During Guide Failures

### BEFORE (Unsafe):
```
Guide State:     IDLE → SELECTING → CALIBRATING ❌ ABORTED
                 │                                  │
Capture State:                                      STARTING (❌ too early!)
                                                    ↓
                                                    Taking image (unguided)
                                                    ↓
                                                    Large star trails
                                                    ↓
                                                    Image discarded, but system
                                                    already moved mount
```

### AFTER (Safe):
```
Guide State:     IDLE → SELECTING → CALIBRATING ❌ ABORTED
                 │                                  │
                 │                                  └─→ Recovery Triggered
                 │                                      Focus → Align → Guide
                 │
Capture State:   [WAITS for guide to be GUIDING]
                 
                 After recovery: Guide = GUIDING ✓
                 ↓
                 STARTING
                 ↓
                 Taking image (with active guidance) ✓
                 ↓
                 Good quality image, star round
```

---

## Mount Safety Protection

```
Unguided Mount Behavior:
Time    Alt Error   Azm Error   Description
────    ─────────   ─────────   ───────────
t=0     -0.1°       +0.2°       Guide calibration fails
t=1     +0.3°       -0.4°       Mount drifts (no correction)
t=2     +0.7°       -0.8°       Error growing (exponential)
t=3     +1.4°       -1.6°       Large error, at physical limit
t=4     +2.8°       -3.2°       ❌ COLLISION with support column!
        [System Crash, Mount disabled, Images lost]

Guided Mount Behavior (with fix):
Time    Alt Error   Azm Error   Action
────    ─────────   ─────────   ──────
t=0     -0.1°       +0.2°       Guide calibration fails
t=0     Detected!               Capture aborts IMMEDIATELY
t=0+    Begin recovery          Focus → Align → Guide
t=30    ✓ Recovery succeeds     Mount re-engaged with guidance
        Guide = GUIDING         Errors stay < 0.5° (within tolerance)
        
        [No collision, system stable, ready to resume]
```
