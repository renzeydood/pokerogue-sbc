extends BattlePhase
class_name EncounterTransitionResolvePhase

var _battle = null
var _context := {}
var _fainted_species_id := ""
var _active_turn_token := -1
var _include_fainted_text := true

func _init(battle, context: Dictionary, fainted_species_id: String, active_turn_token: int, include_fainted_text: bool) -> void:
	phase_name = "EncounterTransitionResolvePhase"
	_battle = battle
	_context = context
	_fainted_species_id = fainted_species_id
	_active_turn_token = active_turn_token
	_include_fainted_text = include_fainted_text

func _on_start() -> void:
	if _battle == null:
		complete()
		return

	if bool(_context.get("aborted", false)):
		complete()
		return

	var resolve_flow = _battle._advance_to_next_enemy_resolve_phase(
		_fainted_species_id,
		_active_turn_token,
		_include_fainted_text
	)
	if resolve_flow is GDScriptFunctionState:
		yield(resolve_flow, "completed")

	complete()
