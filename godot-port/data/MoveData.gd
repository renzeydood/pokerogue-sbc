extends Reference

const CATEGORY_PHYSICAL := "physical"
const CATEGORY_SPECIAL := "special"
const CATEGORY_STATUS := "status"

var move_id: String
var power: int
var move_type: String
var category: String
var max_pp: int
var current_pp: int

func _init(p_move_id: String, p_power: int, p_move_type: String, p_category: String, p_max_pp: int = -1) -> void:
	move_id = p_move_id
	power = p_power
	move_type = p_move_type
	category = p_category
	max_pp = int(p_max_pp)
	if max_pp < 0:
		current_pp = -1
	else:
		current_pp = max_pp

func has_pp() -> bool:
	if max_pp < 0:
		return true
	return current_pp > 0

func consume_pp(amount: int = 1) -> void:
	if max_pp < 0:
		return
	current_pp = int(max(0, current_pp - max(0, amount)))

func restore_pp_full() -> void:
	if max_pp < 0:
		current_pp = -1
		return
	current_pp = max_pp

func set_current_pp(value: int) -> void:
	if max_pp < 0:
		current_pp = -1
		return
	current_pp = int(clamp(value, 0, max_pp))
