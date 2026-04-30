#!/usr/bin/env bash
set -euo pipefail
if [[ $# -lt 5 ]]; then
  echo "usage: $0 <case-name> <workdir> <close-mode:x11|wayland> <window-regex> <command...>" >&2
  exit 2
fi
case_name="$1"
workdir="$2"
close_mode="$3"
window_regex="$4"
shift 4
outdir="$(cd "$(dirname "$0")" && pwd)"
log="$outdir/${case_name}.log"
wayland_debug_log="$outdir/${case_name}-wayland-debug.log"
meta="$outdir/${case_name}-meta.txt"
wm_before="$outdir/${case_name}-wm-before.txt"
wm_after="$outdir/${case_name}-wm-after.txt"
xdotool_before="$outdir/${case_name}-xdotool-before.txt"
xdotool_after="$outdir/${case_name}-xdotool-after.txt"
ps_after="$outdir/${case_name}-ps-after.txt"
launcher_ps_after="$outdir/${case_name}-launcher-ps-after.txt"
userjournal="$outdir/${case_name}-user-journal.log"
cmdline="$outdir/${case_name}-cmdline.txt"
fd_targets="$outdir/${case_name}-fd-targets.txt"
screenshot_before="$outdir/${case_name}-before.png"
screenshot_after="$outdir/${case_name}-after.png"
start_iso="$(date --iso-8601=seconds)"
start_epoch="$(date +%s)"
{
  echo "CASE $case_name"
  echo "START $start_iso"
  echo "PWD $workdir"
  printf 'CMD'
  for arg in "$@"; do printf ' %q' "$arg"; done
  printf '\n'
  echo "WINDOW_REGEX $window_regex"
  echo "XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-}"
  echo "DISPLAY=${DISPLAY:-}"
  echo "WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-}"
  echo "XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-}"
  echo "CLOSE_MODE $close_mode"
} > "$meta"
wmctrl -lx > "$wm_before" 2>&1 || true
xdotool search --onlyvisible --name "$window_regex" > "$xdotool_before" 2>&1 || true
gnome-screenshot --include-pointer -f "$screenshot_before" >/dev/null 2>&1 || true
(
  cd "$workdir"
  if [[ "$close_mode" == "wayland" ]]; then
    WAYLAND_DEBUG=1 "$@" >"$log" 2>"$wayland_debug_log"
  else
    "$@" >"$log" 2>&1
  fi
) &
launcher_pid=$!
echo "LAUNCHER_PID $launcher_pid" >> "$meta"
child_pid=""
for _ in $(seq 1 120); do
  ready_pid="$(grep -oE '\[MinimalCloseRepro\] READY pid=[0-9]+' "$log" 2>/dev/null | tail -n1 | sed -E 's/.*pid=([0-9]+)/\1/' || true)"
  if [[ -n "$ready_pid" ]] && kill -0 "$ready_pid" 2>/dev/null; then
    child_pid="$ready_pid"
    echo "CHILD_PID_SOURCE ready-log" >> "$meta"
    break
  fi
  child_pid="$(pgrep -P "$launcher_pid" | tail -n1 || true)"
  if [[ -n "$child_pid" ]] && kill -0 "$child_pid" 2>/dev/null; then
    echo "CHILD_PID_SOURCE child-process" >> "$meta"
    break
  fi
  if ! kill -0 "$launcher_pid" 2>/dev/null; then
    break
  fi
  sleep 0.25
done
if [[ -n "$child_pid" ]]; then
  echo "CHILD_PID $child_pid" >> "$meta"
else
  child_pid="$launcher_pid"
  echo "CHILD_PID same-as-launcher" >> "$meta"
fi
if kill -0 "$child_pid" 2>/dev/null; then
  tr '\0' ' ' < "/proc/$child_pid/cmdline" > "$cmdline" 2>/dev/null || true
  ls -l "/proc/$child_pid/fd" > "$fd_targets" 2>&1 || true
fi
win_id=""
for _ in $(seq 1 60); do
  win_id="$(xdotool search --onlyvisible --name "$window_regex" 2>/dev/null | tail -n1 || true)"
  if [[ -n "$win_id" ]]; then
    break
  fi
  if grep -q '\[MinimalCloseRepro\] READY' "$log" 2>/dev/null; then
    :
  fi
  if ! kill -0 "$child_pid" 2>/dev/null; then
    break
  fi
  sleep 0.5
done
if [[ -n "$win_id" ]]; then
  echo "WINDOW_ID $win_id" >> "$meta"
else
  echo "WINDOW_ID none" >> "$meta"
fi
if [[ "$close_mode" == "x11" ]]; then
  if [[ -n "$win_id" ]]; then
    echo "WINDOW_CLOSE_AT $(date --iso-8601=seconds)" >> "$meta"
    xdotool windowclose "$win_id" || true
    sleep 2
    if kill -0 "$child_pid" 2>/dev/null; then
      echo "WINDOW_CLOSE_RETRY_AT $(date --iso-8601=seconds)" >> "$meta"
      wmctrl -i -c "$win_id" || true
    fi
  fi
else
  if kill -0 "$child_pid" 2>/dev/null; then
    echo "UI_ALT_F4_AT $(date --iso-8601=seconds)" >> "$meta"
    python3 - <<'PY'
import time
from evdev import UInput, ecodes as e
ui = UInput({e.EV_KEY: [e.KEY_LEFTALT, e.KEY_F4]}, name='openclaw-oc-b2r-close')
time.sleep(1.0)
for code, val in [
    (e.KEY_LEFTALT, 1),
    (e.KEY_F4, 1),
    (e.KEY_F4, 0),
    (e.KEY_LEFTALT, 0),
]:
    ui.write(e.EV_KEY, code, val)
    ui.syn()
    time.sleep(0.05)
time.sleep(0.2)
ui.close()
PY
    sleep 2
    if kill -0 "$child_pid" 2>/dev/null; then
      echo "UI_ALT_F4_RETRY_AT $(date --iso-8601=seconds)" >> "$meta"
      python3 - <<'PY'
import time
from evdev import UInput, ecodes as e
ui = UInput({e.EV_KEY: [e.KEY_LEFTALT, e.KEY_F4]}, name='openclaw-oc-b2r-close-retry')
time.sleep(1.0)
for code, val in [
    (e.KEY_LEFTALT, 1),
    (e.KEY_F4, 1),
    (e.KEY_F4, 0),
    (e.KEY_LEFTALT, 0),
]:
    ui.write(e.EV_KEY, code, val)
    ui.syn()
    time.sleep(0.05)
time.sleep(0.2)
ui.close()
PY
    fi
  fi
fi
for _ in $(seq 1 20); do
  if ! kill -0 "$child_pid" 2>/dev/null; then
    break
  fi
  sleep 1
done
if kill -0 "$child_pid" 2>/dev/null; then
  echo "FORCED_KILL_AT $(date --iso-8601=seconds)" >> "$meta"
  kill "$child_pid" 2>/dev/null || true
  sleep 2
fi
if kill -0 "$child_pid" 2>/dev/null; then
  echo "FORCED_KILL9_AT $(date --iso-8601=seconds)" >> "$meta"
  kill -9 "$child_pid" 2>/dev/null || true
fi
child_exit=0
if wait "$launcher_pid"; then
  launcher_exit=0
else
  launcher_exit=$?
fi
if [[ "$child_pid" != "$launcher_pid" ]]; then
  wait "$child_pid" 2>/dev/null || child_exit=$?
else
  child_exit="$launcher_exit"
fi
end_iso="$(date --iso-8601=seconds)"
end_epoch="$(date +%s)"
{
  echo "END $end_iso"
  echo "LAUNCHER_EXIT_CODE $launcher_exit"
  echo "CHILD_EXIT_CODE $child_exit"
  echo "DURATION_SEC $((end_epoch-start_epoch))"
} >> "$meta"
wmctrl -lx > "$wm_after" 2>&1 || true
xdotool search --onlyvisible --name "$window_regex" > "$xdotool_after" 2>&1 || true
ps -p "$child_pid" -o pid=,ppid=,stat=,etime=,cmd= > "$ps_after" 2>&1 || true
ps -p "$launcher_pid" -o pid=,ppid=,stat=,etime=,cmd= > "$launcher_ps_after" 2>&1 || true
gnome-screenshot --include-pointer -f "$screenshot_after" >/dev/null 2>&1 || true
journalctl --user --since "@$start_epoch" --no-pager > "$userjournal" 2>&1 || true
