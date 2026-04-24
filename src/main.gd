extends Node
## Main entry point for AeroBeat Assembly

const MEDIAPIPE_INPUT_PROVIDER := preload("res://addons/aerobeat-input-mediapipe/src/input_provider.gd")

@onready var input_manager: InputManager = $InputManager
@onready var ui: CanvasLayer = $UI
@onready var status_label: Label = $UI/TrackingStatus
@onready var debug_info: Label = $UI/DebugInfo

## When true, the app runs in simulation mode without requiring a camera
@export var is_simulation_mode: bool = false

## Show latency display when using MediaPipe
@export var show_latency_display: bool = true

var _latency_display: LatencyDisplay = null
var _mediapipe_provider: AeroInputProvider = null

func _ready() -> void:
    print("AeroBeat Assembly started")
    print("Godot version: ", Engine.get_version_info())
    
    # Connect signals
    input_manager.started.connect(_on_tracking_started)
    input_manager.stopped.connect(_on_tracking_stopped)
    input_manager.failed.connect(_on_tracking_failed)
    
    # Register input providers
    _register_input_providers()
    
    if _mediapipe_provider == null:
        _enable_simulation_mode("MediaPipe provider not available")
        return
    
    print("Initializing MediaPipe addon adapter...")
    var provider: AeroInputProvider = input_manager.get_active_provider()
    if provider == null:
        var provider_started: bool = input_manager.set_active_provider(_mediapipe_provider)
        if not provider_started:
            _enable_simulation_mode("Failed to initialize MediaPipe adapter/runtime")
            return
        provider = input_manager.get_active_provider()
    elif provider != _mediapipe_provider:
        var switched_provider: bool = input_manager.set_active_provider(_mediapipe_provider)
        if not switched_provider:
            _enable_simulation_mode("Failed to switch to MediaPipe adapter/runtime")
            return
        provider = input_manager.get_active_provider()
    
    if provider == null:
        _enable_simulation_mode("MediaPipe provider was not activated")
        return
    
    # The current public adapter may expose dependency checks, but does not guarantee it.
    if provider.has_method("check_dependencies"):
        var deps: Dictionary = provider.check_dependencies()
        if not deps.python_found:
            _enable_simulation_mode("Python not found. Install Python 3.8+")
            return
        if not deps.mediapipe_installed:
            _enable_simulation_mode("MediaPipe not installed. Run: pip install -r requirements.txt")
            return
    
    # Add latency display if enabled. The current public adapter does not guarantee
    # the internal latency metrics surface, so the UI degrades honestly if unavailable.
    if show_latency_display:
        _add_latency_display(provider)

func _register_input_providers() -> void:
    var mediapipe: AeroInputProvider = MEDIAPIPE_INPUT_PROVIDER.new()
    mediapipe.name = "MediaPipeInputProvider"
    add_child(mediapipe)
    
    if input_manager.register_provider(mediapipe, {}):
        _mediapipe_provider = mediapipe
        print("Registered MediaPipe addon adapter")
    else:
        push_warning("Failed to register MediaPipe addon adapter")

func _add_latency_display(provider: AeroInputProvider) -> void:
    """Add the latency display UI"""
    var latency_script := load("res://src/latency_display.gd")
    if latency_script:
        _latency_display = latency_script.new()
        _latency_display.name = "LatencyDisplay"
        ui.add_child(_latency_display)
        _latency_display.set_provider(provider)
        print("Latency display added")
    else:
        push_warning("Could not load latency_display.gd")

func _on_tracking_started() -> void:
    print("Tracking started")
    status_label.text = "Tracking: Active"

func _on_tracking_stopped() -> void:
    print("Tracking stopped")
    status_label.text = "Tracking: Off"

func _on_tracking_failed(error: String) -> void:
    push_warning("Tracking failed: " + error)
    _enable_simulation_mode(error)

func _show_error(message: String) -> void:
    push_warning(message)
    status_label.text = "Error: " + message

## Enables simulation mode when camera/input is unavailable
## Allows the app to run for testing/demo purposes without camera
func _enable_simulation_mode(reason: String) -> void:
    is_simulation_mode = true
    push_warning("Entering simulation mode: " + reason)
    status_label.text = "Tracking: Simulation Mode"
    debug_info.text = "Camera unavailable: " + reason + "\nRunning in simulation mode."
    print("Simulation mode enabled: " + reason)

## Toggle simulation mode on/off at runtime
func toggle_simulation_mode() -> void:
    is_simulation_mode = !is_simulation_mode
    if is_simulation_mode:
        input_manager.stop_active_provider()
        status_label.text = "Tracking: Simulation Mode"
        debug_info.text = "Simulation mode manually enabled."
        push_warning("Simulation mode manually enabled")
    elif _mediapipe_provider != null:
        debug_info.text = "Attempting to restart MediaPipe adapter..."
        var success: bool = input_manager.set_active_provider(_mediapipe_provider)
        if not success:
            _enable_simulation_mode("Failed to restart MediaPipe adapter")
    else:
        _enable_simulation_mode("MediaPipe adapter is not registered")

## Get current latency metrics (if available)
func get_latency_metrics() -> Dictionary:
    if _latency_display:
        return _latency_display.get_metrics()
    return {}

## Get average latency over history (if available)
func get_average_latency() -> Dictionary:
    if _latency_display:
        return _latency_display.get_average_metrics()
    return {}

func _exit_tree() -> void:
    input_manager.stop_active_provider()
