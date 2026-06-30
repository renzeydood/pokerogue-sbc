extends Reference
class_name BattleCalc

const TYPE_CHART := {
	"NORMAL": {},
	"FIRE": {
		"GRASS": 2.0,
		"POISON": 1.0,
		"FIRE": 0.5,
		"WATER": 0.5,
		"ROCK": 0.5,
	},
	"GRASS": {
		"FIRE": 0.5,
		"WATER": 2.0,
		"GRASS": 0.5,
		"ROCK": 2.0,
		"GROUND": 2.0,
		"POISON": 0.5,
	},
}

# BATTLE-03C scope: add type effectiveness on top of neutral core damage.
# Intentionally deferred to later tickets: STAB, criticals, status/burn,
# weather, screens, abilities, and items.

static func calc_damage(attacker, move, defender) -> int:
	if attacker == null or move == null or defender == null:
		return 1

	var level = max(1, int(attacker.level))
	var power = max(0, int(move.power))

	# Neutral baseline uses physical attack/defense only for now.
	var attack_stat = max(1, int(attacker.get_base_stat("atk")))
	var defense_stat = max(1, int(defender.get_base_stat("def")))

	var level_multiplier = (2.0 * float(level)) / 5.0 + 2.0
	var base_damage = (level_multiplier * float(power) * float(attack_stat) / float(defense_stat)) / 50.0 + 2.0
	var type_multiplier = _get_type_multiplier(move.move_type, defender)
	base_damage *= type_multiplier

	return _to_damage_value(base_damage)

static func get_type_multiplier(move_type: String, defender) -> float:
	return _get_type_multiplier(move_type, defender)

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
		var atk = int(test_case["attacker_atk"])
		var power = int(test_case["move_power"])
		var defense = int(test_case["defender_def"])
		var expected = int(test_case["expected"])
		var move_type = String(test_case.get("move_type", "NORMAL"))
		var defender_types = test_case.get("defender_types", [])

		var level_multiplier = (2.0 * float(level)) / 5.0 + 2.0
		var base_damage = (level_multiplier * float(power) * float(atk) / float(defense)) / 50.0 + 2.0
		var defender_stub = {"types": defender_types}
		base_damage *= _get_type_multiplier(move_type, defender_stub)
		var actual = _to_damage_value(base_damage)

		results.append({
			"name": test_case["name"],
			"expected": expected,
			"actual": actual,
			"pass": actual == expected,
		})

	return results
