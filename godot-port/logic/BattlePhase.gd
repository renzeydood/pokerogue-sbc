extends Reference
class_name BattlePhase

var phase_name := "BattlePhase"

var _runner = null
var _is_completed := false

func begin(runner) -> void:
	_runner = runner
	_is_completed = false
	_on_start()

func _on_start() -> void:
	complete()

func complete() -> bool:
	if _runner == null:
		return false
	return _runner._on_phase_completion_requested(self)

func is_completed() -> bool:
	return _is_completed

func _mark_completed() -> void:
	_is_completed = true
