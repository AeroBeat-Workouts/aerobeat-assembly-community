# AeroBeat Assembly Rename Core Addon Key to aerobeat-input-core

**Date:** 2026-04-24  
**Status:** Draft  
**Agent:** Pico 🐱‍🏍

---

## Goal

Rename the assembly repo’s GodotEnv core addon install key/path from `aerobeat-core` to `aerobeat-input-core`, and update the project to use the new mounted addon path truthfully.

---

## Overview

The previous pass intentionally kept the compatibility mount key `aerobeat-core` while retargeting its source repo to `aerobeat-input-core`. Derrick has now explicitly asked to finish the rename by updating the GodotEnv addon key itself. That makes this a broader but still focused migration slice: update the manifest key, update all assembly-side references from `res://addons/aerobeat-core/...` to `res://addons/aerobeat-input-core/...`, regenerate the addon tree, and verify the project still imports cleanly.

The initial assumption that this could stay assembly-only was wrong. Research confirmed the mounted MediaPipe addon still hardcodes the old core path, so this rename must now be handled as a coordinated two-repo slice: update `aerobeat-input-mediapipe-python` to consume `res://addons/aerobeat-input-core/...`, then update `aerobeat-assembly-community` to rename the GodotEnv addon key/path and assembly references, then re-verify the integrated path end to end. The target is a truthful state where both the source repo and the mounted addon path use `aerobeat-input-core` without relying on the old `aerobeat-core` compatibility alias.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Derrick’s explicit request to update the key as well as the source repo | current session, 2026-04-24 16:42 EDT |
| `REF-02` | Current assembly addon manifest | `addons.jsonc` |
| `REF-03` | Current project/runtime wiring still using `aerobeat-core` | `project.godot`, `src/`, `scenes/`, `tests/` |
| `REF-04` | Current generated addon tree | `addons/` |
| `REF-05` | Prior compatibility-key pass | `.plans/2026-04-24-godotenv-addon-tree-out-of-sync.md` |
| `REF-06` | Current input-core source repo for parity/reference | `../aerobeat-input-core/` |

---

## Tasks

### Task 1: Audit all remaining `aerobeat-core` path assumptions in the assembly repo

**Bead ID:** `oc-q4o`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Audit `aerobeat-assembly-community` for every remaining runtime/project/test/doc reference that still assumes the mounted addon path `res://addons/aerobeat-core/...`. Determine the exact rename scope needed to move the assembly to `res://addons/aerobeat-input-core/...` and propose the smallest truthful fix. Do not implement yet.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `addons/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-24-rename-assembly-core-addon-key-to-aerobeat-input-core.md`

**Status:** ✅ Complete

**Results:** Audit complete with direct repo sweep plus dependency spot-checks. Exact live assembly-root references that still assume the mounted core path/key `aerobeat-core` are: `addons.jsonc:4-10` (manifest key/comment), `project.godot:31-33` (enabled plugin path), `scenes/main.tscn:3-4` (InputManager script path), `src/input_manager.gd:1-5` (compatibility shim extends old mounted path and documents the alias), and `README.md:12-15,77-78` (docs still describe the compatibility mount) (`REF-02`, `REF-03`). No repo-local root test file currently references `res://addons/aerobeat-core/...`; the root `test/` surface is not part of the rename scope in this repo.

Generated/install-output references also exist under `addons/aerobeat-core/` and `.addons/aerobeat-core/`, but those are not source-of-truth edits for this task; they should move only by changing the manifest key and rerunning `godotenv addons install`, not by hand-editing generated payloads (`REF-04`). Historical/stale references remain in `.plans/`, `.qa-logs/`, and installed dependency docs; treat those as history/evidence noise unless a later cleanup explicitly claims them.

Critical scope caveat from dependency inspection: the mounted MediaPipe addon consumed by this assembly still hardcodes the old core mount path. Evidence: `addons/aerobeat-input-mediapipe/src/input_provider.gd:1` extends `res://addons/aerobeat-core/src/interfaces/input_provider.gd`, and the sibling source repo `../aerobeat-input-mediapipe-python/src/input_provider.gd:1` matches that same runtime assumption, while its README/testbed docs still describe `aerobeat-input-core` mounted under the compatibility key `aerobeat-core` (`REF-04`, `REF-06`). So a pure assembly-only rename to `res://addons/aerobeat-input-core/...` is not truthfully self-contained today.

Smallest truthful rename scope for Task 2: update only the assembly-owned manifest/project/runtime/doc references listed above (`addons.jsonc`, `project.godot`, `scenes/main.tscn`, `src/input_manager.gd`, `README.md`), regenerate the addon tree, and verify import behavior. However, to keep the assembly runnable, Task 2 must either (a) preserve a temporary compatibility alias/mirror for `aerobeat-core` during the transition, or (b) be coordinated with the corresponding runtime rename in `aerobeat-input-mediapipe-python` so that addon no longer imports core from `res://addons/aerobeat-core/...`. Recommendation: do not leave the old alias as the long-term assembly truth after this pass, but do assume a temporary compatibility bridge is still required unless the MediaPipe addon is updated in lockstep.

---

### Task 2: Update the MediaPipe addon to consume `aerobeat-input-core`

**Bead ID:** `oc-5zt`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-03`, `REF-05`, `REF-06`  
**Prompt:** In `../aerobeat-input-mediapipe-python`, update the MediaPipe addon so it no longer hardcodes `res://addons/aerobeat-core/...` and instead consumes `res://addons/aerobeat-input-core/...` truthfully. Keep scope tight to the path rename needed for integrated compatibility with the assembly repo, validate the repo-local path, and commit/push by default.

**Folders Created/Deleted/Modified:**
- `addons/`
- `.plans/`

**Files Created/Deleted/Modified:**
- `../aerobeat-input-mediapipe-python/src/input_provider.gd`
- `../aerobeat-input-mediapipe-python/.testbed/addons.jsonc`
- `../aerobeat-input-mediapipe-python/.testbed/project.godot`
- `../aerobeat-input-mediapipe-python/README.md`
- `../aerobeat-input-mediapipe-python/src/providers/mediapipe_provider.gd`
- `../aerobeat-input-mediapipe-python/.testbed/tests/mediapipe_provider_test.gd`
- `.plans/2026-04-24-rename-assembly-core-addon-key-to-aerobeat-input-core.md`

**Status:** ✅ Complete

**Results:** Completed in `../aerobeat-input-mediapipe-python` with the runtime-facing adapter and repo-local workbench contract moved from `aerobeat-core` to `aerobeat-input-core` (`REF-01`, `REF-06`). The only live code path that actually hardcoded the old mounted core path was `src/input_provider.gd:1`, which now extends `res://addons/aerobeat-input-core/src/interfaces/input_provider.gd`; the repo-local `.testbed` manifest/plugin wiring was updated in lockstep via `.testbed/addons.jsonc` and `.testbed/project.godot`, and the local docs/comments were tightened so they now describe the truthful mount path instead of the old compatibility alias.

Validation evidence from the MediaPipe repo: (1) `grep -RIn ... 'aerobeat-core'` across live repo surfaces returned no remaining matches outside historical/generated areas after the edit set; (2) `cd .testbed && godotenv addons install` resolved and installed `aerobeat-input-core` from `../../aerobeat-input-core`; (3) `readlink -f .testbed/addons/aerobeat-input-core` resolved to the sibling input-core repo and `.testbed/project.godot` now enables `res://addons/aerobeat-input-core/plugin.cfg`; (4) after deleting the stale generated `.testbed/addons/aerobeat-core` compatibility link left over from prior installs, `godot --headless --path .testbed --import --quit-after 1000` exited cleanly with no duplicate-UID warnings; and (5) a one-off headless script successfully loaded and instantiated `res://addons/aerobeat-input-mediapipe-python/src/input_provider.gd`, printing `VALIDATION_OK:res://addons/aerobeat-input-mediapipe-python/src/input_provider.gd`. Repo commit/push evidence was completed in the MediaPipe repo as part of this task handoff.

---

### Task 3: Rename the assembly addon key/path and resync GodotEnv

**Bead ID:** `oc-a93`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** After the MediaPipe addon path update lands, implement the assembly-side migration from addon key/path `aerobeat-core` to `aerobeat-input-core`. Update manifest/project/runtime/test/docs as needed, regenerate the addon tree, and record exact validation evidence. Commit/push by default.

**Folders Created/Deleted/Modified:**
- `addons/`
- `.addons/`
- `.qa-logs/`
- `.plans/`

**Files Created/Deleted/Modified:**
- `addons.jsonc`
- `project.godot`
- `scenes/main.tscn`
- `src/input_manager.gd`
- `README.md`
- `.qa-logs/task3-cleanup.log`
- `.qa-logs/task3-godotenv-install.log`
- `.qa-logs/task3-mediapipe-refresh.log`
- `.qa-logs/task3-addon-tree.log`
- `.qa-logs/task3-import.log`
- `.qa-logs/task3-check-main.log`
- `.qa-logs/task3-runtime.log`
- `.plans/2026-04-24-rename-assembly-core-addon-key-to-aerobeat-input-core.md`

**Status:** ✅ Complete

**Results:** Completed the assembly-side rename from `aerobeat-core` to `aerobeat-input-core` across the live manifest/project/runtime/doc surfaces identified in Task 1 (`REF-02`, `REF-03`). Exact source-of-truth edits: `addons.jsonc` now declares addon key `aerobeat-input-core` while keeping the same source repo/tag; `project.godot` now enables `res://addons/aerobeat-input-core/plugin.cfg`; `scenes/main.tscn` now points the `InputManager` node at `res://addons/aerobeat-input-core/src/input_manager.gd`; `src/input_manager.gd` now forwards to the new mounted core path; and `README.md` now describes the truthful installed addon path instead of the old compatibility alias.

Generated-tree validation/evidence (`REF-04`): before reinstall, the stale generated old alias mounts were explicitly removed from both `addons/aerobeat-core` and `.addons/aerobeat-core` (`.qa-logs/task3-cleanup.log`). A first reinstall showed the core rename working but exposed a stale cached MediaPipe payload still carrying the old core-path import; to keep the integrated state truthful, the generated MediaPipe install/cache mounts were also purged from `addons/aerobeat-input-mediapipe` and `.addons/aerobeat-input-mediapipe`, then `godotenv addons install` was rerun (`.qa-logs/task3-mediapipe-refresh.log`). The final install log shows `Resolved: Addon "aerobeat-input-core" ... on branch \`v0.1.0\` of \`git@github.com:AeroBeat-Workouts/aerobeat-input-core.git\`` and the resulting addon tree contains `addons/aerobeat-input-core`, `addons/aerobeat-input-mediapipe`, and `addons/gut`, with matching `.addons/` cache entries and no remaining `addons/aerobeat-core` / `.addons/aerobeat-core` mounts (`.qa-logs/task3-godotenv-install.log`, `.qa-logs/task3-addon-tree.log`).

Integrated import/runtime evidence: `grep -RIn` across live assembly-owned sources found no remaining `aerobeat-core` references outside historical/generated areas after the rename. The refreshed installed MediaPipe addon now extends `res://addons/aerobeat-input-core/src/interfaces/input_provider.gd` at `addons/aerobeat-input-mediapipe/src/input_provider.gd:1`, matching the landed sibling repo prerequisite. `godot --headless --path . --script src/main.gd --check-only` exited cleanly (`.qa-logs/task3-check-main.log`), `godot --headless --path . --import --quit-after 1000` exited cleanly (`.qa-logs/task3-import.log`), and `godot --headless --path . --quit-after 2 --verbose` reached runtime with `AeroBeat Assembly started`, `Registered MediaPipe addon adapter`, `Tracking started`, and `Latency display added` in `.qa-logs/task3-runtime.log`. The prior addon-internal `MediaPipeServer` missing-child startup warning did not reproduce in this refreshed integrated pass.

---

### Task 4: QA/audit that the integrated assembly path imports cleanly with the new addon path

**Bead ID:** `oc-9vm`  
**SubAgent:** `primary`  
**Role:** `qa` / `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Independently verify that the MediaPipe addon and assembly now both use `aerobeat-input-core` truthfully, that the regenerated addon tree matches, and that the integrated project still imports cleanly. Close only if the evidence supports it.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-24-rename-assembly-core-addon-key-to-aerobeat-input-core.md`

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
