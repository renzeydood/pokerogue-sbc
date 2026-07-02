extends Control

var selection_scene_path := "res://scenes/PokemonSelect.tscn"

func _ready():
	var result = get_tree().change_scene(selection_scene_path)
	if result != OK:
		push_error("Failed to open selection scene: %s" % selection_scene_path)
