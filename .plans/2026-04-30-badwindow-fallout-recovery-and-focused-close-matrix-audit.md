# Audit — recovery procedure and focused close-route matrix

**Date:** 2026-04-30  
**Bead:** `oc-0z0`  
**Plan:** `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-badwindow-fallout-recovery-and-focused-close-matrix.md`

## Scope audited

- Recovery/session reset notes: `.plans/2026-04-30-badwindow-fallout-session-reset-notes.md`
- Recovery QA notes: `.qa-logs/oc-ucn/2026-04-30-recovery-qa-notes.md`
- Focused matrix notes: `.qa-logs/oc-a1e/2026-04-30-focused-close-matrix-notes.md`
- Focused matrix raw evidence: `.qa-logs/oc-a1e/focused-close-matrix-20260430-142039/`
- Manual discrepancy audit context: `.plans/2026-04-30-manual-export-vs-repro-close-path-diff.md`
- Current upstream draft: `.plans/2026-04-30-godot-upstream-issue-review-draft-linux-close-x11-xwayland.md`

## Independent evidence check

I spot-checked the raw artifacts, not just the summaries.

### Recovery procedure

The recovery chain is supported by the evidence:

- Before reset, Task 2 documented the bad baseline as an unmapped/iconic X11 object.
- After restarting **Xwayland only**, the rebuilt artifact opened visibly again.
- Recovery QA then verified a real visible baseline:
  - `open-window-state.txt` shows visible IDs and `Map State: IsViewable`
  - `final-close-verification.txt` shows a semantic titlebar `Close` action succeeded
  - the app log includes exactly one `WM_CLOSE_REQUEST`
  - no leftover process/window remained after close

Audit verdict on recovery: **pass**. The truthful recovery recipe is:

1. kill leftover `GodotClosePathMinimal.x86_64` processes
2. restart the current session’s `Xwayland`
3. relaunch and re-verify visible open state

That is a real recovery procedure, not just hopeful cleanup.

### Focused close-route matrix

The raw focused-matrix artifacts support a clean route split:

#### Titlebar close

Verified from the recovery QA evidence rather than duplicated in the matrix run:

- visible open state confirmed
- semantic titlebar `Close` action succeeded
- app logged `WM_CLOSE_REQUEST`
- no `BadWindow`
- no leftover process/window

#### `wmctrl -c`

Raw evidence matches the notes:

- `wmctrl-result.txt` says:
  - `WM_CLOSE_REQUEST_LOGGED yes`
  - `BADWINDOW no`
  - `FORCED_KILL_NEEDED no`
  - `NEXT_LAUNCH_DEGRADED_OR_BLANKED no`
- `wmctrl-open.log` contains one `WM_CLOSE_REQUEST`
- `wmctrl-open.log` contains zero `BadWindow`
- `wmctrl-next-launch-xwininfo.txt` shows `Map State: IsViewable`

#### `xdotool windowclose`

Raw evidence also matches the notes:

- `xdotool-windowclose-result.txt` says:
  - `WM_CLOSE_REQUEST_LOGGED no`
  - `BADWINDOW yes`
  - `FORCED_KILL_NEEDED yes`
  - `NEXT_LAUNCH_DEGRADED_OR_BLANKED no`
- `xdotool-windowclose-open.log` contains **53943** `BadWindow` lines
- `xdotool-windowclose-open.log` contains **zero** `WM_CLOSE_REQUEST`
- `xdotool-windowclose-next-launch-xwininfo.txt` shows `Map State: IsViewable`

Audit verdict on matrix: **pass**. The route split is real and reproduced.

## Truthful narrowed bug statement

The currently supported bug statement is:

> On this Linux Wayland-session/X11-path repro, the failure is **route-specific**. Normal titlebar close and `wmctrl -c` are in the clean family and produce `WM_CLOSE_REQUEST` with no `BadWindow`. `xdotool windowclose` is the dirty family and reproduces heavy `BadWindow` spam, no `WM_CLOSE_REQUEST`, and a forced-kill requirement.

Put more bluntly:

- **titlebar close:** clean
- **`wmctrl -c`:** clean
- **`xdotool windowclose`:** bad

The stronger earlier statement that the dirty route reliably poisons the **next** launch is **not supported as the current primary claim** after the focused rerun. In this audit set, the next launch after explicit cleanup was still visible and normal.

## Upstream-draft decision

## Decision: hold and rewrite/narrow before any upstream post

The current upstream draft should **not** be posted as written.

Why:

- it currently tells upstream to close the app using the **window manager close button**
- the audited evidence now shows the window-manager/titlebar close route is **clean**, not failing
- `wmctrl -c` is also clean
- the reproduced failure is now specifically tied to **`xdotool windowclose`**

So the existing draft’s central framing is no longer truthful enough.

### What not to say upstream now

Do **not** currently claim:

- “closing the window with the titlebar close button hangs the export”
- “ordinary window-manager close on Linux/X11 reproduces the bug”
- “the next launch becomes degraded/blank as the primary expected fallout”

Those claims are not what this audit supports.

### Recommended next action

Before any upstream filing, Derrick should decide whether an **automation-route-specific** issue is worth reporting.

My recommendation:

- **Hold** the current draft immediately.
- If the intent is still to report upstream, **rewrite/narrow** it to an automation-route-sensitive X11 close-path issue.
- If upstream relevance depends on ordinary human close being broken, then **abandon** the current filing idea entirely, because that story no longer holds.

Given the current evidence alone, I would **not** post the existing draft and I would **not** post a titlebar-close bug.

## Suggested wording changes if the draft is salvaged

### Title

Replace the current title with something closer to:

> Linux exported app hits repeated `BadWindow` on the X11 path when closed via `xdotool windowclose`, while titlebar close and `wmctrl -c` close cleanly

### Tested versions / issue description

Replace claims about generic close failure with something like:

> On my Linux Wayland desktop session, the exported app still lands on an X11/Xwayland-manageable path by default. In a focused close-method matrix, ordinary titlebar close and `wmctrl -c` both close cleanly and log `WM_CLOSE_REQUEST`. The failure reproduces specifically when the same window is closed via `xdotool windowclose`: the app emits repeated `BadWindow` errors from `platform/linuxbsd/x11/display_server_x11.cpp`, never logs `WM_CLOSE_REQUEST`, and requires forced termination.

### Steps to reproduce

Replace the current close step with:

1. Launch the exported app on Linux so it appears as an X11-manageable window.
2. Confirm it renders normally.
3. Close it with `xdotool windowclose <window-id>`.
4. Observe repeated `BadWindow` errors and lack of clean exit.
5. For comparison, rerun and close via the titlebar close button or `wmctrl -c`; those routes close cleanly.

## Final audit verdict

- **Recovery procedure:** verified
- **Focused matrix:** verified
- **Truthful bug framing:** now **tool/route-specific**, not generic titlebar close
- **Current upstream draft:** **hold and rewrite/narrow** before any posting

If Derrick wants an upstream post, it should be about the **`xdotool windowclose` route on the X11 path**, not about ordinary titlebar close.