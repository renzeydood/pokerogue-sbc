extends BattlePhase
class_name TurnPlayerDefeatGatePhase

var _battle = null
var _context := {}
var _active_turn_token := -1

func _init(battle, context: Dictionary, active_turn_token: int) -> void:
	phase_name = "TurnPlayerDefeatGatePhase"
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
			_battle._log_turn_checkpoint("phase.defeat_gate.skipped_cancelled")
		return complete()

	if not bool(turn_state.get("player_fainted", false)):
		if _battle.has_method("_log_turn_checkpoint"):
			_battle._log_turn_checkpoint("phase.defeat_gate.skipped")
		return complete()

	if _battle.has_method("_log_turn_checkpoint"):
		_battle._log_turn_checkpoint("phase.defeat_gate.start")

	var gate_result = _battle._run_turn_player_defeat_gate_phase_state(turn_state, _active_turn_token)
	if gate_result is GDScriptFunctionState:
		gate_result = yield(gate_result, "completed")
	if typeof(gate_result) == TYPE_DICTIONARY:
		turn_state = gate_result
	_context["turn_state"] = turn_state

	if _battle.has_method("_log_turn_checkpoint"):
		_battle._log_turn_checkpoint("phase.defeat_gate.complete", {
			"player_defeat": bool(turn_state.get("player_defeat", false)),
			"forced_switch_required": bool(turn_state.get("forced_switch_required", false)),
			"cancelled": bool(turn_state.get("cancelled", false)),
		})

	return complete()