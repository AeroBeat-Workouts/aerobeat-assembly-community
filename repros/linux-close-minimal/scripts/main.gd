extends Control

@onready var status_label: Label = $Panel/Margin/VBox/Status
@onready var details_label: Label = $Panel/Margin/VBox/Details

var _started_at_ms: int = 0
var _frames: int = 0

func _ready() -> void:
	_started_at_ms = Time.get_ticks_msec()
	print("[MinimalCloseRepro] READY pid=%s title=%s" % [OS.get_process_id(), get_window().title])
	status_label.text = "Window active"
	_update_details()

func _process(_delta: float) -> void:
	_frames += 1
	if _frames % 60 == 0:
		_update_details()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("[MinimalCloseRepro] WM_CLOSE_REQUEST uptime_ms=%s frames=%s" % [Time.get_ticks_msec() - _started_at_ms, _frames])
		get_tree().quit()

func _update_details() -> void:
	var uptime_ms := Time.get_ticks_msec() - _started_at_ms
	details_label.text = "This is a brand-new standalone Godot project kept outside the AeroBeat boot path.\n\nExpected behavior:\n1. Export bundle launches to this one screen.\n2. Closing the window prints WM_CLOSE_REQUEST to stdout.\n3. Process exits immediately after get_tree().quit().\n\nUptime: %.2fs\nFrames: %d" % [float(uptime_ms) / 1000.0, _frames]
