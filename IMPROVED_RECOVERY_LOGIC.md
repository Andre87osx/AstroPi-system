# Ekos Scheduler - Improved Two-Stage Guide Recovery Logic

## Overview

This document describes the **improved guide failure recovery logic** that intelligently handles different types of guide failures with adaptive retry strategies.

## Problem Statement

The original fix had a limitation: when guide failed, it always attempted a full focus+align+guide recovery sequence immediately. This was inefficient for temporary issues like passing clouds, which only affect guide and can be resolved within seconds.

The improved logic separates guide recovery into two stages:
- **Stage 1:** Quick guide-only retries (fast, ~30 seconds total)
- **Stage 2:** Full calibration recovery (slow, ~2-3 minutes total)

This provides a balance between quick recovery for temporary issues and robust recovery for real problems.

---

## New Recovery Flow

```
Guide fails (GUIDE_ABORTED or CALIBRATION_ERROR)
│
├─── STAGE 1: QUICK RECOVERY (Guide-Only Retries)
│    │
│    ├─ Retry count: 0-3
│    ├─ Action: Retry GUIDE ONLY with timer delay
│    ├─ Delay: 5s for attempt #1, 10s for #2, 15s for #3
│    ├─ Time per attempt: ~5 seconds (quick!)
│    ├─ Total time: ~30 seconds max
│    │
│    └─ If succeeds: ✅ Go to capture
│       If fails 3x: ↓ Move to Stage 2
│
├─── STAGE 2: FULL RECOVERY (Focus+Align+Guide)
│    │
│    ├─ Trigger count: 4-6
│    ├─ Action: Full focus → align → guide sequence
│    ├─ Time per attempt: ~2-3 minutes
│    ├─ Total time: ~6-9 minutes max (3 attempts)
│    │
│    └─ If succeeds: ✅ Go to capture
│       If fails 3x: ↓ Move to Stage 3
│
└─── STAGE 3: GIVE UP (Move to Next Job)
     │
     ├─ Log: "Moving to next job or initiating shutdown"
     ├─ Reset: guideFailureCount = 0 (for next job)
     ├─ Action: Call findNextJob()
     │
     └─ Next job may succeed if issue was job-specific
```

---

## Code Implementation

### Retry Counting Logic

```cpp
// guideFailureCount tracks progress through both stages
guideFailureCount = 0  (start)
guideFailureCount = 1  (Stage 1, attempt #1)
guideFailureCount = 2  (Stage 1, attempt #2)
guideFailureCount = 3  (Stage 1, attempt #3)
guideFailureCount = 4  (Stage 2, deep recovery attempt #1)
guideFailureCount = 5  (Stage 2, deep recovery attempt #2)
guideFailureCount = 6  (Stage 2, deep recovery attempt #3) → findNextJob()
```

### Decision Tree

```cpp
if (guideFailureCount < MAX_FAILURE_ATTEMPTS)  // 0-2
{
    // STAGE 1: Quick guide-only retry
    guideFailureCount++;
    startGuidingWithDelay();
}
else if (guideFailureCount < MAX_FAILURE_ATTEMPTS * 2)  // 3-5
{
    // STAGE 2: Full recovery sequence
    guideFailureCount++;
    startFocusing();  // or startAstrometry() or startGuiding(true)
}
else
{
    // STAGE 3: Move to next job
    guideFailureCount = 0;
    findNextJob();
}
```

---

## Example Scenarios

### Scenario 1: Temporary Cloud (Happy Path)

```
Time    Event                           Action
────    ─────                           ──────
t=0     Guide failed (cloud passes)     Stage 1, attempt #1
t=5     Timer delay 5 seconds
t=5     Guide restarts                  Retry GUIDE ONLY
t=10    Guide succeeds! ✅              Reset guideFailureCount = 0
t=11    Resume capture                  Continue job normally
```

**Total recovery time: 11 seconds** ✨

### Scenario 2: Focus/Align Drift (Problem Solving)

```
Time    Event                           Action
────    ─────                           ──────
t=0     Guide fails (not cloud)         Stage 1, attempt #1
t=5     Guide fails again                Stage 1, attempt #2
t=15    Guide fails AGAIN               Stage 1, attempt #3
t=20    Still failing                   Move to Stage 2
t=20    Start FOCUS recovery            Full sequence
t=50    Focus complete
t=50    Start ALIGN
t=80    Align complete
t=80    Start GUIDE
t=90    Guide succeeds! ✅              Reset guideFailureCount = 0
t=91    Resume capture                  Continue job
```

**Total recovery time: 91 seconds** (~1.5 minutes) ✓

### Scenario 3: Mechanical Misalignment (Give Up)

```
Time    Event                           Action
────────────────────────────────────────────────
t=0     Guide fails                     Stage 1, attempt #1 → FAILS
t=15    Guide fails                     Stage 1, attempt #2 → FAILS
t=30    Guide fails                     Stage 1, attempt #3 → FAILS
t=60    Start full recovery             Stage 2, attempt #1
        Focus → Align → Guide
t=180   Full recovery fails             Move to Stage 2, attempt #2
t=360   Second full recovery fails      Move to Stage 2, attempt #3
t=540   Third full recovery fails       Stage 3 triggered
t=540   Log: "Moving to next job"       Reset counter, call findNextJob()
────────────────────────────────────────────────
Total: 540 seconds (~9 minutes)
Result: Job abandoned, next job attempted
```

**Prevents infinite loops while being thorough** 💪

---

## Smart Failure Handling During Recovery

### If Focus Fails During Stage 2 Recovery

```cpp
if (guideFailureCount > MAX_FAILURE_ATTEMPTS)  // In recovery mode
{
    // Don't try to recover focus recovery!
    // Just move to next job
    findNextJob();
}
```

**Benefit:** Avoids cascading failures (focus failure → align retry → guide retry → etc.)

### If Align Fails During Stage 2 Recovery

```cpp
if (guideFailureCount > MAX_FAILURE_ATTEMPTS)  // In recovery mode
{
    // Don't try to recover alignment recovery!
    // Just move to next job
    findNextJob();
}
```

**Benefit:** If mount is fundamentally misaligned, we detect this quickly and move on instead of wasting time.

---

## Log Messages for Diagnostics

### Stage 1 (Quick Recovery)
```
"Job 'M103' retrying guiding only (quick recovery attempt #1 of 3) in 5 seconds."
"Job 'M103' retrying guiding only (quick recovery attempt #2 of 3) in 10 seconds."
"Job 'M103' retrying guiding only (quick recovery attempt #3 of 3) in 15 seconds."
```

### Transition to Stage 2
```
"Job 'M103' quick retries exhausted. 
Starting full focus-align-guide recovery (deep recovery attempt #1 of 3)..."
```

### During Stage 2
```
"Job 'M103' restarting focus-align-guide recovery chain (attempt #1 of 3)..."
```

### If Focus Fails During Stage 2
```
"Job 'M103' focusing failed during guide recovery. 
Moving to next job or initiating shutdown."
```

### Final Failure
```
"Job 'M103' guiding recovery failed after 3 quick attempts and 3 deep attempts. 
Moving to next job or initiating shutdown."
```

---

## Configuration Parameters

```cpp
#define MAX_FAILURE_ATTEMPTS 3
#define RESTART_GUIDING_DELAY_MS 5000  // 5 second base delay
```

### How Delays Work

For stage 1 quick retries, delay increases with attempt number:
```
Attempt #1 delay: 5s × 1 = 5 seconds
Attempt #2 delay: 5s × 2 = 10 seconds
Attempt #3 delay: 5s × 3 = 15 seconds
```

This gives the system time to stabilize between retries.

---

## Performance Comparison

### Before This Improvement
```
Cloud passes:
    → Immediately starts FOCUS → ALIGN → GUIDE
    → Takes 2-3 minutes
    → Wastes time for temporary issue

Real problem:
    → Also tries FOCUS → ALIGN → GUIDE immediately
    → Works the same as cloud scenario
```

### After This Improvement
```
Cloud passes:
    → Retries guide only 3 times in 30 seconds
    → If cleared, resume immediately ⚡
    → 4x faster recovery for clouds!

Real problem:
    → Tries guide 3 times (30s)
    → Then does FOCUS → ALIGN → GUIDE
    → Total: ~2-3 minutes (same)
    → But gains useful information from first stage
```

---

## When to Use Each Stage

### Stage 1 (Quick Retries) Works Best For:
- ✅ Passing clouds
- ✅ Temporary atmospheric turbulence
- ✅ Brief equipment hiccups
- ✅ Auto-focus interference (temporary)

### Stage 2 (Full Recovery) Works Best For:
- ✅ Focus drift (temperature, mirror shift)
- ✅ Mount creep (periodic error)
- ✅ Guide star lost (but recoverable)
- ✅ Alignment error (wind, vibration)

### Stage 3 (Give Up) Indicates:
- ❌ Mechanical misalignment (loose gears)
- ❌ Camera disconnection
- ❌ Environmental issues (heavy clouds, dust)
- ❌ Fundamental equipment failure

---

## Integration with findNextJob()

When `findNextJob()` is called after guide recovery failure:

```
Current job: M103 (FAILED)
  ↓
Check next job in queue
  ↓
Next job: M45 (different object, different sky location)
  ↓
M45 may have better conditions:
  - Better focus position (different altitude)
  - Better alignment (different mount angle)
  - Better guide stars (different field)
  ↓
M45 may succeed even if M103 failed ✓
```

**This is why moving to next job can help:** Issues are often object-specific or position-specific.

---

## Recovery Sequence Details

### Stage 1: startGuiding() with Timer

```cpp
restartGuidingTimer.start(RESTART_GUIDING_DELAY_MS * guideFailureCount);
// Waits, then guide module is triggered by timer
// Takes ~5 seconds to calibrate
```

### Stage 2A: startFocusing()

```cpp
currentJob->setStage(SchedulerJob::STAGE_FOCUSING);
startFocusing();
// Takes ~30 seconds
// Auto-transitions to STAGE_FOCUS_COMPLETE
// Then getNextAction() → STAGE_ALIGNING
```

### Stage 2B: startAstrometry() [Align]

```cpp
currentJob->setStage(SchedulerJob::STAGE_ALIGNING);
startAstrometry();
// Takes ~30 seconds
// Auto-transitions to STAGE_ALIGN_COMPLETE
// Then getNextAction() → STAGE_GUIDING
```

### Stage 2C: startGuiding(true) [Reset Calibration]

```cpp
startGuiding(true);  // true = reset calibration
// Takes ~60-90 seconds
// Calibrates from scratch
// Transitions to STAGE_GUIDING_COMPLETE
// Then getNextAction() → STAGE_CAPTURING
```

---

## Safety Features

1. **Bounded Retries:** 6 attempts max (3 quick + 3 deep)
2. **Fast Failure Detection:** Moves to next job quickly if recovery unlikely
3. **Mode Detection:** Can distinguish between "in recovery" vs "normal operation"
4. **Cascading Failure Prevention:** If focus/align fails during recovery, don't retry
5. **Clear Diagnostics:** Log messages explain what stage and why

---

## Testing Recommendations

### Test 1: Cloud Simulation
1. Start job with guide running
2. Block guide star briefly (cover telescope)
3. Verify: Quick recovery within 30 seconds
4. Verify: No full focus/align recovery triggered

### Test 2: Focus Drift Simulation
1. Defocus the scope after alignment
2. Start job
3. Let focus fail and trigger recovery
4. Verify: Stage 1 fails 3x
5. Verify: Stage 2 starts focus recovery
6. Verify: Job resumes when recovery succeeds

### Test 3: Repeated Job Failures
1. Set up scenario where job will repeatedly fail
2. Let it fail in Stage 1 → Stage 2 → findNextJob()
3. Verify: Next job in queue is attempted
4. Verify: Log shows all recovery stages

### Test 4: Focus Recovery Failure
1. Break focus (simulate disconnection)
2. Trigger guide failure to start recovery
3. Verify: Focus fails during Stage 2
4. Verify: Log shows "focusing failed during guide recovery"
5. Verify: Immediately moves to findNextJob() (no retry)

---

## Future Enhancements

### Possible Improvements:
1. **Adaptive delay:** Increase delays if failures repeat
2. **Telemetry:** Log why each stage failed (better diagnostics)
3. **Smart stage skipping:** Skip focus if focus was just completed
4. **Time estimation:** Don't start recovery if not enough time until dawn

### Backward Compatibility:
✅ All changes are internal to Scheduler
✅ No API changes
✅ No configuration changes needed
✅ Existing jobs automatically benefit

---

## Summary

The two-stage recovery logic provides:
- ⚡ **Fast recovery** for temporary issues (clouds) in ~30 seconds
- 💪 **Robust recovery** for real problems with full recalibration
- 🛡️ **Safe failure** modes with bounded retries and intelligent next-job selection
- 📊 **Clear diagnostics** with detailed log messages for troubleshooting

**Result:** Smarter, more efficient scheduler that handles diverse failure scenarios appropriately.
