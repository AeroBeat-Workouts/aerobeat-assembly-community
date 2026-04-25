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
- `scenes/mediapipe_test_scene.tscn`
- `src/mediapipe_test_scene.gd`
- `src/mediapipe_landmark_drawer.gd`
- `src/mediapipe_provider_test.gd`
- `src/mediapipe_test_autostart_manager.gd`
- `.qa-logs/oc-izk-load-check.gd`
- `.qa-logs/oc-izk-load-check.log`
- `.qa-logs/oc-izk-editor-open.log`
- `.qa-logs/oc-izk-runtime.log`
- `.qa-logs/oc-izk-export.log`
- `.plans/2026-04-24-assembly-mediapipe-test-scene-port-for-editor-and-build-validation.md`

**Status:** ✅ Complete

**Results:** Duplicated the four scoped `.testbed` assets from `REF-02` into assembly as `scenes/mediapipe_test_scene.tscn`, `src/mediapipe_test_scene.gd`, `src/mediapipe_landmark_drawer.gd`, and `src/mediapipe_provider_test.gd`, then retargeted their assembly-facing resource paths from `res://addons/aerobeat-input-mediapipe-python/...` to `res://addons/aerobeat-input-mediapipe/...`. The copied scene stays standalone and does not touch `scenes/main.tscn` / `InputManager`, satisfying `REF-01` / `REF-04`.

A fifth file, `src/mediapipe_test_autostart_manager.gd`, was added as a temporary validation-only wrapper copy because the mounted addon autostart script in the ignored addon tree still preloads `res://addons/aerobeat-input-mediapipe-python/...` and would not parse when the duplicated scene instantiated. The wrapper preserves the addon runtime/process implementation but pins runtime-path resolution back to `res://addons/aerobeat-input-mediapipe/src/autostart_manager.gd`, so the temporary validation scene can load against the assembly addon layout without changing ignored addon vendor files during this task.

Validation evidence:
- Parse/load proof: `~/.local/bin/godot --headless --path . -s .qa-logs/oc-izk-load-check.gd` succeeded and logged `LOAD_CHECK_OK` plus `INSTANTIATED TestScene` in `.qa-logs/oc-izk-load-check.log`.
- Best truthful editor-open check: `~/.local/bin/godot --headless --path . --quit --editor` succeeded with exit code `0` and no MediaPipe parse/load errors in `.qa-logs/oc-izk-editor-open.log`.
- Best truthful runtime check: `timeout 20s ~/.local/bin/godot --headless --path . scenes/mediapipe_test_scene.tscn` started the duplicated scene and reached AutoStartManager validation, then failed for a real environment reason — missing required model assets under `../python_mediapipe/assets/models/pose_landmarker_{full,heavy,lite}.task` — as captured in `.qa-logs/oc-izk-runtime.log`.
- Best truthful Linux build-oriented check available: direct export attempt `~/.local/bin/godot --headless --path . --export-release "Linux/X11" build/oc-izk-test.x86_64` failed immediately because the repo has no root `export_presets.cfg`; this exact limitation is recorded in `.qa-logs/oc-izk-export.log`. No synthetic export preset was invented during this task.

Reference check: copied scope matches `REF-02`; no `.testbed/tests/**`, `install_progress.gd`, or main-scene rewiring was introduced, honoring `REF-03` / `REF-04` / `REF-05`. Commit/push pending.

---

### Task 3: Fix temporary proof wrapper runtime path resolution

**Bead ID:** `oc-oeq`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Fix the temporary duplicated MediaPipe proof scene so its runtime/autostart wrapper resolves sidecar runtime assets from the installed addon path, not from the assembly-local `res://src/...` path. Keep the fix minimal and temporary, update the plan with exact evidence, and commit/push by default.

**Folders Created/Deleted/Modified:**
- `src/`
- `.qa-logs/`
- `.plans/`

**Files Created/Deleted/Modified:**
- `src/mediapipe_test_autostart_manager.gd`
- `.qa-logs/oc-oeq-load-check.log`
- `.qa-logs/oc-oeq-path-check.gd`
- `.qa-logs/oc-oeq-path-check.log`
- `.qa-logs/oc-oeq-runtime.log`
- `.plans/2026-04-24-assembly-mediapipe-test-scene-port-for-editor-and-build-validation.md`

**Status:** ✅ Complete

**Results:** Kept the fix temporary and local to `src/mediapipe_test_autostart_manager.gd` rather than rewriting the installed addon runtime helper. The wrapper now post-processes `DesktopSidecarRuntime.validate_runtime(...)` so manifest `model_assets[].relative_path` entries are re-resolved relative to the installed addon package root returned by `DesktopSidecarRuntime.get_package_root(ADDON_AUTOSTART_SCRIPT_PATH)`, not via the helper’s baked-in `res://../...` project-parent assumption. The wrapper also now logs the exact resolved model path when the required asset check passes.

Exact validation evidence:
- Parse/load still passes after the wrapper change: `~/.local/bin/godot --headless --path . -s .qa-logs/oc-izk-load-check.gd` logged `LOAD_CHECK_OK` and `INSTANTIATED TestScene`; mirrored run output captured in `.qa-logs/oc-oeq-load-check.log`.
- Direct path proof from the wrapper: `~/.local/bin/godot --headless --path . -s .qa-logs/oc-oeq-path-check.gd` logged `MODEL_PATH=/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/addons/aerobeat-input-mediapipe/python_mediapipe/assets/models/pose_landmarker_full.task`, `MODEL_EXISTS=true`, and `RUNTIME_VALID=true` in `.qa-logs/oc-oeq-path-check.log`. That is the installed addon path, not the prior assembly-parent `../python_mediapipe/...` path.
- Re-running the temporary proof scene (`timeout 25s ~/.local/bin/godot --headless --path . scenes/mediapipe_test_scene.tscn`) advanced past the old missing-model failure. `.qa-logs/oc-oeq-runtime.log` now shows runtime resolution at `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/addons/aerobeat-input-mediapipe/python_mediapipe/assets/runtimes/linux-x64/venv/bin/python`, then fails on the next truthful blocker: `MediaPipe is not importable from the prepared sidecar runtime` in that installed-addon runtime venv.

Reference check: still honors `REF-01` temporary-scaffolding scope and leaves the copied proof scene separate from `REF-04` main-scene wiring; no permanent addon architecture changes were introduced.

---

### Task 4: QA/audit the temporary duplicated MediaPipe validation scene for editor/runtime/build proof

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
