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

func _init(p_species_id: String, p_base_stats: Dictionary, p_level: int = 5, p_current_hp: int = -1, p_moves: Array = []) -> void:
	species_id = p_species_id
	base_stats = p_base_stats.duplicate(true)
	level = p_level
	current_hp = p_current_hp
	if current_hp < 0:
		current_hp = get_base_stat("hp")
	moves = p_moves.duplicate(true)

func get_base_stat(stat_name: String) -> int:
	return int(base_stats.get(stat_name, 0))

func is_fainted() -> bool:
	return current_hp <= 0

static func create_battle_02_test_data() -> Dictionary:
	var pokemon_data_script = load("res://data/PokemonData.gd")
	# Base stats sourced from dependency/pokerogue/src/data/balance/species/generation-01.ts.
	var bulbasaur_stats := {
		"hp": 45,
		"atk": 49,
		"def": 49,
		"sp_atk": 65,
		"sp_def": 65,
		"spd": 45,
	}
	var charmander_stats := {
		"hp": 39,
		"atk": 52,
		"def": 43,
		"sp_atk": 60,
		"sp_def": 50,
		"spd": 65,
	}

	# Move values sourced from dependency/pokerogue/src/data/moves/move.ts.
	var bulbasaur_move = MoveData.new("TACKLE", 40, "NORMAL", MoveData.CATEGORY_PHYSICAL)
	var charmander_move = MoveData.new("EMBER", 40, "FIRE", MoveData.CATEGORY_SPECIAL)

	var bulbasaur = pokemon_data_script.new("BULBASAUR", bulbasaur_stats, 5, -1, [bulbasaur_move])
	var charmander = pokemon_data_script.new("CHARMANDER", charmander_stats, 5, -1, [charmander_move])

	return {
		"player": bulbasaur,
		"enemy": charmander,
	}
