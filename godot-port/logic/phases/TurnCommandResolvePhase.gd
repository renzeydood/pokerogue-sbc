extends BattlePhase
class_name TurnCommandResolvePhase

var _battle = null
var _context := {}
var _active_turn_token := -1

func _init(battle, context: Dictionary, active_turn_token: int) -> void:
	phase_name = "TurnCommandResolvePhase"
	_battle = battle
	_context = context
	_active_turn_token = active_turn_token

func _on_start() -> void:
	if _battle == null:
		complete()
		return

	if _battle.has_method("_log_turn_checkpoint"):
		_battle._log_turn_checkpoint("phase.command.start", {
			"active_turn_token": _active_turn_token,
		})

	var turn_state = _context.get("turn_state", {})
	if typeof(turn_state) != TYPE_DICTIONARY:
		turn_state = {}

	turn_state = _battle._run_turn_command_resolve_phase_state(turn_state, _active_turn_token)
	_context["turn_state"] = turn_state

	if _battle.has_method("_log_turn_checkpoint"):
		_battle._log_turn_checkpoint("phase.command.complete", {
			"cancelled": bool(turn_state.get("cancelled", false)),
			"terminal": bool(turn_state.get("terminal", false)),
			"battle_error": bool(turn_state.get("battle_error", false)),
		})

	complete()
