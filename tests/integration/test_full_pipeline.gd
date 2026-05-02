extends GutTest
## End-to-end-ish integration test anchored to the current truthful contract.

const MEDIAPIPE_INPUT_PROVIDER_PATH := "res://addons/aerobeat-input-mediapipe/src/input_provider.gd"

var main
var im: InputManager
var provider: AeroInputProvider

func before_each() -> void:
    # This test requires the full setup:
    # 1. addons.jsonc restored into addons/ via ./scripts/restore-addons.sh
    # 2. aerobeat-input-mediapipe currently arrives through addons/aerobeat-input-mediapipe
    # 3. Python-side runtime success remains environment-dependent
    main = preload("res://scenes/main.tscn").instantiate()
    add_child(main)
    im = main.get_node("InputManager")
    await get_tree().process_frame
    provider = im.get_active_provider()

func after_each() -> void:
    main.queue_free()

func test_main_scene_exposes_active_provider() -> void:
    assert_not_null(provider)
    assert_is(provider, AeroInputProvider)

func test_active_provider_is_public_addon_adapter() -> void:
    assert_not_null(provider)
    assert_eq(provider.get_script().resource_path, MEDIAPIPE_INPUT_PROVIDER_PATH)

func test_public_adapter_exposes_polling_surface() -> void:
    assert_not_null(provider)
    assert_not_null(provider.get_left_hand_position())
    assert_not_null(provider.get_right_hand_position())
    assert_not_null(provider.get_head_position())

func test_cleanup_on_exit() -> void:
    main.queue_free()
    pass
