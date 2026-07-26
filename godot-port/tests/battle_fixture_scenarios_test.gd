extends SceneTree

func _init() -> void:
	var loader_script = load("res://logic/BattleFixtureLoader.gd")
	if loader_script == null:
		push_error("BattleFixtureLoader script is missing.")
		quit(1)
		return

	var loader = loader_script.new()
	var scenario_ids = [
		"basic-damage",
		"type-effectiveness",
		"special-attack-scaling",
		"stat-stage-reduction",
		"accuracy-check-baseline",
		"turn-priority-baseline",
	]
	for scenario_id in scenario_ids:
		var scenario = loader.load_scenario(scenario_id)
		if scenario == null:
			push_error("Scenario '%s' failed to load." % scenario_id)
			quit(1)
			return
		var battle_seed = loader.build_battle_seed_from_fixture(scenario)
		if battle_seed == null or not battle_seed.has("player") or not battle_seed.has("enemy"):
			push_error("Scenario '%s' did not build a battle seed." % scenario_id)
			quit(1)
			return
		var player = battle_seed["player"]
		var enemy = battle_seed["enemy"]
		assert(player != null)
		assert(enemy != null)
		assert(player.moves.size() > 0)
		assert(enemy.moves.size() > 0)
	print("Fixture scenarios validated: %s" % var2str(scenario_ids))
	quit(0)
