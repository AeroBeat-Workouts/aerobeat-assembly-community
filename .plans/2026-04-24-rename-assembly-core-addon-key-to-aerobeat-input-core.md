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

This pass should stay scoped to the assembly repo and its generated addon tree. We are not trying to rename every historical reference in every repo at once. The target is a truthful assembly state where both the source repo and the mounted addon path use `aerobeat-input-core`.

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

### Task 2: Rename the assembly addon key/path and resync GodotEnv

**Bead ID:** `oc-a93`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Implement the smallest truthful assembly-side migration from addon key/path `aerobeat-core` to `aerobeat-input-core`. Update manifest/project/runtime/test/docs as needed, regenerate the addon tree, and record exact validation evidence. Commit/push by default.

**Folders Created/Deleted/Modified:**
- `addons/`
- `.plans/`

**Files Created/Deleted/Modified:**
- manifest/config/runtime/test/docs files as needed
- `.plans/2026-04-24-rename-assembly-core-addon-key-to-aerobeat-input-core.md`

**Status:** ⏳ Pending

**Results:** Pending.

---

### Task 3: QA/audit that the assembly imports cleanly with the new addon path

**Bead ID:** `oc-9vm`  
**SubAgent:** `primary`  
**Role:** `qa` / `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Independently verify that the assembly now uses `aerobeat-input-core` both as the GodotEnv addon key and mounted addon path, that the regenerated addon tree matches, and that the project still imports cleanly. Close only if the evidence supports it.

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
