# AeroBeat Environment Core Rollout and Repo Rename Coordination

**Date:** 2026-05-15  
**Status:** In Progress  
**Agent:** Cookie 🍪

---

## Goal

Coordinate the introduction of `aerobeat-environment-core`, the rename rollout for the existing environment repos, and the follow-up audit/update pass across AeroBeat polyrepos and docs so the new environment family lands cleanly.

---

## Overview

Derrick wants to standardize the environment architecture around a cleaner family:
- `aerobeat-environment-core`
- `aerobeat-environment-loader`
- `aerobeat-environment-gaussian-splat`

Derrick will handle the GitHub-side repo creation/renames, while the follow-up agent work will need to audit and switch references everywhere else: local repo folders, git remotes, GodotEnv dependency declarations, docs references, plan references, and any other polyrepo links. This is cross-repo coordination work, so it needs a dedicated umbrella plan before execution.

This plan should also confirm the best template for the new core repo so the created repository starts from the right AeroBeat baseline instead of forcing unnecessary cleanup later.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Higher-level environment architecture roadmap | `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/.plans/2026-05-15-default-environment-fallback-ladder.md` |
| `REF-02` | Parallel Lego-piece coordination plan | `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/.plans/2026-05-15-parallel-lego-piece-implementation-coordination.md` |
| `REF-03` | Splat core-boundary refactor plan | `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-gaussian-splat/.plans/2026-05-15-splat-core-boundary-refactor.md` |
| `REF-04` | Current environment tool repo | `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-loader` |
| `REF-05` | Current gaussian splat tool repo | `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-gaussian-splat` |
| `REF-06` | Docs repo that will likely need rename/reference updates | `/home/derrick/Documents/projects/aerobeat/aerobeat-docs` |

---

## Tasks

### Task 1: Confirm the new family naming and best template choice for `aerobeat-environment-core`

**Bead ID:** `aerobeat-assembly-community-f8h`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`  
**Prompt:** Confirm the target environment family naming, recommend the best GitHub template for the new `aerobeat-environment-core` repo, and record any core-repo bootstrap expectations so the created repo starts from the right baseline.

**Folders Created/Deleted/Modified:**
- `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-core/`

**Files Created/Deleted/Modified:**
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/.plans/2026-05-15-environment-core-rollout-and-repo-rename-coordination.md`

**Status:** ✅ Complete

**Results:** Confirmed the target naming family as `aerobeat-environment-core`, `aerobeat-environment-loader`, and `aerobeat-environment-gaussian-splat`, matching Derrick’s completed GitHub-side rename/create actions. The new `aerobeat-environment-core` repo was not present locally, so it was cloned via SSH to `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-core`. The cloned baseline is already seeded from the AeroBeat internal environment template rather than an empty repo: it includes the standard root package files (`plugin.cfg`, `README.md`, `AGENTS.md`, hidden `.testbed/`, `.github/`, and repo-local Beads scaffolding) and points at SSH remote `git@github.com:AeroBeat-Workouts/aerobeat-environment-core.git`. Current cloned HEAD: `759e371`. No bootstrap corrections were needed before proceeding to the wider rename audit.

---

### Task 2: Audit all local references that will break or drift after the GitHub renames

**Bead ID:** `aerobeat-assembly-community-k2q`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Audit the AeroBeat workspace for references to the pre-rename repo names (`aerobeat-tool-environment`, `aerobeat-tool-gaussian-splat`) and any planned/core references that will need switchover. Include polyrepo manifests, GodotEnv files, docs references, README references, and plan links.

**Folders Created/Deleted/Modified:**
- Audit only; no folder changes during this step

**Files Created/Deleted/Modified:**
- `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/.plans/2026-05-15-environment-core-rollout-and-repo-rename-coordination.md`

**Status:** ✅ Complete

**Results:** Audited the local AeroBeat workspace for string references to `aerobeat-tool-environment` and `aerobeat-tool-gaussian-splat` before applying the switchover. The results split cleanly into three buckets:
1. **Active repo/testbed references that needed update in the switchover pass:**
   - `aerobeat-environment-community/.testbed/addons.jsonc`
   - `aerobeat-environment-community/.testbed/scripts/splat_test_scene.gd`
   - `aerobeat-environment-community/.testbed/tests/test_testbed_structure.gd`
2. **Plan/docs references that needed update because they described the now-renamed active repos:**
   - coordination plans under `aerobeat-assembly-community/.plans/`
   - the environment lane plan under `aerobeat-environment-loader/.plans/`
   - the splat refactor plans under `aerobeat-environment-gaussian-splat/.plans/`
3. **Expected historical or vendored/install-copy references to review after the rename:**
   - archived planning note `aerobeat-environment-community/.plans/archive/2026-05-15-splat-format-policy-alignment.md`
   - installed addon copies under `.testbed/addons/` that mirror repo state and might need a local refresh if path keys changed

No additional active old-name references were found in top-level docs/README/manifests outside those planning files and `aerobeat-environment-community` testbed assets. This audit gave the switchover pass a bounded update surface rather than a workspace-wide mystery.

---

### Task 3: Execute the local switchover after Derrick’s GitHub-side rename/create actions

**Bead ID:** `aerobeat-assembly-community-06e`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Execute the local switchover sequence now that GitHub-side changes are live: rename local repo folders without losing history, update git remotes to SSH on the new repo names, update docs/plans/GodotEnv references, repair any local addon-path fallout, and validate what old-name references remain.

**Folders Created/Deleted/Modified:**
- `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-core/` (new local clone)
- `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-loader/` (renamed from `aerobeat-tool-environment`)
- `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-gaussian-splat/` (renamed from `aerobeat-tool-gaussian-splat`)
- `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-gaussian-splat/addons/aerobeat-environment-gaussian-splat-fulfillment/` (renamed from old fulfillment package folder)
- `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-community/.testbed/addons/aerobeat-environment-gaussian-splat/` (renamed installed addon folder)
- `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-community/.testbed/.addons/aerobeat-environment-gaussian-splat/` (renamed cached addon folder)

**Files Created/Deleted/Modified:**
- coordination plans under `aerobeat-assembly-community/.plans/`
- `aerobeat-environment-loader/.plans/2026-05-15-environment-tool-first-implementation-lane.md`
- `aerobeat-environment-gaussian-splat/README.md`
- `aerobeat-environment-gaussian-splat/.plans/2026-05-15-splat-core-boundary-refactor.md`
- `aerobeat-environment-gaussian-splat/.plans/2026-05-15-splat-lower-fulfillment-package-first-slice.md`
- `aerobeat-environment-gaussian-splat/.testbed/addons.jsonc`
- `aerobeat-environment-gaussian-splat/.testbed/tests/test_AeroToolManager.gd`
- `aerobeat-environment-gaussian-splat/src/AeroGaussianSplatManager.gd`
- `aerobeat-environment-gaussian-splat/src/AeroGaussianSplatBackgroundLoader.gd`
- `aerobeat-environment-gaussian-splat/src/AeroGaussianSplatBackgroundReadWorker.gd`
- `aerobeat-environment-gaussian-splat/addons/aerobeat-environment-gaussian-splat-fulfillment/**`
- `aerobeat-environment-community/.testbed/addons.jsonc`
- `aerobeat-environment-community/.testbed/scripts/splat_test_scene.gd`
- `aerobeat-environment-community/.testbed/tests/test_testbed_structure.gd`
- `aerobeat-environment-community/.testbed/addons/aerobeat-environment-gaussian-splat/README.md`

**Status:** ✅ Complete

**Results:** Executed the local switchover in place. Local repo folders were renamed with simple filesystem moves so the existing `.git/` directories and working trees stayed intact: `aerobeat-tool-environment -> aerobeat-environment-loader` and `aerobeat-tool-gaussian-splat -> aerobeat-environment-gaussian-splat`. Git remotes were then updated to SSH URLs on the new GitHub names: `git@github.com:AeroBeat-Workouts/aerobeat-environment-loader.git` and `git@github.com:AeroBeat-Workouts/aerobeat-environment-gaussian-splat.git`. The new `aerobeat-environment-core` repo was cloned locally via SSH and needed no further baseline repair.

Reference updates were applied across the active coordination/implementation plans plus the concrete GodotEnv/testbed surface that still depended on the old splat repo name. In `aerobeat-environment-community`, the manifest key/URL, preload path, and test assertion were updated to `aerobeat-environment-gaussian-splat`. Inside the renamed splat repo, the lower fulfillment package folder was also renamed to `aerobeat-environment-gaussian-splat-fulfillment`, all internal preload/extends/test references were updated, and the broken self-symlink under `.testbed/addons/` caused by the repo-folder rename was repaired. The local installed addon/cache folders in `aerobeat-environment-community/.testbed/addons/` and `.testbed/.addons/` were renamed as well so the updated preload paths resolve immediately instead of waiting for a later restore pass.

Validation after the switchover showed no remaining active references to `aerobeat-tool-environment`, and the only remaining `aerobeat-tool-gaussian-splat` references are intentional historical notes in archived planning plus the archived file path text they preserved at that time. No active top-level repo folders remain under the old names.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Completed the environment-family local switchover: cloned `aerobeat-environment-core`, renamed the two existing environment repos locally, repointed their Git remotes to the new SSH destinations, updated active plans/docs/manifests/scripts/tests to the new names, and repaired addon-path fallout caused by the rename.

**Reference Check:** `REF-01` through `REF-06` were rechecked during the switchover. Active references now point at `aerobeat-environment-core`, `aerobeat-environment-loader`, and `aerobeat-environment-gaussian-splat`. The only old-name references intentionally left behind are in archived historical planning under `aerobeat-environment-community/.plans/archive/2026-05-15-splat-format-policy-alignment.md`.

**Commits:**
- Pending repo commits/pushes for `aerobeat-assembly-community`, `aerobeat-environment-loader`, `aerobeat-environment-gaussian-splat`, and `aerobeat-environment-community`.

**Lessons Learned:** Cross-repo rename work is manageable when the audit distinguishes active runtime/manifests from historical/archive notes. The extra gotcha here was local GodotEnv install state: repo-folder renames changed more than docs, so addon-path symlinks/caches needed an explicit repair step too.

---

*Completed on 2026-05-15*
