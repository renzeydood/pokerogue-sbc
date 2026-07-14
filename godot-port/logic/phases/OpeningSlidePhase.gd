extends BattlePhase
class_name OpeningSlidePhase

var _battle = null
var _context := {}

func _init(battle, context: Dictionary) -> void:
	phase_name = "OpeningSlidePhase"
	_battle = battle
	_context = context

func _on_start() -> void:
	if _battle == null:
		complete()
		return

	var opening_state = _context.get("opening_state", {})
	if typeof(opening_state) != TYPE_DICTIONARY:
		if _battle.has_method("_log_opening_checkpoint"):
			_battle._log_opening_checkpoint("phase.slide.skipped_invalid_state")
		complete()
		return

	if _battle.has_method("_log_opening_checkpoint"):
		_battle._log_opening_checkpoint("phase.slide.start")

	var slide_result = _battle._run_opening_slide_phase_state(opening_state)
	if slide_result is GDScriptFunctionState:
		yield(slide_result, "completed")

	if _battle.has_method("_log_opening_checkpoint"):
		_battle._log_opening_checkpoint("phase.slide.complete")

	complete()
