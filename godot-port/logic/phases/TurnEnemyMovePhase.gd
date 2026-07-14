extends BattlePhase
class_name TurnEnemyMovePhase

var _battle = null
var _context := {}
var _active_turn_token := -1

func _init(battle, context: Dictionary, active_turn_token: int) -> void:
	phase_name = "TurnEnemyMovePhase"
	_battle = battle
	_context = context
	_active_turn_token = active_turn_token

func _on_start() -> void:
	if _battle == null:
		complete()
		return

	var turn_state = _context.get("turn_state", {})
	if typeof(turn_state) != TYPE_DICTIONARY:
		turn_state = {}

	if bool(turn_state.get("cancelled", false)):
		if _battle.has_method("_log_turn_checkpoint"):
			_battle._log_turn_checkpoint("phase.enemy.skipped_cancelled")
		complete()
		return

	if bool(turn_state.get("enemy_fainted", false)):
		if _battle.has_method("_log_turn_checkpoint"):
			_battle._log_turn_checkpoint("phase.enemy.skipped")
		complete()
		return

	if not bool(turn_state.get("enemy_has_move", true)):
		var defender = turn_state.get("defender", null)
		var defender_name = "Enemy"
		if defender != null:
			defender_name = String(defender.species_id)
		if _battle.has_method("set_battle_text"):
			_battle.set_battle_text("%s has no move." % defender_name)
		var hold_sec = max(0.0, float(_battle.turn_step_delay_sec))
		if hold_sec > 0.0:
			yield(_battle.get_tree().create_timer(hold_sec), "timeout")
		if _battle.has_method("_is_turn_token_cancelled") and _battle._is_turn_token_cancelled(_active_turn_token):
			turn_state["cancelled"] = true
			_context["turn_state"] = turn_state
		if _battle.has_method("_log_turn_checkpoint"):
			_battle._log_turn_checkpoint("phase.enemy.skipped_no_move")
		complete()
		return

	if _battle.has_method("_log_turn_checkpoint"):
		_battle._log_turn_checkpoint("phase.enemy.start")

	var enemy_result = _battle._run_turn_enemy_move_phase_state(turn_state, _active_turn_token)
	if enemy_result is GDScriptFunctionState:
		enemy_result = yield(enemy_result, "completed")
	if typeof(enemy_result) == TYPE_DICTIONARY:
		turn_state = enemy_result
	_context["turn_state"] = turn_state

	if _battle.has_method("_log_turn_checkpoint"):
		_battle._log_turn_checkpoint("phase.enemy.complete", {
			"cancelled": bool(turn_state.get("cancelled", false)),
			"player_fainted": bool(turn_state.get("player_fainted", false)),
			"terminal": bool(turn_state.get("terminal", false)),
		})

	complete()
