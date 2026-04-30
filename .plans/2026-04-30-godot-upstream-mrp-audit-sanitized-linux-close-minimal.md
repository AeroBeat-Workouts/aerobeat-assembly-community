# Sanitized Linux close MRP audit

**Date:** 2026-04-30  
**Bead:** `oc-1n7`  
**Auditor:** OpenClaw subagent (`auditor` role)

## Verdict

**✅ Pass.**

The rebuilt sanitized MRP now passes the strict source-project ZIP audit.

Confirmed:
- the ZIP no longer contains `icon.svg.import`
- the ZIP no longer contains `scripts/main.gd.uid`
- the sanitized source tree is generic and free of AeroBeat / Derrick / OpenClaw / local-machine contamination
- the rebuilt ZIP is also generic and free of that contamination
- the ZIP contains only the minimal source-project files needed for an upstream Godot MRP

Derrick can recheck/sign off now.

## What was checked

### Source tree
Checked `repros/linux-close-minimal/` for:
- exact file set
- presence/absence of editor-generated sidecars
- generic wording
- personal/machine-specific strings
- generated artifact directories
- minimum files needed to open/run/export the repro

### ZIP
Checked `.artifacts/godot-linux-close-minimal-source-mrp-sanitized-2026-04-30.zip` for:
- exact contents list
- absence of `icon.svg.import`
- absence of `scripts/main.gd.uid`
- contamination strings in filenames and extracted text payloads
- exclusion of generated folders/artifacts
- sufficiency as a source-project MRP

## Final source tree contents

`repros/linux-close-minimal/` contains exactly:
- `.gitignore`
- `README.md`
- `export_presets.cfg`
- `icon.svg`
- `project.godot`
- `scenes/main.tscn`
- `scripts/main.gd`

## Final ZIP contents

`.artifacts/godot-linux-close-minimal-source-mrp-sanitized-2026-04-30.zip` contains exactly:
- `.gitignore`
- `README.md`
- `export_presets.cfg`
- `icon.svg`
- `project.godot`
- `scenes/main.tscn`
- `scripts/main.gd`

## Findings

### Packaging checks
- `icon.svg.import` is absent from the sanitized source tree and absent from the ZIP.
- `scripts/main.gd.uid` is absent from the sanitized source tree and absent from the ZIP.
- `.godot/`, `build/`, `dist/`, and `.qa-logs/` are excluded from the sanitized source tree and ZIP.
- No extra export outputs, logs, or editor cache artifacts were present.

### Genericity / contamination checks
- No `AeroBeat` strings found in the sanitized source tree or extracted ZIP payload.
- No `OpenClaw` strings found in the sanitized source tree or extracted ZIP payload.
- No `Derrick` strings found in the sanitized source tree or extracted ZIP payload.
- No `/home/derrick` or similar local-path contamination found.
- `README.md` and `scripts/main.gd` are phrased generically for any Godot developer.

### Minimality check
The retained files are appropriate for a minimal upstream source-project MRP:
- `project.godot` — project entry point
- `export_presets.cfg` — export preset used during testing
- `scenes/main.tscn` — only scene
- `scripts/main.gd` — only logic script
- `icon.svg` — referenced project icon
- `README.md` — human-facing repro instructions/context
- `.gitignore` — harmless repo hygiene file

## Final ZIP audited

`/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.artifacts/godot-linux-close-minimal-source-mrp-sanitized-2026-04-30.zip`
