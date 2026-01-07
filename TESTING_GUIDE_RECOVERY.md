# Ekos Scheduler Guide Failure Recovery - Test Cases

## Test Setup

Use a scheduler job with:
- `USE_FOCUS` ✓
- `USE_ALIGN` ✓  
- `USE_GUIDE` ✓
- `USE_CAPTURE` ✓

Target: Any bright star or Messier object

## Test Case 1: Guide Failure During Calibration

**Objective:** Verify guide failure triggers focus→align→guide recovery

**Steps:**
1. Start scheduler job
2. Wait until guide enters "Calibrating" state
3. Manually abort guide (in Guide module panel, click "Abort")
4. Observe scheduler behavior

**Expected Results:**
- ✓ Log message: "guiding failed. Mount position unstable - restarting calibration chain"
- ✓ Scheduler transitions: GUIDING → FOCUSING
- ✓ Focus module starts automatically
- ✓ After focus completes: FOCUSING → ALIGNING  
- ✓ Align module starts automatically
- ✓ After align completes: ALIGNING → GUIDING
- ✓ Guide module restarts with fresh calibration
- ✓ After guide succeeds: GUIDING_COMPLETE → CAPTURING

**Failure Indicators:**
- ✗ Capture starts while guide is still IDLE (bug not fixed)
- ✗ Scheduler only retries guide without focus/align
- ✗ Mount moves erratically without proper guidance

---

## Test Case 2: Guide Failure During Capture

**Objective:** Verify guide failure during capture aborts capture and triggers recovery

**Steps:**
1. Start scheduler job
2. Let it proceed through focus, align, and guide
3. Wait until capture starts (image being taken)
4. Manually abort guide while capture is running
5. Observe scheduler behavior

**Expected Results:**
- ✓ Log message: "guide failed during capture. Aborting capture and restarting guide"
- ✓ Capture is immediately aborted (CCD stop exposure)
- ✓ Current image is discarded (not saved or partial)
- ✓ Scheduler transitions: CAPTURING → GUIDING (recovery mode)
- ✓ Focus restarts (if in pipeline)
- ✓ Align restarts (if in pipeline)
- ✓ Guide restarts with calibration
- ✓ After recovery succeeds, capture resumes

**Failure Indicators:**
- ✗ Capture continues despite guide being offline
- ✗ Mount drifts without guidance
- ✗ Images have trailing due to unguided motion
- ✗ Multiple images saved before recovery triggered

---

## Test Case 3: Maximum Retry Threshold

**Objective:** Verify job aborts after 3 consecutive guide failures

**Steps:**
1. Set up a scenario where guide will repeatedly fail:
   - Use poor focus position, or
   - Use misaligned mount, or
   - Use incorrect camera settings
2. Start scheduler job
3. Count guide failure/recovery attempts
4. After 3 failed retries, observe final behavior

**Expected Results:**
- ✓ First failure: Focus → Align → Guide recovery (attempt #1 of 3)
- ✓ Second failure: Focus → Align → Guide recovery (attempt #2 of 3)
- ✓ Third failure: Focus → Align → Guide recovery (attempt #3 of 3)
- ✓ Fourth failure: Job aborted with message "Mount may be physically misaligned"
- ✓ Scheduler stops (does not attempt to continue)
- ✓ No capture images taken after job abort

**Failure Indicators:**
- ✗ Recovery retries after failure #3 (infinite loop)
- ✗ Capture attempted despite repeated guide failures
- ✗ Mount continues moving without proper alignment

---

## Test Case 4: Guide Failure with No Focus in Pipeline

**Objective:** Verify recovery sequence adapts when focus not enabled

**Steps:**
1. Configure scheduler job WITHOUT focus (uncheck USE_FOCUS)
2. BUT keep: USE_ALIGN ✓, USE_GUIDE ✓
3. Start job and manually abort guide during calibration
4. Observe recovery sequence

**Expected Results:**
- ✓ Log message: "restarting align-guide recovery chain"
- ✓ Focus is NOT called (respects pipeline config)
- ✓ Align starts immediately: GUIDING → ALIGNING
- ✓ After align: ALIGNING → GUIDING
- ✓ Capture proceeds after guide succeeds

**Failure Indicators:**
- ✗ Focus is called even though not in pipeline
- ✗ Recovery sequence doesn't adapt to available modules
- ✗ Wrong stage transitions occur

---

## Test Case 5: Guide Failure with No Align in Pipeline

**Objective:** Verify recovery sequence when align not enabled

**Steps:**
1. Configure scheduler job WITHOUT align (uncheck USE_ALIGN)
2. BUT keep: USE_FOCUS ✓, USE_GUIDE ✓
3. Start job and manually abort guide during calibration
4. Observe recovery sequence

**Expected Results:**
- ✓ Log message: "restarting focus-align-guide recovery chain" (but align won't be called)
- ✓ Focus starts: GUIDING → FOCUSING
- ✓ After focus completes: FOCUSING → GUIDING (skips align, respects pipeline)
- ✓ Guide restarts immediately after focus

**Failure Indicators:**
- ✗ Align is called even though not in pipeline
- ✗ Job stops or hangs due to missing module

---

## Test Case 6: Capture Pre-Check Prevention

**Objective:** Verify capture cannot start if guide is in error state

**Steps:**
1. Configure job with guide enabled
2. Start job and let it complete through focus and align
3. Just before guide starts, monitor the guide module
4. When guide is in "Selecting star" state, manually set it to error state
   - Option A: Abort from Guide panel
   - Option B: Disconnect guide camera temporarily
5. Observe scheduler behavior when it tries to start capture

**Expected Results:**
- ✓ Log message: "detected guide error before capture. Restarting focus-align-guide sequence"
- ✓ Capture does NOT start
- ✓ Focus is immediately restarted
- ✓ Align restarts after focus
- ✓ Guide restarts after align
- ✓ Only after guide succeeds does capture start

**Failure Indicators:**
- ✗ Capture starts despite guide being in error
- ✗ Mount unguided images are captured
- ✗ No recovery sequence triggered

---

## Test Case 7: Recovery Delay Timer

**Objective:** Verify recovery uses appropriate delay between retries

**Steps:**
1. Configure job with guide, focus, and align
2. Trigger a guide failure (manual abort)
3. Monitor the time interval between guide failure and recovery start
4. Check log message for "will be restarted in N seconds"

**Expected Results:**
- ✓ Log shows: "guiding procedure will be restarted in 5 seconds" (for attempt #1)
- ✓ Recovery does NOT start immediately (5 second delay)
- ✓ For attempt #2: delay is 10 seconds
- ✓ For attempt #3: delay is 15 seconds
- ✓ Delays increase to give hardware time to stabilize

**Failure Indicators:**
- ✗ Recovery starts immediately (no delay)
- ✗ Delays don't increase with retry count
- ✗ Mount thrashing due to rapid consecutive retries

---

## Logging Best Practices

When testing, save the log file and check for these message patterns:

```
"Job '%s' guiding failed. Mount position unstable"
"Job '%s' restarting focus-align-guide recovery chain"
"Job '%s' restarting align-guide recovery chain"  
"Job '%s' guiding procedure will be restarted in %d seconds"
"guide failed during capture. Aborting capture"
"detected guide error before capture"
"guiding procedure failed after 3 attempts"
"Mount may be physically misaligned"
```

## Performance Considerations

- Each retry cycle (focus + align + guide) takes ~2-3 minutes
- 3 retries = ~6-9 minutes worst case before job aborts
- For jobs scheduled near dawn, 3 retries may exceed twilight limit
- Consider this when setting `FINISH_AT` completion times

## Integration with Other Features

- ✓ Compatible with in-sequence-focus
- ✓ Compatible with meridian flip
- ✓ Compatible with scheduler job loops (FINISH_LOOP)
- ✓ Compatible with multi-object jobs
- ✓ Respects altitude and moon separation constraints

## Known Limitations

1. **Offline guide camera:** If guide camera becomes completely disconnected, recovery will fail after MAX_FAILURE_ATTEMPTS. Consider adding hardware monitoring.

2. **Focus/Align camera issues:** If focus or align camera fails, the recovery chain stops at that module. Implement cascading error handling for multi-stage pipelines.

3. **Physical mount issues:** Large periodic errors (> 3 pixels) indicate mechanical problems (loose gears, etc). The fix prevents system crash but doesn't diagnose hardware issues.
