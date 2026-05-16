# AeroBeat Assembly Community Environment Contract Test Scene

**Date:** 2026-05-16  
**Status:** In Progress  
**Agent:** Cookie 🍪

---

## Goal

Add a dedicated assembly-community environment-contract test scene under `scenes/tests/` and update the repo’s GodotEnv dependency restore flow so the scene can install and exercise the required environment-family addons for manual integration testing.

---

## Overview

Derrick called out the real gap correctly: even though the contract plumbing work is landed in the environment-family repos, manual validation inside `aerobeat-assembly-community` is still awkward without a purpose-built integration scene. The right next move is to add a test surface inside the owning consumer repo instead of trying to infer correctness from addon-level testbeds alone.

The owning repo for this work should be `aerobeat-assembly-community`, because that repo already owns the root Godot project, the current manual proof scenes under `scenes/`, the root `addons.jsonc` manifest, and the repo-local addon restore script at `scripts/restore-addons.sh`. This plan therefore treats the work as assembly-owned integration scaffolding: create a dedicated `scenes/tests/` scene plus any helper scripts it needs, update the dependency manifest / restore flow truthfully, then QA/audit that the scene is a usable surface for manual testing without overclaiming final gaussian-splat render stability.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Current assembly-community repo and Godot project root | `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community` |
| `REF-02` | Root assembly dependency manifest | `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/addons.jsonc` |
| `REF-03` | Repo-local addon restore script | `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/scripts/restore-addons.sh` |
| `REF-04` | Prior temporary assembly proof-scene plan for MediaPipe | `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-24-assembly-mediapipe-test-scene-port-for-editor-and-build-validation.md` |
| `REF-05` | Shared environment contract repo | `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-core` |
| `REF-06` | Async/progress-enabled gaussian-splat fulfillment repo | `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-gaussian-splat` |
| `REF-07` | Current environment loader repo | `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-loader` |

---

## Tasks

### Task 1: Define the assembly test-scene scope and dependency set

**Bead ID:** `aerobeat-assembly-community-eh2`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`  
**Prompt:** In repo `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community`, claim the assigned bead and define the minimal truthful scope for a new environment-contract manual test scene under `scenes/tests/`. Identify which addons the assembly manifest/restore flow must install, what the scene should prove, what helper scripts/resources it needs, and what should remain explicitly out of scope because of the known gaussian-splat runtime/render bug.

**Folders Created/Deleted/Modified:**
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/.plans/`
- `scenes/tests/` (planned)
- `scripts/` and manifest files if needed

**Files Created/Deleted/Modified:**
- Plan updates only unless minor notes are needed

**Status:** ✅ Complete

**Results:** Research complete. The minimal truthful assembly-owned scope is **one standalone manual integration scene under `scenes/tests/` with a single controller script that exposes two distinct proving lanes instead of pretending the current loader already solves everything**.

**Recommended scene scope:**
- Add a dedicated standalone scene, e.g. `scenes/tests/environment_contract_test_scene.tscn`, rather than modifying `scenes/main.tscn` or the existing MediaPipe proof scenes.
- Keep the UI/testbed shape close to the existing environment-loader `.testbed` proving surface (`REF-07`) because that already matches the environment contract vocabulary well: a simple left-side control panel, current asset label, buttons, and a scrollable status log.
- The scene should have **two honest test lanes**:
  1. **Loader lane** using `res://addons/aerobeat-environment-loader/src/AeroToolManager.gd` to prove assembly can load the current generic environment contract surface for `.png`, `.ogv`, `.glb`, plus `load_environment_from_workout_yaml(...)` translation.
  2. **Gaussian-splat async lane** using `res://addons/aerobeat-environment-gaussian-splat/src/AeroToolManager.gd` directly to prove the new shared async contract path (`begin_fulfill(...)`, typed `AeroEnvironmentOperation`, progress/state/phase updates) inside the assembly consumer repo.
- Critical truth boundary: **do not route splat proof through the current loader** for this first assembly scene. `REF-07` still fulfills splats with a structured placeholder node rather than the real gaussian runtime, so using loader-only splat would under-prove the new async contract work.

**What the scene should prove:**
- Assembly can restore/install and import the environment-family addons from the root repo manifest.
- The assembly project can instantiate the environment-loader manager and receive truthful request/progress/success/failure dictionaries for image/video/GLB loads.
- The assembly project can exercise workout-YAML translation through the loader lane using a repo-local fixture.
- The assembly project can instantiate the gaussian-splat wrapper, start `begin_fulfill(...)` for a `.compressed.ply` request, and surface ordered async contract updates (`state`, `status`, `phase`, `sequence`, `message`) from the returned operation.
- On success, the scene can attach the returned splat node to a `WorldRoot` and optionally pass a `WorldEnvironment` through request context so compositor wiring is attempted honestly.
- The scene should also display the gaussian renderer-support status from `get_renderer_support_status()` so manual testers can see whether the current backend is unsupported vs experimental before over-interpreting visible output.

**Required root-manifest addon additions (`addons.jsonc`):**
- `aerobeat-environment-core` — required by both loader and gaussian contract-facing scripts.
- `aerobeat-environment-loader` — required for the generic image/video/GLB/workout-YAML lane.
- `aerobeat-environment-gaussian-splat` — required for the contract-facing splat wrapper/API used by the assembly scene.
- `aerobeat-environment-gaussian-splat-fulfillment` — required separately because the public splat wrapper in `REF-06` extends scripts at `res://addons/aerobeat-environment-gaussian-splat-fulfillment/...` rather than using its repo-root mount as the lower runtime path.
- `gdgs` — required by the lower splat fulfillment runtime in `REF-06`.
- Existing `aerobeat-input-core`, `aerobeat-input-mediapipe`, `openclaw`, and `gut` entries remain as-is.

**Restore-flow finding:**
- `scripts/restore-addons.sh` does **not** need logic changes for this rollout. It already does the right repo-local reset (`rm -rf addons .addons`) and reruns `godotenv addons install` from the manifest.
- So the dependency wiring change should be **manifest-only**, unless a later implementation pass uncovers a concrete install quirk. At research time there is no evidence that a script change is needed.

**Helper scripts/resources the scene needs:**
- One assembly-local controller script for the scene UI/state/logging.
- Repo-local fixture assets under an assembly-owned test folder (recommended: symlinks, not copied large binaries) for:
  - one sample `.png`
  - one sample `.ogv`
  - one sample `.glb` plus its sidecar `.json`
  - one sample `.compressed.ply` plus its sidecar `.json`
  - one `workout.yaml` fixture that resolves to one of those sample assets
- Best source of truth for those fixtures is the already-curated environment-loader `.testbed/assets/` and `.testbed/fixtures/` surface from `REF-07`, which itself already points into the environment-community sample catalog. That keeps the assembly scene consistent with the loader lane instead of inventing a second sample set.
- The scene should include a simple `WorldRoot`, `WorldEnvironment`, `Camera3D`, and `CanvasLayer` shell so GLB and splat nodes have a truthful mount target.

**Explicitly out of scope because of the known gaussian-splat renderer/runtime bug (`REF-06`):**
- Do **not** claim stable visible splat rendering correctness in Assembly.
- Do **not** claim Forward+ / Vulkan compositor stability or successful end-to-end visual output across hardware/renderers.
- Do **not** treat a successful async operation / node creation as proof that the final visible splat render path is fixed.
- Do **not** broaden this task into solving teardown/reset issues, renderer crashes, or a new loader-level splat integration rewrite.
- The scene may expose renderer support truth and whatever visible output happens, but the acceptance bar must stop at contract plumbing + integration-surface proof.

**Implementation sequencing recommendation:**
- **Do scene implementation and dependency wiring in one serialized repo pass, not parallel passes.**
- Reason: both changes land in the same repo, and the scene script will import exact addon paths from the manifest entries. Splitting them into parallel passes creates avoidable churn and broken intermediate states (scene paths with missing addons or manifest entries with no exercising scene).
- Practical handoff shape: one coder pass can update `addons.jsonc`, add the fixture symlinks/resources, add the `scenes/tests/` scene + controller script, then run restore/import/manual smoke validation together.

**Recommendation strength:** strong enough to unblock implementation. Task 1 is complete.

---

### Task 2: Implement the assembly environment-contract test scene and helper scripts

**Bead ID:** `aerobeat-assembly-community-yz2`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-04`, `REF-05`, `REF-06`, `REF-07`  
**Prompt:** In repo `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community`, claim the assigned bead and implement the new `scenes/tests/` environment-contract manual test surface plus any narrowly-scoped helper scripts/resources it needs. Keep the scene focused on truthful integration testing for the environment contract and async/progress path rather than pretending the known splat render bug is solved. Run repo-local validation, commit/push by default, and update the plan with exact evidence.

**Folders Created/Deleted/Modified:**
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/scenes/tests/`
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/src/`
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/fixtures/environment_contract/`

**Files Created/Deleted/Modified:**
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/scenes/tests/environment_contract_test_scene.tscn`
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/src/environment_contract_test_scene.gd`
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/src/environment_contract_test_scene.gd.uid`
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/fixtures/environment_contract/assets/images/perfect-hue-may-14-2026.png` (symlink)
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/fixtures/environment_contract/assets/images/perfect-hue-may-14-2026.png.import`
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/fixtures/environment_contract/assets/videos/calm_blue_sea_1.ogv` (symlink)
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/fixtures/environment_contract/assets/videos/calm_blue_sea_1.ogv.uid`
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/fixtures/environment_contract/assets/models/alien-planet.glb` (symlink)
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/fixtures/environment_contract/assets/models/alien-planet.glb.import`
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/fixtures/environment_contract/assets/models/alien-planet_0.jpg` (symlink)
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/fixtures/environment_contract/assets/models/alien-planet_0.jpg.import`
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/fixtures/environment_contract/assets/models/alien-planet.json`
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/fixtures/environment_contract/assets/splats/CountrySide farm.compressed.ply` (symlink)
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/fixtures/environment_contract/assets/splats/CountrySide farm.json`
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/fixtures/environment_contract/workout_yaml_valid_image/workout.yaml`
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/fixtures/environment_contract/workout_yaml_valid_image/sets/ab-set-image-demo-round.yaml`
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/fixtures/environment_contract/workout_yaml_valid_image/environments/ab-environment-image-demo.yaml`
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/fixtures/environment_contract/workout_yaml_valid_image/media/environments/demo.png` (symlink)
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/fixtures/environment_contract/workout_yaml_valid_image/media/environments/demo.png.import`

**Status:** ✅ Complete

**Results:** Implemented an assembly-owned manual proof surface that keeps the two required lanes separate and honest (`REF-01`, `REF-05`, `REF-06`, `REF-07`). The new `scenes/tests/environment_contract_test_scene.tscn` + `src/environment_contract_test_scene.gd` scene mirrors the addon testbed control-panel shape enough to be usable, but narrows scope to exactly what Derrick asked for: loader-lane buttons for PNG / OGV / GLB / workout.yaml and a separate direct gaussian-splat async button that calls `begin_fulfill(...)` on the gaussian-splat tool wrapper instead of pretending the loader’s current splat placeholder is sufficient proof.

The scene mounts loader-created 2D/3D content onto dedicated loader roots, mounts direct splat results onto a separate `SplatWorldRoot`, surfaces the renderer-support note from `get_renderer_support_status()`, and logs contract-facing async evidence (`state`, `status`, `phase`, `sequence`, `progress`, `message`) from the returned `AeroEnvironmentOperation`. The success copy and status notes explicitly preserve the known bug boundary: a successful direct async fulfill / node attach is treated as plumbing proof only, not stable visible splat rendering proof.

Added repo-local fixture scaffolding under `fixtures/environment_contract/` using symlinks to representative environment-community sample binaries where practical, plus tiny assembly-owned YAML/JSON glue files for the workout package and config sidecars. This keeps the assembly repo self-describing without copying large binaries into source control.

Validation run from the assembly repo root:
- `godot --headless --path . --import --quit-after 1000` ✅
- Headless runtime smoke script instantiating `res://scenes/tests/environment_contract_test_scene.tscn` and programmatically driving both lanes ✅
  - loader PNG ✅
  - loader OGV ✅
  - loader GLB ✅
  - loader workout.yaml bridge ✅
  - direct splat async `begin_fulfill(...)` / `AeroEnvironmentOperation` completion ✅
- Validation renderer note stayed honest in headless mode: `support_level=unsupported`, `renderer=forward_plus`, with the expected message that GDGS visible rendering is unavailable on the current renderer path even though async load plumbing succeeded.

Implementation commit: `1e34dcf` (`Add environment contract test scene`).

---

### Task 3: Update GodotEnv manifest/restore flow for the new scene dependencies

**Bead ID:** `aerobeat-assembly-community-4d0`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-02`, `REF-03`, `REF-05`, `REF-06`, `REF-07`  
**Prompt:** In repo `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community`, claim the assigned bead and update the root `addons.jsonc` and any repo-local restore flow needed so the new test scene installs the right environment-family dependencies reproducibly. Keep the dependency story truthful and minimal, validate the restore/install flow, commit/push by default, and update the plan with exact evidence.

**Folders Created/Deleted/Modified:**
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/scripts/`

**Files Created/Deleted/Modified:**
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/addons.jsonc`
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/scripts/restore-addons.sh`
- Related docs if needed

**Status:** ✅ Complete

**Results:** Completed the dependency-wiring pass with a manifest-only change, which matched the Task 1 recommendation and kept scope tight to the restore/install contract. `addons.jsonc` now adds the five environment-family entries needed by the upcoming assembly scene: `aerobeat-environment-core`, `aerobeat-environment-loader`, `aerobeat-environment-gaussian-splat`, `aerobeat-environment-gaussian-splat-fulfillment`, and `gdgs` (`REF-02`, `REF-05`, `REF-06`, `REF-07`). The new entries intentionally use `checkout: "main"` because these repos do not yet have a tagged release contract documented for assembly consumers, and the sibling repo manifests/readmes already describe `main` as the truthful temporary pin for this rollout.

`scripts/restore-addons.sh` was explicitly inspected and left untouched (`REF-03`). No script change was needed: the repo-local wrapper already clears disposable/generated `addons/` + `.addons/` state and then reruns `godotenv addons install`, which is still the correct reproducible restore flow here.

Validation run from the assembly repo root:
- `./scripts/restore-addons.sh` ✅
- `godot --headless --path . --import --quit-after 1000` ✅
- Fresh installed addon tree now includes `addons/aerobeat-environment-core`, `addons/aerobeat-environment-loader`, `addons/aerobeat-environment-gaussian-splat`, `addons/aerobeat-environment-gaussian-splat-fulfillment`, and `addons/gdgs`.
- Import registered the new environment contract/global classes (`AeroEnvironmentRequest`, `AeroEnvironmentResult`, `AeroEnvironmentOperation`, `AeroToolManager`, `AeroGaussianSplatManager`, etc.), which is the practical proof that the assembly can now see the new dependency surface.

Notable install nuance recorded truthfully: `godotenv addons install` emits a conflict warning when both the gaussian-splat repo root (`subfolder: "/"`) and its lower fulfillment subfolder (`subfolder: "/addons/aerobeat-environment-gaussian-splat-fulfillment"`) are installed from the same Git URL. In this validated run the install still completed successfully and materialized both required mount points, so the warning is informational rather than a blocker for this repo pass.

Files changed in this task: `addons.jsonc`, this plan file. Implementation commit: `865f89b` (`Add environment test scene dependencies`), pushed to `origin/main`.

---

### Task 4: QA the assembly test scene and dependency restore path

**Bead ID:** `aerobeat-assembly-community-0ts`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-05`, `REF-06`, `REF-07`  
**Prompt:** In and against `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community`, claim the assigned bead and verify that the new `scenes/tests/` environment test surface loads, that the repo-local restore/install flow brings in the required addons, and that the scene provides truthful manual-testing value. Clearly distinguish what is verified from what remains blocked by the known gaussian-splat render/runtime bug.

**Folders Created/Deleted/Modified:**
- Validation only expected

**Files Created/Deleted/Modified:**
- Plan updates only unless minimal QA-fix follow-ups are absolutely required

**Status:** ⏳ Pending

**Results:** Pending.

---

### Task 5: Independently audit the assembly test-scene rollout

**Bead ID:** `aerobeat-assembly-community-3tw`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`  
**Prompt:** In and against `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community`, claim the assigned bead and independently audit whether the new `scenes/tests/` environment-contract test scene plus dependency restore changes actually give Derrick a truthful manual testing surface. Confirm the boundary between landed plumbing and the still-known gaussian-splat bug remains honest.

**Folders Created/Deleted/Modified:**
- Audit only expected

**Files Created/Deleted/Modified:**
- Plan updates only unless an audit retry is required

**Status:** ⏳ Pending

**Results:** Pending.

---

## Final Results

**Status:** ⏳ Pending

**What We Built:** Pending.

**Reference Check:** Pending.

**Commits:**
- Pending

**Lessons Learned:** Pending.

---

*Completed on Pending*
