extends BattlePhase
class_name RunFinalizePhase

var _battle = null
var _context := {}
var _active_turn_token := -1

func _init(battle, context: Dictionary, active_turn_token: int) -> void:
	phase_name = "RunFinalizePhase"
	_battle = battle
	_context = context
	_active_turn_token = active_turn_token

func _on_start() -> void:
	if _battle == null:
		var _completed = complete()
		return

	var run_state = _context.get("run_state", {})
	if typeof(run_state) != TYPE_DICTIONARY:
		run_state = {}

	var result = _battle._run_run_finalize_phase_state(run_state, _active_turn_token)
	if result is GDScriptFunctionState:
		result = yield(result, "completed")
	if typeof(result) == TYPE_DICTIONARY:
		run_state = result

	_context["run_state"] = run_state
	var _completed = complete()
