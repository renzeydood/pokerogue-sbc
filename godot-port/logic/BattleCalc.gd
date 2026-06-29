extends Reference
class_name BattleCalc

# BATTLE-03B scope: neutral core damage only.
# Intentionally deferred to later tickets: STAB, type multipliers,
# criticals, status/burn, weather, screens, abilities, and items.

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

	return _to_damage_value(base_damage)

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
			"name": "Charmander Ember (neutral core) vs Bulbasaur",
			"attacker_level": 5,
			"attacker_atk": 52,
			"move_power": 40,
			"defender_def": 49,
			"expected": 5,
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

		var level_multiplier = (2.0 * float(level)) / 5.0 + 2.0
		var base_damage = (level_multiplier * float(power) * float(atk) / float(defense)) / 50.0 + 2.0
		var actual = _to_damage_value(base_damage)

		results.append({
			"name": test_case["name"],
			"expected": expected,
			"actual": actual,
			"pass": actual == expected,
		})

	return results
