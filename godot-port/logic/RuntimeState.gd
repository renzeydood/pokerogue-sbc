extends Reference
class_name RuntimeState

const PARTY_META_KEY := "runtime_party_v1"
const ROSTER_META_KEY := "runtime_roster_v1"
const BIOME_META_KEY := "runtime_biome_v1"
const LEGACY_SELECTED_SPECIES_META_KEY := "selected_species_id"
const DEBUG_SEED_PROFILES_PATH := "res://data/debug-seed-profiles.json"
const STARTER_SPECIES_INDEX_META_KEY := "runtime_starter_species_index_v1"
const SPECIES_CATALOG_PATH := "res://godot-minimal-assets/data/species-catalog.v3.json"
const PartyModel = preload("res://data/PartyModel.gd")
const DEFAULT_BIOME_ID := "grass"
const DEFAULT_BIOME_SOURCE := "baseline_rotation"
const DEFAULT_CAUGHT_SPECIES_IDS := [
	"BULBASAUR", "CHARMANDER", "SQUIRTLE",
	"CHIKORITA", "CYNDAQUIL", "TOTODILE",
	"TREECKO", "TORCHIC", "MUDKIP",
	"TURTWIG", "CHIMCHAR", "PIPLUP",
	"SNIVY", "TEPIG", "OSHAWOTT",
	"CHESPIN", "FENNEKIN", "FROAKIE",
	"ROWLET", "LITTEN", "POPPLIO",
	"GROOKEY", "SCORBUNNY", "SOBBLE",
	"SPRIGATITO", "FUECOCO", "QUAXLY",
]
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
			normalized_roster = _backfill_roster_base_species_ids(tree, normalized_roster)
			tree.set_meta(ROSTER_META_KEY, normalized_roster)
			return normalized_roster.duplicate(true)
		if typeof(stored_roster) == TYPE_ARRAY:
			var legacy_roster = _normalize_roster({"caught_species_ids": stored_roster})
			legacy_roster = _backfill_roster_base_species_ids(tree, legacy_roster)
			tree.set_meta(ROSTER_META_KEY, legacy_roster)
			return legacy_roster.duplicate(true)

	var roster = _normalize_roster({})
	roster = _backfill_roster_base_species_ids(tree, roster)
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

	var normalized_base_species_id = _resolve_starter_species_id(tree, normalized_species_id)
	var changed := false

	if not caught_species_ids.has(normalized_species_id):
		caught_species_ids.append(normalized_species_id)
		changed = true

	if not normalized_base_species_id.empty() and not caught_species_ids.has(normalized_base_species_id):
		caught_species_ids.append(normalized_base_species_id)
		changed = true

	if not changed:
		return {"ok": true, "reason": "already_present", "added": false}

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
	var current_biome_id = String(biome_state.get("current_biome_id", DEFAULT_BIOME_ID))

	if current_level % interval == 0:
		var resolved_next_biome_id = _normalize_biome_id(next_biome_id)
		if resolved_next_biome_id.empty():
			resolved_next_biome_id = _pick_next_biome_id(current_biome_id)
		biome_state["previous_biome_id"] = current_biome_id
		biome_state["current_biome_id"] = resolved_next_biome_id
	else:
		# Keep previous/current aligned on non-switch levels so consumers can detect real biome changes.
		biome_state["previous_biome_id"] = current_biome_id

	set_biome_state(tree, biome_state)
	return biome_state.duplicate(true)

static func get_current_biome_id(tree) -> String:
	return String(get_biome_state(tree).get("current_biome_id", DEFAULT_BIOME_ID))

static func get_debug_seed_species_ids(profile_id: String = "ui_party_showcase") -> Array:
	var profile = _get_debug_seed_profile(profile_id)
	if profile.empty():
		return []
	return _collect_profile_species_ids(profile)

static func merge_species_ids_with_debug_seed_profile(base_species_ids: Array, profile_id: String = "ui_party_showcase") -> Array:
	var merged_species := []
	for raw_species_id in base_species_ids:
		var species_id = String(raw_species_id).strip_edges().to_upper()
		if species_id.empty() or merged_species.has(species_id):
			continue
		merged_species.append(species_id)

	for species_id in get_debug_seed_species_ids(profile_id):
		if merged_species.has(species_id):
			continue
		merged_species.append(species_id)

	return merged_species

static func apply_debug_seed_profile(tree, profile_id: String = "ui_party_showcase", replace_party: bool = true, merge_roster: bool = true) -> Dictionary:
	if tree == null:
		return {"ok": false, "reason": "tree_missing", "profile_id": profile_id}

	var profile = _get_debug_seed_profile(profile_id)
	if profile.empty():
		return {"ok": false, "reason": "profile_not_found", "profile_id": profile_id}

	var profile_species_ids = _collect_profile_species_ids(profile)
	var roster_species_ids := []
	if merge_roster:
		roster_species_ids = get_caught_species_ids(tree)

	roster_species_ids = _merge_species_arrays(roster_species_ids, profile_species_ids)
	set_roster(tree, {"caught_species_ids": roster_species_ids})

	var party_members_payload = profile.get("party_members", [])
	if replace_party and typeof(party_members_payload) == TYPE_ARRAY:
		var seeded_party = PartyModel.new()
		for raw_member in party_members_payload:
			if typeof(raw_member) != TYPE_DICTIONARY:
				continue
			var add_result = seeded_party.add_member(_normalize_profile_party_member(raw_member))
			if not bool(add_result.get("ok", false)):
				continue

		if seeded_party.size() > 0:
			var requested_active_slot = int(profile.get("active_slot_index", 0))
			seeded_party.set_active_slot(clamp(requested_active_slot, 0, seeded_party.size() - 1))
			set_party(tree, seeded_party)

	var selected_species_id = String(profile.get("selected_species_id", "")).strip_edges().to_upper()
	if selected_species_id.empty() and not roster_species_ids.empty():
		selected_species_id = String(roster_species_ids[0])
	if not selected_species_id.empty():
		tree.set_meta(LEGACY_SELECTED_SPECIES_META_KEY, selected_species_id)

	return {
		"ok": true,
		"reason": "ok",
		"profile_id": String(profile.get("id", profile_id)),
		"roster_count": roster_species_ids.size(),
		"party_count": get_party(tree).size() if get_party(tree) != null else 0,
	}

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

static func _get_debug_seed_profile(profile_id: String) -> Dictionary:
	var normalized_profile_id = String(profile_id).strip_edges().to_lower()
	if normalized_profile_id.empty():
		normalized_profile_id = "ui_party_showcase"

	var profiles = _load_debug_seed_profiles()
	for profile in profiles:
		if typeof(profile) != TYPE_DICTIONARY:
			continue
		var candidate_id = String(profile.get("id", "")).strip_edges().to_lower()
		if candidate_id == normalized_profile_id:
			return profile.duplicate(true)

	return {}

static func _load_debug_seed_profiles() -> Array:
	var file = File.new()
	if not file.file_exists(DEBUG_SEED_PROFILES_PATH):
		return []
	if file.open(DEBUG_SEED_PROFILES_PATH, File.READ) != OK:
		return []

	var parse_result = JSON.parse(file.get_as_text())
	file.close()
	if parse_result.error != OK or typeof(parse_result.result) != TYPE_DICTIONARY:
		return []

	var payload = parse_result.result
	var profiles = payload.get("profiles", [])
	if typeof(profiles) != TYPE_ARRAY:
		return []
	return profiles

static func _collect_profile_species_ids(profile: Dictionary) -> Array:
	var collected_species_ids := []
	collected_species_ids = _merge_species_arrays(collected_species_ids, profile.get("caught_species_ids", []))

	var party_members = profile.get("party_members", [])
	if typeof(party_members) == TYPE_ARRAY:
		for raw_member in party_members:
			if typeof(raw_member) != TYPE_DICTIONARY:
				continue
			var member_species_id = String(raw_member.get("species_id", "")).strip_edges().to_upper()
			if member_species_id.empty() or collected_species_ids.has(member_species_id):
				continue
			collected_species_ids.append(member_species_id)

	var selected_species_id = String(profile.get("selected_species_id", "")).strip_edges().to_upper()
	if not selected_species_id.empty() and not collected_species_ids.has(selected_species_id):
		collected_species_ids.append(selected_species_id)

	return collected_species_ids

static func _normalize_profile_party_member(member_payload: Dictionary) -> Dictionary:
	var normalized_species_id = String(member_payload.get("species_id", "")).strip_edges().to_upper()
	if normalized_species_id.empty():
		return {}

	return {
		"species_id": normalized_species_id,
		"level": max(1, int(member_payload.get("level", 5))),
		"current_hp": int(member_payload.get("current_hp", -1)),
		"move_ids": _normalize_move_ids(member_payload.get("move_ids", [])),
	}

static func _normalize_move_ids(move_ids_payload) -> Array:
	if typeof(move_ids_payload) != TYPE_ARRAY:
		return []

	var normalized_move_ids := []
	for raw_move_id in move_ids_payload:
		var move_id = String(raw_move_id).strip_edges().to_upper()
		if move_id.empty() or normalized_move_ids.has(move_id):
			continue
		normalized_move_ids.append(move_id)
	return normalized_move_ids

static func _merge_species_arrays(left_species_ids: Array, right_species_ids: Array) -> Array:
	var merged_species_ids := []
	for raw_species_id in left_species_ids:
		var species_id = String(raw_species_id).strip_edges().to_upper()
		if species_id.empty() or merged_species_ids.has(species_id):
			continue
		merged_species_ids.append(species_id)

	for raw_species_id in right_species_ids:
		var species_id = String(raw_species_id).strip_edges().to_upper()
		if species_id.empty() or merged_species_ids.has(species_id):
			continue
		merged_species_ids.append(species_id)

	return merged_species_ids

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

	for default_species_id in DEFAULT_CAUGHT_SPECIES_IDS:
		if caught_species_ids.has(default_species_id):
			continue
		caught_species_ids.append(default_species_id)

	return {
		"caught_species_ids": caught_species_ids,
	}

static func _backfill_roster_base_species_ids(tree, roster: Dictionary) -> Dictionary:
	if tree == null:
		return roster
	if typeof(roster) != TYPE_DICTIONARY:
		return _normalize_roster({})

	var caught_species_ids = roster.get("caught_species_ids", [])
	if typeof(caught_species_ids) != TYPE_ARRAY:
		caught_species_ids = []

	var normalized_caught_species_ids := []
	for raw_species_id in caught_species_ids:
		var species_id = String(raw_species_id).strip_edges().to_upper()
		if species_id.empty() or normalized_caught_species_ids.has(species_id):
			continue
		normalized_caught_species_ids.append(species_id)
		var base_species_id = _resolve_starter_species_id(tree, species_id)
		if not base_species_id.empty() and not normalized_caught_species_ids.has(base_species_id):
			normalized_caught_species_ids.append(base_species_id)

	roster["caught_species_ids"] = normalized_caught_species_ids
	return _normalize_roster(roster)

static func _resolve_starter_species_id(tree, species_id: String) -> String:
	var normalized_species_id = species_id.strip_edges().to_upper()
	if normalized_species_id.empty():
		return ""

	var starter_species_index = _get_starter_species_index(tree)
	if starter_species_index.has(normalized_species_id):
		return String(starter_species_index.get(normalized_species_id, normalized_species_id)).strip_edges().to_upper()

	return normalized_species_id

static func _get_starter_species_index(tree) -> Dictionary:
	if tree != null and tree.has_meta(STARTER_SPECIES_INDEX_META_KEY):
		var cached_index = tree.get_meta(STARTER_SPECIES_INDEX_META_KEY)
		if typeof(cached_index) == TYPE_DICTIONARY and not cached_index.empty():
			return cached_index

	var index := {}
	var file = File.new()
	if file.file_exists(SPECIES_CATALOG_PATH) and file.open(SPECIES_CATALOG_PATH, File.READ) == OK:
		var parse_result = JSON.parse(file.get_as_text())
		file.close()
		if parse_result.error == OK and typeof(parse_result.result) == TYPE_DICTIONARY:
			var items = parse_result.result.get("items", [])
			if typeof(items) == TYPE_ARRAY:
				for item in items:
					if typeof(item) != TYPE_DICTIONARY:
						continue
					var species_id = String(item.get("species_id", "")).strip_edges().to_upper()
					if species_id.empty():
						continue
					var starter_species_id = String(item.get("starter_species_id", species_id)).strip_edges().to_upper()
					if starter_species_id.empty():
						starter_species_id = species_id
					index[species_id] = starter_species_id

	if tree != null:
		tree.set_meta(STARTER_SPECIES_INDEX_META_KEY, index)
	return index

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
