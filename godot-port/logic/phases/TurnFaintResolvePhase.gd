extends BattlePhase
class_name TurnFaintResolvePhase

var _battle = null
var _context := {}
var _active_turn_token := -1

func _init(battle, context: Dictionary, active_turn_token: int) -> void:
	phase_name = "TurnFaintResolvePhase"
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
			_battle._log_turn_checkpoint("phase.faint.skipped_cancelled")
		complete()
		return

	if not bool(turn_state.get("enemy_fainted", false)) and not bool(turn_state.get("player_fainted", false)):
		if _battle.has_method("_log_turn_checkpoint"):
			_battle._log_turn_checkpoint("phase.faint.skipped")
		complete()
		return

	if _battle.has_method("_log_turn_checkpoint"):
		_battle._log_turn_checkpoint("phase.faint.start", {
			"enemy_fainted": bool(turn_state.get("enemy_fainted", false)),
			"player_fainted": bool(turn_state.get("player_fainted", false)),
		})

	var faint_result = _battle._run_turn_faint_resolve_phase_state(turn_state, _active_turn_token)
	if faint_result is GDScriptFunctionState:
		faint_result = yield(faint_result, "completed")
	if typeof(faint_result) == TYPE_DICTIONARY:
		turn_state = faint_result
	_context["turn_state"] = turn_state

	if _battle.has_method("_log_turn_checkpoint"):
		_battle._log_turn_checkpoint("phase.faint.complete", {
			"cancelled": bool(turn_state.get("cancelled", false)),
		})

	complete()
