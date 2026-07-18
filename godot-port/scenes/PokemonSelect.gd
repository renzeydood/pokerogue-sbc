tool
extends Control

const SPECIES_CATALOG_PATH := "res://godot-minimal-assets/data/species-catalog.v2.json"
const BATTLE_SCENE_PATH := "res://scenes/BattleScreen.tscn"
const MAIN_SCENE_PATH := "res://scenes/MainScreen.tscn"
const POKEDEX_ENTRY_OVERLAY_PATH := "res://scenes/PokedexEntryOverlay.tscn"
const MENU_BGM_CANDIDATE_PATHS := [
	"res://godot-minimal-assets/assets/audio/bgm/menu.mp3",
	"res://assets/audio/bgm/menu.mp3",
]
const TYPE_TEXTURE_REL := "assets/images/types.png"
const TYPE_ATLAS_REL := "assets/images/types.json"
const ICON_TEXTURE_TEMPLATE := "res://godot-minimal-assets/assets/images/pokemon_icons_%d.png"
const ICON_ATLAS_TEMPLATE := "res://godot-minimal-assets/assets/images/pokemon_icons_%d.json"
const ICON_FALLBACK_ATLAS_INDEX := 0
const ICON_DEFAULT_FRAME := "unknown"
const MAX_SELECTED_TEAM_SIZE := 6
const DEFAULT_UNLOCKED_SPECIES_ID := "BULBASAUR"
const CANONICAL_STARTER_BASE_SPECIES_IDS := [
	"BULBASAUR", "CHARMANDER", "SQUIRTLE",
	"CHIKORITA", "CYNDAQUIL", "TOTODILE",
	"TREECKO", "TORCHIC", "MUDKIP",
	"TURTWIG", "CHIMCHAR", "PIPLUP",
	"SNIVY", "TEPIG", "OSHAWOTT",
	"CHESPIN", "FENNEKIN", "FROAKIE",
	"ROWLET", "LITTEN", "POPPLIO",
	"GROOKEY", "SCORBUNNY", "SOBBLE",
	"SPRIGATITO", "FUECOCO", "QUAXLY",
]
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
var party_model_script = load("res://data/PartyModel.gd")
var pokedex_overlay_scene = load(POKEDEX_ENTRY_OVERLAY_PATH)

export(float) var ui_scale := 2.0
export(float) var preview_anim_frame_sec := 0.1
export(String, "center", "bottom") var preview_sprite_anchor_mode := "bottom"
export(float) var preview_sprite_scale := 1.0
export(bool) var play_menu_bgm := true
export(String) var menu_bgm_path := "res://godot-minimal-assets/assets/audio/bgm/menu.mp3"
export(float) var menu_bgm_volume_db := 0.0
export(float) var menu_bgm_fade_in_sec := 0.35
export(float) var menu_bgm_fade_out_sec := 0.3
export(bool) var editor_preview_enabled := true
export(int) var editor_preview_pokedex_number := 1
export(String) var editor_preview_species_name := "BULBASAUR"
export(String) var editor_preview_type1 := "grass"
export(String) var editor_preview_type2 := "poison"
export(int) var starter_grid_columns := 6
export(int) var starter_grid_visible_rows := 2
export(int) var starter_grid_h_separation := 4
export(int) var starter_grid_v_separation := 4
export(Vector2) var starter_grid_cell_size := Vector2(20, 20)
export(float) var starter_grid_icon_scale := 0.5
export(float) var starter_grid_global_icon_scale := 1.0
export(float) var starter_grid_icon_padding := 1.0
export(bool) var use_runtime_starter_grid_layout_overrides := false
export(float) var selected_team_icon_bob_interval_sec := 0.2
export(float) var selected_team_icon_bob_delta_px := -1.0
export(float) var starter_scroll_margin_left := 6.0
export(float) var starter_scroll_margin_top := 2.0
export(float) var starter_scroll_margin_right := 165.0
export(float) var starter_scroll_margin_bottom := 277.0
export(bool) var use_temporary_seed_species := false
export(String) var temporary_seed_profile_id := "ui_party_showcase"

var ui_scale_root = null
var starter_scroll = null
var starter_list = null
var current_pokemon_sprite = null
var pokemon_number_label = null
var pokemon_label = null
var details_type1_sprite = null
var details_type2_sprite = null
var start_button = null
var refresh_button = null
var quit_button = null
var random_button = null
var status_label = null
var action_window_sprite = null
var add_party_button = null
var remove_party_button = null
var pokedex_button = null
var action_cancel_button = null
var selected_team_count_label = null
var menu_bgm_player: AudioStreamPlayer = null
var menu_bgm_tween: Tween = null

var minimal_assets_path = "res://godot-minimal-assets/"
var selected_species_entry = null
var selected_team_species_ids := []
var selected_team_slot_sprites := []
var selected_team_slot_base_positions := []
var selected_team_slot_base_scales := []
var selected_team_slot_placeholder_states := []
var _selected_team_icon_bob_elapsed := 0.0
var _selected_team_icon_bob_toggled := false
var active_overlay = null
var species_entries := []
var preview_sprite_frames := []
var preview_anim_index := 0
var preview_anim_elapsed := 0.0
var preview_sprite_base_scale := Vector2.ONE
var editor_preview_seeded := false
var editor_preview_last_pokedex := -1
var editor_preview_list_seeded := false
var starter_grid_slots := []

func _resolve_first_existing(paths: Array):
	for path in paths:
		var candidate = get_node_or_null(String(path))
		if candidate != null:
			return candidate
	return null

func _set_status_text(message: String) -> void:
	if status_label != null:
		status_label.text = message
	else:
		print(message)

func _ready():
	ui_scale_root = _resolve_first_existing([
		"UiScaleRoot",
	])
	starter_list = _resolve_first_existing([
		"UiScaleRoot/MenuRoot/MenuCard/StarterScrollBackgroundSprite/StarterScroll/StarterList",
		"UiScaleRoot/MenuRoot/MenuCard/StarterScroll/StarterList",
		"UiScaleRoot/MenuRoot@MenuCard@StarterScrollBackgroundSprite@StarterScroll@StarterList",
		"UiScaleRoot/MenuRoot@MenuCard@StarterScroll@StarterList",
		"MenuRoot@MenuCard@StarterScroll@StarterList",
	])
	starter_scroll = _resolve_first_existing([
		"UiScaleRoot/MenuRoot/MenuCard/StarterScrollBackgroundSprite/StarterScroll",
		"UiScaleRoot/MenuRoot/MenuCard/StarterScroll",
		"UiScaleRoot/MenuRoot@MenuCard@StarterScrollBackgroundSprite@StarterScroll",
		"UiScaleRoot/MenuRoot@MenuCard@StarterScroll",
		"MenuRoot@MenuCard@StarterScroll",
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
		"UiScaleRoot/MenuRoot/MenuCard/StartWindow/StartButton",
		"UiScaleRoot/MenuRoot/MenuCard/StartWindow/Button",
		"UiScaleRoot/MenuRoot/MenuCard/FooterRow/StartButton",
		"UiScaleRoot/MenuRoot@MenuCard@StartWindow@StartButton",
		"UiScaleRoot/MenuRoot@MenuCard@StartWindow@Button",
		"UiScaleRoot/MenuRoot@MenuCard@FooterRow@StartButton",
		"MenuRoot@MenuCard@StartWindow@StartButton",
		"MenuRoot@MenuCard@StartWindow@Button",
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
	random_button = _resolve_first_existing([
		"UiScaleRoot/MenuRoot/MenuCard/RandomWindow/RandomButton",
		"UiScaleRoot/MenuRoot@MenuCard@RandomWindow@RandomButton",
		"MenuRoot@MenuCard@RandomWindow@RandomButton",
	])
	action_window_sprite = _resolve_first_existing([
		"UiScaleRoot/MenuRoot/MenuCard/ActionWindowSprite",
		"UiScaleRoot/MenuRoot@MenuCard@ActionWindowSprite",
		"MenuRoot@MenuCard@ActionWindowSprite",
	])
	add_party_button = _resolve_first_existing([
		"UiScaleRoot/MenuRoot/MenuCard/ActionWindowSprite/ActionContentMargin/ActionButtonList/AddPartyButton",
		"UiScaleRoot/MenuRoot@MenuCard@ActionWindowSprite@ActionContentMargin@ActionButtonList@AddPartyButton",
	])
	remove_party_button = _resolve_first_existing([
		"UiScaleRoot/MenuRoot/MenuCard/ActionWindowSprite/ActionContentMargin/ActionButtonList/RemovePartyButton",
		"UiScaleRoot/MenuRoot@MenuCard@ActionWindowSprite@ActionContentMargin@ActionButtonList@RemovePartyButton",
	])
	pokedex_button = _resolve_first_existing([
		"UiScaleRoot/MenuRoot/MenuCard/ActionWindowSprite/ActionContentMargin/ActionButtonList/PokedexButton",
		"UiScaleRoot/MenuRoot@MenuCard@ActionWindowSprite@ActionContentMargin@ActionButtonList@PokedexButton",
	])
	action_cancel_button = _resolve_first_existing([
		"UiScaleRoot/MenuRoot/MenuCard/ActionWindowSprite/ActionContentMargin/ActionButtonList/CancelButton",
		"UiScaleRoot/MenuRoot@MenuCard@ActionWindowSprite@ActionContentMargin@ActionButtonList@CancelButton",
	])
	selected_team_count_label = _resolve_first_existing([
		"UiScaleRoot/MenuRoot/MenuCard/StartWindow/Label",
		"UiScaleRoot/MenuRoot@MenuCard@StartWindow@Label",
		"MenuRoot@MenuCard@StartWindow@Label",
	])

	if ui_scale_root != null:
		ui_scale_root.rect_scale = Vector2(ui_scale, ui_scale)
	_apply_starter_grid_container_layout()
	if use_runtime_starter_grid_layout_overrides:
		_apply_starter_grid_layout_overrides()
	_collect_scene_grid_slots()

	if starter_list == null or current_pokemon_sprite == null or pokemon_number_label == null or pokemon_label == null:
		push_error("PokemonSelect scene is missing required UI nodes. Check MenuRoot/MenuCard structure in PokemonSelectScreen.tscn.")
		return
	_collect_selected_team_slot_sprites()
	_refresh_selected_team_window()
	preview_sprite_base_scale = current_pokemon_sprite.scale
	if Engine.editor_hint:
		if editor_preview_enabled:
			_apply_editor_preview_state()
		return
	if start_button == null:
		push_error("PokemonSelect scene is missing Start button. Check UiScaleRoot/MenuRoot/MenuCard/StartWindow paths in PokemonSelectScreen.tscn.")
		return
	start_button.disabled = true
	start_button.connect("pressed", self, "_on_StartButton_pressed")
	if refresh_button != null:
		refresh_button.connect("pressed", self, "_on_RefreshButton_pressed")
	if quit_button != null:
		quit_button.connect("pressed", self, "_on_QuitButton_pressed")
	if random_button != null:
		random_button.connect("pressed", self, "_on_RandomButton_pressed")
	if add_party_button != null:
		add_party_button.connect("pressed", self, "_on_AddPartyButton_pressed")
	if remove_party_button != null:
		remove_party_button.connect("pressed", self, "_on_RemovePartyButton_pressed")
	if pokedex_button != null:
		pokedex_button.connect("pressed", self, "_on_PokedexButton_pressed")
	if action_cancel_button != null:
		action_cancel_button.connect("pressed", self, "_on_ActionCancelButton_pressed")
	_set_action_window_visible(false)
	configure_type_sprite(details_type1_sprite)
	configure_type_sprite(details_type2_sprite)
	randomize()
	_play_menu_bgm_if_enabled()
	_load_species_catalog()
	if species_entries.empty():
		_set_status_text("Species catalog not found yet. Generate the catalog to populate this menu.")
		pokemon_number_label.text = "000"
		pokemon_label.text = "Pokemon"
		current_pokemon_sprite.texture = null
		preview_sprite_frames.clear()
		preview_anim_index = 0
		preview_anim_elapsed = 0.0
		details_type1_sprite.visible = false
		details_type2_sprite.visible = false
		return

	_set_status_text("Select a starter Pokemon to continue.")
	_select_species_entry(species_entries[0], false)

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
	var preview_species_entries := []
	for i in range(EDITOR_PREVIEW_LIST_SPECIES.size()):
		preview_species_entries.append({
			"species_id": String(EDITOR_PREVIEW_LIST_SPECIES[i]),
			"pokedex_number": i + 1,
			"source": {"generation": 1},
		})
	_populate_species_grid(preview_species_entries, true)
	editor_preview_list_seeded = true

func _apply_starter_grid_layout_overrides() -> void:
	if starter_scroll != null:
		starter_scroll.margin_left = starter_scroll_margin_left
		starter_scroll.margin_top = starter_scroll_margin_top
		starter_scroll.margin_right = starter_scroll_margin_right
		starter_scroll.margin_bottom = starter_scroll_margin_bottom

		var visible_rows = max(1, starter_grid_visible_rows)
		var cell_height = max(1.0, starter_grid_cell_size.y)
		var visible_height = visible_rows * cell_height
		if visible_rows > 1:
			visible_height += float((visible_rows - 1) * max(0, starter_grid_v_separation))
		starter_scroll.rect_min_size.y = visible_height

func _apply_starter_grid_container_layout() -> void:

	if starter_list != null:
		if starter_list is GridContainer:
			starter_list.columns = max(1, starter_grid_columns)
			starter_list.add_constant_override("hseparation", max(0, starter_grid_h_separation))
			starter_list.add_constant_override("vseparation", max(0, starter_grid_v_separation))
		else:
			starter_list.add_constant_override("separation", max(0, starter_grid_v_separation))

func _collect_scene_grid_slots() -> void:
	starter_grid_slots.clear()
	if starter_list == null:
		return

	for child in starter_list.get_children():
		if child is Button:
			starter_grid_slots.append(child)

func _collect_selected_team_slot_sprites() -> void:
	selected_team_slot_sprites.clear()
	selected_team_slot_base_positions.clear()
	selected_team_slot_base_scales.clear()
	selected_team_slot_placeholder_states.clear()
	for slot_index in range(MAX_SELECTED_TEAM_SIZE):
		var slot_number = slot_index + 1
		var slot_sprite = _resolve_first_existing([
			"UiScaleRoot/MenuRoot/MenuCard/SelectedTeamWindow/MarginContainer/VBoxContainer/SelectedPartySprite%d" % slot_number,
			"UiScaleRoot/MenuRoot@MenuCard@SelectedTeamWindow@MarginContainer@VBoxContainer@SelectedPartySprite%d" % slot_number,
		])
		selected_team_slot_sprites.append(slot_sprite)
		if slot_sprite != null:
			selected_team_slot_base_positions.append(slot_sprite.position)
			selected_team_slot_base_scales.append(slot_sprite.scale)
			selected_team_slot_placeholder_states.append({
				"texture": slot_sprite.texture,
				"region_enabled": slot_sprite.region_enabled,
				"region_rect": slot_sprite.region_rect,
				"centered": slot_sprite.centered,
				"position": slot_sprite.position,
				"visible": slot_sprite.visible,
			})
		else:
			selected_team_slot_base_positions.append(Vector2.ZERO)
			selected_team_slot_base_scales.append(Vector2.ONE)
			selected_team_slot_placeholder_states.append({})

func _set_action_window_visible(is_visible: bool) -> void:
	if action_window_sprite == null:
		return
	action_window_sprite.visible = is_visible

func _resolve_menu_bgm_path() -> String:
	var preferred = menu_bgm_path.strip_edges()
	if not preferred.empty() and ResourceLoader.exists(preferred):
		return preferred
	for candidate in MENU_BGM_CANDIDATE_PATHS:
		if ResourceLoader.exists(candidate):
			return candidate
	return ""

func _stop_menu_bgm_tween() -> void:
	if menu_bgm_tween != null and is_instance_valid(menu_bgm_tween):
		var _stop_result = menu_bgm_tween.stop_all()
		menu_bgm_tween.queue_free()
	menu_bgm_tween = null

func _configure_looping_stream(stream) -> void:
	if stream == null:
		return
	if stream is AudioStreamMP3:
		stream.loop = true
	elif stream is AudioStreamOGGVorbis:
		stream.loop = true
	elif stream is AudioStreamSample:
		stream.loop_mode = AudioStreamSample.LOOP_FORWARD

func _play_menu_bgm_if_enabled() -> void:
	if Engine.editor_hint or not play_menu_bgm:
		return

	var resolved_path = _resolve_menu_bgm_path()
	if resolved_path.empty():
		push_warning("PokemonSelect menu BGM not found. Expected menu.mp3 in minimal assets.")
		return

	var stream = load(resolved_path)
	if stream == null:
		push_warning("Failed to load PokemonSelect menu BGM: %s" % resolved_path)
		return

	if menu_bgm_player == null:
		menu_bgm_player = AudioStreamPlayer.new()
		menu_bgm_player.name = "MenuAudioPlayer"
		add_child(menu_bgm_player)

	_configure_looping_stream(stream)
	menu_bgm_player.stream = stream
	_stop_menu_bgm_tween()
	menu_bgm_player.volume_db = -80.0
	menu_bgm_player.play()

	if menu_bgm_fade_in_sec > 0.0:
		menu_bgm_tween = Tween.new()
		add_child(menu_bgm_tween)
		var _tween_result = menu_bgm_tween.interpolate_property(
			menu_bgm_player,
			"volume_db",
			menu_bgm_player.volume_db,
			menu_bgm_volume_db,
			max(0.01, menu_bgm_fade_in_sec),
			Tween.TRANS_SINE,
			Tween.EASE_IN_OUT
		)
		var _start_result = menu_bgm_tween.start()
	else:
		menu_bgm_player.volume_db = menu_bgm_volume_db

func _fade_out_menu_bgm(duration_sec: float):
	if menu_bgm_player == null:
		yield(get_tree(), "idle_frame")
		return

	_stop_menu_bgm_tween()
	var fade_duration = max(0.0, duration_sec)
	if fade_duration <= 0.0:
		menu_bgm_player.stop()
		menu_bgm_player.volume_db = menu_bgm_volume_db
		yield(get_tree(), "idle_frame")
		return

	menu_bgm_tween = Tween.new()
	add_child(menu_bgm_tween)
	var _tween_result = menu_bgm_tween.interpolate_property(
		menu_bgm_player,
		"volume_db",
		menu_bgm_player.volume_db,
		-80.0,
		fade_duration,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	var _start_result = menu_bgm_tween.start()
	yield(get_tree().create_timer(fade_duration), "timeout")
	if menu_bgm_player != null:
		menu_bgm_player.stop()
		menu_bgm_player.volume_db = menu_bgm_volume_db
	_stop_menu_bgm_tween()

func _refresh_action_window_mode() -> void:
	if selected_species_entry == null:
		if add_party_button != null:
			add_party_button.visible = true
		if remove_party_button != null:
			remove_party_button.visible = false
		return

	var selected_species_id = String(selected_species_entry.get("species_id", "")).strip_edges().to_upper()
	var is_in_party = (not selected_species_id.empty()) and selected_team_species_ids.has(selected_species_id)
	if add_party_button != null:
		add_party_button.visible = not is_in_party
	if remove_party_button != null:
		remove_party_button.visible = is_in_party

func _refresh_selected_team_window() -> void:
	if selected_team_count_label != null:
		selected_team_count_label.text = "%d/%d" % [selected_team_species_ids.size(), MAX_SELECTED_TEAM_SIZE]

	for slot_index in range(selected_team_slot_sprites.size()):
		var slot_sprite = selected_team_slot_sprites[slot_index]
		if slot_sprite == null:
			continue
		if slot_index >= selected_team_species_ids.size():
			var placeholder_state = selected_team_slot_placeholder_states[slot_index] if slot_index < selected_team_slot_placeholder_states.size() else {}
			slot_sprite.texture = placeholder_state.get("texture", slot_sprite.texture)
			slot_sprite.region_enabled = bool(placeholder_state.get("region_enabled", slot_sprite.region_enabled))
			slot_sprite.region_rect = placeholder_state.get("region_rect", slot_sprite.region_rect)
			slot_sprite.centered = bool(placeholder_state.get("centered", slot_sprite.centered))
			if placeholder_state.has("position"):
				slot_sprite.position = placeholder_state.get("position", slot_sprite.position)
			if slot_index < selected_team_slot_base_positions.size():
				selected_team_slot_base_positions[slot_index] = slot_sprite.position
			slot_sprite.scale = selected_team_slot_base_scales[slot_index]
			slot_sprite.visible = bool(placeholder_state.get("visible", true))
			continue

		var species_id = String(selected_team_species_ids[slot_index]).strip_edges().to_upper()
		var species_entry = _find_species_entry_by_id(species_id)
		if species_entry.empty():
			slot_sprite.texture = null
			slot_sprite.visible = false
			continue

		var dex_num = int(species_entry.get("pokedex_number", -1))
		var source = species_entry.get("source", {})
		var generation = int(source.get("generation", 1)) if typeof(source) == TYPE_DICTIONARY else 1
		if generation <= 0:
			generation = 1

		var icon_payload = _build_icon_atlas_payload(generation, str(dex_num)) if dex_num > 0 else {}
		if icon_payload.empty():
			icon_payload = _build_icon_atlas_payload(ICON_FALLBACK_ATLAS_INDEX, ICON_DEFAULT_FRAME)
		if icon_payload.empty():
			slot_sprite.texture = null
			slot_sprite.visible = false
			continue

		var resolved_icon_scale = _resolve_icon_display_scale(float(icon_payload.get("atlas_scale", 1.0)))
		slot_sprite.texture = icon_payload.get("texture", null)
		slot_sprite.scale = selected_team_slot_base_scales[slot_index] * resolved_icon_scale
		slot_sprite.centered = true
		slot_sprite.region_enabled = false
		if slot_index < selected_team_slot_base_positions.size():
			selected_team_slot_base_positions[slot_index] = slot_sprite.position
		slot_sprite.visible = true

	_apply_selected_team_icon_bob_offsets()
	_refresh_action_window_mode()

func _apply_selected_team_icon_bob_offsets() -> void:
	for i in range(selected_team_slot_sprites.size()):
		var slot_sprite: Sprite = selected_team_slot_sprites[i]
		if slot_sprite == null:
			continue
		if i >= selected_team_slot_base_positions.size():
			continue

		var base_position: Vector2 = selected_team_slot_base_positions[i]
		var delta_y = selected_team_icon_bob_delta_px if _selected_team_icon_bob_toggled and slot_sprite.visible else 0.0
		slot_sprite.position = Vector2(base_position.x, base_position.y + delta_y)

func _reset_selected_team_icon_bob_state() -> void:
	_selected_team_icon_bob_elapsed = 0.0
	_selected_team_icon_bob_toggled = false
	_apply_selected_team_icon_bob_offsets()

func _add_random_species_to_party() -> void:
	if selected_team_species_ids.size() >= MAX_SELECTED_TEAM_SIZE:
		_set_status_text("Selected team is full. Remove a member to add another.")
		return

	var eligible_entries := []
	for species_entry in species_entries:
		if typeof(species_entry) != TYPE_DICTIONARY:
			continue
		var species_id = String(species_entry.get("species_id", "")).strip_edges().to_upper()
		if species_id.empty() or selected_team_species_ids.has(species_id):
			continue
		eligible_entries.append(species_entry)

	if eligible_entries.empty():
		_set_status_text("No eligible random Pokemon left to add.")
		return

	var random_index = randi() % eligible_entries.size()
	var chosen_entry: Dictionary = eligible_entries[random_index]
	_add_selected_species_to_party(chosen_entry)
	_select_species_entry(chosen_entry, false)


func _find_species_entry_by_id(species_id: String) -> Dictionary:
	var normalized_id = species_id.strip_edges().to_upper()
	if normalized_id.empty():
		return {}
	for species_entry in species_entries:
		if typeof(species_entry) != TYPE_DICTIONARY:
			continue
		if String(species_entry.get("species_id", "")).strip_edges().to_upper() == normalized_id:
			return species_entry
	return {}

func _add_selected_species_to_party(species_entry: Dictionary) -> void:
	if typeof(species_entry) != TYPE_DICTIONARY:
		return
	if selected_team_species_ids.size() >= MAX_SELECTED_TEAM_SIZE:
		_set_status_text("Selected team is full. Remove a member to add another.")
		return
	var species_id = String(species_entry.get("species_id", "")).strip_edges().to_upper()
	if species_id.empty():
		return
	if selected_team_species_ids.has(species_id):
		_set_status_text("%s is already in team." % species_id)
		_refresh_action_window_mode()
		return
	selected_team_species_ids.append(species_id)
	_refresh_selected_team_window()
	_set_status_text("Added %s to team." % species_id)
	_set_action_window_visible(false)

func _remove_selected_species_from_party(species_entry: Dictionary) -> void:
	if typeof(species_entry) != TYPE_DICTIONARY:
		return
	var species_id = String(species_entry.get("species_id", "")).strip_edges().to_upper()
	if species_id.empty():
		return
	var idx = selected_team_species_ids.find(species_id)
	if idx < 0:
		_set_status_text("%s is not in team." % species_id)
		_refresh_action_window_mode()
		return
	selected_team_species_ids.remove(idx)
	_refresh_selected_team_window()
	_set_status_text("Removed %s from team." % species_id)
	_set_action_window_visible(false)

func _open_pokedex_entry_overlay(species_id: String) -> void:
	if pokedex_overlay_scene == null:
		_set_status_text("Pokedex entry scene is missing.")
		return

	_close_active_overlay()

	var overlay = pokedex_overlay_scene.instance()
	if overlay == null:
		_set_status_text("Failed to open Pokedex overlay.")
		return

	add_child(overlay)
	overlay.raise()
	active_overlay = overlay
	if overlay.has_signal("close_requested"):
		overlay.connect("close_requested", self, "_on_PokedexOverlay_close_requested", [overlay])
	if overlay.has_method("open_menu"):
		overlay.open_menu(species_id, runtime_state_script.has_caught_species(get_tree(), species_id) if runtime_state_script != null else false)
	if overlay.has_method("focus_default"):
		overlay.focus_default()

func _close_active_overlay() -> void:
	if active_overlay != null:
		active_overlay.queue_free()
		active_overlay = null

func _build_selected_team_party_model():
	if party_model_script == null:
		return null
	var party = party_model_script.new()
	if party == null:
		return null
	for species_id in selected_team_species_ids:
		party.add_member({
			"species_id": String(species_id).strip_edges().to_upper(),
			"level": 5,
			"current_hp": -1,
			"move_ids": [],
		})
	party.set_active_slot(0)
	return party

func _ensure_species_grid_capacity(required_count: int) -> void:
	if starter_list == null:
		return
	if starter_grid_slots.empty():
		_collect_scene_grid_slots()

	while starter_grid_slots.size() < required_count:
		var slot_index = starter_grid_slots.size() + 1
		var slot_button = _build_species_grid_button({}, true)
		slot_button.name = "IconSlot%02d" % slot_index
		starter_list.add_child(slot_button)
		starter_grid_slots.append(slot_button)

func _populate_species_grid(entries: Array, disable_buttons: bool = false) -> void:
	if starter_list == null:
		return
	_collect_scene_grid_slots()
	_ensure_species_grid_capacity(entries.size())

	for i in range(starter_grid_slots.size()):
		var slot_button: Button = starter_grid_slots[i]
		if slot_button == null:
			continue
		var slot_icon_sprite = _ensure_slot_icon_sprite(slot_button)
		if not slot_button.is_connected("pressed", self, "_on_species_grid_button_pressed"):
			var _slot_connect_result = slot_button.connect("pressed", self, "_on_species_grid_button_pressed", [slot_button])
		slot_button.rect_min_size = starter_grid_cell_size
		slot_button.rect_scale = Vector2.ONE

		if i < entries.size() and typeof(entries[i]) == TYPE_DICTIONARY:
			var species_entry: Dictionary = entries[i]
			slot_button.visible = true
			slot_button.disabled = disable_buttons
			slot_button.hint_tooltip = _format_species_button_text(species_entry)
			slot_button.set_meta("species_entry", species_entry)
			_apply_species_icon_to_button(slot_button, species_entry)
		else:
			slot_button.visible = false
			slot_button.disabled = true
			slot_button.icon = null
			slot_button.expand_icon = false
			if slot_icon_sprite != null:
				slot_icon_sprite.texture = null
				slot_icon_sprite.visible = false
			slot_button.hint_tooltip = ""
			if slot_button.has_meta("species_entry"):
				slot_button.remove_meta("species_entry")

func _build_species_grid_button(species_entry: Dictionary, disable_button: bool = false) -> Button:
	var button = Button.new()
	button.rect_min_size = starter_grid_cell_size
	button.flat = true
	button.text = ""
	button.icon = null
	button.expand_icon = false
	button.disabled = disable_button
	button.hint_tooltip = _format_species_button_text(species_entry)
	if not button.is_connected("pressed", self, "_on_species_grid_button_pressed"):
		var _button_connect_result = button.connect("pressed", self, "_on_species_grid_button_pressed", [button])
	if typeof(species_entry) == TYPE_DICTIONARY and not species_entry.empty():
		button.set_meta("species_entry", species_entry)
	var _button_icon_sprite = _ensure_slot_icon_sprite(button)
	_apply_species_icon_to_button(button, species_entry)
	return button

func _ensure_slot_icon_sprite(button: Button) -> Sprite:
	if button == null:
		return null

	var icon_sprite = button.get_node_or_null("IconSprite")
	if icon_sprite == null:
		icon_sprite = Sprite.new()
		icon_sprite.name = "IconSprite"
		button.add_child(icon_sprite)

	var pad = max(0.0, starter_grid_icon_padding)
	icon_sprite.centered = false
	icon_sprite.offset = Vector2.ZERO
	icon_sprite.position = Vector2(pad, pad)
	icon_sprite.region_enabled = false
	icon_sprite.visible = false
	return icon_sprite

func _position_slot_icon_sprite_bottom_center(button: Button, icon_sprite: Sprite) -> void:
	if button == null or icon_sprite == null or icon_sprite.texture == null:
		return

	var frame_size = Vector2.ZERO
	if icon_sprite.texture is AtlasTexture:
		frame_size = (icon_sprite.texture as AtlasTexture).region.size
	else:
		frame_size = icon_sprite.texture.get_size()

	var scale_x = icon_sprite.scale.x
	var scale_y = icon_sprite.scale.y
	var pad = max(0.0, starter_grid_icon_padding)
	var anchor_x = pad + ((button.rect_size.x - (pad * 2.0)) / 2.0)
	var anchor_y = button.rect_size.y - pad
	var icon_w = frame_size.x * scale_x
	var icon_h = frame_size.y * scale_y

	icon_sprite.position = Vector2(anchor_x - (icon_w / 2.0), anchor_y - icon_h)

func _on_species_grid_button_pressed(button: Button) -> void:
	if button == null:
		return
	if not button.has_meta("species_entry"):
		return
	var species_entry = button.get_meta("species_entry")
	if typeof(species_entry) != TYPE_DICTIONARY:
		return
	_select_species_entry(species_entry, true)

func _apply_species_icon_to_button(button: Button, species_entry: Dictionary) -> void:
	if button == null:
		return
	button.icon = null
	button.expand_icon = false
	var icon_sprite = _ensure_slot_icon_sprite(button)
	if icon_sprite == null:
		return
	icon_sprite.texture = null
	icon_sprite.visible = false

	var dex_num = int(species_entry.get("pokedex_number", -1))
	var source = species_entry.get("source", {})
	var generation = 1
	if typeof(source) == TYPE_DICTIONARY:
		generation = int(source.get("generation", 1))
	if generation <= 0:
		generation = 1

	if dex_num > 0:
		var icon_payload = _build_icon_atlas_payload(generation, str(dex_num))
		if not icon_payload.empty():
			var icon_texture = icon_payload.get("texture", null)
			var resolved_icon_scale = _resolve_icon_display_scale(float(icon_payload.get("atlas_scale", 1.0)))
			icon_sprite.texture = icon_texture
			icon_sprite.scale = Vector2(resolved_icon_scale, resolved_icon_scale)
			_position_slot_icon_sprite_bottom_center(button, icon_sprite)
			icon_sprite.visible = true
			return

	var fallback_payload = _build_icon_atlas_payload(ICON_FALLBACK_ATLAS_INDEX, ICON_DEFAULT_FRAME)
	var fallback_texture = fallback_payload.get("texture", null) if not fallback_payload.empty() else null
	var fallback_scale = _resolve_icon_display_scale(float(fallback_payload.get("atlas_scale", 1.0))) if not fallback_payload.empty() else starter_grid_icon_scale
	icon_sprite.texture = fallback_texture
	icon_sprite.scale = Vector2(fallback_scale, fallback_scale)
	_position_slot_icon_sprite_bottom_center(button, icon_sprite)
	icon_sprite.visible = fallback_texture != null

func _build_icon_atlas_payload(atlas_index: int, frame_name: String) -> Dictionary:
	var texture_path = ICON_TEXTURE_TEMPLATE % atlas_index
	if not resource_exists(texture_path):
		return {}

	var atlas_path = ICON_ATLAS_TEMPLATE % atlas_index
	var frame_data = parse_sprite_frame(atlas_path, frame_name)
	if frame_data == null:
		return {}

	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = load(texture_path)
	var frame = frame_data["frame"]
	atlas_texture.region = Rect2(frame["x"], frame["y"], frame["w"], frame["h"])
	return {
		"texture": atlas_texture,
		"atlas_scale": float(frame_data.get("_atlas_scale", 1.0)),
	}

func _resolve_icon_display_scale(atlas_scale: float) -> float:
	var safe_atlas_scale = max(0.001, atlas_scale)
	return (starter_grid_icon_scale * max(0.01, starter_grid_global_icon_scale)) / safe_atlas_scale

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
	selected_species_entry = null
	_clear_starter_buttons()

	var file := File.new()
	if not file.file_exists(SPECIES_CATALOG_PATH):
		return

	if file.open(SPECIES_CATALOG_PATH, File.READ) != OK:
		_set_status_text("Failed to read species catalog.")
		return

	var parse_result = JSON.parse(file.get_as_text())
	file.close()
	if parse_result.error != OK or parse_result.result == null:
		_set_status_text("Failed to parse species catalog.")
		return

	var payload = parse_result.result
	if not (payload is Dictionary):
		_set_status_text("Species catalog format is invalid.")
		return

	var items = payload.get("items", [])
	if not (items is Array):
		_set_status_text("Species catalog items are missing.")
		return

	for item in items:
		if item is Dictionary:
			species_entries.append(item)

	species_entries.sort_custom(self, "_sort_species_by_pokedex")
	species_entries = _filter_species_entries_by_roster(species_entries)
	_populate_species_grid(species_entries)

func _filter_species_entries_by_roster(all_species_entries: Array) -> Array:
	if all_species_entries.empty():
		return []

	var species_entry_by_id := {}
	var starter_species_by_id := {}
	for species_entry in all_species_entries:
		if typeof(species_entry) != TYPE_DICTIONARY:
			continue
		var sid = String(species_entry.get("species_id", "")).strip_edges().to_upper()
		if sid.empty():
			continue
		species_entry_by_id[sid] = species_entry
		var starter_species_id = String(species_entry.get("starter_species_id", sid)).strip_edges().to_upper()
		if starter_species_id.empty():
			starter_species_id = sid
		starter_species_by_id[sid] = starter_species_id

	var unlocked_species_ids := []
	for starter_species_id in CANONICAL_STARTER_BASE_SPECIES_IDS:
		if species_entry_by_id.has(starter_species_id) and not unlocked_species_ids.has(starter_species_id):
			unlocked_species_ids.append(starter_species_id)
	if unlocked_species_ids.empty() and species_entry_by_id.has(DEFAULT_UNLOCKED_SPECIES_ID):
		unlocked_species_ids.append(DEFAULT_UNLOCKED_SPECIES_ID)

	if runtime_state_script != null:
		var roster_species_ids = runtime_state_script.get_caught_species_ids(get_tree())
		if typeof(roster_species_ids) == TYPE_ARRAY and not roster_species_ids.empty():
			for raw_species_id in roster_species_ids:
				var normalized_species_id = String(raw_species_id).strip_edges().to_upper()
				if normalized_species_id.empty():
					continue
				var normalized_base_species_id = String(starter_species_by_id.get(normalized_species_id, normalized_species_id)).strip_edges().to_upper()
				if species_entry_by_id.has(normalized_base_species_id) and not unlocked_species_ids.has(normalized_base_species_id):
					unlocked_species_ids.append(normalized_base_species_id)
	if use_temporary_seed_species:
		unlocked_species_ids = runtime_state_script.merge_species_ids_with_debug_seed_profile(unlocked_species_ids, temporary_seed_profile_id)

	var filtered_entries := []
	for species_entry in all_species_entries:
		if typeof(species_entry) != TYPE_DICTIONARY:
			continue
		var species_id = String(species_entry.get("species_id", "")).strip_edges().to_upper()
		if species_id.empty() or not unlocked_species_ids.has(species_id):
			continue
		filtered_entries.append(species_entry)

	if not filtered_entries.empty():
		return filtered_entries

	for species_entry in all_species_entries:
		if String(species_entry.get("species_id", "")).strip_edges().to_upper() == DEFAULT_UNLOCKED_SPECIES_ID:
			return [species_entry]

	return [all_species_entries[0]]

func _add_species_button(species_entry):
	var button = _build_species_grid_button(species_entry)
	starter_list.add_child(button)
	if button is Button:
		starter_grid_slots.append(button)

func _clear_starter_buttons():
	if starter_list == null:
		return
	_collect_scene_grid_slots()
	for slot_button in starter_grid_slots:
		if slot_button == null:
			continue
		var slot_icon_sprite = _ensure_slot_icon_sprite(slot_button)
		slot_button.visible = false
		slot_button.disabled = true
		slot_button.icon = null
		slot_button.expand_icon = false
		if slot_icon_sprite != null:
			slot_icon_sprite.texture = null
			slot_icon_sprite.visible = false
		slot_button.hint_tooltip = ""
		if slot_button.has_meta("species_entry"):
			slot_button.remove_meta("species_entry")

func _sort_species_by_pokedex(a, b):
	return int(a.get("pokedex_number", 99999)) < int(b.get("pokedex_number", 99999))

func _format_species_button_text(species_entry: Dictionary) -> String:
	var species_id = String(species_entry.get("species_id", "UNKNOWN"))
	return species_id

func _on_species_button_pressed(species_entry):
	_select_species_entry(species_entry)

func _select_species_entry(species_entry, reveal_action_window: bool = true):
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
	start_button.disabled = selected_team_species_ids.empty()
	_refresh_action_window_mode()
	_set_action_window_visible(reveal_action_window)
	_set_status_text("Selected %s. Choose an action." % species_name if reveal_action_window else "Selected %s." % species_name)

func _on_AddPartyButton_pressed() -> void:
	if selected_species_entry == null:
		return
	_add_selected_species_to_party(selected_species_entry)
	start_button.disabled = selected_team_species_ids.empty()

func _on_RemovePartyButton_pressed() -> void:
	if selected_species_entry == null:
		return
	_remove_selected_species_from_party(selected_species_entry)
	start_button.disabled = selected_team_species_ids.empty()

func _on_PokedexButton_pressed() -> void:
	if selected_species_entry == null:
		return
	var species_id = String(selected_species_entry.get("species_id", "")).strip_edges().to_upper()
	if species_id.empty():
		return
	_open_pokedex_entry_overlay(species_id)

func _on_ActionCancelButton_pressed() -> void:
	_set_action_window_visible(false)

func _unhandled_input(event) -> void:
	if not _is_back_input_event(event):
		return

	if active_overlay == null:
		_return_to_main_scene()
		get_tree().set_input_as_handled()
		return

	if active_overlay.has_method("handle_back_action"):
		if active_overlay.handle_back_action():
			get_tree().set_input_as_handled()
			return
	_close_active_overlay()
	get_tree().set_input_as_handled()

func _is_back_input_event(event) -> bool:
	if event == null:
		return false
	if event.is_action_pressed("ui_back") or event.is_action_pressed("ui_cancel"):
		return true
	if event is InputEventKey and event.pressed and not event.echo:
		return event.scancode == KEY_ESCAPE or event.scancode == KEY_BACKSPACE
	return false

func _return_to_main_scene() -> void:
	if menu_bgm_player != null and menu_bgm_player.playing:
		yield(_fade_out_menu_bgm(menu_bgm_fade_out_sec), "completed")
	var result = get_tree().change_scene(MAIN_SCENE_PATH)
	if result != OK:
		_set_status_text("Failed to open main menu scene.")

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
	if data == null or typeof(data) != TYPE_DICTIONARY:
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

	_selected_team_icon_bob_elapsed += delta
	if _selected_team_icon_bob_elapsed >= max(0.01, selected_team_icon_bob_interval_sec):
		_selected_team_icon_bob_elapsed = 0.0
		_selected_team_icon_bob_toggled = not _selected_team_icon_bob_toggled
		_apply_selected_team_icon_bob_offsets()

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
	if selected_team_species_ids.empty():
		_set_status_text("Add at least one Pokemon to team first.")
		return
	_close_active_overlay()
	_set_action_window_visible(false)
	if menu_bgm_player != null and menu_bgm_player.playing:
		yield(_fade_out_menu_bgm(menu_bgm_fade_out_sec), "completed")
	var selected_species_id = String(selected_team_species_ids[0]).strip_edges().to_upper()
	if runtime_state_script != null:
		for species_id in selected_team_species_ids:
			runtime_state_script.add_caught_species(get_tree(), String(species_id).strip_edges().to_upper())
		var party = _build_selected_team_party_model()
		if party != null:
			runtime_state_script.set_party(get_tree(), party)
		else:
			runtime_state_script.ensure_party_with_starter(get_tree(), selected_species_id, 5)
	else:
		get_tree().set_meta("selected_species_id", selected_species_id)
	get_tree().set_meta("selected_species_id", selected_species_id)
	var result = get_tree().change_scene(BATTLE_SCENE_PATH)
	if result != OK:
		_set_status_text("Failed to open battle scene.")
		push_error("Failed to open battle scene: %s" % BATTLE_SCENE_PATH)

func _on_PokedexOverlay_close_requested(overlay) -> void:
	if overlay == active_overlay:
		_close_active_overlay()
	elif overlay != null:
		overlay.queue_free()

func _on_RefreshButton_pressed():
	_load_species_catalog()
	if not species_entries.empty() and selected_species_entry == null:
		_select_species_entry(species_entries[0])

func _on_RandomButton_pressed() -> void:
	_add_random_species_to_party()

func _on_QuitButton_pressed():
	get_tree().quit()
