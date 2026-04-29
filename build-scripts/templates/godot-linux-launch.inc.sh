# Common Linux Godot launcher logic for AeroBeat exported bundles.
# ShellCheck source=/dev/null

launcher_has_display_driver_arg() {
    local arg
    for arg in "$@"; do
        case "$arg" in
            --display-driver|--display-driver=*)
                return 0
                ;;
        esac
    done
    return 1
}

launcher_select_display_driver() {
    LAUNCHER_FORCE_X11=false
    LAUNCHER_FORCE_WAYLAND=false
    LAUNCHER_PASSTHROUGH_ARGS=()

    local arg
    for arg in "$@"; do
        case "$arg" in
            --x11)
                LAUNCHER_FORCE_X11=true
                ;;
            --wayland)
                LAUNCHER_FORCE_WAYLAND=true
                ;;
            *)
                LAUNCHER_PASSTHROUGH_ARGS+=("$arg")
                ;;
        esac
    done

    LAUNCHER_DISPLAY_ARGS=()

    if launcher_has_display_driver_arg "${LAUNCHER_PASSTHROUGH_ARGS[@]}"; then
        return 0
    fi

    if [ "${AEROBEAT_FORCE_X11:-0}" = "1" ] || [ "$LAUNCHER_FORCE_X11" = true ]; then
        return 0
    fi

    if [ "$LAUNCHER_FORCE_WAYLAND" = true ]; then
        LAUNCHER_DISPLAY_ARGS=(--display-driver wayland)
        return 0
    fi

    if [ "${XDG_SESSION_TYPE:-}" = "wayland" ] && [ -n "${WAYLAND_DISPLAY:-}" ]; then
        LAUNCHER_DISPLAY_ARGS=(--display-driver wayland)
    fi
}

launcher_report_display_driver_choice() {
    if launcher_has_display_driver_arg "${LAUNCHER_PASSTHROUGH_ARGS[@]}"; then
        status_info "Using explicit Godot display-driver argument from command line"
        return 0
    fi

    if [ "${AEROBEAT_FORCE_X11:-0}" = "1" ] || [ "$LAUNCHER_FORCE_X11" = true ]; then
        status_info "Using X11-compatible launch path (Wayland workaround disabled)"
        return 0
    fi

    if [ ${#LAUNCHER_DISPLAY_ARGS[@]} -gt 0 ]; then
        status_info "Wayland session detected; preferring native Wayland via --display-driver wayland"
        return 0
    fi

    status_info "Using default Godot display-driver selection"
}
