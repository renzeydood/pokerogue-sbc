extends Reference

const MoveData = preload("res://data/MoveData.gd")
const PokemonData = preload("res://data/PokemonData.gd")

const FIXTURE_PATH := "res://data/fixtures/regression-prototype.v3.fixture.json"

var _last_error := ""

func get_last_error() -> String:
	return _last_error

func load_scenario(scenario_id: String, fixture_path: String = FIXTURE_PATH):
	var payload = _read_json_file(fixture_path)
	if payload == null:
		return null
	if typeof(payload) != TYPE_DICTIONARY:
		_last_error = "Fixture payload is not a dictionary."
		return null

	var scenarios = payload.get("scenarios", [])
	if typeof(scenarios) == TYPE_ARRAY:
		var normalized_id = String(scenario_id).strip_edges().to_lower()
		for scenario in scenarios:
			if typeof(scenario) != TYPE_DICTIONARY:
				continue
			var candidate_id = String(scenario.get("id", "")).strip_edges().to_lower()
			if candidate_id == normalized_id:
				return scenario.duplicate(true)

	if _has_catalog_fixture_payload(payload):
		return {
			"id": String(scenario_id).strip_edges().to_lower() if not String(scenario_id).strip_edges().empty() else "default",
			"name": "Regression prototype fixture",
			"player": {
				"species_id": "CHARMANDER",
				"level": 5,
				"moves": [
					{"move_id": "TACKLE"},
				],
			},
			"enemy": {
				"species_id": "BULBASAUR",
				"level": 5,
				"moves": [
					{"move_id": "EMBER"},
				],
			},
		}

	_last_error = "Fixture payload is not a supported battle fixture format."
	return null

func build_battle_seed_from_fixture(scenario: Dictionary, fixture_path: String = FIXTURE_PATH):
	if typeof(scenario) != TYPE_DICTIONARY or scenario.empty():
		_last_error = "A valid fixture scenario is required."
		return null

	var payload = _read_json_file(fixture_path)
	if payload == null:
		return null
	if typeof(payload) != TYPE_DICTIONARY:
		_last_error = "Fixture payload is not a dictionary."
		return null

	var species_index = _index_species(payload)
	var moves_index = _index_moves(payload)
	var player_fixture = _normalize_side_fixture(scenario.get("player", {}))
	var enemy_fixture = _normalize_side_fixture(scenario.get("enemy", {}))

	var player_species_id = _resolve_species_id(player_fixture, "CHARMANDER")
	var enemy_species_id = _resolve_species_id(enemy_fixture, "BULBASAUR")
	var player_level = int(_resolve_level(player_fixture, 5))
	var enemy_level = int(_resolve_level(enemy_fixture, 5))

	var player_pokemon = _build_pokemon_from_fixture(species_index, moves_index, player_fixture, player_species_id, player_level)
	var enemy_pokemon = _build_pokemon_from_fixture(species_index, moves_index, enemy_fixture, enemy_species_id, enemy_level)
	if player_pokemon == null or enemy_pokemon == null:
		_last_error = "Fixture battle seed could not be built."
		return null

	return {
		"player": player_pokemon,
		"enemy": enemy_pokemon,
		"fixture_id": String(scenario.get("id", "")).strip_edges(),
		"fixture_name": String(scenario.get("name", "")).strip_edges(),
	}

func _build_pokemon_from_fixture(species_index: Dictionary, moves_index: Dictionary, fixture: Dictionary, species_id: String, level: int):
	if typeof(fixture) != TYPE_DICTIONARY:
		fixture = {}

	var species_entry = species_index.get(String(species_id).strip_edges().to_upper(), {})
	if typeof(species_entry) != TYPE_DICTIONARY:
		species_entry = {}

	var base_stats = {}
	if species_entry.has("base_stats") and typeof(species_entry.get("base_stats", {})) == TYPE_DICTIONARY:
		base_stats = species_entry.get("base_stats", {}).duplicate(true)
	else:
		base_stats = {
			"hp": 1,
			"atk": 1,
			"def": 1,
			"sp_atk": 1,
			"sp_def": 1,
			"spd": 1,
		}

	var types := []
	if species_entry.has("types") and typeof(species_entry.get("types", [])) == TYPE_ARRAY:
		types = species_entry.get("types", []).duplicate(true)

	var moves := []
	var input_moves = fixture.get("moves", [])
	if typeof(input_moves) != TYPE_ARRAY:
		input_moves = []
	for entry in input_moves:
		var move_data = _build_move_from_fixture(moves_index, entry)
		if move_data != null:
			moves.append(move_data)

	if moves.empty():
		moves.append(_build_move_from_fixture(moves_index, "TACKLE"))

	var pokemon = PokemonData.new(
		String(species_id).strip_edges().to_upper(),
		base_stats,
		int(level),
		-1,
		moves,
		types
	)
	pokemon.base_stats = base_stats.duplicate(true)
	pokemon.types = types.duplicate(true)
	pokemon.level = int(level)
	pokemon.current_hp = int(base_stats.get("hp", 1))
	if fixture.has("current_hp") and (typeof(fixture.get("current_hp")) == TYPE_INT or typeof(fixture.get("current_hp")) == TYPE_REAL):
		pokemon.current_hp = int(fixture.get("current_hp"))
	if fixture.has("stat_stages") and typeof(fixture.get("stat_stages", {})) == TYPE_DICTIONARY:
		pokemon.stat_stages = fixture.get("stat_stages", {}).duplicate(true)
	return pokemon

func _build_move_from_fixture(moves_index: Dictionary, entry) -> MoveData:
	if typeof(entry) == TYPE_STRING:
		entry = {"move_id": String(entry).strip_edges().to_upper()}
	elif typeof(entry) != TYPE_DICTIONARY:
		return null

	var move_id = String(entry.get("move_id", entry.get("id", ""))).strip_edges().to_upper()
	if move_id.empty():
		return null

	var move_entry = moves_index.get(move_id, {})
	if typeof(move_entry) != TYPE_DICTIONARY:
		move_entry = {}

	var power = int(entry.get("power", move_entry.get("power", 0)))
	var move_type = String(entry.get("type", move_entry.get("type", "NORMAL"))).strip_edges().to_upper()
	var category = String(entry.get("category", move_entry.get("category", "STATUS"))).strip_edges().to_upper()
	var pp = int(entry.get("pp", move_entry.get("pp", 25)))
	var effect_data = entry.get("effect_data", move_entry.get("effect_data", {}))
	if typeof(effect_data) != TYPE_DICTIONARY:
		effect_data = {}

	var category_value := MoveData.CATEGORY_STATUS
	if category == "PHYSICAL":
		category_value = MoveData.CATEGORY_PHYSICAL
	elif category == "SPECIAL":
		category_value = MoveData.CATEGORY_SPECIAL

	var move_data = MoveData.new(move_id, power, move_type, category_value, pp, effect_data.duplicate(true))
	move_data.move_id = move_id
	move_data.power = power
	move_data.move_type = move_type
	move_data.category = category_value
	return move_data

func _normalize_side_fixture(fixture) -> Dictionary:
	if typeof(fixture) == TYPE_DICTIONARY:
		return fixture.duplicate(true)
	return {}

func _resolve_species_id(fixture: Dictionary, fallback_species_id: String) -> String:
	var species_id = String(fixture.get("species_id", "")).strip_edges().to_upper()
	if species_id.empty():
		species_id = String(fallback_species_id).strip_edges().to_upper()
	return species_id

func _resolve_level(fixture: Dictionary, fallback_level: int) -> int:
	var level_value = fixture.get("level", fallback_level)
	if typeof(level_value) == TYPE_INT or typeof(level_value) == TYPE_REAL:
		return int(level_value)
	return fallback_level

func _index_species(payload: Dictionary) -> Dictionary:
	var species_index := {}
	var species_items = payload.get("species", [])
	if typeof(species_items) != TYPE_ARRAY:
		return species_index
	for species_entry in species_items:
		if typeof(species_entry) != TYPE_DICTIONARY:
			continue
		var key = String(species_entry.get("species_id", "")).strip_edges().to_upper()
		if key.empty():
			continue
		species_index[key] = species_entry.duplicate(true)
	return species_index

func _index_moves(payload: Dictionary) -> Dictionary:
	var moves_index := {}
	var moves_items = payload.get("moves", [])
	if typeof(moves_items) != TYPE_ARRAY:
		return moves_index
	for move_entry in moves_items:
		if typeof(move_entry) != TYPE_DICTIONARY:
			continue
		var key = String(move_entry.get("move_id", move_entry.get("id", ""))).strip_edges().to_upper()
		if key.empty():
			continue
		moves_index[key] = move_entry.duplicate(true)
	return moves_index

func _has_catalog_fixture_payload(payload: Dictionary) -> bool:
	if typeof(payload) != TYPE_DICTIONARY:
		return false
	var species_items = payload.get("species", [])
	var moves_items = payload.get("moves", [])
	return typeof(species_items) == TYPE_ARRAY and typeof(moves_items) == TYPE_ARRAY and not species_items.empty() and not moves_items.empty()

func _read_json_file(path: String):
	var file = File.new()
	var open_error = file.open(path, File.READ)
	if open_error != OK:
		_last_error = "Failed to open %s (error %d)." % [path, open_error]
		return null
	var raw_text = file.get_as_text()
	file.close()
	var parse_result = JSON.parse(raw_text)
	if parse_result.error != OK:
		_last_error = "Failed to parse JSON %s at line %d." % [path, parse_result.error_line]
		return null
	return parse_result.result
