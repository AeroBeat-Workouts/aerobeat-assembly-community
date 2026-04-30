# AeroBeat Assembly Community

**Date:** 2026-04-29  
**Status:** In Progress  
**Agent:** Pico 🐱‍🏍

---

## Goal

Determine whether newer Godot builds, especially 4.7 beta/current prerelease builds, contain Linux/X11/Wayland window-close fixes that could plausibly resolve the standalone exported close-path `BadWindow` hang, and if so validate our minimal repro against the most promising build.

---

## Overview

We already have a strong standalone non-AeroBeat repro in `repros/linux-close-minimal/`, which means this thread is now mostly an upstream/runtime validation problem rather than an AeroBeat code problem. The next useful move is to compare our signature against the latest upstream Godot release/beta history and recent Linux/X11/Wayland-related fixes.

This plan keeps the work in two phases: first a research pass to identify whether a newer Godot build likely contains a relevant fix, and then a controlled local validation pass using the existing minimal repro. We should avoid random version churn; instead we should pick the most evidence-backed candidate build, document the fix candidates, install that build cleanly on Derrick’s terminal, and rerun the same repro so results stay comparable.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Active teardown/isolation investigation plan | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-28-mediapipe-proof-teardown-isolation.md` |
| `REF-02` | Standalone close-repro memory writeup | `/home/derrick/.openclaw/workspace/memory/2026-04-29-linux-close-repro.md` |
| `REF-03` | Standalone minimal repro project | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/repros/linux-close-minimal/` |
| `REF-04` | Godot issue `#102633` | `https://github.com/godotengine/godot/issues/102633` |

---

## Tasks

### Task 1: Research latest Godot versions and relevant fix candidates

**Bead ID:** `oc-smk`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and research the most up-to-date Godot versions relevant to this Linux close-hang investigation, with emphasis on 4.7 beta/current prerelease builds. Identify release notes, merged PRs, or commits involving Linux/X11/Xwayland/Wayland/window-destruction/`BadWindow` behavior that could plausibly affect our standalone exported close-path hang. Compare those candidates against our exact repro signature and recommend the single best build to test first. Do not install anything yet.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-29-godot-4-7-close-hang-check.md`

**Status:** ✅ Complete

**Results:** Research completed and bead `oc-smk` was closed with a proceed recommendation. Latest relevant builds found: `4.6.2-stable` and `4.7-beta1` (commit `1c8cc9e7e`), with `4.7-dev5` as the prior prerelease. No convincing exact fix was found for our standalone exported Linux/X11/Xwayland `BadWindow` close-hang, but several recent LinuxBSD/windowing changes are plausibly adjacent enough to justify a low-confidence validation pass, especially PRs `#117385`, `#116692`, `#116513`, `#118205`, and `#118680`. Best first candidate: `4.7-beta1`, because it includes both the current stable fixes and additional 4.7-era Wayland/window cleanup/existence-check work. Important caveat: because Linux exports still default to X11, an apples-to-apples rerun may not exercise the Wayland-native fixes unless we later force Wayland explicitly.

---

### Task 2: Install the most promising Godot candidate on Derrick’s terminal

**Bead ID:** `oc-7yh`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-03`  
**Prompt:** Claim the assigned bead and install the single most promising Godot candidate selected by Task 1 onto Derrick’s terminal in a way that preserves the existing stable setup or makes rollback obvious. Document exact binary/version/commit hash and any path or launcher changes. Do not broaden scope beyond installing the chosen candidate cleanly.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/repros/linux-close-minimal/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/repros/linux-close-minimal/godot-4.7-beta1-install-notes.md`
- `~/.local/bin/godot-4.7-beta1`
- `~/.local/share/applications/org.godotengine.Godot-4.7-beta1.desktop`
- `~/.local/share/openclaw/godot/installs/4.7-beta1-standard-20260429075106/`
- `~/.local/share/godot/export_templates/4.7.beta1`

**Status:** ✅ Complete

**Results:** Installed Godot `4.7.beta1.official.1c8cc9e7e` side-by-side without touching the existing default stable setup. `~/.local/bin/godot` remains on stable `4.6.2.stable.official.71f334935`; the unchanged stable desktop entry remains `org.godotengine.Godot.desktop`. The new beta is available as `~/.local/bin/godot-4.7-beta1`, with its binary at `~/.local/share/openclaw/godot/installs/4.7-beta1-standard-20260429075106/godot`, matching upstream commit `1c8cc9e7e2c9a083cf726e74193d3824fb38cda4`. Export templates were installed under `~/.local/share/godot/export_templates/4.7.beta1`, and rollback is isolated and obvious because stable was left untouched.

---

### Task 3: Re-run the standalone minimal repro against the chosen Godot candidate

**Bead ID:** `oc-my4`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-02`, `REF-03`  
**Prompt:** Claim the assigned bead and rerun the standalone minimal Linux close-path repro against the newly installed Godot candidate using the most comparable export/run/close harness possible. Capture whether the `BadWindow` spam, hang, exit-code `143`, or any close-path regression/improvement still occurs. Keep artifacts and summary directly comparable to the prior `oc-6q7` baseline.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/repros/linux-close-minimal/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-my4/`

**Status:** ✅ Complete

**Results:** QA rebuilt `repros/linux-close-minimal` against side-by-side `godot-4.7-beta1` using the same `build-linux-bundle.sh` flow by PATH-shimming `godot` to `~/.local/bin/godot-4.7-beta1`. A small non-destructive template-layout fix was needed because the beta export templates initially lived one directory deeper than the export flow expected; the corrected layout was captured in `.qa-logs/oc-my4/template-root-after-fix.txt`. The repro result is materially unchanged from baseline `oc-6q7`: `BadWindow` spam still appears, the app still hangs until forced kill, and exit code remains `143`. The spam volume was lower (`129429` vs `193711` baseline), and the X11 handler site shifted from `display_server_x11.cpp:1310` to `:1335`, but the failure mode remained the same, so no truthful fix claim is supported yet.

---

### Task 4: Independently audit whether the newer Godot build changes the truth state

**Bead ID:** `oc-yoj`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and independently audit whether the tested newer Godot build materially changes the truth state of the exported Linux close-path bug. Review the research evidence, installed version details, repro artifacts, and compare against the old baseline. Decide whether the bug appears fixed, reduced, unchanged, or still ambiguous.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/`

**Files Created/Deleted/Modified:**
- audit notes embedded in plan/results summary

**Status:** ✅ Complete

**Results:** Auditor verdict: **unchanged**. Comparing baseline `oc-6q7` against `4.7-beta1` validation `oc-my4`, both runs still hang until forced kill and exit with code `143`, under the same session context (`XDG_SESSION_TYPE=wayland`, `DISPLAY=:0`, `WAYLAND_DISPLAY=wayland-0`). The repeated `BadWindow` failure still routes through `platform/linuxbsd/x11/display_server_x11.cpp`; only the handler line number changed (`:1310` → `:1335`). Spam volume dropped (`193711` → `129429`), but the materially important truth state did not improve, so the apples-to-apples exported repro can honestly be treated as unchanged. If we want to probe whether 4.7’s likely Wayland-native fixes matter, the next optional slice is one Wayland-forced follow-up because this comparable run still exercised the X11/Xwayland path.

---

### Task 5: Run one Wayland-forced 4.7-beta1 follow-up for issue-quality evidence

**Bead ID:** `oc-7wx`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-02`, `REF-03`  
**Prompt:** Claim the assigned bead and run one additional Linux close-path repro using the standalone `repros/linux-close-minimal/` project built/tested with `godot-4.7-beta1`, but force the runtime down the most truthful Wayland-native path you can achieve without disturbing the stable setup. Keep this narrowly scoped: the goal is issue-quality evidence about whether 4.7’s likely Wayland-native fixes matter compared to the already-recorded X11/Xwayland path. Capture the exact backend/path exercised, whether the app still hangs on close, whether `BadWindow` still appears, and how the result compares to baseline beads `oc-6q7` and `oc-my4`.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/repros/linux-close-minimal/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-7wx/`

**Status:** ✅ Complete

**Results:** QA ran the standalone repro against side-by-side `Godot 4.7-beta1` on a forced native Wayland path using `run.sh --display-driver wayland`, then closed it with a real compositor-visible `uinput` `Alt+F4` instead of the older X11 automation path. Evidence shows this was genuinely Wayland-native: `XDG_SESSION_TYPE=wayland`, `WAYLAND_DISPLAY=wayland-0`, `WAYLAND_DEBUG=1` captured `wl_display` / `wl_registry` / `xdg_wm_base` / `xdg_toplevel`, while `wmctrl` and `xdotool` never found a matching X11 window. On this Wayland-native path the app closed cleanly: `WM_CLOSE_REQUEST` logged once, exit code `0`, no `BadWindow`, and no forced kill. Compared to baseline `oc-6q7` and default-path `oc-my4`, this strongly narrows the bad close behavior toward the X11/Xwayland path rather than native Wayland on `4.7-beta1`. Artifacts live under `.qa-logs/oc-7wx/`, especially `summary.md`, `proof-minimal-wm-close-beta1-wayland.log`, `proof-minimal-wm-close-beta1-wayland-wayland-debug.log`, and `proof-minimal-wm-close-beta1-wayland-meta.txt`.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** We researched the latest Godot stable/prerelease builds for plausible Linux/X11/Wayland close-path fixes, installed `4.7-beta1` side-by-side without disturbing stable, reran the standalone `repros/linux-close-minimal/` export/repro against it on the comparable default path, and then ran one additional forced native-Wayland follow-up. The result is now much sharper: `4.7-beta1` does **not** materially resolve the bug on the comparable default X11/Xwayland path, but the same minimal repro **does** close cleanly on the forced native Wayland path with no `BadWindow`, no hang, and exit code `0`.

**Reference Check:** `REF-01` and `REF-02` are now strengthened by the new split result: the strongest shared bug framing is exported Linux **X11/Xwayland** close-path failure rather than a generic all-backend Linux close failure or AeroBeat-specific teardown. `REF-03` remained the truth anchor for both the comparable and Wayland-forced validations. `REF-04` still looks like adjacent bug-family overlap rather than an exact resolved match, but the new backend split gives us much better issue-quality evidence.

**Commits:**
- None yet.

**Lessons Learned:** Newer engine churn alone is not enough evidence of a fix. Backend-specific validation matters: a Wayland desktop session is not the same as a native Wayland app path. The most useful upstream issue framing now is the backend split itself — broken on X11/Xwayland, clean on forced native Wayland under `4.7-beta1`.

---

*Completed on 2026-04-29*
