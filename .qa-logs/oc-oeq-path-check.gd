extends SceneTree

func _init() -> void:
	var wrapper_script: GDScript = load("res://src/mediapipe_test_autostart_manager.gd")
	var wrapper: Node = wrapper_script.new()
	print("MODEL_PATH=" + wrapper._get_model_asset_path())
	print("MODEL_EXISTS=" + str(FileAccess.file_exists(wrapper._get_model_asset_path())))
	var validation: Dictionary = wrapper._validate_sidecar_runtime()
	print("RUNTIME_VALID=" + str(validation.get("valid", false)))
	for error in validation.get("errors", PackedStringArray()):
		print("VALIDATION_ERROR=" + String(error))
	quit()
