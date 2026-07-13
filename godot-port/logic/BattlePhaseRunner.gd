extends Reference
class_name BattlePhaseRunner

signal phase_started(phase_name)
signal phase_completed(phase_name)
signal phase_error(phase_name, message)
signal queue_idle

const BattlePhaseType = preload("res://logic/BattlePhase.gd")

var _push_queue := []
var _immediate_queue := []
var _deferred_queue := []

var _active_phase = null
var _is_running := false
var _is_dispatching := false
var _allow_completion := false

func push_phase(phase) -> void:
	if phase == null:
		return
	_push_queue.append(phase)
	_try_dispatch()

func unshift_phase(phase) -> void:
	if phase == null:
		return
	_immediate_queue.append(phase)
	_try_dispatch()

func defer_phase(phase) -> void:
	if phase == null:
		return
	_deferred_queue.append(phase)
	_try_dispatch()

func clear() -> void:
	_push_queue.clear()
	_immediate_queue.clear()
	_deferred_queue.clear()
	_active_phase = null
	_is_running = false
	_is_dispatching = false
	_allow_completion = false

func get_active_phase_name() -> String:
	return _active_phase.phase_name if _active_phase != null else ""

func is_running() -> bool:
	return _is_running

func queue_sizes() -> Dictionary:
	return {
		"push": _push_queue.size(),
		"immediate": _immediate_queue.size(),
		"deferred": _deferred_queue.size(),
	}

func _next_phase():
	if not _immediate_queue.empty():
		return _immediate_queue.pop_front()
	if not _deferred_queue.empty():
		return _deferred_queue.pop_front()
	if not _push_queue.empty():
		return _push_queue.pop_front()
	return null

func _try_dispatch() -> void:
	if _is_dispatching:
		return
	if _active_phase != null:
		return
	_is_dispatching = true
	while true:
		var next_phase = _next_phase()
		if next_phase == null:
			_is_running = false
			emit_signal("queue_idle")
			break

		if not (next_phase is BattlePhaseType):
			emit_signal("phase_error", "<invalid>", "Attempted to run non-BattlePhase value")
			continue

		_is_running = true
		_active_phase = next_phase
		_allow_completion = true
		emit_signal("phase_started", _active_phase.phase_name)
		_active_phase.begin(self)

		# Async phases will complete later and re-enter dispatch via completion callback.
		if _active_phase != null:
			break
	_is_dispatching = false

func _on_phase_completion_requested(phase) -> bool:
	if phase == null:
		return false
	if _active_phase == null:
		emit_signal("phase_error", phase.phase_name, "Completion requested with no active phase")
		return false
	if _active_phase != phase:
		emit_signal("phase_error", phase.phase_name, "Completion requested by non-active phase")
		return false
	if not _allow_completion:
		emit_signal("phase_error", phase.phase_name, "Duplicate completion requested")
		return false

	_allow_completion = false
	phase._mark_completed()
	emit_signal("phase_completed", phase.phase_name)
	_active_phase = null
	_try_dispatch()
	return true
