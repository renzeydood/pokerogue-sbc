extends BattlePhase
class_name TurnPlayerMovePhase

var _battle = null
var _context := {}
var _active_turn_token := -1

func _init(battle, context: Dictionary, active_turn_token: int) -> void:
	phase_name = "TurnPlayerMovePhase"
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

	if bool(turn_state.get("cancelled", false)) or bool(turn_state.get("battle_error", false)):
		if _battle.has_method("_log_turn_checkpoint"):
			_battle._log_turn_checkpoint("phase.player.skipped")
		complete()
		return

	if _battle.has_method("_log_turn_checkpoint"):
		_battle._log_turn_checkpoint("phase.player.start")

	var player_result = _battle._run_turn_player_move_phase_state(turn_state, _active_turn_token)
	if player_result is GDScriptFunctionState:
		player_result = yield(player_result, "completed")
	if typeof(player_result) == TYPE_DICTIONARY:
		turn_state = player_result
	_context["turn_state"] = turn_state

	if _battle.has_method("_log_turn_checkpoint"):
		_battle._log_turn_checkpoint("phase.player.complete", {
			"cancelled": bool(turn_state.get("cancelled", false)),
			"enemy_fainted": bool(turn_state.get("enemy_fainted", false)),
			"enemy_has_move": bool(turn_state.get("enemy_has_move", true)),
			"terminal": bool(turn_state.get("terminal", false)),
		})

	complete()
