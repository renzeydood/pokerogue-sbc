extends Control

signal close_requested

export(float) var ui_scale := 2.0
export(bool) var editor_preview_enabled := true
export(float) var pokemon_anim_frame_sec := 0.1
export(float) var base_bar_scale := 1.0
export(float) var base_bar_stat_ceiling := 150.0
export(float) var base_bar_max_width := 50.0
export(float) var base_bar_height := 5.0
export(float) var base_bar_right_inset_px := 8.0
export(float) var base_bar_overlap_px := 12.0
export(bool) var use_sprite_trim_offset := false
export(String, "center", "bottom") var preview_sprite_anchor_mode := "bottom"
export(float) var sprite_vertical_nudge_px := 0.0

const TYPE_TEXTURE_REL := "assets/images/types.png"
const TYPE_ATLAS_REL := "assets/images/types.json"
const BASE_STATS_KEYS := ["hp", "atk", "def", "sp_atk", "sp_def", "spd"]
const BASE_STATS_LABELS := ["HP", "ATK", "DEF", "SPATK", "SPDEF", "SPD"]
const BASE_BAR_COLOR := Color(0.4, 0.666667, 0.6, 1)

onready var ui_scale_root = $Panel/UiScaleRoot
onready var current_pokemon_sprite = $Panel/UiScaleRoot/CurrentPokemonSprite
onready var details_type1_sprite = $Panel/UiScaleRoot/DetailsType1Sprite
onready var details_type2_sprite = $Panel/UiScaleRoot/DetailsType2Sprite
onready var species_label = get_node_or_null("Panel/UiScaleRoot/SpeciesLabel")
onready var status_label = get_node_or_null("Panel/UiScaleRoot/StatusLabel")
onready var body_label = get_node_or_null("Panel/UiScaleRoot/EntryWindow/EntryMargin/BodyLabel")
onready var pokemon_number_label = $Panel/UiScaleRoot/PokemonNumberLabel
onready var base_stats_button = $Panel/UiScaleRoot/EntryWindow/ActionContentMargin/ActionButtonList/BaseStatsButton
onready var abilities_button = $Panel/UiScaleRoot/EntryWindow/ActionContentMargin/ActionButtonList/AbilitiesButton
onready var level_moves_button = $Panel/UiScaleRoot/EntryWindow/ActionContentMargin/ActionButtonList/LevelMovesButton
onready var egg_moves_button = $Panel/UiScaleRoot/EntryWindow/ActionContentMargin/ActionButtonList/EggMovesButton
onready var tm_moves_button = $Panel/UiScaleRoot/EntryWindow/ActionContentMargin/ActionButtonList/TMMovesButton
onready var biomes_button = $Panel/UiScaleRoot/EntryWindow/ActionContentMargin/ActionButtonList/BiomesButton
onready var natures_button = $Panel/UiScaleRoot/EntryWindow/ActionContentMargin/ActionButtonList/NaturesButton
onready var ribbons_button = $Panel/UiScaleRoot/EntryWindow/ActionContentMargin/ActionButtonList/RibbonsButton
onready var evolutions_button = $Panel/UiScaleRoot/EntryWindow/ActionContentMargin/ActionButtonList/EvolutionsButton
onready var base_stats_window = $Panel/UiScaleRoot/BaseStatsWindow
onready var hp_label = $Panel/UiScaleRoot/BaseStatsWindow/ActionContentMargin/ActionButtonList/HPContainer/HPLabel
onready var atk_label = $Panel/UiScaleRoot/BaseStatsWindow/ActionContentMargin/ActionButtonList/AtkContainer/AtkLabel
onready var def_label = $Panel/UiScaleRoot/BaseStatsWindow/ActionContentMargin/ActionButtonList/DefContainer/DefLabel
onready var spatk_label = $Panel/UiScaleRoot/BaseStatsWindow/ActionContentMargin/ActionButtonList/SpAtkContainer/SpAtkLabel
onready var spdef_label = $Panel/UiScaleRoot/BaseStatsWindow/ActionContentMargin/ActionButtonList/SpDefContainer/SpDefLabel
onready var spd_label = $Panel/UiScaleRoot/BaseStatsWindow/ActionContentMargin/ActionButtonList/SpdContainer/SpdLabel
onready var hp_bar = $Panel/UiScaleRoot/BaseStatsWindow/ActionContentMargin/ActionButtonList/HPContainer/HPBar
onready var atk_bar = $Panel/UiScaleRoot/BaseStatsWindow/ActionContentMargin/ActionButtonList/AtkContainer/AtkBar
onready var def_bar = $Panel/UiScaleRoot/BaseStatsWindow/ActionContentMargin/ActionButtonList/DefContainer/DefBar
onready var spatk_bar = $Panel/UiScaleRoot/BaseStatsWindow/ActionContentMargin/ActionButtonList/SpAtkContainer/SpAtkBar
onready var spdef_bar = $Panel/UiScaleRoot/BaseStatsWindow/ActionContentMargin/ActionButtonList/SpDefContainer/SpDefBar
onready var spd_bar = $Panel/UiScaleRoot/BaseStatsWindow/ActionContentMargin/ActionButtonList/SpdContainer/SpdBar
onready var total_label = $Panel/UiScaleRoot/BaseStatsWindow/ActionContentMargin/ActionButtonList/TotalLabel
onready var action_text_label = $Panel/UiScaleRoot/Footer/MessageActionWindowSprite/MessageActionMargin/ActionTextLabel
onready var close_button = get_node_or_null("Panel/UiScaleRoot/Footer/BackButton")

var catalog_loader_script = load("res://logic/CatalogDataLoader.gd")
var runtime_state_script = load("res://logic/RuntimeState.gd")
var catalog_loader = null
var minimal_assets_path = "res://godot-minimal-assets/"

var current_species_id := ""
var current_is_caught := false
var current_species_types: Array = []
var sprite_frames: Array = []
var sprite_anim_index := 0
var sprite_anim_elapsed := 0.0
var sprite_editor_base_offset := Vector2.ZERO
var sprite_anchor_frame_offset := Vector2.ZERO
var sprite_anchor_frame_offset_set := false
var current_base_stats := {}
var pending_base_stat_values := []
var base_bar_right_edge_hint := -1.0
var base_bar_y_offsets := []

func _ready() -> void:
	set_process(true)
	if ui_scale_root != null:
		ui_scale_root.rect_scale = Vector2(ui_scale, ui_scale)
	_setup_action_buttons()
	_setup_type_sprites()
	_setup_base_stats_window()
	if current_pokemon_sprite != null:
		sprite_editor_base_offset = current_pokemon_sprite.offset
	visible = false
	if close_button != null and not close_button.is_connected("pressed", self, "_on_close_button_pressed"):
		close_button.connect("pressed", self, "_on_close_button_pressed")

func _process(_delta: float) -> void:
	if not visible:
		return
	_update_sprite_animation(_delta)

func open_menu(species_id: String, is_caught: bool) -> void:
	current_species_id = species_id.strip_edges().to_upper()
	current_is_caught = _resolve_species_caught_state(current_species_id, is_caught)
	_refresh_entry_view()
	visible = true
	focus_default()

func close_menu() -> void:
	visible = false

func focus_default() -> void:
	if not visible:
		return
	if base_stats_button != null and not base_stats_button.disabled:
		base_stats_button.grab_focus()
		return
	if close_button != null:
		close_button.grab_focus()

func move_focus(_action_name: String) -> void:
	focus_default()

func press_focused() -> void:
	if not visible:
		return
	var focus_owner = get_focus_owner()
	if focus_owner is Button and not focus_owner.disabled:
		focus_owner.emit_signal("pressed")

func handle_back_action() -> bool:
	if not visible:
		return false
	if base_stats_window != null and base_stats_window.visible:
		_hide_base_stats_window()
		return true
	emit_signal("close_requested")
	return true

func is_overlay_focus_owner(focus_owner) -> bool:
	if focus_owner == null:
		return false
	if focus_owner == close_button:
		return true
	return false

func _refresh_entry_text() -> void:
	if species_label == null or status_label == null or pokemon_number_label == null:
		return

	var display_species = current_species_id if not current_species_id.empty() else "UNKNOWN"
	if not current_is_caught:
		display_species = "----------"
	species_label.text = display_species
	pokemon_number_label.text = _format_species_number(_get_species_dex_number(current_species_id))
	status_label.text = "Status: Caught" if current_is_caught else "Status: Not Caught"
	if body_label != null:
		body_label.text = "Pokedex overlays for %s are wired. Select Base Stats to continue." % display_species

func _refresh_entry_view() -> void:
	_refresh_entry_text()
	_load_species_base_stats()
	_populate_base_stats_window()
	_hide_base_stats_window()
	_load_species_types()
	_refresh_type_badges()
	_load_species_sprite()

func _setup_action_buttons() -> void:
	var buttons = _get_action_buttons()
	for button in buttons:
		if button == null:
			continue
		if not button.is_connected("focus_entered", self, "_on_action_button_focus_entered"):
			button.connect("focus_entered", self, "_on_action_button_focus_entered", [button])

	if base_stats_button != null and not base_stats_button.is_connected("pressed", self, "_on_BaseStatsButton_pressed"):
		base_stats_button.connect("pressed", self, "_on_BaseStatsButton_pressed")

	if base_stats_button != null:
		base_stats_button.disabled = false
	for button in buttons:
		if button == null or button == base_stats_button:
			continue
		button.disabled = true

	if action_text_label != null:
		action_text_label.text = "Show its base stats."

func _get_action_buttons() -> Array:
	return [
		base_stats_button,
		abilities_button,
		level_moves_button,
		egg_moves_button,
		tm_moves_button,
		biomes_button,
		natures_button,
		ribbons_button,
		evolutions_button,
	]

func _on_action_button_focus_entered(button: Button) -> void:
	if action_text_label == null or button == null:
		return
	if button == base_stats_button:
		action_text_label.text = "Show or hide base stats."
	else:
		action_text_label.text = "Overlay not implemented yet."

func _on_BaseStatsButton_pressed() -> void:
	if base_stats_window == null:
		return
	if base_stats_window.visible:
		_hide_base_stats_window()
	else:
		_show_base_stats_window()

func _setup_base_stats_window() -> void:
	_capture_base_stat_layout_hints()
	if base_stats_window != null:
		base_stats_window.visible = false
	var scale_y = _get_ui_scale_y()
	for row in _get_base_stat_rows():
		if row == null:
			continue
		var baseline_row_height = max(11.0, max(row.rect_min_size.y, row.rect_size.y))
		row.rect_min_size = Vector2(0.0, baseline_row_height)
		row.rect_size = Vector2(row.rect_size.x, baseline_row_height)
	for label in _get_base_stat_labels():
		if label == null:
			continue
		label.align = Label.ALIGN_LEFT
		label.size_flags_horizontal = Control.SIZE_FILL
		label.raise()
	for bar in _get_base_stat_bars():
		if bar == null:
			continue
		bar.color = BASE_BAR_COLOR
		bar.anchor_left = 1.0
		bar.anchor_right = 1.0
		bar.rect_min_size = Vector2(0.0, max(1.0, base_bar_height / scale_y))
		bar.rect_size = Vector2(0.0, max(1.0, base_bar_height / scale_y))

func _load_species_base_stats() -> void:
	current_base_stats = {
		"hp": 0,
		"atk": 0,
		"def": 0,
		"sp_atk": 0,
		"sp_def": 0,
		"spd": 0,
	}
	var species_entry = _get_species_entry(current_species_id)
	if species_entry.empty():
		return
	var base_stats = species_entry.get("base_stats", {})
	if typeof(base_stats) != TYPE_DICTIONARY:
		return
	for stat_key in BASE_STATS_KEYS:
		current_base_stats[stat_key] = int(base_stats.get(stat_key, 0))

func _populate_base_stats_window() -> void:
	var labels = _get_base_stat_labels()
	var total := 0
	pending_base_stat_values.clear()
	for i in range(BASE_STATS_KEYS.size()):
		var key = String(BASE_STATS_KEYS[i])
		var value = int(current_base_stats.get(key, 0))
		pending_base_stat_values.append(value)
		total += value
		if i < labels.size() and labels[i] != null:
			labels[i].text = "%s: %d" % [String(BASE_STATS_LABELS[i]), value]
	if total_label != null:
		total_label.text = "Total: %d" % total
	if base_stats_window != null and base_stats_window.visible:
		_reflow_base_stat_bars()

func _show_base_stats_window() -> void:
	if base_stats_window == null:
		return
	_populate_base_stats_window()
	base_stats_window.visible = true
	call_deferred("_reflow_base_stat_bars")
	if action_text_label != null:
		action_text_label.text = "Base stats shown."

func _hide_base_stats_window() -> void:
	if base_stats_window != null:
		base_stats_window.visible = false
	if action_text_label != null:
		action_text_label.text = "Show or hide base stats."

func _get_base_stat_labels() -> Array:
	return [hp_label, atk_label, def_label, spatk_label, spdef_label, spd_label]

func _get_base_stat_bars() -> Array:
	return [hp_bar, atk_bar, def_bar, spatk_bar, spdef_bar, spd_bar]

func _get_base_stat_rows() -> Array:
	var rows := []
	for bar in _get_base_stat_bars():
		if bar == null:
			continue
		var row = bar.get_parent()
		if row == null or rows.has(row):
			continue
		rows.append(row)
	return rows

func _reflow_base_stat_bars() -> void:
	var bars = _get_base_stat_bars()
	var labels = _get_base_stat_labels()
	var count = min(bars.size(), pending_base_stat_values.size())
	var scale_x = _get_ui_scale_x()
	var scale_y = _get_ui_scale_y()
	var effective_max_width = min(max(0.0, base_bar_max_width), 50.0) / scale_x
	var effective_scale = max(0.0, base_bar_scale)
	var stat_ceiling = max(1.0, base_bar_stat_ceiling)
	var effective_min_width = 2.0 / scale_x
	var effective_right_inset = max(0.0, base_bar_right_inset_px) / scale_x
	for i in range(count):
		var bar: ColorRect = bars[i]
		var label: Label = null
		if i < labels.size():
			label = labels[i]
		if bar == null:
			continue
		var value = int(pending_base_stat_values[i])
		var row = bar.get_parent()
		var row_width = effective_max_width
		if row != null:
			row_width = max(0.0, row.rect_size.x)
		if label != null:
			label.rect_position = Vector2.ZERO
			label.rect_size = Vector2(row_width, label.rect_size.y)
		var right_x = row_width - effective_right_inset
		if base_bar_right_edge_hint > 0.0:
			right_x = clamp(base_bar_right_edge_hint, 0.0, row_width)
		right_x = floor(right_x + 0.5)
		var width_limit = min(effective_max_width, max(0.0, right_x))
		var normalized_value = clamp(float(value), 0.0, stat_ceiling) / stat_ceiling
		var width = clamp(normalized_value * effective_scale * effective_max_width, 0.0, width_limit)
		if width_limit > 0.0:
			width = clamp(max(width, effective_min_width), 0.0, width_limit)
		var height = max(1.0, base_bar_height / scale_y)
		bar.anchor_left = 1.0
		bar.anchor_right = 1.0
		bar.rect_min_size = Vector2(0.0, height)
		bar.rect_size = Vector2(0.0, height)
		var x_pos = floor((right_x - width) + 0.5)
		var y_pos = max(0.0, (row.rect_size.y - height) * 0.5) if row != null else 0.0
		if i < base_bar_y_offsets.size() and float(base_bar_y_offsets[i]) >= 0.0:
			y_pos = float(base_bar_y_offsets[i])
		bar.margin_left = x_pos - row_width
		bar.margin_right = right_x - row_width
		bar.margin_top = y_pos
		bar.margin_bottom = y_pos + height
		bar.minimum_size_changed()

func _capture_base_stat_layout_hints() -> void:
	base_bar_right_edge_hint = -1.0
	base_bar_y_offsets.clear()
	for bar in _get_base_stat_bars():
		if bar == null:
			base_bar_y_offsets.append(-1.0)
			continue
		var right_edge = bar.rect_position.x + bar.rect_size.x
		var y_offset = bar.rect_position.y
		if right_edge > 0.0:
			if base_bar_right_edge_hint < 0.0:
				base_bar_right_edge_hint = right_edge
			else:
				base_bar_right_edge_hint = min(base_bar_right_edge_hint, right_edge)
		base_bar_y_offsets.append(max(0.0, y_offset))
	if base_bar_right_edge_hint > 0.0:
		base_bar_right_edge_hint = floor(base_bar_right_edge_hint + 0.5)

func _get_ui_scale_x() -> float:
	if ui_scale_root == null:
		return 1.0
	return max(0.01, abs(ui_scale_root.rect_scale.x))

func _get_ui_scale_y() -> float:
	if ui_scale_root == null:
		return 1.0
	return max(0.01, abs(ui_scale_root.rect_scale.y))

func _setup_type_sprites() -> void:
	for type_sprite in [details_type1_sprite, details_type2_sprite]:
		if type_sprite == null:
			continue
		type_sprite.centered = false
		type_sprite.region_enabled = true
		type_sprite.visible = false

func _load_species_types() -> void:
	current_species_types.clear()
	var species_entry = _get_species_entry(current_species_id)
	if species_entry.empty():
		current_species_types = ["UNKNOWN"]
		return

	var entry_types = species_entry.get("types", [])
	if typeof(entry_types) != TYPE_ARRAY or entry_types.empty():
		current_species_types = ["UNKNOWN"]
		return

	for raw_type in entry_types:
		var type_name = String(raw_type).strip_edges().to_upper()
		if type_name.empty():
			continue
		current_species_types.append(type_name)

	if current_species_types.empty():
		current_species_types = ["UNKNOWN"]

func _refresh_type_badges() -> void:
	if details_type1_sprite == null or details_type2_sprite == null:
		return

	if current_species_types.empty():
		current_species_types = ["UNKNOWN"]

	_apply_type_badge(details_type1_sprite, String(current_species_types[0]))
	if current_species_types.size() >= 2:
		_apply_type_badge(details_type2_sprite, String(current_species_types[1]))
	else:
		details_type2_sprite.visible = false

func _apply_type_badge(type_sprite: Sprite, type_name: String) -> void:
	if type_sprite == null:
		return

	var texture_path = minimal_assets_path + TYPE_TEXTURE_REL
	if not ResourceLoader.exists(texture_path):
		type_sprite.visible = false
		return

	type_sprite.texture = load(texture_path)
	type_sprite.region_enabled = true
	type_sprite.centered = false

	var frame_data = _parse_sprite_frame(minimal_assets_path + TYPE_ATLAS_REL, type_name.strip_edges().to_lower())
	if frame_data == null:
		frame_data = _parse_sprite_frame(minimal_assets_path + TYPE_ATLAS_REL, "unknown")
	if frame_data == null:
		type_sprite.visible = false
		return

	var frame = frame_data["frame"]
	type_sprite.region_rect = Rect2(frame["x"], frame["y"], frame["w"], frame["h"])
	type_sprite.visible = true

func _load_species_sprite() -> void:
	if current_pokemon_sprite == null:
		return

	var sprite_paths = _get_species_sprite_paths(current_species_id)
	if sprite_paths.empty():
		sprite_paths = {
			"texture_rel": "assets/images/pokemon/1.png",
			"atlas_rel": "assets/images/pokemon/1.json",
		}

	var texture_path = minimal_assets_path + String(sprite_paths.get("texture_rel", ""))
	var atlas_path = minimal_assets_path + String(sprite_paths.get("atlas_rel", ""))
	if not ResourceLoader.exists(texture_path):
		current_pokemon_sprite.visible = false
		current_pokemon_sprite.modulate = Color(1, 1, 1, 1)
		sprite_frames.clear()
		return

	current_pokemon_sprite.texture = load(texture_path)
	current_pokemon_sprite.centered = true
	current_pokemon_sprite.region_enabled = true
	current_pokemon_sprite.offset = Vector2.ZERO
	sprite_anchor_frame_offset_set = false
	sprite_frames = _get_all_numeric_frames(atlas_path)
	if sprite_frames.empty():
		var fallback = _parse_sprite_frame(atlas_path, "0001.png")
		if fallback != null:
			sprite_frames.append(fallback)

	if sprite_frames.empty():
		current_pokemon_sprite.region_enabled = false
		current_pokemon_sprite.offset = sprite_editor_base_offset
		current_pokemon_sprite.modulate = Color(1, 1, 1, 1) if current_is_caught else Color(0, 0, 0, 1)
		current_pokemon_sprite.visible = true
		return

	sprite_anim_index = 0
	sprite_anim_elapsed = 0.0
	_apply_sprite_frame(current_pokemon_sprite, sprite_frames[0])
	current_pokemon_sprite.modulate = Color(1, 1, 1, 1) if current_is_caught else Color(0, 0, 0, 1)
	current_pokemon_sprite.visible = true

func _update_sprite_animation(delta: float) -> void:
	if current_pokemon_sprite == null:
		return
	if sprite_frames.size() <= 1:
		return
	if pokemon_anim_frame_sec <= 0.0:
		return

	sprite_anim_elapsed += delta
	if sprite_anim_elapsed < pokemon_anim_frame_sec:
		return

	sprite_anim_elapsed = 0.0
	sprite_anim_index = (sprite_anim_index + 1) % sprite_frames.size()
	_apply_sprite_frame(current_pokemon_sprite, sprite_frames[sprite_anim_index])

func _get_species_entry(species_id: String) -> Dictionary:
	if species_id.strip_edges().empty():
		return {}
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()
	if catalog_loader == null or not catalog_loader.load_catalogs():
		return {}
	return catalog_loader.get_species(species_id)

func _get_species_dex_number(species_id: String) -> int:
	if species_id.strip_edges().empty():
		return -1
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()
	if catalog_loader == null or not catalog_loader.load_catalogs():
		return -1
	return catalog_loader.get_species_dex_number(species_id)

func _get_species_sprite_paths(species_id: String) -> Dictionary:
	if species_id.strip_edges().empty():
		return {}
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()
	if catalog_loader == null or not catalog_loader.load_catalogs():
		return {}
	return catalog_loader.build_sprite_resource_paths(species_id, false)

func _format_species_number(dex_number: int) -> String:
	if dex_number <= 0:
		return "---"
	return "%03d" % dex_number

func _parse_sprite_frame(json_path: String, frame_name: String):
	var frames = _parse_all_sprite_frames(json_path)
	if frames.empty():
		return null
	for frame in frames:
		if frame.has("filename") and String(frame["filename"]) == frame_name:
			return frame
	return null

func _parse_all_sprite_frames(json_path: String) -> Array:
	var file = File.new()
	if not file.file_exists(json_path):
		return []
	if file.open(json_path, File.READ) != OK:
		return []
	var json_text = file.get_as_text()
	file.close()

	var result = JSON.parse(json_text)
	if result.error != OK:
		return []
	var data = result.result
	if typeof(data) != TYPE_DICTIONARY:
		return []
	var root_scale = _parse_atlas_scale(data.get("meta", {}).get("scale", 1.0))

	if data.has("textures"):
		var textures = data["textures"]
		if typeof(textures) == TYPE_ARRAY and not textures.empty():
			var merged_frames := []
			for texture_entry in textures:
				if typeof(texture_entry) != TYPE_DICTIONARY:
					continue
				var texture_scale = _parse_atlas_scale(texture_entry.get("scale", root_scale))
				var texture_frames = _normalize_atlas_frames_container(texture_entry.get("frames", null), texture_scale)
				for frame in texture_frames:
					merged_frames.append(frame)
			if not merged_frames.empty():
				return merged_frames

	if data.has("frames"):
		var root_frames = _normalize_atlas_frames_container(data.get("frames", null), root_scale)
		if not root_frames.empty():
			return root_frames

	return []

func _normalize_atlas_frames_container(frames_container, atlas_scale: float = 1.0) -> Array:
	if frames_container == null:
		return []
	if typeof(frames_container) == TYPE_ARRAY:
		var normalized_array := []
		for frame_entry in frames_container:
			if typeof(frame_entry) != TYPE_DICTIONARY:
				continue
			var normalized_frame = frame_entry.duplicate(true)
			normalized_frame["_atlas_scale"] = atlas_scale
			normalized_array.append(normalized_frame)
		return normalized_array
	if typeof(frames_container) == TYPE_DICTIONARY:
		var keys = frames_container.keys()
		keys.sort()
		var normalized := []
		for key in keys:
			var frame_entry = frames_container[key]
			if typeof(frame_entry) != TYPE_DICTIONARY:
				continue
			frame_entry = frame_entry.duplicate(true)
			if not frame_entry.has("filename"):
				frame_entry["filename"] = String(key)
			frame_entry["_atlas_scale"] = atlas_scale
			normalized.append(frame_entry)
		return normalized
	return []

func _parse_atlas_scale(value) -> float:
	var scale = float(value)
	if scale <= 0.0:
		return 1.0
	return scale

func _get_all_numeric_frames(json_path: String) -> Array:
	var frames = _parse_all_sprite_frames(json_path)
	if frames.empty():
		return []

	var indexed := []
	for frame in frames:
		if frame == null or not frame.has("filename"):
			continue
		var frame_index = _extract_numeric_frame_index(String(frame["filename"]))
		if frame_index < 0:
			continue
		indexed.append({"index": frame_index, "frame": frame})

	indexed.sort_custom(self, "_sort_frame_dicts")
	var result := []
	for item in indexed:
		result.append(item["frame"])
	return result

func _sort_frame_dicts(a: Dictionary, b: Dictionary) -> bool:
	return int(a["index"]) < int(b["index"])

func _extract_numeric_frame_index(filename: String) -> int:
	var cleaned = filename.strip_edges()
	if cleaned.empty():
		return -1
	if cleaned.ends_with(".png"):
		cleaned = cleaned.substr(0, cleaned.length() - 4)
	if cleaned.is_valid_integer():
		return int(cleaned)
	return -1

func _apply_sprite_frame(sprite_node: Sprite, sprite_info: Dictionary) -> void:
	if sprite_node == null or sprite_info == null:
		return
	var frame = sprite_info["frame"]
	sprite_node.region_rect = Rect2(frame["x"], frame["y"], frame["w"], frame["h"])
	if not use_sprite_trim_offset:
		sprite_node.offset = Vector2(0, sprite_vertical_nudge_px)
		return
	var frame_offset = _compute_sprite_frame_offset(sprite_info)
	sprite_node.offset = frame_offset + Vector2(0, sprite_vertical_nudge_px)

func _compute_sprite_frame_offset(sprite_info: Dictionary) -> Vector2:
	if sprite_info == null:
		return Vector2.ZERO
	var frame = sprite_info.get("frame", null)
	if frame == null:
		return Vector2.ZERO

	var sprite_source_size = sprite_info.get("spriteSourceSize", null)
	var source_size = sprite_info.get("sourceSize", null)
	if sprite_source_size != null and source_size != null:
		var trimmed_cx = float(sprite_source_size["x"]) + float(frame["w"]) / 2.0
		var trimmed_cy = float(sprite_source_size["y"]) + float(frame["h"]) / 2.0
		var anchor_x = float(source_size["w"]) / 2.0
		var anchor_y = float(source_size["h"]) / 2.0
		if preview_sprite_anchor_mode == "bottom":
			anchor_y = float(source_size["h"])
		return Vector2(trimmed_cx - anchor_x, trimmed_cy - anchor_y)
	elif sprite_source_size != null:
		return Vector2(float(sprite_source_size["x"]), float(sprite_source_size["y"]))
	return Vector2.ZERO

func _apply_preview_state() -> void:
	current_species_id = "BULBASAUR"
	current_is_caught = true
	_refresh_entry_view()

func _resolve_species_caught_state(species_id: String, fallback_is_caught: bool) -> bool:
	var normalized_species_id = species_id.strip_edges().to_upper()
	if normalized_species_id.empty():
		return fallback_is_caught

	if fallback_is_caught:
		return true

	var tree = get_tree()
	if tree == null:
		return false

	if runtime_state_script != null and runtime_state_script.has_caught_species(tree, normalized_species_id):
		return true

	return false

func _on_close_button_pressed() -> void:
	emit_signal("close_requested")
