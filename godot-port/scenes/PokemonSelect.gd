tool
extends Control

const SPECIES_CATALOG_PATH := "res://godot-minimal-assets/data/species-catalog.v1.json"
const BATTLE_SCENE_PATH := "res://scenes/BattleScreen.tscn"
const TYPE_TEXTURE_REL := "assets/images/types.png"
const TYPE_ATLAS_REL := "assets/images/types.json"
const EditorPreviewSync = preload("res://logic/EditorPreviewSync.gd")
const EDITOR_PREVIEW_LIST_SPECIES := [
	"BULBASAUR",
	"IVYSAUR",
	"VENUSAUR",
	"CHARMANDER",
	"CHARMELEON",
	"CHARIZARD",
]
var runtime_state_script = load("res://logic/RuntimeState.gd")

export(float) var ui_scale := 2.0
export(float) var preview_anim_frame_sec := 0.1
export(String, "center", "bottom") var preview_sprite_anchor_mode := "bottom"
export(float) var preview_sprite_scale := 1.0
export(bool) var editor_preview_enabled := true
export(int) var editor_preview_pokedex_number := 1
export(String) var editor_preview_species_name := "BULBASAUR"
export(String) var editor_preview_type1 := "grass"
export(String) var editor_preview_type2 := "poison"

var ui_scale_root = null
var starter_list = null
var current_pokemon_sprite = null
var pokemon_number_label = null
var pokemon_label = null
var details_type1_sprite = null
var details_type2_sprite = null
var start_button = null
var refresh_button = null
var quit_button = null
var status_label = null

var minimal_assets_path = "res://godot-minimal-assets/"
var selected_species_entry = null
var species_entries := []
var preview_sprite_frames := []
var preview_anim_index := 0
var preview_anim_elapsed := 0.0
var preview_sprite_base_scale := Vector2.ONE
var editor_preview_seeded := false
var editor_preview_last_pokedex := -1
var editor_preview_list_seeded := false

func _resolve_first_existing(paths: Array):
	for path in paths:
		var candidate = get_node_or_null(String(path))
		if candidate != null:
			return candidate
	return null

func _ready():
	ui_scale_root = _resolve_first_existing([
		"UiScaleRoot",
	])
	starter_list = _resolve_first_existing([
		"UiScaleRoot/MenuRoot/MenuCard/StarterScroll/StarterList",
		"UiScaleRoot/MenuRoot@MenuCard@StarterScroll@StarterList",
		"MenuRoot@MenuCard@StarterScroll@StarterList",
	])
	current_pokemon_sprite = _resolve_first_existing([
		"UiScaleRoot/MenuRoot/CurrentPokemonSprite",
		"UiScaleRoot/MenuRoot@CurrentPokemonSprite",
		"MenuRoot@CurrentPokemonSprite",
	])
	pokemon_number_label = _resolve_first_existing([
		"UiScaleRoot/MenuRoot/MenuCard/PokemonNumberLabel",
		"UiScaleRoot/MenuRoot@MenuCard@PokemonNumberLabel",
		"MenuRoot@MenuCard@PokemonNumberLabel",
	])
	pokemon_label = _resolve_first_existing([
		"UiScaleRoot/MenuRoot/MenuCard/PokemonLabel",
		"UiScaleRoot/MenuRoot@MenuCard@PokemonLabel",
		"MenuRoot@MenuCard@PokemonLabel",
	])
	details_type1_sprite = _resolve_first_existing([
		"UiScaleRoot/MenuRoot/MenuCard/DetailsType1Sprite",
		"UiScaleRoot/MenuRoot@MenuCard@DetailsType1Sprite",
		"MenuRoot@MenuCard@DetailsType1Sprite",
	])
	details_type2_sprite = _resolve_first_existing([
		"UiScaleRoot/MenuRoot/MenuCard/DetailsType2Sprite",
		"UiScaleRoot/MenuRoot@MenuCard@DetailsType2Sprite",
		"MenuRoot@MenuCard@DetailsType2Sprite",
	])
	status_label = _resolve_first_existing([
		"UiScaleRoot/MenuRoot/MenuCard/StatusLabel",
		"UiScaleRoot/MenuRoot@MenuCard@StatusLabel",
		"MenuRoot@MenuCard@StatusLabel",
	])
	start_button = _resolve_first_existing([
		"UiScaleRoot/MenuRoot/MenuCard/FooterRow/StartButton",
		"UiScaleRoot/MenuRoot@MenuCard@FooterRow@StartButton",
		"MenuRoot@MenuCard@FooterRow@StartButton",
	])
	refresh_button = _resolve_first_existing([
		"UiScaleRoot/MenuRoot/MenuCard/FooterRow/RefreshButton",
		"UiScaleRoot/MenuRoot@MenuCard@FooterRow@RefreshButton",
		"MenuRoot@MenuCard@FooterRow@RefreshButton",
	])
	quit_button = _resolve_first_existing([
		"UiScaleRoot/MenuRoot/MenuCard/FooterRow/QuitButton",
		"UiScaleRoot/MenuRoot@MenuCard@FooterRow@QuitButton",
		"MenuRoot@MenuCard@FooterRow@QuitButton",
	])

	if ui_scale_root != null:
		ui_scale_root.rect_scale = Vector2(ui_scale, ui_scale)

	if starter_list == null or current_pokemon_sprite == null or pokemon_number_label == null or pokemon_label == null or status_label == null:
		push_error("PokemonSelect scene is missing required UI nodes. Check MenuRoot/MenuCard structure in PokemonSelectScreen.tscn.")
		return
	preview_sprite_base_scale = current_pokemon_sprite.scale
	if Engine.editor_hint:
		if editor_preview_enabled:
			_apply_editor_preview_state()
		return
	if start_button == null or refresh_button == null or quit_button == null:
		push_error("PokemonSelect scene is missing footer buttons. Check UiScaleRoot/MenuRoot/MenuCard/FooterRow paths in PokemonSelectScreen.tscn.")
		return
	start_button.disabled = true
	start_button.connect("pressed", self, "_on_StartButton_pressed")
	refresh_button.connect("pressed", self, "_on_RefreshButton_pressed")
	quit_button.connect("pressed", self, "_on_QuitButton_pressed")
	configure_type_sprite(details_type1_sprite)
	configure_type_sprite(details_type2_sprite)
	_load_species_catalog()
	if species_entries.empty():
		status_label.text = "Species catalog not found yet. Generate the catalog to populate this menu."
		pokemon_number_label.text = "000"
		pokemon_label.text = "Pokemon"
		current_pokemon_sprite.texture = null
		preview_sprite_frames.clear()
		preview_anim_index = 0
		preview_anim_elapsed = 0.0
		details_type1_sprite.visible = false
		details_type2_sprite.visible = false
		return

	status_label.text = "Select a starter Pokemon to continue."
	_select_species_entry(species_entries[0])

func _apply_editor_preview_state() -> void:
	if current_pokemon_sprite == null or pokemon_number_label == null or pokemon_label == null:
		return
	if ui_scale_root != null:
		ui_scale_root.rect_scale = Vector2(ui_scale, ui_scale)
	if status_label != null:
		status_label.visible = false
	if start_button != null:
		start_button.disabled = false
	_apply_editor_preview_list_state()

	var preview_number = max(1, editor_preview_pokedex_number)
	pokemon_number_label.text = "%03d" % preview_number
	pokemon_label.text = editor_preview_species_name.strip_edges()
	if pokemon_label.text.empty():
		pokemon_label.text = "Pokemon"

	configure_type_sprite(details_type1_sprite)
	configure_type_sprite(details_type2_sprite)
	apply_type_badge(details_type1_sprite, editor_preview_type1)
	if editor_preview_type2.strip_edges().empty():
		if details_type2_sprite != null:
			details_type2_sprite.visible = false
	else:
		apply_type_badge(details_type2_sprite, editor_preview_type2)

	if (not editor_preview_seeded) or editor_preview_last_pokedex != preview_number:
		load_preview_sprite(preview_number)
		editor_preview_seeded = true
		editor_preview_last_pokedex = preview_number

func _apply_editor_preview_list_state() -> void:
	if starter_list == null:
		return
	_clear_starter_buttons()
	for species_id in EDITOR_PREVIEW_LIST_SPECIES:
		var button = Button.new()
		button.rect_min_size = Vector2(0, 24)
		button.text = String(species_id)
		button.disabled = true
		starter_list.add_child(button)
	editor_preview_list_seeded = true

func _refresh_editor_preview_state() -> void:
	if ui_scale_root != null:
		ui_scale_root.rect_scale = Vector2(ui_scale, ui_scale)
	if starter_list != null and (not editor_preview_list_seeded or starter_list.get_child_count() == 0):
		_apply_editor_preview_list_state()
	if current_pokemon_sprite != null:
		var scale_mul = max(0.01, preview_sprite_scale)
		current_pokemon_sprite.scale = Vector2(preview_sprite_base_scale.x * scale_mul, preview_sprite_base_scale.y * scale_mul)
	if details_type1_sprite != null:
		apply_type_badge(details_type1_sprite, editor_preview_type1)
	if details_type2_sprite != null:
		if editor_preview_type2.strip_edges().empty():
			details_type2_sprite.visible = false
		else:
			apply_type_badge(details_type2_sprite, editor_preview_type2)

func resource_exists(path: String) -> bool:
	if ResourceLoader.exists(path):
		return true
	var f = File.new()
	return f.file_exists(path)

func configure_type_sprite(type_sprite):
	if type_sprite == null:
		return
	type_sprite.centered = false
	type_sprite.region_enabled = true
	type_sprite.visible = false

func _load_species_catalog():
	species_entries.clear()
	_clear_starter_buttons()

	var file := File.new()
	if not file.file_exists(SPECIES_CATALOG_PATH):
		return

	if file.open(SPECIES_CATALOG_PATH, File.READ) != OK:
		status_label.text = "Failed to read species catalog."
		return

	var parse_result = JSON.parse(file.get_as_text())
	file.close()
	if parse_result.error != OK or parse_result.result == null:
		status_label.text = "Failed to parse species catalog."
		return

	var payload = parse_result.result
	if not (payload is Dictionary):
		status_label.text = "Species catalog format is invalid."
		return

	var items = payload.get("items", [])
	if not (items is Array):
		status_label.text = "Species catalog items are missing."
		return

	for item in items:
		if item is Dictionary:
			species_entries.append(item)

	species_entries.sort_custom(self, "_sort_species_by_pokedex")
	for species_entry in species_entries:
		_add_species_button(species_entry)

func _add_species_button(species_entry):
	var button = Button.new()
	button.rect_min_size = Vector2(0, 24)
	button.text = _format_species_button_text(species_entry)
	button.connect("pressed", self, "_on_species_button_pressed", [species_entry])
	starter_list.add_child(button)

func _clear_starter_buttons():
	for child in starter_list.get_children():
		child.queue_free()

func _sort_species_by_pokedex(a, b):
	return int(a.get("pokedex_number", 99999)) < int(b.get("pokedex_number", 99999))

func _format_species_button_text(species_entry: Dictionary) -> String:
	var species_id = String(species_entry.get("species_id", "UNKNOWN"))
	return species_id

func _on_species_button_pressed(species_entry):
	_select_species_entry(species_entry)

func _select_species_entry(species_entry):
	if not (species_entry is Dictionary):
		return

	selected_species_entry = species_entry
	var species_id = String(species_entry.get("species_id", "UNKNOWN"))
	var species_name = String(species_entry.get("name", species_id))
	var pokedex_number = int(species_entry.get("pokedex_number", 0))
	var types = species_entry.get("types", [])

	pokemon_number_label.text = "%03d" % pokedex_number
	pokemon_label.text = species_name
	load_preview_sprite(pokedex_number)
	refresh_type_badges(types)
	start_button.disabled = false
	status_label.text = "Selected %s. Press Continue to start battle." % species_name

func refresh_type_badges(types):
	if not (types is Array) or types.empty():
		details_type1_sprite.visible = false
		details_type2_sprite.visible = false
		return

	apply_type_badge(details_type1_sprite, String(types[0]))
	if types.size() > 1:
		apply_type_badge(details_type2_sprite, String(types[1]))
	else:
		details_type2_sprite.visible = false

func apply_type_badge(type_sprite, type_name: String):
	if type_sprite == null:
		return

	var texture_path = minimal_assets_path + TYPE_TEXTURE_REL
	var atlas_json_path = minimal_assets_path + TYPE_ATLAS_REL
	if not resource_exists(texture_path):
		type_sprite.visible = false
		return

	type_sprite.texture = load(texture_path)
	type_sprite.region_enabled = true
	type_sprite.centered = false

	var frame_name = type_name.strip_edges().to_lower()
	if frame_name.empty():
		frame_name = "unknown"

	var frame_data = parse_sprite_frame(atlas_json_path, frame_name)
	if frame_data == null:
		frame_data = parse_sprite_frame(atlas_json_path, "unknown")
	if frame_data == null:
		type_sprite.visible = false
		return

	var frame = frame_data["frame"]
	type_sprite.region_rect = Rect2(frame["x"], frame["y"], frame["w"], frame["h"])
	type_sprite.visible = true

func load_preview_sprite(pokedex_number: int):
	var sprite_relative_path = "assets/images/pokemon/%d.png" % pokedex_number
	var atlas_relative_path = "assets/images/pokemon/%d.json" % pokedex_number
	var sprite_path = minimal_assets_path + sprite_relative_path
	var json_path = minimal_assets_path + atlas_relative_path

	if not resource_exists(sprite_path):
		current_pokemon_sprite.texture = null
		return

	current_pokemon_sprite.texture = load(sprite_path)
	current_pokemon_sprite.centered = true
	current_pokemon_sprite.region_enabled = true
	current_pokemon_sprite.offset = Vector2.ZERO
	var scale_mul = max(0.01, preview_sprite_scale)
	current_pokemon_sprite.scale = Vector2(preview_sprite_base_scale.x * scale_mul, preview_sprite_base_scale.y * scale_mul)

	preview_sprite_frames = get_all_numeric_frames(json_path)
	if preview_sprite_frames.empty():
		var fallback_frame = parse_sprite_frame(json_path, "0001.png")
		if fallback_frame != null:
			preview_sprite_frames.append(fallback_frame)

	preview_anim_index = 0
	preview_anim_elapsed = 0.0

	if not preview_sprite_frames.empty():
		apply_preview_sprite_frame(current_pokemon_sprite, preview_sprite_frames[0])
	else:
		current_pokemon_sprite.region_enabled = false
		current_pokemon_sprite.offset = Vector2.ZERO

func parse_sprite_frame(json_path: String, frame_name: String):
	var frames = parse_all_sprite_frames(json_path)
	if frames.empty():
		return null

	for frame in frames:
		if frame.has("filename") and frame["filename"] == frame_name:
			return frame

	return null

func parse_all_sprite_frames(json_path: String) -> Array:
	var f = File.new()
	if not f.file_exists(json_path):
		return []

	f.open(json_path, File.READ)
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

func get_all_numeric_frames(json_path: String) -> Array:
	var frames = parse_all_sprite_frames(json_path)
	if frames.empty():
		return []

	var indexed := []
	for frame in frames:
		if frame == null or not frame.has("filename"):
			continue
		var filename = String(frame["filename"])
		if filename.length() != 8:
			continue
		if not filename.ends_with(".png"):
			continue
		var frame_num_text = filename.substr(0, 4)
		if not frame_num_text.is_valid_integer():
			continue
		indexed.append({
			"index": int(frame_num_text),
			"frame": frame,
		})

	indexed.sort_custom(self, "_sort_frame_dicts")

	var result := []
	for item in indexed:
		result.append(item["frame"])

	return result

func _sort_frame_dicts(a: Dictionary, b: Dictionary) -> bool:
	return int(a["index"]) < int(b["index"])

func apply_preview_sprite_frame(sprite_node: Sprite, sprite_info: Dictionary):
	if sprite_node == null or sprite_info == null:
		return

	var frame = sprite_info["frame"]
	sprite_node.region_rect = Rect2(frame["x"], frame["y"], frame["w"], frame["h"])

	var sprite_source_size = sprite_info.get("spriteSourceSize", null)
	var source_size = sprite_info.get("sourceSize", null)
	if sprite_source_size != null and source_size != null:
		var trimmed_cx = float(sprite_source_size["x"]) + float(frame["w"]) / 2.0
		var trimmed_cy = float(sprite_source_size["y"]) + float(frame["h"]) / 2.0
		var anchor_x = float(source_size["w"]) / 2.0
		var anchor_y = float(source_size["h"]) / 2.0
		if preview_sprite_anchor_mode == "bottom":
			anchor_y = float(source_size["h"])
		sprite_node.offset = Vector2(trimmed_cx - anchor_x, trimmed_cy - anchor_y)
	elif sprite_source_size != null:
		sprite_node.offset = Vector2(float(sprite_source_size["x"]), float(sprite_source_size["y"]))
	else:
		sprite_node.offset = Vector2.ZERO

func _process(delta):
	if Engine.editor_hint:
		EditorPreviewSync.sync_scene(
			self,
			editor_preview_enabled,
			editor_preview_seeded,
			"_apply_editor_preview_state",
			"_refresh_editor_preview_state"
		)
		return

	if preview_anim_frame_sec <= 0.0:
		return
	if preview_sprite_frames.size() <= 1:
		return

	preview_anim_elapsed += delta
	while preview_anim_elapsed >= preview_anim_frame_sec:
		preview_anim_elapsed -= preview_anim_frame_sec
		preview_anim_index = (preview_anim_index + 1) % preview_sprite_frames.size()
		apply_preview_sprite_frame(current_pokemon_sprite, preview_sprite_frames[preview_anim_index])

func _on_StartButton_pressed():
	if selected_species_entry == null:
		return
	var selected_species_id = String(selected_species_entry.get("species_id", "UNKNOWN")).strip_edges().to_upper()
	if runtime_state_script != null:
		runtime_state_script.ensure_party_with_starter(get_tree(), selected_species_id, 5)
	else:
		get_tree().set_meta("selected_species_id", selected_species_id)
	var result = get_tree().change_scene(BATTLE_SCENE_PATH)
	if result != OK:
		push_error("Failed to open battle scene: %s" % BATTLE_SCENE_PATH)

func _on_RefreshButton_pressed():
	_load_species_catalog()
	if not species_entries.empty() and selected_species_entry == null:
		_select_species_entry(species_entries[0])

func _on_QuitButton_pressed():
	get_tree().quit()
