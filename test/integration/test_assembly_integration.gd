extends GutTest

var main_scene

func before_each():
    main_scene = preload("res://scenes/main.tscn").instantiate()
    add_child(main_scene)
    # Wait for _ready
    await get_tree().process_frame

func after_each():
    main_scene.queue_free()

func test_main_scene_instantiates():
    assert_not_null(main_scene)

func test_input_manager_exists():
    var im = main_scene.get_node_or_null("InputManager")
    assert_not_null(im)
    assert_is(im, InputManager)

func test_input_manager_has_mediapipe_provider():
    var im = main_scene.get_node("InputManager")
    assert_true(im.has_provider("mediapipe"))

func test_set_strategy_changes_provider():
    var im = main_scene.get_node("InputManager")
    var success = im.set_strategy("mediapipe")
    assert_true(success)
    assert_not_null(im.get_provider())
    assert_eq(im.get_current_strategy(), "mediapipe")

func test_provider_is_mediapipe_type():
    var im = main_scene.get_node("InputManager")
    im.set_strategy("mediapipe")
    var provider = im.get_provider()
    assert_is(provider, MediaPipeProvider)
    assert_is(provider, AeroInputProvider)

func test_tracking_signals_exist():
    var im = main_scene.get_node("InputManager")
    
    var started = false
    var stopped = false
    
    im.tracking_started.connect(func(): started = true)
    im.tracking_stopped.connect(func(): stopped = true)
    
    # Just verify signals are connected
    assert_has_signal(im, "tracking_started")
    assert_has_signal(im, "tracking_stopped")
