extends Control

var battle_scene_path := "res://scenes/Battle.tscn"

func _ready():
	var result = get_tree().change_scene(battle_scene_path)
	if result != OK:
		push_error("Failed to open battle scene: %s" % battle_scene_path)
