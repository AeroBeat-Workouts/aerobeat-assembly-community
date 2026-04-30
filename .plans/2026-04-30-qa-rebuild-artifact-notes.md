# QA Rebuild Notes — Linux Close Minimal Artifact

**Date:** 2026-04-30 10:47 EDT  
**Bead:** `oc-k52`  
**Source project:** `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/repros/linux-close-minimal/`

## Summary

Rebuilt a fresh stock-style Linux export artifact from the current minimal repro project into a new ignored QA/testing folder:

- **Artifact folder:** `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/godot-close-path-minimal-qa-rebuild-20260430-1048/`
- This stays outside the sanitized source-project ZIP path and inside repo-ignored `build/` so Derrick can test it manually without contaminating the MRP package.

## Export flavor

- **Godot binary used:** `/home/derrick/.local/bin/godot-4.7-beta1`
- **Godot version:** `4.7.beta1.official.1c8cc9e7e`
- **Export command:** `--headless --path repros/linux-close-minimal --export-debug "Linux Minimal Close Repro" .../GodotClosePathMinimal.x86_64`
- **Preset:** `Linux Minimal Close Repro`
- **Preset path basis:** `repros/linux-close-minimal/export_presets.cfg`
- **Observed output shape:** stock Linux Godot export with shell wrapper + binary + external PCK
- **Wrapper behavior:** stock generated wrapper directly launches the binary and sets the terminal title; it does **not** `exec` the binary
- **Binary identity:** rebuilt binary hash matches installed template `~/.local/share/godot/export_templates/4.7.beta1/templates/linux_debug.x86_64`, confirming a stock **debug** export template

## Exact artifact contents

### 1) Wrapper
- **Path:** `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/godot-close-path-minimal-qa-rebuild-20260430-1048/GodotClosePathMinimal.sh`
- **Size:** `147` bytes
- **SHA-256:** `97f0bf6380058764ba65fa202c00ad3fd4504d4b060f3556c87c1f6c7ce999cc`

### 2) Linux binary
- **Path:** `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/godot-close-path-minimal-qa-rebuild-20260430-1048/GodotClosePathMinimal.x86_64`
- **Size:** `73560408` bytes
- **SHA-256:** `a46ef2982935aa6439fe7c8c16072945dfbf86c53b792c5f9e41347e9dc1165a`
- **File type:** `ELF 64-bit LSB executable, x86-64, stripped`

### 3) Project data PCK
- **Path:** `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/godot-close-path-minimal-qa-rebuild-20260430-1048/GodotClosePathMinimal.pck`
- **Size:** `8432` bytes
- **SHA-256:** `6c7218dbb40a1440ff24b746fbb3886e3ca763bee91edcb5a38cde2b870029b7`

## Comparison against the earlier stock-style export in-repo

Compared against `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/godot-close-path-minimal-reproducible/`:

- **Wrapper:** identical hash/content
- **Binary:** identical hash/content
- **PCK:** same size (`8432` bytes) but **different hash** (`6c7218db...` fresh vs `8abedf7a...` earlier)

That means the rebuilt QA artifact is the same stock export *shape* and same 4.7-beta1 debug template binary, while the packed project payload was regenerated freshly from current source state.

## Supporting logs

- Export command: `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-k52/export-command.txt`
- Export log: `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-k52/export.log`
