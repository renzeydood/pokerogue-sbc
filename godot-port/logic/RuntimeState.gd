extends Reference
class_name RuntimeState

const PARTY_META_KEY := "runtime_party_v1"
const LEGACY_SELECTED_SPECIES_META_KEY := "selected_species_id"
const PartyModel = preload("res://data/PartyModel.gd")

static func get_party(tree):
	if tree == null:
		return null

	if tree.has_meta(PARTY_META_KEY):
		var stored_party = tree.get_meta(PARTY_META_KEY)
		if stored_party is PartyModel:
			return stored_party
		if typeof(stored_party) == TYPE_DICTIONARY:
			var restored_party = PartyModel.from_dict(stored_party)
			tree.set_meta(PARTY_META_KEY, restored_party)
			return restored_party

	var party = PartyModel.new()
	tree.set_meta(PARTY_META_KEY, party)
	return party

static func set_party(tree, party) -> void:
	if tree == null or party == null:
		return
	tree.set_meta(PARTY_META_KEY, party)

static func clear_party(tree) -> void:
	if tree == null:
		return
	if tree.has_meta(PARTY_META_KEY):
		tree.remove_meta(PARTY_META_KEY)

static func ensure_party_with_starter(tree, starter_species_id: String, level: int = 5):
	if tree == null:
		return null

	var normalized_species_id = starter_species_id.strip_edges().to_upper()
	if normalized_species_id.empty():
		return get_party(tree)

	var starter_party = PartyModel.new()
	starter_party.add_member({
		"species_id": normalized_species_id,
		"level": max(1, level),
		"current_hp": -1,
		"move_ids": [],
	})
	starter_party.set_active_slot(0)
	set_party(tree, starter_party)
	tree.set_meta(LEGACY_SELECTED_SPECIES_META_KEY, normalized_species_id)
	return starter_party
