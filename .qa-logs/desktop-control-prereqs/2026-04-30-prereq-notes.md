# Desktop-control prerequisite notes — 2026-04-30

## Host/session state

- Session type: `wayland`
- Desktop: `zorin:GNOME`
- `WAYLAND_DISPLAY=wayland-0`
- `DISPLAY=:0` is present via Xwayland, but that does **not** make native Wayland surfaces generically automatable.
- Visible monitor layout right now: one monitor via `xrandr --listmonitors`
  - `DP-3` at `1920x1080`

## Canonical Wayland control path status

- GNOME Remote Desktop user service is running:
  - `systemctl --user status gnome-remote-desktop.service` => active
- RDP mode is aligned with the desktop-control skill’s canonical workflow:
  - `org.gnome.desktop.remote-desktop.rdp view-only` => `false`
  - `org.gnome.desktop.remote-desktop.rdp screen-share-mode` => `'mirror-primary'`
- Host-local screenshot observability works:
  - verified with `gnome-screenshot --include-pointer`
  - proof artifact: `.qa-logs/desktop-control-prereqs/preflight-pointer-shot.png`
- GNOME/Mutter D-Bus capability probes are present for:
  - `org.gnome.Shell.Screenshot`
  - `org.gnome.Shell.Introspect`
  - `org.freedesktop.portal.Desktop`
  - `org.gnome.Mutter.RemoteDesktop`
  - `org.gnome.Mutter.ScreenCast`

## Canonical blind-click helper

- Required canonical helper path:
  - `/home/derrick/.openclaw/workspace/skills/desktop-control/scripts/libfreerdp-blind/build/blind_rdp_client`
- Initial state: helper was missing.
- Action taken: rebuilt it via the documented ensure script:
  - `/home/derrick/.openclaw/workspace/skills/desktop-control/scripts/ensure_blind_rdp_client.sh`
- Current state: helper is now present and executable.
- Helper usage/help responds correctly.
- Guard wrapper also exists and is usable for enforced selector-based clicks:
  - `/home/derrick/.openclaw/workspace/skills/desktop-control/scripts/guarded_blind_click.py`

## Sudo/dependency notes

- Temporary sudo grant was active and usable during this prep.
- Sudo was required because the helper build initially failed on missing FreeRDP 3 development packages.
- Installed with sudo:
  - `freerdp3-dev`
  - `libwinpr3-dev`
- One `apt-get update` attempt was blocked by an existing apt lock from another updater process, so I used the minimal install path instead of forcing the lock.

## Honest remaining control limits for QA

- Follow the skill exactly: for live blind mouse clicks on Wayland, use only the canonical helper path above. Do **not** switch to `ydotool` or another click backend.
- The canonical helper is a **click-only transport**. Pointer movement/positioning must already be handled by the separate movement system before firing the click.
- Use the screenshot-first closed loop:
  1. fresh `gnome-screenshot --include-pointer`
  2. selector / recursive narrowing for the current target
  3. click through the canonical helper only after the target is isolated enough
  4. post-action screenshot to confirm outcome
- X11 tools on this host (`xdotool`, `wmctrl`, `xwininfo`, `xprop`) are available, but on Wayland they are only trustworthy for Xwayland-visible surfaces and diagnostics.
- Protected surfaces remain unsafe/unreliable by design for automation: portal pickers, permission dialogs, lock/login, polkit, and similar secure dialogs.
- GRD journal still shows recurring PipeWire wrong-context warnings; service is up, but QA should validate by application-side state change rather than trusting transport visuals alone.
- The skill’s current honesty boundary still applies: cursor placement and screenshots can be truthful, but click success must be confirmed from the app/resulting UI state, not assumed from pointer position alone.
