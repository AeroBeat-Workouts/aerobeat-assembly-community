# AeroBeat Assembly GodotEnv Addon Tree Out-of-Sync

**Date:** 2026-04-24  
**Status:** In Progress  
**Agent:** Pico 🐱‍🏍

---

## Goal

Fix the `aerobeat-assembly-community` GodotEnv addon state so the generated `addons/` tree and editor-visible addon set match the current AeroBeat repo naming and dependency reality.

---

## Overview

Derrick reported that the assembly repo’s GodotEnv addon tree looks out of sync with the latest expected repos. Initial inspection showed `addons.jsonc` still declares `aerobeat-core`, and the generated `addons/` directory currently contains `addons/aerobeat-core`, `addons/aerobeat-input-mediapipe`, and `addons/gut`. Derrick then clarified the key naming change: the old `aerobeat-core` repo no longer exists in the current architecture and was renamed to `aerobeat-input-core`.

That means this is not just an editor refresh suspicion anymore — it is a truthful manifest/config drift problem. The assembly repo needs to be checked for all stale `aerobeat-core` assumptions across `addons.jsonc`, project/plugin wiring, runtime script paths, and any generated addon state. Then we need the smallest truthful fix that restores consistency with the current six-core naming model, reruns GodotEnv sync, and verifies the editor sees the expected addon set.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Derrick’s current report that the addon tree is out of sync | current session, 2026-04-24 15:15 EDT |
| `REF-02` | Derrick’s clarification that `aerobeat-core` became `aerobeat-input-core` | current session, 2026-04-24 15:16 EDT |
| `REF-03` | Current assembly addon manifest | `addons.jsonc` |
| `REF-04` | Current project/plugin/runtime wiring | `project.godot`, `src/`, `scenes/`, `tests/` |
| `REF-05` | Current generated addon tree in the assembly repo | `addons/` |
| `REF-06` | Prior memory confirming six-core rename and local workspace retarget | `memory/2026-04-20.md#L9-L13` |

---

## Tasks

### Task 1: Research stale `aerobeat-core` assumptions and exact drift scope

**Bead ID:** `oc-977`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Audit `aerobeat-assembly-community` for stale `aerobeat-core` assumptions versus the current `aerobeat-input-core` naming. Check `addons.jsonc`, `project.godot`, runtime script paths, tests, and the generated `addons/` tree. Determine the exact drift scope and propose the smallest truthful fix. Do not implement yet.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `addons/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-24-godotenv-addon-tree-out-of-sync.md`

**Status:** ✅ Complete

**Results:** Audit complete. Exact drift scope is narrower than a full path rewrite but broader than a single repo URL typo. Evidence:

- Root manifest drift is real: `addons.jsonc:5-8` still declares addon key `aerobeat-core` and points it at `git@github.com:AeroBeat-Workouts/aerobeat-core.git`.
- Root docs drift is real: `README.md:12-15,74-80` still documents `aerobeat-core` as the pinned foundation dependency.
- Root runtime/plugin wiring still intentionally consumes the installed addon at the historical path `res://addons/aerobeat-core/...`: `project.godot:31-33`, `src/input_manager.gd:1-6`, and `scenes/main.tscn:3-4`.
- The generated addon tree is still materialized under `addons/aerobeat-core/`, and its installed identity text is stale old-name content: `addons/aerobeat-core/plugin.cfg:1-6` says `AeroBeat Core`, and `addons/aerobeat-core/README.md:1-39` still brands the package as `aerobeat-core`.
- However, the mounted code surface under that path already matches the current sibling `../aerobeat-input-core` repo for the actual runtime contract files (`plugin.gd`, `src/input_manager.gd`, and all `src/interfaces/*.gd` checked byte-equal). The only code-level mismatch observed at the package root was identity metadata in `plugin.cfg`, not API/layout drift.
- Cross-repo evidence says the current naming model is to preserve the old mount path when consumers still depend on it: the sibling `aerobeat-input-mediapipe-python` repo already mounts `aerobeat-input-core` under the compatibility addon key/path `aerobeat-core` in `.testbed/addons.jsonc`, and its README explicitly documents that compatibility contract.

Smallest truthful recommended fix for Task 2:

1. Keep the assembly install key/path `aerobeat-core` for now so `res://addons/aerobeat-core/...` runtime references remain valid.
2. Change only the manifest source of that key from the dead old repo name to the current repo: point `addons.jsonc` at `git@github.com:AeroBeat-Workouts/aerobeat-input-core.git` while preserving the addon key `aerobeat-core`.
3. Update the assembly README to state the truth explicitly: the assembly still mounts the input-core package under the compatibility addon path `aerobeat-core` for current project-path compatibility.
4. Reinstall/regenerate `addons/` so the generated tree reflects the new source repo under the preserved compatibility mount.

Do **not** rename project paths to `res://addons/aerobeat-input-core/...` in this slice unless the owning core package and all consuming repos deliberately drop the alias together; current evidence says alias compatibility should be preserved here, not broken piecemeal.

---

### Task 2: Fix the manifest/wiring drift and resync GodotEnv

**Bead ID:** `oc-3a1`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Implement the smallest truthful fix for the stale `aerobeat-core` vs `aerobeat-input-core` drift in the assembly repo, resync the generated addon tree, and update the plan with exact evidence. Commit/push by default.

**Folders Created/Deleted/Modified:**
- `addons/`
- `.plans/`

**Files Created/Deleted/Modified:**
- `addons.jsonc`
- `README.md`
- `src/input_manager.gd`
- `.plans/2026-04-24-godotenv-addon-tree-out-of-sync.md`

**Status:** ✅ Complete

**Results:** Implemented the smallest truthful assembly-side fix without breaking the compatibility mount. Exact changes:

- `addons.jsonc:4-10` now keeps the addon key/path `aerobeat-core` but changes its source URL to `git@github.com:AeroBeat-Workouts/aerobeat-input-core.git` at `checkout: "v0.1.0"`.
- `README.md:12-15,77-78` now states the truth explicitly: the assembly depends on `aerobeat-input-core` but still installs it under the compatibility addon key/path `aerobeat-core` so current runtime references remain valid.
- `src/input_manager.gd:4-7` now documents the same compatibility-alias reality for the local forwarding shim.

Validation/evidence captured during implementation:

- Fresh restore succeeded after removing the stale generated mount: `rm -rf addons/aerobeat-core .addons/aerobeat-core && godotenv addons install`.
- GodotEnv resolution output explicitly showed the new source identity while preserving the old mount key: `Resolved: Addon "aerobeat-core" ... on branch \`v0.1.0\` of \`git@github.com:AeroBeat-Workouts/aerobeat-input-core.git\``.
- Compatibility project paths remain intact and coherent: `project.godot:33`, `src/input_manager.gd:1`, and `scenes/main.tscn:4` still reference `res://addons/aerobeat-core/...`.
- Runtime contract parity still holds after the resync: `cmp -s` matched `addons/aerobeat-core/plugin.gd`, `src/input_manager.gd`, and every checked `src/interfaces/*.gd` file against the sibling `../aerobeat-input-core` repo.
- Headless import smoke check passed: `godot --headless --path . --import` exited `0` after registering the expected input classes (`BoxingInput`, `FlowInput`, `AeroInputProvider`, `InputManager`).

Important truthful caveat observed during this pass: the generated addon payload under `addons/aerobeat-core/README.md` and `addons/aerobeat-core/plugin.cfg` still contains old-name upstream branding (`aerobeat-core` / `AeroBeat Core`) even though GodotEnv now resolves the package from the `aerobeat-input-core` repo URL. That appears to be an upstream package/tag identity issue, not an assembly wiring issue, and should be treated as a QA note rather than silently rewritten here.

---

### Task 3: QA/audit the synced addon tree and editor-visible addon set

**Bead ID:** `oc-g23`  
**SubAgent:** `primary`  
**Role:** `qa` / `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Independently verify that the assembly repo now references the correct addon names, that GodotEnv regenerated the expected addon tree, and that the editor-visible addon set matches the intended current dependencies. Close only if the evidence supports it.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-24-godotenv-addon-tree-out-of-sync.md`

**Status:** ✅ Complete

**Results:** Independent QA/audit passed. Exact evidence re-verified in a fresh auditor pass:

- Manifest/source truth is correct: `addons.jsonc:4-10` still preserves the compatibility addon key/path `aerobeat-core` while sourcing it from `git@github.com:AeroBeat-Workouts/aerobeat-input-core.git` at `checkout: "v0.1.0"`.
- Compatibility runtime refs remain intentionally unchanged: `project.godot:33`, `src/input_manager.gd:1,4-5`, and `scenes/main.tscn:4` still load `res://addons/aerobeat-core/...`, and no assembly-side rewrite to `res://addons/aerobeat-input-core/...` was introduced.
- Fresh GodotEnv reinstall reproduced the expected resolution contract: `godotenv addons install` again reported `Resolved: Addon "aerobeat-core" ... on branch \`v0.1.0\` of \`git@github.com:AeroBeat-Workouts/aerobeat-input-core.git\`` while leaving the installed mount at `addons/aerobeat-core/`.
- The regenerated addon tree matches the intended dependency set: `addons/` contains `aerobeat-core`, `aerobeat-input-mediapipe`, and `gut`; plugin manifests are present at `addons/aerobeat-core/plugin.cfg`, `addons/aerobeat-input-mediapipe/plugin.cfg`, and `addons/gut/plugin.cfg`.
- Editor-visible enabled addons match the intended current project dependencies: `project.godot:33` enables only `res://addons/aerobeat-core/plugin.cfg` and `res://addons/gut/plugin.cfg`; `aerobeat-input-mediapipe` is installed but intentionally not enabled as an editor plugin.
- Headless editor/import verification passed again: `godot --headless --path . --import` exited `0`, initialized plugins successfully, and completed the editor load path without addon resolution failures.
- Runtime contract parity with the actual current core repo still holds after the reinstall: `cmp -s` matched `addons/aerobeat-core/plugin.gd`, `src/input_manager.gd`, and checked interface files against `../aerobeat-input-core` (`src/interfaces/boxing_input.gd`, `flow_input.gd`, `input_provider.gd`).
- Remaining old-name branding inside the generated payload is real but not a blocker for this slice: `addons/aerobeat-core/README.md:1` still says `# aerobeat-core` and `addons/aerobeat-core/plugin.cfg:2` still says `name="AeroBeat Core"`. Because the assembly manifest now resolves from the correct repo and the mounted code matches `../aerobeat-input-core`, this is best classified as an upstream package/tag identity caveat, not an assembly wiring failure.

Conclusion: Task 3 evidence supports closure of `oc-g23`.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** The assembly repo now truthfully sources the compatibility-mounted `aerobeat-core` addon from `aerobeat-input-core`, regenerates the expected GodotEnv addon tree, and keeps the project/editor-visible addon set aligned with the current dependency intent.

**Reference Check:** `REF-01`/`REF-02` satisfied by correcting the stale repo identity while preserving the compatibility mount Derrick said still matters; `REF-03` satisfied by `addons.jsonc:4-10`; `REF-04` satisfied by unchanged intentional runtime refs in `project.godot`, `src/`, and `scenes/`; `REF-05` satisfied by the regenerated `addons/` tree plus successful headless import; `REF-06` satisfied by confirming the rename is real but still consumed through the historical mount path.

**Commits:**
- `837fd1c` - Document addon naming drift audit
- `6720a8e` - Point assembly core addon at aerobeat-input-core

**Lessons Learned:** When repo identities change but consumer mount paths are intentionally preserved, the audit target is the source-of-truth resolution contract, not just the installed folder name. Also, old branding inside a tagged addon payload can be a legitimate upstream identity caveat without being an assembly-side blocker if code parity and runtime/editor wiring are otherwise correct.

---

*Completed on 2026-04-24*
