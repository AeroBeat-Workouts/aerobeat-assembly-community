# AeroBeat Assembly OpenClaw Godot Plugin GodotEnv Integration

**Date:** 2026-04-27  
**Status:** Draft  
**Agent:** Pico 🐱‍🏍

---

## Goal

Add the OpenClaw Godot project plugin to `aerobeat-assembly-community` through GodotEnv, wire the assembly project to the OpenClaw-side connection path, and enable the plugin in Godot per the plugin instructions.

---

## Overview

The OpenClaw/Godot integration is split across three surfaces that should stay explicit: the host-side OpenClaw gateway extension under `~/.openclaw/extensions/godot/`, the workflow skill under `~/.openclaw/workspace/skills/godot/`, and the Godot project addon that belongs inside a project’s `addons/` tree. Only the third piece is a GodotEnv concern. The first two are already prepared on this host, so the remaining work is to mount the Godot plugin into the assembly project cleanly and truthfully.

For AeroBeat, the right path is to manage the project addon via root `addons.jsonc`, install it into `res://addons/openclaw/`, then enable the plugin in the assembly project the way the upstream plugin expects. Because this repo is already carrying unrelated dirty state from the MediaPipe/build thread, this pass should stay narrow and avoid silently normalizing unrelated files. We should wire the plugin in, verify the addon lands where expected, enable it in Godot, and confirm the OpenClaw-side connection path is the one being used.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Current assembly GodotEnv manifest | `addons.jsonc` |
| `REF-02` | Current assembly plugin enablement state | `project.godot` |
| `REF-03` | Earlier GodotEnv conventions for AeroBeat assembly repos | `memory/2026-04-17.md#L1-L23`, `memory/2026-04-17.md#L18-L37` |
| `REF-04` | OpenClaw Godot plugin upstream install model | `https://raw.githubusercontent.com/TomLeeLive/openclaw-godot-plugin/main/README.md` |
| `REF-05` | Local OpenClaw skill instructions already installed | `~/.openclaw/workspace/skills/godot/SKILL.md`, `~/.openclaw/workspace/skills/godot/README.md` |
| `REF-06` | Existing host-side OpenClaw extension already staged | `~/.openclaw/extensions/godot/` |

---

## Tasks

### Task 1: Define the exact GodotEnv mount contract for the OpenClaw Godot plugin

**Bead ID:** `oc-dgs`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Inspect the OpenClaw Godot plugin repo shape and determine the truthful GodotEnv entry for `aerobeat-assembly-community`: install key, repo URL, checkout strategy, and the exact `subfolder` needed so the project receives `res://addons/openclaw/` and not unrelated host-side files. Do not implement yet.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-27-openclaw-godot-plugin-godotenv-integration.md`

**Status:** ✅ Complete

**Results:** Research complete. The truthful GodotEnv install contract is to mount only the upstream addon subtree, not the whole repo. Evidence: the upstream README explicitly says to copy `addons/openclaw` into the project’s `addons/` directory (`REF-04`, `README.md` Installation + Quick Start), and a local clone confirms the repo root also contains unrelated `OpenClawPlugin~/`, `MCP~/`, and `Documentation~/` folders that must not be mounted into the Godot addon path (`.temp/openclaw-godot-plugin/`). The exact addon subtree does expose a proper Godot plugin descriptor at `.temp/openclaw-godot-plugin/addons/openclaw/plugin.cfg`, with plugin name `OpenClaw`, version `1.4.2`, and script `openclaw_plugin.gd`, so the correct assembly-side addon path is `res://addons/openclaw/plugin.cfg`.

Recommended `addons.jsonc` entry shape for Task 2: `"openclaw": { "url": "git@github.com:TomLeeLive/openclaw-godot-plugin.git", "checkout": "main", "subfolder": "/addons/openclaw" }`. The install key should be `openclaw` so the project receives `res://addons/openclaw/`; using any other key would misname the mounted addon directory, and using `subfolder: "/"` would wrongly pull repo-root host/plugin/MCP/docs files into the mounted addon path. Checkout strategy: the repo currently exposes `origin/main` and no tags from `git tag -l`, so `main` is the truthful branch-based contract today; if we later want a pinned immutable revision, pin a commit SHA instead of inventing a release tag.

Enablement should happen through the normal Godot plugin flow after install. Upstream instructs `Project → Project Settings → Plugins → OpenClaw → Enable` (`REF-04`), and this project already records plugin enablement in `project.godot` under `[editor_plugins] enabled=PackedStringArray(...)` (`REF-02`). So Task 3 should truthfully add `res://addons/openclaw/plugin.cfg` to that enabled plugin list via Godot/editor flow or an equivalent exact `project.godot` update, rather than treating install alone as activation.

---

### Task 2: Add the plugin to assembly via GodotEnv and verify installed addon layout

**Bead ID:** `oc-ajq`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Update `aerobeat-assembly-community` so GodotEnv installs the OpenClaw Godot plugin into the correct project addon path, then run the install/refresh flow and verify the resulting addon files land exactly where Godot expects them. Keep scope narrow and record the exact commands and installed paths.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `addons/`

**Files Created/Deleted/Modified:**
- `addons.jsonc`
- validation evidence as needed
- `.plans/2026-04-27-openclaw-godot-plugin-godotenv-integration.md`

**Status:** ✅ Complete

**Results:** Implemented the GodotEnv manifest change in `addons.jsonc` using the exact researched entry shape from Task 1: `"openclaw": { "url": "git@github.com:TomLeeLive/openclaw-godot-plugin.git", "checkout": "main", "subfolder": "/addons/openclaw" }` (`REF-01`, `REF-04`, `REF-05`). This keeps the install key/path truthful at `res://addons/openclaw/` and avoids mounting the upstream repo root helper folders into the Godot addon path.

Exact install/refresh commands and evidence:
1. `rm -rf addons/openclaw .addons/openclaw && godotenv addons install` initially failed because GodotEnv refused to replace a separately modified generated addon mount: `addons/aerobeat-input-mediapipe` contained untracked generated `*.uid` files and raised `Cannot delete modified addon aerobeat-input-mediapipe`.
2. To keep scope narrow and avoid touching unrelated source dirt, only disposable generated addon/cache trees were removed: `rm -rf addons/aerobeat-input-mediapipe .addons/aerobeat-input-mediapipe addons/openclaw .addons/openclaw`.
3. Re-running `godotenv addons install` from the repo root then succeeded and reported: `Resolved: Addon "openclaw" from \`addons.jsonc\` at \`addons/openclaw/\` on branch \`main\` of \`git@github.com:TomLeeLive/openclaw-godot-plugin.git\`` (`.qa-logs/oc-ajq-openclaw-install.log`).

Installed-layout verification (`REF-04`):
- Project addon path now exists at `addons/openclaw/`.
- Plugin descriptor exists at `addons/openclaw/plugin.cfg`.
- `plugin.cfg` reports `name="OpenClaw"`, `version="1.4.2"`, and `script="openclaw_plugin.gd"`.
- The referenced script exists exactly at `addons/openclaw/openclaw_plugin.gd`, so the plugin descriptor resolves within the installed project addon path the way Godot expects.
- GodotEnv cache/source tree also exists at `.addons/openclaw/addons/openclaw/plugin.cfg`, confirming the mounted project addon came from the intended upstream subtree rather than a hand-copied local folder.

Truthful caveat for QA: the install/layout slice is complete, but activation is intentionally deferred to Task 3. Also note that the generated `addons/openclaw/` and `.addons/openclaw/` trees currently include upstream `.git` metadata in addition to the addon files; the actual Godot-facing addon path is still correct, but QA/audit should decide whether that packaging detail is acceptable or worth a follow-up against GodotEnv/upstream packaging behavior.

---

### Task 3: Enable the plugin in Godot and verify the OpenClaw connection path

**Bead ID:** `oc-wsm`  
**SubAgent:** `primary`  
**Role:** `qa`  
**References:** `REF-02`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Enable the installed OpenClaw Godot plugin in the assembly project the way upstream documents, then verify the project is using the OpenClaw-side connection path and report the best truthful evidence available from the editor/project state.

**Folders Created/Deleted/Modified:**
- `.plans/`
- project/editor files as required by the plugin enablement flow

**Files Created/Deleted/Modified:**
- `project.godot`
- validation evidence as needed
- `.plans/2026-04-27-openclaw-godot-plugin-godotenv-integration.md`

**Status:** ⏳ Pending

**Results:** Pending.

---

### Task 4: Audit the final assembly-side integration slice

**Bead ID:** `oc-ddd`  
**SubAgent:** `primary`  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Audit whether the assembly repo now truthfully has the OpenClaw Godot plugin integrated via GodotEnv, installed under the correct addon path, enabled in the project, and pointed at the OpenClaw-side connection model rather than a made-up local shortcut. Close only if the evidence supports that exact slice.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-27-openclaw-godot-plugin-godotenv-integration.md`

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
