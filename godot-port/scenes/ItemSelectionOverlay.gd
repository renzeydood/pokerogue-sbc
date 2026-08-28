tool
extends Control

const EditorPreviewSync = preload("res://logic/EditorPreviewSync.gd")
const AtlasFrameParser = preload("res://logic/AtlasFrameParser.gd")
const POKEBALL_TEXTURE_REL := "assets/images/pb.png"
const POKEBALL_ATLAS_REL := "assets/images/pb.json"
const POKEBALL_FRAME_CLOSED := "pb"
const POKEBALL_FRAME_OPENING := "pb_opening"
const POKEBALL_FRAME_OPEN := "pb_open"
const ITEM_ATLAS_TEXTURE_PATH := "res://godot-minimal-assets/assets/images/items.png"
const ITEM_ATLAS_FRAMES_PATH := "res://godot-minimal-assets/assets/images/items.json"

signal close_requested
signal modal_opened(context)
signal overlay_closed

export(float) var ui_scale := 2.0 setget set_ui_scale
export(bool) var editor_preview_enabled := true
export(bool) var use_runtime_layout_overrides := false
export(bool) var close_on_back := true
export(String) var default_title := "Modal Template"
export(int, 0, 14) var preview_shop_item_count := 0
export(int, 0, 14) var preview_free_item_count := 0
export(float) var post_battle_item_menu_overlay_duration_sec := 0.3
export(float) var post_battle_item_menu_shop_fade_duration_sec := 0.2
export(float) var post_battle_item_menu_free_stagger_delay_sec := 0.15
export(float) var post_battle_item_menu_free_drop_height_px := 120.0
export(float) var post_battle_item_menu_free_drop_duration_sec := 0.35
export(float) var post_battle_item_menu_free_bounce_duration_sec := 0.15
export(float) var post_battle_item_menu_free_bounce_peak_px := 4.0
export(float) var post_battle_item_menu_free_reveal_stagger_delay_sec := 0.12
export(float) var post_battle_item_menu_free_reveal_duration_sec := 0.18
export(float) var post_battle_item_menu_free_scale_peak := 1.2
export(float) var post_battle_item_menu_free_pokeball_offset_x_px := 6.0
export(float) var post_battle_item_menu_free_pokeball_offset_y_px := 5.0

export(NodePath) var ui_scale_root_path = NodePath("Backdrop/Panel/UiScaleRoot")
export(NodePath) var title_label_path = NodePath("Backdrop/Panel/UiScaleRoot/ModalRoot/TitleLabel")
export(NodePath) var content_root_path = NodePath("Backdrop/Panel/UiScaleRoot/ModalRoot/ContentRoot")
export(NodePath) var footer_root_path = NodePath("Backdrop/Panel/UiScaleRoot/ModalRoot/FooterRoot")
export(NodePath) var back_button_path = NodePath("Backdrop/Panel/UiScaleRoot/ModalRoot/FooterRoot/BackButton")
export(NodePath) var skip_confirm_panel_path = NodePath("Backdrop/Panel/UiScaleRoot/ModalRoot/ActionWindowSprite")
export(NodePath) var skip_confirm_yes_button_path = NodePath("Backdrop/Panel/UiScaleRoot/ModalRoot/ActionWindowSprite/ActionContentMargin/ActionButtonList/YesButton")
export(NodePath) var skip_confirm_no_button_path = NodePath("Backdrop/Panel/UiScaleRoot/ModalRoot/ActionWindowSprite/ActionContentMargin/ActionButtonList/NoButton")
export(NodePath) var battle_text_label_path = NodePath("Backdrop/Panel/UiScaleRoot/ModalRoot/MessagePanel/MessageMargin/BattleTextLabel")
export(String) var skip_confirm_prompt_text := "Are you sure you want to skip taking an item?"

onready var ui_scale_root = get_node_or_null(ui_scale_root_path)
onready var title_label = get_node_or_null(title_label_path)
onready var content_root = get_node_or_null(content_root_path)
onready var footer_root = get_node_or_null(footer_root_path)
onready var back_button = get_node_or_null(back_button_path)
onready var skip_confirm_panel = get_node_or_null(skip_confirm_panel_path)
onready var skip_confirm_yes_button = get_node_or_null(skip_confirm_yes_button_path)
onready var skip_confirm_no_button = get_node_or_null(skip_confirm_no_button_path)
onready var battle_text_label = get_node_or_null(battle_text_label_path)

var editor_preview_seeded := false
var modal_context = null
var is_modal_open := false
var item_atlas_texture: Texture = null
var item_icon_regions := {}
var skip_confirmation_pending := false
var skip_confirm_restore_text := ""
var skip_confirm_text_captured := false

func _ready() -> void:
	set_process(true)
	set_process_input(true)
	_apply_ui_scale()
	_load_item_icon_atlas_cache()
	if not Engine.editor_hint:
		hide()
	if title_label != null:
		title_label.text = default_title
	if back_button != null and not back_button.is_connected("pressed", self, "_on_BackButton_pressed"):
		back_button.connect("pressed", self, "_on_BackButton_pressed")
	if skip_confirm_yes_button != null and not skip_confirm_yes_button.is_connected("pressed", self, "_on_SkipConfirmYesButton_pressed"):
		skip_confirm_yes_button.connect("pressed", self, "_on_SkipConfirmYesButton_pressed")
	if skip_confirm_no_button != null and not skip_confirm_no_button.is_connected("pressed", self, "_on_SkipConfirmNoButton_pressed"):
		skip_confirm_no_button.connect("pressed", self, "_on_SkipConfirmNoButton_pressed")

func set_ui_scale(value: float) -> void:
	ui_scale = value
	_apply_ui_scale()

func open_menu(context = null) -> void:
	modal_context = context
	is_modal_open = true
	skip_confirmation_pending = false
	_set_skip_confirmation_visible(false)
	show()
	if use_runtime_layout_overrides and not Engine.editor_hint:
		_apply_runtime_layout_overrides(context)
	emit_signal("modal_opened", context)

func close_menu(emit_close: bool = true) -> void:
	is_modal_open = false
	hide()
	if emit_close:
		emit_signal("close_requested")
	emit_signal("overlay_closed")

func handle_back_action() -> bool:
	if not close_on_back:
		return false
	if not visible and not is_modal_open:
		return false
	if skip_confirmation_pending:
		skip_confirmation_pending = false
		_set_skip_confirmation_visible(false)
		return true
	skip_confirmation_pending = true
	_set_skip_confirmation_visible(true)
	return true

func is_skip_confirmation_pending() -> bool:
	return skip_confirmation_pending

func move_skip_confirmation_focus() -> void:
	if not skip_confirmation_pending:
		return
	if skip_confirm_yes_button == null or skip_confirm_no_button == null:
		return
	if skip_confirm_yes_button.has_focus():
		skip_confirm_no_button.grab_focus()
	else:
		skip_confirm_yes_button.grab_focus()

func _set_skip_confirmation_visible(is_visible: bool) -> void:
	if skip_confirm_panel != null:
		skip_confirm_panel.visible = is_visible
	_set_item_buttons_disabled_for_confirmation(is_visible)
	if battle_text_label != null:
		if is_visible:
			skip_confirm_restore_text = battle_text_label.text
			skip_confirm_text_captured = true
			battle_text_label.text = skip_confirm_prompt_text
		elif skip_confirm_text_captured:
			battle_text_label.text = skip_confirm_restore_text
			skip_confirm_text_captured = false
	if is_visible and skip_confirm_no_button != null:
		skip_confirm_no_button.grab_focus()

func _set_item_buttons_disabled_for_confirmation(is_disabled: bool) -> void:
	if content_root == null:
		return
	for container_name in ["FreeItemSlots", "ShopItemSlots"]:
		var container = content_root.find_node(container_name, true, false)
		for button in _get_item_slot_buttons_in_container(container):
			if is_disabled:
				button.set_meta("skip_confirm_was_disabled", button.disabled)
				button.disabled = true
			elif button.has_meta("skip_confirm_was_disabled"):
				button.disabled = bool(button.get_meta("skip_confirm_was_disabled"))
				button.remove_meta("skip_confirm_was_disabled")

func _on_SkipConfirmYesButton_pressed() -> void:
	if not skip_confirmation_pending:
		return
	close_menu(true)

func _on_SkipConfirmNoButton_pressed() -> void:
	if not skip_confirmation_pending:
		return
	skip_confirmation_pending = false
	_set_skip_confirmation_visible(false)

func set_modal_title(value: String) -> void:
	default_title = value
	if title_label != null:
		title_label.text = value

func get_modal_context():
	return modal_context

func get_content_root() -> Node:
	return content_root

func get_footer_root() -> Node:
	return footer_root

func get_preview_shop_item_count() -> int:
	return int(clamp(preview_shop_item_count, 0, 14))

func get_preview_free_item_count() -> int:
	return int(clamp(preview_free_item_count, 0, 14))

func populate_post_battle_item_menu_slots(free_items: Array, shop_items: Array, pressed_owner, pressed_method: String) -> void:
	if content_root == null:
		return
	var free_slots_container = content_root.find_node("FreeItemSlots", true, false)
	var shop_slots_container = content_root.find_node("ShopItemSlots", true, false)
	if free_slots_container == null or shop_slots_container == null:
		return
	if free_slots_container is Control:
		free_slots_container.rect_clip_content = true
	if shop_slots_container is Control:
		shop_slots_container.rect_clip_content = true

	for child in free_slots_container.get_children():
		child.queue_free()
	for child in shop_slots_container.get_children():
		child.queue_free()

	_populate_item_slot_rows(free_slots_container, free_items, 7, pressed_owner, pressed_method)
	_populate_item_slot_rows(shop_slots_container, shop_items, 7, pressed_owner, pressed_method)

func _populate_item_slot_rows(container, item_entries: Array, max_per_row: int, pressed_owner, pressed_method: String) -> void:
	if container == null:
		return
	if max_per_row <= 0:
		max_per_row = 1
	if item_entries.empty():
		return
	var slot_scale := 1.0
	if item_entries.size() > 5:
		slot_scale = 0.7

	var index = 0
	while index < item_entries.size():
		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.alignment = BoxContainer.ALIGN_CENTER
		row.add_constant_override("separation", int(round(6.0 * slot_scale)))
		container.add_child(row)

		var row_count = min(max_per_row, item_entries.size() - index)
		for _i in range(row_count):
			var entry = item_entries[index]
			var slot_button = _build_item_slot_button(entry, slot_scale, pressed_owner, pressed_method)
			row.add_child(slot_button)
			index += 1

func _build_item_slot_button(entry: Dictionary, slot_scale: float = 1.0, pressed_owner = null, pressed_method: String = "") -> Button:
	slot_scale = clamp(slot_scale, 0.5, 1.0)
	var compact_text_scale := slot_scale if slot_scale < 1.0 else 1.0
	var button = Button.new()
	button.toggle_mode = false
	button.flat = true
	button.focus_mode = Control.FOCUS_ALL
	button.disabled = not bool(entry.get("enabled", true))
	button.modulate = Color(1, 1, 1, 0)
	button.hint_tooltip = String(entry.get("label", ""))
	button.rect_min_size = Vector2(58, 48) * slot_scale

	var icon_rect = TextureRect.new()
	icon_rect.expand = true
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.rect_position = Vector2(17, 1) * slot_scale
	icon_rect.rect_min_size = Vector2(24, 24) * slot_scale
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon_key = String(entry.get("icon", "")).strip_edges().to_lower()
	if icon_key.empty():
		icon_key = _resolve_item_slot_icon_key(String(entry.get("id", "")))
	var region = _get_item_icon_region(icon_key)
	if region.size.x > 0 and region.size.y > 0 and item_atlas_texture != null:
		var atlas_tex = AtlasTexture.new()
		atlas_tex.atlas = item_atlas_texture
		atlas_tex.region = region
		icon_rect.texture = atlas_tex
	button.add_child(icon_rect)

	var name_label = Label.new()
	name_label.align = Label.ALIGN_CENTER
	name_label.valign = Label.VALIGN_CENTER
	name_label.rect_position = Vector2(1, 24) * slot_scale
	name_label.rect_min_size = Vector2(56, 11)
	name_label.clip_text = true
	name_label.text = String(entry.get("label", ""))
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.rect_scale = Vector2(compact_text_scale, compact_text_scale)
	button.add_child(name_label)

	var cost_label = Label.new()
	cost_label.align = Label.ALIGN_CENTER
	cost_label.valign = Label.VALIGN_CENTER
	cost_label.rect_position = Vector2(1, 35) * slot_scale
	cost_label.rect_min_size = Vector2(56, 10)
	var item_cost = int(entry.get("cost", 0))
	if String(entry.get("kind", "free")) == "free":
		cost_label.text = ""
	else:
		cost_label.text = "$%d" % item_cost
	cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cost_label.rect_scale = Vector2(compact_text_scale, compact_text_scale)
	button.add_child(cost_label)

	if pressed_owner != null and not pressed_method.empty() and pressed_owner.has_method(pressed_method):
		button.connect("pressed", pressed_owner, pressed_method, [String(entry.get("id", "")), String(entry.get("kind", "free"))])
	return button

func _resolve_item_slot_icon_key(item_id: String) -> String:
	match item_id.strip_edges().to_lower():
		"potion":
			return "potion"
		"super_potion":
			return "super_potion"
		"hyper_potion":
			return "hyper_potion"
		"max_potion":
			return "max_potion"
		"full_restore":
			return "full_restore"
		"full_heal":
			return "full_heal"
		"revive":
			return "revive"
		"max_revive":
			return "max_revive"
		"ether":
			return "ether"
		"max_ether":
			return "max_ether"
		"elixir":
			return "elixir"
		"max_elixir":
			return "max_elixir"
		"memory_mushroom":
			return "memory_mushroom"
		"sacred_ash":
			return "sacred_ash"
		_:
			return "potion"

func _load_item_icon_atlas_cache() -> void:
	if item_atlas_texture != null and not item_icon_regions.empty():
		return

	item_atlas_texture = load(ITEM_ATLAS_TEXTURE_PATH)
	item_icon_regions = {}
	var frames = AtlasFrameParser.parse_all_sprite_frames(ITEM_ATLAS_FRAMES_PATH)
	for frame_entry in frames:
		if typeof(frame_entry) != TYPE_DICTIONARY:
			continue
		var filename = String(frame_entry.get("filename", "")).strip_edges().to_lower()
		if filename.empty():
			continue
		var frame_rect = frame_entry.get("frame", {})
		if typeof(frame_rect) != TYPE_DICTIONARY:
			continue
		item_icon_regions[filename] = Rect2(
			float(frame_rect.get("x", 0)),
			float(frame_rect.get("y", 0)),
			float(frame_rect.get("w", 0)),
			float(frame_rect.get("h", 0))
		)

func _get_item_icon_region(icon_key: String) -> Rect2:
	if item_icon_regions.empty():
		return Rect2()
	var key = icon_key.strip_edges().to_lower()
	if item_icon_regions.has(key):
		return item_icon_regions[key]
	if item_icon_regions.has("potion"):
		return item_icon_regions["potion"]
	return Rect2()

func animate_post_battle_item_menu_reveal(cancel_owner = null, cancel_method: String = "", active_turn_token: int = -1, minimal_assets_path: String = "res://godot-minimal-assets/"):
	if not visible:
		return
	var overlay_ui_scale_root = get_node_or_null("Backdrop/Panel/UiScaleRoot")
	if overlay_ui_scale_root == null:
		return
	if content_root == null:
		return
	var free_slots_container = content_root.find_node("FreeItemSlots", true, false)
	var shop_slots_container = content_root.find_node("ShopItemSlots", true, false)

	overlay_ui_scale_root.modulate = Color(1, 1, 1, 0)
	var overlay_tween = Tween.new()
	add_child(overlay_tween)
	overlay_tween.interpolate_property(overlay_ui_scale_root, "modulate:a", 0.0, 1.0, post_battle_item_menu_overlay_duration_sec, Tween.TRANS_SINE, Tween.EASE_OUT)
	overlay_tween.start()
	yield(overlay_tween, "tween_all_completed")
	overlay_tween.queue_free()

	if _is_reveal_cancelled(cancel_owner, cancel_method, active_turn_token):
		return

	if shop_slots_container != null:
		var shop_buttons = _get_item_slot_buttons_in_container(shop_slots_container)
		var shop_tween = Tween.new()
		add_child(shop_tween)
		for i in range(shop_buttons.size()):
			var button = shop_buttons[i]
			if button == null:
				continue
			button.modulate = Color(1, 1, 1, 0)
			shop_tween.interpolate_property(button, "modulate:a", 0.0, 1.0, post_battle_item_menu_shop_fade_duration_sec, Tween.TRANS_SINE, Tween.EASE_OUT)
		shop_tween.start()
		yield(shop_tween, "tween_all_completed")
		shop_tween.queue_free()

	if _is_reveal_cancelled(cancel_owner, cancel_method, active_turn_token):
		return

	if free_slots_container != null:
		var free_buttons = _get_item_slot_buttons_in_container(free_slots_container)
		var drop_states := []
		for i in range(free_buttons.size()):
			if _is_reveal_cancelled(cancel_owner, cancel_method, active_turn_token):
				break
			var button = free_buttons[i]
			if button == null:
				continue
			button.modulate = Color(1, 1, 1, 0)
			var ball_anim = _animate_pokeball_drop_and_settle(button, post_battle_item_menu_free_stagger_delay_sec * float(i), minimal_assets_path)
			if ball_anim is GDScriptFunctionState:
				drop_states.append(ball_anim)
		for ball_anim in drop_states:
			yield(ball_anim, "completed")

		if _is_reveal_cancelled(cancel_owner, cancel_method, active_turn_token):
			return

		var reveal_states := []
		for i in range(free_buttons.size()):
			if _is_reveal_cancelled(cancel_owner, cancel_method, active_turn_token):
				break
			var button = free_buttons[i]
			if button == null:
				continue
			var reveal_anim = _animate_free_item_reveal(button, post_battle_item_menu_free_reveal_stagger_delay_sec * float(i), minimal_assets_path)
			if reveal_anim is GDScriptFunctionState:
				reveal_states.append(reveal_anim)
		for reveal_anim in reveal_states:
			yield(reveal_anim, "completed")

func _is_reveal_cancelled(cancel_owner, cancel_method: String, active_turn_token: int) -> bool:
	if cancel_owner == null:
		return false
	if cancel_method.empty():
		return false
	if not cancel_owner.has_method(cancel_method):
		return false
	return bool(cancel_owner.call(cancel_method, active_turn_token))

func _get_item_slot_buttons_in_container(container: Node) -> Array:
	var buttons := []
	if container == null:
		return buttons
	for row in container.get_children():
		if row is BoxContainer:
			for button in row.get_children():
				if button is Button:
					buttons.append(button)
	return buttons

# Used when reopening the same post-battle menu (e.g. after a shop purchase) so items
# that were already revealed don't replay their fade/drop/reveal animation.
func show_post_battle_item_menu_immediate() -> void:
	if not visible:
		return
	var overlay_ui_scale_root = get_node_or_null("Backdrop/Panel/UiScaleRoot")
	if overlay_ui_scale_root != null:
		overlay_ui_scale_root.modulate = Color(1, 1, 1, 1)
	if content_root == null:
		return
	var free_slots_container = content_root.find_node("FreeItemSlots", true, false)
	var shop_slots_container = content_root.find_node("ShopItemSlots", true, false)
	for button in _get_item_slot_buttons_in_container(free_slots_container):
		if button != null:
			button.modulate = Color(1, 1, 1, 1)
	for button in _get_item_slot_buttons_in_container(shop_slots_container):
		if button != null:
			button.modulate = Color(1, 1, 1, 1)

func _get_post_battle_item_icon_rect(item_button: Button) -> TextureRect:
	if item_button == null or not is_instance_valid(item_button):
		return null
	for child in item_button.get_children():
		if child is TextureRect:
			return child
	return null

func _load_pokeball_frame_texture(atlas_texture: Texture, atlas_path: String, frame_name: String) -> AtlasTexture:
	if atlas_texture == null:
		return null
	var frame_data = AtlasFrameParser.parse_sprite_frame(atlas_path, frame_name)
	if frame_data == null or not frame_data.has("frame"):
		return null
	var frame = frame_data["frame"]
	var atlas_frame = AtlasTexture.new()
	atlas_frame.atlas = atlas_texture
	atlas_frame.region = Rect2(frame["x"], frame["y"], frame["w"], frame["h"])
	return atlas_frame

func _animate_pokeball_drop_and_settle(item_button: Button, start_delay: float = 0.0, minimal_assets_path: String = "res://godot-minimal-assets/"):
	if item_button == null or not is_instance_valid(item_button):
		return
	yield(get_tree().create_timer(start_delay), "timeout")

	if content_root == null:
		return

	var icon_rect = _get_post_battle_item_icon_rect(item_button)
	if icon_rect == null:
		return
	var icon_center_global = icon_rect.rect_global_position + (icon_rect.rect_size / 2.0)
	var icon_size = icon_rect.rect_size

	var pokeball_sprite = Sprite.new()
	pokeball_sprite.centered = true
	pokeball_sprite.modulate = Color(1, 1, 1, 1)
	pokeball_sprite.z_index = 1000

	var texture_path = minimal_assets_path + POKEBALL_TEXTURE_REL
	var atlas_path = minimal_assets_path + POKEBALL_ATLAS_REL
	var frame_size = icon_size
	var atlas_texture = null

	if ResourceLoader.exists(texture_path):
		atlas_texture = load(texture_path)
		if atlas_texture != null:
			var atlas_frame = _load_pokeball_frame_texture(atlas_texture, atlas_path, POKEBALL_FRAME_CLOSED)
			if atlas_frame != null:
				frame_size = Vector2(atlas_frame.region.size.x, atlas_frame.region.size.y)
				pokeball_sprite.texture = atlas_frame

	var pokeball_display_size = min(icon_size.x, icon_size.y) * 0.85
	var pokeball_scale = pokeball_display_size / max(1.0, max(frame_size.x, frame_size.y))
	pokeball_sprite.scale = Vector2(pokeball_scale, pokeball_scale)
	pokeball_sprite.set_meta("free_item_atlas_texture", atlas_texture)
	pokeball_sprite.set_meta("free_item_atlas_path", atlas_path)

	var content_root_local = content_root.get_global_transform_with_canvas().affine_inverse().xform(icon_center_global)
	var final_pos = content_root_local + Vector2(post_battle_item_menu_free_pokeball_offset_x_px, post_battle_item_menu_free_pokeball_offset_y_px)
	var start_pos = final_pos
	start_pos.y -= post_battle_item_menu_free_drop_height_px
	pokeball_sprite.position = start_pos
	item_button.set_meta("free_item_pokeball_sprite", pokeball_sprite)
	content_root.add_child(pokeball_sprite)

	var drop_tween = Tween.new()
	add_child(drop_tween)
	drop_tween.interpolate_property(pokeball_sprite, "position:y", start_pos.y, final_pos.y + post_battle_item_menu_free_bounce_peak_px, post_battle_item_menu_free_drop_duration_sec, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	drop_tween.start()
	yield(drop_tween, "tween_all_completed")
	drop_tween.queue_free()

	var bounce_tween = Tween.new()
	add_child(bounce_tween)
	bounce_tween.interpolate_property(pokeball_sprite, "position:y", final_pos.y + post_battle_item_menu_free_bounce_peak_px, final_pos.y, post_battle_item_menu_free_bounce_duration_sec, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	bounce_tween.start()
	yield(bounce_tween, "tween_all_completed")
	bounce_tween.queue_free()

func _animate_free_item_reveal(item_button: Button, start_delay: float = 0.0, minimal_assets_path: String = "res://godot-minimal-assets/"):
	if item_button == null or not is_instance_valid(item_button):
		return
	yield(get_tree().create_timer(start_delay), "timeout")

	var pokeball_sprite = null
	if item_button.has_meta("free_item_pokeball_sprite"):
		pokeball_sprite = item_button.get_meta("free_item_pokeball_sprite")
	if pokeball_sprite == null or not is_instance_valid(pokeball_sprite):
		return

	var atlas_texture = null
	if pokeball_sprite.has_meta("free_item_atlas_texture"):
		atlas_texture = pokeball_sprite.get_meta("free_item_atlas_texture")
	var atlas_path = minimal_assets_path + POKEBALL_ATLAS_REL
	if pokeball_sprite.has_meta("free_item_atlas_path"):
		atlas_path = String(pokeball_sprite.get_meta("free_item_atlas_path"))

	var opening_frame = _load_pokeball_frame_texture(atlas_texture, atlas_path, POKEBALL_FRAME_OPENING)
	if opening_frame != null:
		pokeball_sprite.texture = opening_frame
	yield(get_tree().create_timer(0.017), "timeout")
	var open_frame = _load_pokeball_frame_texture(atlas_texture, atlas_path, POKEBALL_FRAME_OPEN)
	if open_frame != null:
		pokeball_sprite.texture = open_frame

	var pivot = item_button.rect_size / 2.0
	item_button.rect_pivot_offset = pivot
	item_button.rect_scale = Vector2(0.92, 0.92)

	var reveal_tween = Tween.new()
	add_child(reveal_tween)
	reveal_tween.interpolate_property(pokeball_sprite, "modulate:a", 1.0, 0.0, post_battle_item_menu_free_reveal_duration_sec, Tween.TRANS_SINE, Tween.EASE_IN)
	reveal_tween.interpolate_property(item_button, "modulate:a", 0.0, 1.0, post_battle_item_menu_free_reveal_duration_sec, Tween.TRANS_SINE, Tween.EASE_OUT)
	reveal_tween.interpolate_property(item_button, "rect_scale", Vector2(0.92, 0.92), Vector2(1.0, 1.0), post_battle_item_menu_free_reveal_duration_sec, Tween.TRANS_BACK, Tween.EASE_OUT)
	reveal_tween.start()
	yield(reveal_tween, "tween_all_completed")
	reveal_tween.queue_free()

	item_button.rect_scale = Vector2(1.0, 1.0)
	item_button.remove_meta("free_item_pokeball_sprite")
	pokeball_sprite.queue_free()

func _apply_editor_preview_state() -> void:
	_apply_ui_scale()
	_apply_preview_content()
	editor_preview_seeded = true

func _refresh_editor_preview_state() -> void:
	_apply_ui_scale()
	_apply_preview_content()

func _process(_delta: float) -> void:
	if not Engine.editor_hint:
		return

	EditorPreviewSync.sync_scene(
		self,
		editor_preview_enabled,
		editor_preview_seeded,
		"_apply_editor_preview_state",
		"_refresh_editor_preview_state"
	)

func _input(event: InputEvent) -> void:
	if Engine.editor_hint:
		return
	if _is_back_input(event) and handle_back_action():
		get_tree().set_input_as_handled()

func _apply_ui_scale() -> void:
	if ui_scale_root != null:
		ui_scale_root.rect_scale = Vector2(ui_scale, ui_scale)

func _apply_preview_content() -> void:
	if title_label != null:
		title_label.text = default_title

func _apply_runtime_layout_overrides(_context = null) -> void:
	# Intentionally empty in template. Extend in concrete modal scenes.
	pass

func _is_back_input(event: InputEvent) -> bool:
	if event is InputEventAction:
		var action_event := event as InputEventAction
		if action_event.pressed and (action_event.action == "ui_cancel" or action_event.action == "ui_back"):
			return true
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and (key_event.scancode == KEY_ESCAPE or key_event.scancode == KEY_BACKSPACE):
			return true
	return false

func _on_BackButton_pressed() -> void:
	var _handled = handle_back_action()
