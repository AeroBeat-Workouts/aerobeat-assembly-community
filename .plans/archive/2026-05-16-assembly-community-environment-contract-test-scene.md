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

**Status:** ✅ Complete

**Results:** QA passed on the assembly-owned contract surface, with the known gaussian-splat renderer/runtime boundary kept honest (`REF-01`, `REF-02`, `REF-03`, `REF-05`, `REF-06`, `REF-07`). I re-ran the repo-local restore/install flow from scratch, re-imported the Godot project headlessly, then drove the new `scenes/tests/environment_contract_test_scene.tscn` through a throwaway headless QA harness that instantiated the real scene and exercised both the loader lane and the direct splat async lane instead of trusting prior summaries.

**Commands run from `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community`:**
- `bd update aerobeat-assembly-community-0ts --status in_progress --json`
- `git log --oneline -n 8`
- `./scripts/restore-addons.sh`
- `find addons -maxdepth 1 -mindepth 1 -type d | sort`
- `godot --headless --path . --import --quit-after 1000`
- `godot --headless --path . --script /tmp/aerobeat_env_contract_qa.gd`

**Evidence captured:**
- Restore flow truthfully reinstalled the required environment-family dependencies from the root manifest: `addons/aerobeat-environment-core`, `addons/aerobeat-environment-loader`, `addons/aerobeat-environment-gaussian-splat`, `addons/aerobeat-environment-gaussian-splat-fulfillment`, and `addons/gdgs` were all present after `./scripts/restore-addons.sh`. The previously documented same-repo conflict warning for gaussian-splat + gaussian-splat-fulfillment reproduced, but install still completed successfully.
- Headless import succeeded on Godot `4.6.2.stable.official.71f334935`, and the import log registered the expected contract/global classes including `AeroEnvironmentOperation`, `AeroEnvironmentProgress`, `AeroToolManager`, and `AeroGaussianSplatManager`.
- The new scene really exists and loads from `scenes/tests/`: the QA harness loaded `res://scenes/tests/environment_contract_test_scene.tscn` as a `PackedScene`, instantiated it successfully, and verified the boundary label text explicitly says: `Loader lane proves png / ogv / glb / workout.yaml. Direct splat lane proves begin_fulfill + AeroEnvironmentOperation progress/state/phase. Visible splat rendering remains experimental / known-bug-boundary honest.`
- Loader lane verification passed truthfully for all requested cases:
  - PNG → success, `kind=image`, `format=.png`, final loader progress status `ready`
  - OGV → success, `kind=video`, `format=.ogv`, final loader progress status `ready`
  - GLB → success, `kind=glb`, `format=.glb`, `config_applied=true`, final loader progress status `ready`
  - workout.yaml bridge → success, resolved to `res://fixtures/environment_contract/workout_yaml_valid_image/media/environments/demo.png`, returned `kind=image`, final loader progress status `ready`
- Direct gaussian-splat async lane verification also passed truthfully:
  - calling the scene’s direct lane produced a real `AeroEnvironmentOperation`
  - the operation exposed the expected async signals (`started`, `progressed`, `succeeded`, `finished`)
  - progress/state/phase/sequence evidence was real and ordered all the way through completion (`sequence` advanced monotonically through 1625 updates on this sample run)
  - terminal operation state was `succeeded` with `latest_progress.state=succeeded`, `latest_progress.status=ready`, and `latest_progress.phase=ready`
  - result details reported `point_count=2200000` and `config_applied=true`, so the lane really exercised `begin_fulfill(...)` plus the shared operation contract rather than a fake placeholder path
- Overclaim check passed: the renderer-support note reported `support_level=unsupported` / `renderer=forward_plus`, and the scene’s success copy stayed honest: `Direct splat success: async contract completed. Visible render remains experimental / bug-boundary honest.`

**Caveats worth preserving for audit:**
- On this headless QA run, gaussian-splat visible rendering is still not a validated outcome. The renderer-support note said GDGS rendering is unavailable on the current renderer path, so this pass is strictly contract/plumbing proof.
- The direct splat result completed successfully, but `result.details.world_environment_configured` remained `false` under this unsupported renderer path. That is acceptable for this QA pass because the requirement here is truthful async contract proof plus honest reporting, not compositor/renderer success.
- The sample splat is large enough that the async lane is not a trivial smoke check; the QA harness had to allow a long-enough wait window for the background `building` phase to reach terminal `ready`.

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
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/.plans/2026-05-16-assembly-community-environment-contract-test-scene.md`

**Status:** ✅ Complete

**Results:** Audit passed as **complete**, with the known gaussian-splat visible-render boundary still documented honestly (`REF-01`, `REF-02`, `REF-03`, `REF-05`, `REF-06`, `REF-07`). I did not trust the plan summaries alone: I re-ran the repo-local restore flow, re-imported the project headlessly, spot-checked the landed files/fixtures, and drove the real `scenes/tests/environment_contract_test_scene.tscn` through an independent headless audit harness.

**Fresh audit evidence:**
- `./scripts/restore-addons.sh` still performs the real repo-local restore contract: clear generated `addons/` + `.addons/`, then run `godotenv addons install`. Re-running it from scratch installed the required environment-family mount points under `addons/`: `aerobeat-environment-core`, `aerobeat-environment-loader`, `aerobeat-environment-gaussian-splat`, `aerobeat-environment-gaussian-splat-fulfillment`, and `gdgs`, alongside the pre-existing assembly deps.
- The same-repo install warning for gaussian-splat + gaussian-splat-fulfillment reproduced exactly as previously reported, but install still completed successfully and materialized both required addon roots. That warning is real debt to remember, not a blocker for this rollout.
- `godot --headless --path . --import --quit-after 1000` succeeded on Godot `4.6.2.stable.official.71f334935` and registered the expected contract/runtime classes including `AeroEnvironmentOperation`, `AeroEnvironmentProgress`, `AeroToolManager`, and `AeroGaussianSplatManager`.
- `scenes/tests/environment_contract_test_scene.tscn` is real and coherent: it wires the assembly-local controller script, a loader-lane `AeroToolManager`, a direct gaussian-splat `AeroToolManager`, dedicated loader/splat world roots, and UI copy that explicitly says loader proves `png / ogv / glb / workout.yaml` while direct splat proves `begin_fulfill + AeroEnvironmentOperation progress/state/phase`, with visible splat rendering still marked experimental.
- `src/environment_contract_test_scene.gd` keeps the two proof lanes honestly separated. Loader buttons call `load_environment(...)` / `load_environment_from_workout_yaml(...)`; the direct splat button calls `begin_fulfill(...)` on the gaussian-splat manager directly, subscribes to `started` / `progressed` / `succeeded` / `failed` / `finished`, and surfaces `state`, `status`, `phase`, `sequence`, `progress`, and `message` into the scene log.
- Fixture scaffolding is real, not hand-waved: the repo contains assembly-local YAML/JSON glue plus symlinks to representative `.png`, `.ogv`, `.glb`, and `.compressed.ply` samples from the environment-community catalog.
- Independent audit harness results matched the intended proving surface:
  - loader PNG succeeded
  - loader OGV succeeded
  - loader GLB succeeded with config applied
  - loader workout.yaml bridge succeeded and resolved to the repo-local `demo.png`
  - direct gaussian-splat async lane returned a real operation, emitted 1600+ progress updates with advancing `sequence`, and completed successfully with `point_count=2200000` and `config_applied=true`
  - renderer support stayed honest: `support_level=unsupported`, `renderer=forward_plus`, and the message still says visible splat rendering should not be expected on the current renderer path
- Overclaim check passed: the scene summary copy says `Direct splat success: async contract completed. Visible render remains experimental / bug-boundary honest.` So the rollout proves contract plumbing and a truthful manual surface, not stable splat rendering.

**Coherence / paperwork note:** Task 3’s file checklist still mentions `scripts/restore-addons.sh`, but the actual Task 3 narrative and commit `865f89b` correctly show that the restore-flow rollout was manifest-only in this repo pass. I treated that as a documentation over-listing, not an implementation mismatch.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** `aerobeat-assembly-community` now has an assembly-owned manual environment-contract proving surface at `scenes/tests/environment_contract_test_scene.tscn`, plus repo-local fixture scaffolding and root-manifest dependency wiring so Derrick can restore the required environment-family addons and manually exercise two truthful lanes: loader-driven `png / ogv / glb / workout.yaml` integration and direct gaussian-splat async contract integration.

**Reference Check:** `REF-01`, `REF-02`, and `REF-03` are satisfied by the landed assembly repo state: the root manifest installs the required environment-family addons and the restore wrapper still works reproducibly. `REF-05`, `REF-06`, and `REF-07` are satisfied by actual consumer usage rather than prose alone: the assembly scene imports the shared environment contract packages, uses the loader for the generic lane, and uses the gaussian-splat wrapper directly for the async `begin_fulfill(...)` lane. The rollout deliberately preserves the `REF-06` bug boundary by reporting renderer support truthfully and avoiding any claim of stable visible splat rendering.

**Commits:**
- `865f89b` - Add environment test scene dependencies
- `1e34dcf` - Add environment contract test scene
- `b7d9e42` - Update environment test scene plan evidence

**Lessons Learned:** Keep consumer-repo integration proof lanes separate when one backend still has a known renderer/runtime bug; otherwise the test surface lies by implication. Also, same-repo multi-subfolder addon installs are workable here but noisy enough that future cleanup should either remove the warning path or document it more centrally.

---

*Completed on 2026-05-16*
