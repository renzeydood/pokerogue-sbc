extends Control

var entry_scene_path := "res://scenes/BattleScreen.tscn"
var runtime_state_script = load("res://logic/RuntimeState.gd")

export(bool) var debug_seed_full_party_for_ui := false
export(int) var debug_seed_party_level := 5
export(bool) var use_debug_seed_profile := false
export(String) var debug_seed_profile_id := "ui_party_showcase"

func _ready():
	if runtime_state_script != null:
		if use_debug_seed_profile:
			var seed_result = runtime_state_script.apply_debug_seed_profile(get_tree(), debug_seed_profile_id, true, true)
			if not bool(seed_result.get("ok", false)):
				push_warning("Debug seed profile failed (%s). Falling back to starter seed." % String(seed_result.get("reason", "unknown")))
				runtime_state_script.ensure_party_with_starter(get_tree(), "BULBASAUR", debug_seed_party_level)
		elif debug_seed_full_party_for_ui:
			_seed_debug_full_party(get_tree())
		else:
			runtime_state_script.ensure_party_with_starter(get_tree(), "BULBASAUR", debug_seed_party_level)
	var result = get_tree().change_scene(entry_scene_path)
	if result != OK:
		push_error("Failed to open entry scene: %s" % entry_scene_path)

func _seed_debug_full_party(tree) -> void:
	if tree == null:
		return
	var seed_result = runtime_state_script.apply_debug_seed_profile(tree, "ui_party_showcase", true, true)
	if not bool(seed_result.get("ok", false)):
		# Legacy fallback path for sessions where profile data is unavailable.
		runtime_state_script.ensure_party_with_starter(tree, "BULBASAUR", debug_seed_party_level)
