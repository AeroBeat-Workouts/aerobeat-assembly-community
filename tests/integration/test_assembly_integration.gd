extends GutTest

const MEDIAPIPE_INPUT_PROVIDER_PATH := "res://addons/aerobeat-input-mediapipe/src/input_provider.gd"

var main_scene

func before_each():
    main_scene = preload("res://scenes/main.tscn").instantiate()
    add_child(main_scene)
    # Wait for _ready
    await get_tree().process_frame

func after_each():
    main_scene.queue_free()

func test_main_scene_instantiates() -> void:
    assert_not_null(main_scene)

func test_input_manager_exists() -> void:
    var im = main_scene.get_node_or_null("InputManager")
    assert_not_null(im)
    assert_is(im, InputManager)

func test_main_scene_registers_an_active_provider() -> void:
    var im: InputManager = main_scene.get_node("InputManager")
    var provider := im.get_active_provider()
    assert_not_null(provider)
    assert_is(provider, AeroInputProvider)

func test_active_provider_uses_public_mediapipe_adapter_entrypoint() -> void:
    var im: InputManager = main_scene.get_node("InputManager")
    var provider: AeroInputProvider = im.get_active_provider()
    assert_not_null(provider)
    assert_eq(provider.get_script().resource_path, MEDIAPIPE_INPUT_PROVIDER_PATH)

func test_core_input_manager_signals_exist() -> void:
    var im: InputManager = main_scene.get_node("InputManager")
    assert_has_signal(im, "started")
    assert_has_signal(im, "stopped")
    assert_has_signal(im, "failed")
