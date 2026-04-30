# AeroBeat Assembly Community

**Date:** 2026-04-29  
**Status:** Draft  
**Agent:** Pico 🐱‍🏍

---

## Goal

Determine the cleanest, safest way for AeroBeat Linux exports to prefer or force native Wayland so the exported-app close-path bug can be avoided locally while preserving a truthful fallback story.

---

## Overview

The latest validation split the bug cleanly by backend: the standalone exported repro still fails on the comparable default X11/Xwayland path, but closes normally on forced native Wayland under Godot 4.7 beta1. That means the most useful local follow-up is no longer broad crash hunting — it is workaround design.

This plan keeps the scope narrow and practical. First we should research what knobs Godot/Linux exports actually support for display-driver/backend selection at runtime and whether there is a clean packaging or launcher-layer way to prefer Wayland without hard-breaking X11-only environments. Then, if the path looks sane, we can implement the smallest reversible workaround in the assembly repo, validate it on the exported proof/minimal repro path, and independently audit whether it gives Derrick a real local mitigation instead of just a lab result.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Godot 4.7 close-hang validation plan | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-29-godot-4-7-close-hang-check.md` |
| `REF-02` | Standalone close-repro memory writeup | `/home/derrick/.openclaw/workspace/memory/2026-04-29-linux-close-repro.md` |
| `REF-03` | Standalone minimal repro project | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/repros/linux-close-minimal/` |
| `REF-04` | Assembly repo exported-app/build scripts and launchers | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/` |

---

## Tasks

### Task 1: Research the cleanest Linux Wayland-preference workaround shape

**Bead ID:** `oc-wn3`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and research the cleanest, safest workaround shape for preferring native Wayland on Linux for AeroBeat/Godot exports. Determine what Godot runtime flags, environment variables, launcher patterns, or packaging-layer choices are available; whether Wayland preference can be made opt-in vs default; and what fallback story exists for X11-only systems. Recommend the single best workaround shape to implement first in `aerobeat-assembly-community`, with rollback considerations.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-29-linux-wayland-workaround-path.md`

**Status:** ✅ Complete

**Results:** Research completed and bead `oc-wn3` was closed. Best first workaround shape is launcher-level backend selection, not a deep app/project-setting change: on Linux Wayland sessions, launch exported Godot binaries with `--display-driver wayland`; otherwise keep the existing path unchanged. This is supported in release exports, matches the already-validated clean path from the 4.7-beta1 repro work, and is more reversible than setting `display/display_server/driver.linuxbsd = wayland` project-wide. Recommended safety rails: explicit opt-out such as `AEROBEAT_FORCE_X11=1` and/or a `--x11` launcher flag, with optional explicit `--wayland` opt-in. Generic toolkit env vars were not judged to be the right primary control surface for Godot here.

---

### Task 2: Implement the smallest reversible Wayland-preference workaround

**Bead ID:** `oc-9y4`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and implement the smallest reversible workaround recommended by Task 1 for preferring native Wayland on Linux in `aerobeat-assembly-community`. Keep scope tight: launcher/build/export wrapper level if possible, not deep engine/app changes. Preserve a truthful fallback path and document how to disable/revert the workaround.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/`

**Files Created/Deleted/Modified:**
- `build-scripts/templates/godot-linux-launch.inc.sh`
- generated/exported Linux launcher wrappers and `.desktop` launchers
- generated bundle README text documenting Wayland preference and rollback
- proof bundle launcher path
- proof-control bundle launcher path
- direct-close harness bundle launcher path
- minimal repro Linux bundle launcher path

**Status:** ✅ Complete

**Results:** Implemented the launcher-side workaround and pushed commit `436104c` (`Prefer Wayland in Linux export launchers`). The repo now adds `--display-driver wayland` automatically on Wayland sessions at the Linux launcher-wrapper layer, leaves non-Wayland/X11-only paths unchanged, and provides explicit rollback/override controls via `AEROBEAT_FORCE_X11=1`, `--x11`, `--wayland`, and respect for any pre-existing `--display-driver ...` passed by the operator. Linux `.desktop` launchers were updated to call the wrapper rather than bypassing it, and bundle README text was refreshed to document behavior and rollback. Validation passed for shell syntax plus rebuilds of the proof, proof-control, direct-close harness, and minimal repro bundles.

---

### Task 3: Validate the workaround on exported Linux runs

**Bead ID:** `oc-dhd`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and validate the implemented Wayland-preference workaround on the exported Linux path. Confirm whether it truly steers the app onto the expected backend, whether close behavior stays clean, and whether fallback behavior remains sane when Wayland preference is unavailable or disabled.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-dhd/`

**Status:** ✅ Complete

**Results:** QA validated the launcher workaround on an actual Wayland session using the exported wrapper `repros/linux-close-minimal/dist/GodotClosePathMinimal-Linux/run.sh`. Plain `./run.sh` now auto-injects `--display-driver wayland`, lands on a native Wayland path, and closes cleanly with `WM_CLOSE_REQUEST`, exit `0`, and no forced kill or `BadWindow`. The X11 rollback/override paths remain truthful and operator-controlled: both `AEROBEAT_FORCE_X11=1 ./run.sh` and `./run.sh --x11` disable the workaround, exercise the X11/Xwayland path, and reproduce the known bad close behavior (`BadWindow`, hang, forced kill, exit `143`). Explicit `--wayland` and pre-supplied `--display-driver ...` handling also worked as intended. This makes the workaround look like a real local mitigation on the exercised export path, not just a beta-only lab result.

---

### Task 4: Audit whether the workaround is good enough for local mitigation

**Bead ID:** `oc-h8u`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and independently audit whether the implemented Wayland-preference workaround is a truthful local mitigation rather than a brittle demo. Review the research rationale, implementation diff, validation artifacts, reversibility, and fallback story. Decide whether the workaround is ready for Derrick to use locally while we prepare any upstream issue.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/`

**Files Created/Deleted/Modified:**
- audit notes to be linked in plan/results summary

**Status:** ⏳ Pending

**Results:** Pending.

---

## Final Results

**Status:** ⚠️ Partial

**What We Built:** Draft plan created for turning the Wayland-vs-X11 split into a real local mitigation path.

**Reference Check:** No execution yet; draft plan only.

**Commits:**
- None yet.

**Lessons Learned:** Backend-specific evidence is only useful if we can package it into a real operator-facing workaround.

---

*Completed on 2026-04-29*
