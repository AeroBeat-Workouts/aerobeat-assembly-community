# Audit — rebuilt artifact identity vs desktop-control close result

**Date:** 2026-04-30  
**Auditor bead:** `oc-3hy`  
**Plan reviewed:** `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-qa-rebuild-and-desktop-control-close-test.md`

## Verdict

**The rebuilt-artifact + human-equivalent close result narrows and weakens the current upstream framing.**

The rebuilt artifact identity is credible and apples-to-apples enough for operator testing:
- stock Godot `4.7.beta1` **debug** export shape
- stock wrapper hash matches earlier stock export
- binary hash matches the installed `linux_debug.x86_64` export template exactly
- only the regenerated PCK hash changed

But the new close result matters more for upstream wording:
- under an actual titlebar-close style interaction on the rebuilt stock export, QA got **one `WM_CLOSE_REQUEST`, zero `BadWindow`, no forced kill, launcher exit `0`**
- that is materially different from the earlier default/X11-discoverable failure family that used stricter automation/logging paths and ended in **`BadWindow` spam + forced kill + exit `143`**

So the evidence no longer supports the strongest simple claim of:
> default exported X11/Xwayland path + normal window-manager close button = reliable repro

That claim is now **too strong**.

## What changed in the evidence story

### Earlier evidence still stands
The repo still has real evidence that the exported default/X11-discoverable family can fail:
- `4.6.2` comparable default-path repro: `BadWindow`, forced kill, exit `143`
- `4.7.beta1` comparable default-path repro: same failure family
- forced native Wayland comparison: clean close, `WM_CLOSE_REQUEST`, exit `0`, no `BadWindow`
- controlled rerun of Derrick's separate manual export under logging: same backend split again

That means the X11/Xwayland-path bug family is **not invented** and is still worth preserving.

### What the new test specifically changes
The rebuilt stock artifact did **not** reproduce when QA used a screenshot-driven, human-equivalent titlebar click on the live X11-discoverable window.

That narrows the bug from a broad backend-only story to a more conditional one:
- backend/path still matters
- but **close mechanism / event path also appears to matter**
- the older failing evidence is dominated by automated/window-manager-driven close flows (`xdotool windowclose`, `wmctrl -c`, earlier harnesses)
- the new clean evidence is a direct titlebar click on the same general X11-discoverable family path

## Why this weakens the current upstream draft

The current draft says, in effect:
- export app
- run it on a Wayland desktop session on the default path
- close it with the window manager close button
- observe a hang with repeated `BadWindow`

After this audit, that wording overstates what we can currently promise.

The repo evidence now supports a weaker and more honest claim:
- there is a reproducible exported Linux close-path failure on the default/X11-discoverable path in our controlled harnesses
- forcing native Wayland avoids it in our comparison runs
- but at least one audited human-equivalent titlebar-close pass on a rebuilt stock export **closed cleanly**, so reproduction may depend on the exact close route or runtime context

## Exact difference between the clean human-close and the earlier bad paths

### Clean human-equivalent result
- live X11-discoverable window on a Wayland desktop session
- target chosen from a fresh screenshot
- pointer placed on the real titlebar close region
- single bounded click
- app logged exactly one `WM_CLOSE_REQUEST`
- wrapper exited `0`
- no `BadWindow`
- no forced kill

### Earlier bad results
- controlled close harnesses on default/X11-discoverable runs
- close initiated through automation/window-manager command paths such as `xdotool windowclose` and `wmctrl -c`
- app then emitted repeated `BadWindow`
- no clean `WM_CLOSE_REQUEST` handling on the failing path
- process hung until forced kill
- exit `143`

### Meaning
The clean titlebar-click result does **not** erase the earlier failures.
But it does mean we should stop treating all default-path closes as equivalent.

## Recommendation for Derrick's next manual testing

Before posting anything upstream, Derrick should do a short manual matrix on the rebuilt stock export **from a terminal with logs visible**:

1. **Titlebar X button** on the rebuilt stock wrapper (`./GodotClosePathMinimal.sh`)
   - repeat at least 3 times
   - confirm whether it keeps closing cleanly
2. **Alt+F4** on the same rebuilt stock wrapper
   - note whether this behaves like the clean titlebar click or like the earlier failure family
3. **Direct binary launch** (`./GodotClosePathMinimal.x86_64`) with the same two close methods
   - checks whether wrapper-shell behavior matters at all
4. If practical, rerun the old **default-path automation close** once more on the same rebuilt artifact
   - only to confirm the split is really **click vs WM/automation close path**, not just old-artifact drift

Minimum evidence to capture for each pass:
- whether `WM_CLOSE_REQUEST` appears
- whether any `BadWindow` appears
- whether the process exits on its own
- final exit code
- whether any forced kill was needed

## Recommended upstream-draft change

**Do not post the current draft unchanged.**

At minimum, change the reproduction wording so it no longer promises that a normal titlebar/window-manager close button will reliably reproduce.

### Suggested wording changes

Change the title from:
> Linux exported app hangs on close with repeated `BadWindow` on the X11/Xwayland path, but closes cleanly on native Wayland

to something narrower, for example:
> Linux exported app can hang on close with repeated `BadWindow` on the default X11/Xwayland path, while the native Wayland comparison closes cleanly

Change the issue-description bullets from:
> A minimal exported Linux Godot app hangs when I close the window on the default exported path I get on my machine.

to:
> A minimal exported Linux Godot app can hang on close on the default exported path I get on my machine.

Add a caveat near the evidence bullets, for example:
> In my controlled default-path runs, the failure reproduced when the close request came through the earlier automation/window-manager-driven paths. In a later audited titlebar-click test on a rebuilt stock export, the app closed cleanly, so the reproduction currently appears sensitive to the exact close route/runtime context.

Change the steps-to-reproduce from a deterministic promise to a scoped report of the failing path, for example:
> 4. Trigger window close using the same default-path close flow used in the failing harness runs.
> 5. Observe that on this path the process can fail to exit cleanly and can emit repeated `BadWindow` errors until force-killed.

If Derrick wants a cleaner upstream report, the better move may be to wait until the manual matrix above tells us whether **Alt+F4**, **titlebar click**, and **WM/automation close** split cleanly.

## Bottom line

- **Rebuilt artifact identity:** passes audit.
- **Desktop-control close result:** clean under human-equivalent titlebar click.
- **Effect on upstream framing:** the current draft is now **too strong** where it implies normal close-button repro on the default path.
- **Best next move:** do a short manual close-method matrix before posting anything upstream.
