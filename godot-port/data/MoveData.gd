extends Reference
class_name MoveData

const CATEGORY_PHYSICAL := "physical"
const CATEGORY_SPECIAL := "special"
const CATEGORY_STATUS := "status"

var move_id: String
var power: int
var move_type: String
var category: String

func _init(p_move_id: String, p_power: int, p_move_type: String, p_category: String) -> void:
	move_id = p_move_id
	power = p_power
	move_type = p_move_type
	category = p_category
