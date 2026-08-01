tool
extends Control

const EditorPreviewSync = preload("res://logic/EditorPreviewSync.gd")

signal close_requested
signal modal_opened(context)
signal overlay_closed

export(float) var ui_scale := 2.0 setget set_ui_scale
export(bool) var editor_preview_enabled := true
export(bool) var use_runtime_layout_overrides := false
export(bool) var close_on_back := true
export(String) var default_title := "Modal Template"

export(NodePath) var ui_scale_root_path = NodePath("Backdrop/Panel/UiScaleRoot")
export(NodePath) var title_label_path = NodePath("Backdrop/Panel/UiScaleRoot/ModalRoot/TitleLabel")
export(NodePath) var content_root_path = NodePath("Backdrop/Panel/UiScaleRoot/ModalRoot/ContentRoot")
export(NodePath) var footer_root_path = NodePath("Backdrop/Panel/UiScaleRoot/ModalRoot/FooterRoot")
export(NodePath) var back_button_path = NodePath("Backdrop/Panel/UiScaleRoot/ModalRoot/FooterRoot/BackButton")

onready var ui_scale_root = get_node_or_null(ui_scale_root_path)
onready var title_label = get_node_or_null(title_label_path)
onready var content_root = get_node_or_null(content_root_path)
onready var footer_root = get_node_or_null(footer_root_path)
onready var back_button = get_node_or_null(back_button_path)

var editor_preview_seeded := false
var modal_context = null
var is_modal_open := false

func _ready() -> void:
	set_process(true)
	set_process_input(true)
	_apply_ui_scale()
	if not Engine.editor_hint:
		hide()
	if title_label != null:
		title_label.text = default_title
	if back_button != null and not back_button.is_connected("pressed", self, "_on_BackButton_pressed"):
		back_button.connect("pressed", self, "_on_BackButton_pressed")

func set_ui_scale(value: float) -> void:
	ui_scale = value
	_apply_ui_scale()

func open_menu(context = null) -> void:
	modal_context = context
	is_modal_open = true
	show()
	if use_runtime_layout_overrides and not Engine.editor_hint:
		_apply_runtime_layout_overrides(context)
	emit_signal("modal_opened", context)

func close_menu(emit_close: bool = true) -> void:
	is_modal_open = false
	hide()
	if emit_close:
		emit_signal("close_requested")
	emit_signal("overlay_closed")

func handle_back_action() -> bool:
	if not close_on_back:
		return false
	if not visible and not is_modal_open:
		return false
	close_menu(true)
	return true

func set_modal_title(value: String) -> void:
	default_title = value
	if title_label != null:
		title_label.text = value

func get_modal_context():
	return modal_context

func get_content_root() -> Node:
	return content_root

func get_footer_root() -> Node:
	return footer_root

func _apply_editor_preview_state() -> void:
	_apply_ui_scale()
	_apply_preview_content()
	editor_preview_seeded = true

func _refresh_editor_preview_state() -> void:
	_apply_ui_scale()
	_apply_preview_content()

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

func _input(event: InputEvent) -> void:
	if Engine.editor_hint:
		return
	if _is_back_input(event) and handle_back_action():
		get_tree().set_input_as_handled()

func _apply_ui_scale() -> void:
	if ui_scale_root != null:
		ui_scale_root.rect_scale = Vector2(ui_scale, ui_scale)

func _apply_preview_content() -> void:
	if title_label != null:
		title_label.text = default_title

func _apply_runtime_layout_overrides(_context = null) -> void:
	# Intentionally empty in template. Extend in concrete modal scenes.
	pass

func _is_back_input(event: InputEvent) -> bool:
	if event is InputEventAction:
		var action_event := event as InputEventAction
		if action_event.pressed and (action_event.action == "ui_cancel" or action_event.action == "ui_back"):
			return true
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and (key_event.scancode == KEY_ESCAPE or key_event.scancode == KEY_BACKSPACE):
			return true
	return false

func _on_BackButton_pressed() -> void:
	var _handled = handle_back_action()
