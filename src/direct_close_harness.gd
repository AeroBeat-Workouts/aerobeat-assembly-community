extends Node2D
## Minimal direct-entry harness for close-path isolation.
##
## This scene is exported as the application's main scene for the dedicated
## direct harness build so QA can compare close behavior without routing through
## project.godot -> scenes/main.tscn -> src/main.gd scene switching.

@onready var status_label: Label = $StatusLabel
@onready var info_label: Label = $InfoLabel

var _start_time_ms: int = 0
var _frame_count: int = 0

func _ready() -> void:
	_start_time_ms = Time.get_ticks_msec()
	status_label.text = "Direct harness active"
	status_label.modulate = Color(0.4, 1.0, 0.4, 1.0)
	_update_info_label(0.0)

func _process(_delta: float) -> void:
	_frame_count += 1
	if _frame_count % 60 == 0:
		var uptime_s := maxf(0.0, float(Time.get_ticks_msec() - _start_time_ms) / 1000.0)
		_update_info_label(uptime_s)

func _update_info_label(uptime_s: float) -> void:
	info_label.text = """Direct Close Harness

This export boots straight into this trivial scene.
It intentionally skips:
- scenes/main.tscn
- src/main.gd
- feature-based scene switching
- MediaPipe/provider startup
- control/proof shell bootstrap

Uptime: %.1fs
Close this window to compare the pure direct-entry close path.""" % uptime_s

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("[DirectCloseHarness] Window close request; allowing normal window close path")
