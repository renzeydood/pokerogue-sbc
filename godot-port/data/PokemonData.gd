extends Reference

const MoveData = preload("res://data/MoveData.gd")

var species_id: String
var level: int
var base_stats := {
	"hp": 0,
	"atk": 0,
	"def": 0,
	"sp_atk": 0,
	"sp_def": 0,
	"spd": 0,
}
var current_hp: int
var moves: Array = []
var types: Array = []
var stat_stages: Dictionary = {}

func _init(p_species_id: String, p_base_stats: Dictionary, p_level: int = 5, p_current_hp: int = -1, p_moves: Array = [], p_types: Array = []) -> void:
	species_id = p_species_id
	base_stats = p_base_stats.duplicate(true)
	level = p_level
	current_hp = p_current_hp
	if current_hp < 0:
		current_hp = get_base_stat("hp")
	moves = p_moves.duplicate(true)
	types = p_types.duplicate(true)
	stat_stages = {
		"atk": 0,
		"def": 0,
		"sp_atk": 0,
		"sp_def": 0,
		"spd": 0,
		"acc": 0,
		"eva": 0,
	}.duplicate(true)

func get_types() -> Array:
	return types.duplicate(true)

func get_base_stat(stat_name: String) -> int:
	return int(base_stats.get(stat_name, 0))

func get_stat_stage(stat_name: String) -> int:
	if typeof(stat_stages) != TYPE_DICTIONARY:
		stat_stages = {}
	var normalized_stat_name = String(stat_name).strip_edges().to_lower()
	return int(stat_stages.get(normalized_stat_name, 0))

func set_stat_stage(stat_name: String, value: int) -> void:
	if typeof(stat_stages) != TYPE_DICTIONARY:
		stat_stages = {}
	var normalized_stat_name = String(stat_name).strip_edges().to_lower()
	stat_stages[normalized_stat_name] = int(clamp(value, -6, 6))

func is_fainted() -> bool:
	return current_hp <= 0

static func create_battle_02_test_data(selected_player_species_id: String = "") -> Dictionary:
	var loader_script = load("res://logic/CatalogDataLoader.gd")
	var loader = loader_script.new()
	if not loader.load_catalogs():
		push_warning("CatalogDataLoader failed (%s). Using loader fallback battle seed." % loader.get_last_error())
	var normalized_species_id = selected_player_species_id.strip_edges().to_upper()
	if normalized_species_id.empty():
		return loader.build_battle_seed()
	return loader.build_battle_seed(normalized_species_id)
