extends Reference

const MoveData = preload("res://data/MoveData.gd")

const SPECIES_CATALOG_PATH := "res://godot-minimal-assets/data/species-catalog.v3.json"
const MOVES_CATALOG_PATH := "res://godot-minimal-assets/data/moves-catalog.v1.json"
const POKEMON_SPRITE_ROOT := "assets/images/pokemon/"
const DEFAULT_MOVE_ID := "TACKLE"
const MAX_BATTLE_MOVE_SLOTS := 4
const MOVE_EFFECT_OVERRIDES := {
	"GROWL": {"target": "defender", "stat_changes": {"atk": -1}},
	"TAIL_WHIP": {"target": "defender", "stat_changes": {"def": -1}},
	"LEER": {"target": "defender", "stat_changes": {"def": -1}},
	"STRING_SHOT": {"target": "defender", "stat_changes": {"spd": -1}},
	"SCARY_FACE": {"target": "defender", "stat_changes": {"spd": -2}},
	"SMOKESCREEN": {"target": "defender", "stat_changes": {"acc": -1}},
	"SAND_ATTACK": {"target": "defender", "stat_changes": {"acc": -1}},
	"CHARM": {"target": "defender", "stat_changes": {"atk": -2}},
	"BABY_DOLL_EYES": {"target": "defender", "stat_changes": {"atk": -1}},
	"METAL_SOUND": {"target": "defender", "stat_changes": {"sp_def": -2}},
	"AGILITY": {"target": "attacker", "stat_changes": {"spd": 2}},
	"HARDEN": {"target": "attacker", "stat_changes": {"def": 1}},
	"IRON_DEFENSE": {"target": "attacker", "stat_changes": {"def": 2}},
	"GROWTH": {"target": "attacker", "stat_changes": {"atk": 1, "sp_atk": 1}},
	"HONE_CLAWS": {"target": "attacker", "stat_changes": {"atk": 1, "acc": 1}},
	"WORK_UP": {"target": "attacker", "stat_changes": {"atk": 1, "sp_atk": 1}},
	"SWORDS_DANCE": {"target": "attacker", "stat_changes": {"atk": 2}},
	"DEFENSE_CURL": {"target": "attacker", "stat_changes": {"def": 1}},
	"WITHDRAW": {"target": "attacker", "stat_changes": {"def": 1}},
}

var _loaded := false
var _species_by_id := {}
var _moves_by_id := {}
var _last_error := ""

func is_loaded() -> bool:
	return _loaded

func get_last_error() -> String:
	return _last_error

func load_catalogs() -> bool:
	if _loaded:
		return true

	var species_payload = _read_json_file(SPECIES_CATALOG_PATH)
	if species_payload == null:
		return false

	var moves_payload = _read_json_file(MOVES_CATALOG_PATH)
	if moves_payload == null:
		return false

	if not _index_catalog_entries(species_payload, _species_by_id, "species_id"):
		return false
	if not _index_catalog_entries(moves_payload, _moves_by_id, "move_id"):
		return false

	_loaded = true
	_last_error = ""
	return true

func get_species(species_id: String) -> Dictionary:
	if not _loaded and not load_catalogs():
		return {}
	var key = species_id.strip_edges().to_upper()
	if not _species_by_id.has(key):
		return {}
	return _species_by_id[key].duplicate(true)

func get_move(move_id: String) -> Dictionary:
	if not _loaded and not load_catalogs():
		return {}
	var key = move_id.strip_edges().to_upper()
	if not _moves_by_id.has(key):
		return {}
	return _moves_by_id[key].duplicate(true)

func get_all_species_ids() -> Array:
	if not _loaded and not load_catalogs():
		return []

	var species_ids := []
	for species_id in _species_by_id.keys():
		species_ids.append(String(species_id).strip_edges().to_upper())

	species_ids.sort()
	return species_ids

func build_move_data(move_id: String):
	var move_entry = get_move(move_id)
	if move_entry.empty():
		push_warning("Missing move entry for %s. Using fallback move data." % move_id)
		var fallback_move = MoveData.new(move_id.strip_edges().to_upper(), 0, "UNKNOWN", MoveData.CATEGORY_STATUS)
		fallback_move.set("max_pp", -1)
		if fallback_move.has_method("set_current_pp"):
			fallback_move.set_current_pp(-1)
		return fallback_move

	var category = String(move_entry.get("category", "STATUS")).to_upper()
	var category_value = MoveData.CATEGORY_STATUS
	if category == "PHYSICAL":
		category_value = MoveData.CATEGORY_PHYSICAL
	elif category == "SPECIAL":
		category_value = MoveData.CATEGORY_SPECIAL

	var move_data = MoveData.new(
		String(move_entry.get("move_id", move_id)).to_upper(),
		int(move_entry.get("power", 0)),
		String(move_entry.get("type", "UNKNOWN")).to_upper(),
		category_value
	)
	move_data.max_pp = int(move_entry.get("pp", -1))
	move_data.accuracy = int(move_entry.get("accuracy", 100))
	move_data.priority = int(move_entry.get("priority", 0))
	move_data.effect_data = _resolve_move_effect_data(move_data.move_id, move_entry)
	if move_data.has_method("restore_pp_full"):
		move_data.restore_pp_full()
	return move_data

func _resolve_move_effect_data(move_id: String, move_entry: Dictionary) -> Dictionary:
	if move_entry.has("effect_data") and typeof(move_entry.get("effect_data")) == TYPE_DICTIONARY:
		return move_entry.get("effect_data", {}).duplicate(true)
	var key = String(move_id).strip_edges().to_upper()
	if MOVE_EFFECT_OVERRIDES.has(key):
		return MOVE_EFFECT_OVERRIDES[key].duplicate(true)
	return {}

func build_pokemon_data(species_id: String, level: int = 5, move_ids: Array = []):
	var pokemon_data_script = load("res://data/PokemonData.gd")
	var species_entry = get_species(species_id)
	var requested_move_ids := _normalize_move_ids(move_ids)
	if requested_move_ids.empty() and not species_entry.empty():
		requested_move_ids = _extract_species_starter_moves(species_entry, MAX_BATTLE_MOVE_SLOTS)
	if requested_move_ids.empty():
		requested_move_ids.append(DEFAULT_MOVE_ID)

	var moves := []
	for requested_move_id in requested_move_ids:
		moves.append(build_move_data(requested_move_id))

	if species_entry.empty():
		push_warning("Missing species entry for %s. Using fallback species data." % species_id)
		return pokemon_data_script.new(
			species_id.strip_edges().to_upper(),
			{"hp": 1, "atk": 1, "def": 1, "sp_atk": 1, "sp_def": 1, "spd": 1},
			level,
			-1,
			moves,
			["UNKNOWN"]
		)

	var base_stats = species_entry.get("base_stats", {}).duplicate(true)
	var types = species_entry.get("types", []).duplicate(true)
	if types.empty():
		types = ["UNKNOWN"]

	return pokemon_data_script.new(
		String(species_entry.get("species_id", species_id)).to_upper(),
		base_stats,
		level,
		-1,
		moves,
		types
	)

func build_battle_seed(player_species_id: String = "BLASTOISE", enemy_species_id: String = "CHARMANDER") -> Dictionary:
	var normalized_player_species_id = player_species_id.strip_edges().to_upper()
	if normalized_player_species_id.empty():
		normalized_player_species_id = "BLASTOISE"

	var normalized_enemy_species_id = enemy_species_id.strip_edges().to_upper()
	if normalized_enemy_species_id.empty():
		normalized_enemy_species_id = "CHARMANDER"

	var player = build_pokemon_data(normalized_player_species_id, 5)
	var enemy = build_pokemon_data(normalized_enemy_species_id, 5)
	return {
		"player": player,
		"enemy": enemy,
	}

func _normalize_move_ids(move_ids: Array) -> Array:
	var normalized: Array = []
	for move_id in move_ids:
		var key = String(move_id).strip_edges().to_upper()
		if key.empty():
			continue
		if normalized.has(key):
			continue
		normalized.append(key)
		if normalized.size() >= MAX_BATTLE_MOVE_SLOTS:
			break
	return normalized

func _extract_species_starter_moves(species_entry: Dictionary, max_count: int) -> Array:
	var starter_moves = species_entry.get("starter_moves", [])
	if typeof(starter_moves) != TYPE_ARRAY:
		return []

	var normalized: Array = []
	for move_id in starter_moves:
		var key = String(move_id).strip_edges().to_upper()
		if key.empty():
			continue
		if normalized.has(key):
			continue
		normalized.append(key)
		if normalized.size() >= max_count:
			break

	return normalized

func get_species_dex_number(species_id: String) -> int:
	var species_entry = get_species(species_id)
	if species_entry.empty():
		return -1
	if not species_entry.has("pokedex_number"):
		return -1
	return int(species_entry["pokedex_number"])

func build_sprite_resource_paths(species_id: String, is_back: bool = false, form_tag: String = "", is_shiny: bool = false) -> Dictionary:
	var dex_num = get_species_dex_number(species_id)
	if dex_num <= 0:
		push_warning("Cannot build sprite paths: unknown species %s" % species_id)
		return {}

	var root = POKEMON_SPRITE_ROOT
	if is_back:
		root += "back/"
	elif is_shiny:
		# Placeholder convention for future expansion (front shiny sprites only for now).
		root += "shiny/"

	var base_key = str(dex_num)
	var form_key = _normalize_form_tag(form_tag)
	var sprite_key = base_key if form_key.empty() else "%s-%s" % [base_key, form_key]

	var sprite_paths = {
		"sprite_key": sprite_key,
		"texture_rel": "%s%s.png" % [root, sprite_key],
		"atlas_rel": "%s%s.json" % [root, sprite_key],
	}

	# Graceful fallback: if a specific form sprite is missing, use base species art.
	if not _resource_file_exists(sprite_paths["texture_rel"]) and not form_key.empty():
		sprite_paths["sprite_key"] = base_key
		sprite_paths["texture_rel"] = "%s%s.png" % [root, base_key]
		sprite_paths["atlas_rel"] = "%s%s.json" % [root, base_key]

	# Some species atlases reference texture filenames that differ from dex-number naming
	# (for example variant-tagged PNG files). Resolve texture path from atlas metadata.
	if not _resource_file_exists(sprite_paths["texture_rel"]) and _resource_file_exists(sprite_paths["atlas_rel"]):
		var atlas_texture_rel = _resolve_texture_rel_from_atlas(String(sprite_paths["atlas_rel"]))
		if not atlas_texture_rel.empty() and _resource_file_exists(atlas_texture_rel):
			sprite_paths["texture_rel"] = atlas_texture_rel
			sprite_paths["sprite_key"] = atlas_texture_rel.get_file().get_basename()

	return sprite_paths

func _resolve_texture_rel_from_atlas(atlas_rel: String) -> String:
	var absolute_atlas_path = "res://godot-minimal-assets/" + atlas_rel
	var file = File.new()
	if not file.file_exists(absolute_atlas_path):
		return ""

	var open_error = file.open(absolute_atlas_path, File.READ)
	if open_error != OK:
		return ""
	var json_text = file.get_as_text()
	file.close()

	var parse_result = JSON.parse(json_text)
	if parse_result.error != OK:
		return ""
	if typeof(parse_result.result) != TYPE_DICTIONARY:
		return ""

	var data = parse_result.result
	var image_name = ""
	if data.has("textures") and typeof(data["textures"]) == TYPE_ARRAY and not data["textures"].empty():
		var texture_entry = data["textures"][0]
		if typeof(texture_entry) == TYPE_DICTIONARY:
			image_name = String(texture_entry.get("image", "")).strip_edges()
	if image_name.empty() and data.has("meta") and typeof(data["meta"]) == TYPE_DICTIONARY:
		image_name = String(data["meta"].get("image", "")).strip_edges()
	if image_name.empty():
		return ""

	var atlas_dir = atlas_rel.get_base_dir()
	var texture_rel = image_name
	if image_name.find("/") == -1 and image_name.find("\\") == -1:
		texture_rel = "%s/%s" % [atlas_dir, image_name]

	return texture_rel.replace("\\", "/")

func _index_catalog_entries(payload, index_map: Dictionary, id_key: String) -> bool:
	index_map.clear()
	if typeof(payload) != TYPE_DICTIONARY:
		_last_error = "Catalog payload is not a dictionary"
		push_warning(_last_error)
		return false

	var items = payload.get("items", null)
	if typeof(items) != TYPE_ARRAY:
		_last_error = "Catalog payload missing items array"
		push_warning(_last_error)
		return false

	for item in items:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var key = String(item.get(id_key, "")).strip_edges().to_upper()
		if key.empty():
			continue
		index_map[key] = item.duplicate(true)

	if index_map.empty():
		_last_error = "Catalog items array produced no indexable entries"
		push_warning(_last_error)
		return false

	return true

func _read_json_file(path: String):
	var file = File.new()
	var open_error = file.open(path, File.READ)
	if open_error != OK:
		_last_error = "Failed to open %s (error %d)" % [path, open_error]
		push_warning(_last_error)
		return null

	var raw_text = file.get_as_text()
	file.close()

	var parse_result = JSON.parse(raw_text)
	if parse_result.error != OK:
		_last_error = "Failed to parse JSON %s at line %d" % [path, parse_result.error_line]
		push_warning(_last_error)
		return null

	return parse_result.result

func _normalize_form_tag(form_tag: String) -> String:
	return form_tag.strip_edges().to_lower().replace("_", "-").replace(" ", "-")

func _resource_file_exists(relative_path: String) -> bool:
	var absolute_path = "res://godot-minimal-assets/" + relative_path
	if ResourceLoader.exists(absolute_path):
		return true
	var file = File.new()
	return file.file_exists(absolute_path)
