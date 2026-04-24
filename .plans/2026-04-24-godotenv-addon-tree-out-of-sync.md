# AeroBeat Assembly GodotEnv Addon Tree Out-of-Sync

**Date:** 2026-04-24  
**Status:** Draft  
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
- manifest/config/runtime/test files as needed
- `.plans/2026-04-24-godotenv-addon-tree-out-of-sync.md`

**Status:** ⏳ Pending

**Results:** Pending.

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
