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

var _active_phase: BattlePhase = null
var _is_running := false
var _is_dispatching := false
var _allow_completion := false

func push_phase(phase: BattlePhase) -> void:
	if phase == null:
		return
	_push_queue.append(phase)
	_try_dispatch()

func unshift_phase(phase: BattlePhase) -> void:
	if phase == null:
		return
	_immediate_queue.append(phase)
	_try_dispatch()

func defer_phase(phase: BattlePhase) -> void:
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

func _next_phase() -> BattlePhase:
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

func _on_phase_completion_requested(phase: BattlePhase) -> bool:
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

class _SelfTestPhase extends BattlePhaseType:
	var _label := ""
	var _log := []
	var _runner_ref: BattlePhaseRunner = null
	var _op := ""
	var _enqueue_phase: BattlePhase = null

	func _init(label: String, log: Array, runner_ref: BattlePhaseRunner, op: String = "", enqueue_phase: BattlePhase = null) -> void:
		phase_name = label
		_label = label
		_log = log
		_runner_ref = runner_ref
		_op = op
		_enqueue_phase = enqueue_phase

	func _on_start() -> void:
		_log.append("start:" + _label)
		if _op == "unshift" and _enqueue_phase != null:
			_runner_ref.unshift_phase(_enqueue_phase)
		elif _op == "defer" and _enqueue_phase != null:
			_runner_ref.defer_phase(_enqueue_phase)
		complete()

func run_deterministic_self_test() -> Dictionary:
	clear()
	var log := []
	var deferred = _SelfTestPhase.new("Deferred", log, self)
	var child = _SelfTestPhase.new("Child", log, self)
	var root = _SelfTestPhase.new("Root", log, self, "unshift", child)
	var add_deferred = _SelfTestPhase.new("AddDeferred", log, self, "defer", deferred)
	var tail = _SelfTestPhase.new("Tail", log, self)

	push_phase(root)
	push_phase(add_deferred)
	push_phase(tail)

	return {
		"ok": log == ["start:Root", "start:Child", "start:AddDeferred", "start:Deferred", "start:Tail"],
		"execution_log": log,
		"remaining": queue_sizes(),
	}
