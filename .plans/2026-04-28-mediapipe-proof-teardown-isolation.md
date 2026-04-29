# AeroBeat Assembly Community

**Date:** 2026-04-28  
**Status:** In Progress  
**Agent:** Pico 🐱‍🏍

---

## Goal

Isolate and fix the shared exported-app close-path bug in `aerobeat-assembly-community`, while distinguishing the cross-host X11 teardown failure from Cookie's extra NVIDIA/Vulkan escalation.

---

## Overview

The earlier handoff correctly narrowed the investigation enough to remove the broad proof-path kill fallback and re-test safely, but the latest cross-host evidence changes the root framing again. Both Cookie and Derrick's local desktop now reproduce a close-triggered X11 `BadWindow` failure on exported builds, including the no-sidecar control export. That means the shared base bug is no longer best described as MediaPipe proof teardown; it is more defensibly an exported-window close / X11 teardown problem.

What remains host-specific is the escalation layer. On Cookie, the shared close bug climbs into Vulkan/NVIDIA failure (`fence_wait`, segfault, `NVRM Xid 31`, `libnvidia-glcore`). On Derrick's local APU host, the same close path degrades into persistent `BadWindow` spam and a hang without the NVIDIA crash signature. The next slice should therefore inspect the shared exported close path first, compare control vs proof only for what they still share, and treat the Cookie GPU/driver behavior as a second-layer escalation rather than the primary root.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Cookie close-crash forensic plan and narrowed conclusions | `.plans/2026-04-28-cookie-close-crash-forensics.md` |
| `REF-02` | Cookie transfer/run notes for the current proof artifact | `.plans/2026-04-28-cookie-build-transfer-and-run.md` |
| `REF-03` | Proof scene teardown entrypoint | `src/mediapipe_test_scene.gd` |
| `REF-04` | Proof autostart/sidecar lifecycle management | `src/mediapipe_test_autostart_manager.gd` |

---

## Tasks

### Task 1: Truth-map the MediaPipe proof teardown path

**Bead ID:** `oc-zks`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-03`, `REF-04`  
**Prompt:** Inspect the current proof teardown path in `aerobeat-assembly-community`. Claim the assigned bead on start. Trace shutdown ordering through `src/mediapipe_test_scene.gd`, `src/mediapipe_test_autostart_manager.gd`, MJPEG stream shutdown, heartbeat handling, and detached sidecar cleanup. Produce a precise timeline of what closes what, where re-entrancy or double-stop risk exists, and what the most likely crash/reset trigger is. Do not implement yet unless the orchestrator updates the plan.

**Folders Created/Deleted/Modified:**
- `src/`

**Files Created/Deleted/Modified:**
- `src/mediapipe_test_scene.gd`
- `src/mediapipe_test_autostart_manager.gd`
- optional notes/log artifacts if needed

**Status:** ✅ Complete

**Results:** Research subagent completed and closed bead `oc-zks`. Truth-mapped teardown entry is `src/mediapipe_test_scene.gd:_stop_everything()` across WM_CLOSE / EXIT_TREE / PREDELETE. Current order is: stop `CameraView` stream, `queue_free` camera view, stop provider/UDP server, deliberately avoid async `AutoStartManager.stop_server()`, then sleep 200ms. Highest-risk code-supported trigger is the broad Linux cleanup in `src/mediapipe_test_autostart_manager.gd`, especially `pkill -9` patterns and `fuser -k -9 /dev/video0`, with secondary risk from `DesktopSidecarLauncher` PGID fallback-to-shell-PID race and tertiary risk from `CameraView.stop_stream()` waiting on thread completion before closing TCP. Recommended next slice: keep teardown process-group-targeted only, remove/disable broad `pkill`/`fuser` fallback from the proof path, and add explicit shutdown logging for `launch_info`, pid/pgid, and `terminate_sync()` results. No Cookie SSH evidence was needed for this code-path truth pass.

---

### Task 2: Implement the narrowest teardown fix/instrumentation needed

**Bead ID:** `oc-5zb`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-03`, `REF-04`  
**Prompt:** Based on the truth-mapped teardown findings, claim the assigned bead, implement the smallest safe fix or instrumentation set that addresses the likely MediaPipe proof teardown trigger, run relevant repo-local validation, commit/push by default, and document exactly what changed plus any remaining uncertainty.

**Folders Created/Deleted/Modified:**
- `src/`
- optional test/log helper locations if justified

**Files Created/Deleted/Modified:**
- `src/mediapipe_test_scene.gd`
- `src/mediapipe_test_autostart_manager.gd`
- any directly related teardown helper files

**Status:** ✅ Complete

**Results:** Coder subagent completed bead `oc-5zb` and pushed commit `da2baf6` (`Limit MediaPipe teardown to tracked sidecar process`). The assembly-scoped fix in `src/mediapipe_test_autostart_manager.gd` removed the broad Linux proof-path fallback kills (`pkill -9 -f python_mediapipe/main.py`, `pkill -9 -f main.py`, and `fuser -k -9 /dev/video0`), keeping teardown on `DesktopSidecarLauncher.terminate()` / `terminate_sync()` only. It also added explicit shutdown logging for full `launch_info`, launch `pid`, launch `process_group_id`, and terminate/terminate_sync results. Repo-local validation passed on `godot --headless --path . --import` and the GUT suite exited 0 with 10/11 passing; the one non-passing item was a pre-existing risky test (`test_cleanup_on_exit did not assert`). Remaining known risk not addressed by this assembly-only fix: nested addon `DesktopSidecarLauncher` still has the shell-PID fallback / PGID race, and Cookie end-to-end close behavior is not yet re-proven.

---

### Task 3: Verify shutdown behavior in the highest-fidelity environment available

**Bead ID:** `oc-fk8`  
**SubAgent:** `primary`  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and verify the shutdown behavior end to end. Validate both the sidecar-enabled proof path and an appropriate no-sidecar control path if still relevant. Capture whether the app closes cleanly, whether tracking still works before close, and whether any desktop-session reset evidence remains.

**Folders Created/Deleted/Modified:**
- runtime/log artifact locations as needed

**Files Created/Deleted/Modified:**
- QA notes/log artifacts as needed

**Status:** ✅ Complete

**Results:** QA completed bead `oc-fk8` with the updated live Cookie observation folded in. Current strongest conclusion: the previous full desktop-session reset appears mitigated or changed — AeroBeat closed, Derrick's browser stayed open, and Cookie's active X11/GNOME session remained alive. The Nerve backend also remained healthy (`127.0.0.1:3080` still served `/health` successfully), so the remaining collateral does not currently look like whole-session death or backend termination. The remaining failure surface now looks more like AeroBeat still crashing on close and destabilizing Brave-hosted Nerve app windows / their relaunch behavior. QA also confirmed launcher recovery is flaky rather than fully dead: relaunch printed `Opening in existing browser session.` and a live Nerve window was observed afterward. What remains unproven is Derrick's exact visible failure mode for the Nerve apps (closed, blank, hung, or failed-to-focus), and whether the browser-side instability is shared GPU/X11 fallout from the AeroBeat crash versus a separate Brave launcher/session-handoff issue.

---

### Task 4: Independently audit the claimed fix and evidence

**Bead ID:** `oc-79y`  
**SubAgent:** `primary`  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and independently audit the teardown investigation/fix. Check the plan, relevant diffs, validation output, and QA evidence. Confirm whether the remaining bug is actually resolved, only narrowed further, or still open. Close the bead only if the truth supports completion.

**Folders Created/Deleted/Modified:**
- audit notes if needed

**Files Created/Deleted/Modified:**
- audit notes/log artifacts as needed

**Status:** ✅ Complete

**Results:** Auditor completed bead `oc-79y`. Audit verdict: PASS if the claim is narrowly phrased as teardown kill-surface reduction plus a smaller bug boundary; FAIL if phrased as full bug resolution. The current evidence supports that the old exact "full desktop/X11/GNOME reset plus Nerve backend death" shape did not reproduce in the validated pass, but it does not prove the overall close-path bug is fixed or that the remaining collateral is definitively limited to Brave/Nerve windows. The most exact open problem is now a Cookie close-path abnormal crash event whose fallout appears browser/Nerve-like without yet ruling out a broader browser/X11/GPU disturbance. Recommended next slice: reproduce on a clean Cookie surface with synchronized AeroBeat shutdown logs plus exact Brave/Nerve window-state capture before close, immediately after close, and after one launcher retry; if code-first, the next narrow candidate is the nested addon `DesktopSidecarLauncher` shell-PID/PGID fallback race.

---

### Task 5: Reproduce on Cookie's clean surface and correlate Nerve window fallout

**Bead ID:** `oc-5b4`  
**SubAgent:** `primary`  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and use the freshly reset Cookie desktop/Nerve surface for a tight repro. Capture exact Brave/Nerve window state before AeroBeat close, immediately after close, and after one launcher retry. Correlate that with AeroBeat shutdown output, session state, and GPU/X11 journal lines. Goal: distinguish window-layer Nerve/Brave fallout from broader browser/X11/GPU disturbance while keeping the current close-path crash evidence tied to exact timestamps.

**Folders Created/Deleted/Modified:**
- `.qa-logs/`
- Cookie runtime/log locations as needed

**Files Created/Deleted/Modified:**
- QA notes/log artifacts as needed

**Status:** ⏳ In Progress

**Results:** Bead `oc-5b4` created after Derrick restored Cookie's terminal/Nerve surface to a clean baseline. This pass is specifically targeting the post-`da2baf6` crash boundary on a fresh station state instead of a possibly already-disturbed browser/app environment.

---

### Task 6: Reproduce the same close-path test on Derrick's terminal

**Bead ID:** `oc-d3o`  
**SubAgent:** `primary`  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and run the same close-path validation on Derrick's local terminal/desktop surface using the current post-`da2baf6` build. Capture whether the exported control/proof app reproduces the same X11 `BadWindow` / Vulkan `fence_wait` / segfault signature seen on Cookie, and compare any browser/session collateral. Keep the result directly comparable to the Cookie clean-surface repro.

**Folders Created/Deleted/Modified:**
- `.qa-logs/`
- local runtime/log locations as needed

**Files Created/Deleted/Modified:**
- QA notes/log artifacts as needed

**Status:** ⏳ In Progress

**Results:** Bead `oc-d3o` created to run a sibling repro on Derrick's local terminal so we can tell whether the remaining close-path crash is Cookie-specific or reproducible on another desktop surface with the same artifact family.

---

### Task 7: Research the shared exported-window close path and X11 teardown bug

**Bead ID:** `oc-c9r`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and analyze the shared exported-app close-path bug now reproduced on both Cookie and Derrick's local desktop. Compare control and proof close behavior to identify the common exported-window / X11 teardown path, the likely event-loop or window-destruction origin of the `BadWindow` spam, and the narrowest next implementation target. Treat Cookie's Vulkan/NVIDIA crash as a host-specific escalation layer rather than the primary shared root.

**Folders Created/Deleted/Modified:**
- `.qa-logs/`
- source locations as needed for investigation notes

**Files Created/Deleted/Modified:**
- investigation notes/log references as needed

**Status:** ⏳ In Progress

**Results:** Bead `oc-c9r` created after the cross-host comparison proved the shared base bug is the exported-app close/X11 teardown path rather than MediaPipe-specific teardown. This task will identify the narrowest next code target before another implementation pass.

---

### Task 8: Implement the assembly close-handler quit-deferral truth test

**Bead ID:** `oc-1lt`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and implement the smallest shared-root truth test in `aerobeat-assembly-community`: proof/control exports should no longer call `get_tree().quit()` directly from `NOTIFICATION_WM_CLOSE_REQUEST`. Use the narrowest safe deferral or normal-close approach that still preserves cleanup behavior, run repo-local validation, and commit/push by default. Keep scope tightly on the shared exported close path.

**Folders Created/Deleted/Modified:**
- `src/`
- optional test/log helper locations if justified

**Files Created/Deleted/Modified:**
- `src/mediapipe_control_test_scene.gd`
- `src/mediapipe_test_scene.gd`
- any tiny directly related helper files if truly needed

**Status:** ⏳ In Progress

**Results:** Bead `oc-1lt` created to test the current leading repo-level hypothesis: direct `get_tree().quit()` during `NOTIFICATION_WM_CLOSE_REQUEST` may be contributing to the shared exported-app X11 close failure. This pass stays in the assembly repo because control and proof both reproduce the base bug.

---

### Task 9: QA the quit-deferral truth test on exported builds

**Bead ID:** `oc-52u`  
**SubAgent:** `primary`  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and validate commit `9893331` on actual exported control/proof artifacts. Rebuild as needed, rerun the local-host close-path repro first for fast signal, and determine whether removing direct `get_tree().quit()` from `WM_CLOSE_REQUEST` changes the shared X11 `BadWindow` / hang behavior before any follow-up Cookie retest.

**Folders Created/Deleted/Modified:**
- `.qa-logs/`
- build/runtime artifact locations as needed

**Files Created/Deleted/Modified:**
- QA notes/log artifacts as needed

**Status:** ⏳ In Progress

**Results:** Bead `oc-52u` created to verify whether the assembly-level quit-deferral truth test changes exported close behavior in practice. The first pass is local-host QA for fast comparable signal against the prior `oc-d3o` baseline.

---

### Task 10: Research the deeper shared exported close root after the quit-deferral miss

**Bead ID:** `oc-340`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and analyze what control and proof still share below the scene-level `WM_CLOSE_REQUEST` handlers now that commit `9893331` failed to change the local exported close failure. Use the latest `oc-52u` and `oc-d3o` artifacts plus source inspection to identify the narrowest next target: repo-local shared runtime path, addon/runtime layer, minimal export harness, or likely upstream Godot/X11 behavior.

**Folders Created/Deleted/Modified:**
- `.qa-logs/`
- source locations as needed for investigation notes

**Files Created/Deleted/Modified:**
- investigation notes/log references as needed

**Status:** ⏳ In Progress

**Results:** Bead `oc-340` created after the assembly-level quit-deferral truth test failed to materially change the local exported close behavior. This pass is aimed one layer deeper than the scene handlers to find the next defensible target before more implementation or another Cookie retest.

---

### Task 11: Implement the direct trivial-scene export harness

**Bead ID:** `oc-6wn`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and add the smallest repo-local truth-test harness that exports directly into a trivial scene, skipping `scenes/main.tscn` and `src/main.gd` shared bootstrap/feature-switch logic entirely. Keep scope minimal and aimed at enabling the next close-path QA comparison. Run repo-local validation and commit/push by default.

**Folders Created/Deleted/Modified:**
- `src/`
- `scenes/`
- export/build config locations only if truly required

**Files Created/Deleted/Modified:**
- minimal harness scene/script/config files as needed
- build/export helper files only if truly needed

**Status:** ✅ Complete

**Results:** Coder completed bead `oc-6wn` and pushed commit `04eed80` (`Add direct close harness export`). This added a minimal direct-entry harness scene/script (`scenes/direct_close_harness.tscn`, `src/direct_close_harness.gd`), a `Linux Direct Close Harness` export preset, and `build-scripts/build-linux-direct-close-harness-bundle.sh`. The build helper temporarily rewrites `project.godot` `run/main_scene` only during export so the exported harness boots straight into the trivial scene and fully skips `scenes/main.tscn`, `src/main.gd`, and the feature-based bootstrap path. Validation included `bash -n` on the build script, a successful harness export, and `./dist/AeroBeatDirectCloseHarness-Linux/AeroBeatDirectCloseHarness.x86_64 --quit-after 120`. Export log: `.qa-logs/oc-6wn-export-direct-close-harness.log`. This change enables the next decisive QA comparison but does not claim the close bug is fixed.

---

### Task 12: QA the direct close harness export

**Bead ID:** `oc-muv`  
**SubAgent:** `primary`  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and run the new direct close harness export. Compare its close behavior to the existing control/proof exports to determine whether the shared exported close-path failure still reproduces when `main.tscn` / `main.gd` / bootstrap scene switching are skipped entirely.

**Folders Created/Deleted/Modified:**
- `.qa-logs/`
- build/runtime artifact locations as needed

**Files Created/Deleted/Modified:**
- QA notes/log artifacts as needed

**Status:** ✅ Complete

**Results:** QA completed bead `oc-muv`. The direct harness built from commit `04eed80` still reproduced the same local exported close failure: close request, retry, persistent `BadWindow` spam, hang until forced kill, and exit code `143`. Because this harness boots directly into `scenes/direct_close_harness.tscn` and skips `scenes/main.tscn`, `src/main.gd`, feature-based scene switching, and MediaPipe/bootstrap startup entirely, the result points away from repo-local bootstrap glue and toward export/runtime/windowing or upstream Godot X11 behavior. Key artifacts live under `.qa-logs/oc-muv/`.

---

### Task 13: Research upstream Godot/X11 ownership and minimal repro strategy

**Bead ID:** `oc-s6v`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and research the strongest next engine-level path now that even the direct trivial-scene harness still reproduces the exported close-path `BadWindow` hang. Compare against known Godot/X11 Linux close issues, identify what evidence is sufficient for upstream ownership, and define the smallest minimal repro extraction strategy if an upstream issue or engine-fork investigation is next.

**Folders Created/Deleted/Modified:**
- `.qa-logs/`
- source/doc note locations as needed for investigation notes

**Files Created/Deleted/Modified:**
- investigation notes/log references as needed

**Status:** ✅ Complete

**Results:** Research completed bead `oc-s6v`. The strongest current read is that engine/upstream ownership is now the leading hypothesis, but not yet absolute proof. Already enough: stop blaming AeroBeat bootstrap/gameplay flow as the primary suspect, justify an upstream-facing minimal repro effort, and reserve `gambit-godot` for deeper engine tracing only if needed. Missing proof at that point was a fresh non-AeroBeat minimal project reproducing the same hang. Recommended next step was exactly that: build a brand-new tiny Godot/Linux standalone repro, then reuse the same close harness and keep everything internal until Derrick reviews it.

---

### Task 14: Implement the fresh non-AeroBeat minimal repro package

**Bead ID:** `oc-doo`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and create a fresh tiny Godot/Linux repro package for the close-path hang hypothesis. It should be a brand-new minimal project or equivalently isolated export target with one trivial scene/UI and WM-close logging, not copied from AeroBeat app/bootstrap flow. Keep scope minimal, run repo-local validation, and commit/push by default. Do not file or prepare any upstream bug yet; this slice is only to build the test package.

**Folders Created/Deleted/Modified:**
- minimal repro project/export locations as needed
- build helper/config locations only if truly required

**Files Created/Deleted/Modified:**
- minimal repro scene/script/config/build files as needed

**Status:** ✅ Complete

**Results:** Coder completed bead `oc-doo` and pushed commit `cffaa52` (`Add standalone Linux close-path repro project`). The new standalone repro lives at `repros/linux-close-minimal/` with its own `project.godot`, `export_presets.cfg`, trivial `scenes/main.tscn`, `scripts/main.gd`, `build-linux-bundle.sh`, and `README.md`. It does not use AeroBeat bootstrap/app flow/addons. Validation passed for export/build and timed launch/quit. Logs: `repros/linux-close-minimal/.qa-logs/export.log` and `repros/linux-close-minimal/.qa-logs/bundle.log`. This enables the clean non-AeroBeat close-path test Derrick requested, still with no upstream bug filing.

---

### Task 15: QA the standalone minimal repro package

**Bead ID:** `oc-6q7`  
**SubAgent:** `primary`  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and run the fresh non-AeroBeat standalone Linux close-path repro package. Determine whether exported window close reproduces the same `BadWindow` hang behavior, keep the result comparable to the earlier local repro style when practical, and keep all work internal — do not file any upstream bug yet.

**Folders Created/Deleted/Modified:**
- `repros/linux-close-minimal/.qa-logs/`
- runtime/log artifact locations as needed

**Files Created/Deleted/Modified:**
- QA notes/log artifacts as needed

**Status:** ✅ Complete

**Results:** QA completed bead `oc-6q7`. The fresh standalone repro at `repros/linux-close-minimal/` reproduced the same exported close-path failure pattern under a comparable GNOME Wayland/Xwayland harness: no immediate exit, persistent `BadWindow` spam, hang until forced kill, exit code `143`, and a run profile closely matching the AeroBeat-derived repros. This strengthened the conclusion that the bug is not AeroBeat-specific app/bootstrap/addon code and instead points strongly toward Godot Linux/X11/Xwayland exported close behavior. Artifacts live under `.qa-logs/oc-6q7/` and `repros/linux-close-minimal/.qa-logs/`.

---

### Task 16: Research whether Godot GitHub already knows/fixes this close-hang bug

**Bead ID:** `oc-1i9`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and research whether the standalone minimal exported Linux close-path `BadWindow` hang is already known on Godot GitHub, and whether any issue or PR appears to match or fix it. Use the current standalone repro evidence as the comparison point. Keep this internal; do not file anything.

**Folders Created/Deleted/Modified:**
- investigation note locations as needed

**Files Created/Deleted/Modified:**
- research notes/log references as needed

**Status:** ✅ Complete

**Results:** Research completed bead `oc-1i9`. No convincing exact match was found on Godot GitHub for the current signature: standalone exported Linux app on GNOME Wayland/Xwayland where window close triggers persistent `BadWindow` spam and hangs until forced kill. There is overlap with a known family of Linux/X11/Wayland window lifecycle bugs — especially issues/PRs like `#102039`, `#114986`, `#103978`, `#102633`, `#111931`, and PRs `#102045` / `#54601` — but none cleanly capture or clearly fix this exact standalone exported close-hang pattern. Best classification: no close match found, but definitely adjacent to a known family.

---

### Task 17: Re-test the standalone repro with a real mouse-click close via desktop control

**Bead ID:** `oc-0wj`  
**SubAgent:** `primary`  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and run the standalone minimal repro again, but close its window using a real mouse-click / desktop-control path instead of `xdotool windowclose`. Goal: compare human-like close behavior against the automated WM-close repro while keeping all work internal.

**Folders Created/Deleted/Modified:**
- `repros/linux-close-minimal/.qa-logs/`
- desktop-control artifact locations as needed

**Files Created/Deleted/Modified:**
- QA notes/log artifacts as needed

**Status:** ⚠️ Blocked

**Results:** QA completed bead `oc-0wj` as a truthful blocked result. The standalone repro launched and the local session path was inspected first: host is GNOME Wayland, GNOME Remote Desktop is active, and the desktop-control skill's canonical real-click backend should be `/home/derrick/.openclaw/workspace/skills/desktop-control/scripts/libfreerdp-blind/build/blind_rdp_client`. That binary was missing, and the documented rebuild helper failed because `freerdp3`/`freerdp3-dev` is not installed, so a truthful real pointer click could not be executed. No fake fallback close path was substituted. Artifacts for the blocked attempt live under `.qa-logs/oc-0wj/`.

---

## Final Results

**Status:** ⚠️ Partial

**What We Built:** We fully narrowed the original Cookie close-crash mystery into a shared exported Linux close-path bug plus a Cookie-specific NVIDIA/Vulkan escalation layer. Along the way we removed the broad MediaPipe proof-path kill fallback (`da2baf6`), proved the no-sidecar control path avoids the original desktop-wipe symptom on Cookie, proved the shared base bug reproduces locally on both control and proof exports, tested and rejected the scene-level `WM_CLOSE_REQUEST -> get_tree().quit()` hypothesis (`9893331`), added a direct-entry harness (`04eed80`), and then added a fresh standalone non-AeroBeat minimal repro project (`cffaa52`) that still reproduces the same automated close hang. We also researched Godot GitHub and found related Linux/X11/Wayland window-lifecycle bug family overlap, but no convincing exact issue/PR match for this standalone exported close hang.

**Reference Check:** `REF-01` and `REF-02` remain useful provenance for how the investigation began on Cookie, but the current boundary has moved well beyond MediaPipe proof teardown. `REF-03` / `REF-04` remain historically relevant to the teardown isolation phase, yet the latest evidence weakens them as primary owners of the surviving base bug.

**Commits:**
- `da2baf6` - `Limit MediaPipe teardown to tracked sidecar process`
- `9893331` - `Stop direct quit in proof close handlers`
- `04eed80` - `Add direct close harness export`
- `cffaa52` - `Add standalone Linux close-path repro project`

**Lessons Learned:** Polyrepo teardown suspicion was a reasonable starting point, but the decisive progress came from turning each hypothesis into a smaller exportable truth test. The strongest current next step is not more AeroBeat app churn; it is to install the missing desktop-control dependency (`freerdp3-dev`) so the real-click close test can run, then decide whether to prepare an upstream Godot issue draft for Derrick's review based on the standalone repro plus any human-click result.

---

*Completed on 2026-04-28*
