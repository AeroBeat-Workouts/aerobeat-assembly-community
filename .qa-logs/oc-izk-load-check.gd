extends SceneTree

func _init() -> void:
	var targets := [
		"res://src/mediapipe_test_scene.gd",
		"res://src/mediapipe_landmark_drawer.gd",
		"res://src/mediapipe_provider_test.gd",
		"res://src/mediapipe_test_autostart_manager.gd",
		"res://scenes/mediapipe_test_scene.tscn",
	]
	var failures := []
	for path in targets:
		var res := load(path)
		if res == null:
			failures.append(path)
			push_error("FAILED_LOAD %s" % path)
		else:
			print("LOADED %s :: %s" % [path, res.get_class()])
	var scene := load("res://scenes/mediapipe_test_scene.tscn") as PackedScene
	if scene == null:
		failures.append("res://scenes/mediapipe_test_scene.tscn (packed)")
		push_error("FAILED_PACKED_SCENE")
	else:
		var instance := scene.instantiate()
		if instance == null:
			failures.append("res://scenes/mediapipe_test_scene.tscn (instantiate)")
			push_error("FAILED_INSTANTIATE")
		else:
			print("INSTANTIATED %s" % instance.name)
			instance.free()
	if failures.is_empty():
		print("LOAD_CHECK_OK")
		quit(0)
	else:
		print("LOAD_CHECK_FAIL %s" % ", ".join(failures))
		quit(1)
