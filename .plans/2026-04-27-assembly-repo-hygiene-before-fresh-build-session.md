# AeroBeat Assembly Repo Hygiene Before Fresh Build Session

**Date:** 2026-04-27
**Status:** Draft
**Agent:** Pico 🐱‍🏍

---

## Goal

Clean up the current `aerobeat-assembly-community` working tree so the next session can start the Linux build/export proof from a truthful, low-noise repo state instead of mixing real work with leftover logs and half-finished path moves.

---

## Overview

We are explicitly **not** continuing the build/export validation in this session. The purpose of this pass is hygiene only: normalize the repo state created by the recent MediaPipe/OpenClaw investigation work, make sure transient artifacts like `.qa-logs/` are ignored appropriately, and either commit or intentionally park the current path/layout changes so the next session begins from a clean baseline.

The dirty tree currently contains three different classes of changes that should not be conflated. First, there are transient runtime artifacts under `.qa-logs/` and new desktop screenshots from the live Godot/OpenClaw verification; those should be governed by `.gitignore` rather than allowed to accumulate as accidental untracked noise. Second, there is a real repo-layout change already half-present in the tree: root `build-test.sh`, `INVESTIGATION-build-distribution.md`, and `test/` are gone while `build-scripts/build-test.sh`, `docs/INVESTIGATION-build-distribution.md`, and `tests/` exist untracked. Third, there is one stray deleted `AGENTS.md` entry that needs a truth-check before we decide whether it should stay deleted or be restored.

This pass should stay narrow. We are cleaning and documenting state, not reopening Linux build proof or MediaPipe runtime testing. The result should be: clean ignore rules, a normalized and committed repo tree if the moved files are intentional, and an explicit fresh-session handoff for the remaining build/export work.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Current dirty working tree in assembly repo | `git status --short --branch` |
| `REF-02` | Current repo ignore policy | `.gitignore` |
| `REF-03` | Newly created QA/runtime artifacts that should likely be ignored | `.qa-logs/` |
| `REF-04` | Current path-reshape candidates | `build-scripts/build-test.sh`, `docs/INVESTIGATION-build-distribution.md`, `tests/` |
| `REF-05` | Previously tracked paths now deleted in the working tree | `build-test.sh`, `INVESTIGATION-build-distribution.md`, `test/` |
| `REF-06` | Active OpenClaw/Godot integration proof already captured | `.plans/2026-04-27-openclaw-godot-plugin-godotenv-integration.md` |

---

## Tasks

### Task 1: Research the exact cleanup boundary and classify the dirty tree

**Bead ID:** `oc-clk`
**SubAgent:** `primary`
**Role:** `research`
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`
**Prompt:** Inspect the current dirty working tree in `aerobeat-assembly-community` and classify it into transient artifacts, intentional repo-layout changes, and anything ambiguous. Determine the smallest truthful cleanup scope that leaves the future build/export session in a clean state without accidentally discarding needed work.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `.qa-logs/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-27-assembly-repo-hygiene-before-fresh-build-session.md`

**Status:** ✅ Complete

**Results:** Research completed with direct working-tree and content checks. Exact dirty-tree classes:

1. **Intentional repo-layout changes already in progress, but not yet normalized:**
   - `INVESTIGATION-build-distribution.md` is deleted at repo root while `docs/INVESTIGATION-build-distribution.md` exists untracked, and the moved file content is byte-for-byte the same as `HEAD:INVESTIGATION-build-distribution.md`; this is a pure docs relocation that should be staged/committed as a rename.
   - `build-test.sh` is deleted at repo root while `build-scripts/build-test.sh` exists untracked with identical content to `HEAD:build-test.sh`; this looks like an intentional relocation, but the script still does `PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"` and `cd "$PROJECT_ROOT"`, which now resolves to `build-scripts/` instead of repo root. It also still runs GUT with `-gdir=res://test`, so the move is **not** normalized yet.
   - `test/` is deleted while `tests/` exists untracked. The two `.uid` files (`tests/integration/test_assembly_integration.gd.uid`, `tests/integration/test_full_pipeline.gd.uid`) match the old tracked files exactly, but the GDScript files are not pure renames: `tests/integration/test_assembly_integration.gd` and `tests/integration/test_full_pipeline.gd` were materially rewritten to match the current active-provider contract, while `tests/test_example.gd` appears to be the same content moved from `test/test_example.gd`. This means the repo is mid-migration from `test/` to `tests/`, not merely dirty from accidental moves.
   - Evidence that the migration is incomplete: `README.md:24,58,81,89` still documents `test/` and `res://test`, `.github/workflows/gut_ci.yml:46` still runs GUT with `-gdir=res://test`, and `build-scripts/build-test.sh:19` still does the same.

2. **Mixed `.qa-logs/` state, not a simple transient folder:**
   - The repo already tracks many `.qa-logs/*` evidence files (for example `git ls-files -- .qa-logs` includes `oc-imp-*`, `oc-izk-*`, `oc-wsm-headless-import.log`, `task1-*`, `task3-*`, and `task4-*`), so blanket-ignoring `.qa-logs/` would conflict with existing repo practice and would invalidate plan evidence paths.
   - Some currently untracked `.qa-logs/*` files are clearly intentional evidence for active plan claims, e.g. `.qa-logs/oc-5ep-editor-open-1.png` and `.qa-logs/oc-5ep-editor-open-2.png`, both cited in `.plans/2026-04-27-openclaw-godot-plugin-godotenv-integration.md:146,177`.
   - Some untracked `.qa-logs/*` files are evidence paths already cited by older plans but never committed, e.g. `.qa-logs/task2-editor-open.log` and `.qa-logs/task2-import.log`, both cited in `.plans/2026-04-24-editor-open-errors-mediapipe-plugin-and-font.md:76-82`; `task3-refresh-audit-install.log`, `task3-refresh-audit-import.log`, and `task3-refresh-audit-check-main.log` are cited from the sibling addon-core plan at `addons/aerobeat-input-core/.plans/2026-04-24-refresh-input-core-release-identity-and-consumer-pin.md:99-101`.
   - Remaining untracked `.qa-logs/oc-d0m-*`, `.qa-logs/oc-wsm-host-extension-qa-2026-04-27.log`, and `.qa-logs/task4-old-name-scan.log` are ambiguous: they may be scratch or cross-repo evidence, but I did not find matching citations in this repo’s active plans.

3. **Ambiguous-but-likely-intentional cleanup:**
   - `AGENTS.md` is deleted in the working tree. This is likely intentional repo cleanup rather than accidental loss, because the repo history shows `9afd92c` (`Remove repo-local agent instruction files`) previously removed the old repo-local instructions, then `63a7795` (`bd init: initialize beads issue tracking`) reintroduced a new `AGENTS.md` containing mostly generic Beads instructions. Deleting it now appears consistent with restoring the repo’s prior “no repo-local agent file” posture, but that should still be treated as an explicit decision during implementation.

**Concrete minimal cleanup recommendation:**
- Treat the smallest truthful cleanup scope as **normalizing and committing the path migration**, not discarding it: stage the `INVESTIGATION-build-distribution.md` → `docs/INVESTIGATION-build-distribution.md`, `build-test.sh` → `build-scripts/build-test.sh`, and `test/` → `tests/` changes together.
- In the same narrow pass, update every still-live `test` reference to `tests` (`README.md`, `.github/workflows/gut_ci.yml`, and `build-scripts/build-test.sh`) and fix `build-scripts/build-test.sh` so it resolves repo root correctly after the move; otherwise the repo remains half-migrated and the next Linux build/export session starts from a misleading baseline.
- Do **not** blanket-ignore `.qa-logs/`. Instead, keep/commit only the untracked evidence files that are actually cited by retained plans or needed for the current handoff, and either delete or relocate the remaining scratch/unreferenced session logs before the hygiene audit. The most obviously keep-worthy current files are `.qa-logs/oc-5ep-editor-open-1.png` and `.qa-logs/oc-5ep-editor-open-2.png`; `task2-*` and `task3-refresh-audit-*` need an explicit choice because plans already cite them.
- Commit the `AGENTS.md` deletion only if the hygiene implementation explicitly adopts the repo’s earlier no-repo-local-agent-file policy; otherwise restore it. My read is that deletion is the more truthful default, but it is the one item I would still call out in the implementation prompt as an intentional decision point.
- Leave the actual Linux build/export proof deferred; this cleanup pass should only make the repo start that later session from a clean, non-ambiguous baseline.

---

### Task 2: Implement the hygiene cleanup and ignore policy updates

**Bead ID:** `oc-6xz`
**SubAgent:** `primary`
**Role:** `coder`
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`
**Prompt:** Make the smallest truthful repo-hygiene changes needed in `aerobeat-assembly-community`: update ignore rules for transient artifacts such as `.qa-logs/` if appropriate, normalize intentional path moves if they are indeed the intended repo shape, and avoid touching the deferred Linux build/export proof itself. Commit/push by default if tracked files change.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `.qa-logs/`
- `docs/`
- `build-scripts/`
- `tests/`

**Files Created/Deleted/Modified:**
- `README.md`
- `.github/workflows/gut_ci.yml`
- `build-scripts/build-test.sh`
- `docs/INVESTIGATION-build-distribution.md`
- `tests/`
- `.qa-logs/oc-5ep-editor-open-1.png`
- `.qa-logs/oc-5ep-editor-open-2.png`
- `.qa-logs/task2-editor-open.log`
- `.qa-logs/task2-import.log`
- `.qa-logs/task3-refresh-audit-install.log`
- `.qa-logs/task3-refresh-audit-import.log`
- `.qa-logs/task3-refresh-audit-check-main.log`
- `AGENTS.md` (deleted)
- `.plans/2026-04-27-assembly-repo-hygiene-before-fresh-build-session.md`

**Status:** ✅ Complete

**Results:** Implemented the smallest truthful hygiene pass without reopening Linux build/export proof. I normalized the in-progress repo-layout migration instead of discarding it: staged the doc move `INVESTIGATION-build-distribution.md` → `docs/INVESTIGATION-build-distribution.md`, the validation script move `build-test.sh` → `build-scripts/build-test.sh`, and the repo-local test surface move `test/` → `tests/`. I then fixed the lingering old-path references that would have left the repo mid-migration: `README.md` now documents `tests/` and `res://tests`, `.github/workflows/gut_ci.yml` now runs GUT with `-gdir=res://tests`, and `build-scripts/build-test.sh` now resolves repo root through its parent directory before running `godotenv addons install`, `godot --headless --path . --import`, and GUT against `res://tests`.

For `.qa-logs/`, I deliberately did **not** blanket-ignore the folder because tracked evidence already lives there and several untracked files are explicitly cited by retained plans. I kept/staged the clearly referenced evidence files (`oc-5ep-editor-open-1.png`, `oc-5ep-editor-open-2.png`, `task2-editor-open.log`, `task2-import.log`, `task3-refresh-audit-install.log`, `task3-refresh-audit-import.log`, `task3-refresh-audit-check-main.log`) and removed only the unreferenced scratch-like leftovers (`oc-d0m-*`, `oc-wsm-host-extension-qa-2026-04-27.log`, `task3-refresh-audit-mounted-files.log`, `task4-old-name-scan.log`) via trash instead of silently hiding them with a new ignore rule. I also kept the working-tree deletion of repo-local `AGENTS.md` as intentional because repo history already shows a prior cleanup removing repo-local agent instructions and I found no contradictory repo-owned need to restore it. Implementation commit: `92721ed` (`Normalize assembly repo hygiene migration`). Push/closure status follows from the remaining workflow roles.

---

### Task 3: Audit the cleaned assembly repo and leave a fresh-session handoff

**Bead ID:** `oc-hax`
**SubAgent:** `primary`
**Role:** `auditor`
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`
**Prompt:** Audit that the cleanup pass left `aerobeat-assembly-community` in a truthful handoff state for a fresh future build/export session: transient artifacts are governed appropriately, intentional repo-layout changes are normalized, and the remaining Linux build/export work is clearly deferred rather than half-executed.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-27-assembly-repo-hygiene-before-fresh-build-session.md`

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
