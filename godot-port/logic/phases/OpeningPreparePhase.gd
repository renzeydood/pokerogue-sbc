extends BattlePhase
class_name OpeningPreparePhase

var _battle = null
var _context := {}

func _init(battle, context: Dictionary) -> void:
	phase_name = "OpeningPreparePhase"
	_battle = battle
	_context = context

func _on_start() -> void:
	if _battle == null:
		complete()
		return

	if _battle.has_method("_log_opening_checkpoint"):
		_battle._log_opening_checkpoint("phase.prepare.start")

	var opening_state = _battle._prepare_opening_phase_state()
	if typeof(opening_state) != TYPE_DICTIONARY:
		opening_state = {
			"use_trainer_intro": false,
			"use_player_trainer_intro": false,
		}
	_context["opening_state"] = opening_state

	if _battle.has_method("_log_opening_checkpoint"):
		_battle._log_opening_checkpoint("phase.prepare.complete", opening_state)

	complete()
