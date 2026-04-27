# AeroBeat Assembly Linux Desktop Identity Cleanup

**Date:** 2026-04-27  
**Status:** In Progress  
**Agent:** Pico 🐱‍🏍

---

## Goal

Keep the Linux proof app windowed, but make it present like a normal desktop application with a cleaner AeroBeat identity in the taskbar/window metadata, then verify the behavior with a fresh export.

---

## Overview

The current proof/export work is functionally correct, but the live window Derrick saw is presenting like a Godot debug/utility child window instead of a normal desktop app. On this host, the observed proof window was tagged with `_NET_WM_WINDOW_TYPE_UTILITY` and `_NET_WM_STATE_SKIP_TASKBAR`, which explains why it did not appear in the Zorin taskbar like a normal app.

This follow-up slice should stay narrow: fix the exported/windowed app identity without regressing the MediaPipe proof path. That means we need to identify whether the bad identity is coming from editor/debug launch behavior, export metadata, project settings, runtime window-title code, or Linux desktop integration details — then rebuild a fresh export and verify taskbar presence, title/class quality, and proof-scene behavior.

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
- fresh QA/export evidence under `.qa-logs/`
- `.plans/2026-04-27-assembly-linux-windowed-desktop-identity.md`

**Status:** ⏳ Pending

**Results:** Pending.

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
- final audit evidence under `.qa-logs/`

**Status:** ⏳ Pending

**Results:** Pending.

---

## Final Results

**Status:** ⏳ Pending

**What We Built:** Pending.

**Reference Check:** Pending.

**Commits:**
- Pending.

**Lessons Learned:** Pending.

---

*Completed on Pending*
