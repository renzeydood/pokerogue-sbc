extends BattlePhase
class_name CaptureSequencePhase

var _battle = null
var _context := {}
var _active_turn_token := -1

func _init(battle, context: Dictionary, active_turn_token: int) -> void:
	phase_name = "CaptureSequencePhase"
	_battle = battle
	_context = context
	_active_turn_token = active_turn_token

func _on_start() -> void:
	if _battle == null:
		var _completed = complete()
		return

	var capture_state = _context.get("capture_state", {})
	if typeof(capture_state) != TYPE_DICTIONARY:
		capture_state = {}

	if bool(capture_state.get("cancelled", false)):
		if _battle.has_method("_log_capture_checkpoint"):
			_battle._log_capture_checkpoint("phase.sequence.skipped_cancelled")
		var _completed = complete()
		return

	if _battle.has_method("_log_capture_checkpoint"):
		_battle._log_capture_checkpoint("phase.sequence.start")

	var sequence_result = _battle._run_capture_sequence_phase_state(capture_state, _active_turn_token)
	if sequence_result is GDScriptFunctionState:
		sequence_result = yield(sequence_result, "completed")
	if typeof(sequence_result) == TYPE_DICTIONARY:
		capture_state = sequence_result
	_context["capture_state"] = capture_state

	if _battle.has_method("_log_capture_checkpoint"):
		_battle._log_capture_checkpoint("phase.sequence.complete", {
			"cancelled": bool(capture_state.get("cancelled", false)),
			"capture_success": bool(capture_state.get("capture_success", false)),
			"shake_successes": int(capture_state.get("shake_successes", 0)),
		})

	var _completed = complete()
