extends BattlePhase
class_name BiomeTransitionPartyRestorePhase

var _battle = null
var _context := {}
var _active_turn_token := -1

func _init(battle, context: Dictionary, active_turn_token: int) -> void:
	phase_name = "BiomeTransitionPartyRestorePhase"
	_battle = battle
	_context = context
	_active_turn_token = active_turn_token

func _on_start() -> void:
	if _battle == null:
		var _completed = complete()
		return
	if bool(_context.get("aborted", false)):
		if _battle.has_method("_log_transition_checkpoint"):
			_battle._log_transition_checkpoint("phase.biome_restore.skipped_aborted")
		var _completed = complete()
		return

	var transition_state = _context.get("transition_state", {})
	if typeof(transition_state) != TYPE_DICTIONARY:
		if _battle.has_method("_log_transition_checkpoint"):
			_battle._log_transition_checkpoint("phase.biome_restore.skipped_invalid_state")
		var _completed = complete()
		return

	if bool(transition_state.get("cancelled", false)) or not bool(transition_state.get("ok", false)):
		if _battle.has_method("_log_transition_checkpoint"):
			_battle._log_transition_checkpoint("phase.biome_restore.skipped_not_ready")
		var _completed = complete()
		return

	if _battle.has_method("_log_transition_checkpoint"):
		_battle._log_transition_checkpoint("phase.biome_restore.start")

	var restore_result = _battle._run_biome_transition_party_restore_phase_state(transition_state, _active_turn_token)
	if restore_result is GDScriptFunctionState:
		restore_result = yield(restore_result, "completed")

	_context["transition_state"] = transition_state
	if _battle.has_method("_log_transition_checkpoint"):
		_battle._log_transition_checkpoint("phase.biome_restore.complete", {
			"cancelled": bool(transition_state.get("cancelled", false)),
			"biome_changed": bool(transition_state.get("biome_changed", false)),
			"biome_transition_recalled": bool(transition_state.get("biome_transition_recalled", false)),
		})

	var _completed = complete()