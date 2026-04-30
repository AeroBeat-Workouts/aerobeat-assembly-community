# Audit — manual export discrepancy vs upstream draft

**Date:** 2026-04-30  
**Auditor bead:** `oc-4zh`  
**Plan reviewed:** `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-manual-export-vs-repro-close-path-diff.md`  
**Upstream draft reviewed:** `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-godot-upstream-issue-review-draft-linux-close-x11-xwayland.md`

## Verdict

**The new manual-export findings reinforce the upstream draft rather than contradict it.**

The draft can remain **truthful as written** because the controlled rerun of Derrick's manual export reproduced the same backend split already described upstream:
- default/manual export path still lands on an **X11-discoverable** close path and still hangs with repeated `BadWindow` plus forced-kill exit `143`
- forced `--display-driver wayland` still closes cleanly with one `WM_CLOSE_REQUEST`, exit `0`, and no `BadWindow`

So the discrepancy was not "the bug disappeared in the manual export." It was **observation-context drift**: the earlier casual manual run lacked strict backend/exit/log capture.

## What changed vs prior understanding

The comparison notes added one useful narrowing point:
- Derrick's manual export is a **stock 4.7-beta1 debug export** rather than the earlier repo-built release bundle.

That build-mode mismatch is real, but after QA reran the manual export under controlled logging, it did **not** change the material truth of the upstream bug story. The same exported artifact still reproduces on the X11/Xwayland family path and still stops reproducing on native Wayland.

## Draft-truth audit

### Claims that remain supported
- The issue is correctly framed as an exported Linux close-path bug that is **specific to the X11/Xwayland path**, not a generic all-backend Linux close failure.
- The claim that `4.7.beta1` still reproduces on the default exported path remains true.
- The claim that forced native Wayland is the clean comparison case, **not proof of a full engine fix**, remains true.
- The local launcher workaround remains correctly described as a mitigation rather than an engine fix.

### What the manual-export audit does **not** require
- No retraction of the upstream draft's core claim.
- No widening of scope to say the bug is resolved or inconsistent.
- No rewrite of the backend-split framing.

## Recommendation before posting

**No mandatory draft wording change is required before posting.**

Optional improvement only:
- If Derrick wants to preempt reviewer confusion, add one short sentence in `Issue description` after the concise evidence bullets saying that a separately re-exported stock `4.7-beta1` manual build was rerun under logging and showed the same X11/Xwayland-vs-Wayland split. This would be clarifying extra evidence, not a correction.

Suggested optional sentence shape:

> A separately re-exported stock `4.7.beta1` build was rerun under controlled logging and showed the same result: the default/X11-discoverable path still hung with repeated `BadWindow`, while `--display-driver wayland` closed cleanly.

## Bottom line

The upstream issue draft should **not** be changed for truthfulness before posting. At most, it could gain one extra corroborating sentence about the audited manual export rerun.