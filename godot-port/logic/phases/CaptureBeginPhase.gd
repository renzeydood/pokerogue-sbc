extends BattlePhase
class_name CaptureBeginPhase

var _battle = null
var _context := {}
var _active_turn_token := -1

func _init(battle, context: Dictionary, active_turn_token: int) -> void:
	phase_name = "CaptureBeginPhase"
	_battle = battle
	_context = context
	_active_turn_token = active_turn_token

func _on_start() -> void:
	if _battle == null:
		var _completed = complete()
		return

	if _battle.has_method("_log_capture_checkpoint"):
		_battle._log_capture_checkpoint("phase.begin.start", {
			"active_turn_token": _active_turn_token,
		})

	var capture_state = _context.get("capture_state", {})
	if typeof(capture_state) != TYPE_DICTIONARY:
		capture_state = {}
	capture_state = _battle._run_capture_begin_phase_state(capture_state, _active_turn_token)
	_context["capture_state"] = capture_state

	if _battle.has_method("_log_capture_checkpoint"):
		_battle._log_capture_checkpoint("phase.begin.complete", {
			"cancelled": bool(capture_state.get("cancelled", false)),
		})

	var _completed = complete()
