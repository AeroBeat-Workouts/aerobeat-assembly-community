# AeroBeat Assembly MediaPipe Test Scene Port for Editor and Build Validation

**Date:** 2026-04-24  
**Status:** Complete  
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

### Task 4: Fix installed MediaPipe runtime importability for the temporary proof scene

**Bead ID:** `oc-1jq`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Fix the next discovered blocker in the temporary duplicated MediaPipe proof scene: the prepared addon runtime venv under the installed assembly addon path must be able to import `mediapipe`. Diagnose the exact install/runtime-prep failure, make the smallest truthful fix, and rerun the proof scene. Keep this temporary-proof scope tight and update the plan with exact evidence. Commit/push by default.

**Folders Created/Deleted/Modified:**
- `.qa-logs/`
- `.plans/`
- `addons/aerobeat-input-mediapipe/python_mediapipe/assets/runtimes/linux-x64/`

**Files Created/Deleted/Modified:**
- `.qa-logs/oc-1jq-pip-install.log`
- `.qa-logs/oc-1jq-import-check.log`
- `.qa-logs/oc-1jq-prepare-runtime.json`
- `.qa-logs/oc-1jq-runtime.log`
- `.plans/2026-04-24-assembly-mediapipe-test-scene-port-for-editor-and-build-validation.md`
- `addons/aerobeat-input-mediapipe/python_mediapipe/assets/runtimes/linux-x64/venv/**` (generated local runtime site-packages only; ignored)

**Status:** ✅ Complete

**Results:** Diagnosed the blocker directly in the installed addon runtime under `REF-05`: the prepared venv existed and the runtime contract files were present, but `mediapipe` was not actually installed inside `addons/aerobeat-input-mediapipe/python_mediapipe/assets/runtimes/linux-x64/venv/`. The exact failing baseline was `addons/aerobeat-input-mediapipe/python_mediapipe/assets/runtimes/linux-x64/venv/bin/python -c "import mediapipe"`, which raised `ModuleNotFoundError: No module named 'mediapipe'`, while `runtime-manifest.json` still reported only `"validation_status": "venv_created"`. That made the failure an honest runtime-prep gap, not a wrapper path bug.

Applied the smallest truthful fix without broadening architecture: installed the addon’s documented `python_mediapipe/requirements.txt` into the already-prepared installed-addon runtime venv. No source-code changes were required for this bead; only the generated local runtime contents changed. Exact evidence: `.qa-logs/oc-1jq-pip-install.log` shows `addons/aerobeat-input-mediapipe/python_mediapipe/assets/runtimes/linux-x64/venv/bin/python -m pip install -r addons/aerobeat-input-mediapipe/python_mediapipe/requirements.txt` completed successfully and installed `mediapipe-0.10.33`, `opencv-python-4.13.0.92`, `opencv-contrib-python-4.13.0.92`, and `numpy-2.4.4` into the installed runtime. `.qa-logs/oc-1jq-import-check.log` then confirmed `MEDIAPIPE_OK`, `CV2_OK`, `NUMPY_OK`, and `PYTHON_OK` from that exact installed-addon runtime python path. Re-running `python3 addons/aerobeat-input-mediapipe/python_mediapipe/prepare_runtime.py --platform linux-x64 --mode dev --validate --json` from the assembly repo still returned `"validation_errors": []` in `.qa-logs/oc-1jq-prepare-runtime.json`; the helper remains honest that plain `--validate` is contract-only and warns that dependency installation is outside that foundation pass unless separately performed.

Re-running the temporary proof scene advanced past the old blocker and reached live runtime behavior. `.qa-logs/oc-1jq-runtime.log` now shows: runtime python resolved from the installed addon path, `Python dependencies ready`, model asset validation passing, sidecar launch with PID `2976479`, UDP server bind on `127.0.0.1:4242`, camera HTTP stream connection to `127.0.0.1:4243`, and sustained stream stats before the intentional harness cutoff (`EXIT_CODE=124` from `timeout 12s`). So the prior `MediaPipe is not importable...` failure is fixed; no new blocker appeared in this bounded rerun.

---

### Task 5: QA/audit the temporary duplicated MediaPipe validation scene for editor/runtime/build proof

**Bead ID:** `oc-imp`  
**SubAgent:** `primary`  
**Role:** `qa` / `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Independently verify that the duplicated temporary MediaPipe validation scene/scripts open and run correctly in the assembly repo, and perform the best truthful Linux build-oriented validation available. Close only if the evidence supports that this temporary scaffolding genuinely proves the integration.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-24-assembly-mediapipe-test-scene-port-for-editor-and-build-validation.md`

**Status:** ✅ Complete

**Results:** Independent QA/audit reran the temporary proof surface directly against the current `main` at `612cd38` and confirmed the evidence holds. Exact rerun evidence recorded in `.qa-logs/oc-imp-*.log`: parse/load check via `~/.local/bin/godot --headless --path . -s .qa-logs/oc-izk-load-check.gd` logged `LOAD_CHECK_OK` and `INSTANTIATED TestScene` in `.qa-logs/oc-imp-load-check.log`, proving the duplicated scene/scripts still parse and instantiate in assembly. Headless editor-open via `~/.local/bin/godot --headless --path . --quit --editor` completed without MediaPipe parse/load failures in `.qa-logs/oc-imp-editor-open.log`, so the project still opens cleanly enough for truthful editor validation.

The old blockers are also independently cleared. `.qa-logs/oc-imp-path-check.log` shows `MODEL_PATH=/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/addons/aerobeat-input-mediapipe/python_mediapipe/assets/models/pose_landmarker_full.task`, `MODEL_EXISTS=true`, and `RUNTIME_VALID=true`, confirming the wrapper now resolves model assets from the installed addon path instead of the broken assembly-parent path. `.qa-logs/oc-imp-import-check.log` confirms the installed runtime venv can now import `mediapipe`, `cv2`, and `numpy`, so the prior `MediaPipe is not importable...` blocker from `REF-05` is no longer present.

Best truthful runtime rerun: `timeout 12s ~/.local/bin/godot --headless --path . scenes/mediapipe_test_scene.tscn` reached full temporary-proof behavior in `.qa-logs/oc-imp-runtime.log`: runtime Python resolved from the installed addon venv, dependency check passed (`Python dependencies ready`), model asset validation passed, detached sidecar launch succeeded, UDP server bound on `127.0.0.1:4242`, MJPEG camera stream connected on `127.0.0.1:4243`, and stream stats accumulated (`26205113 bytes, 642 frames`) before the intentional harness cutoff (`RUNTIME_EXIT_CODE=124` in `.qa-logs/oc-imp-exit-codes.txt`). That is strong enough evidence that this duplicated scene is now a truthful temporary proof surface for next-session interactive validation in assembly, even though it remains disposable scaffolding and not productized game flow.

Best truthful Linux build-oriented validation available remains blocked at project-export setup, not at the temporary MediaPipe scene itself. `~/.local/bin/godot --headless --path . --export-release "Linux/X11" build/oc-imp-test.x86_64` failed exactly because the repo root has no `export_presets.cfg`, as captured in `.qa-logs/oc-imp-export.log` and `EXPORT_PRESETS_PRESENT=false` in `.qa-logs/oc-imp-exit-codes.txt`. So this task proves editor-open and runtime proof-surface viability, but it does not prove assembly exportability yet.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** A temporary duplicated MediaPipe validation surface inside `aerobeat-assembly-community` consisting of `scenes/mediapipe_test_scene.tscn` plus its copied helper scripts and a temporary assembly-local autostart wrapper. Independent reruns now confirm the scene still parses, opens in the editor, resolves the installed addon runtime/model paths correctly, imports `mediapipe` from the installed runtime venv, launches the Python sidecar, binds the UDP provider, and connects to the camera MJPEG stream. This is sufficient as truthful disposable proof scaffolding for the next interactive validation session inside assembly.

**Reference Check:** `REF-01` satisfied: the MediaPipe `.testbed` proof surface was duplicated into assembly as temporary validation scaffolding rather than permanent product code. `REF-02` satisfied: the copied runtime scene/scripts remain faithful to the source testbed scope. `REF-03` satisfied: out-of-scope `.testbed/tests/**` and other nonessential harness files were not pulled into this proof pass. `REF-04` satisfied: `scenes/main.tscn` and main assembly wiring were not repurposed; the proof scene remains standalone. `REF-05` satisfied for the targeted blockers: the temporary scene now gets past the prior missing-model-path and missing-`mediapipe`-import failures. Deliberate remaining gap: Linux export proof is still blocked by missing root `export_presets.cfg`, so build/export success is not yet proven.

**Commits:**
- `05ed306` - Add temporary MediaPipe validation scene
- `9763158` - Fix temporary MediaPipe proof runtime asset resolution
- `612cd38` - Document installed MediaPipe runtime import fix
- `e86dc6b` - Audit temporary MediaPipe proof scene

**Lessons Learned:** For this addon, a truthful assembly proof surface depended more on validating the installed addon runtime contract than on wiring the assembly main scene. The temporary wrapper approach was sufficient to expose real blockers in order: first wrong model-asset resolution, then missing installed-runtime Python dependencies. Also, “best truthful build validation available” must explicitly report repo-export prerequisites; without `export_presets.cfg`, any claim of Linux export success would be fiction.

---

*Completed on 2026-04-24*
