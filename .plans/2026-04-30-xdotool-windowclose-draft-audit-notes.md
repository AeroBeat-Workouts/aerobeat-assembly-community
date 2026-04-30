# Audit notes — current Godot issue draft vs `xdotool windowclose` research

**Date:** 2026-04-30  
**Bead:** `oc-nc0`  
**Plan:** `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-xdotool-windowclose-research-and-draft-reframe.md`

## Verdict

**Abandon the current draft. Hold any narrower upstream report unless we get a stronger non-`xdotool windowclose` reproduction.**

That is not the same as saying “definitely not a Godot bug.” It means the **current draft is no longer supportable** and the **remaining narrower theory is not worth reporting yet** on the evidence we have.

## Why the current draft should be abandoned

The current draft is built around a normal close-path story:

- titlebar/window-manager close is the failing trigger
- default Linux/X11/Xwayland close behavior is broadly broken
- native Wayland is the main clean comparison

The focused matrix and upstream research broke that story.

What the current evidence actually supports:

- titlebar close is clean
- `wmctrl -c` is clean
- `xdotool windowclose` is the dirty route
- `xdotool windowclose` is documented/implemented as **destroying** the window (`XDestroyWindow`), not sending a graceful close request
- the missing `WM_CLOSE_REQUEST` on that route is therefore expected from the tool semantics, not strong evidence of a normal-close regression in Godot

So the current draft should not be “held for minor edits.” Its central framing is wrong enough that it should be retired.

## Is any narrower upstream report still justified?

**Maybe, but not yet.**

The only remaining upstream-worthy theory is narrower:

> On X11/Xwayland, if the Godot window is externally destroyed / abruptly invalidated, the X11 backend may enter repeated `BadWindow` spam and fail to self-terminate cleanly.

That is plausibly in the same family as other Godot X11 invalid-window robustness issues, but the present repro is still too tied to `xdotool windowclose` semantics.

Right now the honest call is:

- **not worth reporting yet** as an upstream issue
- **not proven to be “definitely not a bug”**

## Exact recommendation on framing if we revisit later

Do **not** frame it as:

- generic Linux close bug
- titlebar close bug
- window-manager close bug
- “Wayland fixes it” bug

If more evidence appears, frame it as:

> Linux/X11 backend robustness issue after abrupt external window destruction / invalidation, causing repeated `BadWindow` and non-exit.

That framing should only be used if we can reproduce it via at least one route that is not just “xdotool chose a non-graceful destroy command.”

## What would justify reopening upstream-report work

Any one of these would materially improve the case:

1. Reproduce the same `BadWindow` + non-exit behavior with `xdotool windowquit` or another graceful close route.
2. Reproduce it with a small raw X11 destroy/invalidation reproducer that makes the engine-side robustness issue clearer and tool-agnostic.
3. Reproduce it with another external destruction/invalidation route that upstream would recognize as meaningfully distinct from `xdotool` command semantics.
4. Find a tighter code-path match in Godot upstream showing this exact abrupt-invalid-window case is already recognized but still open.

## Recommended next action

- Mark the current draft as abandoned for upstream use.
- Keep the research notes and this audit note as the historical record.
- Only reopen upstream filing work if we get a stronger narrow repro for abrupt external window destruction robustness.
