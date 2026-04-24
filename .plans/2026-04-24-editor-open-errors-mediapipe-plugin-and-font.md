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

**Files Created/Deleted/Modified:**
- plugin/config/resource files as needed
- `.plans/2026-04-24-editor-open-errors-mediapipe-plugin-and-font.md`

**Status:** ⏳ Pending

**Results:** Pending.

---

### Task 3: QA/audit that the assembly editor now opens without those two errors

**Bead ID:** `oc-7c5`  
**SubAgent:** `primary`  
**Role:** `qa` / `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Independently verify that opening `aerobeat-assembly-community` no longer triggers the MediaPipe plugin popup error or the missing `default_font.ttf` log error. Re-check the editor/import path and close only if the evidence supports it.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-24-editor-open-errors-mediapipe-plugin-and-font.md`

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
