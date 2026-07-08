extends Control

var entry_scene_path := "res://scenes/Battle.tscn"
var runtime_state_script = load("res://logic/RuntimeState.gd")
const PartyModel = preload("res://data/PartyModel.gd")

export(bool) var debug_seed_full_party_for_ui := false
export(int) var debug_seed_party_level := 5

var debug_seed_species_ids := [
	"BULBASAUR",
	"IVYSAUR",
	"VENUSAUR",
	"CHARMANDER",
	"CHARMELEON",
	"CHARIZARD",
]

func _ready():
	if runtime_state_script != null:
		if debug_seed_full_party_for_ui:
			_seed_debug_full_party(get_tree())
		else:
			runtime_state_script.ensure_party_with_starter(get_tree(), "BULBASAUR", debug_seed_party_level)
	var result = get_tree().change_scene(entry_scene_path)
	if result != OK:
		push_error("Failed to open entry scene: %s" % entry_scene_path)

func _seed_debug_full_party(tree) -> void:
	if tree == null:
		return

	var party = PartyModel.new()
	for species_id in debug_seed_species_ids:
		party.add_member({
			"species_id": String(species_id).strip_edges().to_upper(),
			"level": max(1, debug_seed_party_level),
			"current_hp": -1,
			"move_ids": [],
		})
	if not party.members.empty():
		party.set_active_slot(0)
	runtime_state_script.set_party(tree, party)
	tree.set_meta(runtime_state_script.LEGACY_SELECTED_SPECIES_META_KEY, "BULBASAUR")
