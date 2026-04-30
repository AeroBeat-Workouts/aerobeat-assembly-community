# Research notes — `xdotool windowclose` / synthetic X11 close semantics vs Godot findings

**Date:** 2026-04-30  
**Bead:** `oc-xl5`  
**Plan:** `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-xdotool-windowclose-research-and-draft-reframe.md`

## Question

Does our narrowed repro (`xdotool windowclose` on the X11/Xwayland-manageable path causing no `WM_CLOSE_REQUEST`, heavy `BadWindow`, and forced kill) already match known Godot issues, or is it better explained as unsupported / tool-specific close semantics?

## Short answer

**High confidence:** the current narrowed finding is **not** a good match for a generic “window manager close is broken” Godot report.

The strongest upstream explanation is that **`xdotool windowclose` is not the graceful close route**:

- xdotool documents `windowclose` as: **“Close a window. This action will destroy the window”**.
- xdotool implements `windowclose` with **`XDestroyWindow(...)`**.
- xdotool separately documents `windowquit` as the graceful route that **“sends a request”**.
- Our local matrix already shows the same split from the Godot side:
  - titlebar close: clean
  - `wmctrl -c`: clean
  - `xdotool windowclose`: dirty

So the missing `WM_CLOSE_REQUEST` on the `windowclose` path is **consistent with the tool semantics**, not surprising evidence that Godot is mishandling the normal user close route.

## Primary-source findings

### 1) xdotool semantics strongly explain the split

**xdotool docs:**

- `windowclose`: “Close a window. This action will destroy the window...”  
  URL: <https://github.com/jordansissel/xdotool/blob/master/xdotool.pod>
- `windowquit`: “Close a window gracefully. This action sends a request...”  
  URL: <https://github.com/jordansissel/xdotool/blob/master/xdotool.pod>

**xdotool implementation:**

- `cmd_windowclose` calls `xdo_close_window(...)`  
  URL: <https://github.com/jordansissel/xdotool/blob/master/cmd_windowclose.c>
- `xdo_close_window(...)` calls **`XDestroyWindow(xdo->xdpy, window)`**  
  URL: <https://github.com/jordansissel/xdotool/blob/master/xdo.c>
- `xdo_quit_window(...)` sends **`_NET_CLOSE_WINDOW`** via `XSendEvent(...)`  
  URL: <https://github.com/jordansissel/xdotool/blob/master/xdo.c>

### 2) `wmctrl -c` is explicitly the graceful family

Local tool help on this machine:

- `wmctrl -c <WIN>` = **“Close the window gracefully.”**

That lines up with our observed matrix split: `wmctrl -c` behaves like titlebar close, while `xdotool windowclose` does not.

### 3) Godot upstream does have real X11 `BadWindow` history — but not this exact repro

#### Partial overlap A — invalidated X11 windows can trigger `BadWindow`

- PR #54601: “Fix BadWindow X11 errors when a window is closed while processing struts”  
  URL: <https://github.com/godotengine/godot/pull/54601>
- Summary: a window can be closed on the server side while processing `_NET_CLIENT_LIST`, causing `BadWindow`; Godot added temporary error handling around that path.

**Overlap with us:** proves Godot/X11 has prior history with windows becoming invalid during server-side/window-manager interactions.

**Why it is not an exact match:** this is a different code path and not about exported app close semantics or `xdotool windowclose`.

#### Partial overlap B — killing/invalidating the game window can trigger `BadWindow`

- Issue #102039: “Unhandled XServer error” when stopping embedded game  
  URL: <https://github.com/godotengine/godot/issues/102039>
- PR #102045: “Fix BadWindow error when stopping embedded game on Linux”  
  URL: <https://github.com/godotengine/godot/pull/102045>

PR #102045 explicitly says the error happened when the game process was **killed** and the **window id became invalid**, so the next X11 call hit `BadWindow`.

Issue #102039 also says normal close routes like **Alt+F4** / the **window manager close button** do **not** reproduce that same failure family.

**Overlap with us:** very relevant pattern match. When the window disappears through a non-normal/kill-like route, Godot can hit `BadWindow` on subsequent X11 work.

**Why it is not an exact match:** this upstream issue is editor embedding / stop-button specific, not exported app + `xdotool windowclose`. But it does support the idea that **abrupt window invalidation** is the real family resemblance here, not ordinary WM close.

#### Partial overlap C — generic X11 `BadWindow` reports exist

- Issue #103978: `BadWindow` when opening KDE launcher with embedded game active  
  URL: <https://github.com/godotengine/godot/issues/103978>
- Issue #102633: generic intermittent X11 `BadWindow` crash report  
  URL: <https://github.com/godotengine/godot/issues/102633>
- Issue #54554: old X11 `BadWindow` when saving a scene  
  URL: <https://github.com/godotengine/godot/issues/54554>

**Overlap with us:** confirms this is not the first time Godot’s X11 backend has had `BadWindow` edge cases.

**Why it is not an exact match:** none of these describe `xdotool windowclose`, exported app close, or a clean-vs-dirty split where titlebar / `wmctrl -c` are fine.

## What this means for our narrowed finding

### What looks explained by tool semantics

**High confidence:** these parts now look better explained by `xdotool` semantics than by a normal-close Godot bug:

- no `WM_CLOSE_REQUEST` when using `xdotool windowclose`
- clean behavior for titlebar close and `wmctrl -c`
- route-sensitive difference between `windowclose` and the graceful close family

That is because `xdotool windowclose` is a direct **destroy-window** action, while the clean routes are graceful close requests.

### What may still be a Godot robustness problem

**Medium confidence:** even if `xdotool windowclose` is not a supported graceful-close route, the observed Godot behavior may still be **too brittle** on X11:

- repeated `BadWindow` spam (`53943` lines in the focused matrix)
- no self-termination after the window is destroyed
- forced kill required

That resembles other upstream X11 invalid-window bugs in spirit: once the window becomes invalid abruptly, Godot may keep touching stale X11 state instead of degrading gracefully.

But that is a **different claim** from “normal Linux close is broken.”

## Exact/partial-match conclusion

### Exact matches found

- **None found** for: exported Godot app + `xdotool windowclose` + no `WM_CLOSE_REQUEST` + repeated `BadWindow` + titlebar/`wmctrl -c` still clean.

### Partial matches found

- **Strong partial:** Godot PR #102045 / issue #102039 — invalid window after kill/stop path causing `BadWindow` on the next X11 call.
- **Moderate partial:** Godot PR #54601 / issue #54554 — server-side closed window during X11 property processing causing `BadWindow`.
- **Weak partial:** other generic X11 `BadWindow` issues, because they share the backend symptom but not the trigger or close-route split.

## Recommendation

### Recommendation for the current draft

**Do not post the current upstream draft.** It is framed as ordinary window-manager/titlebar close failure, and our audited evidence no longer supports that.

### Recommendation on whether this is still upstream-reportable

**Primary recommendation: hold, and probably do not report this as-is.**

Reason:

- the trigger route currently depends on **`xdotool windowclose`**, which upstream can reasonably view as a **non-graceful synthetic destroy** rather than a supported user-close path
- titlebar close and `wmctrl -c` are both clean
- the strongest explanatory source is the xdotool implementation itself, not a Godot normal-close regression

### Narrow exception where a report could still be justified

If Derrick still wants to pursue an upstream issue, the only framing that currently looks defensible is:

> On X11/Xwayland, if the game window is destroyed externally / abruptly invalidated (for example via an X11 destroy-window route), Godot’s X11 backend can enter a repeated `BadWindow` spam / non-exiting state instead of handling the invalid window robustly.

Even then, I would treat it as **low-to-medium confidence upstream-reportable** unless we can reproduce the same failure with:

- a non-xdotool reproduction using a smaller/raw X11 destroy path, or
- another external close/invalidation route that is clearly not just xdotool-specific behavior.

## Bottom line

- **Generic close bug?** No.
- **Normal titlebar / WM close bug?** Current evidence says no.
- **Tool-specific semantics explain the missing `WM_CLOSE_REQUEST`?** Yes, strongly.
- **Possible X11 robustness issue after abrupt external destruction?** Maybe, but that is a narrower and less compelling upstream report than the original draft.
