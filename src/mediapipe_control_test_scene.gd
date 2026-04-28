extends Node2D
## No-sidecar control scene for exported close-crash isolation.
##
## Keep the visible shell comparable to the MediaPipe proof window while
## intentionally avoiding every sidecar/autostart/camera startup path.

@onready var status_label: Label = $StatusLabel
@onready var info_label: Label = $InfoLabel
@onready var camera_display: TextureRect = $CameraDisplay

var _start_time_ms: int = 0
var _frame_count: int = 0

func _ready() -> void:
	_start_time_ms = Time.get_ticks_msec()
	update_status("Control mode active (no sidecar)", Color.GREEN)
	info_label.text = """MediaPipe Proof Control

This control build keeps the proof window shell/layout comparable while
intentionally skipping:
- AutoStartManager
- MediaPipe sidecar launch
- camera stream startup
- tracking/provider startup

Close this window to test whether teardown alone resets the desktop session."""
	if camera_display:
		camera_display.modulate = Color(0.12, 0.12, 0.12, 1.0)
		camera_display.tooltip_text = "No-sidecar control placeholder"

func _process(_delta: float) -> void:
	_frame_count += 1
	if _frame_count % 60 == 0:
		var uptime_s := maxf(0.0, float(Time.get_ticks_msec() - _start_time_ms) / 1000.0)
		info_label.text = """MediaPipe Proof Control

This control build keeps the proof window shell/layout comparable while
intentionally skipping:
- AutoStartManager
- MediaPipe sidecar launch
- camera stream startup
- tracking/provider startup

Uptime: %.1fs
Close this window to test whether teardown alone resets the desktop session.""" % uptime_s

func update_status(text: String, color: Color = Color.WHITE) -> void:
	if status_label:
		status_label.text = text
		status_label.modulate = color

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("[ControlScene] Window close request; allowing normal window close path")
