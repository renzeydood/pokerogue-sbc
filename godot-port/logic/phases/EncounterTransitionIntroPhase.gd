extends BattlePhase
class_name EncounterTransitionIntroPhase

var _battle = null
var _context := {}
var _fainted_species_id := ""
var _active_turn_token := -1
var _include_fainted_text := true

func _init(battle, context: Dictionary, fainted_species_id: String, active_turn_token: int, include_fainted_text: bool) -> void:
	phase_name = "EncounterTransitionIntroPhase"
	_battle = battle
	_context = context
	_fainted_species_id = fainted_species_id
	_active_turn_token = active_turn_token
	_include_fainted_text = include_fainted_text

func _on_start() -> void:
	if _battle == null:
		complete()
		return

	if _include_fainted_text and not _fainted_species_id.empty():
		_battle.set_battle_text("%s fainted!" % _fainted_species_id)

	var delay_sec = float(_battle.enemy_switch_delay_sec)
	if delay_sec > 0.0:
		yield(_battle.get_tree().create_timer(delay_sec), "timeout")
		if _active_turn_token != -1 and _active_turn_token != int(_battle.turn_token):
			_context["aborted"] = true

	complete()
