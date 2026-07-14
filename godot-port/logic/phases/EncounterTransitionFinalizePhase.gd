extends BattlePhase
class_name EncounterTransitionFinalizePhase

var _battle = null
var _context := {}
var _fainted_species_id := ""
var _include_fainted_text := true

func _init(battle, context: Dictionary, fainted_species_id: String, _active_turn_token: int, include_fainted_text: bool) -> void:
	phase_name = "EncounterTransitionFinalizePhase"
	_battle = battle
	_context = context
	_fainted_species_id = fainted_species_id
	_include_fainted_text = include_fainted_text

func _on_start() -> void:
	if _battle == null:
		complete()
		return
	if bool(_context.get("aborted", false)):
		if _battle.has_method("_log_transition_checkpoint"):
			_battle._log_transition_checkpoint("phase.finalize.skipped_aborted")
		complete()
		return

	var transition_state = _context.get("transition_state", {})
	if typeof(transition_state) != TYPE_DICTIONARY:
		if _battle.has_method("_log_transition_checkpoint"):
			_battle._log_transition_checkpoint("phase.finalize.skipped_invalid_state")
		complete()
		return

	if bool(transition_state.get("cancelled", false)) or bool(transition_state.get("early_return", false)) or not bool(transition_state.get("ok", false)):
		if _battle.has_method("_log_transition_checkpoint"):
			_battle._log_transition_checkpoint("phase.finalize.skipped_not_ready")
		complete()
		return

	if _battle.has_method("_log_transition_checkpoint"):
		_battle._log_transition_checkpoint("phase.finalize.start")

	_battle._advance_to_next_enemy_finalize_phase_state(transition_state, _fainted_species_id, _include_fainted_text)

	if _battle.has_method("_log_transition_checkpoint"):
		_battle._log_transition_checkpoint("phase.finalize.complete")

	complete()
