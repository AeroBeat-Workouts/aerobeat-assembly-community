extends Node

const SAMPLE_IMAGE_PATH := "res://fixtures/environment_contract/assets/images/perfect-hue-may-14-2026.png"
const SAMPLE_VIDEO_PATH := "res://fixtures/environment_contract/assets/videos/calm_blue_sea_1.ogv"
const SAMPLE_GLB_PATH := "res://fixtures/environment_contract/assets/models/alien-planet.glb"
const SAMPLE_GLB_CONFIG_PATH := "res://fixtures/environment_contract/assets/models/alien-planet.json"
const SAMPLE_WORKOUT_YAML_PATH := "res://fixtures/environment_contract/workout_yaml_valid_image/workout.yaml"
const SAMPLE_SPLAT_PATH := "res://fixtures/environment_contract/assets/splats/CountrySide farm.compressed.ply"
const SAMPLE_SPLAT_CONFIG_PATH := "res://fixtures/environment_contract/assets/splats/CountrySide farm.json"

@onready var loader_tool_manager: Node = $LoaderToolManager
@onready var splat_tool_manager: Node = $SplatToolManager
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var loader_summary_label: Label = $CanvasLayer/Ui/Panel/Margin/VBox/LoaderSummaryLabel
@onready var splat_summary_label: Label = $CanvasLayer/Ui/Panel/Margin/VBox/SplatSummaryLabel
@onready var renderer_support_label: Label = $CanvasLayer/Ui/Panel/Margin/VBox/RendererSupportLabel
@onready var sample_paths_label: Label = $CanvasLayer/Ui/Panel/Margin/VBox/SamplePathsLabel
@onready var current_loader_asset_label: Label = $CanvasLayer/Ui/Panel/Margin/VBox/CurrentLoaderAssetLabel
@onready var current_splat_asset_label: Label = $CanvasLayer/Ui/Panel/Margin/VBox/CurrentSplatAssetLabel
@onready var status_log: RichTextLabel = $CanvasLayer/Ui/Panel/Margin/VBox/StatusLog
@onready var splat_world_root: Node3D = $WorldRoot/SplatWorldRoot

var _current_splat_node: Node = null
var _active_splat_operation: Variant = null
var _splat_load_in_flight: bool = false

func _ready() -> void:
	loader_tool_manager.environment_load_started.connect(_on_loader_load_started)
	loader_tool_manager.environment_load_progress.connect(_on_loader_load_progress)
	loader_tool_manager.environment_load_succeeded.connect(_on_loader_load_succeeded)
	loader_tool_manager.environment_load_failed.connect(_on_loader_load_failed)
	loader_tool_manager.environment_cleared.connect(_on_loader_cleared)
	loader_summary_label.text = "Loader lane idle. Use this lane for PNG / OGV / GLB / workout.yaml proof."
	splat_summary_label.text = "Direct splat lane idle. This lane proves async contract progress, not stable visible rendering."
	current_loader_asset_label.text = "Loader lane asset: (none)"
	current_splat_asset_label.text = "Direct splat asset: (none)"
	sample_paths_label.text = "PNG: %s\nOGV: %s\nGLB: %s\nworkout.yaml: %s\nDirect splat: %s" % [
		SAMPLE_IMAGE_PATH,
		SAMPLE_VIDEO_PATH,
		SAMPLE_GLB_PATH,
		SAMPLE_WORKOUT_YAML_PATH,
		SAMPLE_SPLAT_PATH,
	]
	_refresh_renderer_support_label()
	_append_status("Assembly environment contract test scene ready.")
	_append_status("Loader lane intentionally excludes splat proof; direct splat lane uses begin_fulfill(...) instead.")

func _on_load_png_pressed() -> void:
	_load_loader_request("image", SAMPLE_IMAGE_PATH, "", "loader-image-demo")

func _on_load_ogv_pressed() -> void:
	_load_loader_request("video", SAMPLE_VIDEO_PATH, "", "loader-video-demo")

func _on_load_glb_pressed() -> void:
	_load_loader_request("glb", SAMPLE_GLB_PATH, SAMPLE_GLB_CONFIG_PATH, "loader-glb-demo")

func _on_load_workout_yaml_pressed() -> void:
	current_loader_asset_label.text = "Loader lane asset: %s" % SAMPLE_WORKOUT_YAML_PATH
	loader_summary_label.text = "Loader lane running workout.yaml translation through the environment loader bridge."
	_append_status("LOADER BEGIN workout_yaml asset=%s" % SAMPLE_WORKOUT_YAML_PATH)
	loader_tool_manager.load_environment_from_workout_yaml(SAMPLE_WORKOUT_YAML_PATH, {
		"request_id": "loader-workout-yaml-demo",
		"display_mode": "cover",
		"context": {
			"source": "assembly_environment_contract_test_scene",
			"lane": "loader",
			"mode": "workout_yaml",
		},
		"metadata": {
			"sample": true,
			"contract_surface": "assembly_environment_contract_test_scene",
		},
	})

func _on_clear_loader_pressed() -> void:
	loader_tool_manager.clear_environment()

func _on_start_direct_splat_pressed() -> void:
	if _splat_load_in_flight:
		_append_status("SPLAT IGNORE another direct async splat operation is still running.")
		return
	_refresh_renderer_support_label()
	_clear_direct_splat_node(false)
	current_splat_asset_label.text = "Direct splat asset: %s" % SAMPLE_SPLAT_PATH
	splat_summary_label.text = "Direct splat lane queued. Watching AeroEnvironmentOperation state / status / phase updates..."
	var operation: Variant = splat_tool_manager.begin_fulfill({
		"request_id": "direct-splat-demo",
		"kind": "splat",
		"asset_path": SAMPLE_SPLAT_PATH,
		"config_path": SAMPLE_SPLAT_CONFIG_PATH,
		"display_mode": "cover",
		"context": {
			"source": "assembly_environment_contract_test_scene",
			"lane": "direct_splat_async",
			"world_environment": world_environment,
		},
		"metadata": {
			"sample": true,
			"contract_surface": "assembly_environment_contract_test_scene",
		},
	})
	_active_splat_operation = operation
	_splat_load_in_flight = operation != null and not _operation_is_terminal(operation)
	if operation == null:
		splat_summary_label.text = "Direct splat lane failed to return an AeroEnvironmentOperation."
		_append_status("SPLAT ERROR begin_fulfill returned null.")
		return
	if operation.has_signal("started"):
		operation.started.connect(_on_splat_operation_started)
	if operation.has_signal("progressed"):
		operation.progressed.connect(_on_splat_operation_progressed)
	if operation.has_signal("succeeded"):
		operation.succeeded.connect(_on_splat_operation_succeeded)
	if operation.has_signal("failed"):
		operation.failed.connect(_on_splat_operation_failed)
	if operation.has_signal("finished"):
		operation.finished.connect(_on_splat_operation_finished)
	_append_status("SPLAT BEGIN request_id=direct-splat-demo asset=%s" % SAMPLE_SPLAT_PATH)
	_log_operation_snapshot("SPLAT SNAPSHOT", operation)

func _on_clear_direct_splat_pressed() -> void:
	_clear_direct_splat_node(true)

func _on_refresh_renderer_note_pressed() -> void:
	_refresh_renderer_support_label()
	_append_status("SPLAT RENDERER %s" % renderer_support_label.text.replace("\n", " | "))

func _load_loader_request(kind: String, asset_path: String, config_path: String, request_id: String) -> void:
	current_loader_asset_label.text = "Loader lane asset: %s" % asset_path
	loader_summary_label.text = "Loader lane resolving %s through AeroToolManager." % kind
	_append_status("LOADER BEGIN kind=%s asset=%s config=%s" % [kind, asset_path, config_path])
	loader_tool_manager.load_environment({
		"request_id": request_id,
		"kind": kind,
		"asset_path": asset_path,
		"config_path": config_path,
		"display_mode": "cover",
		"context": {
			"source": "assembly_environment_contract_test_scene",
			"lane": "loader",
		},
		"metadata": {
			"sample": true,
			"contract_surface": "assembly_environment_contract_test_scene",
		},
	})

func _on_loader_load_started(request: Dictionary) -> void:
	loader_summary_label.text = "Loader lane started %s request." % String(request.get("kind", "environment"))
	_append_status("LOADER START kind=%s asset=%s" % [request.get("kind", ""), request.get("asset_path", "")])

func _on_loader_load_progress(progress: Dictionary) -> void:
	loader_summary_label.text = "Loader lane progress: %s (%.2f)" % [progress.get("status", "loading"), float(progress.get("progress", 0.0))]
	_append_status("LOADER PROGRESS status=%s progress=%.3f message=%s" % [progress.get("status", ""), float(progress.get("progress", 0.0)), progress.get("message", "")])

func _on_loader_load_succeeded(result: Dictionary) -> void:
	current_loader_asset_label.text = "Loader lane asset: %s" % String(result.get("asset_path", ""))
	loader_summary_label.text = "Loader lane success: %s via loader contract." % String(result.get("kind", "environment"))
	_append_status("LOADER SUCCESS kind=%s format=%s config_applied=%s asset=%s" % [
		result.get("kind", ""),
		result.get("format", ""),
		result.get("config_applied", false),
		result.get("asset_path", ""),
	])

func _on_loader_load_failed(error: Dictionary) -> void:
	loader_summary_label.text = "Loader lane failed: %s" % String(error.get("message", "Unknown loader failure."))
	_append_status("LOADER ERROR code=%s message=%s" % [error.get("error_code", "loader_failed"), error.get("message", "")])

func _on_loader_cleared() -> void:
	current_loader_asset_label.text = "Loader lane asset: (none)"
	loader_summary_label.text = "Loader lane cleared."
	_append_status("LOADER CLEARED")

func _on_splat_operation_started(progress: Variant) -> void:
	_splat_load_in_flight = true
	var payload: Dictionary = _dict_from_variant(progress)
	splat_summary_label.text = "Direct splat running: %s / %s" % [payload.get("state", "running"), payload.get("phase", "reading")]
	_append_status(_format_splat_progress_line("SPLAT START", payload))

func _on_splat_operation_progressed(progress: Variant) -> void:
	var payload: Dictionary = _dict_from_variant(progress)
	splat_summary_label.text = "Direct splat progress: %s / %s / %.2f" % [payload.get("state", "running"), payload.get("phase", "reading"), float(payload.get("progress", 0.0))]
	_append_status(_format_splat_progress_line("SPLAT PROGRESS", payload))

func _on_splat_operation_succeeded(result: Variant) -> void:
	_splat_load_in_flight = false
	var payload: Dictionary = _dict_from_variant(result)
	var details: Dictionary = payload.get("details", {}) if payload.get("details", {}) is Dictionary else {}
	var node: Variant = details.get("node", null)
	if node is Node:
		_clear_direct_splat_node(false)
		splat_world_root.add_child(node)
		_current_splat_node = node
	splat_summary_label.text = "Direct splat success: async contract completed. Visible render remains experimental / bug-boundary honest."
	_append_status("SPLAT SUCCESS state=succeeded phase=ready point_count=%s config_applied=%s world_environment_configured=%s node_attached=%s" % [
		details.get("point_count", 0),
		payload.get("config_applied", false),
		details.get("world_environment_configured", false),
		node is Node,
	])

func _on_splat_operation_failed(error: Variant) -> void:
	_splat_load_in_flight = false
	var payload: Dictionary = _dict_from_variant(error)
	splat_summary_label.text = "Direct splat failed: %s" % String(payload.get("message", "Unknown splat failure."))
	_append_status("SPLAT ERROR state=failed code=%s message=%s" % [payload.get("error_code", "loader_failed"), payload.get("message", "")])

func _on_splat_operation_finished(operation: Variant) -> void:
	_splat_load_in_flight = false
	_log_operation_snapshot("SPLAT FINISHED", operation)

func _refresh_renderer_support_label() -> void:
	var support: Dictionary = splat_tool_manager.get_renderer_support_status()
	renderer_support_label.text = "Renderer support: %s | renderer=%s\n%s" % [
		String(support.get("support_level", "unknown")),
		String(support.get("renderer_name", "unknown")),
		String(support.get("message", "No renderer support details available.")),
	]

func _clear_direct_splat_node(emit_log: bool) -> void:
	if _current_splat_node != null and is_instance_valid(_current_splat_node):
		_current_splat_node.queue_free()
	_current_splat_node = null
	current_splat_asset_label.text = "Direct splat asset: (none)"
	splat_summary_label.text = "Direct splat lane cleared."
	if emit_log:
		_append_status("SPLAT CLEARED mounted node removed; this does not cancel an in-flight background decode.")

func _log_operation_snapshot(prefix: String, operation: Variant) -> void:
	var payload: Dictionary = _dict_from_variant(operation)
	var latest_progress: Dictionary = payload.get("latest_progress", {}) if payload.get("latest_progress", {}) is Dictionary else {}
	_append_status("%s state=%s terminal=%s latest_status=%s latest_phase=%s latest_sequence=%s" % [
		prefix,
		payload.get("state", "unknown"),
		payload.get("terminal", false),
		latest_progress.get("status", ""),
		latest_progress.get("phase", ""),
		latest_progress.get("sequence", ""),
	])

func _operation_is_terminal(operation: Variant) -> bool:
	return operation != null and operation.has_method("is_terminal") and bool(operation.is_terminal())

func _dict_from_variant(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value).duplicate(true)
	if value != null and value.has_method("to_dict"):
		var payload: Variant = value.to_dict()
		if payload is Dictionary:
			return Dictionary(payload).duplicate(true)
	return {}

func _format_splat_progress_line(prefix: String, payload: Dictionary) -> String:
	return "%s state=%s status=%s phase=%s sequence=%s progress=%.3f message=%s" % [
		prefix,
		payload.get("state", ""),
		payload.get("status", ""),
		payload.get("phase", ""),
		payload.get("sequence", ""),
		float(payload.get("progress", 0.0)),
		payload.get("message", ""),
	]

func _append_status(line: String) -> void:
	status_log.append_text("%s\n" % line)
