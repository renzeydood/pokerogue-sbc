tool
extends Control

const EditorPreviewSync = preload("res://logic/EditorPreviewSync.gd")

export(float) var ui_scale := 2.0 setget set_ui_scale
export(bool) var editor_preview_enabled := true

onready var ui_scale_root = $Backdrop/Panel/UiScaleRoot

var editor_preview_seeded := false

func _ready() -> void:
	set_process(true)
	_apply_ui_scale()

func set_ui_scale(value: float) -> void:
	ui_scale = value
	_apply_ui_scale()

func _apply_editor_preview_state() -> void:
	_apply_ui_scale()
	editor_preview_seeded = true

func _refresh_editor_preview_state() -> void:
	_apply_ui_scale()

func _process(_delta: float) -> void:
	if not Engine.editor_hint:
		return

	EditorPreviewSync.sync_scene(
		self,
		editor_preview_enabled,
		editor_preview_seeded,
		"_apply_editor_preview_state",
		"_refresh_editor_preview_state"
	)

func _apply_ui_scale() -> void:
	if ui_scale_root != null:
		ui_scale_root.rect_scale = Vector2(ui_scale, ui_scale)
