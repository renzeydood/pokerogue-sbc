extends BattlePhase
class_name EncounterTransitionSeedLoadPhase

var _battle = null
var _context := {}
var _fainted_species_id := ""
var _active_turn_token := -1

func _init(battle, context: Dictionary, fainted_species_id: String, active_turn_token: int, _include_fainted_text: bool) -> void:
	phase_name = "EncounterTransitionSeedLoadPhase"
	_battle = battle
	_context = context
	_fainted_species_id = fainted_species_id
	_active_turn_token = active_turn_token

func _on_start() -> void:
	if _battle == null:
		complete()
		return
	if bool(_context.get("aborted", false)):
		if _battle.has_method("_log_transition_checkpoint"):
			_battle._log_transition_checkpoint("phase.seed_load.skipped_aborted")
		complete()
		return

	if _battle.has_method("_log_transition_checkpoint"):
		_battle._log_transition_checkpoint("phase.seed_load.start", {
			"fainted_species_id": _fainted_species_id,
			"active_turn_token": _active_turn_token,
		})

	var transition_state = _battle._advance_to_next_enemy_seed_and_load_phase_state(_fainted_species_id, _active_turn_token)
	if transition_state is GDScriptFunctionState:
		transition_state = yield(transition_state, "completed")

	if typeof(transition_state) != TYPE_DICTIONARY:
		transition_state = {
			"ok": false,
			"cancelled": false,
			"early_return": false,
		}

	_context["transition_state"] = transition_state
	if _battle.has_method("_log_transition_checkpoint"):
		_battle._log_transition_checkpoint("phase.seed_load.complete", {
			"ok": bool(transition_state.get("ok", false)),
			"cancelled": bool(transition_state.get("cancelled", false)),
		})

	complete()
