tool
extends Control
class_name UiScaledModalTemplate

export(float) var ui_scale := 2.0 setget set_ui_scale

onready var ui_scale_root = $Backdrop/Panel/UiScaleRoot

func _ready() -> void:
	_apply_ui_scale()

func set_ui_scale(value: float) -> void:
	ui_scale = value
	_apply_ui_scale()

func _apply_ui_scale() -> void:
	if ui_scale_root != null:
		ui_scale_root.rect_scale = Vector2(ui_scale, ui_scale)
