extends BattlePhase
class_name TurnEndUnlockPhase

var _battle = null
var _context := {}
var _active_turn_token := -1

func _init(battle, context: Dictionary, active_turn_token: int) -> void:
	phase_name = "TurnEndUnlockPhase"
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

	if _battle.has_method("_log_turn_checkpoint"):
		_battle._log_turn_checkpoint("phase.end.start")

	turn_state = _battle._run_turn_end_unlock_phase_state(turn_state, _active_turn_token)
	_context["turn_state"] = turn_state

	if _battle.has_method("_log_turn_checkpoint"):
		_battle._log_turn_checkpoint("phase.end.complete", {
			"cancelled": bool(turn_state.get("cancelled", false)),
		})

	complete()
