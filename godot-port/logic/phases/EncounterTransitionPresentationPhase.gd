extends BattlePhase
class_name EncounterTransitionPresentationPhase

var _battle = null
var _context := {}
var _active_turn_token := -1

func _init(battle, context: Dictionary, _fainted_species_id: String, active_turn_token: int, _include_fainted_text: bool) -> void:
	phase_name = "EncounterTransitionPresentationPhase"
	_battle = battle
	_context = context
	_active_turn_token = active_turn_token

func _on_start() -> void:
	if _battle == null:
		complete()
		return
	if bool(_context.get("aborted", false)):
		if _battle.has_method("_log_transition_checkpoint"):
			_battle._log_transition_checkpoint("phase.presentation.skipped_aborted")
		complete()
		return

	var transition_state = _context.get("transition_state", {})
	if typeof(transition_state) != TYPE_DICTIONARY:
		if _battle.has_method("_log_transition_checkpoint"):
			_battle._log_transition_checkpoint("phase.presentation.skipped_invalid_state")
		complete()
		return

	if bool(transition_state.get("cancelled", false)) or not bool(transition_state.get("ok", false)):
		if _battle.has_method("_log_transition_checkpoint"):
			_battle._log_transition_checkpoint("phase.presentation.skipped_not_ready")
		complete()
		return

	if _battle.has_method("_log_transition_checkpoint"):
		_battle._log_transition_checkpoint("phase.presentation.start")

	var presentation_result = _battle._advance_to_next_enemy_run_presentation_phase_state(transition_state, _active_turn_token)
	if presentation_result is GDScriptFunctionState:
		yield(presentation_result, "completed")

	_context["transition_state"] = transition_state
	if _battle.has_method("_log_transition_checkpoint"):
		_battle._log_transition_checkpoint("phase.presentation.complete", {
			"cancelled": bool(transition_state.get("cancelled", false)),
			"early_return": bool(transition_state.get("early_return", false)),
		})

	complete()
