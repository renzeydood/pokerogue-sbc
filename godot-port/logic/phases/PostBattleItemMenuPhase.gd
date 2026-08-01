extends BattlePhase

var _battle = null
var _context := {}
var _active_turn_token := -1

func _init(battle, context: Dictionary, active_turn_token: int) -> void:
	phase_name = "PostBattleItemMenuPhase"
	_battle = battle
	_context = context
	_active_turn_token = active_turn_token

func _on_start() -> void:
	if _battle == null:
		var _completed = complete()
		return

	if bool(_context.get("aborted", false)):
		if _battle.has_method("_log_transition_checkpoint"):
			_battle._log_transition_checkpoint("phase.item_menu.skipped_aborted")
		var _completed = complete()
		return

	if _battle.has_method("_log_transition_checkpoint"):
		_battle._log_transition_checkpoint("phase.item_menu.start", {
			"active_turn_token": _active_turn_token,
		})

	var menu_result = _battle._run_post_battle_item_menu_phase_state(_context, _active_turn_token)
	if menu_result is GDScriptFunctionState:
		menu_result = yield(menu_result, "completed")
	if typeof(menu_result) == TYPE_DICTIONARY:
		_context["post_battle_item_menu"] = menu_result
		if bool(menu_result.get("aborted", false)):
			_context["aborted"] = true

	if _battle.has_method("_log_transition_checkpoint"):
		var item_result = _context.get("post_battle_item_menu", {})
		_battle._log_transition_checkpoint("phase.item_menu.complete", {
			"action": String(item_result.get("action", "")),
			"used_item_id": String(item_result.get("item_id", "")),
		})

	var _completed = complete()