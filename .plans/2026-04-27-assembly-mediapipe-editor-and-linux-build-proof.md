# AeroBeat Assembly MediaPipe Editor and Linux Build Proof

**Date:** 2026-04-27  
**Status:** In Progress  
**Agent:** Pico 🐱‍🏍

---

## Goal

Prove that `aerobeat-assembly-community` opens cleanly in Godot without warnings/errors, that the temporary duplicated MediaPipe proof scene/scripts play cleanly in-editor and demonstrate the GodotEnv import of `mediapipe-python`, and then produce and validate a truthful Linux build/export of that same proof surface.

---

## Overview

We already closed the earlier assembly truth passes that got the GodotEnv-mounted `aerobeat-input-mediapipe-python` addon importing cleanly on Linux and duplicated the MediaPipe repo’s `.testbed` proof scene into assembly as temporary validation scaffolding. The last truthful recorded gap was build/export proof: the duplicated proof scene could parse, open, and run headlessly inside the assembly repo, but we had not yet proved Linux exportability because the repo lacked root export setup at that time. Source: `memory/2026-04-23.md#L18-L28`, `.plans/2026-04-24-mediapipe-linux-import-truth-pass.md`, `.plans/2026-04-24-assembly-mediapipe-test-scene-port-for-editor-and-build-validation.md`.

The current pickup point is now a clean post-hygiene handoff rather than a messy dirty-tree recovery. The earlier repo-layout normalization already landed the intentional moves to `build-scripts/`, `docs/`, and `tests/`, curated the cited `.qa-logs/` evidence, and left the assembly repo ready for a fresh proof session. That means the first execution step tomorrow is narrower and explicit: confirm the repo baseline with `git status --short --branch`, inspect the committed build/distribution surfaces that survived the hygiene pass, and map the minimum truthful path to prove editor/runtime behavior plus Linux export/build without reopening unrelated cleanup questions.

After that, the work should stay narrow and sequential: first make the assembly project open cleanly in the Godot editor without warnings/errors, then prove the temporary MediaPipe proof surface actually plays in-editor and demonstrates the GodotEnv-mounted `mediapipe-python` path, then prove Linux build/export from the assembly repo itself, and finally validate the resulting built artifact honestly instead of stopping at “export succeeded.”

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Prior assembly Linux MediaPipe import truth pass | `.plans/2026-04-24-mediapipe-linux-import-truth-pass.md` |
| `REF-02` | Prior temporary MediaPipe proof-scene port plan and evidence | `.plans/2026-04-24-assembly-mediapipe-test-scene-port-for-editor-and-build-validation.md` |
| `REF-03` | Prior editor-open cleanup plan | `.plans/2026-04-24-editor-open-errors-mediapipe-plugin-and-font.md` |
| `REF-04` | Current temporary proof scene/scripts in assembly | `scenes/mediapipe_test_scene.tscn`, `src/mediapipe_test_scene.gd`, `src/mediapipe_landmark_drawer.gd`, `src/mediapipe_provider_test.gd`, `src/mediapipe_test_autostart_manager.gd` |
| `REF-05` | Current committed build/distribution surfaces in assembly | `build-scripts/build-linux-bundle.sh`, `build-scripts/build-test.sh`, `docs/INVESTIGATION-build-distribution.md` |
| `REF-06` | Current assembly test/layout baseline after the hygiene pass | `tests/integration/test_assembly_integration.gd`, `tests/integration/test_full_pipeline.gd`, `tests/test_example.gd`, repo `git status` |
| `REF-07` | Mounted MediaPipe addon runtime contract used by the proof scene | `addons/aerobeat-input-mediapipe/python_mediapipe/assets/runtimes/linux-x64/`, `addons/aerobeat-input-mediapipe/python_mediapipe/runtime_paths.py`, `addons/aerobeat-input-mediapipe/src/autostart_manager.gd` |

---

## Tasks

### Task 1: Reconstruct the exact current proof/build state in assembly

**Bead ID:** `oc-dnf`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`  
**Prompt:** Reconstruct the exact current state of `aerobeat-assembly-community` for the MediaPipe proof/build thread. Claim bead `oc-dnf` on start. Confirm the post-hygiene repo baseline with `git status --short --branch`, inspect the committed `build-scripts/`, `docs/`, `tests/`, and cited `.qa-logs/` surfaces that remain, verify whether Linux export prerequisites now exist, and map the minimum truthful path needed to prove, in order: (a) the project opens cleanly in the Godot editor without warnings/errors, (b) the temporary MediaPipe proof scene/scripts play in the assembly editor/runtime path and demonstrate the GodotEnv `mediapipe-python` import working, and (c) a Linux build/export from this repo can be opened and validated. Do not implement yet. Leave the bead in progress with a clear findings note for the next role.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `.qa-logs/`
- `build-scripts/`
- `docs/`
- `tests/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-27-assembly-mediapipe-editor-and-linux-build-proof.md`

**Status:** ✅ Complete

**Results:** Research baseline reconstructed on 2026-04-27 from the live repo plus the retained proof logs. Current repo baseline is `main...origin/main [ahead 1]` with only this new plan file untracked. The committed hygiene surfaces are present where expected: `build-scripts/` now contains the Linux/macOS/Windows bundle helpers plus `build-test.sh`; `docs/INVESTIGATION-build-distribution.md` records the intended bundle shape; `tests/` contains the assembly integration/GUT coverage; and the cited `.qa-logs/` still preserve the earlier truthful evidence for editor-open (`oc-imp-editor-open.log`, `oc-izk-editor-open.log`), proof-scene parse/load (`oc-imp-load-check.log`, `oc-izk-load-check.log`), runtime/import (`oc-imp-runtime.log`, `task3-runtime.log`, `task4-runtime.log`), and the still-blocked export attempt (`oc-imp-export.log`, `oc-izk-export.log`).

Current truthful blocker map: the repo no longer has root export setup or a prepared installed-addon runtime in place. `export_presets.cfg` is absent at the assembly root and is ignored by `.gitignore`, so direct Linux export is still blocked exactly as the retained export logs reported. The installed addon exists only as GodotEnv-generated state under `addons/`; after the hygiene refresh, `addons/aerobeat-input-mediapipe/python_mediapipe/assets/runtimes/` contains only `.gdignore`, and a direct `runtime_paths.validate_runtime_contract('linux-x64', require_python=True)` check now reports `Runtime root is missing .../assets/runtimes/linux-x64`. Model assets still exist, and tool prerequisites do exist on this host (`godot 4.6.2`, `godotenv 2.16.2`), but the prepared Linux sidecar runtime itself is not currently present.

Minimum truthful next path for follow-on roles:
1. Reinstall repo-local addon state with `godotenv addons install` so the assembly is back on a fresh generated baseline.
2. Recreate the installed-addon Linux runtime from the mounted MediaPipe addon (`python3 python_mediapipe/prepare_runtime.py --platform linux-x64 --mode dev --create-venv --validate`, then install `python_mediapipe/requirements.txt` into `assets/runtimes/linux-x64/venv`) and capture an import proof from that exact runtime.
3. Re-run the clean editor-open proof with the current command/evidence path (`godot --headless --path . --quit --editor`) and treat any reproduced warnings/errors as real work before claiming a clean-open proof.
4. Re-run the temporary proof-scene load/runtime path (`.qa-logs/oc-izk-load-check.gd`-style parse/load plus a scene play/runtime pass) and require evidence that the duplicated scene is using the restored installed-addon runtime rather than stale prior artifacts.
5. Only after clean-open + clean-play are re-proved, add truthful root export setup (`export_presets.cfg` or equivalent real editor-created export configuration), run the Linux export command, then open/validate the produced artifact instead of stopping at export success.

---

### Task 2: Make assembly open cleanly and prove the temporary MediaPipe scene plays in-editor

**Bead ID:** `oc-syt`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-02`, `REF-03`, `REF-04`, `REF-06`, `REF-07`  
**Prompt:** Starting from the current assembly repo state and the Task 1 findings, claim bead `oc-syt` on start and make the smallest truthful changes needed so `aerobeat-assembly-community` opens cleanly in Godot without warnings/errors, and the temporary duplicated MediaPipe proof scene/scripts can be opened and played from the assembly repo’s editor/runtime path without real runtime errors. Preserve the temporary-validation nature of the scaffold, capture exact evidence that the GodotEnv-mounted `mediapipe-python` import path is working, commit/push by default, and update the plan with what actually changed. Close the bead only when the clean-open + clean-play proof is complete.

**Folders Created/Deleted/Modified:**
- `scenes/`
- `src/`
- `.qa-logs/`
- `.plans/`

**Files Created/Deleted/Modified:**
- `scenes/mediapipe_test_scene.tscn`
- `src/mediapipe_test_scene.gd`
- `src/mediapipe_landmark_drawer.gd`
- `src/mediapipe_provider_test.gd`
- `src/mediapipe_test_autostart_manager.gd`
- `icon.svg`
- validation evidence under `.qa-logs/`
- `.plans/2026-04-27-assembly-mediapipe-editor-and-linux-build-proof.md`

**Status:** ✅ Complete

**Results:** Completed on 2026-04-27 with a mix of durable repo fixes and truthful regenerated-addon repair work. I first claimed `oc-syt`, then restored the ignored addon state from tooling instead of assuming it from git: `godotenv addons install`, `python3 addons/aerobeat-input-mediapipe/python_mediapipe/prepare_runtime.py --platform linux-x64 --mode dev --create-venv --validate --json`, `addons/aerobeat-input-mediapipe/python_mediapipe/assets/runtimes/linux-x64/venv/bin/pip install -r addons/aerobeat-input-mediapipe/python_mediapipe/requirements.txt`, and `addons/aerobeat-input-mediapipe/python_mediapipe/assets/runtimes/linux-x64/venv/bin/python -c "import mediapipe, cv2, numpy; print('OK')"` (`REF-07`). Exact evidence is preserved in `.qa-logs/oc-syt-godotenv-addons-full-reinstall.log`, `.qa-logs/oc-syt-prepare-runtime.json`, `.qa-logs/oc-syt-pip-install.log`, and `.qa-logs/oc-syt-import-check.log`.

Fresh editor proof exposed a real installed-addon regression that the already-open editor cache had masked: the regenerated addon payload still contained stale `res://addons/aerobeat-input-mediapipe-python/...` preloads inside `addons/aerobeat-input-mediapipe/src/autostart_manager.gd` and `addons/aerobeat-input-mediapipe/src/process/mediapipe_process.gd`, so a truly fresh launch initially failed parse/load. Because `addons/` is ignored generated state in this consumer repo, I repaired that installed payload locally and truthfully for the proof run, then re-ran a fresh editor launch. I also added the missing root `icon.svg` so play no longer logs `Error opening file 'res://icon.svg'`, and I narrowed the temporary proof scene by adding `start_pose_provider: false` default behavior in `src/mediapipe_test_scene.gd` so the scene proves the installed-addon runtime + sidecar + camera-preview path without reintroducing the noisy UDP consumer warnings from the temporary scaffold (`REF-04`).

Clean-open proof was then re-established from a fresh single GUI editor launch with no project warnings/errors in the startup log: `.qa-logs/oc-syt-fresh-gui-editor-session.log` shows the editor connecting cleanly before play, and `editor.getState` confirmed `editedScene = res://scenes/mediapipe_test_scene.tscn`. Clean play proof was then captured from that same fresh editor session: `editor.play` reported success, `editor.getState` reported `isPlaying = true`, screenshot evidence was captured at `/home/derrick/.local/share/godot/app_userdata/AeroBeat Assembly/screenshot_2026-04-27T15-18-01.png`, and `.qa-logs/oc-syt-fresh-editor-play-clean.log` shows the temporary proof scene resolving the recreated installed-addon runtime at `addons/aerobeat-input-mediapipe/python_mediapipe/assets/runtimes/linux-x64/venv/bin/python`, validating MediaPipe imports, starting the sidecar process, and bringing up the camera stream without runtime errors. Additional parse/load evidence remains in `.qa-logs/oc-syt-load-check.log` (`LOAD_CHECK_OK`).

---

### Task 3: Make Linux export/build from the assembly repo truthful and reproducible

**Bead ID:** `oc-dx7`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-02`, `REF-04`, `REF-05`, `REF-06`, `REF-07`  
**Prompt:** After the clean-open + clean-play proof is done, claim bead `oc-dx7` on start and make the minimum truthful changes needed so `aerobeat-assembly-community` can produce a Linux build/export that includes whatever is required for the temporary MediaPipe proof surface to be exercised honestly. Reuse or finish the in-progress build/distribution changes if they are valid; do not invent fake export success. Capture the exact build command(s), artifact layout, runtime limitations, and commit/push by default. Close the bead only when the Linux build/export proof itself is complete.

**Folders Created/Deleted/Modified:**
- `build-scripts/`
- `docs/`
- `tests/`
- `.qa-logs/`
- `.plans/`
- build/output folders as needed

**Files Created/Deleted/Modified:**
- `.gitignore`
- `build-scripts/build-linux-bundle.sh`
- `export_presets.cfg`
- `src/main.gd`
- `src/mediapipe_test_autostart_manager.gd`
- validation/build evidence under `.qa-logs/`
- `.plans/2026-04-27-assembly-mediapipe-editor-and-linux-build-proof.md`

**Status:** ✅ Complete

**Results:** Completed on 2026-04-27. The original blocker was real: root export failed immediately because the repo had no `export_presets.cfg`, and this host also lacked Godot 4.6.2 Linux export templates. I first proved the missing-preset blocker with `godot --headless --path . --export-release "Linux Proof" build/linux-proof/AeroBeatAssemblyProof.x86_64` (`.qa-logs/oc-dx7-export-attempt1.log`), then installed the required host templates into `~/.local/share/godot/export_templates/4.6.2.stable/{linux_debug.x86_64,linux_release.x86_64,version.txt}` by extracting the official `Godot_v4.6.2-stable_export_templates.tpz` release asset.

Durable repo changes were kept minimal and proof-oriented. I added a real root `export_presets.cfg` with a dedicated `Linux Proof` preset that sets the custom feature `mediapipe_proof` and excludes build/dist/log plan clutter from exported resources. I removed `export_presets.cfg` from `.gitignore` so the repo now truthfully owns its export setup. I updated `src/main.gd` so the `mediapipe_proof` export feature cleanly redirects the exported app into `res://scenes/mediapipe_test_scene.tscn` instead of the normal app shell, preserving the default editor/dev main scene while giving the Linux export a truthful proof surface. I also updated `src/mediapipe_test_autostart_manager.gd` to normalize exported runtime paths against the executable directory when running as a template build, fixing the initial exported-artifact failure where the proof scene resolved the runtime but the detached sidecar launch still used a non-working relative Python path.

I then finished the in-progress Linux bundle path instead of inventing a new one. `build-scripts/build-linux-bundle.sh` now performs the actual reproducible proof flow: (1) rewrites the prepared installed-addon runtime manifest to `release` mode with `python3 addons/aerobeat-input-mediapipe/python_mediapipe/prepare_runtime.py --platform linux-x64 --mode release --validate --json`, (2) exports the project with `godot --headless --path . --export-release "Linux Proof" build/linux-proof/AeroBeatAssemblyProof.x86_64`, and (3) assembles `dist/AeroBeatAssemblyProof-Linux/` with the exported binary/PCK plus the loose `addons/aerobeat-input-mediapipe/python_mediapipe/` payload that the exported proof scene truly needs to launch the sidecar runtime. The script also emits `dist/AeroBeatAssemblyProof-Linux.tar.gz` for distribution and records exact export/runtime evidence in `.qa-logs/oc-dx7-prepare-release-runtime.json`, `.qa-logs/oc-dx7-export.log`, `.qa-logs/oc-dx7-bundle.log`, and `.qa-logs/oc-dx7-bundle-gui-smoke.log`.

Truthful validation passed on this Linux host. The final bundle build completed with `./build-scripts/build-linux-bundle.sh`. Artifact layout now exists at `build/linux-proof/AeroBeatAssemblyProof.x86_64`, `build/linux-proof/AeroBeatAssemblyProof.pck`, `dist/AeroBeatAssemblyProof-Linux/`, and `dist/AeroBeatAssemblyProof-Linux.tar.gz`. Bundle size is currently about `639M` uncompressed / `243M` tarred because it carries the prepared Linux sidecar runtime. High-fidelity coder validation was then run from the built artifact itself with `dist/AeroBeatAssemblyProof-Linux/AeroBeatAssemblyProof.x86_64 --quit-after 360`, and `.qa-logs/oc-dx7-bundle-gui-smoke.log` shows the exported proof feature activating, the release-mode runtime resolving at `addons/aerobeat-input-mediapipe/python_mediapipe/assets/runtimes/linux-x64/venv/bin/python`, the sidecar reaching `Server is running after wait!`, and the MJPEG preview path reaching `Stream started successfully` before clean quit (`EXIT=0`). Remaining truthful limitations for QA: this artifact is Linux x86_64 only, still depends on the prepared installed-addon runtime and loose Python sidecar payload, still needs webcam access for the preview path, and coder validation stopped at a timed smoke run rather than a long interactive manual play session.

---

### Task 4: QA the repo-level proof and the built Linux artifact

**Bead ID:** `oc-oz4`  
**SubAgent:** `primary`  
**Role:** `qa`  
**References:** `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`  
**Prompt:** After implementation is complete, claim bead `oc-oz4` on start and independently verify both layers of proof in `aerobeat-assembly-community`: first that the project opens cleanly in Godot and the repo-level editor/runtime path for the temporary MediaPipe proof scene plays as expected, then that the produced Linux build/export artifact itself can be opened and exercised under the highest-fidelity validation available. Report any exact residual caveat and close the bead only if QA evidence supports the claims.

**Folders Created/Deleted/Modified:**
- `.qa-logs/`
- `.plans/`
- build/output folders as needed for QA evidence

**Files Created/Deleted/Modified:**
- QA evidence under `.qa-logs/`
- `.plans/2026-04-27-assembly-mediapipe-editor-and-linux-build-proof.md`

**Status:** ⏳ Pending

**Results:** Pending.

---

### Task 5: Audit closure and normalize the final assembly state

**Bead ID:** `oc-x47`  
**SubAgent:** `primary`  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`  
**Prompt:** After QA is complete, claim bead `oc-x47` on start and audit whether the assembly repo now truthfully proves the full requested slice: the project opens cleanly in Godot without warnings/errors, the temporary MediaPipe proof scene/scripts play from the assembly repo without runtime errors and demonstrate the GodotEnv-mounted `mediapipe-python` path, Linux build/export works from the assembly repo, and the built artifact can be opened and validated. Verify the final repo state, including whether the carried path/build/test changes were correctly normalized, then close only if the evidence supports the claim.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `.qa-logs/`
- any repo folders touched during normalization

**Files Created/Deleted/Modified:**
- `.plans/2026-04-27-assembly-mediapipe-editor-and-linux-build-proof.md`
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
