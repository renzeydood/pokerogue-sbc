extends Reference

const MoveData = preload("res://data/MoveData.gd")

const TYPE_CHART := {
	"NORMAL": {
		"ROCK": 0.5,
		"STEEL": 0.5,
		"GHOST": 0.0,
	},
	"FIRE": {
		"GRASS": 2.0,
		"ICE": 2.0,
		"BUG": 2.0,
		"STEEL": 2.0,
		"FIRE": 0.5,
		"WATER": 0.5,
		"ROCK": 0.5,
		"DRAGON": 0.5,
	},
	"WATER": {
		"FIRE": 2.0,
		"GROUND": 2.0,
		"ROCK": 2.0,
		"WATER": 0.5,
		"GRASS": 0.5,
		"DRAGON": 0.5,
	},
	"ELECTRIC": {
		"WATER": 2.0,
		"FLYING": 2.0,
		"ELECTRIC": 0.5,
		"GRASS": 0.5,
		"DRAGON": 0.5,
		"GROUND": 0.0,
	},
	"GRASS": {
		"FIRE": 0.5,
		"WATER": 2.0,
		"GRASS": 0.5,
		"ROCK": 2.0,
		"GROUND": 2.0,
		"POISON": 0.5,
		"FLYING": 0.5,
		"BUG": 0.5,
		"DRAGON": 0.5,
		"STEEL": 0.5,
	},
	"ICE": {
		"GRASS": 2.0,
		"GROUND": 2.0,
		"FLYING": 2.0,
		"DRAGON": 2.0,
		"FIRE": 0.5,
		"WATER": 0.5,
		"ICE": 0.5,
		"STEEL": 0.5,
	},
	"FIGHTING": {
		"NORMAL": 2.0,
		"ICE": 2.0,
		"ROCK": 2.0,
		"DARK": 2.0,
		"STEEL": 2.0,
		"POISON": 0.5,
		"FLYING": 0.5,
		"PSYCHIC": 0.5,
		"BUG": 0.5,
		"FAIRY": 0.5,
		"GHOST": 0.0,
	},
	"POISON": {
		"GRASS": 2.0,
		"FAIRY": 2.0,
		"POISON": 0.5,
		"GROUND": 0.5,
		"ROCK": 0.5,
		"GHOST": 0.5,
		"STEEL": 0.0,
	},
	"GROUND": {
		"FIRE": 2.0,
		"ELECTRIC": 2.0,
		"POISON": 2.0,
		"ROCK": 2.0,
		"STEEL": 2.0,
		"GRASS": 0.5,
		"BUG": 0.5,
		"FLYING": 0.0,
	},
	"FLYING": {
		"GRASS": 2.0,
		"FIGHTING": 2.0,
		"BUG": 2.0,
		"ELECTRIC": 0.5,
		"ROCK": 0.5,
		"STEEL": 0.5,
	},
	"PSYCHIC": {
		"FIGHTING": 2.0,
		"POISON": 2.0,
		"PSYCHIC": 0.5,
		"STEEL": 0.5,
		"DARK": 0.0,
	},
	"BUG": {
		"GRASS": 2.0,
		"PSYCHIC": 2.0,
		"DARK": 2.0,
		"FIRE": 0.5,
		"FIGHTING": 0.5,
		"POISON": 0.5,
		"FLYING": 0.5,
		"GHOST": 0.5,
		"STEEL": 0.5,
		"FAIRY": 0.5,
	},
	"ROCK": {
		"FIRE": 2.0,
		"ICE": 2.0,
		"FLYING": 2.0,
		"BUG": 2.0,
		"FIGHTING": 0.5,
		"GROUND": 0.5,
		"STEEL": 0.5,
	},
	"GHOST": {
		"NORMAL": 0.0,
		"FIGHTING": 0.0,
		"PSYCHIC": 2.0,
		"GHOST": 2.0,
		"DARK": 0.5,
	},
	"DRAGON": {
		"DRAGON": 2.0,
		"STEEL": 0.5,
		"FAIRY": 0.0,
	},
	"DARK": {
		"PSYCHIC": 2.0,
		"GHOST": 2.0,
		"FIGHTING": 0.5,
		"DARK": 0.5,
		"FAIRY": 0.5,
	},
	"STEEL": {
		"ROCK": 2.0,
		"ICE": 2.0,
		"FAIRY": 2.0,
		"FIRE": 0.5,
		"WATER": 0.5,
		"ELECTRIC": 0.5,
		"STEEL": 0.5,
	},
	"FAIRY": {
		"FIRE": 0.5,
		"FIGHTING": 2.0,
		"POISON": 0.5,
		"DRAGON": 2.0,
		"DARK": 2.0,
		"STEEL": 0.5,
	},
}

# BATTLE-03C scope: add type effectiveness on top of neutral core damage.
# FEATURE-01A scope: physical/special stat pairing and STAB.
# Intentionally deferred to later tickets: criticals, status/burn,
# weather, screens, abilities, and items.

static func calc_damage(attacker, move, defender, debug_enabled: bool = false) -> int:
	if attacker == null or move == null or defender == null:
		return 1

	var level = max(1, int(attacker.level))
	var power = max(0, int(move.power))
	var move_category = _get_move_category(move)
	var is_physical = move_category == MoveData.CATEGORY_PHYSICAL
	var is_special = move_category == MoveData.CATEGORY_SPECIAL

	var attack_stat_name = "atk" if is_physical or not is_special else "sp_atk"
	var defense_stat_name = "def" if is_physical or not is_special else "sp_def"
	var attack_stat = max(1, int(attacker.get_base_stat(attack_stat_name)))
	var defense_stat = max(1, int(defender.get_base_stat(defense_stat_name)))

	var level_multiplier = (2.0 * float(level)) / 5.0 + 2.0
	var base_damage = (level_multiplier * float(power) * float(attack_stat) / float(defense_stat)) / 50.0 + 2.0
	var type_multiplier = _get_type_multiplier(move.move_type, defender)
	if type_multiplier <= 0.0:
		if debug_enabled:
			print("[BattleCalc] Move=%s Cat=%s Lvl=%d Pow=%d Type=0.0 Applied=0" % [str(move.move_id), move_category, level, power])
		return 0
	var stab_multiplier = _get_stab_multiplier(attacker, move)
	var final_damage = base_damage * stab_multiplier * type_multiplier
	var applied_damage = _to_damage_value(final_damage)

	if debug_enabled:
		print(
			"[BattleCalc] Move=%s Cat=%s Lvl=%d Pow=%d Atk(%s)=%d Def(%s)=%d Base=%.4f STAB=%.2f Type=%.2f Final=%.4f Applied=%d" % [
				str(move.move_id),
				move_category,
				level,
				power,
				attack_stat_name,
				attack_stat,
				defense_stat_name,
				defense_stat,
				base_damage,
				stab_multiplier,
				type_multiplier,
				final_damage,
				applied_damage,
			]
		)

	return applied_damage

static func get_type_multiplier(move_type: String, defender) -> float:
	return _get_type_multiplier(move_type, defender)

static func get_stab_multiplier(attacker, move) -> float:
	return _get_stab_multiplier(attacker, move)

static func _get_type_multiplier(move_type: String, defender) -> float:
	if defender == null:
		return 1.0

	var defender_types: Array = []
	if defender.has_method("get_types"):
		defender_types = defender.get_types()
	elif "types" in defender:
		defender_types = defender.types

	if defender_types.empty():
		return 1.0

	var attack_type = String(move_type).to_upper()
	if not TYPE_CHART.has(attack_type):
		return 1.0

	var chart_row = TYPE_CHART[attack_type]
	var total_multiplier := 1.0
	for defender_type in defender_types:
		var key = String(defender_type).to_upper()
		total_multiplier *= float(chart_row.get(key, 1.0))

	return total_multiplier

static func _get_stab_multiplier(attacker, move) -> float:
	if attacker == null or move == null:
		return 1.0

	var move_category = _get_move_category(move)
	if move_category == MoveData.CATEGORY_STATUS:
		return 1.0

	var move_type = String(move.move_type).strip_edges().to_upper()
	if move_type.empty():
		return 1.0

	var attacker_types: Array = []
	if attacker.has_method("get_types"):
		attacker_types = attacker.get_types()
	elif "types" in attacker:
		attacker_types = attacker.types

	for attacker_type in attacker_types:
		if String(attacker_type).strip_edges().to_upper() == move_type:
			return 1.5

	return 1.0

static func _get_move_category(move) -> String:
	if move == null:
		return ""
	if move.has_method("get_category"):
		return String(move.get_category()).strip_edges().to_lower()
	if "category" in move:
		return String(move.category).strip_edges().to_lower()
	return ""

static func _to_damage_value(value: float) -> int:
	# Match core rounding policy: floor once at end, min 1.
	var floored_damage: int = int(floor(value))
	if floored_damage < 1:
		return 1
	return floored_damage

static func get_fixed_test_vectors() -> Array:
	# Deterministic vectors for BATTLE-03B verification.
	return [
		{
			"name": "Bulbasaur Tackle vs Charmander",
			"attacker_level": 5,
			"attacker_atk": 49,
			"move_power": 40,
			"defender_def": 43,
			"expected": 5,
		},
		{
			"name": "Charmander Ember (type-effective) vs Bulbasaur",
			"attacker_level": 5,
			"attacker_atk": 52,
			"move_power": 40,
			"defender_def": 49,
			"defender_types": ["GRASS", "POISON"],
			"move_type": "FIRE",
			"expected": 10,
		},
		{
			"name": "Squirtle Water Gun (type-effective, STAB) vs Charmander",
			"attacker_level": 5,
			"attacker_atk": 48,
			"move_power": 40,
			"defender_def": 43,
			"defender_types": ["FIRE"],
			"move_type": "WATER",
			"attacker_types": ["WATER"],
			"expected": 16,
		},
		{
			"name": "Bulbasaur Vine Whip (STAB) vs Magikarp",
			"attacker_level": 5,
			"attacker_atk": 49,
			"attacker_types": ["GRASS", "POISON"],
			"move_power": 45,
			"defender_def": 48,
			"defender_types": ["WATER", "FLYING"],
			"move_type": "GRASS",
			"move_category": MoveData.CATEGORY_PHYSICAL,
			"expected": 34,
		},
		{
			"name": "Special attack uses sp_atk/sp_def without STAB",
			"attacker_level": 5,
			"attacker_atk": 20,
			"attacker_sp_atk": 30,
			"move_power": 50,
			"defender_def": 49,
			"defender_sp_def": 60,
			"defender_types": ["NORMAL"],
			"attacker_types": ["FIRE"],
			"move_type": "WATER",
			"move_category": MoveData.CATEGORY_SPECIAL,
			"expected": 6,
		},
		{
			"name": "Ghost move is immune against Normal defender",
			"attacker_level": 5,
			"attacker_atk": 52,
			"move_power": 40,
			"defender_def": 49,
			"defender_types": ["NORMAL"],
			"move_type": "GHOST",
			"expected": 0,
		},
		{
			"name": "Fire move is super effective against Grass and Ice defenders",
			"attacker_level": 5,
			"attacker_atk": 52,
			"move_power": 40,
			"defender_def": 49,
			"defender_types": ["GRASS", "ICE"],
			"move_type": "FIRE",
			"expected": 21,
		},
		{
			"name": "Higher level scaling sanity",
			"attacker_level": 50,
			"attacker_atk": 52,
			"move_power": 40,
			"defender_def": 49,
			"expected": 20,
		},
	]

static func run_fixed_test_vectors() -> Array:
	var results := []
	for test_case in get_fixed_test_vectors():
		var level = int(test_case["attacker_level"])
		var atk = int(test_case.get("attacker_atk", 0))
		var sp_atk = int(test_case.get("attacker_sp_atk", atk))
		var power = int(test_case["move_power"])
		var defense = int(test_case["defender_def"])
		var sp_def = int(test_case.get("defender_sp_def", defense))
		var expected = int(test_case["expected"])
		var move_type = String(test_case.get("move_type", "NORMAL"))
		var move_category = String(test_case.get("move_category", MoveData.CATEGORY_PHYSICAL))
		var defender_types = test_case.get("defender_types", [])
		var attacker_types = test_case.get("attacker_types", [])

		var level_multiplier = (2.0 * float(level)) / 5.0 + 2.0
		var attack_value = sp_atk if move_category == MoveData.CATEGORY_SPECIAL else atk
		var defense_value = sp_def if move_category == MoveData.CATEGORY_SPECIAL else defense
		var base_damage = (level_multiplier * float(power) * float(attack_value) / float(defense_value)) / 50.0 + 2.0
		var stab_multiplier = 1.5 if attacker_types.has(move_type) and move_category != MoveData.CATEGORY_STATUS else 1.0
		var defender_stub = {"types": defender_types}
		var type_multiplier = _get_type_multiplier(move_type, defender_stub)
		var actual = 0
		if type_multiplier <= 0.0:
			actual = 0
		else:
			base_damage *= stab_multiplier * type_multiplier
			actual = _to_damage_value(base_damage)

		results.append({
			"name": test_case["name"],
			"expected": expected,
			"actual": actual,
			"pass": actual == expected,
		})

	return results
