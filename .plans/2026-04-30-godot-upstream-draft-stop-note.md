# Stop note — hold the narrowed Godot upstream draft

**Date:** 2026-04-30

We stopped before filing the narrowed Godot draft upstream.

Why: the remaining repro is still too tied to `xdotool windowclose` semantics. The supported clean/dirty split is now:

- titlebar close: clean
- `wmctrl -c`: clean
- `xdotool windowclose`: dirty

Because `xdotool windowclose` is a direct destroy path rather than a normal graceful close request, the current narrowed draft is being held/abandoned for upstream use. Reopen upstream filing only if the same `BadWindow` / non-exit behavior is reproduced through a stronger non-`xdotool windowclose` route.
