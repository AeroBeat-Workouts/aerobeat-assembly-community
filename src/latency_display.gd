class_name LatencyDisplay
extends Control
## Real-time latency display UI for AeroBeat MediaPipe integration

@export var update_interval_ms: float = 100.0  # Update every 100ms
@export var show_breakdown: bool = true
@export var warning_threshold_ms: float = 60.0
@export var critical_threshold_ms: float = 100.0

var _provider: MediaPipeProvider
var _update_timer: float = 0.0
var _current_metrics: Dictionary = {}

# UI Elements
var _main_label: Label
var _breakdown_label: Label
var _background: ColorRect

# Colors
var _color_good := Color(0.0, 1.0, 0.0, 1.0)  # Green
var _color_warning := Color(1.0, 0.8, 0.0, 1.0)  # Yellow
var _color_critical := Color(1.0, 0.0, 0.0, 1.0)  # Red
var _bg_color := Color(0.0, 0.0, 0.0, 0.7)

func _ready():
	_setup_ui()
	_find_provider()
	
	# Position in top-right corner
	anchors_preset = PRESET_TOP_RIGHT
	position = Vector2(-280, 10)

func _setup_ui():
	# Background
	_background = ColorRect.new()
	_background.color = _bg_color
	_background.size = Vector2(270, show_breakdown ? 180 : 50)
	_background.position = Vector2.ZERO
	add_child(_background)
	
	# Main latency label
	_main_label = Label.new()
	_main_label.position = Vector2(10, 5)
	_main_label.size = Vector2(250, 35)
	_main_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var font_settings := LabelSettings.new()
	font_settings.font_size = 24
	font_settings.font_color = _color_good
	font_settings.outline_size = 2
	font_settings.outline_color = Color.BLACK
	_main_label.label_settings = font_settings
	add_child(_main_label)
	
	# Breakdown label
	if show_breakdown:
		_breakdown_label = Label.new()
		_breakdown_label.position = Vector2(10, 45)
		_breakdown_label.size = Vector2(250, 90)
		_breakdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_breakdown_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		var breakdown_settings := LabelSettings.new()
		breakdown_settings.font_size = 14
		breakdown_settings.font_color = Color.WHITE
		breakdown_settings.outline_size = 1
		breakdown_settings.outline_color = Color.BLACK
		_breakdown_label.label_settings = breakdown_settings
		add_child(_breakdown_label)
	
	_update_display()

func _find_provider():
	# Try to find MediaPipeProvider in the scene
	var root = get_tree().root
	_provider = _find_provider_recursive(root)
	
	if _provider:
		# Connect to latency signal
		if _provider.has_signal("_latency_updated"):
			_provider._latency_updated.connect(_on_latency_updated)
		print("LatencyDisplay: Connected to MediaPipeProvider")
	else:
		print("LatencyDisplay: MediaPipeProvider not found, will poll for metrics")

func _find_provider_recursive(node: Node) -> MediaPipeProvider:
	if node is MediaPipeProvider:
		return node
	
	for child in node.get_children():
		var result := _find_provider_recursive(child)
		if result:
			return result
	
	return null

func _on_latency_updated(metrics: Dictionary):
	_current_metrics = metrics

func _process(delta: float) -> void:
	_update_timer += delta * 1000.0
	
	if _update_timer >= update_interval_ms:
		_update_timer = 0.0
		
		# If not connected to signal, poll for metrics
		if not _provider and _current_metrics.is_empty():
			_find_provider()
		
		if _provider:
			_current_metrics = _provider.get_latency_metrics()
		
		_update_display()

func _update_display():
	if _current_metrics.is_empty():
		_main_label.text = "Latency: -- ms"
		if _breakdown_label:
			_breakdown_label.text = "Waiting for data..."
		return
	
	var total_latency: float = _current_metrics.get("total_latency_ms", 0.0)
	var network_latency: float = _current_metrics.get("network_latency_ms", 0.0)
	var scene_update_ms: float = _current_metrics.get("scene_update_ms", 0.0)
	var inference_ms: float = _current_metrics.get("inference_ms", 0.0)
	var capture_ms: float = _current_metrics.get("capture_ms", 0.0)
	var serialization_ms: float = _current_metrics.get("serialization_ms", 0.0)
	var processing_fps: float = _current_metrics.get("processing_fps", 60.0)
	var skip_frames: int = _current_metrics.get("skip_frames", 1)
	
	# Check if interpolation is active
	var interpolation_active := skip_frames > 1
	
	# Update main label with color coding
	_main_label.text = "Latency: %.1f ms" % total_latency
	
	if total_latency < warning_threshold_ms:
		_main_label.label_settings.font_color = _color_good
	elif total_latency < critical_threshold_ms:
		_main_label.label_settings.font_color = _color_warning
	else:
		_main_label.label_settings.font_color = _color_critical
	
	# Update breakdown
	if _breakdown_label:
		var breakdown_text := "Capture:     %.1f ms\n" % capture_ms
		breakdown_text += "Inference:   %.1f ms\n" % inference_ms
		breakdown_text += "Network:     %.1f ms\n" % network_latency
		breakdown_text += "Scene:       %.1f ms\n" % scene_update_ms
		
		if serialization_ms > 0:
			breakdown_text += "Serial:      %.1f ms\n" % serialization_ms
		
		# Add frame skipping info
		if _current_metrics.has("processing_fps"):
			breakdown_text += "Proc FPS:    %.1f\n" % processing_fps
		
		breakdown_text += "Skip:        %dx (1:%d)\n" % [skip_frames, skip_frames]
		breakdown_text += "Interp:      %s" % ("ON" if interpolation_active else "OFF")
		
		if _current_metrics.has("frame_count"):
			breakdown_text += "\nFrame:       %d" % _current_metrics["frame_count"]
		
		_breakdown_label.text = breakdown_text
	
	# Adjust background size based on content
	if _breakdown_label:
		var lines := _breakdown_label.text.count("\n") + 1
		_background.size = Vector2(270, 45 + lines * 16)

## Get current latency metrics
func get_metrics() -> Dictionary:
	return _current_metrics.duplicate()

## Get average latency from provider history
func get_average_metrics() -> Dictionary:
	if _provider:
		return _provider.get_average_latency()
	return {}
