extends BattlePhase
class_name TurnGameOverPhase

var _battle = null
var _context := {}
var _active_turn_token := -1

func _init(battle, context: Dictionary, active_turn_token: int) -> void:
	phase_name = "TurnGameOverPhase"
	_battle = battle
	_context = context
	_active_turn_token = active_turn_token

func _on_start() -> void:
	if _battle == null:
		return complete()

	var turn_state = _context.get("turn_state", {})
	if typeof(turn_state) != TYPE_DICTIONARY:
		turn_state = {}

	if bool(turn_state.get("cancelled", false)):
		if _battle.has_method("_log_turn_checkpoint"):
			_battle._log_turn_checkpoint("phase.game_over.skipped_cancelled")
		return complete()

	if not bool(turn_state.get("player_defeat", false)):
		if _battle.has_method("_log_turn_checkpoint"):
			_battle._log_turn_checkpoint("phase.game_over.skipped")
		return complete()

	if _battle.has_method("_log_turn_checkpoint"):
		_battle._log_turn_checkpoint("phase.game_over.start")

	var game_over_result = _battle._run_turn_game_over_phase_state(turn_state, _active_turn_token)
	if game_over_result is GDScriptFunctionState:
		game_over_result = yield(game_over_result, "completed")
	if typeof(game_over_result) == TYPE_DICTIONARY:
		turn_state = game_over_result
	_context["turn_state"] = turn_state

	if _battle.has_method("_log_turn_checkpoint"):
		_battle._log_turn_checkpoint("phase.game_over.complete", {
			"cancelled": bool(turn_state.get("cancelled", false)),
			"player_defeat": bool(turn_state.get("player_defeat", false)),
		})

	return complete()