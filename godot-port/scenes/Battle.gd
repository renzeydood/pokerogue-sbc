extends Control

# Tunable gameplay and presentation exports.
export(float) var ui_scale := 2.0
export(float) var turn_step_delay_sec := 0.6
export(bool) var battle_fx_enabled := true
export(float) var pokemon_anim_frame_sec := 0.1
export(String, "center", "bottom") var pokemon_sprite_anchor_mode := "bottom"
export(float) var impact_shake_step_sec := 0.03
export(float) var impact_flash_mul := 1.6
export(float) var impact_shake_px := 2.0
export(float) var move_anim_step_sec := 0.05
export(float) var faint_step_sec := 0.05
export(float) var faint_drop_px := 20.0
export(float) var enemy_switch_delay_sec := 0.9
export(float) var defeat_return_delay_sec := 1.3
export(float) var enemy_switch_slide_distance_px := 220.0
export(float) var enemy_switch_slide_duration_sec := 0.55
export(int) var biome_switch_every_levels := 3
export(float) var arena_switch_blend_duration_sec := 0.22
export(float) var biome_bgm_crossfade_duration_sec := 0.75
export(float) var biome_bgm_volume_db := 0.0
export(Array, String) var biome_test_arena_rotation := ["grass", "metropolis", "abyss"]
export(bool) var debug_open_party_menu_on_ready := false
export(bool) var player_trainer_enabled := true
export(float) var player_trainer_idle_hold_sec := 0.5
export(float) var player_trainer_reveal_delay_sec := 0.1
export(float) var player_trainer_exit_duration_sec := 1.2
export(float) var player_trainer_exit_distance_px := 120.0
export(float) var player_pokeball_start_offset_x := 8.0
export(float) var player_pokeball_start_offset_y := -42.0
export(float) var player_pokeball_target_offset_x := 10.0
export(float) var player_pokeball_target_offset_y := -72.0
export(float) var player_pokeball_start_delay_sec := 0.0
export(float) var player_pokeball_arc_height_px := 42.0
export(float) var player_pokeball_lob_duration_sec := 0.65
export(float) var player_pokeball_lob_up_duration_sec := 0.15
export(float) var player_pokeball_spin_degrees := 720.0
export(float) var player_pokeball_opening_hold_sec := 0.06
export(float) var player_pokeball_open_hold_sec := 0.08
export(float) var player_pokemon_reveal_start_scale := 0.5
export(float) var player_pokemon_reveal_scale_duration_sec := 0.25
export(float) var player_pokemon_reveal_flash_mul := 1.35
export(float) var player_pokemon_reveal_flash_duration_sec := 0.18
export(Color) var player_pokemon_reveal_tint_color := Color(1.0, 0.75, 0.75, 1.0)
export(float) var player_pokemon_reveal_alpha_start := 0.0
const SELECTED_SPECIES_META_KEY := "selected_species_id"
const SELECTION_SCENE_PATH := "res://scenes/PokemonSelectScreen.tscn"
const ATTACK_TYPE_TEXTURE_REL := "assets/images/types.png"
const ATTACK_TYPE_ATLAS_REL := "assets/images/types.json"
const ATTACK_CATEGORY_TEXTURE_REL := "assets/images/categories.png"
const ATTACK_CATEGORY_ATLAS_REL := "assets/images/categories.json"
const PLAYER_TRAINER_BACK_TEXTURE_REL := "assets/images/trainer/trainer_m_back.png"
const PLAYER_TRAINER_BACK_ATLAS_REL := "assets/images/trainer/trainer_m_back.json"
const PLAYER_TRAINER_BACK_PB_TEXTURE_REL := "assets/images/trainer/trainer_m_back_pb.png"
const PLAYER_TRAINER_BACK_PB_ATLAS_REL := "assets/images/trainer/trainer_m_back_pb.json"
const POKEBALL_TEXTURE_REL := "assets/images/pb.png"
const POKEBALL_ATLAS_REL := "assets/images/pb.json"
const POKEBALL_FRAME_CLOSED := "pb"
const POKEBALL_FRAME_OPENING := "pb_opening"
const POKEBALL_FRAME_OPEN := "pb_open"
const CAPTURE_REQUIRED_SHAKES := 3
const BALL_KEY_POKEBALL := "pokeball"
const BALL_KEY_GREATBALL := "greatball"
const BALL_KEY_MASTERBALL := "masterball"
const BALL_DEFAULT_COUNTS := {
	BALL_KEY_POKEBALL: 5,
	BALL_KEY_GREATBALL: 4,
	BALL_KEY_MASTERBALL: 10,
}
const BALL_DEFS := {
	BALL_KEY_POKEBALL: {
		"label": "Pokeball",
		"frame_prefix": "pb",
		"catch_bonus": 1.0,
		"guaranteed": false,
	},
	BALL_KEY_GREATBALL: {
		"label": "Greatball",
		"frame_prefix": "gb",
		"catch_bonus": 1.5,
		"guaranteed": false,
	},
	BALL_KEY_MASTERBALL: {
		"label": "Masterball",
		"frame_prefix": "mb",
		"catch_bonus": 99.0,
		"guaranteed": true,
	},
}
export(float) var capture_throw_start_offset_x := 6.0
export(float) var capture_throw_start_offset_y := -22.0
export(float) var capture_throw_target_offset_x := -2.0
export(float) var capture_throw_target_offset_y := -14.0
export(float) var capture_throw_arc_height_px := 46.0
export(float) var capture_throw_duration_sec := 0.56
export(float) var capture_throw_up_duration_sec := 0.17
export(float) var capture_enemy_absorb_delay_sec := 0.14
export(float) var capture_breakout_open_delay_sec := 0.24
export(float) var capture_ball_settle_offset_y := 12.0
export(float) var capture_enemy_absorb_duration_sec := 0.42
export(float) var capture_enemy_absorb_scale_mul := 0.25
export(float) var capture_enemy_breakout_duration_sec := 0.24
export(float) var capture_ball_success_fade_duration_sec := 0.28
export(float) var capture_ball_pre_bounce_delay_sec := 0.25
export(float) var capture_ball_bounce_duration_sec := 0.35
export(float) var capture_shake_beat_delay_sec := 0.5
const POKEBALL_PARTICLES_TEXTURE_REL := "assets/images/effects/pb_particles.png"
const POKEBALL_PARTICLES_ATLAS_REL := "assets/images/effects/pb_particles.json"
export(int) var player_pokeball_particle_count := 17
export(float) var player_pokeball_particle_spawn_interval_sec := 0.02
export(float) var player_pokeball_particle_radius_px := 48.0
export(float) var player_pokeball_particle_travel_duration_sec := 0.575
export(float) var player_pokeball_particle_fade_delay_sec := 0.5
export(float) var player_pokeball_particle_fade_duration_sec := 0.075

# Data and helper script dependencies.
var pokemon_data_script = load("res://data/PokemonData.gd")
var battle_calc_script = load("res://logic/BattleCalc.gd")
var catalog_loader_script = load("res://logic/CatalogDataLoader.gd")
var runtime_state_script = load("res://logic/RuntimeState.gd")
var party_menu_scene = preload("res://scenes/PartyMenuOverlay.tscn")

func _resolve_first_existing(paths: Array):
	for path in paths:
		var candidate = get_node_or_null(String(path))
		if candidate != null:
			return candidate
	return null

func _connect_once(emitter, signal_name: String, method_name: String, binds: Array = []) -> void:
	if emitter == null:
		return
	if not emitter.is_connected(signal_name, self, method_name):
		emitter.connect(signal_name, self, method_name, binds)

# Cached node references resolved from stable scene anchors.
onready var ui_scale_root = _resolve_first_existing([
	"UiScaleRoot",
])
onready var ui_layer = _resolve_first_existing([
	"UiScaleRoot/UILayer",
	"UILayer",
])
onready var battlefield_layer = _resolve_first_existing([
	"UiScaleRoot/BattlefieldLayer",
	"BattlefieldLayer",
])
onready var enemy_panel = ui_layer.get_node_or_null("EnemyPanel") if ui_layer != null else null
onready var player_panel = ui_layer.get_node_or_null("PlayerPanel") if ui_layer != null else null
onready var controls_container = ui_layer.get_node_or_null("ControlsContainer") if ui_layer != null else null
onready var controls_vbox = controls_container.get_node_or_null("ControlWindowSprite/ContentMargin/VBoxContainer") if controls_container != null else null
onready var attack_menu_container = ui_layer.get_node_or_null("AttackMenuContainer") if ui_layer != null else null
onready var attack_move_grid = attack_menu_container.get_node_or_null("HBoxContainer/AttackWindowSprite/AttackMovesGrid") if attack_menu_container != null else null
onready var attack_move_details = attack_menu_container.get_node_or_null("HBoxContainer/AttackWindowSprite2/AttackMoveDetails") if attack_menu_container != null else null
onready var ball_menu_container = ui_layer.get_node_or_null("BallMenuContainer") if ui_layer != null else null
onready var ball_button_list = ball_menu_container.get_node_or_null("BallWindowSprite/BallContentMargin/BallButtonList") if ball_menu_container != null else null
onready var arena_backdrop = get_node_or_null("ArenaBackdrop")

onready var enemy_name_label = enemy_panel.get_node_or_null("EnemyNameLabel") if enemy_panel != null else null
onready var enemy_level_label = enemy_panel.get_node_or_null("EnemyLevelLabel") if enemy_panel != null else null
onready var enemy_hp_bar = enemy_panel.get_node_or_null("EnemyHpBar") if enemy_panel != null else null
onready var enemy_hp_value_label = enemy_panel.get_node_or_null("EnemyHpValueLabel") if enemy_panel != null else null
onready var enemy_type1_sprite = enemy_panel.get_node_or_null("EnemyType1Sprite") if enemy_panel != null else null
onready var enemy_type2_sprite = enemy_panel.get_node_or_null("EnemyType2Sprite") if enemy_panel != null else null
onready var enemy_layer = battlefield_layer.get_node_or_null("EnemyLayer") if battlefield_layer != null else null
onready var enemy_arena_sprite = enemy_layer.get_node_or_null("EnemyArenaSprite") if enemy_layer != null else null
onready var enemy_arena_sprite_1 = enemy_layer.get_node_or_null("EnemyArenaSprite1") if enemy_layer != null else null
onready var enemy_arena_sprite_2 = enemy_layer.get_node_or_null("EnemyArenaSprite2") if enemy_layer != null else null
onready var enemy_arena_sprite_3 = enemy_layer.get_node_or_null("EnemyArenaSprite3") if enemy_layer != null else null
onready var enemy_pokemon_sprite = enemy_layer.get_node_or_null("EnemyPokemonSpriteBattle") if enemy_layer != null else null
onready var effects_layer = battlefield_layer.get_node_or_null("EffectsLayer") if battlefield_layer != null else null
onready var player_name_label = player_panel.get_node_or_null("PlayerNameLabel") if player_panel != null else null
onready var player_level_label = player_panel.get_node_or_null("PlayerLevelLabel") if player_panel != null else null
onready var player_hp_bar = player_panel.get_node_or_null("PlayerHpBar") if player_panel != null else null
onready var player_hp_value_label = player_panel.get_node_or_null("PlayerHpValueLabel") if player_panel != null else null
onready var player_type1_sprite = player_panel.get_node_or_null("PlayerType1Sprite") if player_panel != null else null
onready var player_type2_sprite = player_panel.get_node_or_null("PlayerType2Sprite") if player_panel != null else null
onready var player_layer = battlefield_layer.get_node_or_null("PlayerLayer") if battlefield_layer != null else null
onready var player_arena_sprite = player_layer.get_node_or_null("PlayerArenaSprite") if player_layer != null else null
onready var player_trainer_sprite = player_layer.get_node_or_null("PlayerTrainerSprite") if player_layer != null else null
onready var player_pokemon_sprite = player_layer.get_node_or_null("PlayerPokemonSprite") if player_layer != null else null
onready var battle_text_label = ui_layer.get_node_or_null("MessagePanel/MessageMargin/BattleTextLabel") if ui_layer != null else null
onready var current_arena_label = _resolve_first_existing([
	"UiScaleRoot/UILayer/CurrentArenaLabel",
	"UILayer/CurrentArenaLabel",
	"CurrentArenaLabel",
])
onready var move_button = controls_vbox.get_node_or_null("ControlsPanel1/FightButton") if controls_vbox != null else null
onready var ball_button = controls_vbox.get_node_or_null("ControlsPanel1/BallButton") if controls_vbox != null else null
onready var pokemon_button = controls_vbox.get_node_or_null("ControlsPanel2/PokemonButton") if controls_vbox != null else null
onready var run_button = controls_vbox.get_node_or_null("ControlsPanel2/RunButton") if controls_vbox != null else null
onready var attack_move_button_1 = attack_move_grid.get_node_or_null("AttackMoveButton1") if attack_move_grid != null else null
onready var attack_move_button_2 = attack_move_grid.get_node_or_null("AttackMoveButton2") if attack_move_grid != null else null
onready var attack_move_button_3 = attack_move_grid.get_node_or_null("AttackMoveButton3") if attack_move_grid != null else null
onready var attack_move_button_4 = attack_move_grid.get_node_or_null("AttackMoveButton4") if attack_move_grid != null else null
onready var attack_type_sprite = attack_move_details.get_node_or_null("AttackTypeSprite") if attack_move_details != null else null
onready var attack_power_label = attack_move_details.get_node_or_null("AttackPowerLabel") if attack_move_details != null else null
onready var attack_category_sprite = attack_move_details.get_node_or_null("AttackCategorySprite") if attack_move_details != null else null
onready var attack_pp_label = attack_move_details.get_node_or_null("AttackPpLabel") if attack_move_details != null else null
onready var ball_window_sprite = ball_menu_container.get_node_or_null("BallWindowSprite") if ball_menu_container != null else null
onready var ball_content_margin = ball_menu_container.get_node_or_null("BallWindowSprite/BallContentMargin") if ball_menu_container != null else null
onready var ball_pokeball_button = ball_button_list.get_node_or_null("PokeballButton") if ball_button_list != null else null
onready var ball_greatball_button = ball_button_list.get_node_or_null("GreatballButton") if ball_button_list != null else null
onready var ball_masterball_button = ball_button_list.get_node_or_null("MasterballButton") if ball_button_list != null else null
onready var ball_cancel_button = ball_button_list.get_node_or_null("BallCancelButton") if ball_button_list != null else null

# Runtime state and asset metadata.
var minimal_assets_path = "res://godot-minimal-assets/"
var hp_overlay_json = "assets/images/ui/overlay_hp.json"
var debug_log_path = "user://battle_debug.log"
var type_ui_assets := {
	"enemy": {
		"single_texture": "assets/images/ui/pbinfo_enemy_type.png",
		"single_json": "assets/images/ui/pbinfo_enemy_type.json",
		"type1_texture": "assets/images/ui/pbinfo_enemy_type1.png",
		"type1_json": "assets/images/ui/pbinfo_enemy_type1.json",
		"type2_texture": "assets/images/ui/pbinfo_enemy_type2.png",
		"type2_json": "assets/images/ui/pbinfo_enemy_type2.json",
	},
	"player": {
		"single_texture": "assets/images/ui/pbinfo_player_type.png",
		"single_json": "assets/images/ui/pbinfo_player_type.json",
		"type1_texture": "assets/images/ui/pbinfo_player_type1.png",
		"type1_json": "assets/images/ui/pbinfo_player_type1.json",
		"type2_texture": "assets/images/ui/pbinfo_player_type2.png",
		"type2_json": "assets/images/ui/pbinfo_player_type2.json",
	},
}

var battle_data = null
var last_applied_arena_asset_id := ""
var arena_blend_tween: Tween = null
var biome_bgm_primary_player: AudioStreamPlayer = null
var biome_bgm_secondary_player: AudioStreamPlayer = null
var biome_bgm_active_player: AudioStreamPlayer = null
var biome_bgm_crossfade_tween: Tween = null
var current_bgm_arena_asset_id := ""
var hp_overlay_frames := {}
var move_anim_textures := {}
var move_anim_configs := {}
var add_blend_material: CanvasItemMaterial = null
const ANIM_FOCUS_TARGET = 1
const ANIM_FOCUS_USER = 2
const ANIM_FOCUS_USER_TARGET = 3
const ANIM_FOCUS_SCREEN = 4
const USER_FOCUS_X = 106.0
const USER_FOCUS_Y = 116.0
const TARGET_FOCUS_X = 234.0
const TARGET_FOCUS_Y = 52.0
const MOVE_SHEET_FRAME_SIZE = 96
var battle_ended := false
var turn_in_progress := false
var turn_token := 0
var player_sprite_frames := []
var enemy_sprite_frames := []
var player_anim_index := 0
var enemy_anim_index := 0
var player_anim_elapsed := 0.0
var enemy_anim_elapsed := 0.0
var enemy_layer_home_position := Vector2.ZERO
var player_sprite_home_position := Vector2.ZERO
var player_sprite_home_scale := Vector2.ONE
var enemy_sprite_home_position := Vector2.ZERO
var enemy_sprite_home_scale := Vector2.ONE
var player_trainer_sprite_home_position := Vector2.ZERO
var player_sprite_anim_enabled := true
var enemy_sprite_anim_enabled := true
var player_trainer_texture_back = null
var player_trainer_texture_back_pb = null
var player_trainer_idle_frame := {}
var player_trainer_throw_frames := []
var player_trainer_choreo_playing := false
var player_trainer_choreo_elapsed := 0.0
var player_trainer_last_throw_index := -1
var player_trainer_pokemon_revealed := false
var player_trainer_exit_started := false
var player_pokeball_sprite = null
var player_pokeball_lob_started := false
var player_pokeball_release_done := false
var player_sendout_cry_played := false
var player_sendout_cry_key := ""
var player_cry_audio_player: AudioStreamPlayer = null
var enemy_sendout_cry_key := ""
var enemy_cry_audio_player: AudioStreamPlayer = null
var pokeball_particles_texture = null
var pokeball_particles_frames := []
var pokeball_open_particle_sprite_frames: SpriteFrames = null
var catalog_loader = null
var selected_player_species_id := ""
var attack_menu_visible := false
var ball_menu_visible := false
var party_menu_visible := false
var party_menu_overlay = null
var enemy_species_pool := []
var ball_inventory := BALL_DEFAULT_COUNTS.duplicate(true)
var capture_in_progress := false
var sendout_controls_locked := false

# Lifecycle and diagnostics.
func _ready():
	if ui_scale_root != null:
		ui_scale_root.rect_scale = Vector2(ui_scale, ui_scale)
	if not _validate_required_refs():
		return
	randomize()
	log_debug("Battle scene ready")
	log_debug("Using minimal assets path: %s" % minimal_assets_path)
	update_run_button_label()
	enemy_layer_home_position = enemy_layer.rect_position
	player_sprite_home_position = player_pokemon_sprite.position
	player_sprite_home_scale = player_pokemon_sprite.scale
	enemy_sprite_home_position = enemy_pokemon_sprite.position
	enemy_sprite_home_scale = enemy_pokemon_sprite.scale
	if player_trainer_sprite != null:
		player_trainer_sprite_home_position = player_trainer_sprite.position
	build_hp_overlay_frames()
	load_audio_assets()
	setup_type_sprite_placeholders()
	setup_attack_detail_sprites()
	setup_party_menu_overlay()
	reset_battle_state("Battle ready.")
	if ball_menu_container != null:
		ball_menu_container.visible = false
	refresh_ball_menu_layout()

	add_blend_material = CanvasItemMaterial.new()
	add_blend_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	setup_keyboard_controls()
	if debug_open_party_menu_on_ready:
		call_deferred("_open_party_menu_on_ready")

func _open_party_menu_on_ready():
	if turn_in_progress or battle_ended:
		return
	open_party_menu()

func log_debug(message: String):
	var f = File.new()
	# Ensure the log file exists before opening in append mode.
	if not f.file_exists(debug_log_path):
		var create_error = f.open(debug_log_path, File.WRITE_READ)
		if create_error != OK:
			print("[Battle] log create failed: %s" % debug_log_path)
			return
		f.close()

	var open_error = f.open(debug_log_path, File.READ_WRITE)
	if open_error != OK:
		print("[Battle] log open failed: %s" % debug_log_path)
		return
	f.seek_end()
	f.store_line("[%s] %s" % [str(OS.get_unix_time()), message])
	f.close()

func resource_exists(path: String) -> bool:
	# In exported builds, imported resources may not be visible to File.file_exists.
	if ResourceLoader.exists(path):
		return true
	var f = File.new()
	return f.file_exists(path)

func _validate_required_refs() -> bool:
	var required_refs = {
		"ui_layer": ui_layer,
		"battlefield_layer": battlefield_layer,
		"enemy_layer": enemy_layer,
		"player_layer": player_layer,
		"enemy_panel": enemy_panel,
		"player_panel": player_panel,
		"enemy_name_label": enemy_name_label,
		"enemy_level_label": enemy_level_label,
		"enemy_hp_bar": enemy_hp_bar,
		"player_name_label": player_name_label,
		"player_level_label": player_level_label,
		"player_hp_bar": player_hp_bar,
		"enemy_pokemon_sprite": enemy_pokemon_sprite,
		"player_pokemon_sprite": player_pokemon_sprite,
		"battle_text_label": battle_text_label,
		"move_button": move_button,
		"ball_button": ball_button,
		"pokemon_button": pokemon_button,
		"run_button": run_button,
		"attack_move_button_1": attack_move_button_1,
		"attack_move_button_2": attack_move_button_2,
		"attack_move_button_3": attack_move_button_3,
		"attack_move_button_4": attack_move_button_4,
		"attack_type_sprite": attack_type_sprite,
		"attack_category_sprite": attack_category_sprite,
		"attack_power_label": attack_power_label,
		"attack_pp_label": attack_pp_label,
	}

	for ref_name in required_refs.keys():
		if required_refs[ref_name] == null:
			push_error("Battle scene is missing required node reference: %s" % ref_name)
			return false

	return true

# Scene setup and data binding.
func setup_party_menu_overlay():
	if party_menu_scene == null:
		return

	party_menu_overlay = party_menu_scene.instance()
	if party_menu_overlay == null:
		return

	party_menu_overlay.visible = false
	party_menu_visible = false
	_connect_once(party_menu_overlay, "close_requested", "_on_PartyMenu_close_requested")
	_connect_once(party_menu_overlay, "switch_slot_requested", "_on_PartyMenu_switch_slot_requested")
	add_child(party_menu_overlay)
	party_menu_overlay.raise()

func bind_battle_data():
	var enemy_data = battle_data["enemy"]
	var player_data = battle_data["player"]

	enemy_name_label.text = enemy_data.species_id
	enemy_level_label.text = "Lv. %d" % enemy_data.level
	player_name_label.text = player_data.species_id
	player_level_label.text = "Lv. %d" % player_data.level

	refresh_hp_ui(enemy_data, enemy_hp_bar, enemy_hp_value_label)
	refresh_hp_ui(player_data, player_hp_bar, player_hp_value_label)
	refresh_type_ui(enemy_data, "enemy", enemy_type1_sprite, enemy_type2_sprite)
	refresh_type_ui(player_data, "player", player_type1_sprite, player_type2_sprite)
	_apply_arena_visuals_from_biome_state()
	_refresh_current_arena_label()

func _refresh_current_arena_label() -> void:
	if current_arena_label == null:
		return
	var biome_state = _get_battle_biome_state()
	var arena_name = String(battle_data.get("arena_asset_id", biome_state.get("current_biome_id", "grass"))).strip_edges().to_lower()
	if arena_name.empty():
		arena_name = "grass"
	var current_level = max(1, int(biome_state.get("encounter_index", 0)) + 1)
	current_arena_label.text = "%s - %02d" % [arena_name, current_level]

func _get_battle_biome_state() -> Dictionary:
	if typeof(battle_data) == TYPE_DICTIONARY and battle_data.has("biome_state") and typeof(battle_data["biome_state"]) == TYPE_DICTIONARY:
		return battle_data["biome_state"]
	return {
		"current_biome_id": "grass",
		"encounter_index": 0,
	}

func _format_biome_name(biome_id: String) -> String:
	var raw = biome_id.strip_edges().replace("_", " ").replace("-", " ")
	if raw.empty():
		return "Unknown"
	var words = raw.split(" ", false)
	for i in range(words.size()):
		var word = String(words[i]).strip_edges()
		if word.empty():
			continue
		words[i] = word.substr(0, 1).to_upper() + word.substr(1)
	return " ".join(words)

func _normalize_arena_asset_id(raw_id: String) -> String:
	return raw_id.strip_edges().to_lower().replace("_", "-").replace(" ", "-")

func _build_arena_texture_path(arena_id: String, suffix: String) -> String:
	return "%sassets/images/arenas/%s%s.png" % [minimal_assets_path, arena_id, suffix]

func _build_bgm_path(track_id: String) -> String:
	return "%sassets/audio/bgm/%s.mp3" % [minimal_assets_path, track_id]

func _load_arena_texture(arena_id: String, suffix: String):
	var path = _build_arena_texture_path(arena_id, suffix)
	if not resource_exists(path):
		return null
	return load(path)

func _has_any_arena_asset(arena_id: String) -> bool:
	for suffix in ["_bg", "_a", "_b", "_b_1", "_b_2", "_b_3"]:
		if resource_exists(_build_arena_texture_path(arena_id, suffix)):
			return true
	return false

func _resolve_arena_asset_id(preferred_id: String) -> String:
	var normalized_preferred = _normalize_arena_asset_id(preferred_id)
	if normalized_preferred.empty():
		normalized_preferred = "grass"
	if _has_any_arena_asset(normalized_preferred):
		return normalized_preferred
	if normalized_preferred != "grass" and _has_any_arena_asset("grass"):
		return "grass"
	return normalized_preferred

func _pick_next_test_arena_id(current_biome_id: String) -> String:
	var rotation: Array = biome_test_arena_rotation
	if rotation.empty():
		return ""

	var normalized_entries := []
	for entry in rotation:
		var normalized_entry = _normalize_arena_asset_id(String(entry))
		if normalized_entry.empty():
			continue
		normalized_entries.append(normalized_entry)

	if normalized_entries.empty():
		return ""

	var normalized_current = _normalize_arena_asset_id(current_biome_id)
	var current_index = normalized_entries.find(normalized_current)
	if current_index == -1:
		return String(normalized_entries[0])
	return String(normalized_entries[(current_index + 1) % normalized_entries.size()])

func _set_arena_texture(target_node, texture) -> void:
	if target_node == null:
		return
	if target_node is TextureRect:
		target_node.texture = texture
		target_node.visible = texture != null
		return
	if target_node is Sprite:
		target_node.texture = texture
		target_node.visible = texture != null

func _ensure_biome_bgm_players() -> void:
	if biome_bgm_primary_player == null:
		biome_bgm_primary_player = get_node_or_null("AudioStreamPlayer")

	if biome_bgm_primary_player == null:
		return

	if biome_bgm_secondary_player == null:
		biome_bgm_secondary_player = AudioStreamPlayer.new()
		biome_bgm_secondary_player.name = "AudioStreamPlayerBiomeCrossfade"
		biome_bgm_secondary_player.bus = biome_bgm_primary_player.bus
		add_child(biome_bgm_secondary_player)

	if biome_bgm_active_player == null:
		biome_bgm_active_player = biome_bgm_primary_player

func _configure_bgm_stream_loop(stream) -> void:
	if stream == null:
		return
	if stream is AudioStreamMP3:
		stream.loop = true
	elif stream is AudioStreamOGGVorbis:
		stream.loop = true
	elif stream is AudioStreamSample:
		stream.loop_mode = AudioStreamSample.LOOP_FORWARD

func _resolve_biome_bgm_stream(arena_asset_id: String) -> Dictionary:
	var normalized_id = _normalize_arena_asset_id(arena_asset_id)
	if normalized_id.empty():
		normalized_id = "grass"

	var candidates = [normalized_id, "grass", "title"]
	var tried := {}
	for candidate in candidates:
		var track_id = String(candidate)
		if tried.has(track_id):
			continue
		tried[track_id] = true
		var path = _build_bgm_path(track_id)
		if resource_exists(path):
			return {"stream": load(path), "track_id": track_id}

	return {"stream": null, "track_id": ""}

func _get_inactive_bgm_player() -> AudioStreamPlayer:
	if biome_bgm_primary_player == null:
		return null
	if biome_bgm_secondary_player == null:
		return biome_bgm_primary_player
	if biome_bgm_active_player == biome_bgm_primary_player:
		return biome_bgm_secondary_player
	return biome_bgm_primary_player

func _stop_biome_bgm_crossfade_tween() -> void:
	if biome_bgm_crossfade_tween != null and is_instance_valid(biome_bgm_crossfade_tween):
		biome_bgm_crossfade_tween.stop_all()
		biome_bgm_crossfade_tween.queue_free()
	biome_bgm_crossfade_tween = null

func _on_biome_bgm_crossfade_completed(outgoing_player: AudioStreamPlayer) -> void:
	if outgoing_player != null and is_instance_valid(outgoing_player):
		outgoing_player.stop()
		outgoing_player.volume_db = biome_bgm_volume_db
	_stop_biome_bgm_crossfade_tween()

func _play_biome_bgm_for_arena(arena_asset_id: String, force_restart: bool = false) -> void:
	_ensure_biome_bgm_players()
	if biome_bgm_primary_player == null:
		return

	var stream_data = _resolve_biome_bgm_stream(arena_asset_id)
	var bgm_stream = stream_data.get("stream", null)
	var resolved_track_id = String(stream_data.get("track_id", ""))
	if bgm_stream == null:
		log_debug("Missing biome BGM for arena '%s'" % arena_asset_id)
		return

	if not force_restart and resolved_track_id == current_bgm_arena_asset_id:
		if biome_bgm_active_player != null and not biome_bgm_active_player.playing:
			biome_bgm_active_player.play()
		biome_bgm_active_player.volume_db = biome_bgm_volume_db
		return

	_configure_bgm_stream_loop(bgm_stream)
	var incoming_player = _get_inactive_bgm_player()
	var outgoing_player = biome_bgm_active_player
	if incoming_player == null:
		incoming_player = biome_bgm_primary_player

	incoming_player.stop()
	incoming_player.stream = bgm_stream

	var crossfade_duration = max(0.0, biome_bgm_crossfade_duration_sec)
	if outgoing_player == null or force_restart:
		_stop_biome_bgm_crossfade_tween()
		incoming_player.volume_db = biome_bgm_volume_db
		incoming_player.play()
		biome_bgm_active_player = incoming_player
		current_bgm_arena_asset_id = resolved_track_id
		return

	incoming_player.volume_db = -80.0
	incoming_player.play()

	if crossfade_duration <= 0.0:
		_stop_biome_bgm_crossfade_tween()
		outgoing_player.stop()
		outgoing_player.volume_db = biome_bgm_volume_db
		incoming_player.volume_db = biome_bgm_volume_db
		biome_bgm_active_player = incoming_player
		current_bgm_arena_asset_id = resolved_track_id
		return

	_stop_biome_bgm_crossfade_tween()
	biome_bgm_crossfade_tween = Tween.new()
	add_child(biome_bgm_crossfade_tween)
	biome_bgm_crossfade_tween.interpolate_property(
		incoming_player,
		"volume_db",
		-80.0,
		biome_bgm_volume_db,
		crossfade_duration,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	biome_bgm_crossfade_tween.interpolate_property(
		outgoing_player,
		"volume_db",
		outgoing_player.volume_db,
		-80.0,
		crossfade_duration,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	_connect_once(
		biome_bgm_crossfade_tween,
		"tween_all_completed",
		"_on_biome_bgm_crossfade_completed",
		[outgoing_player]
	)
	biome_bgm_crossfade_tween.start()

	biome_bgm_active_player = incoming_player
	current_bgm_arena_asset_id = resolved_track_id

func _get_arena_visual_nodes() -> Array:
	return [
		arena_backdrop,
		player_arena_sprite,
		enemy_arena_sprite,
		enemy_arena_sprite_1,
		enemy_arena_sprite_2,
		enemy_arena_sprite_3,
	]

func _set_arena_visual_alpha(node, alpha: float) -> void:
	if node == null:
		return
	var current = node.modulate
	node.modulate = Color(current.r, current.g, current.b, clamp(alpha, 0.0, 1.0))

func _stop_arena_blend_tween() -> void:
	if arena_blend_tween != null and is_instance_valid(arena_blend_tween):
		arena_blend_tween.stop_all()
		arena_blend_tween.queue_free()
	arena_blend_tween = null

func _set_all_arena_visual_alpha(alpha: float) -> void:
	for node in _get_arena_visual_nodes():
		if node == null or not node.visible:
			continue
		_set_arena_visual_alpha(node, alpha)

func _on_arena_blend_tween_completed() -> void:
	_stop_arena_blend_tween()

func _start_arena_visual_fade_in() -> void:
	_stop_arena_blend_tween()
	var duration = max(0.01, arena_switch_blend_duration_sec)
	var has_targets := false
	arena_blend_tween = Tween.new()
	add_child(arena_blend_tween)
	for node in _get_arena_visual_nodes():
		if node == null or not node.visible:
			continue
		has_targets = true
		_set_arena_visual_alpha(node, 0.0)
		arena_blend_tween.interpolate_property(
			node,
			"modulate:a",
			0.0,
			1.0,
			duration,
			Tween.TRANS_SINE,
			Tween.EASE_IN_OUT
		)

	if not has_targets:
		_stop_arena_blend_tween()
		return

	_connect_once(arena_blend_tween, "tween_all_completed", "_on_arena_blend_tween_completed")
	arena_blend_tween.start()

func _apply_arena_visuals_from_biome_state() -> void:
	if typeof(battle_data) != TYPE_DICTIONARY:
		return
	var biome_state = _get_battle_biome_state()
	var requested_arena_id = String(biome_state.get("current_biome_id", "grass"))
	var resolved_arena_id = _resolve_arena_asset_id(requested_arena_id)
	var should_blend = (
		not last_applied_arena_asset_id.empty()
		and last_applied_arena_asset_id != resolved_arena_id
		and arena_switch_blend_duration_sec > 0.0
	)
	battle_data["arena_asset_id"] = resolved_arena_id

	_set_arena_texture(arena_backdrop, _load_arena_texture(resolved_arena_id, "_bg"))
	_set_arena_texture(player_arena_sprite, _load_arena_texture(resolved_arena_id, "_a"))
	_set_arena_texture(enemy_arena_sprite, _load_arena_texture(resolved_arena_id, "_b"))
	_set_arena_texture(enemy_arena_sprite_1, _load_arena_texture(resolved_arena_id, "_b_1"))
	_set_arena_texture(enemy_arena_sprite_2, _load_arena_texture(resolved_arena_id, "_b_2"))
	_set_arena_texture(enemy_arena_sprite_3, _load_arena_texture(resolved_arena_id, "_b_3"))
	_play_biome_bgm_for_arena(resolved_arena_id)

	if should_blend:
		_start_arena_visual_fade_in()
	else:
		_stop_arena_blend_tween()
		_set_all_arena_visual_alpha(1.0)

	last_applied_arena_asset_id = resolved_arena_id

func refresh_hp_ui(pokemon_data, hp_bar, hp_label):
	var max_hp = pokemon_data.get_base_stat("hp")
	var hp_ratio := 0.0
	if max_hp > 0:
		hp_ratio = clamp(float(pokemon_data.current_hp) / float(max_hp), 0.0, 1.0)
	update_hp_bar_sprite(hp_bar, hp_ratio)
	if hp_label != null:
		hp_label.text = "%d / %d" % [pokemon_data.current_hp, max_hp]

func setup_type_sprite_placeholders():
	configure_type_sprite(enemy_type1_sprite, Vector2(89, 49))
	configure_type_sprite(enemy_type2_sprite, Vector2(89, 61))
	configure_type_sprite(player_type1_sprite, Vector2(89, 43))
	configure_type_sprite(player_type2_sprite, Vector2(89, 55))

func setup_attack_detail_sprites():
	configure_type_sprite(attack_type_sprite, Vector2.ZERO)
	configure_type_sprite(attack_category_sprite, Vector2.ZERO)

func configure_type_sprite(type_sprite, fallback_position: Vector2):
	if type_sprite == null:
		return
	type_sprite.centered = false
	type_sprite.region_enabled = true
	type_sprite.visible = false
	if type_sprite.position == Vector2.ZERO:
		type_sprite.position = fallback_position

func refresh_type_ui(pokemon_data, panel_key: String, type1_sprite, type2_sprite):
	if type1_sprite == null or type2_sprite == null:
		return

	var types = []
	if pokemon_data != null:
		types = pokemon_data.get_types()

	if types.empty():
		types = ["UNKNOWN"]

	if types.size() == 1:
		apply_type_badge(type1_sprite, panel_key, "single", str(types[0]))
		type2_sprite.visible = false
		return

	apply_type_badge(type1_sprite, panel_key, "type1", str(types[0]))
	apply_type_badge(type2_sprite, panel_key, "type2", str(types[1]))

func apply_type_badge(type_sprite, panel_key: String, badge_variant: String, type_name: String):
	if type_sprite == null:
		return
	if not type_ui_assets.has(panel_key):
		type_sprite.visible = false
		return

	var panel_assets = type_ui_assets[panel_key]
	var texture_key = "single_texture" if badge_variant == "single" else badge_variant + "_texture"
	var json_key = "single_json" if badge_variant == "single" else badge_variant + "_json"

	if not panel_assets.has(texture_key) or not panel_assets.has(json_key):
		type_sprite.visible = false
		return

	var texture_path = minimal_assets_path + String(panel_assets[texture_key])
	var atlas_json_path = minimal_assets_path + String(panel_assets[json_key])
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

func build_hp_overlay_frames():
	hp_overlay_frames.clear()
	var json_path = minimal_assets_path + hp_overlay_json
	for frame_name in ["high", "medium", "low"]:
		var sprite_info = parse_sprite_frame(json_path, frame_name)
		if sprite_info == null:
			continue
		var frame = sprite_info["frame"]
		hp_overlay_frames[frame_name] = Rect2(frame["x"], frame["y"], frame["w"], frame["h"])

func get_hp_frame_name(hp_ratio: float) -> String:
	if hp_ratio > 0.5:
		return "high"
	if hp_ratio > 0.2:
		return "medium"
	return "low"

func update_hp_bar_sprite(hp_bar, hp_ratio: float):
	if hp_bar == null or not (hp_bar is Sprite):
		return

	var frame_name = get_hp_frame_name(hp_ratio)
	if not hp_overlay_frames.has(frame_name):
		return

	var frame_rect: Rect2 = hp_overlay_frames[frame_name]
	var visible_width = int(round(frame_rect.size.x * hp_ratio))
	if hp_ratio > 0.0 and visible_width < 1:
		visible_width = 1

	hp_bar.region_enabled = true
	hp_bar.region_rect = Rect2(frame_rect.position.x, frame_rect.position.y, visible_width, frame_rect.size.y)

func load_audio_assets():
	_ensure_biome_bgm_players()
	if biome_bgm_primary_player == null:
		log_debug("Missing BGM player node: AudioStreamPlayer")
	else:
		biome_bgm_primary_player.volume_db = biome_bgm_volume_db
	if biome_bgm_secondary_player != null:
		biome_bgm_secondary_player.volume_db = -80.0

	var select_path = minimal_assets_path + "assets/audio/ui/select.wav"
	if resource_exists(select_path):
		$UIAudioStreamPlayer.stream = load(select_path)
	else:
		log_debug("Missing UI SFX resource: %s" % select_path)

func _process(_delta):
	update_pokemon_animations(_delta)
	update_player_trainer_choreography(_delta)

	if Input.is_action_just_pressed("ui_accept") and get_focus_owner() == null and not turn_in_progress and not battle_ended:
		set_battle_text("Battle scene ready. Press the move button to continue.")

# Input and command dispatch.
func _input(event):
	if not (event is InputEventKey):
		return
	if not event.pressed or event.echo:
		return
	if ball_menu_visible:
		if event.is_action_pressed("ui_back"):
			hide_ball_menu(true)
			accept_event()
			return
		if event.is_action_pressed("ui_up"):
			move_ball_menu_focus("ui_up", get_focus_owner())
			accept_event()
			return
		if event.is_action_pressed("ui_down"):
			move_ball_menu_focus("ui_down", get_focus_owner())
			accept_event()
			return
		if event.is_action_pressed("ui_left"):
			move_ball_menu_focus("ui_left", get_focus_owner())
			accept_event()
			return
		if event.is_action_pressed("ui_right"):
			move_ball_menu_focus("ui_right", get_focus_owner())
			accept_event()
			return
		if event.is_action_pressed("ui_accept"):
			press_focused_button()
			accept_event()
			return
	if not party_menu_visible:
		return

	if event.is_action_pressed("ui_back"):
		if party_menu_overlay != null and party_menu_overlay.handle_back_action():
			accept_event()
			return
		close_party_menu()
		accept_event()
		return
	if event.is_action_pressed("ui_up"):
		party_menu_overlay.move_focus("ui_up")
		accept_event()
		return
	if event.is_action_pressed("ui_down"):
		party_menu_overlay.move_focus("ui_down")
		accept_event()
		return
	if event.is_action_pressed("ui_left"):
		party_menu_overlay.move_focus("ui_left")
		accept_event()
		return
	if event.is_action_pressed("ui_right"):
		party_menu_overlay.move_focus("ui_right")
		accept_event()
		return
	if event.is_action_pressed("ui_accept"):
		party_menu_overlay.press_focused()
		accept_event()
		return

func _unhandled_input(event):
	if not (event is InputEventKey):
		return
	if not event.pressed or event.echo:
		return

	if party_menu_visible:
		return
	if ball_menu_visible:
		return

	if event.is_action_pressed("ui_left"):
		move_button_focus("ui_left")
		accept_event()
		return
	if event.is_action_pressed("ui_right"):
		move_button_focus("ui_right")
		accept_event()
		return
	if event.is_action_pressed("ui_up"):
		move_button_focus("ui_up")
		accept_event()
		return
	if event.is_action_pressed("ui_down"):
		move_button_focus("ui_down")
		accept_event()
		return
	if event.is_action_pressed("ui_accept"):
		press_focused_button()
		accept_event()
		return
	if event.is_action_pressed("ui_back"):
		if attack_menu_visible:
			close_attack_menu()
			accept_event()
		return

func _on_MoveButton_pressed():
	if battle_ended:
		set_battle_text("Battle has ended. Press Ball to restart.")
		return

	if turn_in_progress:
		return

	show_attack_menu()
	set_battle_text("")

func _on_AttackMoveButton_pressed(move_slot: int):
	if battle_ended:
		set_battle_text("Battle has ended. Press Ball to restart.")
		return

	if turn_in_progress:
		return

	var attacker = battle_data["player"]
	if attacker == null:
		set_battle_text("Battle data missing.")
		return

	if move_slot < 0 or move_slot >= attacker.moves.size():
		set_battle_text("No move in that slot.")
		return

	execute_player_move(attacker.moves[move_slot])

func _on_AttackMoveButton_focus_entered(move_slot: int):
	refresh_attack_move_details(move_slot)

func close_attack_menu():
	if turn_in_progress or battle_ended:
		return
	hide_attack_menu()
	ensure_button_focus()

func execute_player_move(move):
	if move == null:
		set_battle_text("No move available.")
		return

	turn_in_progress = true
	_enter_action_locked_state()
	var active_turn_token = turn_token

	var attacker = battle_data["player"]
	var defender = battle_data["enemy"]
	if attacker == null or defender == null:
		set_battle_text("Battle data missing.")
		_finish_turn()
		return

	var player_move_anim = play_move_animation(move.move_id, player_pokemon_sprite, enemy_pokemon_sprite, active_turn_token)
	if player_move_anim is GDScriptFunctionState:
		yield(player_move_anim, "completed")
		if active_turn_token != turn_token:
			return

	var damage = int(battle_calc_script.calc_damage(attacker, move, defender))
	defender.current_hp = max(0, defender.current_hp - damage)
	var player_type_multiplier = battle_calc_script.get_type_multiplier(move.move_type, defender)

	refresh_hp_ui(defender, enemy_hp_bar, enemy_hp_value_label)
	var player_hit_feedback = play_hit_feedback(enemy_pokemon_sprite, active_turn_token)
	if player_hit_feedback is GDScriptFunctionState:
		yield(player_hit_feedback, "completed")
		if active_turn_token != turn_token:
			return

	var battle_message = "%s used %s! %d damage." % [attacker.species_id, move.move_id, damage]
	battle_message += build_type_effectiveness_text(player_type_multiplier)
	set_battle_text(battle_message)
	if turn_step_delay_sec > 0.0:
		yield(get_tree().create_timer(turn_step_delay_sec), "timeout")
		if active_turn_token != turn_token:
			return

	if defender.is_fainted():
		var enemy_faint_anim = play_faint_animation(enemy_pokemon_sprite, false, active_turn_token)
		if enemy_faint_anim is GDScriptFunctionState:
			yield(enemy_faint_anim, "completed")
			if active_turn_token != turn_token:
				return
		var enemy_advance = advance_to_next_enemy(defender.species_id, active_turn_token)
		if enemy_advance is GDScriptFunctionState:
			yield(enemy_advance, "completed")
			if active_turn_token != turn_token:
				return
		_finish_turn()
		return

	if defender.moves.empty():
		set_battle_text("%s has no move." % defender.species_id)
		_finish_turn()
		return

	var enemy_move = defender.moves[0]
	var enemy_move_anim = play_move_animation(enemy_move.move_id, enemy_pokemon_sprite, player_pokemon_sprite, active_turn_token)
	if enemy_move_anim is GDScriptFunctionState:
		yield(enemy_move_anim, "completed")
		if active_turn_token != turn_token:
			return

	var enemy_damage = int(battle_calc_script.calc_damage(defender, enemy_move, attacker))
	attacker.current_hp = max(0, attacker.current_hp - enemy_damage)
	var enemy_type_multiplier = battle_calc_script.get_type_multiplier(enemy_move.move_type, attacker)
	refresh_hp_ui(attacker, player_hp_bar, player_hp_value_label)
	sync_active_party_member_from_battle()
	var enemy_hit_feedback = play_hit_feedback(player_pokemon_sprite, active_turn_token)
	if enemy_hit_feedback is GDScriptFunctionState:
		yield(enemy_hit_feedback, "completed")
		if active_turn_token != turn_token:
			return

	var enemy_message = "%s used %s! %d damage." % [defender.species_id, enemy_move.move_id, enemy_damage]
	enemy_message += build_type_effectiveness_text(enemy_type_multiplier)
	set_battle_text(enemy_message)
	if turn_step_delay_sec > 0.0:
		yield(get_tree().create_timer(turn_step_delay_sec), "timeout")
		if active_turn_token != turn_token:
			return

	if attacker.is_fainted():
		var player_faint_anim = play_faint_animation(player_pokemon_sprite, true, active_turn_token)
		if player_faint_anim is GDScriptFunctionState:
			yield(player_faint_anim, "completed")
			if active_turn_token != turn_token:
				return
		end_battle(false, attacker.species_id)
		_finish_turn()
		return

	_finish_turn()

func _on_BallButton_pressed():
	if battle_ended:
		reset_battle_state("Battle reset.")
		return

	if turn_in_progress or capture_in_progress:
		return

	if attack_menu_visible:
		hide_attack_menu()
	if party_menu_visible:
		close_party_menu()

	show_ball_menu()

func _on_BallMenu_pokeball_pressed():
	attempt_capture_with_ball(BALL_KEY_POKEBALL)

func _on_BallMenu_greatball_pressed():
	attempt_capture_with_ball(BALL_KEY_GREATBALL)

func _on_BallMenu_masterball_pressed():
	attempt_capture_with_ball(BALL_KEY_MASTERBALL)

func _on_BallMenu_cancel_pressed():
	hide_ball_menu(true)

func _on_PokemonButton_pressed():
	if battle_ended:
		set_battle_text("Battle has ended. Press Ball to restart.")
		return

	if turn_in_progress:
		return

	if attack_menu_visible:
		hide_attack_menu()

	open_party_menu()

func _on_RunButton_pressed():
	if turn_in_progress:
		return

	battle_fx_enabled = not battle_fx_enabled
	reset_pokemon_animation_state()
	update_run_button_label()
	var state_text = "ON" if battle_fx_enabled else "OFF"
	set_battle_text("Battle FX toggled %s." % state_text)

# Capture flow and ball handling.
func attempt_capture_with_ball(ball_key: String) -> void:
	if battle_ended or turn_in_progress or capture_in_progress:
		return
	if battle_data == null or not battle_data.has("enemy") or battle_data["enemy"] == null:
		set_battle_text("No target to capture.")
		return

	var available = int(ball_inventory.get(ball_key, 0))
	if available <= 0:
		set_battle_text("No %s left." % _get_ball_label(ball_key))
		refresh_ball_menu_labels()
		focus_first_ball_menu_button()
		return

	ball_inventory[ball_key] = max(0, available - 1)
	refresh_ball_menu_labels()
	_enter_action_locked_state()

	turn_in_progress = true
	capture_in_progress = true
	var active_turn_token = turn_token
	var enemy = battle_data["enemy"]
	var capture_flow = _run_capture_sequence(ball_key, enemy, active_turn_token)
	if capture_flow is GDScriptFunctionState:
		yield(capture_flow, "completed")

	if active_turn_token != turn_token:
		capture_in_progress = false
		return

	capture_in_progress = false
	_finish_turn()

func _run_capture_sequence(ball_key: String, enemy, active_turn_token: int):
	set_battle_text("You threw a %s!" % _get_ball_label(ball_key))
	_play_capture_sfx("pb_throw.wav")

	var throw_anim = _play_capture_throw_open_animation(ball_key, active_turn_token)
	if throw_anim is GDScriptFunctionState:
		yield(throw_anim, "completed")
	if active_turn_token != turn_token:
		return null

	var shake_successes = _roll_capture_shakes(ball_key, enemy)
	var capture_success = shake_successes >= CAPTURE_REQUIRED_SHAKES
	var shake_anim = _play_capture_shakes(ball_key, enemy, shake_successes, capture_success, active_turn_token)
	if shake_anim is GDScriptFunctionState:
		yield(shake_anim, "completed")
	if active_turn_token != turn_token:
		return null

	if capture_success:
		var success_flow = _handle_capture_success(enemy, active_turn_token)
		if success_flow is GDScriptFunctionState:
			yield(success_flow, "completed")
		return null

	_handle_capture_failure(enemy)
	return null

func _play_capture_throw_open_animation(ball_key: String, active_turn_token: int):
	if not _apply_capture_ball_frame(ball_key, ""):
		return null

	var sprite = player_pokeball_sprite
	sprite.visible = true
	sprite.rotation_degrees = 0.0
	var start_pos = player_sprite_home_position + Vector2(capture_throw_start_offset_x, capture_throw_start_offset_y)
	var target_pos = enemy_sprite_home_position + Vector2(capture_throw_target_offset_x, capture_throw_target_offset_y)
	var arc_peak_y = min(start_pos.y, target_pos.y) - abs(capture_throw_arc_height_px)
	var total_duration = max(0.08, capture_throw_duration_sec)
	var up_duration = clamp(capture_throw_up_duration_sec, 0.04, total_duration - 0.04)
	var down_duration = max(0.04, total_duration - up_duration)
	sprite.position = start_pos

	var throw_tween = Tween.new()
	add_child(throw_tween)
	throw_tween.interpolate_property(sprite, "position:x", start_pos.x, target_pos.x, total_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	throw_tween.interpolate_property(sprite, "rotation_degrees", 0.0, 540.0, total_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	throw_tween.interpolate_property(sprite, "position:y", start_pos.y, arc_peak_y, up_duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	throw_tween.interpolate_property(sprite, "position:y", arc_peak_y, target_pos.y, down_duration, Tween.TRANS_CUBIC, Tween.EASE_IN, up_duration)
	throw_tween.start()
	yield(throw_tween, "tween_all_completed")
	throw_tween.queue_free()
	if active_turn_token != turn_token:
		return null

	var _opening_frame_applied = _apply_capture_ball_frame(ball_key, "_opening")
	yield(get_tree().create_timer(0.08), "timeout")
	if active_turn_token != turn_token:
		return null

	var _open_frame_applied = _apply_capture_ball_frame(ball_key, "_open")
	_play_capture_sfx("pb_rel.wav")
	_spawn_player_pokeball_open_particles(target_pos + Vector2(0, -2))
	var absorb_anim = _play_capture_enemy_absorb_animation(target_pos, active_turn_token)
	if absorb_anim is GDScriptFunctionState:
		yield(absorb_anim, "completed")
	if active_turn_token != turn_token:
		return null
	yield(get_tree().create_timer(max(0.01, capture_enemy_absorb_delay_sec)), "timeout")
	if active_turn_token != turn_token:
		return null

	var _closed_frame_applied = _apply_capture_ball_frame(ball_key, "")
	var settle_anim = _play_capture_ball_drop_and_bounce(target_pos, active_turn_token)
	if settle_anim is GDScriptFunctionState:
		yield(settle_anim, "completed")
	if active_turn_token != turn_token:
		return null
	return null

func _play_capture_shakes(ball_key: String, enemy, shake_successes: int, capture_success: bool, active_turn_token: int):
	for shake_index in range(CAPTURE_REQUIRED_SHAKES):
		if shake_index >= shake_successes:
			if capture_breakout_open_delay_sec > 0.0:
				yield(get_tree().create_timer(capture_breakout_open_delay_sec), "timeout")
				if active_turn_token != turn_token:
					return null
			_play_capture_sfx("pb_rel.wav")
			if player_pokeball_sprite != null:
				var _break_opening_frame_applied = _apply_capture_ball_frame(ball_key, "_opening")
				_spawn_player_pokeball_open_particles(player_pokeball_sprite.position + Vector2(0, -2))
				yield(get_tree().create_timer(0.06), "timeout")
				if active_turn_token != turn_token:
					return null
				_hide_player_pokeball_sprite()
			var breakout_origin = enemy_sprite_home_position + Vector2(capture_throw_target_offset_x, capture_throw_target_offset_y + capture_ball_settle_offset_y)
			if player_pokeball_sprite != null:
				breakout_origin = player_pokeball_sprite.position
			var breakout_anim = _play_capture_enemy_breakout_animation(breakout_origin, active_turn_token)
			if breakout_anim is GDScriptFunctionState:
				yield(breakout_anim, "completed")
			if active_turn_token != turn_token:
				return null
			set_battle_text("%s broke free!" % String(enemy.species_id))
			return null

		_play_capture_sfx("pb_move.wav")
		var shake_step = _animate_capture_single_shake(active_turn_token)
		if shake_step is GDScriptFunctionState:
			yield(shake_step, "completed")
		if active_turn_token != turn_token:
			return null
		if shake_index < CAPTURE_REQUIRED_SHAKES - 1 and capture_shake_beat_delay_sec > 0.0:
			yield(get_tree().create_timer(capture_shake_beat_delay_sec), "timeout")
			if active_turn_token != turn_token:
				return null

	if capture_success:
		_play_capture_sfx("pb_catch.wav")
		yield(get_tree().create_timer(0.2), "timeout")
		if active_turn_token != turn_token:
			return null
		_play_capture_sfx("pb_lock.wav")

	return null

func _animate_capture_single_shake(active_turn_token: int):
	if player_pokeball_sprite == null:
		return null

	var sprite = player_pokeball_sprite
	var base_pos = sprite.position
	var shake_tween = Tween.new()
	add_child(shake_tween)
	shake_tween.interpolate_property(sprite, "rotation_degrees", 0.0, 16.0, 0.07, Tween.TRANS_SINE, Tween.EASE_OUT)
	shake_tween.interpolate_property(sprite, "rotation_degrees", 16.0, -14.0, 0.11, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.07)
	shake_tween.interpolate_property(sprite, "rotation_degrees", -14.0, 10.0, 0.09, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.18)
	shake_tween.interpolate_property(sprite, "rotation_degrees", 10.0, 0.0, 0.08, Tween.TRANS_SINE, Tween.EASE_IN, 0.27)
	shake_tween.interpolate_property(sprite, "position:x", base_pos.x, base_pos.x + 1.5, 0.07, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	shake_tween.interpolate_property(sprite, "position:x", base_pos.x + 1.5, base_pos.x - 1.5, 0.11, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.07)
	shake_tween.interpolate_property(sprite, "position:x", base_pos.x - 1.5, base_pos.x + 1.0, 0.09, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.18)
	shake_tween.interpolate_property(sprite, "position:x", base_pos.x + 1.0, base_pos.x, 0.08, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.27)
	shake_tween.start()
	yield(shake_tween, "tween_all_completed")
	shake_tween.queue_free()
	if active_turn_token != turn_token:
		return null
	if player_pokeball_sprite != null:
		player_pokeball_sprite.rotation_degrees = 0.0
		player_pokeball_sprite.position = base_pos
	return null

func _play_capture_ball_drop_and_bounce(target_pos: Vector2, active_turn_token: int):
	if player_pokeball_sprite == null:
		return null

	var sprite = player_pokeball_sprite
	sprite.rotation_degrees = 0.0
	sprite.position = target_pos
	if capture_ball_pre_bounce_delay_sec > 0.0:
		yield(get_tree().create_timer(capture_ball_pre_bounce_delay_sec), "timeout")
		if active_turn_token != turn_token:
			return null

	var settle_y = target_pos.y + capture_ball_settle_offset_y
	var bounce_power = 1.0
	var yd = capture_ball_settle_offset_y
	var bounce_duration = max(0.05, capture_ball_bounce_duration_sec)

	while bounce_power > 0.01:
		var down_tween = Tween.new()
		add_child(down_tween)
		down_tween.interpolate_property(sprite, "position:y", sprite.position.y, settle_y, bounce_power * bounce_duration, Tween.TRANS_CUBIC, Tween.EASE_IN)
		down_tween.start()
		yield(down_tween, "tween_all_completed")
		down_tween.queue_free()
		if active_turn_token != turn_token:
			return null

		bounce_power = (bounce_power * 0.5) if bounce_power > 0.01 else 0.0
		if bounce_power <= 0.01:
			break

		var bounce_y = settle_y - (yd * bounce_power)
		var up_tween = Tween.new()
		add_child(up_tween)
		up_tween.interpolate_property(sprite, "position:y", sprite.position.y, bounce_y, bounce_power * bounce_duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		up_tween.start()
		yield(up_tween, "tween_all_completed")
		up_tween.queue_free()
		if active_turn_token != turn_token:
			return null

	sprite.position = Vector2(target_pos.x, settle_y)
	return null

func _handle_capture_success(enemy, active_turn_token: int):
	var enemy_species_id = String(enemy.species_id).strip_edges().to_upper()
	set_battle_text("Gotcha! %s was caught!" % enemy_species_id)
	var fade_anim = _fade_capture_ball_on_success(active_turn_token)
	if fade_anim is GDScriptFunctionState:
		yield(fade_anim, "completed")
	if active_turn_token != turn_token:
		return null

	var add_result = _try_add_captured_enemy_to_party(enemy)
	if add_result.has("ok") and not bool(add_result["ok"]):
		if String(add_result.get("reason", "")) == "full":
			set_battle_text("Gotcha! %s was caught, but party is full." % enemy_species_id)

	yield(get_tree().create_timer(0.45), "timeout")
	if active_turn_token != turn_token:
		return null

	var next_enemy_flow = _spawn_next_enemy_after_capture(enemy_species_id, active_turn_token)
	if next_enemy_flow is GDScriptFunctionState:
		yield(next_enemy_flow, "completed")
	return null

func _handle_capture_failure(enemy) -> void:
	_hide_player_pokeball_sprite()
	if enemy_pokemon_sprite != null:
		restore_battler_sprite_state(enemy_pokemon_sprite, enemy_sprite_home_position)
	set_battle_text("%s escaped!" % String(enemy.species_id))

func _play_capture_enemy_absorb_animation(ball_target_pos: Vector2, active_turn_token: int):
	if enemy_pokemon_sprite == null:
		return null

	enemy_pokemon_sprite.visible = true
	enemy_pokemon_sprite.modulate = Color(1, 1, 1, 1)
	var start_scale = enemy_pokemon_sprite.scale
	var target_scale = start_scale * max(0.05, capture_enemy_absorb_scale_mul)
	var absorb_tween = Tween.new()
	add_child(absorb_tween)
	absorb_tween.interpolate_property(
		enemy_pokemon_sprite,
		"position",
		enemy_pokemon_sprite.position,
		ball_target_pos,
		max(0.01, capture_enemy_absorb_duration_sec),
		Tween.TRANS_SINE,
		Tween.EASE_IN
	)
	absorb_tween.interpolate_property(
		enemy_pokemon_sprite,
		"scale",
		start_scale,
		target_scale,
		max(0.01, capture_enemy_absorb_duration_sec),
		Tween.TRANS_SINE,
		Tween.EASE_IN
	)
	absorb_tween.interpolate_property(
		enemy_pokemon_sprite,
		"modulate:a",
		1.0,
		0.0,
		max(0.01, capture_enemy_absorb_duration_sec),
		Tween.TRANS_SINE,
		Tween.EASE_IN
	)
	absorb_tween.start()
	yield(absorb_tween, "tween_all_completed")
	absorb_tween.queue_free()
	if active_turn_token != turn_token:
		return null
	enemy_pokemon_sprite.visible = false
	return null

func _play_capture_enemy_breakout_animation(ball_origin_pos: Vector2, active_turn_token: int):
	if enemy_pokemon_sprite == null:
		return null

	enemy_pokemon_sprite.visible = true
	var home_scale = enemy_sprite_home_scale
	var start_scale = home_scale * max(0.05, capture_enemy_absorb_scale_mul)
	enemy_pokemon_sprite.position = ball_origin_pos
	enemy_pokemon_sprite.scale = start_scale
	enemy_pokemon_sprite.modulate = Color(1, 1, 1, 0)
	var breakout_tween = Tween.new()
	add_child(breakout_tween)
	breakout_tween.interpolate_property(
		enemy_pokemon_sprite,
		"position",
		ball_origin_pos,
		enemy_sprite_home_position,
		max(0.01, capture_enemy_breakout_duration_sec),
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	)
	breakout_tween.interpolate_property(
		enemy_pokemon_sprite,
		"scale",
		start_scale,
		home_scale,
		max(0.01, capture_enemy_breakout_duration_sec),
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	)
	breakout_tween.interpolate_property(
		enemy_pokemon_sprite,
		"modulate:a",
		0.0,
		1.0,
		max(0.01, capture_enemy_breakout_duration_sec),
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	)
	breakout_tween.start()
	yield(breakout_tween, "tween_all_completed")
	breakout_tween.queue_free()
	if active_turn_token != turn_token:
		return null
	restore_battler_sprite_state(enemy_pokemon_sprite, enemy_sprite_home_position)
	return null

func _fade_capture_ball_on_success(active_turn_token: int):
	if player_pokeball_sprite == null or not player_pokeball_sprite.visible:
		return null

	player_pokeball_sprite.modulate.a = 1.0
	var fade_tween = Tween.new()
	add_child(fade_tween)
	fade_tween.interpolate_property(
		player_pokeball_sprite,
		"modulate:a",
		1.0,
		0.0,
		max(0.01, capture_ball_success_fade_duration_sec),
		Tween.TRANS_SINE,
		Tween.EASE_IN
	)
	fade_tween.start()
	yield(fade_tween, "tween_all_completed")
	fade_tween.queue_free()
	if active_turn_token != turn_token:
		return null
	_hide_player_pokeball_sprite()
	player_pokeball_sprite.modulate.a = 1.0
	return null

func _roll_capture_shakes(ball_key: String, enemy) -> int:
	if _ball_has_guaranteed_catch(ball_key):
		return CAPTURE_REQUIRED_SHAKES

	var max_hp = max(1, int(enemy.get_base_stat("hp")))
	var hp_ratio = clamp(float(enemy.current_hp) / float(max_hp), 0.0, 1.0)
	var hp_factor = 1.0 - hp_ratio

	var catch_rate = _get_enemy_catch_rate(String(enemy.species_id))
	var catch_bonus = _get_ball_catch_bonus(ball_key)
	var shake_chance = (float(catch_rate) / 255.0) * (0.35 + 0.65 * hp_factor) * catch_bonus
	shake_chance = clamp(shake_chance, 0.05, 0.95)

	var successes = 0
	for _i in range(CAPTURE_REQUIRED_SHAKES):
		if randf() <= shake_chance:
			successes += 1
		else:
			break
	return successes

func _get_enemy_catch_rate(species_id: String) -> int:
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()
	if catalog_loader != null and catalog_loader.load_catalogs():
		var species_entry = catalog_loader.get_species(species_id)
		if not species_entry.empty():
			return int(max(1, int(species_entry.get("catch_rate", 45))))
	return 45

func _spawn_next_enemy_after_capture(captured_species_id: String, active_turn_token: int):
	var next_enemy_species_id = pick_random_enemy_species_id(captured_species_id)
	var next_enemy = null
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()
	if catalog_loader != null and catalog_loader.load_catalogs():
		next_enemy = catalog_loader.build_pokemon_data(next_enemy_species_id, 5)

	if next_enemy == null:
		end_battle(true, captured_species_id)
		return null

	var enemy_slide_out = animate_enemy_layer_to(
		enemy_layer_home_position + Vector2(enemy_switch_slide_distance_px, 0),
		enemy_switch_slide_duration_sec,
		active_turn_token
	)
	if enemy_slide_out is GDScriptFunctionState:
		yield(enemy_slide_out, "completed")
		if active_turn_token != -1 and active_turn_token != turn_token:
			return null

	var next_biome_state = _advance_runtime_biome_state("capture_resolved")
	battle_data["enemy"] = next_enemy
	_apply_biome_state_to_battle_data(next_biome_state)
	enemy_layer.rect_position = enemy_layer_home_position + Vector2(-enemy_switch_slide_distance_px, 0)
	load_battle_sprites()
	bind_battle_data()
	player_sprite_anim_enabled = true
	enemy_sprite_anim_enabled = true
	restore_battler_sprite_state(player_pokemon_sprite, player_sprite_home_position)
	restore_battler_sprite_state(enemy_pokemon_sprite, enemy_sprite_home_position)
	reset_pokemon_animation_state()
	var enemy_slide_in = animate_enemy_layer_to(enemy_layer_home_position, enemy_switch_slide_duration_sec, active_turn_token)
	if enemy_slide_in is GDScriptFunctionState:
		yield(enemy_slide_in, "completed")
		if active_turn_token != -1 and active_turn_token != turn_token:
			return null

	set_battle_text("A wild %s appeared!" % String(next_enemy.species_id))
	_play_enemy_sendout_cry_once()
	return null

func _try_add_captured_enemy_to_party(enemy) -> Dictionary:
	if runtime_state_script == null:
		return {"ok": false, "reason": "runtime_missing"}

	var party = runtime_state_script.get_party(get_tree())
	if party == null:
		return {"ok": false, "reason": "party_missing"}

	var move_ids := []
	var enemy_moves = enemy.moves if enemy != null else []
	if typeof(enemy_moves) == TYPE_ARRAY:
		for move in enemy_moves:
			if move == null:
				continue
			var move_id = String(move.move_id).strip_edges().to_upper()
			if move_id.empty() or move_ids.has(move_id):
				continue
			move_ids.append(move_id)

	return party.add_member({
		"species_id": String(enemy.species_id).strip_edges().to_upper(),
		"level": max(1, int(enemy.level)),
		"current_hp": max(1, int(enemy.current_hp)),
		"move_ids": move_ids,
	})

func _get_ball_label(ball_key: String) -> String:
	if BALL_DEFS.has(ball_key):
		return String(BALL_DEFS[ball_key].get("label", "Ball"))
	return "Ball"

func _get_ball_frame_prefix(ball_key: String) -> String:
	if BALL_DEFS.has(ball_key):
		return String(BALL_DEFS[ball_key].get("frame_prefix", "pb"))
	return "pb"

func _get_ball_catch_bonus(ball_key: String) -> float:
	if BALL_DEFS.has(ball_key):
		return max(0.1, float(BALL_DEFS[ball_key].get("catch_bonus", 1.0)))
	return 1.0

func _ball_has_guaranteed_catch(ball_key: String) -> bool:
	if not BALL_DEFS.has(ball_key):
		return false
	return bool(BALL_DEFS[ball_key].get("guaranteed", false))

func _apply_capture_ball_frame(ball_key: String, suffix: String) -> bool:
	var frame_name = _get_ball_frame_prefix(ball_key) + suffix
	return _apply_pokeball_frame(frame_name)

func _play_capture_sfx(file_name: String) -> void:
	if not battle_fx_enabled:
		return
	var sfx_path = resolve_audio_asset_path("assets/audio/se/" + file_name)
	if sfx_path.empty():
		return
	$UIAudioStreamPlayer.stream = load(sfx_path)
	$UIAudioStreamPlayer.play()

# Turn state and battle transitions.
func _show_main_controls_unlocked() -> void:
	show_main_controls()
	set_action_lock(false)

func _show_main_controls_locked() -> void:
	show_main_controls()
	set_action_lock(true)

func _enter_action_locked_state() -> void:
	hide_all_command_menus()
	set_action_lock(true)

func set_action_lock(locked: bool):
	move_button.disabled = locked
	pokemon_button.disabled = locked
	run_button.disabled = locked
	ball_button.disabled = locked and battle_ended == false
	set_attack_menu_enabled(not locked)
	if not locked and not battle_ended:
		ensure_button_focus()

func _finish_turn():
	turn_in_progress = false
	if not battle_ended:
		_show_main_controls_unlocked()

func end_battle(player_won: bool, fainted_species_id: String):
	battle_ended = true
	if player_won:
		_show_main_controls_locked()
		ball_button.disabled = false
		ball_button.grab_focus()
		set_battle_text("%s fainted! You win! Press Ball to restart." % fainted_species_id)
		return

	# Defeat recovery path: return to starter selection.
	_enter_action_locked_state()
	set_battle_text("%s fainted! You lose! Returning to selection..." % fainted_species_id)
	var timer = get_tree().create_timer(max(0.0, defeat_return_delay_sec))
	_connect_once(timer, "timeout", "_return_to_selection_scene")

func _return_to_selection_scene():
	var tree = get_tree()
	if tree == null:
		return

	var result = tree.change_scene(SELECTION_SCENE_PATH)
	if result != OK:
		set_battle_text("Failed to open selection scene.")
		show_main_controls()
		ball_button.disabled = false
		ball_button.grab_focus()

func reset_battle_state(message: String):
	turn_token += 1
	capture_in_progress = false
	sendout_controls_locked = false
	_close_party_menu_internal()
	hide_ball_menu(false)
	ball_inventory = BALL_DEFAULT_COUNTS.duplicate(true)
	refresh_ball_menu_labels()
	var handoff_species_id = consume_selected_species_id()
	if not handoff_species_id.empty():
		selected_player_species_id = handoff_species_id

	var active_party_member := {}
	if runtime_state_script != null:
		var party = runtime_state_script.get_party(get_tree())
		if party != null and not handoff_species_id.empty() and party.is_empty():
			party.add_member({
				"species_id": handoff_species_id,
				"level": 5,
				"current_hp": -1,
				"move_ids": [],
			})
			party.set_active_slot(0)
		if party != null:
			active_party_member = party.get_active_member()

	if active_party_member.empty() and not selected_player_species_id.empty():
		active_party_member = {
			"species_id": selected_player_species_id,
			"level": 5,
			"current_hp": -1,
			"move_ids": [],
		}

	var active_player_species_id = String(active_party_member.get("species_id", selected_player_species_id)).strip_edges().to_upper()
	if active_player_species_id.empty():
		active_player_species_id = "BLASTOISE"
	selected_player_species_id = active_player_species_id

	var initial_biome_state = _ensure_runtime_biome_state()
	var next_enemy_species_id = pick_random_enemy_species_id("")
	battle_data = build_battle_seed(active_player_species_id, next_enemy_species_id, active_party_member)
	_apply_biome_state_to_battle_data(initial_biome_state)
	enemy_layer.rect_position = enemy_layer_home_position
	load_battle_sprites()
	battle_ended = false
	turn_in_progress = false
	hide_attack_menu()
	refresh_attack_menu()
	player_sprite_anim_enabled = true
	enemy_sprite_anim_enabled = true
	set_sendout_controls_locked(true)
	ball_button.disabled = false
	update_run_button_label()
	bind_battle_data()
	restore_battler_sprite_state(player_pokemon_sprite, player_sprite_home_position)
	restore_battler_sprite_state(enemy_pokemon_sprite, enemy_sprite_home_position)
	reset_pokemon_animation_state()
	start_player_trainer_summon_choreography()
	ensure_button_focus()
	set_battle_text(message)
	_play_enemy_sendout_cry_once()

func set_sendout_controls_locked(locked: bool) -> void:
	sendout_controls_locked = locked
	if battle_ended:
		set_action_lock(true)
		return
	set_action_lock(locked)

func _on_player_sendout_settled() -> void:
	if not sendout_controls_locked:
		return
	set_sendout_controls_locked(false)

func build_battle_seed(player_species_id: String, enemy_species_id: String, player_party_member: Dictionary = {}) -> Dictionary:
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()

	if catalog_loader != null and catalog_loader.load_catalogs():
		if typeof(player_party_member) == TYPE_DICTIONARY and not player_party_member.empty():
			var player_level = max(1, int(player_party_member.get("level", 5)))
			var player_move_ids = player_party_member.get("move_ids", [])
			if typeof(player_move_ids) != TYPE_ARRAY:
				player_move_ids = []

			var player_data = catalog_loader.build_pokemon_data(player_species_id, player_level, player_move_ids)
			var enemy_data = catalog_loader.build_pokemon_data(enemy_species_id, 5)
			return {
				"player": player_data,
				"enemy": enemy_data,
			}

		return catalog_loader.build_battle_seed(player_species_id, enemy_species_id)

	return pokemon_data_script.create_battle_02_test_data(player_species_id)

func _ensure_runtime_biome_state() -> Dictionary:
	if runtime_state_script == null:
		return {
			"current_biome_id": "grass",
			"previous_biome_id": "",
			"transition_trigger": "battle_start",
			"encounter_index": 0,
			"seed": 0,
			"source": "baseline_rotation",
		}
	return runtime_state_script.ensure_biome_state(get_tree())

func _advance_runtime_biome_state(transition_trigger: String) -> Dictionary:
	if runtime_state_script == null:
		var fallback_biome_state = _ensure_runtime_biome_state()
		fallback_biome_state["transition_trigger"] = transition_trigger.strip_edges().to_lower().replace(" ", "_")
		fallback_biome_state["encounter_index"] = int(fallback_biome_state.get("encounter_index", 0)) + 1
		return fallback_biome_state
	var current_state = runtime_state_script.get_biome_state(get_tree())
	var current_biome_id = String(current_state.get("current_biome_id", "grass"))
	var next_test_arena_id = _pick_next_test_arena_id(current_biome_id)
	return runtime_state_script.advance_biome_for_level(
		get_tree(),
		transition_trigger,
		biome_switch_every_levels,
		next_test_arena_id
	)

func _apply_biome_state_to_battle_data(biome_state: Dictionary) -> void:
	if typeof(battle_data) != TYPE_DICTIONARY:
		return
	battle_data["biome_state"] = biome_state.duplicate(true)

func get_enemy_species_pool() -> Array:
	if not enemy_species_pool.empty():
		return enemy_species_pool.duplicate()

	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()

	if catalog_loader == null or not catalog_loader.load_catalogs():
		return []

	enemy_species_pool = catalog_loader.get_all_species_ids()
	return enemy_species_pool.duplicate()

func pick_random_enemy_species_id(current_enemy_species_id: String) -> String:
	var pool = get_enemy_species_pool()
	if pool.empty():
		return "CHARMANDER"

	var normalized_current = current_enemy_species_id.strip_edges().to_upper()
	var normalized_player = selected_player_species_id.strip_edges().to_upper()
	var candidates := []
	for species_id in pool:
		var normalized_species_id = String(species_id).strip_edges().to_upper()
		if normalized_species_id.empty():
			continue
		if normalized_species_id == normalized_current:
			continue
		if normalized_species_id == normalized_player and pool.size() > 1:
			continue
		candidates.append(normalized_species_id)

	if candidates.empty():
		candidates = pool.duplicate()

	return String(candidates[randi() % candidates.size()])

func advance_to_next_enemy(fainted_species_id: String, active_turn_token: int = -1):
	if battle_data == null or not battle_data.has("player") or battle_data["player"] == null:
		end_battle(true, fainted_species_id)
		return

	set_battle_text("%s fainted!" % fainted_species_id)
	if enemy_switch_delay_sec > 0.0:
		yield(get_tree().create_timer(enemy_switch_delay_sec), "timeout")
		if active_turn_token != -1 and active_turn_token != turn_token:
			return

	var enemy_slide_out = animate_enemy_layer_to(
		enemy_layer_home_position + Vector2(enemy_switch_slide_distance_px, 0),
		enemy_switch_slide_duration_sec,
		active_turn_token
	)
	if enemy_slide_out is GDScriptFunctionState:
		yield(enemy_slide_out, "completed")
		if active_turn_token != -1 and active_turn_token != turn_token:
			return

	var next_enemy_species_id = pick_random_enemy_species_id(fainted_species_id)
	var next_enemy = null
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()
	if catalog_loader != null and catalog_loader.load_catalogs():
		next_enemy = catalog_loader.build_pokemon_data(next_enemy_species_id, 5)

	if next_enemy == null:
		enemy_layer.rect_position = enemy_layer_home_position
		end_battle(true, fainted_species_id)
		return

	var next_biome_state = _advance_runtime_biome_state("enemy_defeated")
	battle_data["enemy"] = next_enemy
	_apply_biome_state_to_battle_data(next_biome_state)
	enemy_layer.rect_position = enemy_layer_home_position + Vector2(-enemy_switch_slide_distance_px, 0)
	load_battle_sprites()
	bind_battle_data()
	player_sprite_anim_enabled = true
	enemy_sprite_anim_enabled = true
	restore_battler_sprite_state(player_pokemon_sprite, player_sprite_home_position)
	restore_battler_sprite_state(enemy_pokemon_sprite, enemy_sprite_home_position)
	reset_pokemon_animation_state()
	var enemy_slide_in = animate_enemy_layer_to(enemy_layer_home_position, enemy_switch_slide_duration_sec, active_turn_token)
	if enemy_slide_in is GDScriptFunctionState:
		yield(enemy_slide_in, "completed")
		if active_turn_token != -1 and active_turn_token != turn_token:
			return
	show_main_controls()
	set_battle_text("%s fainted! %s appeared!" % [fainted_species_id, next_enemy.species_id])
	_play_enemy_sendout_cry_once()

func animate_enemy_layer_to(target_position: Vector2, duration_sec: float, active_turn_token: int = -1):
	if enemy_layer == null:
		return null

	if duration_sec <= 0.0:
		enemy_layer.rect_position = target_position
		return null

	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(
		enemy_layer,
		"rect_position",
		enemy_layer.rect_position,
		target_position,
		duration_sec,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	tween.start()
	yield(tween, "tween_all_completed")
	tween.queue_free()

	if active_turn_token != -1 and active_turn_token != turn_token:
		return null

	enemy_layer.rect_position = target_position
	return null

func consume_selected_species_id() -> String:
	var tree = get_tree()
	if tree == null or not tree.has_meta(SELECTED_SPECIES_META_KEY):
		return ""

	var raw_species_id = String(tree.get_meta(SELECTED_SPECIES_META_KEY, "")).strip_edges().to_upper()
	tree.remove_meta(SELECTED_SPECIES_META_KEY)
	return raw_species_id

# Navigation and focus handling.
func setup_keyboard_controls():
	ensure_input_action_key("ui_left", KEY_LEFT)
	ensure_input_action_key("ui_right", KEY_RIGHT)
	ensure_input_action_key("ui_up", KEY_UP)
	ensure_input_action_key("ui_down", KEY_DOWN)
	ensure_input_action_key("ui_accept", KEY_SPACE)
	ensure_input_action_key("ui_back", KEY_BACKSPACE)

	move_button.focus_mode = Control.FOCUS_ALL
	ball_button.focus_mode = Control.FOCUS_ALL
	pokemon_button.focus_mode = Control.FOCUS_ALL
	run_button.focus_mode = Control.FOCUS_ALL
	attack_move_button_1.focus_mode = Control.FOCUS_ALL
	attack_move_button_2.focus_mode = Control.FOCUS_ALL
	attack_move_button_3.focus_mode = Control.FOCUS_ALL
	attack_move_button_4.focus_mode = Control.FOCUS_ALL
	for button in _get_ball_menu_buttons():
		if button != null:
			button.focus_mode = Control.FOCUS_ALL

func ensure_input_action_key(action_name: String, key_code: int):
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	for ev in InputMap.get_action_list(action_name):
		if ev is InputEventKey and ev.scancode == key_code:
			return

	var new_event = InputEventKey.new()
	new_event.scancode = key_code
	InputMap.action_add_event(action_name, new_event)

func ensure_button_focus():
	if party_menu_visible and party_menu_overlay != null:
		var party_focus_owner = get_focus_owner()
		if party_menu_overlay.is_overlay_focus_owner(party_focus_owner):
			return
		party_menu_overlay.focus_default()
		return

	if ball_menu_visible:
		var ball_focus_owner = get_focus_owner()
		if is_ball_menu_button(ball_focus_owner):
			return
		focus_first_ball_menu_button()
		return

	if attack_menu_visible:
		var attack_focus_owner = get_focus_owner()
		if is_attack_menu_button(attack_focus_owner):
			return
		focus_first_attack_move_button()
		return

	var focus_owner = get_focus_owner()
	if focus_owner == move_button or focus_owner == ball_button or focus_owner == pokemon_button or focus_owner == run_button:
		return
	if battle_ended:
		ball_button.grab_focus()
	else:
		move_button.grab_focus()

func move_button_focus(action_name: String):
	if party_menu_visible and party_menu_overlay != null:
		party_menu_overlay.move_focus(action_name)
		return
	if ball_menu_visible:
		move_ball_menu_focus(action_name, get_focus_owner())
		return

	ensure_button_focus()
	var focus_owner = get_focus_owner()
	if focus_owner == null:
		return

	if attack_menu_visible:
		move_attack_menu_focus(action_name, focus_owner)
		return

	_move_focus_in_2x2_grid(action_name, focus_owner, [move_button, ball_button, pokemon_button, run_button])

func _move_focus_in_2x2_grid(action_name: String, focus_owner, ordered_buttons: Array) -> void:
	if focus_owner == null or ordered_buttons.size() != 4:
		return

	var current_index = ordered_buttons.find(focus_owner)
	if current_index == -1:
		return

	var d_row = 0
	var d_col = 0
	match action_name:
		"ui_left":
			d_col = -1
		"ui_right":
			d_col = 1
		"ui_up":
			d_row = -1
		"ui_down":
			d_row = 1
		_:
			return

	var row = int(current_index / 2)
	var col = current_index % 2
	var next_row = row + d_row
	var next_col = col + d_col
	if next_row < 0 or next_row > 1 or next_col < 0 or next_col > 1:
		return

	var next_button = ordered_buttons[next_row * 2 + next_col]
	if next_button == null:
		return

	next_button.grab_focus()
	return

func move_attack_menu_focus(action_name: String, focus_owner):
	_move_focus_in_2x2_grid(action_name, focus_owner, _get_attack_move_buttons())

func is_ball_menu_button(focus_owner) -> bool:
	for button in _get_ball_menu_buttons():
		if focus_owner == button:
			return true
	return false

func focus_first_ball_menu_button() -> void:
	for button in _get_ball_menu_buttons():
		if button == null:
			continue
		if button == ball_cancel_button or not button.disabled:
			button.grab_focus()
			return

func move_ball_menu_focus(action_name: String, focus_owner):
	if focus_owner == null or not is_ball_menu_button(focus_owner):
		focus_first_ball_menu_button()
		return

	var focus_order = _get_ball_menu_buttons()
	var enabled_order := []
	for button in focus_order:
		if button == null:
			continue
		if button == ball_cancel_button or not button.disabled:
			enabled_order.append(button)
	if enabled_order.empty():
		return

	var current_index = enabled_order.find(focus_owner)
	if current_index == -1:
		focus_first_ball_menu_button()
		return

	if action_name == "ui_up" or action_name == "ui_left":
		enabled_order[(current_index - 1 + enabled_order.size()) % enabled_order.size()].grab_focus()
		return

	if action_name == "ui_down" or action_name == "ui_right":
		enabled_order[(current_index + 1) % enabled_order.size()].grab_focus()
		return

func press_focused_button():
	if party_menu_visible and party_menu_overlay != null:
		party_menu_overlay.press_focused()
		return

	ensure_button_focus()
	var focus_owner = get_focus_owner()
	if focus_owner == null:
		return
	if focus_owner is Button and not focus_owner.disabled:
		focus_owner.emit_signal("pressed")

func update_run_button_label():
	if run_button == null:
		return

	# Keep this short so the fixed two-column controls window does not resize at runtime.
	run_button.text = "FX ON" if battle_fx_enabled else "FX OFF"

# Command menu visibility and panel layout.
func show_attack_menu():
	refresh_attack_menu()
	_set_command_menu_visibility(false, true, false)
	refresh_attack_move_details(0)
	focus_first_attack_move_button()

func hide_attack_menu():
	show_main_controls()

func show_main_controls():
	_set_command_menu_visibility(true, false, false)
	set_main_command_prompt()

func hide_all_command_menus():
	_set_command_menu_visibility(false, false, false)
	_close_party_menu_internal()

func _set_command_menu_visibility(show_controls: bool, show_attack: bool, show_ball: bool) -> void:
	attack_menu_visible = show_attack
	ball_menu_visible = show_ball
	if attack_menu_container != null:
		attack_menu_container.visible = show_attack
	if ball_menu_container != null:
		ball_menu_container.visible = show_ball
	if controls_container != null:
		controls_container.visible = show_controls

func show_ball_menu() -> void:
	if ball_menu_container == null:
		set_battle_text("Ball menu is missing.")
		return

	hide_all_command_menus()
	refresh_ball_menu_labels()
	refresh_ball_menu_layout()
	_set_command_menu_visibility(false, false, true)
	focus_first_ball_menu_button()
	set_battle_text("Choose a Ball.")

func hide_ball_menu(show_controls: bool) -> void:
	_set_command_menu_visibility(show_controls, false, false)
	if show_controls and not battle_ended and not turn_in_progress and not capture_in_progress:
		_show_main_controls_unlocked()
	ensure_button_focus()

func refresh_ball_menu_labels() -> void:
	if ball_pokeball_button == null or ball_greatball_button == null or ball_masterball_button == null or ball_cancel_button == null:
		return

	for ball_entry in _get_ball_action_entries():
		var button = ball_entry["button"]
		var key = ball_entry["key"]
		var label = ball_entry["label"]
		var count = int(ball_inventory.get(key, 0))
		button.text = "%d x %s" % [max(0, count), label]
		button.disabled = count <= 0
	ball_cancel_button.disabled = false
	refresh_ball_menu_layout()

func refresh_ball_menu_layout() -> void:
	if ball_menu_container == null or ball_window_sprite == null or ball_content_margin == null or ball_button_list == null:
		return

	var list_min_size = ball_button_list.get_combined_minimum_size()
	var margin_padding_y = ball_content_margin.margin_top - ball_content_margin.margin_bottom
	var window_min_height = max(1.0, list_min_size.y + margin_padding_y)
	var window_min_width = max(1.0, ball_window_sprite.rect_min_size.x)
	ball_window_sprite.rect_min_size = Vector2(window_min_width, window_min_height)
	ball_window_sprite.rect_size = Vector2(window_min_width, window_min_height)

	# Keep the menu bottom anchored and expand upward as options are added.
	# BallWindowSprite sits with 2px inset on top and bottom inside BallMenuContainer.
	var container_height = window_min_height + 4.0
	ball_menu_container.margin_top = ball_menu_container.margin_bottom - container_height

func open_party_menu():
	if party_menu_overlay == null:
		set_battle_text("Party menu scene is missing.")
		return

	sync_active_party_member_from_battle()

	var members := []
	var active_index := -1
	if runtime_state_script != null:
		var party = runtime_state_script.get_party(get_tree())
		if party != null:
			members = party.get_members_copy()
			active_index = party.get_active_slot_index()

	hide_all_command_menus()
	party_menu_overlay.open_menu(members, active_index)
	party_menu_visible = true
	set_battle_text("Party menu open.")

func sync_active_party_member_from_battle() -> void:
	if runtime_state_script == null:
		return
	if battle_data == null or not battle_data.has("player"):
		return

	var player_data = battle_data["player"]
	if player_data == null:
		return

	var party = runtime_state_script.get_party(get_tree())
	if party == null:
		return

	var active_index = party.get_active_slot_index()
	if active_index < 0:
		return

	var move_ids := []
	var moves = []
	if typeof(player_data) == TYPE_DICTIONARY:
		moves = player_data.get("moves", [])
	elif player_data.has_method("get"):
		moves = player_data.get("moves")

	if typeof(moves) == TYPE_ARRAY:
		for move in moves:
			if move == null:
				continue
			var move_id = String(move.move_id).strip_edges().to_upper()
			if move_id.empty() or move_ids.has(move_id):
				continue
			move_ids.append(move_id)

	var next_level = int(player_data.level)
	var next_current_hp = int(player_data.current_hp)
	var existing_member = party.get_member_at(active_index)
	if not existing_member.empty():
		var existing_level = int(existing_member.get("level", -1))
		var existing_current_hp = int(existing_member.get("current_hp", -1))
		var existing_move_ids = existing_member.get("move_ids", [])
		if typeof(existing_move_ids) == TYPE_ARRAY \
				and existing_level == next_level \
				and existing_current_hp == next_current_hp \
				and existing_move_ids == move_ids:
			return

	party.update_member_at(active_index, {
		"level": next_level,
		"current_hp": next_current_hp,
		"move_ids": move_ids,
	})

func _build_player_data_from_party_member(member: Dictionary):
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()

	if catalog_loader == null or not catalog_loader.load_catalogs():
		return null

	var species_id = String(member.get("species_id", "")).strip_edges().to_upper()
	if species_id.empty():
		return null

	var level = max(1, int(member.get("level", 5)))
	var move_ids = member.get("move_ids", [])
	if typeof(move_ids) != TYPE_ARRAY:
		move_ids = []

	var player_data = catalog_loader.build_pokemon_data(species_id, level, move_ids)
	if player_data == null:
		return null

	var saved_hp = int(member.get("current_hp", -1))
	if saved_hp >= 0:
		var max_hp = max(1, int(player_data.get_base_stat("hp")))
		player_data.current_hp = int(clamp(saved_hp, 0, max_hp))

	return player_data

func _run_enemy_action_after_player_switch(player_data, active_turn_token: int):
	if battle_data == null or not battle_data.has("enemy"):
		return null

	var enemy = battle_data["enemy"]
	if enemy == null or enemy.moves.empty():
		return null

	var enemy_move = enemy.moves[0]
	var enemy_move_anim = play_move_animation(enemy_move.move_id, enemy_pokemon_sprite, player_pokemon_sprite, active_turn_token)
	if enemy_move_anim is GDScriptFunctionState:
		yield(enemy_move_anim, "completed")
		if active_turn_token != turn_token:
			return null

	var enemy_damage = int(battle_calc_script.calc_damage(enemy, enemy_move, player_data))
	player_data.current_hp = max(0, player_data.current_hp - enemy_damage)
	var enemy_type_multiplier = battle_calc_script.get_type_multiplier(enemy_move.move_type, player_data)
	refresh_hp_ui(player_data, player_hp_bar, player_hp_value_label)
	sync_active_party_member_from_battle()

	var enemy_hit_feedback = play_hit_feedback(player_pokemon_sprite, active_turn_token)
	if enemy_hit_feedback is GDScriptFunctionState:
		yield(enemy_hit_feedback, "completed")
		if active_turn_token != turn_token:
			return null

	var enemy_message = "%s used %s! %d damage." % [enemy.species_id, enemy_move.move_id, enemy_damage]
	enemy_message += build_type_effectiveness_text(enemy_type_multiplier)
	set_battle_text(enemy_message)
	if turn_step_delay_sec > 0.0:
		yield(get_tree().create_timer(turn_step_delay_sec), "timeout")
		if active_turn_token != turn_token:
			return null

	if player_data.is_fainted():
		var player_faint_anim = play_faint_animation(player_pokemon_sprite, true, active_turn_token)
		if player_faint_anim is GDScriptFunctionState:
			yield(player_faint_anim, "completed")
			if active_turn_token != turn_token:
				return null
		end_battle(false, player_data.species_id)

	return null

func close_party_menu():
	if not party_menu_visible:
		return

	_close_party_menu_internal()
	if not battle_ended and not turn_in_progress:
		_show_main_controls_unlocked()
	ensure_button_focus()

func _close_party_menu_internal():
	party_menu_visible = false
	if party_menu_overlay != null:
		party_menu_overlay.close_menu()

func _on_PartyMenu_close_requested():
	close_party_menu()

func _on_PartyMenu_switch_slot_requested(slot_index: int) -> void:
	if battle_ended:
		set_battle_text("Battle has ended. Press Ball to restart.")
		return
	if turn_in_progress or capture_in_progress:
		return
	if runtime_state_script == null:
		set_battle_text("Switch unavailable: runtime missing.")
		return

	var party = runtime_state_script.get_party(get_tree())
	if party == null:
		set_battle_text("Switch unavailable: party state missing.")
		return

	var members = party.get_members_copy()
	if slot_index < 0 or slot_index >= members.size():
		set_battle_text("Invalid switch target.")
		return

	var member = members[slot_index]
	if typeof(member) != TYPE_DICTIONARY or member.empty():
		set_battle_text("Invalid switch target.")
		return

	var active_index = party.get_active_slot_index()
	if slot_index == active_index:
		set_battle_text("That Pokemon is already active.")
		return

	var current_hp = int(member.get("current_hp", 0))
	if current_hp <= 0:
		set_battle_text("That Pokemon cannot battle.")
		return

	var species_label = String(member.get("species_id", "POKEMON")).strip_edges().to_upper()
	if species_label.empty():
		species_label = "POKEMON"

	turn_in_progress = true
	_enter_action_locked_state()
	var active_turn_token = turn_token

	sync_active_party_member_from_battle()
	var incoming_player_data = _build_player_data_from_party_member(member)
	if incoming_player_data == null:
		set_battle_text("Switch failed: could not load %s." % species_label)
		_finish_turn()
		return

	var set_active_result = party.set_active_slot(slot_index)
	if not bool(set_active_result.get("ok", false)):
		set_battle_text("Switch failed: invalid party slot.")
		_finish_turn()
		return

	battle_data["player"] = incoming_player_data
	_close_party_menu_internal()
	load_battle_sprites()
	bind_battle_data()
	player_sprite_anim_enabled = true
	enemy_sprite_anim_enabled = true
	restore_battler_sprite_state(player_pokemon_sprite, player_sprite_home_position)
	restore_battler_sprite_state(enemy_pokemon_sprite, enemy_sprite_home_position)
	reset_pokemon_animation_state()
	set_battle_text("Go! %s!" % species_label)

	if turn_step_delay_sec > 0.0:
		yield(get_tree().create_timer(turn_step_delay_sec), "timeout")
		if active_turn_token != turn_token:
			return

	var enemy_action = _run_enemy_action_after_player_switch(incoming_player_data, active_turn_token)
	if enemy_action is GDScriptFunctionState:
		yield(enemy_action, "completed")
		if active_turn_token != turn_token:
			return

	if not battle_ended:
		set_main_command_prompt()
	_finish_turn()

func set_main_command_prompt():
	if battle_data == null or not battle_data.has("player") or battle_data["player"] == null:
		set_battle_text("What will Pokemon do?")
		return

	var player_species = String(battle_data["player"].species_id)
	set_battle_text("What will %s do?" % player_species)

# Attack menu and detail presentation.
func refresh_attack_menu():
	var attacker = battle_data["player"] if battle_data != null and battle_data.has("player") else null
	var moves = []
	if attacker != null:
		moves = attacker.moves

	var move_buttons = _get_attack_move_buttons()

	for i in range(move_buttons.size()):
		var button = move_buttons[i]
		if button == null:
			continue
		if i < moves.size():
			var move = moves[i]
			button.disabled = false
			button.text = String(move.move_id)
		else:
			button.disabled = true
			button.text = "-"

	refresh_attack_move_details(0)

func set_attack_menu_enabled(enabled: bool):
	for button in _get_attack_move_buttons():
		if button == null:
			continue
		button.disabled = (not enabled) or button.text == "-"

func refresh_attack_move_details(move_slot: int):
	var attacker = battle_data["player"] if battle_data != null and battle_data.has("player") else null
	if attacker == null or move_slot < 0 or move_slot >= attacker.moves.size():
		attack_type_sprite.visible = false
		attack_power_label.text = "Power: -"
		attack_category_sprite.visible = false
		attack_pp_label.text = "PP: -/-"
		return

	var move = attacker.moves[move_slot]
	apply_attack_detail_badge(
		attack_type_sprite,
		ATTACK_TYPE_TEXTURE_REL,
		ATTACK_TYPE_ATLAS_REL,
		[String(move.move_type).strip_edges().to_lower(), "unknown"]
	)
	attack_power_label.text = "Power: %d" % int(move.power)
	apply_attack_detail_badge(
		attack_category_sprite,
		ATTACK_CATEGORY_TEXTURE_REL,
		ATTACK_CATEGORY_ATLAS_REL,
		[
			String(move.category).strip_edges().to_lower(),
			String(move.category).strip_edges(),
			String(move.category).strip_edges().to_upper(),
		]
	)
	attack_pp_label.text = "PP: %s" % build_move_pp_text(move)

func apply_attack_detail_badge(sprite_node: Sprite, texture_rel: String, atlas_rel: String, frame_candidates: Array):
	if sprite_node == null:
		return

	var texture_path = minimal_assets_path + texture_rel
	var atlas_path = minimal_assets_path + atlas_rel
	if not resource_exists(texture_path):
		sprite_node.visible = false
		return

	var frame_data = null
	for candidate in frame_candidates:
		var frame_name = String(candidate).strip_edges()
		if frame_name.empty():
			continue
		frame_data = parse_sprite_frame(atlas_path, frame_name)
		if frame_data != null:
			break

	if frame_data == null:
		sprite_node.visible = false
		return

	sprite_node.texture = load(texture_path)
	sprite_node.region_enabled = true
	sprite_node.centered = false
	var frame = frame_data["frame"]
	sprite_node.region_rect = Rect2(frame["x"], frame["y"], frame["w"], frame["h"])
	sprite_node.visible = true

func build_move_pp_text(move) -> String:
	# Placeholder-first: we will populate real PP once move runtime tracks current/max values.
	if move == null:
		return "-/-"

	if move is Dictionary:
		if move.has("current_pp") and move.has("max_pp"):
			return "%d/%d" % [int(move["current_pp"]), int(move["max_pp"])]
		if move.has("pp"):
			var pp = int(move["pp"])
			return "%d/%d" % [pp, pp]

	return "-/-"

func _get_attack_move_buttons() -> Array:
	return [
		attack_move_button_1,
		attack_move_button_2,
		attack_move_button_3,
		attack_move_button_4,
	]

func _get_ball_action_entries() -> Array:
	return [
		{"button": ball_pokeball_button, "key": BALL_KEY_POKEBALL, "label": "Pokeball"},
		{"button": ball_greatball_button, "key": BALL_KEY_GREATBALL, "label": "Greatball"},
		{"button": ball_masterball_button, "key": BALL_KEY_MASTERBALL, "label": "Masterball"},
	]

func _get_ball_menu_buttons() -> Array:
	return [
		ball_pokeball_button,
		ball_greatball_button,
		ball_masterball_button,
		ball_cancel_button,
	]

func focus_first_attack_move_button():
	for button in _get_attack_move_buttons():
		if button != null and not button.disabled:
			button.grab_focus()
			return

func is_attack_menu_button(focus_owner) -> bool:
	for button in _get_attack_move_buttons():
		if focus_owner == button:
			return true
	return false

func set_battle_text(message: String):
	battle_text_label.text = message

func build_type_effectiveness_text(type_multiplier: float) -> String:
	# Pokerogue-style thresholds: >=2 super effective, <=0.5 not very effective.
	if type_multiplier >= 2.0:
		return " It's super effective!"
	if type_multiplier <= 0.5 and type_multiplier > 0.0:
		return " It's not very effective..."
	return ""

# Move animation asset loading and playback.
func _move_id_to_anim_slug(move_id: String) -> String:
	return move_id.strip_edges().to_lower().replace("_", "-")

func _read_json_payload(path: String):
	var f = File.new()
	if not f.file_exists(path):
		return null

	var open_error = f.open(path, File.READ)
	if open_error != OK:
		return null

	var json_text = f.get_as_text()
	f.close()

	var parsed = JSON.parse(json_text)
	if parsed.error != OK:
		return null

	return parsed.result

func _normalize_move_anim_config(payload):
	if typeof(payload) == TYPE_DICTIONARY:
		return payload
	if typeof(payload) == TYPE_ARRAY and payload.size() > 0 and typeof(payload[0]) == TYPE_DICTIONARY:
		return payload[0]
	return {}

func _extract_first_graphic_name(anim_config: Dictionary) -> String:
	if anim_config.has("graphic"):
		var direct_name = String(anim_config.get("graphic", "")).strip_edges()
		if not direct_name.empty():
			return direct_name

	var frames = anim_config.get("frames", [])
	if typeof(frames) != TYPE_ARRAY:
		return ""

	for frame_entries in frames:
		if typeof(frame_entries) != TYPE_ARRAY:
			continue
		for frame_entry in frame_entries:
			if typeof(frame_entry) != TYPE_DICTIONARY:
				continue
			if frame_entry.has("graphic"):
				var frame_graphic = String(frame_entry.get("graphic", "")).strip_edges()
				if not frame_graphic.empty():
					return frame_graphic

	return ""

func get_move_anim_config(move_id: String) -> Dictionary:
	var key = move_id.strip_edges().to_upper()
	if key.empty():
		return {}

	if move_anim_configs.has(key):
		var cached_config = move_anim_configs[key]
		if typeof(cached_config) == TYPE_DICTIONARY:
			return cached_config
		return {}

	var slug = _move_id_to_anim_slug(key)
	var config_path = minimal_assets_path + "assets/battle-anims/" + slug + ".json"
	var payload = _read_json_payload(config_path)
	var normalized = _normalize_move_anim_config(payload)
	if normalized.empty():
		move_anim_configs[key] = null
		return {}

	move_anim_configs[key] = normalized
	return normalized

func get_move_anim_texture(move_id: String, anim_config: Dictionary):
	var key = move_id.strip_edges().to_upper()
	if key.empty() or anim_config.empty():
		return null

	if move_anim_textures.has(key):
		return move_anim_textures[key]

	var graphic_name = _extract_first_graphic_name(anim_config)
	if graphic_name.empty():
		move_anim_textures[key] = null
		return null

	var texture_candidates = [
		minimal_assets_path + "assets/images/battle_anims/" + graphic_name + ".png",
		minimal_assets_path + "assets/images/battle_anims/" + graphic_name + ".webp",
	]

	for texture_path in texture_candidates:
		if resource_exists(texture_path):
			var texture = load(texture_path)
			move_anim_textures[key] = texture
			return texture

	move_anim_textures[key] = null
	return null

func play_move_animation(move_id: String, attacker_sprite: Sprite, defender_sprite: Sprite, active_turn_token: int):
	if not battle_fx_enabled:
		return null
	if attacker_sprite == null or defender_sprite == null:
		return null
	if effects_layer == null:
		return null
	var anim_config = get_move_anim_config(move_id)
	if anim_config.empty():
		play_move_sfx(move_id)
		return null

	var anim_texture = get_move_anim_texture(move_id, anim_config)
	if anim_texture == null:
		play_move_sfx(move_id)
		return null

	var anim_frames = anim_config.get("frames", [])
	if anim_frames.empty():
		play_move_sfx(move_id)
		return null

	var effect_sprites := []

	var user_x = attacker_sprite.position.x
	var user_y = attacker_sprite.position.y
	var target_x = defender_sprite.position.x
	var target_y = defender_sprite.position.y
	var user_half_h = get_sprite_half_height(attacker_sprite)
	var target_half_h = get_sprite_half_height(defender_sprite)
	var timed_events = anim_config.get("frameTimedEvents", {})
	var played_timed_sound = false

	for frame_idx in range(anim_frames.size()):
		if active_turn_token != turn_token:
			free_effect_sprites(effect_sprites)
			return null

		var frame_entries = anim_frames[frame_idx]
		var visible_effect_count = 0
		for frame_entry in frame_entries:
			if typeof(frame_entry) != TYPE_DICTIONARY:
				continue
			if int(frame_entry.get("target", 0)) != 2:
				continue

			var effect = ensure_effect_sprite(effect_sprites, visible_effect_count, anim_texture)
			apply_move_graphic_frame(
				effect,
				frame_entry,
				user_x,
				user_y,
				target_x,
				target_y,
				user_half_h,
				target_half_h
			)
			visible_effect_count += 1

		for effect_index in range(visible_effect_count, effect_sprites.size()):
			effect_sprites[effect_index].visible = false

		var frame_events = timed_events.get(str(frame_idx), [])
		for evt in frame_events:
			if String(evt.get("eventType", "")) == "AnimTimedSoundEvent":
				play_anim_event_sound(String(evt.get("resourceName", "")))
				played_timed_sound = true

		yield(get_tree().create_timer(move_anim_step_sec), "timeout")

	if not played_timed_sound:
		play_move_sfx(move_id)

	free_effect_sprites(effect_sprites)
	return null

func ensure_effect_sprite(effect_sprites: Array, sprite_index: int, anim_texture):
	while effect_sprites.size() <= sprite_index:
		var effect = Sprite.new()
		effect.texture = anim_texture
		effect.region_enabled = true
		effect.centered = true
		effect.z_index = 0
		effects_layer.add_child(effect)
		effect_sprites.append(effect)

	var sprite = effect_sprites[sprite_index]
	sprite.texture = anim_texture
	sprite.visible = true
	return sprite

func free_effect_sprites(effect_sprites: Array):
	for effect in effect_sprites:
		if effect != null:
			effect.queue_free()

func apply_move_graphic_frame(
	effect: Sprite,
	frame_entry: Dictionary,
	user_x: float,
	user_y: float,
	target_x: float,
	target_y: float,
	user_half_h: float,
	target_half_h: float
):
	if effect == null:
		return

	var frame_x = float(frame_entry.get("x", 0.0)) + USER_FOCUS_X
	var frame_y = float(frame_entry.get("y", 0.0)) + USER_FOCUS_Y
	var focus = int(frame_entry.get("focus", ANIM_FOCUS_TARGET))

	if focus == ANIM_FOCUS_TARGET:
		frame_x += target_x - TARGET_FOCUS_X
		frame_y += target_y - target_half_h - TARGET_FOCUS_Y
	elif focus == ANIM_FOCUS_USER:
		frame_x += user_x - USER_FOCUS_X
		frame_y += user_y - user_half_h - USER_FOCUS_Y
	elif focus == ANIM_FOCUS_USER_TARGET:
		var mapped = transform_anim_point(
			USER_FOCUS_X,
			USER_FOCUS_Y,
			TARGET_FOCUS_X,
			TARGET_FOCUS_Y,
			user_x,
			user_y - user_half_h,
			target_x,
			target_y - target_half_h,
			frame_x,
			frame_y
		)
		frame_x = mapped.x
		frame_y = mapped.y
	elif focus == ANIM_FOCUS_SCREEN:
		pass

	var zoom_x = float(frame_entry.get("zoomX", 100.0)) / 100.0
	var zoom_y = float(frame_entry.get("zoomY", 100.0)) / 100.0
	if bool(frame_entry.get("mirror", false)):
		zoom_x *= -1.0

	var frame_idx = int(frame_entry.get("graphicFrame", 0))
	set_effect_frame_region(effect, frame_idx)
	effect.position = Vector2(frame_x, frame_y)
	effect.rotation_degrees = -float(frame_entry.get("angle", 0.0))
	effect.scale = Vector2(zoom_x, zoom_y)
	effect.visible = bool(frame_entry.get("visible", true))
	effect.modulate = Color(1, 1, 1, float(frame_entry.get("opacity", 255)) / 255.0)

	if int(frame_entry.get("blendType", 0)) == 1 and add_blend_material != null:
		effect.material = add_blend_material
	else:
		effect.material = null

func set_effect_frame_region(effect: Sprite, frame_idx: int):
	if effect == null or effect.texture == null:
		return

	var tex_w = int(effect.texture.get_size().x)
	if tex_w <= 0:
		return

	var cols = max(1, tex_w / MOVE_SHEET_FRAME_SIZE)
	var col = frame_idx % cols
	var row = frame_idx / cols
	effect.region_rect = Rect2(
		float(col * MOVE_SHEET_FRAME_SIZE),
		float(row * MOVE_SHEET_FRAME_SIZE),
		MOVE_SHEET_FRAME_SIZE,
		MOVE_SHEET_FRAME_SIZE
	)

func get_sprite_half_height(sprite_node: Sprite) -> float:
	if sprite_node == null:
		return 0.0

	if sprite_node.region_enabled:
		return float(sprite_node.region_rect.size.y) * abs(sprite_node.scale.y) * 0.5
	if sprite_node.texture == null:
		return 0.0
	return float(sprite_node.texture.get_size().y) * abs(sprite_node.scale.y) * 0.5

func transform_anim_point(
	src_x1: float,
	src_y1: float,
	src_x2: float,
	src_y2: float,
	dst_x1: float,
	dst_y1: float,
	dst_x2: float,
	dst_y2: float,
	px: float,
	py: float
) -> Vector2:
	var t = y_axis_intersect(src_x1, src_y1, src_x2, src_y2, px, py)
	return reposition_y(dst_x1, dst_y1, dst_x2, dst_y2, t.x, t.y)

func y_axis_intersect(x1: float, y1: float, x2: float, y2: float, px: float, py: float) -> Vector2:
	var dx = x2 - x1
	var dy = y2 - y1
	var tx = 0.0 if dx == 0.0 else (px - x1) / dx
	var ty = 0.0 if dy == 0.0 else (py - y1) / dy
	return Vector2(tx, ty)

func reposition_y(x1: float, y1: float, x2: float, y2: float, tx: float, ty: float) -> Vector2:
	var dx = x2 - x1
	var dy = y2 - y1
	return Vector2(x1 + tx * dx, y1 + ty * dy)

func resolve_audio_asset_path(relative_path: String) -> String:
	var normalized = relative_path.strip_edges()
	if normalized.empty():
		return ""

	var exact_path = minimal_assets_path + normalized
	if resource_exists(exact_path):
		return exact_path

	if normalized.to_lower().ends_with(".m4a"):
		var base = normalized.substr(0, normalized.length() - 4)
		var ogg_path = minimal_assets_path + base + ".ogg"
		if resource_exists(ogg_path):
			return ogg_path
		var wav_path = minimal_assets_path + base + ".wav"
		if resource_exists(wav_path):
			return wav_path

	return ""

func play_anim_event_sound(resource_name: String):
	if not battle_fx_enabled:
		return

	var file_name = resource_name.strip_edges()
	if file_name.empty():
		return

	var sfx_path = resolve_audio_asset_path("assets/audio/battle_anims/" + file_name)
	if sfx_path.empty():
		log_debug("Missing timed anim SFX: %s" % sfx_path)
		play_move_sfx("")
		return

	$UIAudioStreamPlayer.stream = load(sfx_path)
	$UIAudioStreamPlayer.play()

func play_move_sfx(move_id: String):
	if not battle_fx_enabled:
		return

	var sfx_relative_path = "assets/audio/ui/select.wav"
	var anim_config = get_move_anim_config(move_id)
	if not anim_config.empty():
		var timed_events = anim_config.get("frameTimedEvents", {})
		if typeof(timed_events) == TYPE_DICTIONARY:
			for frame_key in timed_events.keys():
				var frame_events = timed_events.get(frame_key, [])
				if typeof(frame_events) != TYPE_ARRAY:
					continue
				for evt in frame_events:
					if typeof(evt) != TYPE_DICTIONARY:
						continue
					if String(evt.get("eventType", "")) != "AnimTimedSoundEvent":
						continue
					var resource_name = String(evt.get("resourceName", "")).strip_edges()
					if resource_name.empty():
						continue
					sfx_relative_path = "assets/audio/battle_anims/" + resource_name
					break
				if sfx_relative_path != "assets/audio/ui/select.wav":
					break

	var sfx_path = resolve_audio_asset_path(sfx_relative_path)
	if sfx_path.empty():
		log_debug("Missing move SFX resource: %s" % sfx_path)
		sfx_path = resolve_audio_asset_path("assets/audio/ui/select.wav")
		if sfx_path.empty():
			log_debug("Missing fallback select SFX: %s" % sfx_path)
			return

	$UIAudioStreamPlayer.stream = load(sfx_path)
	$UIAudioStreamPlayer.play()

# Hit/faint feedback helpers.
func play_hit_feedback(target_sprite: Sprite, active_turn_token: int):
	if not battle_fx_enabled:
		return null
	if target_sprite == null:
		return null

	var original_pos = target_sprite.position
	var original_modulate = target_sprite.modulate
	var flash_color = Color(impact_flash_mul, impact_flash_mul, impact_flash_mul, original_modulate.a)
	target_sprite.modulate = flash_color

	var shake_offsets = [
		Vector2(impact_shake_px, 0),
		Vector2(-impact_shake_px, 0),
		Vector2(impact_shake_px * 0.5, 0),
		Vector2.ZERO,
	]

	for offset in shake_offsets:
		target_sprite.position = original_pos + offset
		yield(get_tree().create_timer(impact_shake_step_sec), "timeout")
		if active_turn_token != turn_token:
			target_sprite.position = original_pos
			target_sprite.modulate = original_modulate
			return null

	target_sprite.position = original_pos
	target_sprite.modulate = original_modulate
	return null

func play_faint_animation(target_sprite: Sprite, is_player_sprite: bool, active_turn_token: int):
	if target_sprite == null:
		return null

	if is_player_sprite:
		player_sprite_anim_enabled = false
	else:
		enemy_sprite_anim_enabled = false

	if not battle_fx_enabled:
		target_sprite.modulate.a = 0.0
		target_sprite.visible = false
		return null

	var home_pos = player_sprite_home_position if is_player_sprite else enemy_sprite_home_position
	var original_modulate = target_sprite.modulate
	var step_count = 5
	for step in range(step_count):
		var t = float(step + 1) / float(step_count)
		target_sprite.position = home_pos + Vector2(0, faint_drop_px * t)
		target_sprite.modulate = Color(
			original_modulate.r,
			original_modulate.g,
			original_modulate.b,
			1.0 - t
		)
		yield(get_tree().create_timer(faint_step_sec), "timeout")
		if active_turn_token != turn_token:
			restore_battler_sprite_state(target_sprite, home_pos)
			return null

	target_sprite.position = home_pos + Vector2(0, faint_drop_px)
	target_sprite.modulate = Color(original_modulate.r, original_modulate.g, original_modulate.b, 0.0)
	target_sprite.visible = false
	return null

func restore_battler_sprite_state(target_sprite: Sprite, home_pos: Vector2):
	if target_sprite == null:
		return

	target_sprite.visible = true
	target_sprite.position = home_pos
	if target_sprite == player_pokemon_sprite:
		target_sprite.scale = player_sprite_home_scale
	elif target_sprite == enemy_pokemon_sprite:
		target_sprite.scale = enemy_sprite_home_scale
	target_sprite.modulate = Color(1, 1, 1, 1)

# Sprite atlas parsing helpers.
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
		log_debug("Missing atlas json: %s" % json_path)
		return []

	f.open(json_path, File.READ)
	var json_text = f.get_as_text()
	f.close()

	var result = JSON.parse(json_text)
	if result.error != OK:
		log_debug("JSON parse failed: %s" % json_path)
		return []

	var data = result.result
	if not data.has("textures"):
		log_debug("Atlas missing textures key: %s" % json_path)
		return []

	var textures = data["textures"]
	if textures.size() == 0:
		log_debug("Atlas textures list empty: %s" % json_path)
		return []

	var frames = textures[0].get("frames", null)
	if frames == null:
		log_debug("Atlas has no frames: %s" % json_path)
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
		var frame_index = _extract_numeric_frame_index(String(frame["filename"]))
		if frame_index < 0:
			continue
		indexed.append({
			"index": frame_index,
			"frame": frame,
		})

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

# Sprite loading and trainer/sendout choreography.
func load_battle_sprites():
	var enemy_species_id = "BULBASAUR"
	var player_species_id = "CHARMANDER"
	if battle_data != null:
		if battle_data.has("enemy") and battle_data["enemy"] != null:
			enemy_species_id = String(battle_data["enemy"].species_id)
		if battle_data.has("player") and battle_data["player"] != null:
			player_species_id = String(battle_data["player"].species_id)

	var enemy_paths = get_species_sprite_paths(enemy_species_id, false)
	var player_paths = get_species_sprite_paths(player_species_id, true)

	if enemy_paths.empty():
		enemy_paths = {
			"texture_rel": "assets/images/pokemon/1.png",
			"atlas_rel": "assets/images/pokemon/1.json",
		}
	if player_paths.empty():
		player_paths = {
			"texture_rel": "assets/images/pokemon/back/4.png",
			"atlas_rel": "assets/images/pokemon/back/4.json",
		}

	enemy_sprite_frames = load_sprite_for_node(enemy_pokemon_sprite, String(enemy_paths["texture_rel"]), String(enemy_paths["atlas_rel"]))
	player_sprite_frames = load_sprite_for_node(player_pokemon_sprite, String(player_paths["texture_rel"]), String(player_paths["atlas_rel"]))
	player_sendout_cry_key = _resolve_species_sendout_cry_key(player_species_id, player_paths)
	enemy_sendout_cry_key = _resolve_species_sendout_cry_key(enemy_species_id, enemy_paths)
	if player_sendout_cry_key.empty():
		log_debug("Player sendout cry key unresolved for species %s" % player_species_id)
	if enemy_sendout_cry_key.empty():
		log_debug("Enemy sendout cry key unresolved for species %s" % enemy_species_id)
	load_player_trainer_sprite()

func _resolve_species_sendout_cry_key(species_id: String, species_paths: Dictionary) -> String:
	var normalized_species_id = species_id.strip_edges().to_upper()
	if not normalized_species_id.empty():
		if catalog_loader == null:
			catalog_loader = catalog_loader_script.new()
		if catalog_loader != null and catalog_loader.load_catalogs():
			var dex_number = catalog_loader.get_species_dex_number(normalized_species_id)
			if dex_number > 0:
				return str(dex_number)

	var sprite_key = String(species_paths.get("sprite_key", "")).strip_edges().to_lower()
	if sprite_key.empty():
		var texture_rel = String(species_paths.get("texture_rel", "")).strip_edges().to_lower()
		if not texture_rel.empty():
			sprite_key = texture_rel.get_file().get_basename()

	if sprite_key.empty():
		return ""

	var dash_index = sprite_key.find("-")
	if dash_index > 0:
		sprite_key = sprite_key.substr(0, dash_index)

	var underscore_index = sprite_key.find("_")
	if underscore_index > 0:
		sprite_key = sprite_key.substr(0, underscore_index)

	if not sprite_key.is_valid_integer():
		return ""

	return sprite_key

func load_player_trainer_sprite() -> void:
	player_trainer_idle_frame = {}
	player_trainer_throw_frames.clear()
	player_trainer_choreo_playing = false
	player_trainer_choreo_elapsed = 0.0
	player_trainer_last_throw_index = -1
	player_trainer_pokemon_revealed = false
	player_trainer_exit_started = false
	player_pokeball_lob_started = false
	player_pokeball_release_done = false
	_hide_player_pokeball_sprite()

	if player_trainer_sprite == null:
		return
	if not player_trainer_enabled:
		player_trainer_sprite.visible = false
		return

	var back_texture_path = minimal_assets_path + PLAYER_TRAINER_BACK_TEXTURE_REL
	var back_atlas_path = minimal_assets_path + PLAYER_TRAINER_BACK_ATLAS_REL
	var back_pb_texture_path = minimal_assets_path + PLAYER_TRAINER_BACK_PB_TEXTURE_REL
	var back_pb_atlas_path = minimal_assets_path + PLAYER_TRAINER_BACK_PB_ATLAS_REL

	if not resource_exists(back_texture_path):
		log_debug("Missing player trainer texture: %s" % back_texture_path)
		player_trainer_sprite.visible = false
		return

	player_trainer_texture_back = load(back_texture_path)
	if resource_exists(back_pb_texture_path):
		player_trainer_texture_back_pb = load(back_pb_texture_path)
	else:
		player_trainer_texture_back_pb = null

	var back_frames = get_all_numeric_frames(back_atlas_path)
	if back_frames.empty():
		var fallback_back_frame = parse_sprite_frame(back_atlas_path, "0001.png")
		if fallback_back_frame != null:
			back_frames.append(fallback_back_frame)

	var back_pb_frames = get_all_numeric_frames(back_pb_atlas_path)
	if back_pb_frames.empty():
		var fallback_back_pb_frame = parse_sprite_frame(back_pb_atlas_path, "0001.png")
		if fallback_back_pb_frame != null:
			back_pb_frames.append(fallback_back_pb_frame)

	if back_frames.empty():
		# Atlas fallback: render full texture so trainer is still present.
		player_trainer_sprite.texture = player_trainer_texture_back
		player_trainer_sprite.centered = true
		player_trainer_sprite.region_enabled = false
		player_trainer_sprite.offset = Vector2.ZERO
		player_trainer_sprite.visible = true
		return

	player_trainer_idle_frame = {
		"texture": player_trainer_texture_back,
		"frame": back_frames[0],
	}

	if player_trainer_texture_back_pb != null and not back_pb_frames.empty():
		for i in range(min(3, back_pb_frames.size())):
			player_trainer_throw_frames.append({
				"texture": player_trainer_texture_back_pb,
				"frame": back_pb_frames[i],
			})

	if player_trainer_idle_frame.empty():
		player_trainer_sprite.visible = false
		return

	_apply_trainer_frame(player_trainer_idle_frame)
	# Keep trainer hidden until summon choreography explicitly starts.
	player_trainer_sprite.visible = false

func _apply_trainer_frame(frame_entry: Dictionary) -> void:
	if player_trainer_sprite == null:
		return
	if frame_entry.empty() or not frame_entry.has("texture") or not frame_entry.has("frame"):
		return
	player_trainer_sprite.texture = frame_entry["texture"]
	player_trainer_sprite.centered = true
	player_trainer_sprite.region_enabled = true
	player_trainer_sprite.offset = Vector2.ZERO
	apply_sprite_frame(player_trainer_sprite, frame_entry["frame"])

func start_player_trainer_summon_choreography() -> void:
	set_sendout_controls_locked(true)
	if player_trainer_sprite == null or not player_trainer_enabled:
		if player_pokemon_sprite != null:
			player_pokemon_sprite.visible = true
		_play_player_sendout_cry_once()
		_on_player_sendout_settled()
		return
	if player_trainer_idle_frame.empty():
		if player_pokemon_sprite != null:
			player_pokemon_sprite.visible = true
		_play_player_sendout_cry_once()
		_on_player_sendout_settled()
		return

	player_trainer_choreo_playing = true
	player_trainer_choreo_elapsed = 0.0
	player_trainer_last_throw_index = -1
	player_trainer_pokemon_revealed = false
	player_trainer_exit_started = false
	player_sendout_cry_played = false

	player_trainer_sprite.visible = true
	player_trainer_sprite.position = player_trainer_sprite_home_position
	_apply_trainer_frame(player_trainer_idle_frame)

	if player_pokemon_sprite != null:
		player_pokemon_sprite.visible = false

func _start_player_trainer_exit_tween() -> void:
	if player_trainer_sprite == null:
		return
	if player_trainer_exit_started:
		return
	player_trainer_exit_started = true

	var exit_tween = Tween.new()
	add_child(exit_tween)
	exit_tween.interpolate_property(
		player_trainer_sprite,
		"position:x",
		player_trainer_sprite.position.x,
		player_trainer_sprite_home_position.x - player_trainer_exit_distance_px,
		max(0.01, player_trainer_exit_duration_sec),
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	exit_tween.start()
	_connect_once(exit_tween, "tween_all_completed", "_on_player_trainer_exit_tween_completed", [exit_tween])

func update_player_trainer_choreography(delta: float) -> void:
	if not player_trainer_choreo_playing:
		return

	player_trainer_choreo_elapsed += delta

	# Pokerogue-style player send-out keyframe moments (seconds):
	# 0.000 -> pb frame 1, 0.562 -> pb frame 2, 0.626 -> pb frame 3.
	# We offset these by an idle-hold window so the trainer can breathe before throwing.
	var idle_hold = max(0.0, player_trainer_idle_hold_sec)
	var throw_schedule = [idle_hold, idle_hold + 0.562, idle_hold + 0.626]
	var pokeball_start_time = idle_hold + max(0.0, player_pokeball_start_delay_sec)
	for throw_index in range(min(throw_schedule.size(), player_trainer_throw_frames.size())):
		if player_trainer_choreo_elapsed >= throw_schedule[throw_index] and player_trainer_last_throw_index < throw_index:
			_apply_trainer_frame(player_trainer_throw_frames[throw_index])
			player_trainer_last_throw_index = throw_index
			if throw_index == 0:
				_start_player_trainer_exit_tween()

	if not player_pokeball_lob_started and player_trainer_choreo_elapsed >= pokeball_start_time:
		_start_player_pokeball_lob()

	if player_trainer_throw_frames.empty() and player_trainer_choreo_elapsed >= idle_hold:
		_start_player_trainer_exit_tween()

	var reveal_ready = false
	if player_pokeball_lob_started:
		reveal_ready = player_pokeball_release_done
	else:
		if player_trainer_choreo_elapsed < pokeball_start_time:
			reveal_ready = false
		else:
			# If the lob could not start (missing asset/frame), use the delay fallback.
			var reveal_delay = max(max(0.01, player_trainer_reveal_delay_sec), idle_hold)
			reveal_ready = player_trainer_choreo_elapsed >= reveal_delay

	if not player_trainer_pokemon_revealed and reveal_ready:
		player_trainer_pokemon_revealed = true
		if player_pokemon_sprite != null:
			_play_player_pokemon_sendout_reveal_fx()
		if player_trainer_sprite == null or not player_trainer_sprite.visible:
			player_trainer_choreo_playing = false

func _play_player_pokeball_release_sfx() -> void:
	if not battle_fx_enabled:
		return

	var sfx_path = minimal_assets_path + "assets/audio/se/pb_rel.wav"
	if not resource_exists(sfx_path):
		sfx_path = minimal_assets_path + "assets/audio/ui/menu_open.wav"
		if not resource_exists(sfx_path):
			sfx_path = minimal_assets_path + "assets/audio/ui/select.wav"
			if not resource_exists(sfx_path):
				return

	$UIAudioStreamPlayer.stream = load(sfx_path)
	$UIAudioStreamPlayer.play()

func _play_player_pokemon_sendout_reveal_fx() -> void:
	if player_pokemon_sprite == null:
		_on_player_sendout_settled()
		return

	if not battle_fx_enabled:
		player_pokemon_sprite.visible = true
		player_pokemon_sprite.scale = player_sprite_home_scale
		player_pokemon_sprite.modulate = Color(1, 1, 1, 1)
		_play_player_sendout_cry_once()
		_on_player_sendout_settled()
		return

	_play_player_pokeball_release_sfx()

	var start_scale_mul = max(0.1, player_pokemon_reveal_start_scale)
	var target_scale = player_sprite_home_scale
	var start_scale = Vector2(target_scale.x * start_scale_mul, target_scale.y * start_scale_mul)
	player_pokemon_sprite.scale = start_scale
	var tint = player_pokemon_reveal_tint_color
	var flash_mul = max(0.1, player_pokemon_reveal_flash_mul)
	tint.r = clamp(tint.r * flash_mul, 0.0, 2.0)
	tint.g = clamp(tint.g * flash_mul, 0.0, 2.0)
	tint.b = clamp(tint.b * flash_mul, 0.0, 2.0)
	tint.a = clamp(player_pokemon_reveal_alpha_start, 0.0, 1.0)
	player_pokemon_sprite.modulate = tint
	player_pokemon_sprite.visible = true

	var reveal_tween = Tween.new()
	add_child(reveal_tween)
	reveal_tween.interpolate_property(
		player_pokemon_sprite,
		"scale",
		start_scale,
		target_scale,
		max(0.01, player_pokemon_reveal_scale_duration_sec),
		Tween.TRANS_SINE,
		Tween.EASE_IN
	)
	reveal_tween.interpolate_property(
		player_pokemon_sprite,
		"modulate",
		player_pokemon_sprite.modulate,
		Color(1, 1, 1, 1),
		max(0.01, player_pokemon_reveal_flash_duration_sec),
		Tween.TRANS_SINE,
		Tween.EASE_IN
	)
	reveal_tween.start()
	_connect_once(reveal_tween, "tween_all_completed", "_on_player_pokemon_reveal_tween_completed", [reveal_tween])

func _on_player_pokemon_reveal_tween_completed(reveal_tween: Tween) -> void:
	_play_player_sendout_cry_once()
	_on_player_pokeball_tween_completed(reveal_tween)
	_on_player_sendout_settled()

func _play_player_sendout_cry_once() -> void:
	if player_sendout_cry_played:
		return
	if player_sendout_cry_key.empty():
		log_debug("Skipping player cry: no resolved cry key")
		print("[Battle] Skipping player cry: no resolved cry key")
		return

	var cry_candidates = [
		minimal_assets_path + "assets/audio/cry/%s.ogg" % player_sendout_cry_key,
		minimal_assets_path + "assets/audio/cry/%s.wav" % player_sendout_cry_key,
	]

	var cry_path = ""
	for candidate in cry_candidates:
		if resource_exists(candidate):
			cry_path = candidate
			break

	if cry_path.empty():
		log_debug("Skipping player cry: no cry file found for key %s" % player_sendout_cry_key)
		print("[Battle] Skipping player cry: no cry file found for key %s" % player_sendout_cry_key)
		return

	var cry_stream = load(cry_path)
	if cry_stream == null:
		log_debug("Skipping player cry: failed to load stream %s" % cry_path)
		print("[Battle] Skipping player cry: failed to load stream %s" % cry_path)
		return

	# Some imported streams may carry loop metadata. Force one-shot behavior.
	if cry_stream is AudioStreamOGGVorbis:
		cry_stream.loop = false
	elif cry_stream is AudioStreamSample:
		cry_stream.loop_mode = AudioStreamSample.LOOP_DISABLED

	if player_cry_audio_player == null:
		player_cry_audio_player = AudioStreamPlayer.new()
		player_cry_audio_player.name = "PlayerCryAudioPlayer"
		add_child(player_cry_audio_player)

	player_cry_audio_player.stream = cry_stream
	player_cry_audio_player.play()
	log_debug("Played player cry: %s" % cry_path)
	print("[Battle] Played player cry: %s" % cry_path)
	player_sendout_cry_played = true

func _play_enemy_sendout_cry_once() -> void:
	if enemy_sendout_cry_key.empty():
		log_debug("Skipping enemy cry: no resolved cry key")
		print("[Battle] Skipping enemy cry: no resolved cry key")
		return

	var cry_candidates = [
		minimal_assets_path + "assets/audio/cry/%s.ogg" % enemy_sendout_cry_key,
		minimal_assets_path + "assets/audio/cry/%s.wav" % enemy_sendout_cry_key,
	]

	var cry_path = ""
	for candidate in cry_candidates:
		if resource_exists(candidate):
			cry_path = candidate
			break

	if cry_path.empty():
		log_debug("Skipping enemy cry: no cry file found for key %s" % enemy_sendout_cry_key)
		print("[Battle] Skipping enemy cry: no cry file found for key %s" % enemy_sendout_cry_key)
		return

	var cry_stream = load(cry_path)
	if cry_stream == null:
		log_debug("Skipping enemy cry: failed to load stream %s" % cry_path)
		print("[Battle] Skipping enemy cry: failed to load stream %s" % cry_path)
		return

	# Some imported streams may carry loop metadata. Force one-shot behavior.
	if cry_stream is AudioStreamOGGVorbis:
		cry_stream.loop = false
	elif cry_stream is AudioStreamSample:
		cry_stream.loop_mode = AudioStreamSample.LOOP_DISABLED

	if enemy_cry_audio_player == null:
		enemy_cry_audio_player = AudioStreamPlayer.new()
		enemy_cry_audio_player.name = "EnemyCryAudioPlayer"
		add_child(enemy_cry_audio_player)

	enemy_cry_audio_player.stream = cry_stream
	enemy_cry_audio_player.play()
	log_debug("Played enemy cry: %s" % cry_path)
	print("[Battle] Played enemy cry: %s" % cry_path)

func _ensure_player_pokeball_sprite() -> bool:
	if player_pokeball_sprite != null:
		return true
	if effects_layer == null:
		return false

	player_pokeball_sprite = Sprite.new()
	player_pokeball_sprite.centered = true
	player_pokeball_sprite.region_enabled = true
	player_pokeball_sprite.visible = false
	effects_layer.add_child(player_pokeball_sprite)
	return true

func _apply_pokeball_frame(frame_name: String) -> bool:
	if not _ensure_player_pokeball_sprite():
		return false

	var texture_path = minimal_assets_path + POKEBALL_TEXTURE_REL
	var atlas_path = minimal_assets_path + POKEBALL_ATLAS_REL
	if not resource_exists(texture_path):
		return false

	var frame_data = parse_sprite_frame(atlas_path, frame_name)
	if frame_data == null:
		return false

	player_pokeball_sprite.texture = load(texture_path)
	player_pokeball_sprite.region_enabled = true
	player_pokeball_sprite.centered = true
	var frame = frame_data["frame"]
	player_pokeball_sprite.region_rect = Rect2(frame["x"], frame["y"], frame["w"], frame["h"])
	return true

func _start_player_pokeball_lob() -> void:
	if player_pokeball_lob_started:
		return
	if not _apply_pokeball_frame(POKEBALL_FRAME_CLOSED):
		return

	player_pokeball_lob_started = true
	player_pokeball_release_done = false
	player_pokeball_sprite.visible = true
	player_pokeball_sprite.rotation_degrees = 0.0

	var start_pos = player_trainer_sprite_home_position + Vector2(player_pokeball_start_offset_x, player_pokeball_start_offset_y)
	if player_trainer_sprite != null:
		start_pos = player_trainer_sprite.position + Vector2(player_pokeball_start_offset_x, player_pokeball_start_offset_y)
	var target_pos = player_sprite_home_position + Vector2(player_pokeball_target_offset_x, player_pokeball_target_offset_y)
	var arc_peak_y = target_pos.y - player_pokeball_arc_height_px
	player_pokeball_sprite.position = start_pos
	var lob_duration = max(0.01, player_pokeball_lob_duration_sec)
	var lob_up_duration = clamp(player_pokeball_lob_up_duration_sec, 0.01, lob_duration - 0.01)
	var lob_down_duration = max(0.01, lob_duration - lob_up_duration)

	var x_tween = Tween.new()
	add_child(x_tween)
	x_tween.interpolate_property(player_pokeball_sprite, "position:x", start_pos.x, target_pos.x, lob_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	x_tween.start()
	_connect_once(x_tween, "tween_all_completed", "_on_player_pokeball_tween_completed", [x_tween])

	var rotate_tween = Tween.new()
	add_child(rotate_tween)
	rotate_tween.interpolate_property(player_pokeball_sprite, "rotation_degrees", 0.0, player_pokeball_spin_degrees, lob_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	rotate_tween.start()
	_connect_once(rotate_tween, "tween_all_completed", "_on_player_pokeball_tween_completed", [rotate_tween])

	var up_tween = Tween.new()
	add_child(up_tween)
	up_tween.interpolate_property(player_pokeball_sprite, "position:y", start_pos.y, arc_peak_y, lob_up_duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	up_tween.start()
	_connect_once(up_tween, "tween_all_completed", "_on_player_pokeball_up_completed", [target_pos.y, lob_down_duration, up_tween])

func _on_player_pokeball_up_completed(target_y: float, down_duration: float, up_tween: Tween) -> void:
	if up_tween != null:
		up_tween.queue_free()
	if player_pokeball_sprite == null:
		return

	var down_tween = Tween.new()
	add_child(down_tween)
	down_tween.interpolate_property(player_pokeball_sprite, "position:y", player_pokeball_sprite.position.y, target_y, max(0.01, down_duration), Tween.TRANS_CUBIC, Tween.EASE_IN)
	down_tween.start()
	_connect_once(down_tween, "tween_all_completed", "_on_player_pokeball_down_completed", [down_tween])

func _on_player_pokeball_down_completed(down_tween: Tween) -> void:
	if down_tween != null:
		down_tween.queue_free()
	if player_pokeball_sprite == null:
		player_pokeball_release_done = true
		return

	if not _apply_pokeball_frame(POKEBALL_FRAME_OPENING):
		player_pokeball_release_done = true
		_hide_player_pokeball_sprite()
		return

	var timer_open = get_tree().create_timer(max(0.01, player_pokeball_opening_hold_sec))
	_connect_once(timer_open, "timeout", "_on_player_pokeball_open_timeout")

func _on_player_pokeball_open_timeout() -> void:
	if player_pokeball_sprite != null:
		if not _apply_pokeball_frame(POKEBALL_FRAME_OPEN):
			pass
	player_pokeball_release_done = true
	_spawn_player_pokeball_open_particles()
	var timer_hide = get_tree().create_timer(max(0.01, player_pokeball_open_hold_sec))
	_connect_once(timer_hide, "timeout", "_on_player_pokeball_hide_timeout")

func _on_player_pokeball_hide_timeout() -> void:
	_hide_player_pokeball_sprite()

func _on_player_pokeball_tween_completed(tween_node: Tween) -> void:
	if tween_node != null:
		tween_node.queue_free()

func _ensure_pokeball_particles_assets() -> bool:
	if pokeball_particles_texture != null and not pokeball_particles_frames.empty() and pokeball_open_particle_sprite_frames != null:
		return true

	var texture_path = minimal_assets_path + POKEBALL_PARTICLES_TEXTURE_REL
	var atlas_path = minimal_assets_path + POKEBALL_PARTICLES_ATLAS_REL
	if not resource_exists(texture_path):
		return false

	var frames = get_all_numeric_frames(atlas_path)
	if frames.empty():
		frames = parse_all_sprite_frames(atlas_path)
		if frames.empty():
			return false

	pokeball_particles_texture = load(texture_path)
	pokeball_particles_frames = frames

	var anim_frames = min(4, pokeball_particles_frames.size())
	if anim_frames <= 0:
		return false

	var sprite_frames = SpriteFrames.new()
	sprite_frames.add_animation("default")
	sprite_frames.set_animation_speed("default", 16.0)
	sprite_frames.set_animation_loop("default", true)
	for i in range(anim_frames):
		var frame_entry = pokeball_particles_frames[i]
		if frame_entry == null or not frame_entry.has("frame"):
			continue
		var frame = frame_entry["frame"]
		var atlas_tex = AtlasTexture.new()
		atlas_tex.atlas = pokeball_particles_texture
		atlas_tex.region = Rect2(frame["x"], frame["y"], frame["w"], frame["h"])
		sprite_frames.add_frame("default", atlas_tex)

	if sprite_frames.get_frame_count("default") <= 0:
		return false

	pokeball_open_particle_sprite_frames = sprite_frames
	return true

func _spawn_player_pokeball_open_particles(origin_override = null) -> void:
	if not battle_fx_enabled:
		return
	if effects_layer == null:
		return
	if not _ensure_pokeball_particles_assets():
		return

	var count = max(0, player_pokeball_particle_count)
	if count <= 0:
		return

	var origin = player_sprite_home_position + Vector2(0, -16)
	if typeof(origin_override) == TYPE_VECTOR2:
		origin = origin_override
	var spawn_interval = max(0.0, player_pokeball_particle_spawn_interval_sec)
	var radius = max(0.0, player_pokeball_particle_radius_px)
	var travel_duration = max(0.05, player_pokeball_particle_travel_duration_sec)
	var fade_delay = max(0.0, player_pokeball_particle_fade_delay_sec)
	var fade_duration = max(0.01, player_pokeball_particle_fade_duration_sec)

	for i in range(count):
		var timer = get_tree().create_timer(spawn_interval * i)
		_connect_once(timer, "timeout", "_spawn_player_pokeball_open_particle_step", [i + 1, origin, radius, travel_duration, fade_delay, fade_duration])

func _spawn_player_pokeball_open_particle_step(index: int, origin: Vector2, radius: float, travel_duration: float, fade_delay: float, fade_duration: float) -> void:
	if effects_layer == null:
		return
	if pokeball_open_particle_sprite_frames == null:
		return

	var particle = AnimatedSprite.new()
	particle.frames = pokeball_open_particle_sprite_frames
	particle.animation = "default"
	var frame_count = int(max(1, pokeball_open_particle_sprite_frames.get_frame_count("default")))
	particle.frame = int((index + 3) % frame_count)
	particle.speed_scale = 1.0
	particle.centered = true
	particle.position = origin
	particle.modulate = Color(1, 1, 1, 1)
	effects_layer.add_child(particle)
	particle.play("default")

	var angle_radians = deg2rad(float(index) * 45.0)
	var target = origin + Vector2(cos(angle_radians), sin(angle_radians)) * radius

	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(particle, "position", particle.position, target, travel_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(particle, "modulate:a", 1.0, 0.0, fade_duration, Tween.TRANS_SINE, Tween.EASE_IN, fade_delay)
	tween.start()
	_connect_once(tween, "tween_all_completed", "_on_player_pokeball_particle_tween_completed", [particle, tween])

func _on_player_pokeball_particle_tween_completed(particle: Node, tween_node: Tween) -> void:
	if particle != null:
		particle.queue_free()
	if tween_node != null:
		tween_node.queue_free()

func _hide_player_pokeball_sprite() -> void:
	if player_pokeball_sprite != null:
		player_pokeball_sprite.visible = false

func _on_player_trainer_exit_tween_completed(exit_tween: Tween) -> void:
	if exit_tween != null:
		exit_tween.queue_free()
	player_trainer_exit_started = false
	if player_trainer_sprite != null:
		player_trainer_sprite.visible = false
		player_trainer_sprite.position = player_trainer_sprite_home_position
	if player_trainer_pokemon_revealed:
		player_trainer_choreo_playing = false
	_hide_player_pokeball_sprite()

func get_species_sprite_paths(species_id: String, is_back: bool) -> Dictionary:
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()

	if not catalog_loader.load_catalogs():
		log_debug("Catalog loader unavailable for sprite mapping: %s" % catalog_loader.get_last_error())
		return {}

	return catalog_loader.build_sprite_resource_paths(species_id, is_back)

func load_sprite_for_node(sprite_node: Sprite, sprite_relative_path: String, atlas_json: String) -> Array:
	var sprite_path = minimal_assets_path + sprite_relative_path
	var json_path = minimal_assets_path + atlas_json
	if not resource_exists(sprite_path):
		push_warning("Missing sprite texture: %s" % sprite_path)
		log_debug("Missing sprite texture: %s" % sprite_path)
		return []

	sprite_node.texture = load(sprite_path)
	sprite_node.centered = true
	sprite_node.region_enabled = true
	sprite_node.offset = Vector2.ZERO

	var loaded_frames = get_all_numeric_frames(json_path)
	if loaded_frames.empty():
		var fallback_frame = parse_sprite_frame(json_path, "0001.png")
		if fallback_frame != null:
			loaded_frames.append(fallback_frame)

	if not loaded_frames.empty():
		apply_sprite_frame(sprite_node, loaded_frames[0])
		log_debug("Loaded sprite atlas: %s frames=%d" % [json_path, loaded_frames.size()])
	else:
		# If atlas metadata is unavailable in export, render full texture so battlers stay visible.
		sprite_node.region_enabled = false
		sprite_node.offset = Vector2.ZERO
		push_warning("Missing atlas JSON or frames: %s" % json_path)
		log_debug("Missing atlas JSON or frames, full-texture fallback: %s" % json_path)

	return loaded_frames

func apply_sprite_frame(sprite_node: Sprite, sprite_info: Dictionary):
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
		if pokemon_sprite_anchor_mode == "bottom":
			anchor_y = float(source_size["h"])
		sprite_node.offset = Vector2(trimmed_cx - anchor_x, trimmed_cy - anchor_y)
	elif sprite_source_size != null:
		sprite_node.offset = Vector2(float(sprite_source_size["x"]), float(sprite_source_size["y"]))
	else:
		sprite_node.offset = Vector2.ZERO

func reset_pokemon_animation_state():
	player_anim_index = 0
	enemy_anim_index = 0
	player_anim_elapsed = 0.0
	enemy_anim_elapsed = 0.0
	player_trainer_choreo_elapsed = 0.0
	player_trainer_last_throw_index = -1
	player_trainer_pokemon_revealed = false
	player_trainer_choreo_playing = false
	player_trainer_exit_started = false
	player_pokeball_lob_started = false
	player_pokeball_release_done = false
	player_sendout_cry_played = false

	if not player_sprite_frames.empty():
		apply_sprite_frame(player_pokemon_sprite, player_sprite_frames[0])
	if player_pokemon_sprite != null:
		player_pokemon_sprite.scale = player_sprite_home_scale
		player_pokemon_sprite.modulate = Color(1, 1, 1, 1)
		player_pokemon_sprite.visible = true
	if not enemy_sprite_frames.empty():
		apply_sprite_frame(enemy_pokemon_sprite, enemy_sprite_frames[0])
	if player_trainer_enabled and not player_trainer_idle_frame.empty():
		_apply_trainer_frame(player_trainer_idle_frame)
	if player_trainer_sprite != null:
		player_trainer_sprite.visible = false
		player_trainer_sprite.position = player_trainer_sprite_home_position
	_hide_player_pokeball_sprite()

func update_pokemon_animations(delta: float):
	if not battle_fx_enabled:
		return

	if pokemon_anim_frame_sec <= 0.0:
		return

	# Player: loop sequence continuously.
	if player_sprite_anim_enabled and player_sprite_frames.size() > 1:
		player_anim_elapsed += delta
		while player_anim_elapsed >= pokemon_anim_frame_sec:
			player_anim_elapsed -= pokemon_anim_frame_sec
			player_anim_index = (player_anim_index + 1) % player_sprite_frames.size()
			apply_sprite_frame(player_pokemon_sprite, player_sprite_frames[player_anim_index])

	# Enemy: loop sequence continuously.
	if enemy_sprite_anim_enabled and enemy_sprite_frames.size() > 1:
		enemy_anim_elapsed += delta
		while enemy_anim_elapsed >= pokemon_anim_frame_sec:
			enemy_anim_elapsed -= pokemon_anim_frame_sec
			enemy_anim_index = (enemy_anim_index + 1) % enemy_sprite_frames.size()
			apply_sprite_frame(enemy_pokemon_sprite, enemy_sprite_frames[enemy_anim_index])
