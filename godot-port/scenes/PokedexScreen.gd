extends Control

signal close_requested

export(float) var ui_scale := 2.0
export(bool) var editor_preview_enabled := true
export(float) var pokemon_anim_frame_sec := 0.1
export(float) var preview_sprite_scale := 1.0
export(String, "center", "bottom") var preview_sprite_anchor_mode := "bottom"
export(float) var preview_sprite_vertical_nudge_px := 0.0
export(bool) var use_temporary_seed_species := false
export(String) var temporary_seed_profile_id := "ui_party_showcase"

const TYPE_TEXTURE_REL := "assets/images/types.png"
const TYPE_ATLAS_REL := "assets/images/types.json"

var runtime_state_script = load("res://logic/RuntimeState.gd")
var catalog_loader_script = load("res://logic/CatalogDataLoader.gd")
var pokedex_entry_overlay_scene = load("res://scenes/PokedexEntryOverlay.tscn")
var minimal_assets_path = "res://godot-minimal-assets/"

onready var ui_scale_root = $Backdrop/Panel/UiScaleRoot
onready var summary_label = $Backdrop/Panel/UiScaleRoot/AllPokemonWindow/ContentMargin/ListScroll/ListContent/SummaryLabel
onready var species_button_list = $Backdrop/Panel/UiScaleRoot/AllPokemonWindow/ContentMargin/ListScroll/ListContent/SpeciesButtonList
onready var current_pokemon_sprite = get_node_or_null("Backdrop/Panel/UiScaleRoot/CurrentPokemonSprite")
onready var pokemon_label = get_node_or_null("Backdrop/Panel/UiScaleRoot/PokemonLabel")
onready var pokemon_number_label = get_node_or_null("Backdrop/Panel/UiScaleRoot/PokemonNumberLabel")
onready var details_type1_sprite = get_node_or_null("Backdrop/Panel/UiScaleRoot/DetailsType1Sprite")
onready var details_type2_sprite = get_node_or_null("Backdrop/Panel/UiScaleRoot/DetailsType2Sprite")
onready var close_button = get_node_or_null("Backdrop/Panel/UiScaleRoot/Footer/BackButton")

var caught_species_ids: Array = []
var species_buttons: Array = []
var pokedex_entry_overlay = null
var catalog_loader = null
var selected_species_id := ""
var selected_species_entry := {}
var pending_entry_species_id := ""
var sprite_frames: Array = []
var sprite_anim_index := 0
var sprite_anim_elapsed := 0.0
var preview_sprite_base_scale := Vector2.ONE
var preview_sprite_base_offset := Vector2.ZERO
var preview_sprite_global_reference_offset := Vector2.ZERO

func _ready() -> void:
	set_process(true)
	if ui_scale_root != null:
		ui_scale_root.rect_scale = Vector2(ui_scale, ui_scale)
	if current_pokemon_sprite != null:
		preview_sprite_base_scale = current_pokemon_sprite.scale
		preview_sprite_base_offset = current_pokemon_sprite.offset
		_capture_preview_sprite_reference_offset()
	_setup_type_sprites()
	if Engine.editor_hint:
		visible = editor_preview_enabled
	else:
		visible = true
		_setup_pokedex_entry_overlay()
		_open_runtime_roster()
	if close_button != null and not close_button.is_connected("pressed", self, "_on_close_button_pressed"):
		close_button.connect("pressed", self, "_on_close_button_pressed")

func _process(_delta: float) -> void:
	if Engine.editor_hint:
		if ui_scale_root != null:
			ui_scale_root.rect_scale = Vector2(ui_scale, ui_scale)
		return
	if not visible:
		return
	if Input.is_action_just_pressed("ui_back") or Input.is_action_just_pressed("ui_cancel"):
		if _handle_back_request():
			return
	_update_sprite_animation(_delta)

func _input(event) -> void:
	if not visible:
		return
	if not (event is InputEventKey):
		return
	if not event.pressed or event.echo:
		return
	if not event.is_action_pressed("ui_back") and not event.is_action_pressed("ui_cancel") and not _is_back_key_event(event):
		return
	if _handle_back_request():
		accept_event()

func _is_back_key_event(event: InputEventKey) -> bool:
	if event == null:
		return false
	return event.scancode == KEY_BACKSPACE or event.scancode == KEY_ESCAPE

func _handle_back_request() -> bool:
	if pokedex_entry_overlay != null and pokedex_entry_overlay.visible:
		if pokedex_entry_overlay.has_method("handle_back_action") and pokedex_entry_overlay.handle_back_action():
			return true
		pokedex_entry_overlay.close_menu()
		focus_default()
		return true
	return handle_back_action()

func open_menu(caught_species: Array) -> void:
	caught_species_ids = []
	pending_entry_species_id = ""
	for raw_species_id in caught_species:
		var species_id = String(raw_species_id).strip_edges().to_upper()
		if species_id.empty() or caught_species_ids.has(species_id):
			continue
		caught_species_ids.append(species_id)

	_refresh_list_text()
	if not caught_species_ids.empty():
		_select_species(caught_species_ids[0])
	else:
		_clear_species_preview()
	visible = true
	focus_default()

func _setup_pokedex_entry_overlay() -> void:
	if pokedex_entry_overlay_scene == null:
		return
	pokedex_entry_overlay = pokedex_entry_overlay_scene.instance()
	if pokedex_entry_overlay == null:
		return
	pokedex_entry_overlay.visible = false
	if not pokedex_entry_overlay.is_connected("close_requested", self, "_on_PokedexEntryOverlay_close_requested"):
		pokedex_entry_overlay.connect("close_requested", self, "_on_PokedexEntryOverlay_close_requested")
	add_child(pokedex_entry_overlay)
	pokedex_entry_overlay.raise()

func _open_runtime_roster() -> void:
	if runtime_state_script == null:
		open_menu([])
		return
	var caught_species = runtime_state_script.get_caught_species_ids(get_tree())
	if typeof(caught_species) != TYPE_ARRAY:
		caught_species = []
	if use_temporary_seed_species:
		open_menu(runtime_state_script.merge_species_ids_with_debug_seed_profile(caught_species, temporary_seed_profile_id))
		return
	open_menu(caught_species)

func close_menu() -> void:
	visible = false
	pending_entry_species_id = ""

func focus_default() -> void:
	if not visible:
		return
	if pokedex_entry_overlay != null and pokedex_entry_overlay.visible:
		pokedex_entry_overlay.focus_default()
		return
	for button in species_buttons:
		if button != null and not button.disabled:
			button.grab_focus()
			return
	if close_button != null:
		close_button.grab_focus()

func move_focus(_action_name: String) -> void:
	if pokedex_entry_overlay != null and pokedex_entry_overlay.visible:
		pokedex_entry_overlay.move_focus(_action_name)
		return
	focus_default()

func press_focused() -> void:
	if not visible:
		return
	if pokedex_entry_overlay != null and pokedex_entry_overlay.visible:
		pokedex_entry_overlay.press_focused()
		return
	var focus_owner = get_focus_owner()
	if focus_owner is Button and not focus_owner.disabled:
		focus_owner.emit_signal("pressed")

func handle_back_action() -> bool:
	if not visible:
		return false
	if pokedex_entry_overlay != null and pokedex_entry_overlay.visible:
		pokedex_entry_overlay.close_menu()
		focus_default()
		return true
	emit_signal("close_requested")
	return true

func is_overlay_focus_owner(focus_owner) -> bool:
	if focus_owner == null:
		return false
	if focus_owner == close_button:
		return true
	return false

func _refresh_list_text() -> void:
	if summary_label == null or species_button_list == null:
		return

	for child in species_button_list.get_children():
		species_button_list.remove_child(child)
		child.queue_free()
	species_buttons.clear()

	if caught_species_ids.empty():
		summary_label.text = "No Pokemon caught yet."
		return

	summary_label.text = "Caught: %d" % caught_species_ids.size()
	for i in range(caught_species_ids.size()):
		var species_id = String(caught_species_ids[i])
		var button = Button.new()
		button.text = "%03d %s" % [max(0, _get_species_dex_number(species_id)), species_id]
		button.flat = true
		button.align = Button.ALIGN_LEFT
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_ALL
		button.connect("pressed", self, "_on_species_button_pressed", [species_id])
		species_button_list.add_child(button)
		species_buttons.append(button)

func _open_species_entry(species_id: String) -> void:
	if pokedex_entry_overlay == null:
		return
	pokedex_entry_overlay.open_menu(species_id, true)
	pokedex_entry_overlay.raise()

func _on_species_button_pressed(species_id: String) -> void:
	var normalized_species_id = species_id.strip_edges().to_upper()
	if normalized_species_id.empty():
		return
	if pending_entry_species_id == normalized_species_id:
		_open_species_entry(normalized_species_id)
		pending_entry_species_id = ""
		return
	_select_species(normalized_species_id)
	pending_entry_species_id = normalized_species_id

func _select_species(species_id: String) -> void:
	selected_species_id = species_id.strip_edges().to_upper()
	selected_species_entry = _get_species_entry(selected_species_id)
	if selected_species_entry.empty():
		_clear_species_preview()
		return

	var display_name = String(selected_species_entry.get("name", selected_species_id)).strip_edges()
	if display_name.empty():
		display_name = selected_species_id
	if pokemon_label != null:
		pokemon_label.text = display_name
	if pokemon_number_label != null:
		pokemon_number_label.text = _format_species_number(_get_species_dex_number(selected_species_id))
	_refresh_type_badges(selected_species_entry.get("types", []))
	_load_species_sprite(selected_species_id)

func _clear_species_preview() -> void:
	selected_species_id = ""
	selected_species_entry = {}
	sprite_frames.clear()
	sprite_anim_index = 0
	sprite_anim_elapsed = 0.0
	if pokemon_label != null:
		pokemon_label.text = "Pokemon"
	if pokemon_number_label != null:
		pokemon_number_label.text = "---"
	if current_pokemon_sprite != null:
		current_pokemon_sprite.texture = null
		current_pokemon_sprite.region_enabled = false
		current_pokemon_sprite.offset = preview_sprite_base_offset
	if details_type1_sprite != null:
		details_type1_sprite.visible = false
	if details_type2_sprite != null:
		details_type2_sprite.visible = false

func _setup_type_sprites() -> void:
	for type_sprite in [details_type1_sprite, details_type2_sprite]:
		if type_sprite == null:
			continue
		type_sprite.centered = false
		type_sprite.region_enabled = true
		type_sprite.visible = false

func _refresh_type_badges(types) -> void:
	if details_type1_sprite == null or details_type2_sprite == null:
		return
	if typeof(types) != TYPE_ARRAY or types.empty():
		details_type1_sprite.visible = false
		details_type2_sprite.visible = false
		return
	_apply_type_badge(details_type1_sprite, String(types[0]))
	if types.size() > 1:
		_apply_type_badge(details_type2_sprite, String(types[1]))
	else:
		details_type2_sprite.visible = false

func _apply_type_badge(type_sprite, type_name: String) -> void:
	if type_sprite == null:
		return
	var texture_path = minimal_assets_path + TYPE_TEXTURE_REL
	var atlas_json_path = minimal_assets_path + TYPE_ATLAS_REL
	if not _resource_exists(texture_path):
		type_sprite.visible = false
		return
	type_sprite.texture = load(texture_path)
	type_sprite.region_enabled = true
	type_sprite.centered = false
	var frame_name = type_name.strip_edges().to_lower()
	if frame_name.empty():
		frame_name = "unknown"
	var frame_data = _parse_sprite_frame(atlas_json_path, frame_name)
	if frame_data == null:
		frame_data = _parse_sprite_frame(atlas_json_path, "unknown")
	if frame_data == null:
		type_sprite.visible = false
		return
	var frame = frame_data["frame"]
	type_sprite.region_rect = Rect2(frame["x"], frame["y"], frame["w"], frame["h"])
	type_sprite.visible = true

func _load_species_sprite(species_id: String) -> void:
	if current_pokemon_sprite == null:
		return
	var sprite_paths = _get_species_sprite_paths(species_id)
	if sprite_paths.empty():
		current_pokemon_sprite.texture = null
		current_pokemon_sprite.region_enabled = false
		sprite_frames.clear()
		return
	var texture_path = minimal_assets_path + String(sprite_paths.get("texture_rel", ""))
	var atlas_path = minimal_assets_path + String(sprite_paths.get("atlas_rel", ""))
	if not _resource_exists(texture_path):
		current_pokemon_sprite.texture = null
		current_pokemon_sprite.region_enabled = false
		sprite_frames.clear()
		return
	current_pokemon_sprite.texture = load(texture_path)
	current_pokemon_sprite.centered = true
	current_pokemon_sprite.region_enabled = true
	current_pokemon_sprite.offset = preview_sprite_base_offset
	var scale_mul = max(0.01, preview_sprite_scale)
	current_pokemon_sprite.scale = Vector2(preview_sprite_base_scale.x * scale_mul, preview_sprite_base_scale.y * scale_mul)
	sprite_frames = _get_all_numeric_frames(atlas_path)
	if sprite_frames.empty():
		var fallback_frame = _parse_sprite_frame(atlas_path, "0001.png")
		if fallback_frame != null:
			sprite_frames.append(fallback_frame)
	sprite_anim_index = 0
	sprite_anim_elapsed = 0.0
	if not sprite_frames.empty():
		_apply_preview_sprite_frame(current_pokemon_sprite, sprite_frames[0])
	else:
		current_pokemon_sprite.region_enabled = false
		current_pokemon_sprite.offset = preview_sprite_base_offset

func _update_sprite_animation(delta: float) -> void:
	if current_pokemon_sprite == null:
		return
	if pokemon_anim_frame_sec <= 0.0:
		return
	if sprite_frames.size() <= 1:
		return
	sprite_anim_elapsed += delta
	while sprite_anim_elapsed >= pokemon_anim_frame_sec:
		sprite_anim_elapsed -= pokemon_anim_frame_sec
		sprite_anim_index = (sprite_anim_index + 1) % sprite_frames.size()
		_apply_preview_sprite_frame(current_pokemon_sprite, sprite_frames[sprite_anim_index])

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
		var filename = String(frame["filename"])
		if filename.length() != 8:
			continue
		if not filename.ends_with(".png"):
			continue
		var frame_num_text = filename.substr(0, 4)
		if not frame_num_text.is_valid_integer():
			continue
		indexed.append({"index": int(frame_num_text), "frame": frame})
	indexed.sort_custom(self, "_sort_frame_dicts")
	var result := []
	for item in indexed:
		result.append(item["frame"])
	return result

func _sort_frame_dicts(a: Dictionary, b: Dictionary) -> bool:
	return int(a["index"]) < int(b["index"])

func _apply_preview_sprite_frame(sprite_node: Sprite, sprite_info: Dictionary) -> void:
	if sprite_node == null or sprite_info == null:
		return
	var frame = sprite_info["frame"]
	sprite_node.region_rect = Rect2(frame["x"], frame["y"], frame["w"], frame["h"])
	var frame_offset = _compute_preview_sprite_frame_offset(sprite_info)
	sprite_node.offset = preview_sprite_base_offset + (frame_offset - preview_sprite_global_reference_offset) + Vector2(0, preview_sprite_vertical_nudge_px)

func _capture_preview_sprite_reference_offset() -> void:
	preview_sprite_global_reference_offset = Vector2.ZERO
	if current_pokemon_sprite == null:
		return
	var default_atlas_path = minimal_assets_path + "assets/images/pokemon/1.json"
	var default_frame = _parse_sprite_frame(default_atlas_path, "0001.png")
	if default_frame == null:
		return
	preview_sprite_global_reference_offset = _compute_preview_sprite_frame_offset(default_frame)

func _compute_preview_sprite_frame_offset(sprite_info: Dictionary) -> Vector2:
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

func _resource_exists(path: String) -> bool:
	if ResourceLoader.exists(path):
		return true
	var file = File.new()
	return file.file_exists(path)

func _get_catalog_loader():
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()
	if catalog_loader != null and not catalog_loader.is_loaded():
		catalog_loader.load_catalogs()
	return catalog_loader

func _get_species_entry(species_id: String) -> Dictionary:
	var loader = _get_catalog_loader()
	if loader == null:
		return {}
	return loader.get_species(species_id)

func _get_species_dex_number(species_id: String) -> int:
	var loader = _get_catalog_loader()
	if loader == null:
		return -1
	return loader.get_species_dex_number(species_id)

func _get_species_sprite_paths(species_id: String) -> Dictionary:
	var loader = _get_catalog_loader()
	if loader == null:
		return {}
	return loader.build_sprite_resource_paths(species_id, false)

func _format_species_number(dex_number: int) -> String:
	if dex_number <= 0:
		return "---"
	return "%03d" % dex_number

func _on_PokedexEntryOverlay_close_requested() -> void:
	if pokedex_entry_overlay != null:
		pokedex_entry_overlay.close_menu()
	pending_entry_species_id = ""
	focus_default()

func _on_close_button_pressed() -> void:
	emit_signal("close_requested")
