extends Reference

const DEFAULT_MAX_SLOTS := 6

var max_slots: int = DEFAULT_MAX_SLOTS
var members: Array = []
var active_slot_index: int = -1

func _init(p_max_slots: int = DEFAULT_MAX_SLOTS, initial_members: Array = [], p_active_slot_index: int = -1) -> void:
	max_slots = int(max(1, p_max_slots))
	members = []
	active_slot_index = -1

	for member_entry in initial_members:
		if typeof(member_entry) != TYPE_DICTIONARY:
			continue
		var _add_result = add_member(member_entry)

	if members.empty():
		active_slot_index = -1
		return

	if p_active_slot_index >= 0 and p_active_slot_index < members.size():
		active_slot_index = p_active_slot_index
	else:
		active_slot_index = 0

func get_max_slots() -> int:
	return max_slots

func size() -> int:
	return members.size()

func is_full() -> bool:
	return members.size() >= max_slots

func is_empty() -> bool:
	return members.empty()

func get_active_slot_index() -> int:
	return active_slot_index

func get_members_copy() -> Array:
	return members.duplicate(true)

func get_member_at(slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= members.size():
		return {}
	return members[slot_index].duplicate(true)

func get_active_member() -> Dictionary:
	return get_member_at(active_slot_index)

func add_member(member_data: Dictionary) -> Dictionary:
	if is_full():
		return {"ok": false, "reason": "full", "index": -1}

	var normalized_member = _normalize_member(member_data)
	if normalized_member.empty():
		return {"ok": false, "reason": "invalid_member", "index": -1}

	members.append(normalized_member)
	var new_index = members.size() - 1
	if active_slot_index < 0:
		active_slot_index = new_index

	return {"ok": true, "reason": "ok", "index": new_index}

func remove_member_at(slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= members.size():
		return {"ok": false, "reason": "invalid_index", "index": -1}

	members.remove(slot_index)
	if members.empty():
		active_slot_index = -1
	elif active_slot_index > slot_index:
		active_slot_index -= 1
	elif active_slot_index == slot_index:
		active_slot_index = int(min(slot_index, members.size() - 1))

	return {"ok": true, "reason": "ok", "index": slot_index}

func set_active_slot(slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= members.size():
		return {"ok": false, "reason": "invalid_index", "index": active_slot_index}

	active_slot_index = slot_index
	return {"ok": true, "reason": "ok", "index": active_slot_index}

func swap_active_with_slot(slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= members.size():
		return {"ok": false, "reason": "invalid_index", "index": active_slot_index}
	if active_slot_index < 0 or active_slot_index >= members.size():
		return {"ok": false, "reason": "invalid_active_index", "index": active_slot_index}

	if slot_index == active_slot_index:
		return {"ok": true, "reason": "ok", "index": active_slot_index}

	var original_active_index = active_slot_index
	var incoming_member = members[slot_index]
	members[slot_index] = members[active_slot_index]
	members[original_active_index] = incoming_member
	active_slot_index = original_active_index

	# Keep party ordering invariant: slot 0 is always the active battler.
	if active_slot_index != 0 and members.size() > 0:
		var front_member = members[0]
		members[0] = members[active_slot_index]
		members[active_slot_index] = front_member
		active_slot_index = 0

	return {"ok": true, "reason": "ok", "index": active_slot_index}

func update_member_at(slot_index: int, patch: Dictionary) -> Dictionary:
	if slot_index < 0 or slot_index >= members.size():
		return {"ok": false, "reason": "invalid_index", "index": -1}

	if typeof(patch) != TYPE_DICTIONARY:
		return {"ok": false, "reason": "invalid_patch", "index": slot_index}

	var merged_member = members[slot_index].duplicate(true)
	for key in patch.keys():
		merged_member[key] = patch[key]

	var normalized_member = _normalize_member(merged_member)
	if normalized_member.empty():
		return {"ok": false, "reason": "invalid_member", "index": slot_index}

	members[slot_index] = normalized_member
	return {"ok": true, "reason": "ok", "index": slot_index}

func to_dict() -> Dictionary:
	return {
		"max_slots": max_slots,
		"members": get_members_copy(),
		"active_slot_index": active_slot_index,
	}

static func from_dict(payload: Dictionary):
	if typeof(payload) != TYPE_DICTIONARY:
		return _new_party_model()

	var payload_max_slots = int(payload.get("max_slots", DEFAULT_MAX_SLOTS))
	var payload_members = payload.get("members", [])
	if typeof(payload_members) != TYPE_ARRAY:
		payload_members = []

	var payload_active_slot_index = int(payload.get("active_slot_index", -1))
	return _new_party_model(payload_max_slots, payload_members, payload_active_slot_index)

static func _new_party_model(p_max_slots: int = DEFAULT_MAX_SLOTS, initial_members: Array = [], p_active_slot_index: int = -1):
	# Avoid `PartyModel.new(...)` inside its own class file to prevent cyclic parser errors.
	var script_ref = load("res://data/PartyModel.gd")
	if script_ref == null:
		return null
	return script_ref.new(p_max_slots, initial_members, p_active_slot_index)

func _normalize_member(member_data: Dictionary) -> Dictionary:
	if typeof(member_data) != TYPE_DICTIONARY:
		return {}

	var species_id = String(member_data.get("species_id", "")).strip_edges().to_upper()
	if species_id.empty():
		return {}

	var level = max(1, int(member_data.get("level", 5)))
	var exp_value = int(member_data.get("exp", -1))
	var current_hp = int(member_data.get("current_hp", -1))
	var move_ids = _normalize_move_ids(member_data.get("move_ids", []))
	var move_pp_current = _normalize_move_pp_current(member_data.get("move_pp_current", []), move_ids.size())

	return {
		"species_id": species_id,
		"level": level,
		"exp": exp_value,
		"current_hp": current_hp,
		"move_ids": move_ids,
		"move_pp_current": move_pp_current,
	}

func _normalize_move_ids(move_ids_payload) -> Array:
	if typeof(move_ids_payload) != TYPE_ARRAY:
		return []

	var normalized_move_ids := []
	for raw_move_id in move_ids_payload:
		var move_id = String(raw_move_id).strip_edges().to_upper()
		if move_id.empty():
			continue
		if normalized_move_ids.has(move_id):
			continue
		normalized_move_ids.append(move_id)

	return normalized_move_ids

func _normalize_move_pp_current(pp_payload, move_count: int) -> Array:
	var normalized_pp := []
	if typeof(pp_payload) != TYPE_ARRAY:
		pp_payload = []

	for i in range(move_count):
		if i < pp_payload.size():
			normalized_pp.append(max(-1, int(pp_payload[i])))
		else:
			normalized_pp.append(-1)

	return normalized_pp
