# AeroBeat Assembly Community GodotEnv Audit

**Date:** 2026-04-20  
**Status:** Complete  
**Agent:** Pico 🐱‍🏍

---

## Goal

Audit `aerobeat-assembly-community` against the intended assembly-side GodotEnv architecture and current folder naming conventions, then bring it up to shape through the normal coder → QA → auditor loop.

---

## Overview

Now that the package-class repos have been cleaned up and the family-wide residual root-folder issue is resolved, the next high-value target is `aerobeat-assembly-community`. This repo is assembly-class, so it should not be judged by the same `.testbed` package rules as the addon repos. Instead, it needs to be audited against the assembly-specific GodotEnv shape: root `addons.jsonc`, assembly-consumer package layout, correct addon install/runtime expectations, and current folder naming conventions.

The audit needs to be honest about two things up front. First, `aerobeat-assembly-community` was already noted as having an intentional temporary compatibility alias for MediaPipe, so we need to distinguish intentional temporary exceptions from actual shape drift. Second, the repo may also still have previously known green-state or integration issues that are not architecture-shape bugs. The plan here is to separate assembly-shape cleanup from unrelated behavioral breakage, then execute only the scoped GodotEnv/folder-name alignment work that truly belongs in this repo.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Derrick’s instruction to audit and bring `aerobeat-assembly-community` up to the new GodotEnv architecture and folder names | current session notes (2026-04-20 13:04 EDT) |
| `REF-02` | AeroBeat GodotEnv direction and repo-class rules | `memory/2026-04-17.md` |
| `REF-03` | Current assembly repo layout and files | `.` |
| `REF-04` | AeroBeat package/integration architecture guidance | `../aerobeat-input-mediapipe-python/.plans/INTEGRATION-ARCHITECTURE.md` |
| `REF-05` | Current `aerobeat-assembly-community` README/config/runtime surface | `README.md`, `addons.jsonc`, `project.godot` |

---

## Tasks

### Task 1: Audit the current assembly-community repo against intended assembly shape

**Bead ID:** `oc-c5x`  
**SubAgent:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Audit `aerobeat-assembly-community` against the intended assembly-side GodotEnv architecture and current folder naming conventions. Identify what is already aligned, what is intentional temporary exception vs actual drift, and what repo-local cleanup/change is required to bring this repo up to shape. Distinguish architecture/folder-name issues from unrelated app/test/runtime breakage. Do not edit files yet; return a concise action map with evidence.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-20-assembly-community-godotenv-audit.md`

**Status:** ✅ Complete

**Results:** Audit found that `aerobeat-assembly-community` is already mostly aligned for an assembly-class repo. The correct assembly manifest surface exists at repo root (`addons.jsonc`), README correctly documents the assembly flow using root `addons.jsonc`, generated `addons/` and `.addons/`, and root `test/`, and Git tracking state already treats `addons/` and `.addons/` as disposable generated output rather than committed content. The temporary MediaPipe compatibility alias is also intentional and documented rather than hidden drift: `addons.jsonc` installs key `aerobeat-input-mediapipe` from the `aerobeat-input-mediapipe-python` repo, runtime references use `res://addons/aerobeat-input-mediapipe/...`, and README explicitly calls that out as a deliberate scoped migration exception. The actual repo-local shape drift is small and specific: (1) accidental tool-init fallout is back in the repo as tracked `CLAUDE.md` and `.claude/settings.json`, and (2) repo-root `.gdignore` is wrong for an assembly repo because it is being used like a pattern-based ignore file even though `.gdignore` is a directory-ignore marker in Godot and it conflicts with the intended assembly behavior of loading installed addons from root `addons/`. Recommended implementation scope is therefore narrow: remove `CLAUDE.md`, remove `.claude/`, and remove the bad repo-root `.gdignore`, then re-verify that docs still truthfully describe the root `addons.jsonc` assembly flow and the temporary MediaPipe alias. The audit explicitly recommends *not* treating current MediaPipe/core contract breakage as part of this assembly-shape pass; those remain separate non-shape follow-up issues in the addon/core repos.

---

### Task 2: Implement the scoped assembly-community alignment changes

**Bead ID:** `oc-ydr`  
**SubAgent:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Implement the repo-local GodotEnv architecture and folder-name alignment changes required by the audit for `aerobeat-assembly-community`. Keep scope to actual assembly-shape cleanup, preserve truthful documentation, do not hide unrelated behavioral issues, run relevant repo-local validation, then commit and push by default.

**Folders Created/Deleted/Modified:**
- `.claude/`

**Files Created/Deleted/Modified:**
- `CLAUDE.md`
- `.claude/settings.json`
- `.gdignore`

**Status:** ✅ Complete

**Results:** Implementation landed in commit `2e486c3` (`Clean assembly repo shape drift`) and was pushed to `main`. The coder kept scope tight to the actual assembly-shape cleanup identified by the audit: deleted tracked `CLAUDE.md`, deleted tracked `.claude/settings.json` (removing `.claude/` from the repo), and deleted the bad repo-root `.gdignore`. The temporary MediaPipe compatibility alias was explicitly preserved exactly as requested: `addons.jsonc` still installs key `aerobeat-input-mediapipe` from the `aerobeat-input-mediapipe-python` repo, `project.godot` still enables `res://addons/aerobeat-input-mediapipe/plugin.cfg`, and README continues to explain that deferred alias as deliberate/temporary. Validation reported by the coder: `git diff --stat` showed only the 3 intended deletions, and consistency checks confirmed that README still documents root `addons.jsonc`, generated `addons/` and `.addons/`, and the deferred MediaPipe alias truthfully. The coder also noted the repo already had untracked `.plans/` content, which was intentionally left out of the implementation commit.

---

### Task 3: QA the aligned assembly-community repo

**Bead ID:** `oc-it7`  
**SubAgent:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-05`  
**Prompt:** Independently verify the assembly-community alignment changes. Confirm the repo now matches the intended assembly-side GodotEnv shape and folder names, that docs/config are truthful, and that any still-open non-shape issues are explicitly documented rather than hidden.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-20-assembly-community-godotenv-audit.md`

**Status:** ✅ Complete

**Results:** QA verified the scoped assembly-community cleanup independently. `CLAUDE.md` is gone, `.claude/` is gone, and the bad repo-root `.gdignore` is gone. At the same time, the root assembly flow remained intact: root `addons.jsonc` still exists as the committed manifest, README still truthfully documents root `addons.jsonc`, generated `addons/`, `.addons/`, and root `test/`, and `.gitignore` still treats `addons/` and `.addons/` as generated output. QA also confirmed that the MediaPipe compatibility alias remains present and explicitly documented: `addons.jsonc` still installs key `aerobeat-input-mediapipe` from `aerobeat-input-mediapipe-python`, `project.godot` still enables `res://addons/aerobeat-input-mediapipe/plugin.cfg`, and README still explains this as a deliberate/temporary compatibility path. Independent validation included `git log -1 --stat`, which showed only the intended cleanup deletions, and `godot --headless --path . --import`, which surfaced real script/interface errors in assembly code but not any remaining repo-shape drift. QA’s explicit verdict was that the repo is shape-clean and aligned for the assembly-side GodotEnv/folder naming rules, while separate runtime/interface issues still remain as non-shape follow-up work.

---

### Task 4: Independent audit and completion verdict

**Bead ID:** `oc-6ir`  
**SubAgent:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-05`  
**Prompt:** Audit the final state of `aerobeat-assembly-community` after implementation and QA. Truth-check whether the repo is actually up to shape for the new GodotEnv assembly architecture and folder names, and identify any precise remaining gap if it is not yet complete.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-20-assembly-community-godotenv-audit.md`

**Status:** ✅ Complete

**Results:** The auditor confirmed that the assembly-shape pass is complete and closed bead `oc-6ir`. Audit verified that the scoped cleanup commit `2e486c3` exists, the accidental Claude artifacts are gone, and the bad repo-root `.gdignore` is gone, with the only remaining `.gdignore` being the normal `.godot/.gdignore` editor-state file. Audit also confirmed that the root assembly manifest flow remains intact: `addons.jsonc` still lives at repo root, `godotenv addons install` succeeds from repo root, README still documents root `addons.jsonc`, `addons/`, `.addons/`, and root `test/`, and the temporary MediaPipe alias remains intentionally in place and documented through `addons.jsonc`, `README.md`, and `project.godot`. The auditor was explicit that the current import/runtime errors in `src/main.gd` and `src/input_manager.gd` are real but are not blockers to this repo-shape pass; they are separate runtime/interface follow-up issues in addon/core integration rather than evidence that the assembly repo still drifts from the intended GodotEnv/folder naming architecture.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Completed the assembly-side GodotEnv/folder-name audit and cleanup for `aerobeat-assembly-community`. The repo is now shape-clean for the intended assembly architecture: root `addons.jsonc` remains the canonical manifest, generated root `addons/` and `.addons/` remain the expected install/cache locations, the temporary MediaPipe compatibility alias remains intentionally documented, and the accidental tool-init/shape drift (`CLAUDE.md`, `.claude/`, and the bad repo-root `.gdignore`) has been removed.

**Reference Check:** `REF-01` is satisfied by auditing and aligning the repo to the new assembly-side GodotEnv architecture and current folder naming expectations. `REF-02` is satisfied because the repo continues to use the correct assembly-class root manifest shape rather than the package `.testbed` pattern. `REF-03` and `REF-05` now reflect a shape-clean assembly repo without the accidental Claude artifacts or the invalid repo-root `.gdignore`, while still documenting the deliberate temporary MediaPipe alias. `REF-04` remains relevant as context for package/addon architecture, but the audit correctly kept addon/core contract breakage separate from this repo-shape pass.

**Commits:**
- `2e486c3` - Clean assembly repo shape drift
- `Pending local commit` - Add assembly-community GodotEnv audit plan

**Lessons Learned:** Assembly repos need to be judged by assembly rules, not package-workbench rules. The biggest value in this pass was separating true repo-shape drift from unrelated runtime/interface breakage: the root manifest flow and folder names can be correct even while addon/core contract issues still need separate follow-up. Also, Beads/tool initialization side effects can silently reintroduce repo-local `CLAUDE.md` / `.claude/` drift, so those need to be treated as accidental shape regressions when they appear.

---

*Completed on 2026-04-20*
