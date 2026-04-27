# AeroBeat Assembly Linux Desktop Identity Cleanup

**Date:** 2026-04-27  
**Status:** Complete  
**Agent:** Pico 🐱‍🏍

---

## Goal

Keep the Linux proof app windowed, but make it present like a normal desktop application with a cleaner AeroBeat identity in the taskbar/window metadata, then verify the behavior with a fresh export.

---

## Overview

The root cause turned out to be narrower than the original symptom suggested. The exported Linux proof app was already presenting as a normal desktop window; the earlier `_NET_WM_WINDOW_TYPE_UTILITY` and `_NET_WM_STATE_SKIP_TASKBAR` evidence came from editor/debug-run behavior or a lingering Godot child/play window, not from the exported build itself.

This slice therefore stayed narrow and truthful: keep the exported app windowed, clean up only the repo-owned desktop identity surfaces (`AeroBeat` project name/title/class + emitted `.desktop` metadata), and then rebuild a fresh export to verify normal-window behavior, cleaner taskbar/window identity, and intact MediaPipe proof-scene launch behavior.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Completed MediaPipe clean-open / play proof plan | `.plans/2026-04-27-assembly-mediapipe-editor-and-linux-build-proof.md` |
| `REF-02` | Linux proof export/bundle implementation | `build-scripts/build-linux-bundle.sh`, `export_presets.cfg`, `src/main.gd`, `src/mediapipe_test_autostart_manager.gd` |
| `REF-03` | Current observed utility/skip-taskbar window behavior | live `xprop` / `wmctrl` inspection from 2026-04-27 session |
| `REF-04` | Project desktop identity surfaces | `project.godot`, `icon.svg`, exported bundle metadata / launcher behavior |

---

## Tasks

### Task 1: Reconstruct the desktop-identity cause and map the minimum fix

**Bead ID:** `oc-i68`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Determine why the current Linux/windowed AeroBeat proof app presents as a utility/skip-taskbar window instead of a normal desktop app. Claim bead `oc-i68` on start. Distinguish editor/debug-run behavior from exported-app behavior, inspect the project/export settings and runtime title/class surfaces, and map the minimum truthful fix needed to keep the app windowed while making it look like a normal `AeroBeat` desktop app. Do not implement yet. Leave a clear findings handoff for implementation.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `.qa-logs/`
- `build-scripts/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-27-assembly-linux-windowed-desktop-identity.md`

**Status:** ✅ Complete

**Results:** Research completed. Fresh inspection of the existing Linux export showed the exported proof window is already a normal desktop window, not a utility window: `wmctrl -lx` reported `Godot_Engine.AeroBeat Assembly`, and `xprop` on the live export window reported `WM_CLASS = "Godot_Engine", "AeroBeat Assembly"`, `_NET_WM_WINDOW_TYPE_NORMAL`, and no `_NET_WM_STATE_SKIP_TASKBAR`. That means the earlier `_NET_WM_WINDOW_TYPE_UTILITY` / `_NET_WM_STATE_SKIP_TASKBAR` result was tied to editor/debug-run behavior or a lingering Godot child/play window from prior proof work, not the exported build itself. The project currently has no repo code or setting that explicitly marks the window as utility/skip-taskbar.

Minimum truthful implementation handoff: keep the app windowed, do not chase fullscreen/window mode settings, and focus only on desktop identity surfaces. `project.godot` currently sets `application/config/name="AeroBeat Assembly"`, which is feeding the exported window title and the second WM_CLASS string. Changing that to `AeroBeat` is the project-level way to clean up the visible title/class name. The first WM_CLASS string remains `Godot_Engine` in the exported binary and is not overridden anywhere in this repo; changing that would require engine/export-template support rather than a normal project setting. For better launcher/taskbar identity on Linux, the bundle script should also emit a `.desktop` launcher with `Name=AeroBeat`, the shipped icon, and `StartupWMClass` matching the exported window class string used after the rename. `build-scripts/build-linux-bundle.sh`, `export_presets.cfg`, and bundle naming are the main repo surfaces to adjust for that handoff. Verified against `REF-02`, `REF-03`, and `REF-04`. 

---

### Task 2: Implement normal desktop identity for the windowed Linux proof app

**Bead ID:** `oc-t29`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim bead `oc-t29` on start, then make the minimum truthful changes needed so the Linux proof app stays windowed but presents like a normal desktop app with cleaner `AeroBeat` identity in the taskbar/window class/title. Do not regress the MediaPipe proof path. Capture exact evidence, commit/push by default, and update the plan with what actually changed. Close the bead only when implementation is truly complete.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `.qa-logs/`
- `build-scripts/`
- `dist/`

**Files Created/Deleted/Modified:**
- `project.godot`
- `src/main.gd`
- `build-scripts/build-linux-bundle.sh`
- `.qa-logs/oc-t29-export.log`
- `.qa-logs/oc-t29-bundle-smoke.log`
- `.qa-logs/oc-t29-identity-evidence.txt`
- `.plans/2026-04-27-assembly-linux-windowed-desktop-identity.md`

**Status:** ✅ Complete

**Results:** Completed on 2026-04-27. I kept the proof app windowed and made only the minimum repo-owned identity changes: `project.godot` now sets `application/config/name="AeroBeat"`, which is the project-level source for the exported app title and the second Linux `WM_CLASS` string surfaced by Godot; `src/main.gd` now logs `AeroBeat started` instead of the older assembly title; and `build-scripts/build-linux-bundle.sh` now emits `dist/AeroBeatAssemblyProof-Linux/AeroBeat.desktop` with `Name=AeroBeat`, `StartupWMClass=AeroBeat`, `Icon=icon.svg`, and `Exec=AeroBeatAssemblyProof.x86_64` so the proof bundle has truthful Linux launcher/taskbar integration instead of only a raw binary. I deliberately did **not** change window mode/fullscreen behavior, and I did **not** claim control over the engine-owned first `WM_CLASS` string.

Exact evidence captured for this coder pass: `.qa-logs/oc-t29-export.log` records the fresh successful export/bundle rebuild after the identity changes; `.qa-logs/oc-t29-bundle-smoke.log` shows the rebuilt artifact still boots the MediaPipe proof path and exits `0`, now logging `AeroBeat started` before `Mediapipe proof export feature detected; launching proof scene`; and `.qa-logs/oc-t29-identity-evidence.txt` records the exact `project.godot` rename, emitted `AeroBeat.desktop` contents, and the presence of the new Godot user-data directory at `~/.local/share/godot/app_userdata/AeroBeat` alongside the older `AeroBeat Assembly` directory from prior runs. The remaining truthful limitation is unchanged from research: the first Linux `WM_CLASS` string is still engine-owned (`Godot_Engine`), so this repo can clean up the project name/title/launcher integration but cannot fully rebrand the engine-owned class prefix by itself.

---

### Task 3: Re-export and QA the windowed desktop identity

**Bead ID:** `oc-1w7`  
**SubAgent:** `primary`  
**Role:** `qa`  
**References:** `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim bead `oc-1w7` on start, produce a fresh Linux export after the identity changes, and independently verify that the app remains windowed, appears as a normal desktop app in Zorin/GNOME, has cleaner `AeroBeat` title/class identity, and still launches the MediaPipe proof path truthfully. Report any exact caveats and close only if QA evidence supports the claim.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `.qa-logs/`
- `dist/`
- build/output folders as needed

**Files Created/Deleted/Modified:**
- `.qa-logs/oc-1w7-build-linux-bundle.log`
- `.qa-logs/oc-1w7-desktop.png`
- `.qa-logs/oc-1w7-smoke.log`
- `.qa-logs/oc-1w7-window-inspection.txt`
- `.plans/2026-04-27-assembly-linux-windowed-desktop-identity.md`

**Status:** ✅ Complete

**Results:** Completed on 2026-04-27. I rebuilt the Linux proof bundle fresh with `./build-scripts/build-linux-bundle.sh`, producing a new `dist/AeroBeatAssemblyProof-Linux/` artifact and recording the successful export/bundle pass in `.qa-logs/oc-1w7-build-linux-bundle.log`. I then launched the exported app itself via `dist/AeroBeatAssemblyProof-Linux/run-proof.sh`, captured a host-local desktop screenshot at `.qa-logs/oc-1w7-desktop.png`, and inspected the live window with `wmctrl`, `xprop`, and `xwininfo` as recorded in `.qa-logs/oc-1w7-window-inspection.txt`.

Fresh exported app findings: the proof app still opens windowed, not fullscreen, with `xwininfo` and `wmctrl -lGx` showing a live 1152x648 window and the screenshot showing the AeroBeat titlebar on the visible Zorin desktop. The exported window now presents as a normal desktop window: `xprop` reported `_NET_WM_WINDOW_TYPE_NORMAL`, `Override Redirect State: no`, and no skip-taskbar state. Identity cleanup also landed truthfully in the live exported surface: `wmctrl -lx` showed `Godot_Engine.AeroBeat`, `xprop` showed `WM_CLASS = "Godot_Engine", "AeroBeat"`, and `WM_NAME = "AeroBeat"`, so the title and project-owned class/name now read `AeroBeat` instead of `AeroBeat Assembly`.

MediaPipe proof behavior also held on the fresh export. The live screenshot shows the duplicated proof scene with camera preview text/surface visible, and an independent exported smoke run via `dist/AeroBeatAssemblyProof-Linux/AeroBeatAssemblyProof.x86_64 --quit-after 300` exited 0 with QA log `.qa-logs/oc-1w7-smoke.log`, including `AeroBeat started`, `Mediapipe proof export feature detected; launching proof scene`, and `[CameraView] Stream started successfully`. Remaining caveat: the first `WM_CLASS` string is still engine-owned as `Godot_Engine`; QA also verified live window/title/class behavior and proof-scene launch, but did not independently certify installed `.desktop` launcher semantics beyond the emitted bundle-local `AeroBeat.desktop` artifact.

---

### Task 4: Audit closure

**Bead ID:** `oc-cwx`  
**SubAgent:** `primary`  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim bead `oc-cwx` on start, then audit whether the windowed Linux proof app now presents like a normal `AeroBeat` desktop app, still remains windowed, and still truthfully runs the MediaPipe proof path after fresh export verification. Close only if the evidence supports the claim and the plan reflects the final caveats accurately.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `.qa-logs/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-27-assembly-linux-windowed-desktop-identity.md`
- `.qa-logs/oc-cwx-audit.txt`

**Status:** ✅ Complete

**Results:** Completed on 2026-04-27. I audited the implementation commit `2dc1ed6` plus the fresh QA export evidence and recorded the closure review in `.qa-logs/oc-cwx-audit.txt`. The evidence supports the core claim: after a fresh export, the proof app still opens windowed (`1152x648`), presents as a normal desktop window (`_NET_WM_WINDOW_TYPE_NORMAL`, `Override Redirect State: no`, no skip-taskbar state), and truthfully launches the MediaPipe proof path (`AeroBeat started`, `Mediapipe proof export feature detected; launching proof scene`, `[CameraView] Stream started successfully`).

I also verified that the plan now reflects the real root cause and completion boundary. The earlier utility/skip-taskbar behavior belonged to editor/debug-run or lingering Godot child/play windows, not the exported app; the repo-owned cleanup correctly narrowed to project name/title/class surfaces plus the emitted bundle-local `.desktop` metadata. Closure is truthful with two explicit caveats preserved: the first `WM_CLASS` string remains engine-owned as `Godot_Engine`, and QA did not independently certify installed desktop-entry semantics beyond the emitted bundle-local `AeroBeat.desktop` artifact. Verified against `REF-02`, `REF-03`, and `REF-04`; no deviation found that blocks closure.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** We closed the Linux proof desktop-identity cleanup with a truthful scope boundary. The exported AeroBeat proof app remains windowed, now presents with cleaner project-owned desktop identity (`WM_NAME = AeroBeat`, second `WM_CLASS` string `AeroBeat`, bundle-local `AeroBeat.desktop` with `Name=AeroBeat` / `StartupWMClass=AeroBeat`), and still launches the MediaPipe proof scene after a fresh export. The audit also corrected the original diagnosis: the earlier utility/skip-taskbar behavior came from editor/debug windows, not the exported Linux proof app.

**Reference Check:** `REF-02`, `REF-03`, and `REF-04` are satisfied. The exported app and emitted launcher metadata match the repo-owned cleanup target, and the final plan accurately records the root cause and caveats. Deliberate remaining caveats: engine-owned first `WM_CLASS` string stays `Godot_Engine`, and installed desktop-entry semantics were not separately certified beyond the emitted bundle-local launcher artifact.

**Commits:**
- `2dc1ed6` - Clean up Linux proof desktop identity
- `12e40f6` - Audit Linux proof desktop identity closure

**Lessons Learned:** When Linux desktop identity looks wrong in Godot proof work, separate editor/debug-run windows from the exported artifact before changing project settings. For this repo, the truthful fix lived in project naming and emitted launcher metadata, not in fullscreen/window-mode behavior or any repo-owned utility-window flag.

---

*Completed on 2026-04-27*
