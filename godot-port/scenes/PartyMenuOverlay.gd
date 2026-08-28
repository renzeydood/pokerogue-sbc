tool
extends Control

signal close_requested
signal switch_slot_requested
signal pokedex_entry_requested
signal apply_slot_requested
signal apply_move_slot_requested

enum { MODE_FIELD = 0, MODE_ITEM_TARGET = 1, MODE_ITEM_MOVE_TARGET = 2 }

export(int) var slot_count := 6
export(bool) var editor_preview_enabled := true
export(bool) var use_runtime_layout_overrides := false
export(float) var ui_scale := 2.0
export(float) var action_menu_horizontal_gap_px := 0.0
export(float) var slot_list_margin_left := -32.0
export(float) var slot_list_margin_top := 16.0
export(float) var slot_list_margin_right := 0.0
export(float) var slot_list_margin_bottom := 16.0
export(int) var columns_separation := 14
export(int) var left_column_separation := 6
export(int) var right_column_separation := 10
export(Vector2) var active_slot_size := Vector2(110, 49)
export(Vector2) var side_slot_size := Vector2(175, 24)
export(float) var icon_bob_interval_sec := 0.2
export(float) var action_menu_vertical_padding_px := 4.0

const PARTY_SLOT_TEXTURE_PATH := "res://godot-minimal-assets/assets/images/ui/party_slot.png"
const PARTY_SLOT_ATLAS_PATH := "res://godot-minimal-assets/assets/images/ui/party_slot.json"
const PARTY_SLOT_NORMAL_FRAME := "party_slot"
const PARTY_SLOT_SELECTED_FRAME := "party_slot_sel"
const PARTY_SLOT_FAINT_FRAME := "party_slot_fnt"
const PARTY_SLOT_FAINT_SELECTED_FRAME := "party_slot_fnt_sel"
const PARTY_SLOT_MAIN_TEXTURE_PATH := "res://godot-minimal-assets/assets/images/ui/party_slot_main.png"
const PARTY_SLOT_MAIN_ATLAS_PATH := "res://godot-minimal-assets/assets/images/ui/party_slot_main.json"
const PARTY_SLOT_MAIN_NORMAL_FRAME := "party_slot_main"
const PARTY_SLOT_MAIN_SELECTED_FRAME := "party_slot_main_sel"
const PARTY_SLOT_MAIN_FAINT_FRAME := "party_slot_main_fnt"
const PARTY_SLOT_MAIN_FAINT_SELECTED_FRAME := "party_slot_main_fnt_sel"
const PARTY_CANCEL_TEXTURE_PATH := "res://godot-minimal-assets/assets/images/ui/party_cancel.png"
const PARTY_CANCEL_ATLAS_PATH := "res://godot-minimal-assets/assets/images/ui/party_cancel.json"
const PARTY_CANCEL_NORMAL_FRAME := "party_cancel"
const PARTY_CANCEL_SELECTED_FRAME := "party_cancel_sel"
const PARTY_SLOT_HP_OVERLAY_TEXTURE_PATH := "res://godot-minimal-assets/assets/images/ui/party_slot_hp_overlay.png"
const PARTY_SLOT_HP_OVERLAY_ATLAS_PATH := "res://godot-minimal-assets/assets/images/ui/party_slot_hp_overlay.json"
const PARTY_SLOT_HP_OVERLAY_HIGH_FRAME := "high"
const PARTY_SLOT_HP_OVERLAY_MEDIUM_FRAME := "medium"
const PARTY_SLOT_HP_OVERLAY_LOW_FRAME := "low"
const ICON_TEXTURE_TEMPLATE := "res://godot-minimal-assets/assets/images/pokemon_icons_%d.png"
const ICON_ATLAS_TEMPLATE := "res://godot-minimal-assets/assets/images/pokemon_icons_%d.json"
const ICON_FALLBACK_ATLAS_INDEX := 0
const ICON_DEFAULT_FRAME := "unknown"
const ICON_BOB_MODE_NONE := 0
const ICON_BOB_MODE_PASSIVE := 1
const ICON_BOB_MODE_ACTIVE := 2
const CatalogDataLoader = preload("res://logic/CatalogDataLoader.gd")
const EditorPreviewSync = preload("res://logic/EditorPreviewSync.gd")

onready var ui_scale_root = $Backdrop/Panel/UiScaleRoot
onready var slot_list = $Backdrop/Panel/UiScaleRoot/SlotList
onready var left_slots_anchor = slot_list.get_node_or_null("LeftSlotsAnchor") if slot_list != null else null
onready var right_slots_anchor = slot_list.get_node_or_null("RightSlotsAnchor") if slot_list != null else null
onready var footer_container = $Backdrop/Panel/UiScaleRoot/Footer
onready var footer_text_label = $Backdrop/Panel/UiScaleRoot/Footer/MessageWindowSprite/MessageMargin/FooterTextLabel
onready var back_button = $Backdrop/Panel/UiScaleRoot/Footer/Control/BackButton
onready var cancel_sprite = $Backdrop/Panel/UiScaleRoot/Footer/Control/BackButtonSprite
onready var action_menu_container = $Backdrop/Panel/UiScaleRoot/ActionMenuContainer
onready var message_action_window_sprite = $Backdrop/Panel/UiScaleRoot/ActionMenuContainer/MessageActionWindowSprite
onready var message_action_margin = $Backdrop/Panel/UiScaleRoot/ActionMenuContainer/MessageActionWindowSprite/MessageActionMargin
onready var action_text_label = $Backdrop/Panel/UiScaleRoot/ActionMenuContainer/MessageActionWindowSprite/MessageActionMargin/ActionTextLabel
onready var action_window_sprite = $Backdrop/Panel/UiScaleRoot/ActionMenuContainer/ActionWindowSprite
onready var action_content_margin = $Backdrop/Panel/UiScaleRoot/ActionMenuContainer/ActionWindowSprite/ActionContentMargin
onready var action_button_list = $Backdrop/Panel/UiScaleRoot/ActionMenuContainer/ActionWindowSprite/ActionContentMargin/ActionButtonList
onready var action_switch_in_button = $Backdrop/Panel/UiScaleRoot/ActionMenuContainer/ActionWindowSprite/ActionContentMargin/ActionButtonList/SwitchInButton
onready var action_apply_button = $Backdrop/Panel/UiScaleRoot/ActionMenuContainer/ActionWindowSprite/ActionContentMargin/ActionButtonList/ApplyButton
onready var action_move_buttons = [
	$Backdrop/Panel/UiScaleRoot/ActionMenuContainer/ActionWindowSprite/ActionContentMargin/ActionButtonList/Move1Button,
	$Backdrop/Panel/UiScaleRoot/ActionMenuContainer/ActionWindowSprite/ActionContentMargin/ActionButtonList/Move2Button,
	$Backdrop/Panel/UiScaleRoot/ActionMenuContainer/ActionWindowSprite/ActionContentMargin/ActionButtonList/Move3Button,
	$Backdrop/Panel/UiScaleRoot/ActionMenuContainer/ActionWindowSprite/ActionContentMargin/ActionButtonList/Move4Button,
]
onready var action_summary_button = $Backdrop/Panel/UiScaleRoot/ActionMenuContainer/ActionWindowSprite/ActionContentMargin/ActionButtonList/SummaryButton
onready var action_pokedex_button = $Backdrop/Panel/UiScaleRoot/ActionMenuContainer/ActionWindowSprite/ActionContentMargin/ActionButtonList/PokedexButton
onready var action_rename_button = $Backdrop/Panel/UiScaleRoot/ActionMenuContainer/ActionWindowSprite/ActionContentMargin/ActionButtonList/RenameButton
onready var action_cancel_button = $Backdrop/Panel/UiScaleRoot/ActionMenuContainer/ActionWindowSprite/ActionContentMargin/ActionButtonList/CancelButton

var party_members: Array = []
var active_slot_index := -1
var selected_slot_index := -1
var slot_buttons: Array = []
var slot_roots: Array = []
var slot_background_sprites: Array = []
var slot_icon_sprites: Array = []
var slot_hp_bar_sprites: Array = []
var slot_hp_overlay_sprites: Array = []
var slot_icon_anchor_positions: Array = []
var slot_icon_anchor_frame_sizes: Array = []
var slot_name_labels: Array = []
var slot_level_labels: Array = []
var slot_hp_labels: Array = []
var slot_icon_base_positions: Array = []
var _catalog_loader = null
var _icon_bob_elapsed := 0.0
var _icon_bob_toggled := false
var action_menu_visible := false
var action_menu_slot_index := -1
var menu_mode := MODE_FIELD
var menu_context: Dictionary = {}
var eligible_slot_indexes: Array = []
var _action_window_base_bottom := 0.0
var _message_action_window_base_bottom := 0.0
var _action_window_base_right := 0.0
var _action_window_base_width := 0.0
var _action_content_margin_right_padding := 0.0
var _action_content_base_width := 0.0
var _message_action_window_base_right := 0.0
var _action_message_window_gap := 0.0

func _ready():
	visible = Engine.editor_hint and editor_preview_enabled
	set_process(true)
	if use_runtime_layout_overrides:
		_apply_layout_scale_defaults()
	_setup_slot_layout()
	_setup_footer_controls()
	_setup_action_menu_controls()
	if Engine.editor_hint:
		if editor_preview_enabled:
			_apply_editor_preview_state()
		return

	visible = false
	if back_button != null and not back_button.is_connected("pressed", self, "_on_back_button_pressed"):
		back_button.connect("pressed", self, "_on_back_button_pressed")
	if back_button != null and not back_button.is_connected("focus_entered", self, "_on_back_button_focus_entered"):
		back_button.connect("focus_entered", self, "_on_back_button_focus_entered")
	if back_button != null and not back_button.is_connected("focus_exited", self, "_on_back_button_focus_exited"):
		back_button.connect("focus_exited", self, "_on_back_button_focus_exited")
	if action_switch_in_button != null and not action_switch_in_button.is_connected("pressed", self, "_on_action_switch_in_button_pressed"):
		action_switch_in_button.connect("pressed", self, "_on_action_switch_in_button_pressed")
	if action_apply_button != null and not action_apply_button.is_connected("pressed", self, "_on_action_apply_button_pressed"):
		action_apply_button.connect("pressed", self, "_on_action_apply_button_pressed")
	for move_index in range(action_move_buttons.size()):
		var move_button = action_move_buttons[move_index]
		if move_button != null and not move_button.is_connected("pressed", self, "_on_action_move_button_pressed"):
			move_button.connect("pressed", self, "_on_action_move_button_pressed", [move_index])
	if action_pokedex_button != null and not action_pokedex_button.is_connected("pressed", self, "_on_action_pokedex_button_pressed"):
		action_pokedex_button.connect("pressed", self, "_on_action_pokedex_button_pressed")
	if action_cancel_button != null and not action_cancel_button.is_connected("pressed", self, "_on_action_cancel_button_pressed"):
		action_cancel_button.connect("pressed", self, "_on_action_cancel_button_pressed")

func _apply_editor_preview_state() -> void:
	party_members = [
		{"species_id": "BULBASAUR", "level": 5, "move_ids": []},
		{"species_id": "IVYSAUR", "level": 5, "move_ids": []},
		{"species_id": "VENUSAUR", "level": 5, "move_ids": []},
		{"species_id": "CHARMANDER", "level": 5, "move_ids": []},
		{"species_id": "CHARMELEON", "level": 5, "move_ids": []},
		{"species_id": "CHARIZARD", "level": 5, "move_ids": []},
	]
	active_slot_index = 0
	selected_slot_index = 0
	_refresh_slot_buttons()
	_close_action_menu()
	_update_cancel_sprite(false)

func _apply_layout_scale_defaults() -> void:
	if ui_scale_root != null:
		ui_scale_root.rect_scale = Vector2(ui_scale, ui_scale)
	if slot_list != null:
		slot_list.margin_left = slot_list_margin_left
		slot_list.margin_top = slot_list_margin_top
		slot_list.margin_right = slot_list_margin_right
		slot_list.margin_bottom = slot_list_margin_bottom
	if left_slots_anchor != null:
		left_slots_anchor.add_constant_override("separation", left_column_separation)
	if right_slots_anchor != null:
		right_slots_anchor.add_constant_override("separation", right_column_separation)
func _process(_delta: float) -> void:
	if Engine.editor_hint:
		if not editor_preview_enabled:
			return

		EditorPreviewSync.sync_scene(
			self,
			editor_preview_enabled,
			not party_members.empty(),
			"_apply_editor_preview_state",
			"_refresh_slot_buttons",
			"_close_action_menu"
		)

	if not visible:
		_reset_icon_bob_state()
		return

	_icon_bob_elapsed += _delta
	if _icon_bob_elapsed < max(0.01, icon_bob_interval_sec):
		return

	_icon_bob_elapsed = 0.0
	_icon_bob_toggled = not _icon_bob_toggled
	_apply_icon_bob_offsets()

func open_menu(members: Array, active_index: int, mode: int = MODE_FIELD, context: Dictionary = {}) -> void:
	party_members = members.duplicate(true)
	active_slot_index = active_index
	menu_mode = mode
	menu_context = context.duplicate(true) if typeof(context) == TYPE_DICTIONARY else {}
	var raw_eligible_slots = menu_context.get("eligible_slots", null)
	eligible_slot_indexes = raw_eligible_slots.duplicate() if typeof(raw_eligible_slots) == TYPE_ARRAY else []
	selected_slot_index = _find_initial_selected_index()
	_refresh_slot_buttons()
	_close_action_menu()
	_update_cancel_sprite(false)
	_update_footer_prompt()
	visible = true
	focus_default()

func _update_footer_prompt() -> void:
	if footer_text_label == null:
		return
	footer_text_label.text = String(menu_context.get("prompt", "Choose a Pokemon."))

func _is_slot_eligible(slot_index: int) -> bool:
	if eligible_slot_indexes.empty():
		return menu_mode == MODE_FIELD
	return eligible_slot_indexes.has(slot_index)

func _get_move_options_for_slot(slot_index: int) -> Array:
	var move_options_by_slot = menu_context.get("move_options", {})
	if typeof(move_options_by_slot) != TYPE_DICTIONARY:
		return []
	var move_options = move_options_by_slot.get(slot_index, move_options_by_slot.get(String(slot_index), []))
	if typeof(move_options) != TYPE_ARRAY:
		return []
	return move_options

func close_menu() -> void:
	visible = false
	menu_mode = MODE_FIELD
	menu_context = {}
	eligible_slot_indexes = []
	_close_action_menu()
	_update_cancel_sprite(false)

func focus_default() -> void:
	if not visible:
		return

	if action_menu_visible:
		_focus_first_action_button()
		return

	if selected_slot_index >= 0 and selected_slot_index < slot_buttons.size() and not slot_buttons[selected_slot_index].disabled:
		slot_buttons[selected_slot_index].grab_focus()
		return

	if active_slot_index >= 0 and active_slot_index < slot_buttons.size() and not slot_buttons[active_slot_index].disabled:
		selected_slot_index = active_slot_index
		slot_buttons[active_slot_index].grab_focus()
		return

	for idx in range(slot_buttons.size()):
		if not slot_buttons[idx].disabled:
			selected_slot_index = idx
			slot_buttons[idx].grab_focus()
			return

	if back_button != null:
		back_button.grab_focus()

func move_focus(action_name: String) -> void:
	if not visible:
		return

	if action_menu_visible:
		_move_action_menu_focus(action_name)
		return

	if get_focus_owner() == back_button:
		if action_name == "ui_up":
			_focus_last_visible_slot()
			return
		if action_name == "ui_down":
			_focus_first_visible_slot()
		return

	if selected_slot_index < 0:
		focus_default()
		return

	if action_name == "ui_left":
		if selected_slot_index > 0:
			_focus_slot_button(0)
		return

	if action_name == "ui_right":
		if selected_slot_index == 0:
			_focus_first_right_slot()
		return

	if action_name == "ui_up":
		_select_previous_right_slot()
		return

	if action_name == "ui_down":
		_select_next_right_slot()
		return

func press_focused() -> void:
	if not visible:
		return
	var focus_owner = get_focus_owner()
	if focus_owner is Button and not focus_owner.disabled:
		focus_owner.emit_signal("pressed")

func is_overlay_focus_owner(focus_owner) -> bool:
	if focus_owner == null:
		return false
	if focus_owner == back_button:
		return true
	if _get_action_menu_buttons().has(focus_owner):
		return true
	return slot_buttons.has(focus_owner)

func handle_back_action() -> bool:
	if action_menu_visible:
		_close_action_menu()
		_focus_slot_button(selected_slot_index)
		return true
	return false

func _setup_slot_layout() -> void:
	slot_buttons.clear()
	slot_roots.clear()
	slot_background_sprites.clear()
	slot_icon_sprites.clear()
	slot_hp_bar_sprites.clear()
	slot_hp_overlay_sprites.clear()
	slot_icon_anchor_positions.clear()
	slot_icon_anchor_frame_sizes.clear()
	slot_icon_base_positions.clear()
	slot_name_labels.clear()
	slot_level_labels.clear()
	slot_hp_labels.clear()

	var left_slot = slot_list.get_node_or_null("LeftSlot") if slot_list != null else null
	_register_slot_node(left_slot)

	var right_parent = right_slots_anchor if right_slots_anchor != null else (slot_list.get_node_or_null("RightSlotsAnchor") if slot_list != null else null)

	var right_slot_nodes := []
	if right_parent != null:
		for child in right_parent.get_children():
			if child is Control and child.get_node_or_null("SlotButton") != null:
				right_slot_nodes.append(child)
	elif slot_list != null:
		for child in slot_list.get_children():
			if child is Control and String(child.name).begins_with("RightSlot") and child.get_node_or_null("SlotButton") != null:
				right_slot_nodes.append(child)

	right_slot_nodes.sort_custom(self, "_sort_nodes_by_name")
	for right_slot in right_slot_nodes:
		_register_slot_node(right_slot)

	# Respect the configured slot cap while keeping scene-authored fixed slots.
	while slot_buttons.size() > max(1, slot_count):
		slot_buttons.pop_back()
		slot_roots.pop_back()
		slot_background_sprites.pop_back()
		slot_icon_sprites.pop_back()
		slot_hp_bar_sprites.pop_back()
		slot_hp_overlay_sprites.pop_back()
		slot_icon_anchor_positions.pop_back()
		slot_icon_anchor_frame_sizes.pop_back()
		slot_icon_base_positions.pop_back()
		slot_name_labels.pop_back()
		slot_level_labels.pop_back()
		slot_hp_labels.pop_back()

func _sort_nodes_by_name(a: Node, b: Node) -> bool:
	return String(a.name) < String(b.name)

func _setup_footer_controls() -> void:
	if back_button != null:
		back_button.text = ""
	if footer_text_label != null:
		footer_text_label.text = "Choose a Pokemon."
	if cancel_sprite != null:
		cancel_sprite.centered = false
		cancel_sprite.region_enabled = true
		cancel_sprite.scale = Vector2(1, 1)
		_set_sprite_frame(cancel_sprite, PARTY_CANCEL_TEXTURE_PATH, PARTY_CANCEL_ATLAS_PATH, PARTY_CANCEL_NORMAL_FRAME)

func _setup_action_menu_controls() -> void:
	if action_menu_container != null:
		action_menu_container.visible = false
	if action_window_sprite != null:
		_action_window_base_bottom = action_window_sprite.margin_bottom
		_action_window_base_right = action_window_sprite.margin_right
		_action_window_base_width = action_window_sprite.margin_right - action_window_sprite.margin_left
	if message_action_window_sprite != null:
		_message_action_window_base_bottom = message_action_window_sprite.margin_bottom
		_message_action_window_base_right = message_action_window_sprite.margin_right
	if action_content_margin != null:
		_action_content_base_width = action_content_margin.margin_right - action_content_margin.margin_left
		_action_content_margin_right_padding = _action_window_base_width - action_content_margin.margin_right
	if action_window_sprite != null and message_action_window_sprite != null:
		_action_message_window_gap = action_window_sprite.margin_left - message_action_window_sprite.margin_right
	if action_text_label != null:
		action_text_label.text = "What to do with this Pokemon?"
	if action_apply_button != null:
		action_apply_button.text = "Apply"
		action_apply_button.visible = false
	for move_button in action_move_buttons:
		if move_button != null:
			move_button.visible = false
	if action_summary_button != null:
		action_summary_button.text = "Summary"
		action_summary_button.disabled = true
	if action_pokedex_button != null:
		action_pokedex_button.text = "Pokedex"
		action_pokedex_button.disabled = false
	if action_rename_button != null:
		action_rename_button.text = "Rename"
		action_rename_button.visible = false
		action_rename_button.disabled = true
	if action_cancel_button != null:
		action_cancel_button.text = "Cancel"
	_refresh_action_menu_layout()

func _register_slot_node(slot_node) -> void:
	if slot_node == null:
		return

	var slot_index = slot_buttons.size()
	var background = slot_node.get_node_or_null("Background")
	var icon_sprite = slot_node.get_node_or_null("PokemonIconSprite")
	var hp_bar_sprite = slot_node.get_node_or_null("HPBarSprite")
	var hp_overlay_sprite = slot_node.get_node_or_null("HPOverlaySprite")
	var button = slot_node.get_node_or_null("SlotButton")
	var name_label = slot_node.get_node_or_null("PokemonNameLabel")
	var level_label = slot_node.get_node_or_null("PokemonLevelLabel")
	var hp_label = slot_node.get_node_or_null("PokemonHPLabel")

	if button != null:
		button.focus_mode = Control.FOCUS_ALL
		button.flat = true
		button.text = ""
		if not button.is_connected("pressed", self, "_on_slot_button_pressed"):
			button.connect("pressed", self, "_on_slot_button_pressed", [slot_index])
		if not button.is_connected("focus_entered", self, "_on_slot_button_focus_entered"):
			button.connect("focus_entered", self, "_on_slot_button_focus_entered", [slot_index])

	slot_roots.append(slot_node)
	slot_background_sprites.append(background)
	slot_icon_sprites.append(icon_sprite)
	slot_hp_bar_sprites.append(hp_bar_sprite)
	slot_hp_overlay_sprites.append(hp_overlay_sprite)
	if icon_sprite != null:
		slot_icon_anchor_positions.append(icon_sprite.position)
		slot_icon_base_positions.append(icon_sprite.position)
		var anchor_frame_size = icon_sprite.region_rect.size if icon_sprite.region_enabled else Vector2.ZERO
		slot_icon_anchor_frame_sizes.append(anchor_frame_size)
	else:
		slot_icon_anchor_positions.append(Vector2.ZERO)
		slot_icon_base_positions.append(Vector2.ZERO)
		slot_icon_anchor_frame_sizes.append(Vector2.ZERO)
	slot_buttons.append(button)
	slot_name_labels.append(name_label)
	slot_level_labels.append(level_label)
	slot_hp_labels.append(hp_label)

func _refresh_slot_buttons() -> void:
	for i in range(slot_buttons.size()):
		var button = slot_buttons[i]
		var slot_root = slot_roots[i]
		var has_member = i < party_members.size() and typeof(party_members[i]) == TYPE_DICTIONARY
		if slot_root != null:
			slot_root.visible = has_member

		if has_member:
			if button != null:
				button.disabled = false
				button.text = ""
			_apply_slot_member_labels(i, party_members[i])
			_update_slot_hp_ui(i, party_members[i])
			_update_slot_icon(i, party_members[i])
			_update_slot_background(i)
		else:
			if button != null:
				button.disabled = true
				button.text = ""
			_clear_slot_member_labels(i)
			_clear_slot_hp_ui(i)
			_clear_slot_icon(i)
			_update_slot_background(i)

	_apply_icon_bob_offsets()

func _apply_slot_member_labels(slot_index: int, member: Dictionary) -> void:
	var species_id = String(member.get("species_id", "UNKNOWN"))
	var level = int(member.get("level", 1))
	var species_label = species_id if not species_id.empty() else "--"

	if slot_index < slot_name_labels.size() and slot_name_labels[slot_index] != null:
		slot_name_labels[slot_index].text = species_label
	if slot_index < slot_level_labels.size() and slot_level_labels[slot_index] != null:
		slot_level_labels[slot_index].text = "Lv.%d" % level

func _update_slot_hp_ui(slot_index: int, member: Dictionary) -> void:
	var hp_state = _get_member_hp_state(member)
	if slot_index < slot_hp_labels.size() and slot_hp_labels[slot_index] != null:
		slot_hp_labels[slot_index].text = hp_state["text"]

	if slot_index < slot_hp_overlay_sprites.size():
		var hp_overlay_sprite: Sprite = slot_hp_overlay_sprites[slot_index]
		if hp_overlay_sprite != null:
			_set_hp_overlay_sprite(hp_overlay_sprite, hp_state["ratio"])

func _clear_slot_member_labels(slot_index: int) -> void:
	if slot_index < slot_name_labels.size() and slot_name_labels[slot_index] != null:
		slot_name_labels[slot_index].text = ""
	if slot_index < slot_level_labels.size() and slot_level_labels[slot_index] != null:
		slot_level_labels[slot_index].text = ""
	if slot_index < slot_hp_labels.size() and slot_hp_labels[slot_index] != null:
		slot_hp_labels[slot_index].text = ""

func _clear_slot_hp_ui(slot_index: int) -> void:
	if slot_index < slot_hp_overlay_sprites.size():
		var hp_overlay_sprite: Sprite = slot_hp_overlay_sprites[slot_index]
		if hp_overlay_sprite != null:
			hp_overlay_sprite.visible = false

func _get_member_hp_state(member: Dictionary) -> Dictionary:
	var species_id = String(member.get("species_id", "")).strip_edges().to_upper()
	var current_hp = int(member.get("current_hp", -1))
	var max_hp = -1

	var species_entry = _get_species_entry(species_id)
	if not species_entry.empty() and species_entry.has("base_stats"):
		var base_stats = species_entry.get("base_stats", {})
		if typeof(base_stats) == TYPE_DICTIONARY:
			max_hp = int(base_stats.get("hp", -1))

	if max_hp <= 0:
		max_hp = 1
	if current_hp < 0:
		current_hp = max_hp
	current_hp = clamp(current_hp, 0, max_hp)

	var ratio := 0.0
	if max_hp > 0:
		ratio = clamp(float(current_hp) / float(max_hp), 0.0, 1.0)

	return {
		"current_hp": current_hp,
		"max_hp": max_hp,
		"ratio": ratio,
		"text": "%d/%d" % [current_hp, max_hp],
	}

func _set_hp_overlay_sprite(hp_overlay_sprite: Sprite, hp_ratio: float) -> void:
	if hp_overlay_sprite == null:
		return

	hp_overlay_sprite.centered = false
	hp_overlay_sprite.region_enabled = true

	var frame_name = PARTY_SLOT_HP_OVERLAY_LOW_FRAME
	if hp_ratio > 0.5:
		frame_name = PARTY_SLOT_HP_OVERLAY_HIGH_FRAME
	elif hp_ratio > 0.2:
		frame_name = PARTY_SLOT_HP_OVERLAY_MEDIUM_FRAME

	if not _resource_exists(PARTY_SLOT_HP_OVERLAY_TEXTURE_PATH):
		hp_overlay_sprite.visible = false
		return

	var frame_data = _parse_sprite_frame(PARTY_SLOT_HP_OVERLAY_ATLAS_PATH, frame_name)
	if frame_data == null:
		hp_overlay_sprite.visible = false
		return

	hp_overlay_sprite.texture = load(PARTY_SLOT_HP_OVERLAY_TEXTURE_PATH)
	var frame = frame_data["frame"]
	var visible_width = int(round(frame["w"] * hp_ratio))
	if hp_ratio > 0.0 and visible_width < 1:
		visible_width = 1
	hp_overlay_sprite.region_rect = Rect2(frame["x"], frame["y"], visible_width, frame["h"])
	hp_overlay_sprite.visible = true

func _update_slot_icon(slot_index: int, member: Dictionary) -> void:
	if slot_index < 0 or slot_index >= slot_icon_sprites.size():
		return

	var icon_sprite: Sprite = slot_icon_sprites[slot_index]
	if icon_sprite == null:
		return

	var species_id = String(member.get("species_id", "")).strip_edges().to_upper()
	if species_id.empty():
		_set_fallback_icon(icon_sprite)
		return

	var species_entry = _get_species_entry(species_id)
	if species_entry.empty():
		_set_fallback_icon(icon_sprite)
		return

	var dex_num = int(species_entry.get("pokedex_number", -1))
	if dex_num <= 0:
		_set_fallback_icon(icon_sprite)
		return

	var source = species_entry.get("source", {})
	var generation = int(source.get("generation", 1))
	if generation <= 0:
		generation = 1

	var icon_frame = str(dex_num)
	if not _set_icon_sprite_frame(icon_sprite, generation, icon_frame):
		_set_fallback_icon(icon_sprite)
	else:
		if slot_index > 0:
			_anchor_slot_icon_bottom_right(slot_index)

func _clear_slot_icon(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= slot_icon_sprites.size():
		return
	var icon_sprite: Sprite = slot_icon_sprites[slot_index]
	if icon_sprite == null:
		return
	if slot_index < slot_icon_base_positions.size():
		icon_sprite.position = slot_icon_base_positions[slot_index]
	icon_sprite.visible = false

func _anchor_slot_icon_bottom_right(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= slot_icon_sprites.size():
		return
	var icon_sprite: Sprite = slot_icon_sprites[slot_index]
	if icon_sprite == null:
		return

	var frame_size = Vector2.ZERO
	if icon_sprite.region_enabled:
		frame_size = icon_sprite.region_rect.size
	if frame_size == Vector2.ZERO and icon_sprite.texture != null:
		frame_size = icon_sprite.texture.get_size()

	icon_sprite.centered = false
	icon_sprite.offset = Vector2.ZERO
	if frame_size == Vector2.ZERO:
		frame_size = Vector2(21, 20)

	var anchor_position: Vector2 = slot_icon_anchor_positions[slot_index]
	var anchor_frame_size: Vector2 = slot_icon_anchor_frame_sizes[slot_index]
	if anchor_frame_size == Vector2.ZERO:
		anchor_frame_size = frame_size

	# Keep authored position as baseline; if frame size changes, grow left/up from the same right/bottom anchor.
	var right_edge = anchor_position.x + anchor_frame_size.x
	var bottom_edge = anchor_position.y + anchor_frame_size.y
	var anchored_position = Vector2(right_edge - frame_size.x, bottom_edge - frame_size.y)
	icon_sprite.position = anchored_position
	if slot_index < slot_icon_base_positions.size():
		slot_icon_base_positions[slot_index] = anchored_position

func _get_slot_icon_bob_mode(slot_index: int) -> int:
	if slot_index < 0 or slot_index >= slot_buttons.size():
		return ICON_BOB_MODE_NONE
	if slot_index >= party_members.size():
		return ICON_BOB_MODE_NONE
	if _is_slot_member_fainted(slot_index):
		return ICON_BOB_MODE_NONE
	if slot_roots[slot_index] == null or not slot_roots[slot_index].visible:
		return ICON_BOB_MODE_NONE
	if slot_buttons[slot_index] == null or slot_buttons[slot_index].disabled:
		return ICON_BOB_MODE_NONE
	if get_focus_owner() == back_button:
		return ICON_BOB_MODE_PASSIVE
	if selected_slot_index == slot_index:
		return ICON_BOB_MODE_ACTIVE
	return ICON_BOB_MODE_PASSIVE

func _get_icon_bob_delta(mode: int) -> float:
	match mode:
		ICON_BOB_MODE_ACTIVE:
			return -2.0
		ICON_BOB_MODE_PASSIVE:
			return -1.0
		_:
			return 0.0

func _apply_icon_bob_offsets() -> void:
	for i in range(slot_icon_sprites.size()):
		var icon_sprite: Sprite = slot_icon_sprites[i]
		if icon_sprite == null:
			continue
		if not icon_sprite.visible:
			continue
		if i >= slot_icon_base_positions.size():
			continue

		var base_position: Vector2 = slot_icon_base_positions[i]
		var delta_y = 0.0
		if _icon_bob_toggled:
			delta_y = _get_icon_bob_delta(_get_slot_icon_bob_mode(i))
		icon_sprite.position = Vector2(base_position.x, base_position.y + delta_y)

func _reset_icon_bob_state() -> void:
	_icon_bob_elapsed = 0.0
	_icon_bob_toggled = false
	for i in range(slot_icon_sprites.size()):
		var icon_sprite: Sprite = slot_icon_sprites[i]
		if icon_sprite == null:
			continue
		if i >= slot_icon_base_positions.size():
			continue
		icon_sprite.position = slot_icon_base_positions[i]

func _set_fallback_icon(icon_sprite: Sprite) -> void:
	var _frame_applied = _set_icon_sprite_frame(icon_sprite, ICON_FALLBACK_ATLAS_INDEX, ICON_DEFAULT_FRAME)

func _set_icon_sprite_frame(icon_sprite: Sprite, atlas_index: int, frame_name: String) -> bool:
	if icon_sprite == null:
		return false

	var texture_path = ICON_TEXTURE_TEMPLATE % atlas_index
	var atlas_path = ICON_ATLAS_TEMPLATE % atlas_index
	if not _resource_exists(texture_path):
		icon_sprite.visible = false
		return false

	var frame_data = _parse_sprite_frame(atlas_path, frame_name)
	if frame_data == null:
		icon_sprite.visible = false
		return false

	icon_sprite.centered = false
	icon_sprite.region_enabled = true
	icon_sprite.texture = load(texture_path)
	var frame = frame_data["frame"]
	icon_sprite.region_rect = Rect2(frame["x"], frame["y"], frame["w"], frame["h"])
	icon_sprite.visible = true
	return true

func _get_species_entry(species_id: String) -> Dictionary:
	if _catalog_loader == null:
		_catalog_loader = CatalogDataLoader.new()

	if _catalog_loader == null:
		return {}

	if not _catalog_loader.is_loaded() and not _catalog_loader.load_catalogs():
		return {}

	return _catalog_loader.get_species(species_id)

func _build_slot_text(slot_index: int, member: Dictionary) -> String:
	var species_id = String(member.get("species_id", "UNKNOWN"))
	var level = int(member.get("level", 1))
	var active_marker = "ACTIVE" if slot_index == active_slot_index else ""
	var selected_marker = ">" if slot_index == selected_slot_index else " "
	var species_label = species_id if species_id.length() <= 12 else species_id.substr(0, 12)
	if active_marker.empty():
		return "%s %d. %s Lv.%d" % [selected_marker, slot_index + 1, species_label, level]
	return "%s %d. %s Lv.%d %s" % [selected_marker, slot_index + 1, species_label, level, active_marker]

func _find_initial_selected_index() -> int:
	if active_slot_index >= 0 and active_slot_index < party_members.size() and active_slot_index < slot_roots.size() and slot_roots[active_slot_index].visible:
		return active_slot_index
	for i in range(min(party_members.size(), slot_roots.size())):
		if typeof(party_members[i]) == TYPE_DICTIONARY and slot_roots[i].visible:
			return i
	return -1

func _on_slot_button_pressed(slot_index: int) -> void:
	selected_slot_index = slot_index
	_refresh_slot_buttons()
	_update_cancel_sprite(false)
	_open_action_menu_for_slot(slot_index)

func _on_slot_button_focus_entered(slot_index: int) -> void:
	selected_slot_index = slot_index
	_refresh_slot_buttons()
	_update_cancel_sprite(false)

func _on_back_button_pressed() -> void:
	if action_menu_visible:
		_close_action_menu()
		_focus_slot_button(selected_slot_index)
		return
	emit_signal("close_requested")

func _on_back_button_focus_entered() -> void:
	_update_cancel_sprite(true)
	_refresh_slot_buttons()

func _on_back_button_focus_exited() -> void:
	_update_cancel_sprite(false)
	_refresh_slot_buttons()

func _select_previous_slot() -> void:
	if party_members.empty():
		return
	if selected_slot_index <= 0:
		return
	_focus_slot_button(selected_slot_index - 1)

func _select_next_slot() -> void:
	if party_members.empty():
		return
	if selected_slot_index < slot_buttons.size() - 1:
		_focus_slot_button(selected_slot_index + 1)

func _select_previous_right_slot() -> void:
	if selected_slot_index <= 0:
		if back_button != null:
			back_button.grab_focus()
		return
	if selected_slot_index == 1:
		_focus_slot_button(0)
		return
	_focus_slot_button(selected_slot_index - 1)

func _select_next_right_slot() -> void:
	if selected_slot_index == 0:
		var first_right_visible_slot_index = _find_next_visible_slot_index(1)
		if first_right_visible_slot_index >= 0:
			_focus_slot_button(first_right_visible_slot_index)
			return
	var next_visible_slot_index = _find_next_visible_slot_index(selected_slot_index + 1)
	if next_visible_slot_index >= 0:
		_focus_slot_button(next_visible_slot_index)
		return
	if back_button != null:
		back_button.grab_focus()

func _focus_first_right_slot() -> void:
	for i in range(1, slot_buttons.size()):
		if slot_roots[i] != null and slot_roots[i].visible and slot_buttons[i] != null and not slot_buttons[i].disabled:
			_focus_slot_button(i)
			return

func _focus_first_visible_slot() -> void:
	for i in range(slot_buttons.size()):
		if slot_roots[i] != null and slot_roots[i].visible and slot_buttons[i] != null and not slot_buttons[i].disabled:
			_focus_slot_button(i)
			return

func _focus_last_visible_slot() -> void:
	for i in range(slot_buttons.size() - 1, -1, -1):
		if slot_roots[i] != null and slot_roots[i].visible and slot_buttons[i] != null and not slot_buttons[i].disabled:
			_focus_slot_button(i)
			return

func _find_next_visible_slot_index(start_index: int) -> int:
	for i in range(start_index, slot_buttons.size()):
		if slot_roots[i] != null and slot_roots[i].visible and slot_buttons[i] != null and not slot_buttons[i].disabled:
			return i
	return -1

func _focus_slot_button(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= slot_buttons.size():
		return
	if slot_roots[slot_index] == null or not slot_roots[slot_index].visible:
		return
	if slot_buttons[slot_index] == null or slot_buttons[slot_index].disabled:
		return
	selected_slot_index = slot_index
	slot_buttons[slot_index].grab_focus()
	_refresh_slot_buttons()
	_update_cancel_sprite(false)

func _update_slot_background(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= slot_background_sprites.size():
		return

	var sprite_node: Sprite = slot_background_sprites[slot_index]
	if sprite_node == null:
		return

	var slot_is_selected = selected_slot_index == slot_index and get_focus_owner() != back_button
	var is_fainted = _is_slot_member_fainted(slot_index)

	if slot_index == 0:
		_set_slot_sprite(
			sprite_node,
			PARTY_SLOT_MAIN_TEXTURE_PATH,
			PARTY_SLOT_MAIN_ATLAS_PATH,
			PARTY_SLOT_MAIN_FAINT_SELECTED_FRAME if is_fainted and slot_is_selected else PARTY_SLOT_MAIN_FAINT_FRAME if is_fainted else PARTY_SLOT_MAIN_SELECTED_FRAME if slot_is_selected else PARTY_SLOT_MAIN_NORMAL_FRAME
		)
		return

	_set_slot_sprite(
		sprite_node,
		PARTY_SLOT_TEXTURE_PATH,
		PARTY_SLOT_ATLAS_PATH,
		PARTY_SLOT_FAINT_SELECTED_FRAME if is_fainted and slot_is_selected else PARTY_SLOT_FAINT_FRAME if is_fainted else PARTY_SLOT_SELECTED_FRAME if slot_is_selected else PARTY_SLOT_NORMAL_FRAME
	)

func _is_slot_member_fainted(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= party_members.size():
		return false
	var member = party_members[slot_index]
	if typeof(member) != TYPE_DICTIONARY or member.empty():
		return false
	return int(member.get("current_hp", -1)) == 0

func _open_action_menu_for_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= party_members.size():
		return
	if typeof(party_members[slot_index]) != TYPE_DICTIONARY:
		return

	action_menu_visible = true
	action_menu_slot_index = slot_index
	if footer_container != null:
		footer_container.visible = false
	if action_menu_container != null:
		action_menu_container.visible = true

	var is_item_target_mode = menu_mode == MODE_ITEM_TARGET
	var is_item_move_target_mode = menu_mode == MODE_ITEM_MOVE_TARGET
	if action_switch_in_button != null:
		var can_switch_in = menu_mode == MODE_FIELD and slot_index != active_slot_index and not _is_slot_member_fainted(slot_index)
		action_switch_in_button.visible = can_switch_in
		action_switch_in_button.disabled = not can_switch_in

	if action_apply_button != null:
		var can_apply = is_item_target_mode and _is_slot_eligible(slot_index)
		action_apply_button.visible = is_item_target_mode
		action_apply_button.disabled = not can_apply

	var move_options = _get_move_options_for_slot(slot_index) if is_item_move_target_mode else []
	for move_index in range(action_move_buttons.size()):
		var move_button = action_move_buttons[move_index]
		if move_button == null:
			continue
		var has_move = is_item_move_target_mode and move_index < move_options.size()
		move_button.visible = has_move
		move_button.disabled = not has_move
		if has_move:
			move_button.text = String(move_options[move_index])

	if action_summary_button != null:
		action_summary_button.visible = not is_item_move_target_mode
	if action_pokedex_button != null:
		action_pokedex_button.visible = not is_item_move_target_mode

	if action_text_label != null:
		action_text_label.text = "Select a move." if is_item_move_target_mode else "Do what with this Pokemon?"

	# Two deferral hops: the first lets newly-visible buttons register their minimum size,
	# the second measures content width only after that settles.
	call_deferred("_defer_refresh_action_menu_layout")
	call_deferred("_focus_first_action_button")

func _close_action_menu() -> void:
	action_menu_visible = false
	action_menu_slot_index = -1
	if action_menu_container != null:
		action_menu_container.visible = false
	if footer_container != null:
		footer_container.visible = true

func _defer_refresh_action_menu_layout() -> void:
	call_deferred("_refresh_action_menu_layout")

func _refresh_action_menu_layout() -> void:
	if action_window_sprite == null or action_content_margin == null or action_button_list == null:
		return

	if _action_window_base_bottom == 0.0:
		_action_window_base_bottom = action_window_sprite.margin_bottom

	var content_min_size = action_content_margin.get_combined_minimum_size()
	var padded_height = content_min_size.y + max(0.0, action_menu_vertical_padding_px) * 2.0
	var window_height = max(38.0, padded_height)
	action_window_sprite.rect_min_size.y = window_height
	action_window_sprite.margin_bottom = _action_window_base_bottom
	action_window_sprite.margin_top = _action_window_base_bottom - window_height

	# Grow the window (and its content box) to the left when button labels need more room.
	var content_width = max(_action_content_base_width, content_min_size.x)
	action_content_margin.margin_right = action_content_margin.margin_left + content_width
	var window_width = max(_action_window_base_width, action_content_margin.margin_left + content_width + _action_content_margin_right_padding)
	action_window_sprite.rect_min_size.x = window_width
	action_window_sprite.margin_right = _action_window_base_right
	action_window_sprite.margin_left = _action_window_base_right - window_width

	# Shrink the footer/message window so it never overlaps the widened action window.
	if message_action_window_sprite != null:
		var total_gap = _action_message_window_gap + max(0.0, action_menu_horizontal_gap_px)
		var available_message_right = action_window_sprite.margin_left - total_gap
		message_action_window_sprite.margin_right = min(_message_action_window_base_right, available_message_right)
		# Control clamps rect size up to rect_min_size on every resize, so it must shrink too or the margin change above is silently ignored.
		message_action_window_sprite.rect_min_size.x = message_action_window_sprite.margin_right - message_action_window_sprite.margin_left

func _focus_first_action_button() -> void:
	for button in _get_action_menu_buttons():
		if button == null or not button.visible or button.disabled:
			continue
		button.grab_focus()
		return

func _move_action_menu_focus(action_name: String) -> void:
	var buttons = _get_action_menu_buttons()
	if buttons.empty():
		return

	var current = get_focus_owner()
	var current_index = buttons.find(current)
	if current_index == -1:
		_focus_first_action_button()
		return

	if action_name == "ui_up" or action_name == "ui_left":
		buttons[(current_index - 1 + buttons.size()) % buttons.size()].grab_focus()
		return

	if action_name == "ui_down" or action_name == "ui_right":
		buttons[(current_index + 1) % buttons.size()].grab_focus()

func _get_action_menu_buttons() -> Array:
	var result := []
	var candidates = [action_switch_in_button, action_apply_button]
	for move_button in action_move_buttons:
		candidates.append(move_button)
	candidates.append(action_summary_button)
	candidates.append(action_pokedex_button)
	candidates.append(action_cancel_button)
	for button in candidates:
		if button == null or not button.visible or button.disabled:
			continue
		result.append(button)
	return result

func _on_action_switch_in_button_pressed() -> void:
	if action_menu_slot_index < 0:
		return
	emit_signal("switch_slot_requested", action_menu_slot_index)
	_close_action_menu()

func _on_action_apply_button_pressed() -> void:
	if action_menu_slot_index < 0 or not _is_slot_eligible(action_menu_slot_index):
		return
	var target_slot_index = action_menu_slot_index
	_close_action_menu()
	emit_signal("apply_slot_requested", target_slot_index)

func _on_action_move_button_pressed(move_index: int) -> void:
	if action_menu_slot_index < 0 or menu_mode != MODE_ITEM_MOVE_TARGET:
		return
	if move_index < 0 or move_index >= _get_move_options_for_slot(action_menu_slot_index).size():
		return
	var target_slot_index = action_menu_slot_index
	_close_action_menu()
	emit_signal("apply_move_slot_requested", target_slot_index, move_index)

func _on_action_cancel_button_pressed() -> void:
	_close_action_menu()
	_focus_slot_button(selected_slot_index)

func _on_action_pokedex_button_pressed() -> void:
	var species_id := ""
	if action_menu_slot_index >= 0 and action_menu_slot_index < party_members.size():
		var member = party_members[action_menu_slot_index]
		if typeof(member) == TYPE_DICTIONARY:
			species_id = String(member.get("species_id", "")).strip_edges().to_upper()
	emit_signal("pokedex_entry_requested", species_id)
	_close_action_menu()

func _update_cancel_sprite(is_selected: bool) -> void:
	if cancel_sprite == null:
		return
	_set_sprite_frame(cancel_sprite, PARTY_CANCEL_TEXTURE_PATH, PARTY_CANCEL_ATLAS_PATH, PARTY_CANCEL_SELECTED_FRAME if is_selected else PARTY_CANCEL_NORMAL_FRAME)

func _set_slot_sprite(sprite_node: Sprite, texture_path: String, atlas_path: String, frame_name: String) -> void:
	if sprite_node == null:
		return
	sprite_node.centered = false
	sprite_node.region_enabled = true
	_set_sprite_frame(sprite_node, texture_path, atlas_path, frame_name)

func _set_sprite_frame(sprite_node: Sprite, texture_path: String, atlas_path: String, frame_name: String) -> void:
	if sprite_node == null:
		return

	if not _resource_exists(texture_path):
		sprite_node.visible = false
		return

	var frame_data = _parse_sprite_frame(atlas_path, frame_name)
	if frame_data == null:
		sprite_node.visible = false
		return

	sprite_node.texture = load(texture_path)
	var frame = frame_data["frame"]
	sprite_node.region_rect = Rect2(frame["x"], frame["y"], frame["w"], frame["h"])
	sprite_node.visible = true

func _resource_exists(path: String) -> bool:
	if ResourceLoader.exists(path):
		return true
	var f = File.new()
	return f.file_exists(path)

func _parse_sprite_frame(json_path: String, frame_name: String):
	var frames = _parse_all_sprite_frames(json_path)
	if frames.empty():
		return null

	for frame in frames:
		if frame.has("filename") and String(frame["filename"]) == frame_name:
			return frame

	return null

func _parse_all_sprite_frames(json_path: String) -> Array:
	var f = File.new()
	if not f.file_exists(json_path):
		return []

	if f.open(json_path, File.READ) != OK:
		return []

	var json_text = f.get_as_text()
	f.close()

	var result = JSON.parse(json_text)
	if result.error != OK:
		return []

	var data = result.result
	if data == null or not data.has("textures"):
		return []

	var textures = data["textures"]
	if textures.empty():
		return []

	var frames = textures[0].get("frames", null)
	if frames == null:
		return []

	return frames
