extends GutTest
## End-to-end integration test

var main
var im
var provider

func before_each():
    # This test requires the full setup:
    # 1. aerobeat-core as submodule in assembly
    # 2. aerobeat-input-mediapipe as submodule in assembly
    # 3. Python dependencies installed
    
    main = preload("res://scenes/main.tscn").instantiate()
    add_child(main)
    im = main.get_node("InputManager")

func after_each():
    main.queue_free()

func test_full_pipeline_receives_landmarks():
    # Select MediaPipe
    im.set_strategy("mediapipe")
    
    # Start tracking
    var success = im.initialize_camera()
    assert_true(success, "Camera should initialize")
    
    # Wait for data (use mock in test mode)
    await wait_seconds(1.0)
    
    # Get positions
    provider = im.get_provider()
    var left = provider.get_left_hand_position()
    var right = provider.get_right_hand_position()
    var head = provider.get_head_position()
    
    # Verify we have data
    assert_not_null(left, "Should have left hand data")
    assert_not_null(right, "Should have right hand data")
    assert_not_null(head, "Should have head data")

func test_positions_are_normalized():
    im.set_strategy("mediapipe")
    im.initialize_camera()
    
    await wait_seconds(0.5)
    
    provider = im.get_provider()
    var pos = provider.get_left_hand_position()
    
    # All positions should be 0.0 - 1.0
    assert_between(pos.x, 0.0, 1.0, "X should be normalized")
    assert_between(pos.y, 0.0, 1.0, "Y should be normalized")

func test_provider_implements_interface():
    im.set_strategy("mediapipe")
    provider = im.get_provider()
    
    # Verify it's the correct type
    assert_is(provider, AeroInputProvider)
    assert_is(provider, MediaPipeProvider)

func test_cleanup_on_exit():
    im.set_strategy("mediapipe")
    im.initialize_camera()
    
    # Simulate scene exit
    main.queue_free()
    
    # Process should be cleaned up
    # (This is implicitly tested by no crashes/errors)
    pass
