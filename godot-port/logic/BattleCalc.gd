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
	var attack_stat_multiplier = _get_stat_stage_multiplier(attacker, attack_stat_name)
	var defense_stat_multiplier = _get_stat_stage_multiplier(defender, defense_stat_name)
	var effective_attack_stat = max(1, int(round(float(attack_stat) * attack_stat_multiplier)))
	var effective_defense_stat = max(1, int(round(float(defense_stat) * defense_stat_multiplier)))

	var level_multiplier = (2.0 * float(level)) / 5.0 + 2.0
	var base_damage = (level_multiplier * float(power) * float(effective_attack_stat) / float(effective_defense_stat)) / 50.0 + 2.0
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
				effective_attack_stat,
				defense_stat_name,
				effective_defense_stat,
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

static func is_status_move(move) -> bool:
	return _get_move_category(move) == MoveData.CATEGORY_STATUS

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

static func apply_move_effects(attacker, defender, move) -> Dictionary:
	if move == null:
		return {"applied": false, "messages": [], "stat_changes": {}, "failed": false}

	var effect_data = _get_effect_data(move)
	if typeof(effect_data) != TYPE_DICTIONARY or effect_data.empty():
		return {"applied": false, "messages": [], "stat_changes": {}, "failed": false}

	var stat_changes = effect_data.get("stat_changes", {})
	if typeof(stat_changes) != TYPE_DICTIONARY or stat_changes.empty():
		return {"applied": false, "messages": [], "stat_changes": {}, "failed": false}

	var target_key = String(effect_data.get("target", "defender")).strip_edges().to_lower()
	var target_pokemon = defender if target_key != "attacker" else attacker
	if target_pokemon == null:
		return {"applied": false, "messages": [], "stat_changes": {}, "failed": false}

	var applied_messages := []
	var applied_stat_changes := {}
	var any_applied := false
	var any_failed := false
	var target_name = _get_target_display_name(target_pokemon)
	for stat_name in stat_changes:
		var change_amount = int(stat_changes[stat_name])
		if change_amount == 0:
			continue
		var current_stage = 0
		if target_pokemon.has_method("get_stat_stage"):
			current_stage = int(target_pokemon.get_stat_stage(String(stat_name)))
		elif "stat_stages" in target_pokemon and typeof(target_pokemon.stat_stages) == TYPE_DICTIONARY:
			current_stage = int(target_pokemon.stat_stages.get(String(stat_name), 0))
		var next_stage = int(clamp(current_stage + change_amount, -6, 6))
		var applied_delta = next_stage - current_stage
		if target_pokemon.has_method("set_stat_stage"):
			target_pokemon.set_stat_stage(String(stat_name), next_stage)
		elif "stat_stages" in target_pokemon and typeof(target_pokemon.stat_stages) == TYPE_DICTIONARY:
			target_pokemon.stat_stages[String(stat_name)] = next_stage
		applied_stat_changes[String(stat_name)] = next_stage
		if applied_delta != 0:
			any_applied = true
			applied_messages.append(_build_stat_stage_change_message(target_name, String(stat_name), applied_delta))
		else:
			any_failed = true
			applied_messages.append(_build_stat_stage_cap_message(target_name, String(stat_name), change_amount))

	return {
		"applied": any_applied,
		"messages": applied_messages,
		"stat_changes": applied_stat_changes,
		"failed": any_failed and not any_applied,
	}

static func _get_stat_stage_multiplier(pokemon, stat_name: String) -> float:
	if pokemon == null:
		return 1.0
	var stage_value := 0
	if pokemon.has_method("get_stat_stage"):
		stage_value = int(pokemon.get_stat_stage(stat_name))
	elif "stat_stages" in pokemon and typeof(pokemon.stat_stages) == TYPE_DICTIONARY:
		stage_value = int(pokemon.stat_stages.get(String(stat_name), 0))
	if stage_value == 0:
		return 1.0
	if stage_value > 0:
		return 1.0 + (float(stage_value) / 2.0)
	return 1.0 / (1.0 + (float(abs(stage_value)) / 2.0))

static func _get_move_category(move) -> String:
	if move == null:
		return ""
	if move.has_method("get_category"):
		return String(move.get_category()).strip_edges().to_lower()
	if "category" in move:
		return String(move.category).strip_edges().to_lower()
	return ""

static func _get_effect_data(move) -> Dictionary:
	if move == null:
		return {}
	if move.has_method("get_effect_data"):
		var effect_data = move.get_effect_data()
		if typeof(effect_data) == TYPE_DICTIONARY:
			return effect_data.duplicate(true)
	if "effect_data" in move and typeof(move.effect_data) == TYPE_DICTIONARY:
		return move.effect_data.duplicate(true)
	return {}

static func _get_target_display_name(target_pokemon) -> String:
	if target_pokemon != null and "species_id" in target_pokemon:
		return String(target_pokemon.species_id).strip_edges().to_upper()
	return "The target"

static func _build_stat_stage_change_message(target_name: String, stat_name: String, applied_delta: int) -> String:
	var stat_label = _get_stat_label(stat_name)
	var magnitude = abs(int(applied_delta))
	if applied_delta > 0:
		if magnitude >= 3:
			return "%s's %s rose drastically!" % [target_name, stat_label]
		if magnitude == 2:
			return "%s's %s rose sharply!" % [target_name, stat_label]
		return "%s's %s rose!" % [target_name, stat_label]
	if magnitude >= 3:
		return "%s's %s severely fell!" % [target_name, stat_label]
	if magnitude == 2:
		return "%s's %s harshly fell!" % [target_name, stat_label]
	return "%s's %s fell!" % [target_name, stat_label]

static func _build_stat_stage_cap_message(target_name: String, stat_name: String, requested_delta: int) -> String:
	var stat_label = _get_stat_label(stat_name)
	if int(requested_delta) > 0:
		return "%s's %s won't go any higher!" % [target_name, stat_label]
	return "%s's %s won't go any lower!" % [target_name, stat_label]

static func _get_stat_label(stat_name: String) -> String:
	match String(stat_name).strip_edges().to_lower():
		"atk":
			return "Attack"
		"def":
			return "Defense"
		"sp_atk":
			return "Sp. Atk"
		"sp_def":
			return "Sp. Def"
		"spd":
			return "Speed"
		"acc":
			return "Accuracy"
		"eva":
			return "Evasion"
		_:
			return String(stat_name).strip_edges().to_upper()

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
