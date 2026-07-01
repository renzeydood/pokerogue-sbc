extends Reference
class_name CatalogDataLoader

const MoveData = preload("res://data/MoveData.gd")

const SPECIES_CATALOG_PATH := "res://godot-minimal-assets/data/species-catalog.v1.json"
const MOVES_CATALOG_PATH := "res://godot-minimal-assets/data/moves-catalog.v1.json"
const POKEMON_SPRITE_ROOT := "assets/images/pokemon/"

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

func build_move_data(move_id: String):
	var move_entry = get_move(move_id)
	if move_entry.empty():
		push_warning("Missing move entry for %s. Using fallback move data." % move_id)
		return MoveData.new(move_id.strip_edges().to_upper(), 0, "UNKNOWN", MoveData.CATEGORY_STATUS)

	var category = String(move_entry.get("category", "STATUS")).to_upper()
	var category_value = MoveData.CATEGORY_STATUS
	if category == "PHYSICAL":
		category_value = MoveData.CATEGORY_PHYSICAL
	elif category == "SPECIAL":
		category_value = MoveData.CATEGORY_SPECIAL

	return MoveData.new(
		String(move_entry.get("move_id", move_id)).to_upper(),
		int(move_entry.get("power", 0)),
		String(move_entry.get("type", "UNKNOWN")).to_upper(),
		category_value
	)

func build_pokemon_data(species_id: String, level: int = 5, move_ids: Array = []):
	var pokemon_data_script = load("res://data/PokemonData.gd")
	var species_entry = get_species(species_id)
	var requested_move_ids := []
	for move_id in move_ids:
		requested_move_ids.append(String(move_id).strip_edges().to_upper())
	if requested_move_ids.empty():
		requested_move_ids.append("TACKLE")

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

func build_battle_seed() -> Dictionary:
	var player = build_pokemon_data("BULBASAUR", 5, ["TACKLE"])
	var enemy = build_pokemon_data("CHARMANDER", 5, ["EMBER"])
	return {
		"player": player,
		"enemy": enemy,
	}

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

	return sprite_paths

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
