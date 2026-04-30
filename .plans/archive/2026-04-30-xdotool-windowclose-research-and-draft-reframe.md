# AeroBeat Assembly Community

**Date:** 2026-04-30  
**Status:** ✅ Complete  
**Agent:** Pico 🐱‍🏍

---

## Goal

Research whether the narrowed `xdotool windowclose` / automation-close-route-sensitive X11-path bug is already known, unsupported, or otherwise explained upstream, then use that research to decide how the Godot issue draft should be rewritten or whether it should be posted at all.

---

## Overview

The focused matrix changed the story materially. We no longer have support for a broad “Linux close hangs under normal use” framing. The strongest supported truth is now route-specific: titlebar close and `wmctrl -c` are clean, while `xdotool windowclose` triggers the `BadWindow` / no-`WM_CLOSE_REQUEST` / forced-kill failure family on the X11 path.

That makes research the right next move before any draft rewrite. First, search for Godot issues/PRs/docs and `xdotool`/X11/WM close semantics that could already explain this behavior, whether as a known engine issue or an unsupported synthetic-close path. Then audit whether the current upstream draft should be abandoned, reframed into a route-specific issue, or held entirely because the trigger path is outside what upstream would reasonably support.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Focused close matrix plan/results | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-badwindow-fallout-recovery-and-focused-close-matrix.md` |
| `REF-02` | Focused close matrix QA notes | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-a1e/2026-04-30-focused-close-matrix-notes.md` |
| `REF-03` | Focused close matrix audit | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-badwindow-fallout-recovery-and-focused-close-matrix-audit.md` |
| `REF-04` | Current upstream draft | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-godot-upstream-issue-review-draft-linux-close-x11-xwayland.md` |
| `REF-05` | Prior Godot issue draft plan | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-29-godot-upstream-issue-draft.md` |

---

## Tasks

### Task 1: Research whether `xdotool windowclose` / synthetic X11 close behavior is already known or unsupported

**Bead ID:** `oc-xl5`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and research whether the narrowed Godot bug shape is already known, unsupported, or otherwise explained upstream. Focus on `xdotool windowclose`, X11 synthetic close semantics, `BadWindow`, missing `WM_CLOSE_REQUEST`, and any Godot/Xwayland/X11 issues or docs that overlap. Distinguish exact matches, partial matches, and likely-non-bugs caused by unsupported tooling assumptions.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-xdotool-windowclose-upstream-research-notes.md`

**Status:** ✅ Complete

**Results:** Research note written at `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-xdotool-windowclose-upstream-research-notes.md`. No exact upstream Godot issue matching the current narrowed repro was found. The strongest primary-source explanation is xdotool semantics: `windowclose` is implemented as `XDestroyWindow`, while `windowquit` is the graceful request path. That matches the local matrix where titlebar close and `wmctrl -c` are clean but `xdotool windowclose` is dirty. Relevant Godot partial overlaps do exist around X11 `BadWindow` after invalid/stale window IDs (`#102039` / `#102045`) and server-side closed windows during X11 property work (`#54554` / `#54601`), which suggests possible X11 robustness debt, but not support for the current broad normal-close draft. Recommendation from this task: hold the current draft and treat any future upstream report as, at most, a narrower “external abrupt X11 window destruction robustness” issue rather than a normal window-manager close bug.

---

### Task 2: Audit the research against the current draft and recommend rewrite/hold/abandon

**Bead ID:** `oc-nc0`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Claim the assigned bead and audit the research findings against the current upstream draft. Decide whether we should: (a) rewrite it into a route-specific issue, (b) hold because the trigger path looks unsupported or too tool-specific, or (c) abandon the upstream issue entirely. If a rewrite is still justified, recommend the exact framing it should use.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-xdotool-windowclose-draft-audit-notes.md`

**Status:** ✅ Complete

**Results:** Audit notes written at `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-xdotool-windowclose-draft-audit-notes.md`. Verdict: **abandon the current upstream draft** rather than merely holding it for edits, because the focused matrix plus research no longer support its normal-close/titlebar-close framing. `xdotool windowclose` is documented and implemented as a direct window-destroy route, which explains the missing `WM_CLOSE_REQUEST` and makes the current broad draft unsound. A narrower upstream theory still exists — abrupt external X11 window destruction/invalidation may expose a Godot X11 robustness problem that leads to repeated `BadWindow` spam and non-exit — but it is **not worth reporting yet** on the current evidence because the repro remains too tied to `xdotool windowclose` semantics. Recommended next action: retire the current draft, keep the research/audit notes, and only reopen upstream filing work if the same failure can be reproduced through a stronger non-`xdotool windowclose` path or another clearly tool-agnostic abrupt-invalidation route.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Completed the research-and-audit pass for the narrowed `xdotool windowclose` finding. The repo now contains upstream research notes at `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-xdotool-windowclose-upstream-research-notes.md` and final audit notes at `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-xdotool-windowclose-draft-audit-notes.md`, with a clear recommendation on the fate of the existing Godot issue draft.

**Reference Check:** `REF-03` and the underlying focused-matrix evidence showed that titlebar close and `wmctrl -c` are clean while `xdotool windowclose` is the only dirty route. `REF-04` was audited against those findings and is no longer supportable as written because it frames the problem as a normal Linux/X11/Xwayland close-path issue. `REF-05` remains useful as draft-history context, but the current upstream-facing draft direction derived from it should be retired. Final conclusion: abandon the current draft; do not treat this as “definitely not a bug,” but also do not file a narrower upstream issue yet unless a more tool-agnostic abrupt-window-destruction repro is found.

**Commits:**
- None yet.

**Lessons Learned:** When a repro collapses onto a single automation route, the key upstream question shifts from “can I make it fail?” to “does this route represent a supported contract or just destructive tool semantics?” That distinction matters enough that some drafts should be retired, not just tweaked.

---

*Completed on 2026-04-30*
