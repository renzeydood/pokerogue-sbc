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
const BIOME_WILD_POOL_CATALOG_PATH := "res://data/biome-wild-pools.v1.json"
const BASE_STATS_KEYS := ["hp", "atk", "def", "sp_atk", "sp_def", "spd"]
const BASE_STATS_LABELS := ["HP", "ATK", "DEF", "SPATK", "SPDEF", "SPD"]
const BASE_BAR_COLOR := Color(0.4, 0.666667, 0.6, 1)
const AtlasFrameParser = preload("res://logic/AtlasFrameParser.gd")

onready var ui_scale_root = $Panel/UiScaleRoot
onready var current_pokemon_sprite = $Panel/UiScaleRoot/CurrentPokemonSprite
onready var details_type1_sprite = $Panel/UiScaleRoot/DetailsType1Sprite
onready var details_type2_sprite = $Panel/UiScaleRoot/DetailsType2Sprite
onready var growth_rate_label = get_node_or_null("Panel/UiScaleRoot/GrowthRateLabel")
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
onready var biomes_window = $Panel/UiScaleRoot/BiomesWindow
onready var biomes_window_list = get_node_or_null("Panel/UiScaleRoot/BiomesWindow/ActionContentMargin/ActionButtonList")
onready var biomes_window_cancel_button = get_node_or_null("Panel/UiScaleRoot/BiomesWindow/ActionContentMargin/ActionButtonList/CancelButton")
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
var biome_catalog_cache := {}
var biome_catalog_loaded := false
var biome_lookup_cache := {}
var biome_list_visible := false
var biomes_window_default_height := 0.0

func _ready() -> void:
	set_process(true)
	if ui_scale_root != null:
		ui_scale_root.rect_scale = Vector2(ui_scale, ui_scale)
	_setup_action_buttons()
	_setup_type_sprites()
	_setup_base_stats_window()
	_setup_biomes_window()
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
	if biome_list_visible:
		_biomes_hide_list()
		return true
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
		body_label.text = _build_default_entry_body_text(display_species)
	_refresh_growth_rate_text()

func _refresh_growth_rate_text() -> void:
	if growth_rate_label == null:
		return

	var growth_rate_text = "----------"
	if current_is_caught:
		var species_entry = _get_species_entry(current_species_id)
		if not species_entry.empty():
			var raw_growth_rate = str(species_entry.get("growth_rate", "")).strip_edges().to_upper()
			if not raw_growth_rate.empty():
				growth_rate_text = _format_growth_rate(raw_growth_rate)

	growth_rate_label.text = "Growth Rate: %s" % growth_rate_text

func _format_growth_rate(raw_growth_rate: String) -> String:
	var words = raw_growth_rate.split("_", false)
	for i in range(words.size()):
		var word = str(words[i]).strip_edges().to_lower()
		if word.empty():
			continue
		words[i] = word.substr(0, 1).to_upper() + word.substr(1)
	return " ".join(words)

func _refresh_entry_view() -> void:
	biome_list_visible = false
	_refresh_entry_text()
	_load_species_base_stats()
	_populate_base_stats_window()
	_hide_base_stats_window()
	_hide_biomes_window()
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
	if biomes_button != null and not biomes_button.is_connected("pressed", self, "_on_BiomesButton_pressed"):
		biomes_button.connect("pressed", self, "_on_BiomesButton_pressed")

	if base_stats_button != null:
		base_stats_button.disabled = false
	for button in buttons:
		if button == null or button == base_stats_button:
			continue
		if button == biomes_button:
			button.disabled = false
			continue
		button.disabled = true

	if action_text_label != null:
		action_text_label.text = "Show its base stats or biome list."

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
	elif button == biomes_button:
		action_text_label.text = "Show where this Pokemon can be found."
	else:
		action_text_label.text = "Overlay not implemented yet."

func _on_BaseStatsButton_pressed() -> void:
	if base_stats_window == null:
		return
	_biomes_hide_list()
	if base_stats_window.visible:
		_hide_base_stats_window()
	else:
		_show_base_stats_window()

func _on_BiomesButton_pressed() -> void:
	if current_species_id.strip_edges().empty():
		return
	if biome_list_visible:
		_biomes_hide_list()
		return
	_show_biome_list()

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
		var key = str(BASE_STATS_KEYS[i])
		var value = int(current_base_stats.get(key, 0))
		pending_base_stat_values.append(value)
		total += value
		if i < labels.size() and labels[i] != null:
			labels[i].text = "%s: %d" % [str(BASE_STATS_LABELS[i]), value]
	if total_label != null:
		total_label.text = "Total: %d" % total
	if base_stats_window != null and base_stats_window.visible:
		_reflow_base_stat_bars()

func _show_base_stats_window() -> void:
	if base_stats_window == null:
		return
	_hide_biomes_window()
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

func _show_biome_list() -> void:
	if biomes_window == null:
		return
	biome_list_visible = true
	if base_stats_window != null:
		base_stats_window.visible = false
	_update_biomes_window_contents()
	_resize_biomes_window_to_contents()
	biomes_window.visible = true
	biomes_window.raise()
	if action_text_label != null:
		action_text_label.text = "Biomes shown."

func _biomes_hide_list() -> void:
	if not biome_list_visible:
		return
	_hide_biomes_window()

func _hide_biomes_window() -> void:
	biome_list_visible = false
	if biomes_window != null:
		biomes_window.visible = false
	if action_text_label != null:
		action_text_label.text = "Show its base stats or biome list."

func _setup_biomes_window() -> void:
	if biomes_window != null:
		biomes_window.visible = false
		biomes_window.anchor_top = 1.0
		biomes_window.anchor_bottom = 1.0
	if biomes_window_list != null:
		biomes_window_list.size_flags_vertical = 0
		biomes_window_default_height = max(0.0, biomes_window_list.get_combined_minimum_size().y + 12.0)
	if biomes_window_cancel_button != null and not biomes_window_cancel_button.is_connected("pressed", self, "_on_BiomesWindowCancelButton_pressed"):
		biomes_window_cancel_button.connect("pressed", self, "_on_BiomesWindowCancelButton_pressed")

func _on_BiomesWindowCancelButton_pressed() -> void:
	_hide_biomes_window()

func _update_biomes_window_contents() -> void:
	if biomes_window_list == null:
		return
	for child in biomes_window_list.get_children():
		if child == biomes_window_cancel_button:
			continue
		biomes_window_list.remove_child(child)
		child.queue_free()
	var biome_names = _get_found_biome_names_for_current_species()
	var insert_index = biomes_window_list.get_child_count()
	if biome_names.empty():
		var empty_label = Label.new()
		empty_label.text = "No biome data found."
		empty_label.size_flags_vertical = 0
		biomes_window_list.add_child(empty_label)
		biomes_window_list.move_child(empty_label, max(0, insert_index - 1))
	else:
		for biome_name in biome_names:
			var biome_label = Label.new()
			biome_label.text = biome_name
			biome_label.size_flags_vertical = 0
			biomes_window_list.add_child(biome_label)
			biomes_window_list.move_child(biome_label, max(0, biomes_window_list.get_child_count() - 2))
	if biomes_window_cancel_button != null:
		biomes_window_cancel_button.size_flags_vertical = 0
	biomes_window_list.minimum_size_changed()

func _resize_biomes_window_to_contents() -> void:
	if biomes_window == null:
		return
	var content_height := 0.0
	if biomes_window_list != null:
		content_height = biomes_window_list.get_combined_minimum_size().y + 12.0
	content_height = max(24.0, content_height)
	var target_height = max(biomes_window_default_height, content_height)
	biomes_window.margin_top = biomes_window.margin_bottom - target_height
	biomes_window.rect_min_size.y = target_height

func _build_default_entry_body_text(display_species: String) -> String:
	return "Pokedex overlays for %s are wired. Select Base Stats or Biomes to continue." % display_species

func _format_biome_name(biome_id: String) -> String:
	var raw = biome_id.strip_edges().replace("_", " ").replace("-", " ")
	if raw.empty():
		return "Unknown"
	var words = raw.split(" ", false)
	for i in range(words.size()):
		var word = str(words[i]).strip_edges()
		if word.empty():
			continue
		words[i] = word.substr(0, 1).to_upper() + word.substr(1)
	return " ".join(words)

func _build_biome_list_text() -> String:
	var biome_names = _get_found_biome_names_for_current_species()
	var display_species = current_species_id if not current_species_id.empty() else "UNKNOWN"
	if biome_names.empty():
		return "No biome data found for %s.\n\nThis usually means the species is not present in the current biome pool export." % display_species
	return "Found in:\n- %s" % "\n- ".join(biome_names)

func _get_found_biome_names_for_current_species() -> Array:
	var lineage_ids = _get_species_lineage_ids(current_species_id)
	var biome_ids := {}
	for species_id in lineage_ids:
		for biome_id in _get_biomes_for_species(species_id):
			biome_ids[biome_id] = true
	var sorted_ids := biome_ids.keys()
	sorted_ids.sort()
	var biome_names := []
	for biome_id in sorted_ids:
		biome_names.append(_format_biome_name(str(biome_id)))
	return biome_names

func _get_species_lineage_ids(species_id: String) -> Array:
	var normalized_species_id = species_id.strip_edges().to_upper()
	if normalized_species_id.empty():
		return []
	var lineage := [normalized_species_id]
	var species_entry = _get_species_entry(normalized_species_id)
	if species_entry.empty():
		return lineage
	var prevolution_id = str(species_entry.get("prevolution_species_id", "")).strip_edges().to_upper()
	if not prevolution_id.empty() and not lineage.has(prevolution_id):
		lineage.append(prevolution_id)
	var evolution_ids = species_entry.get("evolution_species_ids", [])
	if typeof(evolution_ids) == TYPE_ARRAY:
		for evo_id in evolution_ids:
			var normalized_evo_id = str(evo_id).strip_edges().to_upper()
			if normalized_evo_id.empty() or lineage.has(normalized_evo_id):
				continue
			lineage.append(normalized_evo_id)
	return lineage

func _get_biomes_for_species(species_id: String) -> Array:
	var normalized_species_id = species_id.strip_edges().to_upper()
	if normalized_species_id.empty():
		return []
	if biome_lookup_cache.has(normalized_species_id):
		var cached = biome_lookup_cache[normalized_species_id]
		if typeof(cached) == TYPE_ARRAY:
			return cached.duplicate(true)
		return []

	var catalog = _get_biome_wild_pool_catalog()
	var biome_ids := []
	if typeof(catalog) == TYPE_DICTIONARY:
		var biomes = catalog.get("biomes", {})
		if typeof(biomes) == TYPE_DICTIONARY:
			for raw_biome_id in biomes.keys():
				var biome_entry = biomes[raw_biome_id]
				if typeof(biome_entry) != TYPE_DICTIONARY:
					continue
				if _biome_entry_contains_species(biome_entry, normalized_species_id):
					biome_ids.append(str(raw_biome_id))
	biome_ids.sort()
	biome_lookup_cache[normalized_species_id] = biome_ids.duplicate(true)
	return biome_ids.duplicate(true)

func _biome_entry_contains_species(biome_entry: Dictionary, species_id: String) -> bool:
	var tiers = biome_entry.get("tiers", {})
	if typeof(tiers) != TYPE_DICTIONARY:
		return false
	for tier_name in tiers.keys():
		var tier_entries = tiers[tier_name]
		if typeof(tier_entries) != TYPE_ARRAY:
			continue
		for entry in tier_entries:
			if typeof(entry) != TYPE_DICTIONARY:
				continue
			if str(entry.get("species_id", "")).strip_edges().to_upper() == species_id:
				return true
	return false

func _get_biome_wild_pool_catalog() -> Dictionary:
	if biome_catalog_loaded:
		if typeof(biome_catalog_cache) == TYPE_DICTIONARY:
			return biome_catalog_cache
		return {}

	biome_catalog_loaded = true
	var payload = _read_json_payload(BIOME_WILD_POOL_CATALOG_PATH)
	if typeof(payload) != TYPE_DICTIONARY:
		biome_catalog_cache = {}
		return {}
	if typeof(payload.get("biomes", {})) != TYPE_DICTIONARY:
		biome_catalog_cache = {}
		return {}
	biome_catalog_cache = payload
	return biome_catalog_cache

func _read_json_payload(path: String):
	var file = File.new()
	if not file.file_exists(path):
		return null
	if file.open(path, File.READ) != OK:
		return null
	var json_text = file.get_as_text()
	file.close()

	var parsed = JSON.parse(json_text)
	if parsed.error != OK:
		return null

	return parsed.result

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
		var type_name = str(raw_type).strip_edges().to_upper()
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

	_apply_type_badge(details_type1_sprite, str(current_species_types[0]))
	if current_species_types.size() >= 2:
		_apply_type_badge(details_type2_sprite, str(current_species_types[1]))
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

	var texture_path = minimal_assets_path + str(sprite_paths.get("texture_rel", ""))
	var atlas_path = minimal_assets_path + str(sprite_paths.get("atlas_rel", ""))
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
	return AtlasFrameParser.parse_sprite_frame(json_path, frame_name)

func _parse_all_sprite_frames(json_path: String) -> Array:
	return AtlasFrameParser.parse_all_sprite_frames(json_path)

func _get_all_numeric_frames(json_path: String) -> Array:
	var frames = _parse_all_sprite_frames(json_path)
	if frames.empty():
		return []

	var indexed := []
	for frame in frames:
		if frame == null or not frame.has("filename"):
			continue
		var frame_index = _extract_numeric_frame_index(str(frame["filename"]))
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
