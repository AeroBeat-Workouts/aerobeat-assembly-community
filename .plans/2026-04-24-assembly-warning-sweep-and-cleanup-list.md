# AeroBeat Assembly Warning Sweep and Cleanup List

**Date:** 2026-04-24  
**Status:** Complete  
**Agent:** Pico 🐱‍🏍

---

## Goal

Run a top-to-bottom warning sweep on `aerobeat-assembly-community`, then produce a truthful cleanup list that separates real blockers from lower-priority noise.

---

## Overview

Derrick asked for a direct check after the recent assembly/import/addon cleanup passes. The current repo should be substantially healthier than before, but we have repeatedly seen residual controller warnings, shutdown noise, and occasional editor/import/runtime caveats that were intentionally left out of narrower fixes.

This pass is not about blindly fixing everything at once. It is about reproducing the current state cleanly, capturing the remaining warnings/errors across the most truthful open/import/runtime paths available from this host, grouping them by severity and likely owner, and then deciding what should be fixed next versus what can remain as known noise.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Current assembly project config and main scene wiring | `project.godot`, `scenes/main.tscn`, `src/main.gd` |
| `REF-02` | Recent assembly rename/addon cleanup plans | `.plans/2026-04-24-rename-assembly-core-addon-key-to-aerobeat-input-core.md`, `.plans/2026-04-24-editor-open-errors-mediapipe-plugin-and-font.md` |
| `REF-03` | Current generated addon tree | `addons/` |

---

## Tasks

### Task 1: Reproduce current editor/import/runtime warnings and classify them

**Bead ID:** `oc-7j6`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`  
**Prompt:** Reproduce the current assembly warning/error surface as truthfully as possible from this host. Use headless editor open, import, and a light runtime path; collect the remaining warnings/errors; classify them into blocker vs caveat vs low-priority noise; and propose the next cleanup order. Do not implement fixes yet.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `.qa-logs/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-24-assembly-warning-sweep-and-cleanup-list.md`

**Status:** ✅ Complete

**Results:** Fresh 2026-04-24 host-side reproduction completed with three direct Godot passes captured in `.qa-logs/task1-editor-open.log`, `.qa-logs/task1-import.log`, and `.qa-logs/task1-runtime.log`. Exact commands used: `godot --headless --editor --path . --quit-after 1 --verbose`, `godot --headless --path . --import --quit-after 1 --verbose`, and `godot --headless --path . --quit-after 3 --verbose` (`REF-01`, `REF-03`). Current truth from those runs: there are **no reproduced blockers** on this host for editor open, import, or a light runtime boot. All three commands exited `0`, the editor/import passes loaded only `res://addons/aerobeat-input-core/plugin.gd` and `res://addons/gut/gut_plugin.gd` during plugin initialization (`.qa-logs/task1-editor-open.log:37-38`, `.qa-logs/task1-import.log:37-38`), and there was **no** `default_font.ttf` error, no MediaPipe editor-plugin misload, and no import/runtime hard failure (`REF-02`, `REF-03`). Remaining reproduced warning surface is narrow: (1) low-priority controller mapping noise before project init — repeated `Unrecognized output string "misc2" in mapping:` lines in all three logs (`.qa-logs/task1-editor-open.log:7-13`, `.qa-logs/task1-import.log:7-13`, `.qa-logs/task1-runtime.log:7-13`); (2) low-priority headless editor shutdown noise — `WARNING: Scan thread aborted...` only on the editor-open quit path (`.qa-logs/task1-editor-open.log:123-124`); (3) caveat-level shutdown leak noise — `WARNING: ObjectDB instances leaked at exit` in editor/import runs (`.qa-logs/task1-editor-open.log:130-135`, `.qa-logs/task1-import.log:139-144`), which appears on shutdown rather than during project load; and (4) caveat-level runtime feature degradation — `LatencyDisplay: Latency metrics unavailable on current public provider adapter` during the short runtime boot (`.qa-logs/task1-runtime.log:38`) even though the app otherwise started cleanly, bound the MediaPipe UDP server, and entered/left tracking without error (`.qa-logs/task1-runtime.log:32-42`). Recommended cleanup order based on current truth: first inspect the runtime adapter/latency surface so the latency UI stops advertising unavailable metrics; second investigate the shutdown leak to confirm whether it is editor/GUT-only or assembly-owned; third optionally suppress or upstream the SDL controller mapping noise; leave `Scan thread aborted...` as lowest-priority headless-editor shutdown noise unless it starts affecting real editor sessions.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** A fresh warning-surface snapshot for the current assembly repo from this host, with exact editor/import/runtime evidence captured and classified. The project currently opens, imports, and performs a short headless runtime boot without reproduced blocking errors. The remaining surface is limited to controller mapping noise, shutdown-only editor/object leak warnings, and a truthful runtime caveat that latency metrics are unavailable on the current public MediaPipe adapter.

**Reference Check:** `REF-01` satisfied by direct validation of the current `project.godot`, `scenes/main.tscn`, and `src/main.gd` wiring against live runs; the observed runtime behavior matched the current main scene and adapter preload path. `REF-02` satisfied by verifying the previously-fixed editor/plugin/font failures did not recur in the fresh logs. `REF-03` satisfied by confirming the current addon tree loads `aerobeat-input-core` and `gut` as editor plugins while the MediaPipe addon remains runtime-only in this project.

**Commits:**
- Pending final commit/push for this plan update.

**Lessons Learned:** The assembly is much cleaner than the earlier failure reports suggested; the remaining work is mostly about separating genuine runtime caveats from noisy shutdown/controller chatter. At the moment, the highest-value cleanup is the runtime-facing latency-metrics caveat because it is the only reproduced issue that affects app behavior rather than just log cleanliness.

---

*Completed on 2026-04-24*
