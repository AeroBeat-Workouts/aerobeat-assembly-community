class_name InputManager
extends Node
## Manages input providers and strategy switching

signal provider_changed(provider_name: String)
signal provider_registered(name: String, provider: AeroInputProvider)
signal tracking_started()
signal tracking_stopped()
signal tracking_failed(error: String)

var _providers: Dictionary = {}  # name -> provider instance
var _current_provider: AeroInputProvider = null
var _current_name: String = ""
var _is_initializing := false

func register_provider(provider_name: String, provider: AeroInputProvider) -> void:
    if _providers.has(provider_name):
        push_warning("Overwriting existing provider: " + provider_name)
    
    _providers[provider_name] = provider
    provider_registered.emit(provider_name, provider)

func unregister_provider(provider_name: String) -> void:
    if _providers.has(provider_name):
        if _current_provider == _providers[provider_name]:
            stop_camera()
            _current_provider = null
            _current_name = ""
        _providers.erase(provider_name)

func has_provider(provider_name: String) -> bool:
    return _providers.has(provider_name)

func get_provider_names() -> Array:
    return _providers.keys()

func set_strategy(provider_name: String) -> bool:
    if not _providers.has(provider_name):
        push_warning("Unknown input provider: " + provider_name)
        return false
    
    # Stop current if switching
    if _current_provider != null and _current_provider != _providers[provider_name]:
        stop_camera()
    
    _current_provider = _providers[provider_name]
    _current_name = provider_name
    provider_changed.emit(provider_name)
    return true

func get_current_strategy() -> String:
    return _current_name

func initialize_camera() -> bool:
    if _current_provider == null:
        push_warning("Cannot initialize camera: No input provider selected")
        tracking_failed.emit("No input provider selected")
        return false
    
    if _is_initializing:
        push_warning("Camera initialization already in progress")
        tracking_failed.emit("Already initializing")
        return false
    
    _is_initializing = true
    
    # Check if provider has start method (it should)
    if not _current_provider.has_method("start"):
        _is_initializing = false
        push_warning("Provider does not support starting")
        tracking_failed.emit("Provider does not support starting")
        return false
    
    # Start the provider (this starts UDP server + Python sidecar)
    var success: bool = _current_provider.start()
    _is_initializing = false
    
    if success:
        tracking_started.emit()
    else:
        push_warning("Failed to start camera provider - camera may not be connected")
        tracking_failed.emit("Failed to start provider")
    
    return success

func stop_camera() -> void:
    if _current_provider and _current_provider.has_method("stop"):
        _current_provider.stop()
    tracking_stopped.emit()

func is_tracking() -> bool:
    if _current_provider and _current_provider.has_method("is_tracking"):
        return _current_provider.is_tracking()
    return false

func get_provider() -> AeroInputProvider:
    return _current_provider

func _notification(what: int) -> void:
    if what == NOTIFICATION_EXIT_TREE:
        stop_camera()
