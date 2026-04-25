# AeroBeat Assembly MediaPipe Test Scene Port for Editor and Build Validation

**Date:** 2026-04-24  
**Status:** Draft  
**Agent:** Pico 🐱‍🏍

---

## Goal

Temporarily duplicate the MediaPipe Python `.testbed` validation scene/scripts into `aerobeat-assembly-community` so we can prove the integration works in editor and in Linux builds before deleting that temporary validation scaffolding.

---

## Overview

Derrick confirmed a real product-validation gap: even though the addon wiring/import/runtime cleanup passes have landed, the current assembly main scene is not the right surface for proving `aerobeat-input-mediapipe-python` actually works end-to-end inside `aerobeat-assembly-community`. For this slice, the most truthful path is to duplicate the proven validation surface from the MediaPipe repo’s `.testbed` instead of inventing a brand-new harness from scratch.

This is explicitly a temporary proof pass, not a permanent product feature. We should copy the existing MediaPipe `.testbed` scene/scripts into the assembly repo with the minimum adaptations required to run them against the assembly-installed addon paths, use them to prove editor/runtime/build behavior inside `aerobeat-assembly-community`, and then treat them as disposable validation scaffolding to be removed after the integration is proven. The work should therefore optimize for faithful duplication and truthful validation evidence, not long-term assembly architecture.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Derrick’s request to duplicate the MediaPipe `.testbed` scene/scripts into assembly for editor/build validation | current session, 2026-04-24 21:06 EDT |
| `REF-02` | Current MediaPipe `.testbed` scenes | `../aerobeat-input-mediapipe-python/.testbed/scenes/` |
| `REF-03` | Current MediaPipe `.testbed` test scripts | `../aerobeat-input-mediapipe-python/.testbed/tests/` |
| `REF-04` | Current assembly project/main scene wiring | `project.godot`, `scenes/main.tscn`, `src/main.gd` |
| `REF-05` | Current assembly addon/runtime state after input-core and MediaPipe cleanup | `.plans/2026-04-24-rename-assembly-core-addon-key-to-aerobeat-input-core.md`, `.plans/2026-04-24-mediapipe-linux-import-truth-pass.md` |

---

## Tasks

### Task 1: Audit the MediaPipe `.testbed` assets and define the minimal assembly port scope

**Bead ID:** `oc-5vl`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Inspect the MediaPipe `.testbed` scenes/scripts and determine the minimal truthful set that should be ported into `aerobeat-assembly-community` to validate MediaPipe in editor and Linux build contexts. Identify what can be copied directly, what must be adapted for assembly paths/wiring, and what should stay out of scope. Do not implement yet.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `scenes/`
- `src/`
- `tests/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-24-assembly-mediapipe-test-scene-port-for-editor-and-build-validation.md`

**Status:** ✅ Complete

**Results:** Audited `REF-02`/`REF-03` against the current assembly addon layout in `REF-04`/`REF-05`. Recommended the minimal truthful duplication scope as: `scenes/mediapipe_test_scene.tscn` (copied from `.testbed/scenes/test_scene.tscn`), `src/mediapipe_test_scene.gd` (copied from `.testbed/scenes/test_scene.gd`), `src/mediapipe_landmark_drawer.gd` (copied from `.testbed/scenes/landmark_drawer.gd`), and `src/mediapipe_provider_test.gd` (copied from `.testbed/scenes/mediapipe_provider_test.gd`). Those four files are the actual runtime surface required to reproduce the current MediaPipe proof scene inside assembly. The copied scene should remain a temporary validation-only surface, separate from `scenes/main.tscn`.

Assembly adaptation notes: update all addon resource paths from `res://addons/aerobeat-input-mediapipe-python/...` to the assembly truth path `res://addons/aerobeat-input-mediapipe/...` (matches `addons.jsonc` and the current assembly tests). In `mediapipe_test_scene.tscn` and `mediapipe_test_scene.gd`, retarget the autostart-manager and camera-view loads to that assembly addon mount. In `mediapipe_provider_test.gd`, retarget the `MediaPipeConfig` and `MediaPipeServer` preloads to the same assembly addon path. Keep the scene as a standalone validation entrypoint rather than wiring it through `InputManager` or replacing `scenes/main.tscn`; that preserves fidelity to the source testbed while minimizing assembly-specific drift.

Out of scope for the temporary duplication pass: `.testbed/scenes/install_progress.gd` (no companion scene and not used by `test_scene.tscn`), all `.testbed/tests/**` files including duplicated `landmark_drawer.gd` / `mediapipe_provider_test.gd`, unit tests, and `mocks/mock_mediapipe_server.py`, plus `.testbed/assets/videos/**`. Those files support unit/mock validation or future harness work, but they are not needed to run the actual camera-driven MediaPipe proof scene in editor/build contexts. Reference check: `REF-02`/`REF-03` audited; assembly path recommendation validated against `REF-04`/`REF-05`.

---

### Task 2: Duplicate the selected MediaPipe test scene/scripts into assembly and wire them just enough for proof

**Bead ID:** `oc-izk`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Duplicate the selected existing MediaPipe `.testbed` scene/scripts into `aerobeat-assembly-community` with the minimum path/wiring changes needed to run them against the assembly-installed addon layout. Treat them as temporary validation scaffolding for proof, not permanent assembly product code. Keep scope tight and update the plan with exact evidence. Commit/push by default.

**Folders Created/Deleted/Modified:**
- `scenes/`
- `src/`
- `tests/`
- `.plans/`

**Files Created/Deleted/Modified:**
- assembly validation scene/script/test files as needed
- `.plans/2026-04-24-assembly-mediapipe-test-scene-port-for-editor-and-build-validation.md`

**Status:** ⏳ Pending

**Results:** Pending.

---

### Task 3: QA/audit the temporary duplicated MediaPipe validation scene for editor/runtime/build proof

**Bead ID:** `oc-imp`  
**SubAgent:** `primary`  
**Role:** `qa` / `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Independently verify that the duplicated temporary MediaPipe validation scene/scripts open and run correctly in the assembly repo, and perform the best truthful Linux build-oriented validation available. Close only if the evidence supports that this temporary scaffolding genuinely proves the integration.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-24-assembly-mediapipe-test-scene-port-for-editor-and-build-validation.md`

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
