extends BattlePhase
class_name TurnForcedSwitchPromptPhase

var _battle = null
var _context := {}
var _active_turn_token := -1

func _init(battle, context: Dictionary, active_turn_token: int) -> void:
	phase_name = "TurnForcedSwitchPromptPhase"
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
			_battle._log_turn_checkpoint("phase.forced_switch.skipped_cancelled")
		return complete()

	if not bool(turn_state.get("forced_switch_required", false)):
		if _battle.has_method("_log_turn_checkpoint"):
			_battle._log_turn_checkpoint("phase.forced_switch.skipped")
		return complete()

	if _battle.has_method("_log_turn_checkpoint"):
		_battle._log_turn_checkpoint("phase.forced_switch.start")

	var switch_result = _battle._run_turn_forced_switch_prompt_phase_state(turn_state, _active_turn_token)
	if switch_result is GDScriptFunctionState:
		switch_result = yield(switch_result, "completed")
	if typeof(switch_result) == TYPE_DICTIONARY:
		turn_state = switch_result
	_context["turn_state"] = turn_state

	if _battle.has_method("_log_turn_checkpoint"):
		_battle._log_turn_checkpoint("phase.forced_switch.complete", {
			"player_defeat": bool(turn_state.get("player_defeat", false)),
			"forced_switch_completed": bool(turn_state.get("forced_switch_completed", false)),
			"cancelled": bool(turn_state.get("cancelled", false)),
		})

	return complete()