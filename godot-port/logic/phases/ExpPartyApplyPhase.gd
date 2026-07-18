extends BattlePhase
class_name ExpPartyApplyPhase

var _battle = null
var _context := {}
var _active_turn_token := -1

func _init(battle, context: Dictionary, active_turn_token: int) -> void:
	phase_name = "ExpPartyApplyPhase"
	_battle = battle
	_context = context
	_active_turn_token = active_turn_token

func _on_start() -> void:
	if _battle == null:
		var _completed = complete()
		return

	var exp_state = _context.get("exp_state", {})
	if typeof(exp_state) != TYPE_DICTIONARY:
		exp_state = {}

	var result = _battle._run_exp_party_apply_phase_state(exp_state, _active_turn_token)
	if result is GDScriptFunctionState:
		result = yield(result, "completed")
	if typeof(result) == TYPE_DICTIONARY:
		exp_state = result
	_context["exp_state"] = exp_state

	var _completed = complete()
