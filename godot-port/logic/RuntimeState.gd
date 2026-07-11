extends Reference
class_name RuntimeState

const PARTY_META_KEY := "runtime_party_v1"
const ROSTER_META_KEY := "runtime_roster_v1"
const BIOME_META_KEY := "runtime_biome_v1"
const LEGACY_SELECTED_SPECIES_META_KEY := "selected_species_id"
const PartyModel = preload("res://data/PartyModel.gd")
const DEFAULT_BIOME_ID := "grass"
const DEFAULT_BIOME_SOURCE := "baseline_rotation"
const BIOME_ROTATION := [
	"grass",
	"forest",
	"cave",
	"lake",
	"mountain",
	"beach",
]

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

static func get_roster(tree) -> Dictionary:
	if tree == null:
		return _normalize_roster({})

	if tree.has_meta(ROSTER_META_KEY):
		var stored_roster = tree.get_meta(ROSTER_META_KEY)
		if typeof(stored_roster) == TYPE_DICTIONARY:
			var normalized_roster = _normalize_roster(stored_roster)
			tree.set_meta(ROSTER_META_KEY, normalized_roster)
			return normalized_roster.duplicate(true)
		if typeof(stored_roster) == TYPE_ARRAY:
			var legacy_roster = _normalize_roster({"caught_species_ids": stored_roster})
			tree.set_meta(ROSTER_META_KEY, legacy_roster)
			return legacy_roster.duplicate(true)

	var roster = _normalize_roster({})
	tree.set_meta(ROSTER_META_KEY, roster)
	return roster.duplicate(true)

static func set_roster(tree, roster: Dictionary) -> void:
	if tree == null:
		return
	tree.set_meta(ROSTER_META_KEY, _normalize_roster(roster))

static func clear_roster(tree) -> void:
	if tree == null:
		return
	if tree.has_meta(ROSTER_META_KEY):
		tree.remove_meta(ROSTER_META_KEY)

static func get_caught_species_ids(tree) -> Array:
	return get_roster(tree).get("caught_species_ids", []).duplicate(true)

static func has_caught_species(tree, species_id: String) -> bool:
	var normalized_species_id = species_id.strip_edges().to_upper()
	if normalized_species_id.empty():
		return false
	return get_caught_species_ids(tree).has(normalized_species_id)

static func add_caught_species(tree, species_id: String) -> Dictionary:
	if tree == null:
		return {"ok": false, "reason": "tree_missing", "added": false}

	var normalized_species_id = species_id.strip_edges().to_upper()
	if normalized_species_id.empty():
		return {"ok": false, "reason": "invalid_species_id", "added": false}

	var roster = get_roster(tree)
	var caught_species_ids = roster.get("caught_species_ids", [])
	if typeof(caught_species_ids) != TYPE_ARRAY:
		caught_species_ids = []

	if caught_species_ids.has(normalized_species_id):
		return {"ok": true, "reason": "already_present", "added": false}

	caught_species_ids.append(normalized_species_id)
	roster["caught_species_ids"] = caught_species_ids
	set_roster(tree, roster)
	return {"ok": true, "reason": "ok", "added": true}

static func get_biome_state(tree) -> Dictionary:
	if tree == null:
		return _normalize_biome_state({})

	if tree.has_meta(BIOME_META_KEY):
		var stored_biome_state = tree.get_meta(BIOME_META_KEY)
		if typeof(stored_biome_state) == TYPE_DICTIONARY:
			var normalized_biome_state = _normalize_biome_state(stored_biome_state)
			tree.set_meta(BIOME_META_KEY, normalized_biome_state)
			return normalized_biome_state.duplicate(true)

	var biome_state = _normalize_biome_state({})
	tree.set_meta(BIOME_META_KEY, biome_state)
	return biome_state.duplicate(true)

static func set_biome_state(tree, biome_state: Dictionary) -> void:
	if tree == null:
		return
	tree.set_meta(BIOME_META_KEY, _normalize_biome_state(biome_state))

static func clear_biome_state(tree) -> void:
	if tree == null:
		return
	if tree.has_meta(BIOME_META_KEY):
		tree.remove_meta(BIOME_META_KEY)

static func ensure_biome_state(tree, initial_biome_id: String = "") -> Dictionary:
	if tree == null:
		return _normalize_biome_state({"current_biome_id": initial_biome_id})

	if tree.has_meta(BIOME_META_KEY):
		return get_biome_state(tree)

	var biome_state = _normalize_biome_state({
		"current_biome_id": initial_biome_id,
		"transition_trigger": "battle_start",
		"source": DEFAULT_BIOME_SOURCE,
	})
	tree.set_meta(BIOME_META_KEY, biome_state)
	return biome_state.duplicate(true)

static func advance_biome_state(tree, transition_trigger: String, next_biome_id: String = "") -> Dictionary:
	if tree == null:
		var fallback_state = _normalize_biome_state({})
		fallback_state["previous_biome_id"] = fallback_state["current_biome_id"]
		fallback_state["current_biome_id"] = _normalize_biome_id(next_biome_id)
		fallback_state["transition_trigger"] = _normalize_transition_trigger(transition_trigger)
		fallback_state["encounter_index"] = int(fallback_state.get("encounter_index", 0)) + 1
		return fallback_state

	var biome_state = get_biome_state(tree)
	var current_biome_id = String(biome_state.get("current_biome_id", DEFAULT_BIOME_ID))
	var resolved_next_biome_id = _normalize_biome_id(next_biome_id)
	if resolved_next_biome_id.empty():
		resolved_next_biome_id = _pick_next_biome_id(current_biome_id)

	biome_state["previous_biome_id"] = current_biome_id
	biome_state["current_biome_id"] = resolved_next_biome_id
	biome_state["transition_trigger"] = _normalize_transition_trigger(transition_trigger)
	biome_state["encounter_index"] = int(biome_state.get("encounter_index", 0)) + 1
	if String(biome_state.get("source", "")).strip_edges().empty():
		biome_state["source"] = DEFAULT_BIOME_SOURCE

	set_biome_state(tree, biome_state)
	return biome_state.duplicate(true)

static func advance_biome_for_level(tree, transition_trigger: String, switch_every_levels: int = 3, next_biome_id: String = "") -> Dictionary:
	var interval = max(1, switch_every_levels)
	var biome_state = get_biome_state(tree)
	var current_level = max(1, int(biome_state.get("encounter_index", 0)) + 1)
	biome_state["encounter_index"] = int(biome_state.get("encounter_index", 0)) + 1
	biome_state["transition_trigger"] = _normalize_transition_trigger(transition_trigger)

	if current_level % interval == 0:
		var current_biome_id = String(biome_state.get("current_biome_id", DEFAULT_BIOME_ID))
		var resolved_next_biome_id = _normalize_biome_id(next_biome_id)
		if resolved_next_biome_id.empty():
			resolved_next_biome_id = _pick_next_biome_id(current_biome_id)
		biome_state["previous_biome_id"] = current_biome_id
		biome_state["current_biome_id"] = resolved_next_biome_id

	set_biome_state(tree, biome_state)
	return biome_state.duplicate(true)

static func get_current_biome_id(tree) -> String:
	return String(get_biome_state(tree).get("current_biome_id", DEFAULT_BIOME_ID))

static func ensure_party_with_starter(tree, starter_species_id: String, level: int = 5):
	if tree == null:
		return null

	var normalized_species_id = starter_species_id.strip_edges().to_upper()
	if normalized_species_id.empty():
		return get_party(tree)

	add_caught_species(tree, normalized_species_id)

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

static func _normalize_roster(payload: Dictionary) -> Dictionary:
	var caught_species_payload = payload.get("caught_species_ids", [])
	if typeof(caught_species_payload) != TYPE_ARRAY:
		caught_species_payload = []

	var caught_species_ids := []
	for raw_species_id in caught_species_payload:
		var normalized_species_id = String(raw_species_id).strip_edges().to_upper()
		if normalized_species_id.empty() or caught_species_ids.has(normalized_species_id):
			continue
		caught_species_ids.append(normalized_species_id)

	return {
		"caught_species_ids": caught_species_ids,
	}

static func _normalize_biome_state(payload: Dictionary) -> Dictionary:
	var current_biome_id = _normalize_biome_id(String(payload.get("current_biome_id", DEFAULT_BIOME_ID)))
	if current_biome_id.empty():
		current_biome_id = DEFAULT_BIOME_ID

	var previous_biome_id = _normalize_biome_id(String(payload.get("previous_biome_id", "")))
	var transition_trigger = _normalize_transition_trigger(String(payload.get("transition_trigger", "battle_start")))
	var source = String(payload.get("source", DEFAULT_BIOME_SOURCE)).strip_edges().to_lower()
	if source.empty():
		source = DEFAULT_BIOME_SOURCE

	return {
		"current_biome_id": current_biome_id,
		"previous_biome_id": previous_biome_id,
		"transition_trigger": transition_trigger,
		"encounter_index": max(0, int(payload.get("encounter_index", 0))),
		"seed": int(payload.get("seed", 0)),
		"source": source,
	}

static func _normalize_biome_id(raw_biome_id: String) -> String:
	return raw_biome_id.strip_edges().to_lower().replace("_", "-").replace(" ", "-")

static func _normalize_transition_trigger(raw_trigger: String) -> String:
	var normalized_trigger = raw_trigger.strip_edges().to_lower().replace(" ", "_")
	if normalized_trigger.empty():
		return "battle_start"
	return normalized_trigger

static func _pick_next_biome_id(current_biome_id: String) -> String:
	if BIOME_ROTATION.empty():
		return DEFAULT_BIOME_ID

	var normalized_current_biome_id = _normalize_biome_id(current_biome_id)
	var current_index = BIOME_ROTATION.find(normalized_current_biome_id)
	if current_index == -1:
		return String(BIOME_ROTATION[0])
	return String(BIOME_ROTATION[(current_index + 1) % BIOME_ROTATION.size()])
