# AeroBeat Assembly Editor-Open Errors: MediaPipe Plugin and Font Path

**Date:** 2026-04-24  
**Status:** Draft  
**Agent:** Pico 🐱‍🏍

---

## Goal

Fix the editor-open errors Derrick hit when opening `aerobeat-assembly-community`, specifically the MediaPipe addon popup error and the missing `default_font.ttf` path in the output log.

---

## Overview

The latest assembly/runtime truth passes validated the Linux import and runtime path under headless checks, but Derrick’s live editor open exposed two new editor-facing issues that were not closed by those earlier passes. The popup screenshot shows Godot trying to load `res://addons/aerobeat-input-mediapipe/src/input_provider.gd` as an editor plugin even though that script extends the core `input_provider` interface rather than `EditorPlugin`. Separately, the editor output reports `ERROR: Can't open file from path 'res://assets/fonts/default_font.ttf'.`, which likely comes from a stale `.tres` resource or missing tracked font asset under `assets/fonts/`.

This pass should stay narrow and truthful. We are not reopening broad MediaPipe provider work here. The work is to fix the plugin registration/wiring so the addon is not misdeclared as an editor plugin, repair the font path or asset expectation, then verify the assembly project opens in the editor without those two errors.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Derrick’s screenshot of the editor popup error | current session, 2026-04-24 14:45 EDT |
| `REF-02` | Assembly project editor plugin enablement | `project.godot` |
| `REF-03` | MediaPipe addon plugin declaration currently installed in the assembly | `addons/aerobeat-input-mediapipe/plugin.cfg`, `../aerobeat-input-mediapipe-python/plugin.cfg` |
| `REF-04` | MediaPipe addon script being incorrectly treated as a plugin | `addons/aerobeat-input-mediapipe/src/input_provider.gd`, `../aerobeat-input-mediapipe-python/src/input_provider.gd` |
| `REF-05` | Missing font path report and current font resource wiring | `assets/fonts/default_font.tres`, `assets/fonts/` |

---

## Tasks

### Task 1: Research the exact editor-open failure sources

**Bead ID:** `oc-cl5`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Reproduce or inspect the assembly editor-open failures, confirm exactly why Godot is trying to load the MediaPipe addon as an editor plugin, confirm the source of the missing `default_font.ttf` path error, and propose the smallest truthful fixes. Do not implement yet.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `assets/fonts/`
- `addons/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-24-editor-open-errors-mediapipe-plugin-and-font.md`

**Status:** ✅ Complete

**Results:** Research completed with direct file inspection plus an editor-mode CLI check. Exact plugin root cause: `project.godot:31-33` enables `res://addons/aerobeat-input-mediapipe/plugin.cfg` under `[editor_plugins]`, so Godot treats that addon as an editor plugin at editor startup (`REF-02`). The enabled `plugin.cfg` in both the mounted assembly addon and the owning sibling repo points to `script="src/input_provider.gd"` (`addons/aerobeat-input-mediapipe/plugin.cfg:1-7`, `../aerobeat-input-mediapipe-python/plugin.cfg:1-7`) (`REF-03`). That script is not an `EditorPlugin`; it extends the runtime input-provider interface from `aerobeat-core` (`addons/aerobeat-input-mediapipe/src/input_provider.gd:1`, same in sibling repo) and is explicitly documented as an assembly-facing runtime adapter, not an editor tool (`REF-04`). A direct `godot --headless --editor --path . --quit-after 1 --verbose` run truthfully showed the editor plugin loader touching `res://addons/aerobeat-input-mediapipe/src/input_provider.gd` during `Initializing plugins...`, which confirms why the editor is trying to load that runtime adapter as a plugin even though the headless editor run did not surface Derrick’s GUI popup text. Smallest truthful plugin fix: remove `res://addons/aerobeat-input-mediapipe/plugin.cfg` from the assembly repo’s `[editor_plugins].enabled` list because the current addon entrypoint is a runtime adapter, not an editor plugin. Cross-repo nuance: the underlying addon repo is also misdeclared today because its `plugin.cfg` advertises a runtime adapter as a plugin; the assembly-only fix is enough to stop this project’s popup immediately, but the owning addon repo should also stop shipping this as an editor plugin (for example by replacing the descriptor with a real `EditorPlugin` only if one truly exists, or by removing/renaming the addon metadata surface so consuming projects do not enable it as an editor plugin by default). Exact font root cause: `assets/fonts/default_font.tres:1-4` is a `FontFile` resource pointing at `res://assets/fonts/default_font.ttf`, but `assets/fonts/` only contains `default_font.tres`; there is no `default_font.ttf` in this repo, it is not tracked by git, and `git log -- assets/fonts/default_font.tres assets/fonts/default_font.ttf` shows only the `.tres` was ever added in commit `06bc165` (`REF-05`). A repo-wide grep found no live scene/project references to `assets/fonts/default_font.tres` beyond plan text, so the missing-file log appears to come from the stale resource itself being scanned/imported rather than from an active theme setting. Smallest truthful font fix: either add the actual `assets/fonts/default_font.ttf` that this resource claims to wrap, or if the project no longer uses this custom font, delete `assets/fonts/default_font.tres` instead of leaving a broken dangling resource. Because no live reference was found, deleting the stale `.tres` is the smallest truthful assembly-side fix; adding a real TTF is only justified if Derrick wants to preserve that specific custom font asset.

---

### Task 2: Fix the plugin declaration/wiring and font path issue

**Bead ID:** `oc-9fo`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Implement the smallest truthful fixes for the MediaPipe addon editor-plugin popup error and the missing `default_font.ttf` asset/path error in the assembly repo or owning repo(s) as appropriate. Keep scope tight, update the plan with exact evidence, and commit/push by default.

**Folders Created/Deleted/Modified:**
- `assets/fonts/`
- `addons/`
- `.plans/`
- `.qa-logs/`

**Files Created/Deleted/Modified:**
- `project.godot`
- `assets/fonts/default_font.tres` (deleted)
- `.qa-logs/task2-editor-open.log`
- `.qa-logs/task2-import.log`
- `.plans/2026-04-24-editor-open-errors-mediapipe-plugin-and-font.md`

**Status:** ✅ Complete

**Results:** Implemented the smallest truthful assembly-only fix set without inventing a fake editor plugin or broadening addon scope. In `project.godot:31-33`, removed `res://addons/aerobeat-input-mediapipe/plugin.cfg` from `[editor_plugins].enabled`, leaving only the real editor plugins `aerobeat-core` and `gut` enabled (`REF-02`, `REF-03`, `REF-04`). This stops Godot from trying to load the MediaPipe runtime adapter at `addons/aerobeat-input-mediapipe/src/input_provider.gd` as an editor plugin while preserving runtime addon usage, because the assembly still preloads and instantiates that adapter directly from `src/main.gd:4,71` and the integration tests still target the same runtime path in `tests/integration/test_assembly_integration.gd:3,34` and `tests/integration/test_full_pipeline.gd:4,30` (`REF-04`). For the font error, deleted the stale broken resource `assets/fonts/default_font.tres` after re-checking repo references: the only matches for `default_font.tres` / `default_font.ttf` in the assembly repo were the active plan text, a historical addon plan note, a stale `.godot` cache entry, and the resource itself; no live scene/project/runtime reference was present (`REF-05`). Validation evidence after the fix: `godot --headless --editor --path . --quit-after 1 --verbose` completed project initialization with plugin loading only for `res://addons/aerobeat-core/plugin.gd` and `res://addons/gut/gut_plugin.gd`; the output no longer referenced `res://addons/aerobeat-input-mediapipe/src/input_provider.gd` during plugin initialization and did not emit any `default_font.ttf` missing-file error. `godot --headless --path . --import --quit-after 1 --verbose` also completed without any `default_font.ttf` error and without loading the MediaPipe adapter as an editor plugin. Exact local evidence files captured for QA/audit: `.qa-logs/task2-editor-open.log` and `.qa-logs/task2-import.log`. The remaining log noise was unchanged non-scope editor shutdown leakage and controller mapping warnings, not the two targeted failures. Commit/push details pending below.

---

### Task 3: QA/audit that the assembly editor now opens without those two errors

**Bead ID:** `oc-7c5`  
**SubAgent:** `primary`  
**Role:** `qa` / `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Independently verify that opening `aerobeat-assembly-community` no longer triggers the MediaPipe plugin popup error or the missing `default_font.ttf` log error. Re-check the editor/import path and close only if the evidence supports it.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `.qa-logs/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-24-editor-open-errors-mediapipe-plugin-and-font.md`
- `.qa-logs/task3-editor-open.log`
- `.qa-logs/task3-import.log`
- `.qa-logs/task3-audit-notes.txt`

**Status:** ✅ Complete

**Results:** Independent QA/audit rerun passed on the fixed assembly state from commit `2413271` (`Fix editor-open MediaPipe plugin and font errors`) after reviewing the research context from `9d20254` (`Document editor plugin and font root causes`). Exact runtime/plugin wiring still makes sense after removing editor-plugin enablement: `project.godot:31-33` now enables only `res://addons/aerobeat-core/plugin.cfg` and `res://addons/gut/plugin.cfg` under `[editor_plugins]` (`REF-02`), while the MediaPipe addon still truthfully declares `script="src/input_provider.gd"` in `addons/aerobeat-input-mediapipe/plugin.cfg:1-7` and remains consumed as a runtime adapter from `src/main.gd:4,71` plus the integration checks in `tests/integration/test_assembly_integration.gd:3,34` and `tests/integration/test_full_pipeline.gd:4,30` (`REF-03`, `REF-04`). Independent evidence rerun on 2026-04-24: `godot --headless --editor --path . --quit-after 1 --verbose` exited `0` and its plugin initialization section loaded only `res://addons/aerobeat-core/plugin.gd` and `res://addons/gut/gut_plugin.gd`; the log contains no reference to `res://addons/aerobeat-input-mediapipe/src/input_provider.gd` and no `default_font.ttf` error (`.qa-logs/task3-editor-open.log`). `godot --headless --path . --import --quit-after 1 --verbose` also exited `0` with no `res://addons/aerobeat-input-mediapipe/src/input_provider.gd` editor-plugin load attempt and no `default_font.ttf` missing-file error (`.qa-logs/task3-import.log`). The current `assets/fonts/` directory is empty, which matches the fix of deleting the stale broken `assets/fonts/default_font.tres`; the rerun produced no font-path complaints, so the missing-font issue is resolved (`REF-05`). Remaining log noise was judged caveat-level and out of scope for this slice: controller mapping warnings emitted before project init, `Scan thread aborted...` during headless editor shutdown, and `ObjectDB instances leaked at exit` on shutdown. None of those warnings mention MediaPipe plugin misloading or the deleted font resource, so they do not block closure for this bead. Exact audit notes and line-oriented evidence were captured in `.qa-logs/task3-audit-notes.txt`.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Narrow assembly-side repair for the two editor-open failures Derrick hit: the assembly no longer enables the MediaPipe runtime adapter as an editor plugin, and the stale broken font resource that pointed at missing `res://assets/fonts/default_font.ttf` is gone. Independent QA/audit reruns confirmed the project now opens/imports headlessly without either targeted failure while preserving the intended runtime MediaPipe wiring.

**Reference Check:** `REF-02` satisfied: `[editor_plugins]` now only enables real editor plugins in `project.godot`. `REF-03` and `REF-04` satisfied: the MediaPipe addon still exposes `script="src/input_provider.gd"`, but it is consumed through runtime preload/instantiation paths rather than editor-plugin enablement. `REF-05` satisfied: no stale tracked font resource remains, `assets/fonts/` is empty, and both audit reruns produced no `default_font.ttf` error. `REF-01` closure check satisfied indirectly by reproducing the previously implicated editor-open path and verifying the popup-causing plugin load path no longer appears in logs.

**Commits:**
- `9d20254` - Document editor plugin and font root causes
- `2413271` - Fix editor-open MediaPipe plugin and font errors
- `d0fcead` - Record final QA/audit evidence for editor-open fixes

**Lessons Learned:** When an addon entrypoint is a runtime adapter rather than an `EditorPlugin`, enabling its `plugin.cfg` under `[editor_plugins]` creates misleading editor-startup failures even if the runtime path itself is valid. Also, stale unreferenced resources can still surface import/editor noise, so missing-file cleanup should verify both live references and orphaned resource files.

---

*Completed on 2026-04-24*
