extends BattlePhase
class_name OpeningResolvePhase

var _battle = null
var _context := {}

func _init(battle, context: Dictionary) -> void:
	phase_name = "OpeningResolvePhase"
	_battle = battle
	_context = context

func _on_start() -> void:
	if _battle == null:
		complete()
		return

	var opening_state = _context.get("opening_state", {})
	if typeof(opening_state) != TYPE_DICTIONARY:
		if _battle.has_method("_log_opening_checkpoint"):
			_battle._log_opening_checkpoint("phase.resolve.skipped_invalid_state")
		complete()
		return

	if _battle.has_method("_log_opening_checkpoint"):
		_battle._log_opening_checkpoint("phase.resolve.start")

	var resolve_result = _battle._run_opening_resolve_phase_state(opening_state)
	if resolve_result is GDScriptFunctionState:
		yield(resolve_result, "completed")

	if _battle.has_method("_log_opening_checkpoint"):
		_battle._log_opening_checkpoint("phase.resolve.complete")

	complete()
