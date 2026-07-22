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
export(float) var faint_to_party_prompt_delay_sec := 1.5
export(float) var enemy_switch_delay_sec := 0.9
export(float) var defeat_return_delay_sec := 1.3
export(float) var run_return_delay_sec := 0.6
export(float) var run_escape_fade_duration_sec := 0.28
export(int) var max_exp_level := 100
export(float) var exp_gain_multiplier := 1.0
export(int) var exp_override_value := -1
export(int) var debug_defeat_exp_override := 650
export(float) var exp_message_hold_sec := 1.05
export(bool) var exp_growth_debug_line_enabled := true
export(int) var debug_player_level_override := 15
export(float) var exp_bar_anim_duration_sec := 0.45
export(float) var exp_bar_level_up_pause_sec := 0.08
export(float) var party_exp_slide_duration_sec := 0.28
export(float) var party_exp_card_hold_sec := 0.45
export(bool) var debug_ohko_enabled := false
export(int, 1, 4) var debug_ohko_move_slot := 1
export(int) var debug_ohko_damage := 9999
export(float) var enemy_switch_slide_distance_px := 220.0
export(float) var enemy_switch_slide_duration_sec := 0.55
export(float) var enemy_panel_slide_distance_px := 180.0
export(float) var enemy_panel_slide_duration_sec := 0.55
export(float) var player_panel_switch_slide_distance_px := 180.0
export(float) var player_panel_switch_slide_duration_sec := 0.24
export(int) var biome_switch_every_levels := 3
export(int) var biome_switch_milestone_interval := 0
export(int) var biome_level_scale_floor_step := 2
export(int) var biome_level_scale_floor_bonus := 1
export(int) var biome_level_scale_trainer_bonus := 1
export(int) var biome_level_scale_boss_bonus := 2
export(float) var biome_level_scale_player_weight := 0.35
export(int) var biome_level_scale_min_level := 3
export(bool) var debug_damage_calculation_enabled := true
export(bool) var debug_pp_override_second_move_one := false
export(bool) var debug_pp_override_all_moves_one := false
export(int) var normal_trainer_encounter_every := 5
export(int) var boss_pokemon_encounter_every := 10
export(int) var boss_trainer_encounter_every := 30
export(bool) var force_first_encounter_trainer := true
export(bool) var debug_force_second_encounter_trainer := false
export(bool) var debug_enemy_sprite_cycle_enabled := false
export(float) var debug_enemy_sprite_cycle_interval_sec := 3.0
export(bool) var debug_enemy_sprite_cycle_play_cries := false
export(bool) var debug_player_sprite_cycle_enabled := false
export(float) var debug_player_sprite_cycle_interval_sec := 3.0
export(bool) var debug_player_sprite_cycle_play_cries := false
export(bool) var debug_player_sprite_cycle_capture_screenshots := false
export(bool) var debug_enemy_baseline_overlay_enabled := true
export(bool) var debug_enemy_sprite_bounds_logging_enabled := false
export(float) var debug_enemy_sprite_bounds_log_interval_sec := 1.0
export(float) var debug_enemy_sprite_bounds_too_low_px := 2.0
export(float) var debug_enemy_sprite_bounds_too_high_px := 16.0
export(bool) var debug_enemy_sprite_bounds_capture_suspicious := false
export(float) var debug_enemy_sprite_bounds_capture_cooldown_sec := 2.0
export(String) var debug_enemy_sprite_bounds_capture_dir := "user://enemy_sprite_snapshots"
export(float) var arena_switch_blend_duration_sec := 0.22
export(float) var biome_transition_restore_message_hold_sec := 0.8
export(float) var biome_transition_post_recall_delay_sec := 0.12
export(float) var biome_transition_post_reentry_delay_sec := 0.18
export(float) var biome_transition_fade_out_duration_sec := 0.3
export(float) var biome_transition_blackout_hold_sec := 0.45
export(float) var biome_transition_fade_in_duration_sec := 0.24
export(float) var biome_transition_post_fade_in_delay_sec := 0.12
export(float) var biome_bgm_crossfade_duration_sec := 0.75
export(float) var biome_bgm_volume_db := 0.0
export(float) var scene_change_bgm_fade_out_sec := 0.35
export(Array, String) var biome_test_arena_rotation := ["grass", "metropolis", "abyss", "beach", "cave", "mountains", "temple", "volcano"]
export(bool) var debug_open_party_menu_on_ready := false
export(bool) var debug_transition_checkpoints := true
export(float) var party_menu_overlay_fade_duration_sec := 0.12
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
export(bool) var enemy_trainer_intro_enabled := true
export(float) var enemy_trainer_intro_text_hold_sec := 1.5
export(float) var enemy_trainer_intro_slide_duration_sec := 0.3
export(float) var enemy_trainer_intro_slide_distance_px := 90.0
export(float) var enemy_trainer_sent_out_text_hold_sec := 1.5
export(float) var enemy_trainer_exit_duration_sec := 0.75
export(float) var enemy_trainer_exit_distance_px := 110.0
export(float) var enemy_trainer_exit_offset_x := 16.0
export(float) var enemy_trainer_exit_offset_y := -16.0
export(float) var enemy_trainer_exit_alpha := 0.0
export(float) var enemy_pokeball_start_offset_x := -6.0
export(float) var enemy_pokeball_start_offset_y := -36.0
export(float) var enemy_pokeball_target_offset_x := -4.0
export(float) var enemy_pokeball_target_offset_y := -32.0
export(float) var enemy_pokeball_arc_height_px := 33.0
export(float) var enemy_pokeball_lob_duration_sec := 0.55
export(float) var enemy_pokeball_lob_up_duration_sec := 0.15
export(float) var enemy_pokeball_spin_degrees := -720.0
export(float) var enemy_pokeball_opening_hold_sec := 0.06
export(float) var enemy_pokeball_open_hold_sec := 0.08
export(float) var enemy_pokemon_reveal_scale_duration_sec := 0.2
export(float) var enemy_pokemon_reveal_flash_duration_sec := 0.16
export(float) var enemy_pokemon_reveal_start_scale := 0.55
export(float) var enemy_pokemon_reveal_alpha_start := 0.0
export(Color) var enemy_pokemon_reveal_tint_color := Color(1.0, 0.88, 0.88, 1.0)
export(float) var enemy_pokemon_reveal_to_player_delay_sec := 0.2
export(float) var trainer_defeat_text_hold_sec := 0.9
export(float) var trainer_victory_transition_slide_distance_px := 220.0
export(float) var trainer_victory_transition_duration_sec := 0.55
export(float) var player_trainer_victory_return_duration_sec := 0.75
export(float) var player_trainer_victory_return_offset_x := 16.0
export(float) var player_trainer_victory_return_offset_y := -16.0
export(float) var trainer_pb_panel_slide_distance_px := 120.0
export(float) var trainer_pb_panel_slide_duration_sec := 0.25
export(float) var trainer_pb_panel_hold_sec := 1.5
export(float) var trainer_pb_ball_spacing_px := 8.0
export(int) var trainer_pb_tray_slot_count := 6
export(int) var trainer_pb_player_active_count := 1
export(int) var trainer_pb_enemy_active_count := 2
const SELECTED_SPECIES_META_KEY := "selected_species_id"
const MAIN_SCENE_PATH := "res://scenes/MainScreen.tscn"
const ENCOUNTER_ARCHETYPE_NORMAL_POKEMON := "normal_pokemon"
const ENCOUNTER_ARCHETYPE_BOSS_POKEMON := "boss_pokemon"
const ENCOUNTER_ARCHETYPE_NORMAL_TRAINER := "normal_trainer"
const ENCOUNTER_ARCHETYPE_BOSS_TRAINER := "boss_trainer"
const ENCOUNTER_TYPE_WILD := "wild"
const ENCOUNTER_TYPE_TRAINER := "trainer"
const ATTACK_TYPE_TEXTURE_REL := "assets/images/types.png"
const ATTACK_TYPE_ATLAS_REL := "assets/images/types.json"
const ICON_TEXTURE_TEMPLATE := "res://godot-minimal-assets/assets/images/pokemon_icons_%d.png"
const ICON_ATLAS_TEMPLATE := "res://godot-minimal-assets/assets/images/pokemon_icons_%d.json"
const ICON_FALLBACK_ATLAS_INDEX := 0
const ICON_DEFAULT_FRAME := "unknown"
const OWNED_ICON_TEXTURE_REL := "assets/images/ui/icon_owned.png"
const ATTACK_CATEGORY_TEXTURE_REL := "assets/images/categories.png"
const ATTACK_CATEGORY_ATLAS_REL := "assets/images/categories.json"
const PLAYER_TRAINER_BACK_TEXTURE_REL := "assets/images/trainer/trainer_m_back.png"
const PLAYER_TRAINER_BACK_ATLAS_REL := "assets/images/trainer/trainer_m_back.json"
const PLAYER_TRAINER_BACK_PB_TEXTURE_REL := "assets/images/trainer/trainer_m_back_pb.png"
const PLAYER_TRAINER_BACK_PB_ATLAS_REL := "assets/images/trainer/trainer_m_back_pb.json"
const TRAINERS_CATALOG_PATH := "res://data/trainers.v1.json"
const PB_TRAY_BALL_TEXTURE_REL := "assets/images/ui/pb_tray_ball.png"
const PB_TRAY_BALL_ATLAS_REL := "assets/images/ui/pb_tray_ball.json"
const PB_TRAY_BALL_FRAME_FILLED := "ball"
const PB_TRAY_BALL_FRAME_EMPTY := "empty"
const PB_TRAY_BALL_FRAME_FAINT := "faint"
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
const MoveData = preload("res://data/MoveData.gd")
var pokemon_data_script = load("res://data/PokemonData.gd")
var battle_calc_script = load("res://logic/BattleCalc.gd")
var catalog_loader_script = load("res://logic/CatalogDataLoader.gd")
var runtime_state_script = load("res://logic/RuntimeState.gd")
var battle_phase_runner_script = load("res://logic/BattlePhaseRunner.gd")
var encounter_transition_intro_phase_script = load("res://logic/phases/EncounterTransitionIntroPhase.gd")
var encounter_transition_seed_load_phase_script = load("res://logic/phases/EncounterTransitionSeedLoadPhase.gd")
var biome_transition_party_restore_phase_script = load("res://logic/phases/BiomeTransitionPartyRestorePhase.gd")
var encounter_transition_presentation_phase_script = load("res://logic/phases/EncounterTransitionPresentationPhase.gd")
var encounter_transition_finalize_phase_script = load("res://logic/phases/EncounterTransitionFinalizePhase.gd")
var opening_prepare_phase_script = load("res://logic/phases/OpeningPreparePhase.gd")
var opening_slide_phase_script = load("res://logic/phases/OpeningSlidePhase.gd")
var opening_resolve_phase_script = load("res://logic/phases/OpeningResolvePhase.gd")
var turn_command_resolve_phase_script = load("res://logic/phases/TurnCommandResolvePhase.gd")
var turn_player_move_phase_script = load("res://logic/phases/TurnPlayerMovePhase.gd")
var turn_enemy_move_phase_script = load("res://logic/phases/TurnEnemyMovePhase.gd")
var turn_faint_resolve_phase_script = load("res://logic/phases/TurnFaintResolvePhase.gd")
var turn_player_defeat_gate_phase_script = load("res://logic/phases/TurnPlayerDefeatGatePhase.gd")
var turn_forced_switch_prompt_phase_script = load("res://logic/phases/TurnForcedSwitchPromptPhase.gd")
var turn_game_over_phase_script = load("res://logic/phases/TurnGameOverPhase.gd")
var turn_end_unlock_phase_script = load("res://logic/phases/TurnEndUnlockPhase.gd")
var exp_resolve_phase_script = load("res://logic/phases/ExpResolvePhase.gd")
var exp_apply_phase_script = load("res://logic/phases/ExpApplyPhase.gd")
var exp_evolution_phase_script = load("res://logic/phases/ExpEvolutionPhase.gd")
var exp_party_apply_phase_script = load("res://logic/phases/ExpPartyApplyPhase.gd")
var exp_party_evolution_phase_script = load("res://logic/phases/ExpPartyEvolutionPhase.gd")
var run_resolve_phase_script = load("res://logic/phases/RunResolvePhase.gd")
var run_finalize_phase_script = load("res://logic/phases/RunFinalizePhase.gd")
var capture_begin_phase_script = load("res://logic/phases/CaptureBeginPhase.gd")
var capture_sequence_phase_script = load("res://logic/phases/CaptureSequencePhase.gd")
var capture_post_encounter_phase_script = load("res://logic/phases/CapturePostEncounterPhase.gd")
var party_menu_scene = preload("res://scenes/PartyMenuOverlay.tscn")
var pokedex_overlay_scene = load("res://scenes/PokedexEntryOverlay.tscn")
var pokemon_evolution_overlay_scene = load("res://scenes/PokemonEvolutionOverlay.tscn")

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
onready var enemy_trainer_pb_panel = ui_layer.get_node_or_null("EnemyTrainerPBPanel") if ui_layer != null else null
onready var player_trainer_pb_panel = ui_layer.get_node_or_null("PlayerTrainerPBPanel") if ui_layer != null else null
onready var enemy_trainer_pb_tray_sprite = enemy_trainer_pb_panel.get_node_or_null("PBTraySprite") if enemy_trainer_pb_panel != null else null
onready var player_trainer_pb_tray_sprite = player_trainer_pb_panel.get_node_or_null("PBTraySprite") if player_trainer_pb_panel != null else null
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
onready var enemy_caught_badge_sprite = enemy_panel.get_node_or_null("EnemyCaughtBadgeSprite") if enemy_panel != null else null
onready var enemy_layer = battlefield_layer.get_node_or_null("EnemyLayer") if battlefield_layer != null else null
onready var enemy_arena_sprite = enemy_layer.get_node_or_null("EnemyArenaSprite") if enemy_layer != null else null
onready var enemy_arena_sprite_1 = enemy_layer.get_node_or_null("EnemyArenaSprite1") if enemy_layer != null else null
onready var enemy_arena_sprite_2 = enemy_layer.get_node_or_null("EnemyArenaSprite2") if enemy_layer != null else null
onready var enemy_arena_sprite_3 = enemy_layer.get_node_or_null("EnemyArenaSprite3") if enemy_layer != null else null
onready var enemy_pokemon_sprite = enemy_layer.get_node_or_null("EnemyPokemonSpriteBattle") if enemy_layer != null else null
onready var enemy_trainer_sprite = enemy_layer.get_node_or_null("EnemyTrainerSprite") if enemy_layer != null else null
onready var effects_layer = battlefield_layer.get_node_or_null("EffectsLayer") if battlefield_layer != null else null
onready var player_name_label = player_panel.get_node_or_null("PlayerNameLabel") if player_panel != null else null
onready var player_level_label = player_panel.get_node_or_null("PlayerLevelLabel") if player_panel != null else null
onready var player_exp_value_label = player_panel.get_node_or_null("PlayerExpValueLabel") if player_panel != null else null
onready var player_exp_bar = player_panel.get_node_or_null("PlayerExpBar") if player_panel != null else null
onready var party_exp_container = ui_layer.get_node_or_null("PartyExpContainer") if ui_layer != null else null
onready var party_exp_bar_sprite = party_exp_container.get_node_or_null("PartyExpBarSprite") if party_exp_container != null else null
onready var party_exp_icon_sprite = party_exp_container.get_node_or_null("PokemonIconSprite") if party_exp_container != null else null
onready var party_exp_label = _resolve_first_existing([
	"UiScaleRoot/UILayer/PartyExpContainer/PartyExpLabel",
	"UiScaleRoot/UILayer/PartyExpContainer/PartyExpLabelLabel",
	"UILayer/PartyExpContainer/PartyExpLabel",
	"UILayer/PartyExpContainer/PartyExpLabelLabel",
])
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
var biome_wild_pool_catalog_path = "res://data/biome-wild-pools.v1.json"
var biome_trainer_rules_catalog_path = "res://data/biome-trainer-rules.v1.json"
var biome_route_graph_catalog_path = "res://data/biome-route-graph.v1.json"
var biome_wild_pool_catalog := {}
var biome_wild_pool_catalog_loaded := false
var biome_trainer_rules_catalog := {}
var biome_trainer_rules_catalog_loaded := false
var biome_route_graph_catalog := {}
var biome_route_graph_catalog_loaded := false
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
var suppress_arena_bgm_apply := false
var transition_fade_overlay: ColorRect = null
var transition_fade_tween: Tween = null
var party_menu_fade_tween: Tween = null
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
var battlefield_layer_home_position := Vector2.ZERO
var player_panel_home_position := Vector2.ZERO
var enemy_panel_home_position := Vector2.ZERO
var enemy_trainer_pb_panel_home_position := Vector2.ZERO
var player_trainer_pb_panel_home_position := Vector2.ZERO
var player_sprite_home_position := Vector2.ZERO
var player_sprite_home_scale := Vector2.ONE
var enemy_sprite_home_position := Vector2.ZERO
var enemy_sprite_home_scale := Vector2.ONE
var enemy_panel_tween: Tween = null
var player_panel_switch_tween: Tween = null
var enemy_trainer_pb_panel_tween: Tween = null
var player_trainer_pb_panel_tween: Tween = null
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
var enemy_trainer_sprite_home_position := Vector2.ZERO
var enemy_trainer_texture_front = null
var enemy_trainer_idle_frame := {}
var pb_tray_ball_texture = null
var pb_tray_ball_frame_rects := {}
var pb_tray_ball_atlas_textures := {}
var player_pokeball_sprite = null
var enemy_pokeball_sprite = null
var player_pokeball_lob_started := false
var player_pokeball_release_done := false
var player_sendout_cry_played := false
var player_sendout_cry_key := ""
var player_cry_audio_player: AudioStreamPlayer = null
var enemy_sendout_cry_key := ""
var enemy_cry_audio_player: AudioStreamPlayer = null
var last_player_cry_key := ""
var last_player_cry_played_at_msec := -1
var last_enemy_cry_key := ""
var last_enemy_cry_played_at_msec := -1
const SENDOUT_CRY_DEDUPE_WINDOW_MSEC := 250
var pokeball_particles_texture = null
var pokeball_particles_frames := []
var pokeball_open_particle_sprite_frames: SpriteFrames = null
var catalog_loader = null
var selected_player_species_id := ""
var attack_menu_visible := false
var ball_menu_visible := false
var party_menu_visible := false
var party_menu_overlay = null
var pokedex_overlay = null
var pokedex_overlay_visible := false
var pokemon_evolution_overlay = null
var pokemon_evolution_overlay_visible := false
var pokedex_return_to_party_menu := false
var enemy_species_pool := []
var trainers_catalog_by_id := {}
var trainers_catalog_ordered := []
var ball_inventory := BALL_DEFAULT_COUNTS.duplicate(true)
var capture_in_progress := false
var sendout_controls_locked := false
var forced_switch_pending := false
var forced_switch_active_turn_token := -1
var forced_switch_success := false
var transition_run_counter := 0
var active_transition_run_id := ""
var opening_run_counter := 0
var active_opening_run_id := ""
var turn_run_counter := 0
var active_turn_run_id := ""
var capture_run_counter := 0
var active_capture_run_id := ""
var debug_enemy_sprite_cycle_species_ids := []
var debug_enemy_sprite_cycle_index := -1
var debug_enemy_sprite_cycle_elapsed := 0.0
var debug_enemy_sprite_cycle_running := false
var debug_enemy_sprite_cycle_completed := false
var debug_player_sprite_cycle_species_ids := []
var debug_player_sprite_cycle_index := -1
var debug_player_sprite_cycle_elapsed := 0.0
var debug_player_sprite_cycle_running := false
var debug_player_sprite_cycle_completed := false
var debug_enemy_baseline_overlay: ColorRect = null
var debug_enemy_sprite_bounds_log_elapsed := 0.0
var debug_enemy_sprite_bounds_last_capture_msec := -1
var party_exp_container_shown_position := Vector2.ZERO
var party_exp_container_hidden_position := Vector2.ZERO
var party_exp_container_right_anchor_x := 0.0
var party_exp_container_base_width := 0.0
var party_exp_container_base_height := 0.0
var party_exp_label_base_height := 0.0
var party_exp_icon_base_y := 0.0

# Lifecycle and diagnostics.
func _ready():
	if ui_scale_root != null:
		ui_scale_root.rect_scale = Vector2(ui_scale, ui_scale)
	if not _validate_required_refs():
		return
	randomize()
	log_debug("Battle scene ready")
	log_debug("Using minimal assets path: %s" % minimal_assets_path)
	_validate_encounter_cadence_settings()
	update_run_button_label()
	battlefield_layer_home_position = battlefield_layer.rect_position
	enemy_layer_home_position = enemy_layer.rect_position
	player_panel_home_position = player_panel.rect_position
	enemy_panel_home_position = enemy_panel.rect_position
	if enemy_trainer_pb_panel != null:
		enemy_trainer_pb_panel_home_position = enemy_trainer_pb_panel.rect_position
		enemy_trainer_pb_panel.visible = false
	if player_trainer_pb_panel != null:
		player_trainer_pb_panel_home_position = player_trainer_pb_panel.rect_position
		player_trainer_pb_panel.visible = false
	player_sprite_home_position = player_pokemon_sprite.position
	player_sprite_home_scale = player_pokemon_sprite.scale
	enemy_sprite_home_position = enemy_pokemon_sprite.position
	enemy_sprite_home_scale = enemy_pokemon_sprite.scale
	if enemy_trainer_sprite != null:
		enemy_trainer_sprite_home_position = enemy_trainer_sprite.position
	if player_trainer_sprite != null:
		player_trainer_sprite_home_position = player_trainer_sprite.position
	build_hp_overlay_frames()
	load_audio_assets()
	setup_type_sprite_placeholders()
	setup_attack_detail_sprites()
	_setup_transition_fade_overlay()
	_setup_party_exp_container()
	setup_party_menu_overlay()
	setup_pokedex_overlay()
	setup_pokemon_evolution_overlay()
	reset_battle_state("Battle ready.")
	if ball_menu_container != null:
		ball_menu_container.visible = false
	refresh_ball_menu_layout()

	add_blend_material = CanvasItemMaterial.new()
	add_blend_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	setup_keyboard_controls()
	if debug_enemy_baseline_overlay_enabled:
		_ensure_debug_enemy_baseline_overlay()
		_update_debug_enemy_baseline_overlay()
	if debug_enemy_sprite_cycle_enabled:
		_init_debug_enemy_sprite_cycle()
	if debug_player_sprite_cycle_enabled:
		_init_debug_player_sprite_cycle()
	if debug_open_party_menu_on_ready:
		call_deferred("_open_party_menu_on_ready")

func _open_party_menu_on_ready():
	if turn_in_progress or battle_ended:
		return
	open_party_menu()

func _setup_party_exp_container() -> void:
	if party_exp_container == null:
		return
	party_exp_container_shown_position = party_exp_container.rect_position
	party_exp_container_base_width = max(1.0, max(party_exp_container.rect_size.x, party_exp_container.rect_min_size.x))
	if party_exp_container_base_width <= 1.0:
		party_exp_container_base_width = max(1.0, party_exp_container.get_combined_minimum_size().x)
	party_exp_container_base_height = max(1.0, max(party_exp_container.rect_size.y, party_exp_container.rect_min_size.y))
	if party_exp_container_base_height <= 1.0:
		party_exp_container_base_height = max(1.0, party_exp_container.get_combined_minimum_size().y)
	party_exp_container_right_anchor_x = party_exp_container_shown_position.x + party_exp_container_base_width
	if party_exp_label != null:
		party_exp_label.align = Label.ALIGN_RIGHT
		party_exp_label_base_height = max(1.0, party_exp_label.rect_size.y)
	if party_exp_icon_sprite != null:
		party_exp_icon_base_y = party_exp_icon_sprite.position.y
	party_exp_container_hidden_position = Vector2(party_exp_container_right_anchor_x + 8.0, party_exp_container_shown_position.y)
	party_exp_container.rect_position = party_exp_container_hidden_position
	party_exp_container.visible = false

func log_debug(message: String):
	print("[Battle] %s" % message)

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

func _log_transition_checkpoint(label: String, details: Dictionary = {}) -> void:
	if not debug_transition_checkpoints:
		return
	var message = "Transition checkpoint: " + label
	if not active_transition_run_id.empty():
		message += " | run_id=%s" % active_transition_run_id
	if typeof(details) == TYPE_DICTIONARY:
		for key in details.keys():
			message += " | %s=%s" % [String(key), String(details[key])]
	log_debug(message)

func _next_transition_run_id() -> String:
	transition_run_counter += 1
	return "tx-%s" % String(transition_run_counter)

func _log_opening_checkpoint(label: String, details: Dictionary = {}) -> void:
	if not debug_transition_checkpoints:
		return
	var message = "Opening checkpoint: " + label
	if not active_opening_run_id.empty():
		message += " | run_id=%s" % active_opening_run_id
	if typeof(details) == TYPE_DICTIONARY:
		for key in details.keys():
			message += " | %s=%s" % [String(key), String(details[key])]
	log_debug(message)

func _next_opening_run_id() -> String:
	opening_run_counter += 1
	return "op-%s" % String(opening_run_counter)

func _log_turn_checkpoint(label: String, details: Dictionary = {}) -> void:
	if not debug_transition_checkpoints:
		return
	var message = "Turn checkpoint: " + label
	if not active_turn_run_id.empty():
		message += " | run_id=%s" % active_turn_run_id
	if typeof(details) == TYPE_DICTIONARY:
		for key in details.keys():
			message += " | %s=%s" % [String(key), String(details[key])]
	log_debug(message)

func _next_turn_run_id() -> String:
	turn_run_counter += 1
	return "tr-%s" % String(turn_run_counter)

func _log_capture_checkpoint(label: String, details: Dictionary = {}) -> void:
	if not debug_transition_checkpoints:
		return
	var message = "Capture checkpoint: " + label
	if not active_capture_run_id.empty():
		message += " | run_id=%s" % active_capture_run_id
	if typeof(details) == TYPE_DICTIONARY:
		for key in details.keys():
			message += " | %s=%s" % [String(key), String(details[key])]
	log_debug(message)

func _next_capture_run_id() -> String:
	capture_run_counter += 1
	return "cp-%s" % String(capture_run_counter)

func _log_biome_route_decision_checkpoint(biome_state: Dictionary) -> void:
	if not debug_transition_checkpoints:
		return
	if typeof(biome_state) != TYPE_DICTIONARY:
		return
	var route_decision = biome_state.get("route_decision", {})
	if typeof(route_decision) != TYPE_DICTIONARY:
		return

	if not bool(route_decision.get("switch_boundary_reached", false)):
		_log_transition_checkpoint("biome_route.skipped_no_switch", {
			"current_biome_id": String(route_decision.get("current_biome_id", biome_state.get("current_biome_id", ""))),
			"floor_index": int(biome_state.get("floor_index", biome_state.get("encounter_index", 0))),
		})
		return

	var candidates = route_decision.get("candidates", [])
	var candidate_count = candidates.size() if typeof(candidates) == TYPE_ARRAY else 0
	_log_transition_checkpoint("biome_route.candidates", {
		"policy_id": String(route_decision.get("policy_id", "rotation_links_v1")),
		"current_biome_id": String(route_decision.get("current_biome_id", biome_state.get("current_biome_id", ""))),
		"candidate_count": candidate_count,
		"candidates": String(candidates),
	})
	_log_transition_checkpoint("biome_route.selected", {
		"selected_biome_id": String(route_decision.get("selected_biome_id", biome_state.get("current_biome_id", ""))),
		"roll_seed": int(route_decision.get("roll_seed", 0)),
		"roll_index": int(route_decision.get("roll_index", 0)),
		"route_roll_counter": int(route_decision.get("route_roll_counter", 0)),
	})
	if bool(route_decision.get("fallback_used", false)):
		_log_transition_checkpoint("biome_route.fallback", {
			"fallback_reason": String(route_decision.get("fallback_reason", "")),
			"selected_biome_id": String(route_decision.get("selected_biome_id", biome_state.get("current_biome_id", ""))),
		})

func _log_biome_trainer_decision_checkpoint(encounter_meta: Dictionary) -> void:
	if not debug_transition_checkpoints:
		return
	if typeof(encounter_meta) != TYPE_DICTIONARY:
		return
	var trainer_decision = encounter_meta.get("trainer_decision", {})
	if typeof(trainer_decision) != TYPE_DICTIONARY or trainer_decision.empty():
		return

	_log_transition_checkpoint("biome_trainer.roll", {
		"biome_id": String(encounter_meta.get("biome_id", "")),
		"encounter_number": int(encounter_meta.get("encounter_number", 0)),
		"roll_seed": int(trainer_decision.get("roll_seed", 0)),
		"roll_value": int(trainer_decision.get("roll_value", 0)),
		"threshold_percent": int(trainer_decision.get("threshold_percent", 0)),
		"selected": bool(trainer_decision.get("selected", false)),
		"reason": String(trainer_decision.get("reason", "")),
	})
	_log_transition_checkpoint("biome_trainer.pool", {
		"trainer_pool_kind": String(trainer_decision.get("trainer_pool_kind", "")),
		"candidate_count": int(trainer_decision.get("candidate_count", 0)),
		"candidate_ids": String(trainer_decision.get("candidate_ids", [])),
		"pool_source": String(trainer_decision.get("pool_source", "")),
	})
	if bool(trainer_decision.get("fallback_used", false)):
		_log_transition_checkpoint("biome_trainer.fallback", {
			"fallback_reason": String(trainer_decision.get("fallback_reason", "")),
			"candidate_ids": String(trainer_decision.get("candidate_ids", [])),
		})

func _validate_encounter_cadence_settings() -> void:
	if force_first_encounter_trainer:
		log_debug("Encounter cadence: forcing encounter #1 to normal trainer for test flow.")

	if normal_trainer_encounter_every <= 0:
		log_debug("Encounter cadence: normal_trainer_encounter_every disabled (<= 0).")
	if boss_pokemon_encounter_every <= 0:
		log_debug("Encounter cadence: boss_pokemon_encounter_every disabled (<= 0).")
	if boss_trainer_encounter_every <= 0:
		log_debug("Encounter cadence: boss_trainer_encounter_every disabled (<= 0).")

	if normal_trainer_encounter_every > 0 and boss_trainer_encounter_every > 0 and boss_trainer_encounter_every % normal_trainer_encounter_every == 0:
		log_debug("Encounter cadence: boss trainer cadence overrides normal trainer cadence on overlapping encounters.")

	if boss_pokemon_encounter_every > 0 and boss_trainer_encounter_every > 0 and boss_trainer_encounter_every % boss_pokemon_encounter_every == 0:
		log_debug("Encounter cadence: boss trainer cadence overrides boss pokemon cadence on overlapping encounters.")

	if normal_trainer_encounter_every == 1:
		log_debug("Encounter cadence: normal trainers are configured for every encounter (except higher-priority boss cadence).")

func _load_trainers_catalog_if_needed() -> bool:
	if not trainers_catalog_by_id.empty():
		return true

	var payload = _read_json_payload(TRAINERS_CATALOG_PATH)
	if typeof(payload) != TYPE_DICTIONARY:
		log_debug("Trainer catalog load failed: payload missing or invalid at %s" % TRAINERS_CATALOG_PATH)
		return false

	var items = payload.get("items", [])
	if typeof(items) != TYPE_ARRAY:
		log_debug("Trainer catalog load failed: items array missing in %s" % TRAINERS_CATALOG_PATH)
		return false

	for item in items:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var trainer_id = String(item.get("trainer_id", "")).strip_edges().to_upper()
		if trainer_id.empty():
			continue
		var trainer_entry = item.duplicate(true)
		trainers_catalog_by_id[trainer_id] = trainer_entry
		trainers_catalog_ordered.append(trainer_entry)

	if trainers_catalog_by_id.empty():
		log_debug("Trainer catalog load failed: no valid trainer entries in %s" % TRAINERS_CATALOG_PATH)
		return false

	log_debug("Trainer catalog loaded: %d trainer(s)." % trainers_catalog_by_id.size())
	return true

func _normalize_trainer_party_members(raw_members) -> Array:
	if typeof(raw_members) != TYPE_ARRAY:
		return []

	var indexed_members := []
	for raw_member in raw_members:
		if typeof(raw_member) != TYPE_DICTIONARY:
			continue
		var species_id = String(raw_member.get("species_id", "")).strip_edges().to_upper()
		if species_id.empty():
			continue
		indexed_members.append({
			"slot_index": int(raw_member.get("slot_index", indexed_members.size())),
			"member": raw_member.duplicate(true),
		})

	indexed_members.sort_custom(self, "_sort_trainer_member_slot")

	var normalized := []
	for entry in indexed_members:
		normalized.append(entry.get("member", {}).duplicate(true))
	return normalized

func _sort_trainer_member_slot(a: Dictionary, b: Dictionary) -> bool:
	return int(a.get("slot_index", 0)) < int(b.get("slot_index", 0))

func _find_trainer_for_encounter(encounter_meta: Dictionary) -> Dictionary:
	if not _load_trainers_catalog_if_needed():
		return {}

	var encounter_number = int(encounter_meta.get("encounter_number", 0))
	if debug_force_second_encounter_trainer and encounter_number == 2:
		var ordered_trainers := []
		for trainer_entry in trainers_catalog_ordered:
			if typeof(trainer_entry) != TYPE_DICTIONARY:
				continue
			if String(trainer_entry.get("encounter_type", "")).strip_edges().to_lower() != ENCOUNTER_TYPE_TRAINER:
				continue
			var trainer_party = _normalize_trainer_party_members(trainer_entry.get("party_members", []))
			if trainer_party.empty():
				continue
			ordered_trainers.append(trainer_entry)
		if ordered_trainers.size() >= 2:
			return ordered_trainers[1].duplicate(true)

	var wants_boss = bool(encounter_meta.get("is_boss_encounter", false))
	var allowed_trainer_ids := []
	var trainer_decision = encounter_meta.get("trainer_decision", {})
	if typeof(trainer_decision) == TYPE_DICTIONARY:
		var raw_allowed_ids = trainer_decision.get("candidate_ids", [])
		if typeof(raw_allowed_ids) == TYPE_ARRAY:
			for raw_trainer_id in raw_allowed_ids:
				var allowed_trainer_id = String(raw_trainer_id).strip_edges().to_upper()
				if allowed_trainer_id.empty() or allowed_trainer_ids.has(allowed_trainer_id):
					continue
				allowed_trainer_ids.append(allowed_trainer_id)
	var matches := []
	for trainer_id in trainers_catalog_by_id.keys():
		if not allowed_trainer_ids.empty() and not allowed_trainer_ids.has(String(trainer_id).strip_edges().to_upper()):
			continue
		var trainer_entry = trainers_catalog_by_id[trainer_id]
		if typeof(trainer_entry) != TYPE_DICTIONARY:
			continue
		if String(trainer_entry.get("encounter_type", "")).strip_edges().to_lower() != ENCOUNTER_TYPE_TRAINER:
			continue
		var trainer_is_boss = bool(trainer_entry.get("is_boss", false))
		if trainer_is_boss != wants_boss:
			continue
		var party_members = _normalize_trainer_party_members(trainer_entry.get("party_members", []))
		if party_members.empty():
			continue
		matches.append(trainer_entry)

	if matches.empty():
		for trainer_id in trainers_catalog_by_id.keys():
			if not allowed_trainer_ids.empty() and not allowed_trainer_ids.has(String(trainer_id).strip_edges().to_upper()):
				continue
			var fallback_entry = trainers_catalog_by_id[trainer_id]
			if typeof(fallback_entry) != TYPE_DICTIONARY:
				continue
			if String(fallback_entry.get("encounter_type", "")).strip_edges().to_lower() != ENCOUNTER_TYPE_TRAINER:
				continue
			var fallback_party = _normalize_trainer_party_members(fallback_entry.get("party_members", []))
			if fallback_party.empty():
				continue
			matches.append(fallback_entry)

	if matches.empty():
		return {}

	matches.sort_custom(self, "_sort_trainer_id")
	return matches[0].duplicate(true)

func _sort_trainer_id(a: Dictionary, b: Dictionary) -> bool:
	var a_id = String(a.get("trainer_id", "")).strip_edges().to_upper()
	var b_id = String(b.get("trainer_id", "")).strip_edges().to_upper()
	return a_id < b_id

func _trainer_pb_panel_enemy_hidden_position() -> Vector2:
	return enemy_trainer_pb_panel_home_position + Vector2(-trainer_pb_panel_slide_distance_px, 0)

func _trainer_pb_panel_player_hidden_position() -> Vector2:
	return player_trainer_pb_panel_home_position + Vector2(trainer_pb_panel_slide_distance_px, 0)

func _stop_trainer_pb_panel_tween(is_enemy_panel: bool) -> void:
	var tween_ref = enemy_trainer_pb_panel_tween if is_enemy_panel else player_trainer_pb_panel_tween
	if tween_ref != null and is_instance_valid(tween_ref):
		tween_ref.stop_all()
		tween_ref.queue_free()
	if is_enemy_panel:
		enemy_trainer_pb_panel_tween = null
	else:
		player_trainer_pb_panel_tween = null

func _animate_trainer_pb_panel_to(is_enemy_panel: bool, target_position: Vector2, duration_sec: float):
	var panel = enemy_trainer_pb_panel if is_enemy_panel else player_trainer_pb_panel
	if panel == null:
		return null

	_stop_trainer_pb_panel_tween(is_enemy_panel)
	if duration_sec <= 0.0:
		panel.rect_position = target_position
		return null

	var tween_ref = Tween.new()
	add_child(tween_ref)
	tween_ref.interpolate_property(
		panel,
		"rect_position",
		panel.rect_position,
		target_position,
		duration_sec,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	tween_ref.start()
	if is_enemy_panel:
		enemy_trainer_pb_panel_tween = tween_ref
	else:
		player_trainer_pb_panel_tween = tween_ref
	yield(tween_ref, "tween_all_completed")

	if tween_ref != null and is_instance_valid(tween_ref):
		tween_ref.queue_free()
	if is_enemy_panel:
		enemy_trainer_pb_panel_tween = null
	else:
		player_trainer_pb_panel_tween = null

	panel.rect_position = target_position
	return null

func _ensure_pb_tray_ball_assets() -> bool:
	if pb_tray_ball_texture != null and not pb_tray_ball_frame_rects.empty():
		return true

	var texture_path = minimal_assets_path + PB_TRAY_BALL_TEXTURE_REL
	var atlas_path = minimal_assets_path + PB_TRAY_BALL_ATLAS_REL
	if not resource_exists(texture_path):
		return false

	pb_tray_ball_texture = load(texture_path)
	var ball_frame = parse_sprite_frame(atlas_path, PB_TRAY_BALL_FRAME_FILLED)
	var empty_frame = parse_sprite_frame(atlas_path, PB_TRAY_BALL_FRAME_EMPTY)
	var faint_frame = parse_sprite_frame(atlas_path, PB_TRAY_BALL_FRAME_FAINT)
	if ball_frame == null or empty_frame == null:
		return false

	var bf = ball_frame.get("frame", {})
	var ef = empty_frame.get("frame", {})
	var ff = ef
	if faint_frame != null:
		ff = faint_frame.get("frame", {})
	pb_tray_ball_frame_rects[PB_TRAY_BALL_FRAME_FILLED] = Rect2(bf.get("x", 0), bf.get("y", 0), bf.get("w", 7), bf.get("h", 7))
	pb_tray_ball_frame_rects[PB_TRAY_BALL_FRAME_EMPTY] = Rect2(ef.get("x", 0), ef.get("y", 0), ef.get("w", 7), ef.get("h", 7))
	pb_tray_ball_frame_rects[PB_TRAY_BALL_FRAME_FAINT] = Rect2(ff.get("x", 0), ff.get("y", 0), ff.get("w", 7), ff.get("h", 7))
	pb_tray_ball_atlas_textures.clear()
	for frame_name in [PB_TRAY_BALL_FRAME_FILLED, PB_TRAY_BALL_FRAME_EMPTY, PB_TRAY_BALL_FRAME_FAINT]:
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = pb_tray_ball_texture
		atlas_texture.region = pb_tray_ball_frame_rects[frame_name]
		pb_tray_ball_atlas_textures[frame_name] = atlas_texture
	return true

func _clear_trainer_pb_tray_balls(panel) -> void:
	if panel == null:
		return
	for child in panel.get_children():
		if child != null and String(child.name).begins_with("RuntimeTrayBall_"):
			child.queue_free()

func _get_editor_trainer_pb_tray_slots(panel) -> Array:
	var slots := []
	if panel == null:
		return slots
	for child in panel.get_children():
		if child is Sprite and String(child.name).begins_with("TrayBall"):
			slots.append(child)
	return slots

func _layout_editor_trainer_pb_tray_slots(panel, slots: Array) -> void:
	if panel == null or slots.size() <= 1:
		return

	var first_slot = slots[0]
	var last_slot = slots[slots.size() - 1]
	if first_slot == null or last_slot == null:
		return

	var left_x = float(first_slot.position.x)
	var right_x = float(last_slot.position.x)
	if is_equal_approx(left_x, right_x):
		var half_span = max(1.0, trainer_pb_ball_spacing_px * float(slots.size() - 1) * 0.5)
		left_x = float(panel.rect_position.x) - half_span
		right_x = float(panel.rect_position.x) + half_span

	var step_x = (right_x - left_x) / float(slots.size() - 1)
	var y = float(first_slot.position.y)
	for i in range(slots.size()):
		var slot = slots[i]
		if slot == null:
			continue
		slot.position = Vector2(left_x + (step_x * i), y)

func _render_trainer_pb_tray_balls(panel, tray_sprite, total_count: int, filled_count: int, faint_count: int = 0) -> void:
	if panel == null or tray_sprite == null:
		return
	if not _ensure_pb_tray_ball_assets():
		return

	_clear_trainer_pb_tray_balls(panel)
	var count = clamp(total_count, 0, max(0, trainer_pb_tray_slot_count))
	var fainted = clamp(faint_count, 0, count)
	var filled = clamp(filled_count, 0, count - fainted)
	var slots = _get_editor_trainer_pb_tray_slots(panel)
	if slots.empty():
		log_debug("No TrayBall sprite slots found under %s; add Sprite children named TrayBall* directly under the panel." % panel.name)
		return

	_layout_editor_trainer_pb_tray_slots(panel, slots)

	var filled_texture = pb_tray_ball_atlas_textures.get(PB_TRAY_BALL_FRAME_FILLED, null)
	var empty_texture = pb_tray_ball_atlas_textures.get(PB_TRAY_BALL_FRAME_EMPTY, null)
	var faint_texture = pb_tray_ball_atlas_textures.get(PB_TRAY_BALL_FRAME_FAINT, empty_texture)

	for i in range(slots.size()):
		var slot = slots[i]
		if slot == null:
			continue
		slot.visible = i < count
		if not slot.visible:
			continue
		if i < fainted:
			slot.texture = faint_texture
		elif i < (fainted + filled):
			slot.texture = filled_texture
		else:
			slot.texture = empty_texture
		slot.centered = true
		slot.region_enabled = false

func _get_enemy_trainer_tray_counts() -> Dictionary:
	var slot_count = max(0, trainer_pb_tray_slot_count)
	var active_count = clamp(trainer_pb_enemy_active_count, 0, slot_count)
	var faint_count = 0

	if _is_active_trainer_encounter() and typeof(battle_data) == TYPE_DICTIONARY:
		var party_total = clamp(int(battle_data.get("enemy_trainer_party_total", active_count)), 0, slot_count)
		var remaining = battle_data.get("enemy_trainer_party_remaining", [])
		var remaining_count = int(remaining.size()) if typeof(remaining) == TYPE_ARRAY else 0
		active_count = clamp(remaining_count + 1, 0, party_total)
		faint_count = clamp(party_total - active_count, 0, party_total)

	return {
		"slot_count": slot_count,
		"active_count": active_count,
		"faint_count": faint_count,
	}

func _get_player_party_member_count_for_tray() -> int:
	if runtime_state_script == null:
		return 1
	var party = runtime_state_script.get_party(get_tree())
	if party == null:
		return 1
	if party.has_method("size"):
		return int(max(1, int(party.size())))
	return 1

func _run_trainer_pb_panel_intro_sequence(show_enemy_panel: bool = true, show_player_panel: bool = true) -> void:
	if not show_enemy_panel and not show_player_panel:
		return
	if show_enemy_panel and enemy_trainer_pb_panel == null:
		show_enemy_panel = false
	if show_player_panel and player_trainer_pb_panel == null:
		show_player_panel = false
	if not show_enemy_panel and not show_player_panel:
		return

	var enemy_counts = _get_enemy_trainer_tray_counts()
	var slot_count = int(enemy_counts.get("slot_count", max(0, trainer_pb_tray_slot_count)))
	var enemy_active_count = int(enemy_counts.get("active_count", 0))
	var enemy_faint_count = int(enemy_counts.get("faint_count", 0))
	var player_active_count = clamp(trainer_pb_player_active_count, 0, slot_count)

	if show_enemy_panel:
		_render_trainer_pb_tray_balls(enemy_trainer_pb_panel, enemy_trainer_pb_tray_sprite, slot_count, enemy_active_count, enemy_faint_count)
	if show_player_panel:
		_render_trainer_pb_tray_balls(player_trainer_pb_panel, player_trainer_pb_tray_sprite, slot_count, player_active_count, 0)

	if show_enemy_panel:
		enemy_trainer_pb_panel.visible = true
		enemy_trainer_pb_panel.rect_position = _trainer_pb_panel_enemy_hidden_position()
	if show_player_panel:
		player_trainer_pb_panel.visible = true
		player_trainer_pb_panel.rect_position = _trainer_pb_panel_player_hidden_position()

	if show_enemy_panel:
		_animate_trainer_pb_panel_to(true, enemy_trainer_pb_panel_home_position, max(0.0, trainer_pb_panel_slide_duration_sec))
	if show_player_panel:
		_animate_trainer_pb_panel_to(false, player_trainer_pb_panel_home_position, max(0.0, trainer_pb_panel_slide_duration_sec))

	if trainer_pb_panel_hold_sec > 0.0:
		yield(get_tree().create_timer(trainer_pb_panel_hold_sec), "timeout")

	var enemy_out = null
	var player_out = null
	if show_enemy_panel:
		enemy_out = _animate_trainer_pb_panel_to(true, _trainer_pb_panel_enemy_hidden_position(), max(0.0, trainer_pb_panel_slide_duration_sec))
	if show_player_panel:
		player_out = _animate_trainer_pb_panel_to(false, _trainer_pb_panel_player_hidden_position(), max(0.0, trainer_pb_panel_slide_duration_sec))
	if enemy_out is GDScriptFunctionState:
		yield(enemy_out, "completed")
	if player_out is GDScriptFunctionState:
		yield(player_out, "completed")

	if show_enemy_panel:
		enemy_trainer_pb_panel.visible = false
	if show_player_panel:
		player_trainer_pb_panel.visible = false

func _build_enemy_from_trainer_member(member: Dictionary, encounter_meta: Dictionary = {}, biome_state: Dictionary = {}, source: String = "trainer_member"):
	if member.empty():
		return null
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()
	if catalog_loader == null or not catalog_loader.load_catalogs():
		return null

	var species_id = String(member.get("species_id", "")).strip_edges().to_upper()
	if species_id.empty():
		return null

	var base_level = max(1, int(member.get("level", 5)))
	var scaling = _resolve_biome_level_scaling(encounter_meta, base_level, biome_state)
	var level = int(scaling.get("target_level", base_level))
	_log_transition_checkpoint("biome_level_scaling.resolved", {
		"source": source,
		"biome_id": String(scaling.get("biome_id", "")),
		"encounter_number": int(scaling.get("encounter_number", 0)),
		"encounter_archetype": String(scaling.get("encounter_archetype", ENCOUNTER_ARCHETYPE_NORMAL_POKEMON)),
		"base_level": base_level,
		"floor_index": int(scaling.get("floor_index", 0)),
		"player_level": int(scaling.get("player_level", 1)),
		"floor_bonus": int(scaling.get("floor_bonus", 0)),
		"archetype_bonus": int(scaling.get("archetype_bonus", 0)),
		"difficulty_delta": int(scaling.get("difficulty_delta", 0)),
		"target_level": level,
	})
	var move_ids = member.get("move_ids", [])
	if typeof(move_ids) != TYPE_ARRAY:
		move_ids = []

	var enemy_data = catalog_loader.build_pokemon_data(species_id, level, move_ids)
	if enemy_data == null:
		return null

	var current_hp = int(member.get("current_hp", -1))
	if current_hp > 0:
		enemy_data.current_hp = min(enemy_data.current_hp, current_hp)

	return enemy_data

func _try_seed_trainer_encounter(encounter_meta: Dictionary, biome_state: Dictionary = {}) -> Dictionary:
	var trainer_entry = _find_trainer_for_encounter(encounter_meta)
	if trainer_entry.empty():
		return {}

	var party_members = _normalize_trainer_party_members(trainer_entry.get("party_members", []))
	if party_members.empty():
		return {}

	var buildable_party := []
	for member in party_members:
		if typeof(member) != TYPE_DICTIONARY:
			continue
		var candidate_enemy = _build_enemy_from_trainer_member(member, encounter_meta, biome_state, "trainer_seed")
		if candidate_enemy == null:
			log_debug(
				"Trainer seed skipped member for trainer_id=%s: species=%s could not be built."
				% [
					String(trainer_entry.get("trainer_id", "")),
					String(member.get("species_id", "")),
				]
			)
			continue
		buildable_party.append({
			"member": member.duplicate(true),
			"enemy": candidate_enemy,
		})

	if buildable_party.empty():
		log_debug("Trainer seed failed for trainer_id=%s: no buildable party members." % String(trainer_entry.get("trainer_id", "")))
		return {}

	var enemy_data = buildable_party[0].get("enemy", null)
	if enemy_data == null:
		log_debug("Trainer seed failed for trainer_id=%s: first buildable party member resolved to null enemy data." % String(trainer_entry.get("trainer_id", "")))
		return {}

	var remaining_members := []
	for i in range(1, buildable_party.size()):
		remaining_members.append(buildable_party[i].get("member", {}).duplicate(true))

	return {
		"trainer_id": String(trainer_entry.get("trainer_id", "")).strip_edges().to_upper(),
		"display_name": String(trainer_entry.get("display_name", "Trainer")).strip_edges(),
		"sprite_asset_id": String(trainer_entry.get("sprite_asset_id", "")).strip_edges().to_lower(),
		"defeat_key": String(trainer_entry.get("dialog", {}).get("defeat_key", "")).strip_edges(),
		"encounter_bgm": String(trainer_entry.get("encounter_bgm", "")).strip_edges(),
		"battle_bgm": String(trainer_entry.get("battle_bgm", "")).strip_edges(),
		"victory_bgm": String(trainer_entry.get("victory_bgm", "")).strip_edges(),
		"is_boss": bool(trainer_entry.get("is_boss", false)),
		"enemy": enemy_data,
		"party_total": int(buildable_party.size()),
		"remaining_members": remaining_members,
	}

func _is_active_trainer_encounter() -> bool:
	if typeof(battle_data) != TYPE_DICTIONARY:
		return false
	if not battle_data.has("enemy_trainer_id"):
		return false
	return not String(battle_data.get("enemy_trainer_id", "")).strip_edges().empty()

func _dequeue_next_trainer_enemy():
	if not _is_active_trainer_encounter():
		return null

	var remaining = battle_data.get("enemy_trainer_party_remaining", [])
	if typeof(remaining) != TYPE_ARRAY or remaining.empty():
		return null

	var next_member = remaining[0]
	var next_remaining := []
	for i in range(1, remaining.size()):
		next_remaining.append(remaining[i])
	battle_data["enemy_trainer_party_remaining"] = next_remaining

	if typeof(next_member) != TYPE_DICTIONARY:
		return null

	var encounter_meta = battle_data.get("encounter_meta", {})
	if typeof(encounter_meta) != TYPE_DICTIONARY:
		encounter_meta = {}
	var biome_state = _get_battle_biome_state()
	return _build_enemy_from_trainer_member(next_member, encounter_meta, biome_state, "trainer_party_progress")

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
	party_menu_overlay.modulate = Color(1, 1, 1, 1)
	party_menu_visible = false
	_connect_once(party_menu_overlay, "close_requested", "_on_PartyMenu_close_requested")
	_connect_once(party_menu_overlay, "switch_slot_requested", "_on_PartyMenu_switch_slot_requested")
	_connect_once(party_menu_overlay, "pokedex_entry_requested", "_on_PartyMenu_pokedex_entry_requested")
	add_child(party_menu_overlay)
	party_menu_overlay.raise()

func setup_pokedex_overlay() -> void:
	if pokedex_overlay_scene == null:
		return

	pokedex_overlay = pokedex_overlay_scene.instance()
	if pokedex_overlay == null:
		return

	pokedex_overlay.visible = false
	pokedex_overlay_visible = false
	pokedex_return_to_party_menu = false
	_connect_once(pokedex_overlay, "close_requested", "_on_Pokedex_close_requested")
	add_child(pokedex_overlay)
	pokedex_overlay.raise()

func setup_pokemon_evolution_overlay() -> void:
	if pokemon_evolution_overlay_scene == null:
		return

	pokemon_evolution_overlay = pokemon_evolution_overlay_scene.instance()
	if pokemon_evolution_overlay == null:
		return

	pokemon_evolution_overlay.visible = false
	pokemon_evolution_overlay_visible = false
	add_child(pokemon_evolution_overlay)
	pokemon_evolution_overlay.raise()

func _play_evolution_overlay_sequence(from_species_id: String, to_species_id: String, active_turn_token: int):
	if pokemon_evolution_overlay == null:
		return true
	if from_species_id.strip_edges().empty() or to_species_id.strip_edges().empty():
		return true

	pokemon_evolution_overlay_visible = true
	pokemon_evolution_overlay.open_sequence(from_species_id, to_species_id)
	var overlay_result = yield(pokemon_evolution_overlay, "sequence_completed")
	pokemon_evolution_overlay_visible = false

	if _is_turn_token_cancelled(active_turn_token):
		return false

	if typeof(overlay_result) == TYPE_BOOL:
		return bool(overlay_result)
	if typeof(overlay_result) == TYPE_ARRAY and overlay_result.size() > 0:
		return bool(overlay_result[0])
	return true

func _stop_party_menu_fade_tween() -> void:
	if party_menu_fade_tween != null and is_instance_valid(party_menu_fade_tween):
		party_menu_fade_tween.stop_all()
		party_menu_fade_tween.queue_free()
	party_menu_fade_tween = null

func _set_party_menu_overlay_alpha(alpha: float) -> void:
	if party_menu_overlay == null:
		return
	var current = party_menu_overlay.modulate
	party_menu_overlay.modulate = Color(current.r, current.g, current.b, clamp(alpha, 0.0, 1.0))

func _on_party_menu_fade_in_completed() -> void:
	_set_party_menu_overlay_alpha(1.0)
	_stop_party_menu_fade_tween()

func _on_party_menu_fade_out_completed() -> void:
	if party_menu_overlay != null:
		party_menu_overlay.close_menu()
		_set_party_menu_overlay_alpha(1.0)
	_stop_party_menu_fade_tween()

func bind_battle_data():
	var enemy_data = battle_data["enemy"]
	var player_data = battle_data["player"]

	enemy_name_label.text = enemy_data.species_id
	enemy_level_label.text = "Lv. %d" % enemy_data.level
	_refresh_enemy_caught_badge(String(enemy_data.species_id))
	player_name_label.text = player_data.species_id
	player_level_label.text = "Lv. %d" % player_data.level
	_refresh_player_exp_label()

	refresh_hp_ui(enemy_data, enemy_hp_bar, enemy_hp_value_label)
	refresh_hp_ui(player_data, player_hp_bar, player_hp_value_label)
	refresh_type_ui(enemy_data, "enemy", enemy_type1_sprite, enemy_type2_sprite)
	refresh_type_ui(player_data, "player", player_type1_sprite, player_type2_sprite)
	_apply_arena_visuals_from_biome_state()
	_refresh_current_arena_label()

func _refresh_enemy_caught_badge(species_id: String) -> void:
	if enemy_caught_badge_sprite == null:
		return
	if enemy_caught_badge_sprite.texture == null:
		enemy_caught_badge_sprite.texture = load(minimal_assets_path + OWNED_ICON_TEXTURE_REL)
	var show_badge = false
	if runtime_state_script != null:
		show_badge = runtime_state_script.has_caught_species(get_tree(), species_id)
	enemy_caught_badge_sprite.visible = show_badge

func _refresh_current_arena_label() -> void:
	if current_arena_label == null:
		return
	var biome_state = _get_battle_biome_state()
	var arena_name = String(battle_data.get("arena_asset_id", biome_state.get("current_biome_id", "grass"))).strip_edges().to_lower()
	if arena_name.empty():
		arena_name = "grass"
	var current_level = max(1, int(biome_state.get("encounter_index", 0)) + 1)
	current_arena_label.text = "%s - %02d" % [arena_name, current_level]

func _refresh_player_exp_label() -> void:
	if player_exp_value_label == null:
		if player_exp_bar != null:
			player_exp_bar.visible = false
		return
	if runtime_state_script == null:
		player_exp_value_label.text = "-- / --"
		if player_exp_bar != null:
			player_exp_bar.visible = false
		return

	var party = runtime_state_script.get_party(get_tree())
	if party == null:
		player_exp_value_label.text = "-- / --"
		if player_exp_bar != null:
			player_exp_bar.visible = false
		return

	var active_index = party.get_active_slot_index()
	if active_index < 0:
		player_exp_value_label.text = "-- / --"
		if player_exp_bar != null:
			player_exp_bar.visible = false
		return

	var member = party.get_member_at(active_index)
	if member.empty():
		player_exp_value_label.text = "-- / --"
		if player_exp_bar != null:
			player_exp_bar.visible = false
		return

	var species_id = String(member.get("species_id", "")).strip_edges().to_upper()
	var growth_rate = _get_species_growth_rate(species_id)
	var level = max(1, int(member.get("level", 1)))
	if level >= max_exp_level:
		player_exp_value_label.text = "MAX"
		if exp_growth_debug_line_enabled:
			player_exp_value_label.text = "%s\nGR: %s" % [player_exp_value_label.text, growth_rate]
		_update_player_exp_bar_fill(1.0)
		return

	var member_exp = int(member.get("exp", -1))
	if member_exp < 0:
		member_exp = _get_level_total_exp(level, growth_rate)

	var level_floor_exp = _get_level_total_exp(level, growth_rate)
	var next_level_exp = _get_level_total_exp(level + 1, growth_rate)
	var rel_exp = max(0, member_exp - level_floor_exp)
	var need_exp = max(1, next_level_exp - level_floor_exp)
	rel_exp = int(clamp(rel_exp, 0, need_exp))
	var exp_fill_ratio = float(rel_exp) / float(need_exp)
	player_exp_value_label.text = "%d / %d" % [rel_exp, need_exp]
	if exp_growth_debug_line_enabled:
		player_exp_value_label.text = "%s\nGR: %s" % [player_exp_value_label.text, growth_rate]
	_update_player_exp_bar_fill(exp_fill_ratio)

func _update_player_exp_bar_fill(fill_ratio: float) -> void:
	if player_exp_bar == null:
		return

	var safe_fill = clamp(fill_ratio, 0.0, 1.0)
	var crop_ratio = 1.0 - safe_fill
	if not player_exp_bar.has_meta("exp_bar_full_region"):
		var initial_rect = player_exp_bar.region_rect
		if initial_rect.size.x <= 0.0 or initial_rect.size.y <= 0.0:
			initial_rect = Rect2(0, 0, 48, 2)
		player_exp_bar.set_meta("exp_bar_full_region", initial_rect)
	var full_rect = player_exp_bar.get_meta("exp_bar_full_region")

	var full_width = max(1.0, full_rect.size.x)
	var visible_width = full_width * (1.0 - crop_ratio)
	var next_rect = full_rect
	next_rect.size.x = max(0.0, visible_width)
	player_exp_bar.region_rect = next_rect
	player_exp_bar.visible = next_rect.size.x > 0.0

func _animate_player_exp_bar_fill(from_ratio: float, to_ratio: float, duration_sec: float, active_turn_token: int):
	if player_exp_bar == null:
		return true
	if duration_sec <= 0.0:
		_update_player_exp_bar_fill(to_ratio)
		return true

	var start_ratio = clamp(from_ratio, 0.0, 1.0)
	var target_ratio = clamp(to_ratio, 0.0, 1.0)
	var elapsed := 0.0
	var step_sec := 0.016
	while elapsed < duration_sec:
		if _is_turn_token_cancelled(active_turn_token):
			return false
		var t = clamp(elapsed / duration_sec, 0.0, 1.0)
		var eased = t * t * (3.0 - 2.0 * t)
		_update_player_exp_bar_fill(lerp(start_ratio, target_ratio, eased))
		yield(get_tree().create_timer(step_sec), "timeout")
		elapsed += step_sec

	_update_player_exp_bar_fill(target_ratio)
	return true

func _animate_player_exp_gain_bar(member_exp_before: int, member_exp_after: int, level_before: int, level_after: int, growth_rate: String, active_turn_token: int):
	if player_exp_bar == null:
		return true
	if level_before >= max_exp_level:
		_update_player_exp_bar_fill(1.0)
		return true

	var safe_before = max(0, member_exp_before)
	var safe_after = max(0, member_exp_after)
	var safe_level_before = max(1, level_before)
	var safe_level_after = max(safe_level_before, level_after)

	for level in range(safe_level_before, safe_level_after + 1):
		if _is_turn_token_cancelled(active_turn_token):
			return false
		if level >= max_exp_level:
			_update_player_exp_bar_fill(1.0)
			return true

		var level_floor_exp = _get_level_total_exp(level, growth_rate)
		var next_level_exp = _get_level_total_exp(level + 1, growth_rate)
		var need_exp = max(1, next_level_exp - level_floor_exp)

		var segment_start_exp = safe_before
		var segment_end_exp = safe_after
		if level > safe_level_before:
			segment_start_exp = level_floor_exp
		if level < safe_level_after:
			segment_end_exp = next_level_exp

		var start_fill = float(clamp(segment_start_exp - level_floor_exp, 0, need_exp)) / float(need_exp)
		var end_fill = float(clamp(segment_end_exp - level_floor_exp, 0, need_exp)) / float(need_exp)

		var segment_duration = max(0.0, exp_bar_anim_duration_sec * max(0.1, abs(end_fill - start_fill)))
		var anim_state = _animate_player_exp_bar_fill(start_fill, end_fill, segment_duration, active_turn_token)
		var completed = true
		if anim_state is GDScriptFunctionState:
			completed = yield(anim_state, "completed")
		else:
			completed = bool(anim_state)
		if not completed:
			return false

		if level < safe_level_after and player_level_label != null:
			player_level_label.text = "Lv. %d" % (level + 1)

		if level < safe_level_after:
			if exp_bar_level_up_pause_sec > 0.0:
				yield(get_tree().create_timer(exp_bar_level_up_pause_sec), "timeout")
				if _is_turn_token_cancelled(active_turn_token):
					return false
			_update_player_exp_bar_fill(0.0)

	return true

func _apply_exp_to_party_member(party, slot_index: int, awarded_exp: int) -> Dictionary:
	if party == null or slot_index < 0:
		return {}
	var member = party.get_member_at(slot_index)
	if member.empty():
		return {}

	var species_id = String(member.get("species_id", "")).strip_edges().to_upper()
	if species_id.empty():
		return {}

	var growth_rate = _get_species_growth_rate(species_id)
	var level_before = max(1, int(member.get("level", 1)))
	var member_exp_before = int(member.get("exp", -1))
	if member_exp_before < 0:
		member_exp_before = _get_level_total_exp(level_before, growth_rate)

	var member_exp_after = member_exp_before + max(0, awarded_exp)
	var level_after = level_before
	while level_after < max_exp_level and member_exp_after >= _get_level_total_exp(level_after + 1, growth_rate):
		level_after += 1

	var update_result = party.update_member_at(slot_index, {
		"exp": member_exp_after,
		"level": level_after,
	})
	if typeof(update_result) == TYPE_DICTIONARY and not bool(update_result.get("ok", false)):
		return {}

	return {
		"slot_index": slot_index,
		"species_id": species_id,
		"growth_rate": growth_rate,
		"level_before": level_before,
		"level_after": level_after,
		"member_exp_before": member_exp_before,
		"member_exp_after": member_exp_after,
	}

func _set_party_exp_icon_for_species(species_id: String) -> void:
	if party_exp_icon_sprite == null:
		return
	party_exp_icon_sprite.texture = null
	party_exp_icon_sprite.visible = false

	var species_entry = _get_species_entry(species_id)
	var dex_num = int(species_entry.get("pokedex_number", -1))
	var source = species_entry.get("source", {})
	var generation = 1
	if typeof(source) == TYPE_DICTIONARY:
		generation = int(source.get("generation", 1))
	if generation <= 0:
		generation = 1

	var icon_payload = _build_icon_atlas_payload(generation, str(dex_num)) if dex_num > 0 else {}
	if icon_payload.empty() and dex_num > 0:
		for atlas_index in range(1, 10):
			if atlas_index == generation:
				continue
			icon_payload = _build_icon_atlas_payload(atlas_index, str(dex_num))
			if not icon_payload.empty():
				break
	if icon_payload.empty():
		icon_payload = _build_icon_atlas_payload(ICON_FALLBACK_ATLAS_INDEX, ICON_DEFAULT_FRAME)
	if icon_payload.empty():
		return

	party_exp_icon_sprite.texture = icon_payload.get("texture", null)
	party_exp_icon_sprite.region_enabled = false
	party_exp_icon_sprite.centered = false
	party_exp_icon_sprite.modulate = Color(1, 1, 1, 1)
	party_exp_icon_sprite.visible = party_exp_icon_sprite.texture != null

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
	}

func _layout_party_exp_card(exp_text: String) -> void:
	if party_exp_container == null:
		return

	if party_exp_label != null:
		party_exp_label.text = exp_text
		party_exp_label.align = Label.ALIGN_RIGHT

	var icon_width = 16.0
	if party_exp_icon_sprite != null and party_exp_icon_sprite.texture != null:
		if party_exp_icon_sprite.texture is AtlasTexture:
			icon_width = max(8.0, float((party_exp_icon_sprite.texture as AtlasTexture).region.size.x) * abs(party_exp_icon_sprite.scale.x))
		else:
			icon_width = max(8.0, float(party_exp_icon_sprite.texture.get_size().x) * abs(party_exp_icon_sprite.scale.x))

	var text_width = 24.0
	if party_exp_label != null:
		text_width = max(24.0, party_exp_label.get_minimum_size().x)

	var left_pad = 6.0
	var right_pad = 6.0
	var icon_text_gap = 8.0
	var desired_width = max(
		party_exp_container_base_width,
		left_pad + icon_width + icon_text_gap + text_width + right_pad
	)

	party_exp_container.rect_size = Vector2(desired_width, party_exp_container_base_height)
	party_exp_container.rect_min_size = Vector2(desired_width, party_exp_container_base_height)
	party_exp_container_shown_position = Vector2(party_exp_container_right_anchor_x - desired_width, party_exp_container_shown_position.y)
	party_exp_container_hidden_position = Vector2(party_exp_container_right_anchor_x + 8.0, party_exp_container_shown_position.y)

	if party_exp_bar_sprite != null:
		var texture_w = float(party_exp_bar_sprite.texture.get_size().x) if party_exp_bar_sprite.texture != null else 1.0
		texture_w = max(1.0, texture_w)
		party_exp_bar_sprite.position.x = desired_width * 0.5
		party_exp_bar_sprite.scale.x = desired_width / texture_w

	if party_exp_icon_sprite != null:
		var label_w_for_icon = max(24.0, text_width)
		var label_left_for_icon = desired_width - right_pad - label_w_for_icon
		var icon_x = max(left_pad, label_left_for_icon - icon_text_gap - icon_width)
		party_exp_icon_sprite.position.x = icon_x
		party_exp_icon_sprite.position.y = party_exp_icon_base_y

	if party_exp_label != null:
		var label_w = max(24.0, text_width)
		var label_left = desired_width - right_pad - label_w
		party_exp_label.margin_left = label_left
		party_exp_label.margin_right = label_left + label_w
		if party_exp_label_base_height > 1.0:
			party_exp_label.margin_bottom = party_exp_label.margin_top + party_exp_label_base_height

func _slide_party_exp_container(show: bool):
	if party_exp_container == null:
		return true

	var target_pos = party_exp_container_shown_position if show else party_exp_container_hidden_position
	if show:
		party_exp_container.rect_position = party_exp_container_hidden_position
		party_exp_container.visible = true

	if party_exp_slide_duration_sec <= 0.0:
		party_exp_container.rect_position = target_pos
		party_exp_container.visible = show
		return true

	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(
		party_exp_container,
		"rect_position",
		party_exp_container.rect_position,
		target_pos,
		party_exp_slide_duration_sec,
		Tween.TRANS_SINE,
		Tween.EASE_OUT if show else Tween.EASE_IN
	)
	tween.start()
	yield(tween, "tween_all_completed")
	tween.queue_free()
	party_exp_container.rect_position = target_pos
	party_exp_container.visible = show
	return true

func _run_party_exp_sequence(party, active_index: int, awarded_exp: int, active_turn_token: int):
	if party == null or awarded_exp <= 0:
		return {
			"ok": true,
			"party_level_ups": [],
		}

	var party_level_ups := []

	for slot_index in range(party.size()):
		if _is_turn_token_cancelled(active_turn_token):
			return {
				"ok": false,
				"party_level_ups": party_level_ups,
			}
		if slot_index == active_index:
			continue

		var member = party.get_member_at(slot_index)
		if member.empty():
			continue
		if int(member.get("current_hp", 1)) == 0:
			continue

		var exp_result = _apply_exp_to_party_member(party, slot_index, awarded_exp)
		if exp_result.empty():
			continue

		var exp_text = "+%d" % awarded_exp
		_set_party_exp_icon_for_species(String(exp_result.get("species_id", "")))
		_layout_party_exp_card(exp_text)

		var show_state = _slide_party_exp_container(true)
		if show_state is GDScriptFunctionState:
			yield(show_state, "completed")
		if _is_turn_token_cancelled(active_turn_token):
			return {
				"ok": false,
				"party_level_ups": party_level_ups,
			}

		if party_exp_card_hold_sec > 0.0:
			yield(get_tree().create_timer(party_exp_card_hold_sec), "timeout")
			if _is_turn_token_cancelled(active_turn_token):
				return {
					"ok": false,
					"party_level_ups": party_level_ups,
				}

		var species_id = String(exp_result.get("species_id", ""))
		var level_before = int(exp_result.get("level_before", 1))
		var level_after = int(exp_result.get("level_after", level_before))

		set_battle_text("%s gained %d EXP." % [species_id, awarded_exp])
		if exp_message_hold_sec > 0.0:
			yield(get_tree().create_timer(exp_message_hold_sec), "timeout")
			if _is_turn_token_cancelled(active_turn_token):
				return {
					"ok": false,
					"party_level_ups": party_level_ups,
				}

		if level_after > level_before:
			party_level_ups.append({
				"slot_index": slot_index,
				"species_id": species_id.strip_edges().to_upper(),
				"level_before": level_before,
				"level_after": level_after,
			})
			set_battle_text("%s grew to Lv.%d!" % [species_id, level_after])
			if exp_message_hold_sec > 0.0:
				yield(get_tree().create_timer(exp_message_hold_sec), "timeout")
				if _is_turn_token_cancelled(active_turn_token):
					return {
						"ok": false,
						"party_level_ups": party_level_ups,
					}

		var hide_state = _slide_party_exp_container(false)
		if hide_state is GDScriptFunctionState:
			yield(hide_state, "completed")
		if _is_turn_token_cancelled(active_turn_token):
			return {
				"ok": false,
				"party_level_ups": party_level_ups,
			}

	if party_exp_container != null:
		party_exp_container.visible = false
		party_exp_container.rect_position = party_exp_container_hidden_position
	return {
		"ok": true,
		"party_level_ups": party_level_ups,
	}

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

func _resolve_named_bgm_stream(track_id: String) -> Dictionary:
	var raw_track_id = String(track_id).strip_edges()
	if raw_track_id.empty():
		return {"stream": null, "track_id": ""}

	var candidates := [raw_track_id]
	var normalized = _normalize_arena_asset_id(raw_track_id)
	if not normalized.empty() and normalized != raw_track_id:
		candidates.append(normalized)

	var tried := {}
	for candidate in candidates:
		var resolved = String(candidate)
		if tried.has(resolved):
			continue
		tried[resolved] = true
		var path = _build_bgm_path(resolved)
		if resource_exists(path):
			return {"stream": load(path), "track_id": resolved}

	return {"stream": null, "track_id": raw_track_id}

func _play_named_bgm_track(track_id: String, force_restart: bool = false) -> bool:
	_ensure_biome_bgm_players()
	if biome_bgm_primary_player == null:
		return false

	var stream_data = _resolve_named_bgm_stream(track_id)
	var bgm_stream = stream_data.get("stream", null)
	var resolved_track_id = String(stream_data.get("track_id", "")).strip_edges()
	if bgm_stream == null:
		log_debug("Missing named BGM track '%s'" % track_id)
		return false

	if not force_restart and resolved_track_id == current_bgm_arena_asset_id:
		if biome_bgm_active_player != null and not biome_bgm_active_player.playing:
			biome_bgm_active_player.play()
		biome_bgm_active_player.volume_db = biome_bgm_volume_db
		return true

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
		if crossfade_duration > 0.0:
			incoming_player.volume_db = -80.0
		else:
			incoming_player.volume_db = biome_bgm_volume_db
		incoming_player.play()
		if crossfade_duration > 0.0:
			biome_bgm_crossfade_tween = Tween.new()
			add_child(biome_bgm_crossfade_tween)
			biome_bgm_crossfade_tween.interpolate_property(
				incoming_player,
				"volume_db",
				incoming_player.volume_db,
				biome_bgm_volume_db,
				crossfade_duration,
				Tween.TRANS_SINE,
				Tween.EASE_IN_OUT
			)
			_connect_once(
				biome_bgm_crossfade_tween,
				"tween_all_completed",
				"_on_biome_bgm_crossfade_completed",
				[null]
			)
			biome_bgm_crossfade_tween.start()
		biome_bgm_active_player = incoming_player
		current_bgm_arena_asset_id = resolved_track_id
		return true

	incoming_player.volume_db = -80.0
	incoming_player.play()

	if crossfade_duration <= 0.0:
		_stop_biome_bgm_crossfade_tween()
		outgoing_player.stop()
		outgoing_player.volume_db = biome_bgm_volume_db
		incoming_player.volume_db = biome_bgm_volume_db
		biome_bgm_active_player = incoming_player
		current_bgm_arena_asset_id = resolved_track_id
		return true

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
	return true

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

func _stop_all_biome_bgm() -> void:
	_stop_biome_bgm_crossfade_tween()
	for player in [biome_bgm_primary_player, biome_bgm_secondary_player]:
		if player == null or not is_instance_valid(player):
			continue
		player.stop()
	if biome_bgm_primary_player != null and is_instance_valid(biome_bgm_primary_player):
		biome_bgm_primary_player.volume_db = biome_bgm_volume_db
	if biome_bgm_secondary_player != null and is_instance_valid(biome_bgm_secondary_player):
		biome_bgm_secondary_player.volume_db = -80.0

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
		if crossfade_duration > 0.0:
			incoming_player.volume_db = -80.0
		else:
			incoming_player.volume_db = biome_bgm_volume_db
		incoming_player.play()
		if crossfade_duration > 0.0:
			biome_bgm_crossfade_tween = Tween.new()
			add_child(biome_bgm_crossfade_tween)
			biome_bgm_crossfade_tween.interpolate_property(
				incoming_player,
				"volume_db",
				incoming_player.volume_db,
				biome_bgm_volume_db,
				crossfade_duration,
				Tween.TRANS_SINE,
				Tween.EASE_IN_OUT
			)
			_connect_once(
				biome_bgm_crossfade_tween,
				"tween_all_completed",
				"_on_biome_bgm_crossfade_completed",
				[null]
			)
			biome_bgm_crossfade_tween.start()
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

	var trainer_bgm_id := ""
	if not suppress_arena_bgm_apply:
		if _is_active_trainer_encounter():
			trainer_bgm_id = String(battle_data.get("enemy_trainer_battle_bgm", "")).strip_edges()
			if trainer_bgm_id.empty():
				trainer_bgm_id = String(battle_data.get("enemy_trainer_encounter_bgm", "")).strip_edges()
		if trainer_bgm_id.empty() or not _play_named_bgm_track(trainer_bgm_id):
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
	if debug_enemy_baseline_overlay_enabled:
		_update_debug_enemy_baseline_overlay()
	_update_debug_enemy_sprite_bounds_logging(_delta)
	_update_debug_enemy_sprite_cycle(_delta)
	_update_debug_player_sprite_cycle(_delta)

	if Input.is_action_just_pressed("ui_accept") and get_focus_owner() == null and not turn_in_progress and not battle_ended:
		set_battle_text("Battle scene ready. Press the move button to continue.")

func _update_debug_enemy_sprite_bounds_logging(delta: float) -> void:
	if not debug_enemy_sprite_bounds_logging_enabled:
		debug_enemy_sprite_bounds_log_elapsed = 0.0
		return
	if enemy_pokemon_sprite == null or enemy_layer == null:
		return

	debug_enemy_sprite_bounds_log_elapsed += max(0.0, delta)
	if debug_enemy_sprite_bounds_log_elapsed < max(0.1, debug_enemy_sprite_bounds_log_interval_sec):
		return
	debug_enemy_sprite_bounds_log_elapsed = 0.0

	var frame_h = 0.0
	if enemy_pokemon_sprite.region_enabled:
		frame_h = enemy_pokemon_sprite.region_rect.size.y
	elif enemy_pokemon_sprite.texture != null:
		frame_h = enemy_pokemon_sprite.texture.get_height()
	if frame_h <= 0.0:
		return

	var scale_y = abs(enemy_pokemon_sprite.scale.y)
	if scale_y <= 0.0:
		scale_y = 1.0

	var top_local_y = enemy_pokemon_sprite.offset.y
	if enemy_pokemon_sprite.centered:
		top_local_y -= frame_h / 2.0

	var top_y = enemy_pokemon_sprite.global_position.y + (top_local_y * scale_y)
	var bottom_y = top_y + (frame_h * scale_y)
	var baseline_y = enemy_layer.rect_position.y + enemy_sprite_home_position.y
	var baseline_delta = bottom_y - baseline_y

	var suspicious_reasons := []
	if baseline_delta > debug_enemy_sprite_bounds_too_low_px:
		suspicious_reasons.append("too_low")
	if baseline_delta < -debug_enemy_sprite_bounds_too_high_px:
		suspicious_reasons.append("too_high")

	var species_id = "UNKNOWN"
	if battle_data != null and battle_data.has("enemy") and battle_data["enemy"] != null:
		species_id = String(battle_data["enemy"].species_id)

	var frame_name = ""
	if enemy_anim_index >= 0 and enemy_anim_index < enemy_sprite_frames.size() and enemy_sprite_frames[enemy_anim_index] is Dictionary:
		frame_name = String(enemy_sprite_frames[enemy_anim_index].get("filename", ""))

	var suspicious_label = "ok"
	if not suspicious_reasons.empty():
		suspicious_label = ",".join(suspicious_reasons)

	log_debug(
		"EnemySpriteBounds species=%s frame=%s top_y=%.2f bottom_y=%.2f baseline_y=%.2f delta=%.2f suspicious=%s"
		% [species_id, frame_name, top_y, bottom_y, baseline_y, baseline_delta, suspicious_label]
	)

	if not suspicious_reasons.empty() and debug_enemy_sprite_bounds_capture_suspicious:
		_capture_sprite_debug_snapshot(species_id, frame_name, baseline_delta, suspicious_label)

func _capture_sprite_debug_snapshot(species_id: String, frame_name: String, baseline_delta: float, suspicious_label: String) -> void:
	var now_msec = OS.get_ticks_msec()
	if debug_enemy_sprite_bounds_last_capture_msec >= 0:
		var cooldown_msec = int(max(0.0, debug_enemy_sprite_bounds_capture_cooldown_sec) * 1000.0)
		if now_msec - debug_enemy_sprite_bounds_last_capture_msec < cooldown_msec:
			return

	var image = get_viewport().get_texture().get_data()
	if image == null:
		return
	image.flip_y()

	var dir_path = debug_enemy_sprite_bounds_capture_dir.strip_edges()
	if dir_path.empty():
		dir_path = "user://enemy_sprite_snapshots"
	var dir = Directory.new()
	if not dir.dir_exists(dir_path):
		var mk_err = dir.make_dir_recursive(dir_path)
		if mk_err != OK:
			log_debug("SpriteSnapshot failed to create dir: %s err=%d" % [dir_path, mk_err])
			return

	var safe_species = species_id.strip_edges().to_lower().replace("/", "_").replace("\\", "_")
	if safe_species.empty():
		safe_species = "unknown"
	var safe_frame = frame_name.strip_edges().to_lower().replace("/", "_").replace("\\", "_").replace(".png", "")
	if safe_frame.empty():
		safe_frame = "frame"
	var stamp = str(OS.get_unix_time())
	var file_path = "%s/%s_%s_%s_d%.2f_%s.png" % [dir_path, safe_species, safe_frame, stamp, baseline_delta, suspicious_label]
	var save_err = image.save_png(file_path)
	if save_err == OK:
		debug_enemy_sprite_bounds_last_capture_msec = now_msec
		log_debug("SpriteSnapshot saved: %s" % file_path)
		log_debug("SpriteSnapshot absolute: %s" % ProjectSettings.globalize_path(file_path))
	else:
		log_debug("SpriteSnapshot save failed: %s err=%d" % [file_path, save_err])
		log_debug("SpriteSnapshot failed absolute target: %s" % ProjectSettings.globalize_path(file_path))

func _init_debug_enemy_sprite_cycle() -> void:
	debug_enemy_sprite_cycle_species_ids.clear()
	debug_enemy_sprite_cycle_index = -1
	debug_enemy_sprite_cycle_elapsed = 0.0
	debug_enemy_sprite_cycle_completed = false
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()
	if catalog_loader == null or not catalog_loader.load_catalogs():
		log_debug("Debug enemy cycle unavailable: catalog not loaded")
		return

	var all_species_ids = catalog_loader.get_all_species_ids()
	var cycle_entries := []
	for species_id in all_species_ids:
		var sid = String(species_id)
		var sprite_paths = get_species_sprite_paths(sid, false)
		if sprite_paths.empty():
			continue
		var texture_path = minimal_assets_path + String(sprite_paths.get("texture_rel", ""))
		var atlas_path = minimal_assets_path + String(sprite_paths.get("atlas_rel", ""))
		if texture_path.empty() or atlas_path.empty():
			continue
		if not resource_exists(texture_path):
			continue
		if not _atlas_has_usable_frames(atlas_path):
			continue
		cycle_entries.append({
			"species_id": sid,
			"dex": catalog_loader.get_species_dex_number(sid),
		})

	cycle_entries.sort_custom(self, "_sort_species_cycle_entries")
	for entry in cycle_entries:
		debug_enemy_sprite_cycle_species_ids.append(String(entry.get("species_id", "")))

	log_debug("Debug enemy cycle initialized with %d species" % debug_enemy_sprite_cycle_species_ids.size())
	if debug_enemy_sprite_bounds_capture_suspicious:
		log_debug("SpriteSnapshot output dir: %s" % ProjectSettings.globalize_path(debug_enemy_sprite_bounds_capture_dir))

func _sort_species_cycle_entries(a: Dictionary, b: Dictionary) -> bool:
	var a_dex = int(a.get("dex", -1))
	var b_dex = int(b.get("dex", -1))
	if a_dex == b_dex:
		return String(a.get("species_id", "")) < String(b.get("species_id", ""))
	if a_dex < 0:
		return false
	if b_dex < 0:
		return true
	return a_dex < b_dex

func _atlas_has_usable_frames(atlas_path: String) -> bool:
	var frames = parse_all_sprite_frames(atlas_path)
	return not frames.empty()

func _update_debug_enemy_sprite_cycle(delta: float) -> void:
	if not debug_enemy_sprite_cycle_enabled:
		return
	if battle_ended or turn_in_progress or debug_enemy_sprite_cycle_running:
		return
	if debug_enemy_sprite_cycle_completed:
		return
	if debug_enemy_sprite_cycle_species_ids.empty():
		_init_debug_enemy_sprite_cycle()
		if debug_enemy_sprite_cycle_species_ids.empty():
			return

	debug_enemy_sprite_cycle_elapsed += max(0.0, delta)
	if debug_enemy_sprite_cycle_elapsed < max(0.1, debug_enemy_sprite_cycle_interval_sec):
		return
	debug_enemy_sprite_cycle_elapsed = 0.0

	var cycle_state = _run_debug_enemy_sprite_cycle_once()
	if cycle_state is GDScriptFunctionState:
		debug_enemy_sprite_cycle_running = true
		_connect_once(cycle_state, "completed", "_on_debug_enemy_sprite_cycle_once_completed")

func _on_debug_enemy_sprite_cycle_once_completed(_result = null) -> void:
	debug_enemy_sprite_cycle_running = false

func _init_debug_player_sprite_cycle() -> void:
	debug_player_sprite_cycle_species_ids.clear()
	debug_player_sprite_cycle_index = -1
	debug_player_sprite_cycle_elapsed = 0.0
	debug_player_sprite_cycle_completed = false
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()
	if catalog_loader == null or not catalog_loader.load_catalogs():
		log_debug("Debug player cycle unavailable: catalog not loaded")
		return

	var cycle_entries := []
	var all_species_ids = catalog_loader.get_all_species_ids()
	for species_id in all_species_ids:
		var sid = String(species_id)
		var sprite_paths = get_species_sprite_paths(sid, true)
		if sprite_paths.empty():
			continue
		var texture_path = minimal_assets_path + String(sprite_paths.get("texture_rel", ""))
		var atlas_path = minimal_assets_path + String(sprite_paths.get("atlas_rel", ""))
		if texture_path.empty() or atlas_path.empty():
			continue
		if not resource_exists(texture_path):
			continue
		if not _atlas_has_usable_frames(atlas_path):
			continue
		cycle_entries.append({
			"species_id": sid,
			"dex": catalog_loader.get_species_dex_number(sid),
		})

	cycle_entries.sort_custom(self, "_sort_species_cycle_entries")
	for entry in cycle_entries:
		debug_player_sprite_cycle_species_ids.append(String(entry.get("species_id", "")))

	log_debug("Debug player cycle initialized with %d species" % debug_player_sprite_cycle_species_ids.size())

func _update_debug_player_sprite_cycle(delta: float) -> void:
	if not debug_player_sprite_cycle_enabled:
		return
	if battle_ended or turn_in_progress or debug_player_sprite_cycle_running:
		return
	if debug_player_sprite_cycle_completed:
		return
	if debug_enemy_sprite_cycle_running:
		return
	if debug_player_sprite_cycle_species_ids.empty():
		_init_debug_player_sprite_cycle()
		if debug_player_sprite_cycle_species_ids.empty():
			return

	debug_player_sprite_cycle_elapsed += max(0.0, delta)
	if debug_player_sprite_cycle_elapsed < max(0.1, debug_player_sprite_cycle_interval_sec):
		return
	debug_player_sprite_cycle_elapsed = 0.0

	var cycle_state = _run_debug_player_sprite_cycle_once()
	if cycle_state is GDScriptFunctionState:
		debug_player_sprite_cycle_running = true
		_connect_once(cycle_state, "completed", "_on_debug_player_sprite_cycle_once_completed")

func _on_debug_player_sprite_cycle_once_completed(_result = null) -> void:
	debug_player_sprite_cycle_running = false

func _run_debug_player_sprite_cycle_once():
	if debug_player_sprite_cycle_species_ids.empty():
		return null
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()
	if catalog_loader == null or not catalog_loader.load_catalogs():
		return null

	var next_index = debug_player_sprite_cycle_index + 1
	if next_index >= debug_player_sprite_cycle_species_ids.size():
		debug_player_sprite_cycle_completed = true
		log_debug("Debug player cycle completed at end of catalog (%d species)" % debug_player_sprite_cycle_species_ids.size())
		set_battle_text("[DEBUG] Player back-sprite cycle completed (%d species)" % debug_player_sprite_cycle_species_ids.size())
		return null

	debug_player_sprite_cycle_index = next_index
	var species_id = String(debug_player_sprite_cycle_species_ids[debug_player_sprite_cycle_index])
	var debug_player = catalog_loader.build_pokemon_data(species_id, 5)
	if debug_player == null:
		return null

	battle_data["player"] = debug_player
	load_battle_sprites()
	bind_battle_data()
	player_sprite_anim_enabled = true
	enemy_sprite_anim_enabled = true
	restore_battler_sprite_state(player_pokemon_sprite, player_sprite_home_position)
	reset_pokemon_animation_state()

	if debug_player_sprite_cycle_play_cries:
		_play_player_sendout_cry_once()
	if debug_player_sprite_cycle_capture_screenshots:
		var frame_name = ""
		if player_anim_index >= 0 and player_anim_index < player_sprite_frames.size() and player_sprite_frames[player_anim_index] is Dictionary:
			frame_name = String(player_sprite_frames[player_anim_index].get("filename", ""))
		_capture_sprite_debug_snapshot(species_id, frame_name, 0.0, "player_cycle")
	set_battle_text("[DEBUG] Player back-sprite cycle: %s" % species_id)
	return null

func _run_debug_enemy_sprite_cycle_once():
	if debug_enemy_sprite_cycle_species_ids.empty():
		return null
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()
	if catalog_loader == null or not catalog_loader.load_catalogs():
		return null

	var slide_out = animate_enemy_layer_to(
		enemy_layer_home_position + Vector2(enemy_switch_slide_distance_px, 0),
		enemy_switch_slide_duration_sec,
		-1
	)
	_animate_enemy_panel_to(_enemy_panel_hidden_position(), max(0.0, enemy_panel_slide_duration_sec), -1)
	if slide_out is GDScriptFunctionState:
		yield(slide_out, "completed")

	var next_index = debug_enemy_sprite_cycle_index + 1
	if next_index >= debug_enemy_sprite_cycle_species_ids.size():
		debug_enemy_sprite_cycle_completed = true
		log_debug("Debug enemy cycle completed at end of catalog (%d species)" % debug_enemy_sprite_cycle_species_ids.size())
		set_battle_text("[DEBUG] Enemy sprite cycle completed (%d species)" % debug_enemy_sprite_cycle_species_ids.size())
		return null
	debug_enemy_sprite_cycle_index = next_index
	var species_id = String(debug_enemy_sprite_cycle_species_ids[debug_enemy_sprite_cycle_index])
	var debug_enemy = catalog_loader.build_pokemon_data(species_id, 5)
	if debug_enemy == null:
		return null

	battle_data["enemy"] = debug_enemy
	enemy_layer.rect_position = enemy_layer_home_position + Vector2(-enemy_switch_slide_distance_px, 0)
	if enemy_panel != null:
		enemy_panel.rect_position = _enemy_panel_hidden_position()
	load_battle_sprites()
	bind_battle_data()
	player_sprite_anim_enabled = true
	enemy_sprite_anim_enabled = true
	restore_battler_sprite_state(enemy_pokemon_sprite, enemy_sprite_home_position)
	reset_pokemon_animation_state()

	var slide_in = animate_enemy_layer_to(enemy_layer_home_position, enemy_switch_slide_duration_sec, -1)
	_animate_enemy_panel_to(enemy_panel_home_position, max(0.0, enemy_panel_slide_duration_sec), -1)
	if slide_in is GDScriptFunctionState:
		yield(slide_in, "completed")

	if debug_enemy_sprite_cycle_play_cries:
		_play_enemy_sendout_cry_once()
	set_battle_text("[DEBUG] Enemy sprite cycle: %s" % species_id)
	return null

func _ensure_debug_enemy_baseline_overlay() -> void:
	if debug_enemy_baseline_overlay != null:
		return
	if battlefield_layer == null:
		return

	debug_enemy_baseline_overlay = ColorRect.new()
	debug_enemy_baseline_overlay.name = "DebugEnemyBaselineOverlay"
	debug_enemy_baseline_overlay.color = Color(1.0, 0.2, 0.2, 0.8)
	debug_enemy_baseline_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	battlefield_layer.add_child(debug_enemy_baseline_overlay)

func _update_debug_enemy_baseline_overlay() -> void:
	if not debug_enemy_baseline_overlay_enabled:
		if debug_enemy_baseline_overlay != null:
			debug_enemy_baseline_overlay.visible = false
		return
	if debug_enemy_baseline_overlay == null:
		_ensure_debug_enemy_baseline_overlay()
	if debug_enemy_baseline_overlay == null or battlefield_layer == null or enemy_layer == null:
		return

	var baseline_y = enemy_layer.rect_position.y + enemy_sprite_home_position.y
	debug_enemy_baseline_overlay.visible = true
	debug_enemy_baseline_overlay.rect_position = Vector2(0.0, baseline_y)
	debug_enemy_baseline_overlay.rect_size = Vector2(max(1.0, battlefield_layer.rect_size.x), 1.0)

# Input and command dispatch.
func _input(event):
	if not (event is InputEventKey):
		return
	if not event.pressed or event.echo:
		return
	if pokedex_overlay_visible:
		if _is_back_input(event):
			if pokedex_overlay != null and pokedex_overlay.handle_back_action():
				accept_event()
				return
			close_pokedex_overlay()
			accept_event()
			return
		if event.is_action_pressed("ui_up"):
			if pokedex_overlay != null:
				pokedex_overlay.move_focus("ui_up")
			accept_event()
			return
		if event.is_action_pressed("ui_down"):
			if pokedex_overlay != null:
				pokedex_overlay.move_focus("ui_down")
			accept_event()
			return
		if event.is_action_pressed("ui_left"):
			if pokedex_overlay != null:
				pokedex_overlay.move_focus("ui_left")
			accept_event()
			return
		if event.is_action_pressed("ui_right"):
			if pokedex_overlay != null:
				pokedex_overlay.move_focus("ui_right")
			accept_event()
			return
		if event.is_action_pressed("ui_accept"):
			if pokedex_overlay != null:
				pokedex_overlay.press_focused()
			accept_event()
			return
	if ball_menu_visible:
		if _is_back_input(event):
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

	if _is_back_input(event):
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
	if pokedex_overlay_visible:
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
	if _is_back_input(event):
		if attack_menu_visible:
			close_attack_menu()
			accept_event()
		return

func _is_back_input(event: InputEventKey) -> bool:
	if event == null:
		return false
	return event.is_action_pressed("ui_back") or event.is_action_pressed("ui_cancel") or event.scancode == KEY_BACKSPACE or event.scancode == KEY_ESCAPE

func _on_MoveButton_pressed():
	if battle_ended:
		set_battle_text("Battle has ended. Press Ball to restart.")
		return

	if turn_in_progress:
		return

	var attacker = battle_data["player"] if typeof(battle_data) == TYPE_DICTIONARY and battle_data.has("player") else null
	if attacker != null and not _pokemon_has_any_usable_move(attacker):
		execute_player_move(_build_struggle_move(), -1)
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
	var move = attacker.moves[move_slot]
	if not _can_use_move(move):
		if _pokemon_has_any_usable_move(attacker):
			set_battle_text("%s has no PP left!" % String(move.move_id))
		else:
			execute_player_move(_build_struggle_move(), -1)
			return
		refresh_attack_menu()
		return

	execute_player_move(move, move_slot)

func _on_AttackMoveButton_focus_entered(move_slot: int):
	refresh_attack_move_details(move_slot)

func close_attack_menu():
	if turn_in_progress or battle_ended:
		return
	hide_attack_menu()
	ensure_button_focus()

func execute_player_move(move, move_slot: int = -1):
	if move == null:
		set_battle_text("No move available.")
		return

	turn_in_progress = true
	_enter_action_locked_state()
	var active_turn_token = turn_token
	active_turn_run_id = _next_turn_run_id()
	_log_turn_checkpoint("entry", {
		"active_turn_token": active_turn_token,
		"move_id": String(move.move_id),
	})

	var turn_context := {
		"aborted": false,
		"turn_state": {
			"move": move,
			"move_slot": move_slot,
			"active_turn_token": active_turn_token,
			"cancelled": false,
			"terminal": false,
			"battle_error": false,
			"enemy_has_move": true,
			"enemy_fainted": false,
			"player_fainted": false,
		},
	}

	var phase_runner = battle_phase_runner_script.new()
	phase_runner.push_phase(turn_command_resolve_phase_script.new(self, turn_context, active_turn_token))
	phase_runner.push_phase(turn_player_move_phase_script.new(self, turn_context, active_turn_token))
	phase_runner.push_phase(turn_enemy_move_phase_script.new(self, turn_context, active_turn_token))
	phase_runner.push_phase(turn_faint_resolve_phase_script.new(self, turn_context, active_turn_token))
	phase_runner.push_phase(turn_player_defeat_gate_phase_script.new(self, turn_context, active_turn_token))
	phase_runner.push_phase(turn_forced_switch_prompt_phase_script.new(self, turn_context, active_turn_token))
	phase_runner.push_phase(turn_game_over_phase_script.new(self, turn_context, active_turn_token))
	phase_runner.push_phase(turn_end_unlock_phase_script.new(self, turn_context, active_turn_token))

	if phase_runner.is_running():
		yield(phase_runner, "queue_idle")

	var turn_state = turn_context.get("turn_state", {})
	if typeof(turn_state) == TYPE_DICTIONARY:
		_log_turn_checkpoint("queue_idle", {
			"cancelled": bool(turn_state.get("cancelled", false)),
			"terminal": bool(turn_state.get("terminal", false)),
		})
	else:
		_log_turn_checkpoint("queue_idle")
	active_turn_run_id = ""
	return

func _run_turn_command_resolve_phase_state(turn_state: Dictionary, active_turn_token: int) -> Dictionary:
	if typeof(turn_state) != TYPE_DICTIONARY:
		return {}
	if _is_turn_token_cancelled(active_turn_token):
		turn_state["cancelled"] = true
		turn_state["terminal"] = true
		return turn_state

	var attacker = battle_data["player"] if typeof(battle_data) == TYPE_DICTIONARY and battle_data.has("player") else null
	var defender = battle_data["enemy"] if typeof(battle_data) == TYPE_DICTIONARY and battle_data.has("enemy") else null
	if attacker == null or defender == null:
		set_battle_text("Battle data missing.")
		turn_state["battle_error"] = true
		turn_state["terminal"] = true
		return turn_state

	var move = turn_state.get("move", null)
	if move == null:
		if _pokemon_has_any_usable_move(attacker):
			set_battle_text("No move available.")
			turn_state["battle_error"] = true
			turn_state["terminal"] = true
			return turn_state
		move = _build_struggle_move()
		turn_state["move"] = move
		turn_state["player_using_struggle"] = true
	if not _can_use_move(move):
		if _pokemon_has_any_usable_move(attacker):
			set_battle_text("%s has no PP left!" % String(move.move_id))
			turn_state["battle_error"] = true
			turn_state["terminal"] = true
			return turn_state
		move = _build_struggle_move()
		turn_state["move"] = move
		turn_state["player_using_struggle"] = true

	_consume_move_pp(move)
	refresh_attack_menu()

	var move_slot = int(turn_state.get("move_slot", -1))
	turn_state["move_display_id"] = String(move.move_id)
	if _is_move_struggle(move):
		turn_state["player_using_struggle"] = true
	if _is_debug_ohko_slot(move_slot):
		turn_state["move_display_id"] = "OHKO"
		turn_state["forced_player_damage"] = max(1, debug_ohko_damage)

	turn_state["attacker"] = attacker
	turn_state["defender"] = defender
	return turn_state

func _run_turn_player_move_phase_state(turn_state: Dictionary, active_turn_token: int):
	if typeof(turn_state) != TYPE_DICTIONARY:
		return {}
	if bool(turn_state.get("terminal", false)) or bool(turn_state.get("cancelled", false)):
		return turn_state

	var attacker = turn_state.get("attacker", null)
	var defender = turn_state.get("defender", null)
	var move = turn_state.get("move", null)
	if attacker == null or defender == null or move == null:
		turn_state["battle_error"] = true
		turn_state["terminal"] = true
		return turn_state

	if bool(turn_state.get("player_using_struggle", false)):
		set_battle_text("%s has no moves left that it can use!" % String(attacker.species_id))
		if turn_step_delay_sec > 0.0:
			yield(get_tree().create_timer(turn_step_delay_sec), "timeout")
			if _is_turn_token_cancelled(active_turn_token):
				turn_state["cancelled"] = true
				turn_state["terminal"] = true
				return turn_state

	var player_move_anim = play_move_animation(move.move_id, player_pokemon_sprite, enemy_pokemon_sprite, active_turn_token)
	if player_move_anim is GDScriptFunctionState:
		yield(player_move_anim, "completed")
		if _is_turn_token_cancelled(active_turn_token):
			turn_state["cancelled"] = true
			turn_state["terminal"] = true
			return turn_state

	var damage = int(battle_calc_script.calc_damage(attacker, move, defender, debug_damage_calculation_enabled))
	if turn_state.has("forced_player_damage"):
		damage = max(1, int(turn_state.get("forced_player_damage", damage)))
	defender.current_hp = max(0, defender.current_hp - damage)
	var player_type_multiplier = battle_calc_script.get_type_multiplier(move.move_type, defender)

	refresh_hp_ui(defender, enemy_hp_bar, enemy_hp_value_label)
	var player_hit_feedback = play_hit_feedback(enemy_pokemon_sprite, active_turn_token)
	if player_hit_feedback is GDScriptFunctionState:
		yield(player_hit_feedback, "completed")
		if _is_turn_token_cancelled(active_turn_token):
			turn_state["cancelled"] = true
			turn_state["terminal"] = true
			return turn_state

	var move_display_id = String(turn_state.get("move_display_id", String(move.move_id)))
	var battle_message = "%s used %s! %d damage." % [attacker.species_id, move_display_id, damage]
	battle_message += build_type_effectiveness_text(player_type_multiplier)
	set_battle_text(battle_message)
	if turn_step_delay_sec > 0.0:
		yield(get_tree().create_timer(turn_step_delay_sec), "timeout")
		if _is_turn_token_cancelled(active_turn_token):
			turn_state["cancelled"] = true
			turn_state["terminal"] = true
			return turn_state

	if bool(turn_state.get("player_using_struggle", false)):
		var player_recoil_damage = _apply_struggle_recoil(attacker)
		if player_recoil_damage > 0:
			refresh_hp_ui(attacker, player_hp_bar, player_hp_value_label)
			sync_active_party_member_from_battle()
			set_battle_text("%s was damaged by the recoil!" % String(attacker.species_id))
			if turn_step_delay_sec > 0.0:
				yield(get_tree().create_timer(turn_step_delay_sec), "timeout")
				if _is_turn_token_cancelled(active_turn_token):
					turn_state["cancelled"] = true
					turn_state["terminal"] = true
					return turn_state
		if attacker.is_fainted():
			turn_state["player_fainted"] = true
			turn_state["terminal"] = true
			turn_state["fainted_species_id"] = String(attacker.species_id)
			return turn_state

	if defender.is_fainted():
		turn_state["enemy_fainted"] = true
		turn_state["terminal"] = true
		turn_state["fainted_species_id"] = String(defender.species_id)
		turn_state["defeated_enemy_species_id"] = String(defender.species_id)
		turn_state["defeated_enemy_level"] = int(defender.level)
		return turn_state

	var enemy_move = _get_first_usable_move(defender)
	if enemy_move == null:
		enemy_move = _build_struggle_move()
		turn_state["enemy_using_struggle"] = true
	elif _is_move_struggle(enemy_move):
		turn_state["enemy_using_struggle"] = true

	turn_state["enemy_move"] = enemy_move
	return turn_state

func _run_turn_enemy_move_phase_state(turn_state: Dictionary, active_turn_token: int):
	if typeof(turn_state) != TYPE_DICTIONARY:
		return {}
	if bool(turn_state.get("cancelled", false)):
		return turn_state
	if bool(turn_state.get("enemy_fainted", false)) or not bool(turn_state.get("enemy_has_move", true)):
		return turn_state

	var attacker = turn_state.get("attacker", null)
	var defender = turn_state.get("defender", null)
	var enemy_move = turn_state.get("enemy_move", null)
	if attacker == null or defender == null or enemy_move == null:
		turn_state["battle_error"] = true
		turn_state["terminal"] = true
		return turn_state

	if bool(turn_state.get("enemy_using_struggle", false)):
		set_battle_text("%s has no moves left that it can use!" % String(defender.species_id))
		if turn_step_delay_sec > 0.0:
			yield(get_tree().create_timer(turn_step_delay_sec), "timeout")
			if _is_turn_token_cancelled(active_turn_token):
				turn_state["cancelled"] = true
				turn_state["terminal"] = true
				return turn_state

	var enemy_move_anim = play_move_animation(enemy_move.move_id, enemy_pokemon_sprite, player_pokemon_sprite, active_turn_token)
	if enemy_move_anim is GDScriptFunctionState:
		yield(enemy_move_anim, "completed")
		if _is_turn_token_cancelled(active_turn_token):
			turn_state["cancelled"] = true
			turn_state["terminal"] = true
			return turn_state

	_consume_move_pp(enemy_move)
	var enemy_damage = int(battle_calc_script.calc_damage(defender, enemy_move, attacker, debug_damage_calculation_enabled))
	attacker.current_hp = max(0, attacker.current_hp - enemy_damage)
	var enemy_type_multiplier = battle_calc_script.get_type_multiplier(enemy_move.move_type, attacker)
	refresh_hp_ui(attacker, player_hp_bar, player_hp_value_label)
	sync_active_party_member_from_battle()
	var enemy_hit_feedback = play_hit_feedback(player_pokemon_sprite, active_turn_token)
	if enemy_hit_feedback is GDScriptFunctionState:
		yield(enemy_hit_feedback, "completed")
		if _is_turn_token_cancelled(active_turn_token):
			turn_state["cancelled"] = true
			turn_state["terminal"] = true
			return turn_state

	var enemy_message = "%s used %s! %d damage." % [defender.species_id, enemy_move.move_id, enemy_damage]
	enemy_message += build_type_effectiveness_text(enemy_type_multiplier)
	set_battle_text(enemy_message)
	if turn_step_delay_sec > 0.0:
		yield(get_tree().create_timer(turn_step_delay_sec), "timeout")
		if _is_turn_token_cancelled(active_turn_token):
			turn_state["cancelled"] = true
			turn_state["terminal"] = true
			return turn_state

	if bool(turn_state.get("enemy_using_struggle", false)):
		var enemy_recoil_damage = _apply_struggle_recoil(defender)
		if enemy_recoil_damage > 0:
			refresh_hp_ui(defender, enemy_hp_bar, enemy_hp_value_label)
			set_battle_text("%s was damaged by the recoil!" % String(defender.species_id))
			if turn_step_delay_sec > 0.0:
				yield(get_tree().create_timer(turn_step_delay_sec), "timeout")
				if _is_turn_token_cancelled(active_turn_token):
					turn_state["cancelled"] = true
					turn_state["terminal"] = true
					return turn_state
		if defender.is_fainted():
			turn_state["enemy_fainted"] = true
			turn_state["terminal"] = true
			turn_state["fainted_species_id"] = String(defender.species_id)
			turn_state["defeated_enemy_species_id"] = String(defender.species_id)
			turn_state["defeated_enemy_level"] = int(defender.level)
			return turn_state

	if attacker.is_fainted():
		turn_state["player_fainted"] = true
		turn_state["terminal"] = true
		turn_state["fainted_species_id"] = String(attacker.species_id)

	return turn_state

func _run_turn_faint_resolve_phase_state(turn_state: Dictionary, active_turn_token: int):
	if typeof(turn_state) != TYPE_DICTIONARY:
		return {}
	if bool(turn_state.get("cancelled", false)):
		return turn_state

	if bool(turn_state.get("enemy_fainted", false)):
		var enemy_species_id = String(turn_state.get("fainted_species_id", ""))
		var defeated_species_id = String(turn_state.get("defeated_enemy_species_id", enemy_species_id)).strip_edges().to_upper()
		var defeated_level = int(turn_state.get("defeated_enemy_level", 1))
		var enemy_faint_anim = play_faint_animation(enemy_pokemon_sprite, false, active_turn_token)
		if enemy_faint_anim is GDScriptFunctionState:
			yield(enemy_faint_anim, "completed")
			if _is_turn_token_cancelled(active_turn_token):
				turn_state["cancelled"] = true
				return turn_state
		set_battle_text("%s fainted!" % enemy_species_id)
		if turn_step_delay_sec > 0.0:
			yield(get_tree().create_timer(turn_step_delay_sec), "timeout")
			if _is_turn_token_cancelled(active_turn_token):
				turn_state["cancelled"] = true
				return turn_state
		var exp_flow = _award_exp_for_enemy_result(defeated_species_id, defeated_level, active_turn_token, "defeat")
		if exp_flow is GDScriptFunctionState:
			yield(exp_flow, "completed")
			if _is_turn_token_cancelled(active_turn_token):
				turn_state["cancelled"] = true
				return turn_state
		var enemy_advance = advance_to_next_enemy(enemy_species_id, active_turn_token, false)
		if enemy_advance is GDScriptFunctionState:
			yield(enemy_advance, "completed")
			if _is_turn_token_cancelled(active_turn_token):
				turn_state["cancelled"] = true
		return turn_state

	if bool(turn_state.get("player_fainted", false)):
		var player_species_id = String(turn_state.get("fainted_species_id", ""))
		var player_faint_anim = play_faint_animation(player_pokemon_sprite, true, active_turn_token)
		if player_faint_anim is GDScriptFunctionState:
			yield(player_faint_anim, "completed")
			if _is_turn_token_cancelled(active_turn_token):
				turn_state["cancelled"] = true
				return turn_state
		set_battle_text("%s fainted!" % player_species_id)
		if turn_step_delay_sec > 0.0:
			yield(get_tree().create_timer(turn_step_delay_sec), "timeout")
			if _is_turn_token_cancelled(active_turn_token):
				turn_state["cancelled"] = true
				return turn_state
		_animate_player_panel_to(_player_panel_hidden_position(), max(0.0, player_panel_switch_slide_duration_sec), active_turn_token)
		turn_state["player_faint_species_id"] = player_species_id
		return turn_state

	return turn_state

func _run_turn_player_defeat_gate_phase_state(turn_state: Dictionary, active_turn_token: int) -> Dictionary:
	if typeof(turn_state) != TYPE_DICTIONARY:
		return {}
	if bool(turn_state.get("cancelled", false)):
		return turn_state
	if not bool(turn_state.get("player_fainted", false)):
		return turn_state
	if _is_turn_token_cancelled(active_turn_token):
		turn_state["cancelled"] = true
		return turn_state

	var legal_slots = _get_legal_player_party_slot_indexes(true)
	if legal_slots.empty():
		turn_state["player_defeat"] = true
		turn_state["forced_switch_required"] = false
		turn_state["terminal"] = true
		return turn_state

	turn_state["player_defeat"] = false
	turn_state["forced_switch_required"] = true
	turn_state["terminal"] = false
	return turn_state

func _run_turn_forced_switch_prompt_phase_state(turn_state: Dictionary, active_turn_token: int):
	if typeof(turn_state) != TYPE_DICTIONARY:
		return {}
	if bool(turn_state.get("cancelled", false)):
		return turn_state
	if not bool(turn_state.get("forced_switch_required", false)):
		return turn_state
	if _is_turn_token_cancelled(active_turn_token):
		turn_state["cancelled"] = true
		return turn_state

	var legal_slots = _get_legal_player_party_slot_indexes(true)
	if legal_slots.empty():
		turn_state["player_defeat"] = true
		turn_state["forced_switch_required"] = false
		turn_state["terminal"] = true
		return turn_state

	if faint_to_party_prompt_delay_sec > 0.0:
		yield(get_tree().create_timer(faint_to_party_prompt_delay_sec), "timeout")
		if _is_turn_token_cancelled(active_turn_token):
			turn_state["cancelled"] = true
			return turn_state

	forced_switch_pending = true
	forced_switch_active_turn_token = active_turn_token
	forced_switch_success = false
	open_party_menu(true)
	set_battle_text("Choose a Pokemon to continue the battle.")

	while forced_switch_pending:
		yield(get_tree(), "idle_frame")
		if _is_turn_token_cancelled(active_turn_token):
			forced_switch_pending = false
			forced_switch_active_turn_token = -1
			forced_switch_success = false
			_close_party_menu_internal()
			turn_state["cancelled"] = true
			return turn_state

	turn_state["forced_switch_required"] = false
	turn_state["forced_switch_completed"] = forced_switch_success
	if not forced_switch_success:
		turn_state["player_defeat"] = true
		turn_state["terminal"] = true
	return turn_state

func _run_turn_game_over_phase_state(turn_state: Dictionary, active_turn_token: int):
	if typeof(turn_state) != TYPE_DICTIONARY:
		return {}
	if bool(turn_state.get("cancelled", false)):
		return turn_state
	if not bool(turn_state.get("player_defeat", false)):
		return turn_state
	if _is_turn_token_cancelled(active_turn_token):
		turn_state["cancelled"] = true
		return turn_state

	var player_species_id = String(turn_state.get("player_faint_species_id", turn_state.get("fainted_species_id", "")))
	end_battle(false, player_species_id)
	return turn_state

func _get_legal_player_party_slot_indexes(exclude_active_slot: bool) -> Array:
	if runtime_state_script == null:
		return []
	var party = runtime_state_script.get_party(get_tree())
	if party == null:
		return []

	var legal_slots := []
	var members = party.get_members_copy()
	var active_index = party.get_active_slot_index()
	for slot_index in range(members.size()):
		if exclude_active_slot and slot_index == active_index:
			continue
		var member = members[slot_index]
		if typeof(member) != TYPE_DICTIONARY or member.empty():
			continue
		if int(member.get("current_hp", -1)) == 0:
			continue
		legal_slots.append(slot_index)
	return legal_slots

func _perform_player_switch_to_slot(slot_index: int, active_turn_token: int, allow_enemy_action: bool, finish_turn_on_complete: bool) -> Dictionary:
	if runtime_state_script == null:
		set_battle_text("Switch unavailable: runtime missing.")
		if finish_turn_on_complete:
			_finish_turn()
		return {"ok": false, "cancelled": false}

	var party = runtime_state_script.get_party(get_tree())
	if party == null:
		set_battle_text("Switch unavailable: party state missing.")
		if finish_turn_on_complete:
			_finish_turn()
		return {"ok": false, "cancelled": false}

	var members = party.get_members_copy()
	if slot_index < 0 or slot_index >= members.size():
		set_battle_text("Invalid switch target.")
		if finish_turn_on_complete:
			_finish_turn()
		return {"ok": false, "cancelled": false}

	var member = members[slot_index]
	if typeof(member) != TYPE_DICTIONARY or member.empty():
		set_battle_text("Invalid switch target.")
		if finish_turn_on_complete:
			_finish_turn()
		return {"ok": false, "cancelled": false}

	var active_index = party.get_active_slot_index()
	if slot_index == active_index:
		set_battle_text("That Pokemon is already active.")
		if finish_turn_on_complete:
			_finish_turn()
		return {"ok": false, "cancelled": false}

	var current_hp = int(member.get("current_hp", -1))
	if current_hp == 0:
		set_battle_text("That Pokemon cannot battle.")
		if finish_turn_on_complete:
			_finish_turn()
		return {"ok": false, "cancelled": false}

	var species_label = String(member.get("species_id", "POKEMON")).strip_edges().to_upper()
	if species_label.empty():
		species_label = "POKEMON"
	var outgoing_species_label = "POKEMON"
	if battle_data != null and battle_data.has("player") and battle_data["player"] != null:
		outgoing_species_label = String(battle_data["player"].species_id).strip_edges().to_upper()
		if outgoing_species_label.empty():
			outgoing_species_label = "POKEMON"

	sync_active_party_member_from_battle()
	set_battle_text("Come back! %s!" % outgoing_species_label)
	var recall_anim = _play_player_switch_withdraw_animation(active_turn_token)
	if recall_anim is GDScriptFunctionState:
		yield(recall_anim, "completed")
		if active_turn_token != turn_token:
			return {"ok": false, "cancelled": true}

	var incoming_player_data = _build_player_data_from_party_member(member)
	if incoming_player_data == null:
		set_battle_text("Switch failed: could not load %s." % species_label)
		if finish_turn_on_complete:
			_finish_turn()
		return {"ok": false, "cancelled": false}

	var set_active_result = party.swap_active_with_slot(slot_index)
	if not bool(set_active_result.get("ok", false)):
		set_battle_text("Switch failed: invalid party slot.")
		if finish_turn_on_complete:
			_finish_turn()
		return {"ok": false, "cancelled": false}

	battle_data["player"] = incoming_player_data
	_close_party_menu_internal()
	load_battle_sprites()
	bind_battle_data()
	player_sprite_anim_enabled = true
	enemy_sprite_anim_enabled = true
	restore_battler_sprite_state(enemy_pokemon_sprite, enemy_sprite_home_position)
	reset_pokemon_animation_state()
	if player_pokemon_sprite != null:
		player_pokemon_sprite.visible = false
		player_pokemon_sprite.position = player_sprite_home_position
		player_pokemon_sprite.scale = player_sprite_home_scale
		player_pokemon_sprite.modulate = Color(1, 1, 1, 1)
	player_sendout_cry_played = false
	set_battle_text("Go! %s!" % species_label)
	var sendout_anim = _play_player_switch_sendout_animation(active_turn_token)
	if sendout_anim is GDScriptFunctionState:
		yield(sendout_anim, "completed")
		if active_turn_token != turn_token:
			return {"ok": false, "cancelled": true}

	if turn_step_delay_sec > 0.0:
		yield(get_tree().create_timer(turn_step_delay_sec), "timeout")
		if active_turn_token != turn_token:
			return {"ok": false, "cancelled": true}

	if allow_enemy_action:
		var enemy_action = _run_enemy_action_after_player_switch(incoming_player_data, active_turn_token)
		if enemy_action is GDScriptFunctionState:
			yield(enemy_action, "completed")
			if active_turn_token != turn_token:
				return {"ok": false, "cancelled": true}

	if not battle_ended:
		set_main_command_prompt()
	if finish_turn_on_complete:
		_finish_turn()
	return {"ok": true, "cancelled": false}

func _run_turn_end_unlock_phase_state(turn_state: Dictionary, _active_turn_token: int) -> Dictionary:
	if typeof(turn_state) != TYPE_DICTIONARY:
		return {}
	if bool(turn_state.get("cancelled", false)):
		return turn_state
	_finish_turn()
	return turn_state

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
	if battle_ended or turn_in_progress or capture_in_progress:
		return

	attempt_run_from_battle()

func attempt_run_from_battle() -> void:
	if battle_ended or turn_in_progress or capture_in_progress:
		return

	turn_in_progress = true
	var active_turn_token = turn_token

	var run_context := {
		"aborted": false,
		"run_state": {
			"active_turn_token": active_turn_token,
			"cancelled": false,
			"run_allowed": false,
			"run_success": false,
			"blocked_reason": "",
		},
	}

	var phase_runner = battle_phase_runner_script.new()
	phase_runner.push_phase(run_resolve_phase_script.new(self, run_context, active_turn_token))
	phase_runner.push_phase(run_finalize_phase_script.new(self, run_context, active_turn_token))

	if phase_runner.is_running():
		yield(phase_runner, "queue_idle")

	if active_turn_token != turn_token:
		turn_in_progress = false
		return

	var run_state = run_context.get("run_state", {})
	if typeof(run_state) != TYPE_DICTIONARY:
		_finish_turn()
		return

	if bool(run_state.get("run_success", false)):
		turn_in_progress = false
		return

	_finish_turn()

func _run_run_resolve_phase_state(run_state: Dictionary, _active_turn_token: int) -> Dictionary:
	if typeof(run_state) != TYPE_DICTIONARY:
		return {}

	_enter_action_locked_state()

	if _is_active_trainer_encounter():
		run_state["run_allowed"] = false
		run_state["blocked_reason"] = "trainer"
		return run_state

	run_state["run_allowed"] = true
	run_state["blocked_reason"] = ""
	return run_state

func _run_run_finalize_phase_state(run_state: Dictionary, active_turn_token: int):
	if typeof(run_state) != TYPE_DICTIONARY:
		return {}
	if _is_turn_token_cancelled(active_turn_token):
		run_state["cancelled"] = true
		return run_state

	if not bool(run_state.get("run_allowed", false)):
		set_battle_text("You cannot run from a trainer battle.")
		return run_state

	run_state["run_success"] = true
	set_battle_text("Got away safely!")
	var timer = get_tree().create_timer(max(0.0, run_return_delay_sec))
	yield(timer, "timeout")
	if _is_turn_token_cancelled(active_turn_token):
		run_state["cancelled"] = true
		return run_state

	var fade_out = _play_run_escape_fade_out(active_turn_token)
	if fade_out is GDScriptFunctionState:
		yield(fade_out, "completed")
	if _is_turn_token_cancelled(active_turn_token):
		run_state["cancelled"] = true
		return run_state

	battle_ended = false
	capture_in_progress = false

	var escaped_species_id = ""
	if typeof(battle_data) == TYPE_DICTIONARY and battle_data.has("enemy") and battle_data["enemy"] != null:
		escaped_species_id = String(battle_data["enemy"].species_id).strip_edges().to_upper()
	if escaped_species_id.empty():
		escaped_species_id = "UNKNOWN"

	var next_transition = advance_to_next_enemy(escaped_species_id, active_turn_token, false)
	if next_transition is GDScriptFunctionState:
		yield(next_transition, "completed")

	_reset_run_escape_fade_visuals()
	if not battle_ended:
		_show_main_controls_unlocked()

	return run_state

func _play_run_escape_fade_out(active_turn_token: int):
	var nodes := _get_run_escape_fade_nodes()
	if nodes.empty():
		return null

	var duration = max(0.01, run_escape_fade_duration_sec)
	var fade_tween = Tween.new()
	add_child(fade_tween)

	for node in nodes:
		if node == null or not is_instance_valid(node):
			continue
		fade_tween.interpolate_property(
			node,
			"modulate:a",
			node.modulate.a,
			0.0,
			duration,
			Tween.TRANS_SINE,
			Tween.EASE_IN_OUT
		)

	fade_tween.start()
	yield(fade_tween, "tween_all_completed")
	fade_tween.queue_free()

	if _is_turn_token_cancelled(active_turn_token):
		return null

	return null

func _get_run_escape_fade_nodes() -> Array:
	var nodes := []
	for arena_node in [enemy_arena_sprite, enemy_arena_sprite_1, enemy_arena_sprite_2, enemy_arena_sprite_3]:
		if arena_node == null or not is_instance_valid(arena_node):
			continue
		nodes.append(arena_node)

	for extra in [enemy_pokemon_sprite]:
		if extra == null or not is_instance_valid(extra):
			continue
		if not nodes.has(extra):
			nodes.append(extra)
	return nodes

func _reset_run_escape_fade_visuals() -> void:
	for node in _get_run_escape_fade_nodes():
		if node == null or not is_instance_valid(node):
			continue
		var color = node.modulate
		node.modulate = Color(color.r, color.g, color.b, 1.0)

func _award_exp_for_enemy_result(defeated_species_id: String, defeated_level: int, active_turn_token: int, source: String = "defeat"):
	if runtime_state_script == null:
		return null
	var party = runtime_state_script.get_party(get_tree())
	if party == null:
		return null
	var active_index = party.get_active_slot_index()
	if active_index < 0:
		return null

	var exp_context := {
		"aborted": false,
		"exp_state": {
			"source": source,
			"active_turn_token": active_turn_token,
			"party_member_index": active_index,
			"defeated_species_id": defeated_species_id.strip_edges().to_upper(),
			"defeated_level": max(1, int(defeated_level)),
			"cancelled": false,
			"awarded_exp": 0,
			"level_before": 0,
			"level_after": 0,
			"party_level_ups": [],
		},
	}

	var phase_runner = battle_phase_runner_script.new()
	phase_runner.push_phase(exp_resolve_phase_script.new(self, exp_context, active_turn_token))
	phase_runner.push_phase(exp_apply_phase_script.new(self, exp_context, active_turn_token))
	phase_runner.push_phase(exp_evolution_phase_script.new(self, exp_context, active_turn_token))
	phase_runner.push_phase(exp_party_apply_phase_script.new(self, exp_context, active_turn_token))
	phase_runner.push_phase(exp_party_evolution_phase_script.new(self, exp_context, active_turn_token))

	if phase_runner.is_running():
		yield(phase_runner, "queue_idle")

	return exp_context.get("exp_state", {})

func _run_exp_resolve_phase_state(exp_state: Dictionary, active_turn_token: int) -> Dictionary:
	if typeof(exp_state) != TYPE_DICTIONARY:
		return {}
	if _is_turn_token_cancelled(active_turn_token):
		exp_state["cancelled"] = true
		return exp_state

	var species_id = String(exp_state.get("defeated_species_id", "")).strip_edges().to_upper()
	var defeated_level = max(1, int(exp_state.get("defeated_level", 1)))
	var enemy_base_exp = _get_species_base_exp(species_id)
	var exp_value = int(floor((float(enemy_base_exp) * float(defeated_level)) / 5.0 + 1.0))

	if _is_active_trainer_encounter():
		exp_value = int(floor(float(exp_value) * 1.5))

	exp_value = int(floor(float(exp_value) * max(0.0, exp_gain_multiplier)))
	if debug_defeat_exp_override >= 0:
		exp_value = max(0, debug_defeat_exp_override)
	elif exp_override_value >= 0:
		exp_value = max(0, exp_override_value)

	exp_state["awarded_exp"] = max(0, exp_value)
	return exp_state

func _run_exp_apply_phase_state(exp_state: Dictionary, active_turn_token: int):
	if typeof(exp_state) != TYPE_DICTIONARY:
		return {}
	if _is_turn_token_cancelled(active_turn_token):
		exp_state["cancelled"] = true
		return exp_state

	var awarded_exp = max(0, int(exp_state.get("awarded_exp", 0)))
	if awarded_exp <= 0:
		return exp_state

	if runtime_state_script == null:
		return exp_state
	var party = runtime_state_script.get_party(get_tree())
	if party == null:
		return exp_state

	var active_index = int(exp_state.get("party_member_index", -1))
	if active_index < 0:
		active_index = party.get_active_slot_index()
	if active_index < 0:
		return exp_state

	var member = party.get_member_at(active_index)
	if member.empty():
		return exp_state

	var active_exp_result = _apply_exp_to_party_member(party, active_index, awarded_exp)
	if active_exp_result.empty():
		return exp_state

	var species_id = String(active_exp_result.get("species_id", "")).strip_edges().to_upper()
	var growth_rate = String(active_exp_result.get("growth_rate", "MEDIUM_FAST"))
	var level_before = int(active_exp_result.get("level_before", 1))
	var level_after = int(active_exp_result.get("level_after", level_before))
	var member_exp = int(active_exp_result.get("member_exp_before", 0))
	var member_exp_after = int(active_exp_result.get("member_exp_after", member_exp))

	exp_state["level_before"] = level_before
	exp_state["level_after"] = level_after
	exp_state["active_species_id"] = species_id

	set_battle_text("%s gained %d EXP." % [species_id, awarded_exp])
	var exp_anim_state = _animate_player_exp_gain_bar(member_exp, member_exp_after, level_before, level_after, growth_rate, active_turn_token)
	if exp_anim_state is GDScriptFunctionState:
		var exp_anim_ok = yield(exp_anim_state, "completed")
		if not exp_anim_ok:
			exp_state["cancelled"] = true
			return exp_state
	elif not bool(exp_anim_state):
		exp_state["cancelled"] = true
		return exp_state
	if exp_message_hold_sec > 0.0:
		yield(get_tree().create_timer(exp_message_hold_sec), "timeout")
	if _is_turn_token_cancelled(active_turn_token):
		exp_state["cancelled"] = true
		return exp_state

	if level_after > level_before:
		set_battle_text("%s grew to Lv.%d!" % [species_id, level_after])
		if exp_message_hold_sec > 0.0:
			yield(get_tree().create_timer(exp_message_hold_sec), "timeout")
		if _is_turn_token_cancelled(active_turn_token):
			exp_state["cancelled"] = true
			return exp_state

	if typeof(battle_data) == TYPE_DICTIONARY and battle_data.has("player") and battle_data["player"] != null:
		var player_data = battle_data["player"]
		if String(player_data.species_id).strip_edges().to_upper() == species_id:
			player_data.level = level_after
			sync_active_party_member_from_battle()
	_refresh_player_exp_label()

	return exp_state

func _run_exp_party_apply_phase_state(exp_state: Dictionary, active_turn_token: int):
	if typeof(exp_state) != TYPE_DICTIONARY:
		return {}
	if _is_turn_token_cancelled(active_turn_token):
		exp_state["cancelled"] = true
		return exp_state

	var awarded_exp = max(0, int(exp_state.get("awarded_exp", 0)))
	if awarded_exp <= 0:
		return exp_state

	if runtime_state_script == null:
		return exp_state
	var party = runtime_state_script.get_party(get_tree())
	if party == null:
		return exp_state

	var active_index = int(exp_state.get("party_member_index", -1))
	if active_index < 0:
		active_index = party.get_active_slot_index()

	var party_exp_state = _run_party_exp_sequence(party, active_index, awarded_exp, active_turn_token)
	if party_exp_state is GDScriptFunctionState:
		party_exp_state = yield(party_exp_state, "completed")
	if typeof(party_exp_state) != TYPE_DICTIONARY:
		exp_state["cancelled"] = true
		return exp_state
	if not bool(party_exp_state.get("ok", false)):
		exp_state["cancelled"] = true
		return exp_state

	exp_state["party_level_ups"] = party_exp_state.get("party_level_ups", [])
	return exp_state

func _run_exp_evolution_phase_state(exp_state: Dictionary, active_turn_token: int):
	if typeof(exp_state) != TYPE_DICTIONARY:
		return {}
	if _is_turn_token_cancelled(active_turn_token):
		exp_state["cancelled"] = true
		return exp_state

	var level_before = int(exp_state.get("level_before", 0))
	var level_after = int(exp_state.get("level_after", level_before))
	if level_after <= level_before:
		return exp_state

	if runtime_state_script == null:
		return exp_state
	var party = runtime_state_script.get_party(get_tree())
	if party == null:
		return exp_state

	var active_index = int(exp_state.get("party_member_index", -1))
	if active_index < 0:
		active_index = party.get_active_slot_index()
	if active_index < 0:
		return exp_state

	var active_species_id = String(exp_state.get("active_species_id", "")).strip_edges().to_upper()
	if active_species_id.empty():
		var active_member = party.get_member_at(active_index)
		if not active_member.empty():
			active_species_id = String(active_member.get("species_id", "")).strip_edges().to_upper()

	if active_species_id.empty():
		return exp_state

	var target_species_id = _resolve_level_up_evolution_target_species_id(active_species_id, level_after)
	if target_species_id.empty():
		return exp_state

	var use_overlay_messages = pokemon_evolution_overlay != null
	if not use_overlay_messages:
		set_battle_text("What? %s is evolving!" % active_species_id)
		if exp_message_hold_sec > 0.0:
			yield(get_tree().create_timer(exp_message_hold_sec), "timeout")
		if _is_turn_token_cancelled(active_turn_token):
			exp_state["cancelled"] = true
			return exp_state

	var overlay_state = _play_evolution_overlay_sequence(active_species_id, target_species_id, active_turn_token)
	if overlay_state is GDScriptFunctionState:
		overlay_state = yield(overlay_state, "completed")
	if not bool(overlay_state):
		exp_state["cancelled"] = true
		return exp_state

	var evolution_result = _apply_active_level_up_evolution_if_eligible(party, active_index, level_after)
	if evolution_result.empty():
		return exp_state

	var from_species_id = String(evolution_result.get("from_species_id", active_species_id)).strip_edges().to_upper()
	var to_species_id = String(evolution_result.get("to_species_id", "")).strip_edges().to_upper()
	if to_species_id.empty():
		return exp_state

	exp_state["evolved"] = true
	exp_state["evolved_from_species_id"] = from_species_id
	exp_state["evolved_to_species_id"] = to_species_id
	exp_state["active_species_id"] = to_species_id

	if not use_overlay_messages:
		set_battle_text("%s evolved into %s!" % [from_species_id, to_species_id])
		if exp_message_hold_sec > 0.0:
			yield(get_tree().create_timer(exp_message_hold_sec), "timeout")
		if _is_turn_token_cancelled(active_turn_token):
			exp_state["cancelled"] = true
			return exp_state

	return exp_state

func _run_exp_party_evolution_phase_state(exp_state: Dictionary, active_turn_token: int):
	if typeof(exp_state) != TYPE_DICTIONARY:
		return {}
	if _is_turn_token_cancelled(active_turn_token):
		exp_state["cancelled"] = true
		return exp_state

	var party_level_ups = exp_state.get("party_level_ups", [])
	if typeof(party_level_ups) != TYPE_ARRAY or party_level_ups.empty():
		return exp_state

	if runtime_state_script == null:
		return exp_state
	var party = runtime_state_script.get_party(get_tree())
	if party == null:
		return exp_state

	for entry in party_level_ups:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		if _is_turn_token_cancelled(active_turn_token):
			exp_state["cancelled"] = true
			return exp_state

		var slot_index = int(entry.get("slot_index", -1))
		if slot_index < 0:
			continue
		var level_before = int(entry.get("level_before", 1))
		var level_after = int(entry.get("level_after", level_before))
		if level_after <= level_before:
			continue

		var member = party.get_member_at(slot_index)
		if member.empty():
			continue
		var from_species_id = String(member.get("species_id", "")).strip_edges().to_upper()
		if from_species_id.empty():
			continue
		var target_species_id = _resolve_level_up_evolution_target_species_id(from_species_id, level_after)
		if target_species_id.empty():
			continue

		var use_overlay_messages = pokemon_evolution_overlay != null
		if not use_overlay_messages:
			set_battle_text("What? %s is evolving!" % from_species_id)
			if exp_message_hold_sec > 0.0:
				yield(get_tree().create_timer(exp_message_hold_sec), "timeout")
			if _is_turn_token_cancelled(active_turn_token):
				exp_state["cancelled"] = true
				return exp_state

		var overlay_state = _play_evolution_overlay_sequence(from_species_id, target_species_id, active_turn_token)
		if overlay_state is GDScriptFunctionState:
			overlay_state = yield(overlay_state, "completed")
		if not bool(overlay_state):
			exp_state["cancelled"] = true
			return exp_state

		var evolution_result = _apply_party_member_level_up_evolution_if_eligible(party, slot_index, level_after)
		if evolution_result.empty():
			continue

		from_species_id = String(evolution_result.get("from_species_id", "")).strip_edges().to_upper()
		var to_species_id = String(evolution_result.get("to_species_id", "")).strip_edges().to_upper()
		if from_species_id.empty() or to_species_id.empty():
			continue

		if not use_overlay_messages:
			set_battle_text("%s evolved into %s!" % [from_species_id, to_species_id])
			if exp_message_hold_sec > 0.0:
				yield(get_tree().create_timer(exp_message_hold_sec), "timeout")
			if _is_turn_token_cancelled(active_turn_token):
				exp_state["cancelled"] = true
				return exp_state

	exp_state["party_level_ups"] = []
	return exp_state

func _get_species_entry(species_id: String) -> Dictionary:
	if species_id.strip_edges().empty():
		return {}
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()
	if catalog_loader == null or not catalog_loader.load_catalogs():
		return {}
	return catalog_loader.get_species(species_id)

func _get_species_base_exp(species_id: String) -> int:
	var species_entry = _get_species_entry(species_id)
	if species_entry.empty():
		return 64
	var value = int(species_entry.get("base_exp", 64))
	if value <= 0:
		value = 1
	return value

func _get_species_growth_rate(species_id: String) -> String:
	var species_entry = _get_species_entry(species_id)
	if species_entry.empty():
		return "MEDIUM_FAST"
	var growth_rate = String(species_entry.get("growth_rate", "MEDIUM_FAST")).strip_edges().to_upper()
	return growth_rate if not growth_rate.empty() else "MEDIUM_FAST"

func _resolve_level_up_evolution_target_species_id(species_id: String, level_after: int) -> String:
	var safe_species_id = species_id.strip_edges().to_upper()
	if safe_species_id.empty():
		return ""

	var species_entry = _get_species_entry(safe_species_id)
	if species_entry.empty():
		return ""

	var evolution_rules = species_entry.get("evolution_rules", [])
	if typeof(evolution_rules) != TYPE_ARRAY:
		return ""

	for raw_rule in evolution_rules:
		if typeof(raw_rule) != TYPE_DICTIONARY:
			continue

		var target_species_id = String(raw_rule.get("target_species_id", "")).strip_edges().to_upper()
		if target_species_id.empty() or target_species_id == safe_species_id:
			continue

		var min_level = max(1, int(raw_rule.get("min_level", 1)))
		if level_after < min_level:
			continue

		if raw_rule.has("item") and not String(raw_rule.get("item", "")).strip_edges().empty():
			continue

		if raw_rule.has("pre_form_key") and not String(raw_rule.get("pre_form_key", "")).strip_edges().empty():
			continue

		if raw_rule.has("evo_form_key") and not String(raw_rule.get("evo_form_key", "")).strip_edges().empty():
			continue

		var conditions = raw_rule.get("conditions", [])
		if typeof(conditions) != TYPE_ARRAY or not conditions.empty():
			continue

		return target_species_id

	return ""

func _apply_active_level_up_evolution_if_eligible(party, active_index: int, level_after: int) -> Dictionary:
	if party == null or active_index < 0:
		return {}

	var member = party.get_member_at(active_index)
	if member.empty():
		return {}

	var from_species_id = String(member.get("species_id", "")).strip_edges().to_upper()
	if from_species_id.empty():
		return {}

	var to_species_id = _resolve_level_up_evolution_target_species_id(from_species_id, level_after)
	if to_species_id.empty():
		return {}

	var update_result = party.update_member_at(active_index, {
		"species_id": to_species_id,
		"level": level_after,
	})
	if typeof(update_result) == TYPE_DICTIONARY and not bool(update_result.get("ok", false)):
		return {}

	var updated_member = party.get_member_at(active_index)
	if updated_member.empty():
		return {}

	var evolved_player_data = _build_player_data_from_party_member(updated_member)
	if evolved_player_data != null and typeof(battle_data) == TYPE_DICTIONARY:
		battle_data["player"] = evolved_player_data
		selected_player_species_id = to_species_id

	if runtime_state_script != null:
		runtime_state_script.add_caught_species(get_tree(), to_species_id)

	bind_battle_data()
	load_battle_sprites()

	return {
		"from_species_id": from_species_id,
		"to_species_id": to_species_id,
	}

func _apply_party_member_level_up_evolution_if_eligible(party, slot_index: int, level_after: int) -> Dictionary:
	if party == null or slot_index < 0:
		return {}

	var member = party.get_member_at(slot_index)
	if member.empty():
		return {}

	var from_species_id = String(member.get("species_id", "")).strip_edges().to_upper()
	if from_species_id.empty():
		return {}

	var to_species_id = _resolve_level_up_evolution_target_species_id(from_species_id, level_after)
	if to_species_id.empty():
		return {}

	var update_result = party.update_member_at(slot_index, {
		"species_id": to_species_id,
		"level": level_after,
	})
	if typeof(update_result) == TYPE_DICTIONARY and not bool(update_result.get("ok", false)):
		return {}

	if runtime_state_script != null:
		runtime_state_script.add_caught_species(get_tree(), to_species_id)

	return {
		"from_species_id": from_species_id,
		"to_species_id": to_species_id,
	}

func _get_level_total_exp(level: int, growth_rate: String) -> int:
	var safe_level = max(1, level)
	var normalized_growth = growth_rate.strip_edges().to_upper()
	if normalized_growth.empty():
		normalized_growth = "MEDIUM_FAST"

	var medium_fast = pow(float(safe_level), 3.0)
	var base_total = medium_fast
	var lv = float(safe_level)

	match normalized_growth:
		"ERRATIC":
			if safe_level <= 50:
				base_total = pow(lv, 3.0) * (100.0 - lv) / 50.0
			elif safe_level <= 68:
				base_total = pow(lv, 3.0) * (150.0 - lv) / 100.0
			elif safe_level <= 98:
				base_total = pow(lv, 3.0) * (1911.0 - 10.0 * lv) / 1500.0
			else:
				base_total = pow(lv, 3.0) * (160.0 - lv) / 100.0
		"FAST":
			base_total = pow(lv, 3.0) * 4.0 / 5.0
		"MEDIUM_SLOW":
			base_total = pow(lv, 3.0) * 6.0 / 5.0 - 15.0 * pow(lv, 2.0) + 100.0 * lv - 140.0
		"SLOW":
			base_total = pow(lv, 3.0) * 5.0 / 4.0
		"FLUCTUATING":
			if safe_level <= 15:
				base_total = pow(lv, 3.0) * (((lv + 1.0) / 3.0) + 24.0) / 50.0
			elif safe_level <= 36:
				base_total = pow(lv, 3.0) * (lv + 14.0) / 50.0
			else:
				base_total = pow(lv, 3.0) * ((lv / 2.0) + 32.0) / 50.0
		_:
			base_total = medium_fast

	if normalized_growth != "MEDIUM_FAST":
		var blended_value = int(floor(base_total * 0.325 + medium_fast * 0.675))
		if blended_value < 0:
			blended_value = 0
		return blended_value
	var base_value = int(floor(base_total))
	if base_value < 0:
		base_value = 0
	return base_value

# Capture flow and ball handling.
func attempt_capture_with_ball(ball_key: String) -> void:
	if battle_ended or turn_in_progress or capture_in_progress:
		return
	if _is_active_trainer_encounter():
		set_battle_text("You cannot catch a trainer's Pokemon.")
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

	turn_in_progress = true
	capture_in_progress = true
	var active_turn_token = turn_token
	active_capture_run_id = _next_capture_run_id()
	_log_capture_checkpoint("entry", {
		"active_turn_token": active_turn_token,
		"ball_key": ball_key,
	})

	var capture_context := {
		"aborted": false,
		"capture_state": {
			"ball_key": ball_key,
			"active_turn_token": active_turn_token,
			"available": available,
			"cancelled": false,
			"capture_success": false,
			"enemy": null,
		},
	}

	var phase_runner = battle_phase_runner_script.new()
	phase_runner.push_phase(capture_begin_phase_script.new(self, capture_context, active_turn_token))
	phase_runner.push_phase(capture_sequence_phase_script.new(self, capture_context, active_turn_token))
	phase_runner.push_phase(capture_post_encounter_phase_script.new(self, capture_context, active_turn_token))

	if phase_runner.is_running():
		yield(phase_runner, "queue_idle")

	if active_turn_token != turn_token:
		capture_in_progress = false
		_log_capture_checkpoint("queue_idle", {
			"cancelled": true,
		})
		active_capture_run_id = ""
		return

	capture_in_progress = false
	_finish_turn()

	var capture_state = capture_context.get("capture_state", {})
	if typeof(capture_state) == TYPE_DICTIONARY:
		_log_capture_checkpoint("queue_idle", {
			"cancelled": bool(capture_state.get("cancelled", false)),
			"capture_success": bool(capture_state.get("capture_success", false)),
		})
	else:
		_log_capture_checkpoint("queue_idle")
	active_capture_run_id = ""

func _run_capture_begin_phase_state(capture_state: Dictionary, _active_turn_token: int) -> Dictionary:
	if typeof(capture_state) != TYPE_DICTIONARY:
		return {}
	var ball_key = String(capture_state.get("ball_key", "")).strip_edges().to_lower()
	var available = int(capture_state.get("available", 0))
	if ball_key.empty() or available <= 0:
		capture_state["cancelled"] = true
		return capture_state

	ball_inventory[ball_key] = max(0, available - 1)
	refresh_ball_menu_labels()
	_enter_action_locked_state()

	if typeof(battle_data) == TYPE_DICTIONARY and battle_data.has("enemy") and battle_data["enemy"] != null:
		capture_state["enemy"] = battle_data["enemy"]
	else:
		capture_state["cancelled"] = true

	return capture_state

func _run_capture_sequence_phase_state(capture_state: Dictionary, active_turn_token: int):
	if typeof(capture_state) != TYPE_DICTIONARY:
		return {}
	if bool(capture_state.get("cancelled", false)):
		return capture_state

	var ball_key = String(capture_state.get("ball_key", "")).strip_edges().to_lower()
	var enemy = capture_state.get("enemy", null)
	if ball_key.empty() or enemy == null:
		capture_state["cancelled"] = true
		return capture_state

	set_battle_text("You threw a %s!" % _get_ball_label(ball_key))
	_play_capture_sfx("pb_throw.wav")

	var throw_anim = _play_capture_throw_open_animation(ball_key, active_turn_token)
	if throw_anim is GDScriptFunctionState:
		yield(throw_anim, "completed")
	if _is_turn_token_cancelled(active_turn_token):
		capture_state["cancelled"] = true
		return capture_state

	var shake_successes = _roll_capture_shakes(ball_key, enemy)
	var capture_success = shake_successes >= CAPTURE_REQUIRED_SHAKES
	capture_state["shake_successes"] = shake_successes
	capture_state["capture_success"] = capture_success
	var shake_anim = _play_capture_shakes(ball_key, enemy, shake_successes, capture_success, active_turn_token)
	if shake_anim is GDScriptFunctionState:
		yield(shake_anim, "completed")
	if _is_turn_token_cancelled(active_turn_token):
		capture_state["cancelled"] = true

	return capture_state

func _run_capture_post_encounter_phase_state(capture_state: Dictionary, active_turn_token: int):
	if typeof(capture_state) != TYPE_DICTIONARY:
		return {}
	if bool(capture_state.get("cancelled", false)):
		return capture_state

	var enemy = capture_state.get("enemy", null)
	if enemy == null:
		capture_state["cancelled"] = true
		return capture_state

	if bool(capture_state.get("capture_success", false)):
		var success_flow = _handle_capture_success(enemy, active_turn_token)
		if success_flow is GDScriptFunctionState:
			yield(success_flow, "completed")
		if _is_turn_token_cancelled(active_turn_token):
			capture_state["cancelled"] = true
		return capture_state

	_handle_capture_failure(enemy)
	return capture_state

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
	if runtime_state_script != null:
		runtime_state_script.add_caught_species(get_tree(), enemy_species_id)
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

	var capture_exp_flow = _award_exp_for_enemy_result(enemy_species_id, int(enemy.level), active_turn_token, "capture")
	if capture_exp_flow is GDScriptFunctionState:
		yield(capture_exp_flow, "completed")
	if active_turn_token != turn_token:
		return null

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
	var enemy_slide_out = animate_enemy_layer_to(
		enemy_layer_home_position + Vector2(enemy_switch_slide_distance_px, 0),
		enemy_switch_slide_duration_sec,
		active_turn_token
	)
	_animate_enemy_panel_to(_enemy_panel_hidden_position(), max(0.0, enemy_panel_slide_duration_sec), active_turn_token)
	if enemy_slide_out is GDScriptFunctionState:
		yield(enemy_slide_out, "completed")
		if active_turn_token != -1 and active_turn_token != turn_token:
			return null

	var next_biome_state = _advance_runtime_biome_state("capture_resolved")
	var next_encounter_meta = _build_encounter_metadata(next_biome_state, "")
	var next_enemy_species_id = _pick_biome_weighted_enemy_species_id(captured_species_id, next_biome_state, next_encounter_meta)
	var next_enemy = null
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()
	if catalog_loader != null and catalog_loader.load_catalogs():
		next_enemy = catalog_loader.build_pokemon_data(next_enemy_species_id, 5)

	if next_enemy == null:
		end_battle(true, captured_species_id)
		return null

	battle_data["enemy"] = next_enemy
	_apply_biome_state_to_battle_data(next_biome_state)
	enemy_layer.rect_position = enemy_layer_home_position + Vector2(-enemy_switch_slide_distance_px, 0)
	if enemy_panel != null:
		enemy_panel.rect_position = _enemy_panel_hidden_position()
	load_battle_sprites()
	bind_battle_data()
	player_sprite_anim_enabled = true
	enemy_sprite_anim_enabled = true
	restore_battler_sprite_state(player_pokemon_sprite, player_sprite_home_position)
	restore_battler_sprite_state(enemy_pokemon_sprite, enemy_sprite_home_position)
	reset_pokemon_animation_state()
	var enemy_slide_in = animate_enemy_layer_to(enemy_layer_home_position, enemy_switch_slide_duration_sec, active_turn_token)
	_animate_enemy_panel_to(enemy_panel_home_position, max(0.0, enemy_panel_slide_duration_sec), active_turn_token)
	if enemy_slide_in is GDScriptFunctionState:
		yield(enemy_slide_in, "completed")
		if active_turn_token != -1 and active_turn_token != turn_token:
			return null

	set_battle_text(_build_enemy_appeared_message(String(next_enemy.species_id)))
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
	if battle_ended:
		return
	if sendout_controls_locked:
		hide_all_command_menus()
		set_action_lock(true)
		return
	_show_main_controls_unlocked()

func end_battle(player_won: bool, fainted_species_id: String):
	battle_ended = true
	if player_won:
		_animate_enemy_panel_to(_enemy_panel_hidden_position(), max(0.0, enemy_panel_slide_duration_sec))
		var encounter_meta = battle_data.get("encounter_meta", {}) if typeof(battle_data) == TYPE_DICTIONARY else {}
		var is_trainer_encounter = bool(encounter_meta.get("is_trainer_encounter", false))
		if is_trainer_encounter:
			_enter_action_locked_state()
			if ball_button != null:
				ball_button.disabled = true
			var trainer_outro = _run_trainer_victory_outro_and_start_next_encounter(fainted_species_id)
			if trainer_outro is GDScriptFunctionState:
				yield(trainer_outro, "completed")
			return

		_show_main_controls_locked()

		ball_button.disabled = false
		ball_button.grab_focus()
		set_battle_text("%s fainted! You win! Press Ball to restart." % fainted_species_id)
		return

	# Defeat recovery path: return to main menu.
	_animate_player_panel_to(_player_panel_hidden_position(), max(0.0, player_panel_switch_slide_duration_sec))
	_enter_action_locked_state()
	set_battle_text("%s fainted! You lose! Returning to main menu..." % fainted_species_id)
	var timer = get_tree().create_timer(max(0.0, defeat_return_delay_sec))
	_connect_once(timer, "timeout", "_return_to_main_scene")

func _resolve_trainer_defeat_message() -> String:
	var trainer_name = String(battle_data.get("enemy_trainer_name", "Trainer")).strip_edges()
	if trainer_name.empty():
		trainer_name = "Trainer"

	var defeat_key = String(battle_data.get("enemy_trainer_defeat_key", "")).strip_edges()
	if not defeat_key.empty():
		return "%s: %s" % [trainer_name, defeat_key]

	return "%s has no Pokemon left!" % trainer_name

func _apply_trainer_seed_to_battle_data(trainer_seed: Dictionary) -> void:
	if typeof(battle_data) != TYPE_DICTIONARY or trainer_seed.empty():
		return
	battle_data["enemy_trainer_id"] = String(trainer_seed.get("trainer_id", "")).strip_edges().to_upper()
	battle_data["enemy_trainer_name"] = String(trainer_seed.get("display_name", "Trainer")).strip_edges()
	battle_data["enemy_trainer_sprite_asset_id"] = String(trainer_seed.get("sprite_asset_id", "")).strip_edges().to_lower()
	battle_data["enemy_trainer_defeat_key"] = String(trainer_seed.get("defeat_key", "")).strip_edges()
	battle_data["enemy_trainer_encounter_bgm"] = String(trainer_seed.get("encounter_bgm", "")).strip_edges()
	battle_data["enemy_trainer_battle_bgm"] = String(trainer_seed.get("battle_bgm", "")).strip_edges()
	battle_data["enemy_trainer_victory_bgm"] = String(trainer_seed.get("victory_bgm", "")).strip_edges()
	battle_data["enemy_trainer_party_total"] = int(trainer_seed.get("party_total", 1))
	battle_data["enemy_trainer_is_boss"] = bool(trainer_seed.get("is_boss", false))
	battle_data["enemy_trainer_party_remaining"] = trainer_seed.get("remaining_members", []).duplicate(true)

func _set_enemy_trainer_state_cleared() -> void:
	if typeof(battle_data) != TYPE_DICTIONARY:
		return
	battle_data.erase("enemy_trainer_id")
	battle_data.erase("enemy_trainer_name")
	battle_data.erase("enemy_trainer_sprite_asset_id")
	battle_data.erase("enemy_trainer_defeat_key")
	battle_data.erase("enemy_trainer_encounter_bgm")
	battle_data.erase("enemy_trainer_battle_bgm")
	battle_data.erase("enemy_trainer_victory_bgm")
	battle_data.erase("enemy_trainer_party_total")
	battle_data.erase("enemy_trainer_is_boss")
	battle_data.erase("enemy_trainer_party_remaining")

func _set_enemy_next_trainer_presentation_visible(visible: bool) -> void:
	if enemy_arena_sprite != null:
		enemy_arena_sprite.visible = visible
	if enemy_arena_sprite_1 != null:
		enemy_arena_sprite_1.visible = visible
	if enemy_arena_sprite_2 != null:
		enemy_arena_sprite_2.visible = visible
	if enemy_arena_sprite_3 != null:
		enemy_arena_sprite_3.visible = visible
	if not visible:
		if enemy_pokemon_sprite != null:
			enemy_pokemon_sprite.visible = false
		if enemy_trainer_sprite != null:
			enemy_trainer_sprite.visible = false
			enemy_trainer_sprite.position = enemy_trainer_sprite_home_position
			enemy_trainer_sprite.modulate = Color(1, 1, 1, 1)

func _clear_active_trainer_encounter_state() -> void:
	if typeof(battle_data) != TYPE_DICTIONARY:
		return
	_set_enemy_trainer_state_cleared()
	battle_data["is_trainer_encounter"] = false
	battle_data["encounter_type"] = ENCOUNTER_TYPE_WILD
	if battle_data.has("encounter_meta") and typeof(battle_data["encounter_meta"]) == TYPE_DICTIONARY:
		battle_data["encounter_meta"]["is_trainer_encounter"] = false
		battle_data["encounter_meta"]["encounter_type"] = ENCOUNTER_TYPE_WILD
		battle_data["encounter_meta"].erase("trainer_id")
		battle_data["encounter_meta"].erase("trainer_display_name")

func _run_trainer_victory_outro_and_start_next_encounter(fainted_species_id: String):
	var victory_bgm_id = String(battle_data.get("enemy_trainer_victory_bgm", "")).strip_edges()
	if not victory_bgm_id.empty():
		var _played_victory_bgm = _play_named_bgm_track(victory_bgm_id)
	hide_all_command_menus()

	if enemy_trainer_sprite != null and not enemy_trainer_idle_frame.empty() and enemy_trainer_idle_frame.has("frame"):
		enemy_trainer_sprite.texture = enemy_trainer_texture_front
		enemy_trainer_sprite.centered = true
		enemy_trainer_sprite.region_enabled = true
		enemy_trainer_sprite.offset = Vector2.ZERO
		apply_sprite_frame(enemy_trainer_sprite, enemy_trainer_idle_frame["frame"])
		enemy_trainer_sprite.visible = true
		enemy_trainer_sprite.position = enemy_trainer_sprite_home_position + Vector2(enemy_trainer_exit_offset_x, enemy_trainer_exit_offset_y)
		enemy_trainer_sprite.modulate = Color(1, 1, 1, clamp(enemy_trainer_exit_alpha, 0.0, 1.0))

		var reenter_tween = Tween.new()
		add_child(reenter_tween)
		reenter_tween.interpolate_property(
			enemy_trainer_sprite,
			"position:x",
			enemy_trainer_sprite.position.x,
			enemy_trainer_sprite_home_position.x,
			max(0.01, enemy_trainer_exit_duration_sec),
			Tween.TRANS_SINE,
			Tween.EASE_IN_OUT
		)
		reenter_tween.interpolate_property(
			enemy_trainer_sprite,
			"position:y",
			enemy_trainer_sprite.position.y,
			enemy_trainer_sprite_home_position.y,
			max(0.01, enemy_trainer_exit_duration_sec),
			Tween.TRANS_SINE,
			Tween.EASE_IN_OUT
		)
		reenter_tween.interpolate_property(
			enemy_trainer_sprite,
			"modulate:a",
			enemy_trainer_sprite.modulate.a,
			1.0,
			max(0.01, enemy_trainer_exit_duration_sec),
			Tween.TRANS_SINE,
			Tween.EASE_IN_OUT
		)
		reenter_tween.start()
		yield(reenter_tween, "tween_all_completed")
		reenter_tween.queue_free()
		enemy_trainer_sprite.position = enemy_trainer_sprite_home_position
		enemy_trainer_sprite.modulate = Color(1, 1, 1, 1)

	set_battle_text(_resolve_trainer_defeat_message())
	if trainer_defeat_text_hold_sec > 0.0:
		yield(get_tree().create_timer(trainer_defeat_text_hold_sec), "timeout")
	set_battle_text("")

	if enemy_trainer_sprite != null and enemy_trainer_sprite.visible:

		var exit_tween = Tween.new()
		add_child(exit_tween)
		exit_tween.interpolate_property(
			enemy_trainer_sprite,
			"position:x",
			enemy_trainer_sprite.position.x,
			enemy_trainer_sprite_home_position.x + enemy_trainer_exit_offset_x,
			max(0.01, enemy_trainer_exit_duration_sec),
			Tween.TRANS_SINE,
			Tween.EASE_IN_OUT
		)
		exit_tween.interpolate_property(
			enemy_trainer_sprite,
			"position:y",
			enemy_trainer_sprite.position.y,
			enemy_trainer_sprite_home_position.y + enemy_trainer_exit_offset_y,
			max(0.01, enemy_trainer_exit_duration_sec),
			Tween.TRANS_SINE,
			Tween.EASE_IN_OUT
		)
		exit_tween.interpolate_property(
			enemy_trainer_sprite,
			"modulate:a",
			enemy_trainer_sprite.modulate.a,
			clamp(enemy_trainer_exit_alpha, 0.0, 1.0),
			max(0.01, enemy_trainer_exit_duration_sec),
			Tween.TRANS_SINE,
			Tween.EASE_IN_OUT
		)
		exit_tween.start()
		yield(exit_tween, "tween_all_completed")
		exit_tween.queue_free()
		enemy_trainer_sprite.visible = false
		enemy_trainer_sprite.position = enemy_trainer_sprite_home_position
		enemy_trainer_sprite.modulate = Color(1, 1, 1, 1)

	battle_ended = false
	turn_in_progress = false
	capture_in_progress = false
	_clear_active_trainer_encounter_state()
	if enemy_trainer_pb_panel != null:
		enemy_trainer_pb_panel.visible = false
	if player_trainer_pb_panel != null:
		player_trainer_pb_panel.visible = false

	var next_transition = advance_to_next_enemy(fainted_species_id, -1, false)
	if next_transition is GDScriptFunctionState:
		yield(next_transition, "completed")

func _return_to_main_scene():
	var tree = get_tree()
	if tree == null:
		return

	_stop_biome_bgm_crossfade_tween()
	var fade_duration = max(0.0, scene_change_bgm_fade_out_sec)
	var has_playing_bgm := false
	for player in [biome_bgm_primary_player, biome_bgm_secondary_player]:
		if player == null or not is_instance_valid(player):
			continue
		if not player.playing:
			continue
		has_playing_bgm = true
		if fade_duration > 0.0:
			if biome_bgm_crossfade_tween == null:
				biome_bgm_crossfade_tween = Tween.new()
				add_child(biome_bgm_crossfade_tween)
			biome_bgm_crossfade_tween.interpolate_property(
				player,
				"volume_db",
				player.volume_db,
				-80.0,
				fade_duration,
				Tween.TRANS_SINE,
				Tween.EASE_IN_OUT
			)

	if has_playing_bgm and fade_duration > 0.0 and biome_bgm_crossfade_tween != null:
		biome_bgm_crossfade_tween.start()
		yield(tree.create_timer(fade_duration), "timeout")

	for player in [biome_bgm_primary_player, biome_bgm_secondary_player]:
		if player == null or not is_instance_valid(player):
			continue
		player.stop()
	if biome_bgm_primary_player != null and is_instance_valid(biome_bgm_primary_player):
		biome_bgm_primary_player.volume_db = biome_bgm_volume_db
	if biome_bgm_secondary_player != null and is_instance_valid(biome_bgm_secondary_player):
		biome_bgm_secondary_player.volume_db = -80.0
	_stop_biome_bgm_crossfade_tween()

	var result = tree.change_scene(MAIN_SCENE_PATH)
	if result != OK:
		set_battle_text("Failed to open main menu.")
		show_main_controls()
		ball_button.disabled = false
		ball_button.grab_focus()

func reset_battle_state(message: String):
	turn_token += 1
	capture_in_progress = false
	sendout_controls_locked = false
	if battlefield_layer != null:
		battlefield_layer.rect_position = battlefield_layer_home_position
	_stop_enemy_panel_tween()
	_stop_trainer_pb_panel_tween(true)
	_stop_trainer_pb_panel_tween(false)
	_stop_player_panel_switch_tween()
	player_trainer_choreo_playing = false
	player_trainer_choreo_elapsed = 0.0
	player_trainer_last_throw_index = -1
	player_trainer_pokemon_revealed = false
	player_trainer_exit_started = false
	player_sendout_cry_played = false
	if player_trainer_sprite != null:
		player_trainer_sprite.visible = false
	if player_panel != null:
		player_panel.rect_position = _player_panel_hidden_position()
	if enemy_panel != null:
		enemy_panel.rect_position = _enemy_panel_hidden_position()
	if enemy_trainer_pb_panel != null:
		enemy_trainer_pb_panel.rect_position = _trainer_pb_panel_enemy_hidden_position()
		enemy_trainer_pb_panel.visible = false
	if player_trainer_pb_panel != null:
		player_trainer_pb_panel.rect_position = _trainer_pb_panel_player_hidden_position()
		player_trainer_pb_panel.visible = false
	_close_party_menu_internal()
	hide_ball_menu(false)
	_hide_enemy_pokeball_sprite()
	ball_inventory = BALL_DEFAULT_COUNTS.duplicate(true)
	refresh_ball_menu_labels()
	var handoff_species_id = consume_selected_species_id()
	if not handoff_species_id.empty():
		selected_player_species_id = handoff_species_id
		if runtime_state_script != null:
			runtime_state_script.clear_biome_state(get_tree())
			log_debug("Run reset: cleared runtime biome progression state from selection handoff.")
			runtime_state_script.add_caught_species(get_tree(), selected_player_species_id)

	var active_party_member := {}
	var runtime_party = null
	if runtime_state_script != null:
		runtime_party = runtime_state_script.get_party(get_tree())
		if runtime_party != null and not handoff_species_id.empty() and runtime_party.is_empty():
			runtime_party.add_member({
				"species_id": handoff_species_id,
				"level": 5,
				"current_hp": -1,
				"move_ids": [],
			})
			runtime_party.set_active_slot(0)
		if runtime_party != null:
			active_party_member = runtime_party.get_active_member()

	if active_party_member.empty() and not selected_player_species_id.empty():
		active_party_member = {
			"species_id": selected_player_species_id,
			"level": 5,
			"current_hp": -1,
			"move_ids": [],
		}

	if not active_party_member.empty():
		var resolved_level = _resolve_debug_player_level(int(active_party_member.get("level", 5)))
		active_party_member["level"] = resolved_level
		if runtime_party != null:
			var active_slot_index = runtime_party.get_active_slot_index()
			if active_slot_index >= 0:
				runtime_party.update_member_at(active_slot_index, {
					"level": resolved_level,
				})

	if runtime_state_script != null and not active_party_member.empty():
		var active_species_id = String(active_party_member.get("species_id", "")).strip_edges().to_upper()
		if not active_species_id.empty():
			runtime_state_script.add_caught_species(get_tree(), active_species_id)

	var active_player_species_id = String(active_party_member.get("species_id", selected_player_species_id)).strip_edges().to_upper()
	if active_player_species_id.empty():
		active_player_species_id = "BLASTOISE"
	selected_player_species_id = active_player_species_id

	var initial_biome_state = _ensure_runtime_biome_state()
	var initial_encounter_meta = _build_encounter_metadata(initial_biome_state, "")
	var trainer_seed = {}
	var trainer_seed_failed := false
	if bool(initial_encounter_meta.get("is_trainer_encounter", false)):
		trainer_seed = _try_seed_trainer_encounter(initial_encounter_meta, initial_biome_state)

	var next_enemy_species_id = _pick_biome_weighted_enemy_species_id("", initial_biome_state, initial_encounter_meta)
	if not trainer_seed.empty() and trainer_seed.has("enemy") and trainer_seed["enemy"] != null:
		next_enemy_species_id = String(trainer_seed["enemy"].species_id).strip_edges().to_upper()

	battle_data = build_battle_seed(active_player_species_id, next_enemy_species_id, active_party_member, initial_encounter_meta, initial_biome_state)
	if not trainer_seed.empty() and trainer_seed.has("enemy") and trainer_seed["enemy"] != null:
		battle_data["enemy"] = trainer_seed["enemy"]
		battle_data["enemy_trainer_id"] = String(trainer_seed.get("trainer_id", "")).strip_edges().to_upper()
		battle_data["enemy_trainer_name"] = String(trainer_seed.get("display_name", "Trainer")).strip_edges()
		battle_data["enemy_trainer_sprite_asset_id"] = String(trainer_seed.get("sprite_asset_id", "")).strip_edges().to_lower()
		battle_data["enemy_trainer_defeat_key"] = String(trainer_seed.get("defeat_key", "")).strip_edges()
		battle_data["enemy_trainer_encounter_bgm"] = String(trainer_seed.get("encounter_bgm", "")).strip_edges()
		battle_data["enemy_trainer_battle_bgm"] = String(trainer_seed.get("battle_bgm", "")).strip_edges()
		battle_data["enemy_trainer_victory_bgm"] = String(trainer_seed.get("victory_bgm", "")).strip_edges()
		battle_data["enemy_trainer_party_total"] = int(trainer_seed.get("party_total", 1))
		battle_data["enemy_trainer_is_boss"] = bool(trainer_seed.get("is_boss", false))
		battle_data["enemy_trainer_party_remaining"] = trainer_seed.get("remaining_members", []).duplicate(true)
		log_debug(
			"Trainer encounter seeded: trainer_id=%s name=%s party_remaining=%d"
			% [
				String(battle_data.get("enemy_trainer_id", "")),
				String(battle_data.get("enemy_trainer_name", "Trainer")),
				int(battle_data.get("enemy_trainer_party_remaining", []).size()),
			]
		)
	else:
		battle_data.erase("enemy_trainer_id")
		battle_data.erase("enemy_trainer_name")
		battle_data.erase("enemy_trainer_sprite_asset_id")
		battle_data.erase("enemy_trainer_defeat_key")
		battle_data.erase("enemy_trainer_encounter_bgm")
		battle_data.erase("enemy_trainer_battle_bgm")
		battle_data.erase("enemy_trainer_victory_bgm")
		battle_data.erase("enemy_trainer_party_total")
		battle_data.erase("enemy_trainer_is_boss")
		battle_data.erase("enemy_trainer_party_remaining")
		if bool(initial_encounter_meta.get("is_trainer_encounter", false)):
			trainer_seed_failed = true
			log_debug("Trainer encounter fallback: no valid trainer seed found; using wild enemy flow.")

	_apply_biome_state_to_battle_data(initial_biome_state)
	if trainer_seed_failed:
		var fallback_meta = battle_data.get("encounter_meta", {}).duplicate(true)
		fallback_meta["encounter_type"] = ENCOUNTER_TYPE_WILD
		fallback_meta["is_trainer_encounter"] = false
		fallback_meta["trainer_id"] = ""
		fallback_meta["trainer_display_name"] = ""
		if bool(fallback_meta.get("is_boss_encounter", false)):
			fallback_meta["encounter_archetype"] = ENCOUNTER_ARCHETYPE_BOSS_POKEMON
		else:
			fallback_meta["encounter_archetype"] = ENCOUNTER_ARCHETYPE_NORMAL_POKEMON
		_apply_encounter_metadata_to_battle_data(fallback_meta)
	enemy_layer.rect_position = enemy_layer_home_position
	load_battle_sprites()
	battle_ended = false
	turn_in_progress = false
	hide_all_command_menus()
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
	var uses_trainer_intro = _is_active_trainer_encounter() and enemy_trainer_intro_enabled and enemy_trainer_sprite != null and not enemy_trainer_idle_frame.empty()
	_start_battle_opening_sequence()
	ensure_button_focus()
	if uses_trainer_intro:
		pass
	elif message == "Battle ready." or message == "Battle reset.":
		set_battle_text(_build_enemy_appeared_message(String(battle_data["enemy"].species_id)))
	else:
		set_battle_text(message)

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
	if not battle_ended and not turn_in_progress and not capture_in_progress:
		_show_main_controls_unlocked()

func build_battle_seed(player_species_id: String, enemy_species_id: String, player_party_member: Dictionary = {}, encounter_meta: Dictionary = {}, biome_state: Dictionary = {}) -> Dictionary:
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()

	if catalog_loader != null and catalog_loader.load_catalogs():
		var enemy_base_level = 5
		var enemy_scaling = _resolve_biome_level_scaling(encounter_meta, enemy_base_level, biome_state)
		var enemy_level = int(enemy_scaling.get("target_level", enemy_base_level))
		_log_transition_checkpoint("biome_level_scaling.resolved", {
			"source": "wild_seed_build",
			"biome_id": String(enemy_scaling.get("biome_id", "")),
			"encounter_number": int(enemy_scaling.get("encounter_number", 0)),
			"encounter_archetype": String(enemy_scaling.get("encounter_archetype", ENCOUNTER_ARCHETYPE_NORMAL_POKEMON)),
			"base_level": enemy_base_level,
			"floor_index": int(enemy_scaling.get("floor_index", 0)),
			"player_level": int(enemy_scaling.get("player_level", 1)),
			"floor_bonus": int(enemy_scaling.get("floor_bonus", 0)),
			"archetype_bonus": int(enemy_scaling.get("archetype_bonus", 0)),
			"difficulty_delta": int(enemy_scaling.get("difficulty_delta", 0)),
			"target_level": enemy_level,
		})

		if typeof(player_party_member) == TYPE_DICTIONARY and not player_party_member.empty():
			var player_level = _resolve_debug_player_level(int(player_party_member.get("level", 5)))
			var player_move_ids = player_party_member.get("move_ids", [])
			if typeof(player_move_ids) != TYPE_ARRAY:
				player_move_ids = []

			var player_data = catalog_loader.build_pokemon_data(player_species_id, player_level, player_move_ids)
			_apply_debug_pp_overrides_to_pokemon(player_data, "seed.player_party_member")
			var enemy_data = catalog_loader.build_pokemon_data(enemy_species_id, enemy_level)
			return {
				"player": player_data,
				"enemy": enemy_data,
			}

		var player_data_default = catalog_loader.build_pokemon_data(player_species_id, _resolve_debug_player_level(5))
		_apply_debug_pp_overrides_to_pokemon(player_data_default, "seed.player_default")
		var enemy_data_default = catalog_loader.build_pokemon_data(enemy_species_id, enemy_level)
		return {
			"player": player_data_default,
			"enemy": enemy_data_default,
		}

	var fallback_seed = pokemon_data_script.create_battle_02_test_data(player_species_id)
	if typeof(fallback_seed) == TYPE_DICTIONARY and fallback_seed.has("player"):
		_apply_debug_pp_overrides_to_pokemon(fallback_seed.get("player", null), "seed.fallback")
	return fallback_seed

func _resolve_debug_player_level(base_level: int) -> int:
	if debug_player_level_override > 0:
		return int(max(1, debug_player_level_override))
	return int(max(1, base_level))

func _apply_debug_pp_overrides_to_pokemon(pokemon_data, source: String = "") -> void:
	if pokemon_data == null:
		return
	if not debug_pp_override_all_moves_one and not debug_pp_override_second_move_one:
		return

	var moves = []
	if typeof(pokemon_data) == TYPE_DICTIONARY:
		moves = pokemon_data.get("moves", [])
	elif pokemon_data.has_method("get"):
		moves = pokemon_data.get("moves")
	if typeof(moves) != TYPE_ARRAY or moves.empty():
		return

	if debug_pp_override_all_moves_one:
		for move in moves:
			_set_debug_move_pp_to_one(move)
		if debug_transition_checkpoints:
			log_debug("Debug PP override (all moves=1) applied [%s]." % source)
		return

	if debug_pp_override_second_move_one and moves.size() > 1:
		_set_debug_move_pp_to_one(moves[1])
		if debug_transition_checkpoints:
			log_debug("Debug PP override (second move=1) applied [%s]." % source)

func _set_debug_move_pp_to_one(move) -> void:
	if move == null or not move.has_method("set_current_pp"):
		return
	var max_pp_value = int(move.max_pp)
	if max_pp_value < 0:
		return
	move.set_current_pp(min(1, max_pp_value))

func _ensure_runtime_biome_state() -> Dictionary:
	if runtime_state_script == null:
		return {
			"current_biome_id": "grass",
			"previous_biome_id": "",
			"transition_trigger": "battle_start",
			"encounter_index": 0,
			"floor_index": 0,
			"switch_boundary_reached": false,
			"cadence_settings": {
				"switch_interval": max(1, biome_switch_every_levels),
				"milestone_interval": max(0, biome_switch_milestone_interval),
				"milestone_floors": [],
				"use_interval": true,
			},
			"seed": 0,
			"source": "baseline_rotation",
		}
	return runtime_state_script.ensure_biome_state(get_tree())

func _build_biome_cadence_settings() -> Dictionary:
	return {
		"switch_interval": max(1, biome_switch_every_levels),
		"milestone_interval": max(0, biome_switch_milestone_interval),
		"milestone_floors": [],
		"use_interval": true,
	}

func _build_rotation_route_links(normalized_entries: Array) -> Dictionary:
	var linked_biomes := {}
	if normalized_entries.size() < 2:
		return linked_biomes

	for i in range(normalized_entries.size()):
		var current_biome_id = String(normalized_entries[i])
		var next_biome_id = String(normalized_entries[(i + 1) % normalized_entries.size()])
		var prev_biome_id = String(normalized_entries[(i - 1 + normalized_entries.size()) % normalized_entries.size()])
		var candidates := []
		if not next_biome_id.empty() and not candidates.has(next_biome_id):
			candidates.append(next_biome_id)
		if normalized_entries.size() > 2 and not prev_biome_id.empty() and not candidates.has(prev_biome_id):
			candidates.append(prev_biome_id)
		if candidates.empty() and not current_biome_id.empty():
			candidates.append(current_biome_id)
		linked_biomes[current_biome_id] = candidates

	return linked_biomes

func _get_biome_route_graph_catalog() -> Dictionary:
	if biome_route_graph_catalog_loaded:
		if typeof(biome_route_graph_catalog) == TYPE_DICTIONARY:
			return biome_route_graph_catalog
		return {}

	biome_route_graph_catalog_loaded = true
	var payload = _read_json_payload(biome_route_graph_catalog_path)
	if typeof(payload) != TYPE_DICTIONARY:
		log_debug("Biome route graph: failed to load JSON payload from %s" % biome_route_graph_catalog_path)
		biome_route_graph_catalog = {}
		return {}

	var biomes = payload.get("biomes", {})
	if typeof(biomes) != TYPE_DICTIONARY:
		log_debug("Biome route graph: invalid payload; expected dictionary at 'biomes'.")
		biome_route_graph_catalog = {}
		return {}

	biome_route_graph_catalog = payload
	return biome_route_graph_catalog

func _extract_catalog_route_links(route_catalog: Dictionary, normalized_entries: Array) -> Dictionary:
	var links := {}
	if typeof(route_catalog) != TYPE_DICTIONARY:
		return links

	var raw_biomes = route_catalog.get("biomes", {})
	if typeof(raw_biomes) != TYPE_DICTIONARY:
		return links

	var allowed_lookup := {}
	for biome_id in normalized_entries:
		var normalized_biome_id = _normalize_arena_asset_id(String(biome_id))
		if normalized_biome_id.empty():
			continue
		allowed_lookup[normalized_biome_id] = true

	for raw_source_biome_id in raw_biomes.keys():
		var source_biome_id = _normalize_arena_asset_id(String(raw_source_biome_id))
		if source_biome_id.empty() or not allowed_lookup.has(source_biome_id):
			continue
		if typeof(raw_biomes[raw_source_biome_id]) != TYPE_DICTIONARY:
			continue
		var biome_entry: Dictionary = raw_biomes[raw_source_biome_id]

		var candidates := []
		var weighted_links = biome_entry.get("linked_biomes", [])
		if typeof(weighted_links) == TYPE_ARRAY:
			for link_entry in weighted_links:
				if typeof(link_entry) != TYPE_DICTIONARY:
					continue
				var target_biome_id = _normalize_arena_asset_id(String(link_entry.get("target_biome_id", "")))
				if target_biome_id.empty() or not allowed_lookup.has(target_biome_id) or candidates.has(target_biome_id):
					continue
				candidates.append(target_biome_id)

		if candidates.empty():
			var legacy_links = biome_entry.get("linked_biome_ids", [])
			if typeof(legacy_links) == TYPE_ARRAY:
				for raw_target in legacy_links:
					var legacy_target_biome_id = _normalize_arena_asset_id(String(raw_target))
					if legacy_target_biome_id.empty() or not allowed_lookup.has(legacy_target_biome_id) or candidates.has(legacy_target_biome_id):
						continue
					candidates.append(legacy_target_biome_id)

		if candidates.empty():
			continue

		links[source_biome_id] = candidates

	return links

func _build_biome_route_policy() -> Dictionary:
	var rotation: Array = biome_test_arena_rotation
	var normalized_entries := []
	for entry in rotation:
		var normalized_entry = _normalize_arena_asset_id(String(entry))
		if normalized_entry.empty() or normalized_entries.has(normalized_entry):
			continue
		normalized_entries.append(normalized_entry)

	var linked_biomes = _build_rotation_route_links(normalized_entries)
	var policy_id = "battle_rotation_links_v1"
	var fallback_mode = "rotation_next"

	var route_catalog = _get_biome_route_graph_catalog()
	if typeof(route_catalog) == TYPE_DICTIONARY and not route_catalog.empty():
		var catalog_links = _extract_catalog_route_links(route_catalog, normalized_entries)
		if not catalog_links.empty():
			for source_biome_id in catalog_links.keys():
				linked_biomes[source_biome_id] = catalog_links[source_biome_id]
			policy_id = String(route_catalog.get("policy_id", "biome_route_graph_v1")).strip_edges().to_lower()
			if policy_id.empty():
				policy_id = "biome_route_graph_v1"
			fallback_mode = String(route_catalog.get("fallback_mode", "rotation_next")).strip_edges().to_lower()
			if fallback_mode.empty():
				fallback_mode = "rotation_next"
			log_debug("Biome route policy: loaded %d route entries from %s" % [catalog_links.size(), biome_route_graph_catalog_path])

	return {
		"policy_id": policy_id,
		"fallback_mode": fallback_mode,
		"linked_biomes": linked_biomes,
	}

func _advance_runtime_biome_state(transition_trigger: String) -> Dictionary:
	if runtime_state_script == null:
		var fallback_biome_state = _ensure_runtime_biome_state()
		var next_index = int(fallback_biome_state.get("encounter_index", 0)) + 1
		fallback_biome_state["transition_trigger"] = transition_trigger.strip_edges().to_lower().replace(" ", "_")
		fallback_biome_state["encounter_index"] = next_index
		fallback_biome_state["floor_index"] = next_index
		fallback_biome_state["switch_boundary_reached"] = false
		fallback_biome_state["route_decision"] = {
			"policy_id": "battle_rotation_links_v1",
			"current_biome_id": String(fallback_biome_state.get("current_biome_id", "grass")),
			"candidates": [],
			"selected_biome_id": String(fallback_biome_state.get("current_biome_id", "grass")),
			"fallback_used": false,
			"fallback_reason": "runtime_state_missing",
			"roll_seed": 0,
			"roll_index": 0,
			"route_roll_counter": int(fallback_biome_state.get("route_roll_counter", 0)),
			"switch_boundary_reached": false,
		}
		_log_biome_route_decision_checkpoint(fallback_biome_state)
		return fallback_biome_state
	var next_biome_state = runtime_state_script.advance_biome_progression(
		get_tree(),
		transition_trigger,
		_build_biome_cadence_settings(),
		"",
		_build_biome_route_policy()
	)
	_log_biome_route_decision_checkpoint(next_biome_state)
	return next_biome_state

func _apply_biome_state_to_battle_data(biome_state: Dictionary) -> void:
	if typeof(battle_data) != TYPE_DICTIONARY:
		return
	battle_data["biome_state"] = biome_state.duplicate(true)
	var _encounter_meta = _refresh_encounter_metadata_for_current_enemy(biome_state)

func _refresh_encounter_metadata_for_current_enemy(biome_state: Dictionary) -> Dictionary:
	if typeof(battle_data) != TYPE_DICTIONARY:
		return {}

	var enemy_species_id := ""
	if battle_data.has("enemy") and battle_data["enemy"] != null:
		enemy_species_id = String(battle_data["enemy"].species_id).strip_edges().to_upper()

	var encounter_meta = _build_encounter_metadata(biome_state, enemy_species_id)
	_apply_encounter_metadata_to_battle_data(encounter_meta)
	_log_encounter_metadata(encounter_meta)
	return encounter_meta

func _build_encounter_metadata(biome_state: Dictionary, enemy_species_id: String) -> Dictionary:
	var encounter_index = max(0, int(biome_state.get("encounter_index", 0)))
	var encounter_number = encounter_index + 1
	var classification = _classify_encounter_archetype(encounter_number, biome_state)
	var biome_id = String(biome_state.get("current_biome_id", "grass")).strip_edges().to_lower()
	if biome_id.empty():
		biome_id = "grass"

	var encounter_meta = {
		"encounter_index": encounter_index,
		"encounter_number": encounter_number,
		"transition_trigger": String(biome_state.get("transition_trigger", "battle_start")),
		"biome_id": biome_id,
		"enemy_species_id": enemy_species_id,
		"encounter_archetype": String(classification.get("encounter_archetype", ENCOUNTER_ARCHETYPE_NORMAL_POKEMON)),
		"encounter_type": String(classification.get("encounter_type", ENCOUNTER_TYPE_WILD)),
		"is_trainer_encounter": bool(classification.get("is_trainer_encounter", false)),
		"is_boss_encounter": bool(classification.get("is_boss_encounter", false)),
		"trainer_decision": classification.get("trainer_decision", {}).duplicate(true) if typeof(classification.get("trainer_decision", {})) == TYPE_DICTIONARY else {},
	}
	_log_biome_trainer_decision_checkpoint(encounter_meta)

	if _is_active_trainer_encounter():
		encounter_meta["trainer_id"] = String(battle_data.get("enemy_trainer_id", "")).strip_edges().to_upper()
		encounter_meta["trainer_display_name"] = String(battle_data.get("enemy_trainer_name", "Trainer")).strip_edges()

	return encounter_meta

func _resolve_active_player_level_for_scaling() -> int:
	if typeof(battle_data) == TYPE_DICTIONARY and battle_data.has("player") and battle_data["player"] != null:
		return int(max(1, int(battle_data["player"].level)))

	if runtime_state_script != null:
		var party = runtime_state_script.get_party(get_tree())
		if party != null:
			var active_index = party.get_active_slot_index()
			var active_member = party.get_member_at(active_index)
			if typeof(active_member) == TYPE_DICTIONARY and not active_member.empty():
				return int(max(1, int(active_member.get("level", 5))))

	return int(max(1, _resolve_debug_player_level(5)))

func _resolve_biome_level_scaling(encounter_meta: Dictionary, base_level: int, biome_state: Dictionary = {}) -> Dictionary:
	var safe_base_level = max(1, int(base_level))
	var resolved_meta = encounter_meta if typeof(encounter_meta) == TYPE_DICTIONARY else {}
	var resolved_biome_state = biome_state if typeof(biome_state) == TYPE_DICTIONARY else {}

	var encounter_index = int(resolved_meta.get("encounter_index", resolved_biome_state.get("encounter_index", 0)))
	var encounter_number = int(resolved_meta.get("encounter_number", encounter_index + 1))
	var floor_index = int(resolved_biome_state.get("floor_index", encounter_index))
	var biome_id = _normalize_arena_asset_id(String(resolved_meta.get("biome_id", resolved_biome_state.get("current_biome_id", "grass"))))
	if biome_id.empty():
		biome_id = "grass"

	var encounter_archetype = String(resolved_meta.get("encounter_archetype", ENCOUNTER_ARCHETYPE_NORMAL_POKEMON))
	var is_trainer = bool(resolved_meta.get("is_trainer_encounter", false))
	var is_boss = bool(resolved_meta.get("is_boss_encounter", false))

	var floor_step = max(1, int(biome_level_scale_floor_step))
	var floor_bonus = int(floor(float(max(0, floor_index)) / float(floor_step))) * max(0, int(biome_level_scale_floor_bonus))

	var archetype_bonus = 0
	if is_trainer:
		archetype_bonus += max(0, int(biome_level_scale_trainer_bonus))
	if is_boss:
		archetype_bonus += max(0, int(biome_level_scale_boss_bonus))

	var player_level = _resolve_active_player_level_for_scaling()
	var weighted_delta = float(player_level - safe_base_level) * float(biome_level_scale_player_weight)
	var difficulty_delta = int(round(weighted_delta))

	var unclamped = safe_base_level + floor_bonus + archetype_bonus + difficulty_delta
	var min_level = max(1, int(biome_level_scale_min_level))
	var target_level = int(clamp(unclamped, min_level, max_exp_level))

	return {
		"biome_id": biome_id,
		"encounter_index": encounter_index,
		"encounter_number": max(1, encounter_number),
		"encounter_archetype": encounter_archetype,
		"base_level": safe_base_level,
		"floor_index": floor_index,
		"player_level": player_level,
		"floor_bonus": floor_bonus,
		"archetype_bonus": archetype_bonus,
		"difficulty_delta": difficulty_delta,
		"target_level": target_level,
	}

func _classify_encounter_archetype(encounter_number: int, biome_state: Dictionary = {}) -> Dictionary:
	var normalized_number = max(1, encounter_number)
	var has_boss_trainer_cadence = boss_trainer_encounter_every > 0
	var has_boss_pokemon_cadence = boss_pokemon_encounter_every > 0
	var trainer_decision = _resolve_biome_trainer_decision(normalized_number, biome_state)
	var normal_trainer_selected = bool(trainer_decision.get("selected", false)) and String(trainer_decision.get("trainer_pool_kind", "normal")) == "normal"
	var boss_trainer_selected = bool(trainer_decision.get("selected", false)) and String(trainer_decision.get("trainer_pool_kind", "normal")) == "boss"

	if force_first_encounter_trainer and normalized_number == 1:
		return {
			"encounter_archetype": ENCOUNTER_ARCHETYPE_NORMAL_TRAINER,
			"encounter_type": ENCOUNTER_TYPE_TRAINER,
			"is_trainer_encounter": true,
			"is_boss_encounter": false,
			"trainer_decision": trainer_decision,
		}

	if debug_force_second_encounter_trainer and normalized_number == 2:
		return {
			"encounter_archetype": ENCOUNTER_ARCHETYPE_NORMAL_TRAINER,
			"encounter_type": ENCOUNTER_TYPE_TRAINER,
			"is_trainer_encounter": true,
			"is_boss_encounter": false,
			"trainer_decision": trainer_decision,
		}

	if has_boss_trainer_cadence and boss_trainer_selected:
		return {
			"encounter_archetype": ENCOUNTER_ARCHETYPE_BOSS_TRAINER,
			"encounter_type": ENCOUNTER_TYPE_TRAINER,
			"is_trainer_encounter": true,
			"is_boss_encounter": true,
			"trainer_decision": trainer_decision,
		}

	if has_boss_pokemon_cadence and normalized_number % boss_pokemon_encounter_every == 0:
		return {
			"encounter_archetype": ENCOUNTER_ARCHETYPE_BOSS_POKEMON,
			"encounter_type": ENCOUNTER_TYPE_WILD,
			"is_trainer_encounter": false,
			"is_boss_encounter": true,
			"trainer_decision": trainer_decision,
		}

	if normal_trainer_selected:
		return {
			"encounter_archetype": ENCOUNTER_ARCHETYPE_NORMAL_TRAINER,
			"encounter_type": ENCOUNTER_TYPE_TRAINER,
			"is_trainer_encounter": true,
			"is_boss_encounter": false,
			"trainer_decision": trainer_decision,
		}

	return {
		"encounter_archetype": ENCOUNTER_ARCHETYPE_NORMAL_POKEMON,
		"encounter_type": ENCOUNTER_TYPE_WILD,
		"is_trainer_encounter": false,
		"is_boss_encounter": false,
		"trainer_decision": trainer_decision,
	}

func _apply_encounter_metadata_to_battle_data(encounter_meta: Dictionary) -> void:
	if typeof(battle_data) != TYPE_DICTIONARY:
		return
	battle_data["encounter_meta"] = encounter_meta.duplicate(true)
	battle_data["encounter_archetype"] = String(encounter_meta.get("encounter_archetype", ENCOUNTER_ARCHETYPE_NORMAL_POKEMON))
	battle_data["encounter_type"] = String(encounter_meta.get("encounter_type", ENCOUNTER_TYPE_WILD))
	battle_data["is_trainer_encounter"] = bool(encounter_meta.get("is_trainer_encounter", false))
	battle_data["is_boss_encounter"] = bool(encounter_meta.get("is_boss_encounter", false))

func _log_encounter_metadata(encounter_meta: Dictionary) -> void:
	if typeof(encounter_meta) != TYPE_DICTIONARY or encounter_meta.empty():
		return
	var encounter_number = int(encounter_meta.get("encounter_number", 0))
	var archetype = String(encounter_meta.get("encounter_archetype", ENCOUNTER_ARCHETYPE_NORMAL_POKEMON))
	var encounter_type = String(encounter_meta.get("encounter_type", ENCOUNTER_TYPE_WILD))
	var biome_id = String(encounter_meta.get("biome_id", ""))
	var enemy_species_id = String(encounter_meta.get("enemy_species_id", ""))
	var trigger = String(encounter_meta.get("transition_trigger", ""))
	var trainer_flag = bool(encounter_meta.get("is_trainer_encounter", false))
	var boss_flag = bool(encounter_meta.get("is_boss_encounter", false))
	var trainer_id = String(encounter_meta.get("trainer_id", ""))
	var trainer_name = String(encounter_meta.get("trainer_display_name", ""))
	log_debug(
		"Encounter meta: #" + str(encounter_number)
		+ " archetype=" + archetype
		+ " type=" + encounter_type
		+ " trainer=" + str(trainer_flag)
		+ " boss=" + str(boss_flag)
		+ " trainer_id=" + trainer_id
		+ " trainer_name=" + trainer_name
		+ " biome=" + biome_id
		+ " enemy=" + enemy_species_id
		+ " trigger=" + trigger
	)

func get_enemy_species_pool() -> Array:
	if not enemy_species_pool.empty():
		return enemy_species_pool.duplicate()

	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()

	if catalog_loader == null or not catalog_loader.load_catalogs():
		return []

	enemy_species_pool = catalog_loader.get_all_species_ids()
	return enemy_species_pool.duplicate()

func _get_biome_wild_pool_catalog() -> Dictionary:
	if biome_wild_pool_catalog_loaded:
		if typeof(biome_wild_pool_catalog) == TYPE_DICTIONARY:
			return biome_wild_pool_catalog
		return {}

	biome_wild_pool_catalog_loaded = true
	var payload = _read_json_payload(biome_wild_pool_catalog_path)
	if typeof(payload) != TYPE_DICTIONARY:
		log_debug("Biome pool: failed to load JSON payload from %s" % biome_wild_pool_catalog_path)
		biome_wild_pool_catalog = {}
		return {}

	var biomes = payload.get("biomes", {})
	if typeof(biomes) != TYPE_DICTIONARY:
		log_debug("Biome pool: invalid payload; expected dictionary at 'biomes'.")
		biome_wild_pool_catalog = {}
		return {}

	biome_wild_pool_catalog = payload
	return biome_wild_pool_catalog

func _get_biome_trainer_rules_catalog() -> Dictionary:
	if biome_trainer_rules_catalog_loaded:
		if typeof(biome_trainer_rules_catalog) == TYPE_DICTIONARY:
			return biome_trainer_rules_catalog
		return {}

	biome_trainer_rules_catalog_loaded = true
	var payload = _read_json_payload(biome_trainer_rules_catalog_path)
	if typeof(payload) != TYPE_DICTIONARY:
		log_debug("Biome trainer rules: failed to load JSON payload from %s" % biome_trainer_rules_catalog_path)
		biome_trainer_rules_catalog = {}
		return {}

	var biomes = payload.get("biomes", {})
	if typeof(biomes) != TYPE_DICTIONARY:
		log_debug("Biome trainer rules: invalid payload; expected dictionary at 'biomes'.")
		biome_trainer_rules_catalog = {}
		return {}

	biome_trainer_rules_catalog = payload
	return biome_trainer_rules_catalog

func _get_biome_trainer_rule_entry(catalog: Dictionary, biome_id: String) -> Dictionary:
	if typeof(catalog) != TYPE_DICTIONARY:
		return {}
	var biomes = catalog.get("biomes", {})
	if typeof(biomes) != TYPE_DICTIONARY:
		return {}
	var normalized_biome_id = _normalize_arena_asset_id(biome_id)
	var default_biome_id = _normalize_arena_asset_id(String(catalog.get("default_biome_id", "grass")))
	if default_biome_id.empty():
		default_biome_id = "grass"
	if biomes.has(normalized_biome_id) and typeof(biomes[normalized_biome_id]) == TYPE_DICTIONARY:
		return biomes[normalized_biome_id]
	if biomes.has(default_biome_id) and typeof(biomes[default_biome_id]) == TYPE_DICTIONARY:
		return biomes[default_biome_id]
	return {}

func _normalize_trainer_id_list(raw_ids) -> Array:
	var normalized_ids := []
	if typeof(raw_ids) != TYPE_ARRAY:
		return normalized_ids
	for raw_id in raw_ids:
		var trainer_id = String(raw_id).strip_edges().to_upper()
		if trainer_id.empty() or normalized_ids.has(trainer_id):
			continue
		normalized_ids.append(trainer_id)
	return normalized_ids

func _resolve_biome_trainer_decision(encounter_number: int, biome_state: Dictionary) -> Dictionary:
	var biome_id = _normalize_arena_asset_id(String(biome_state.get("current_biome_id", "grass")))
	if biome_id.empty():
		biome_id = "grass"
	var catalog = _get_biome_trainer_rules_catalog()
	var rule_entry = _get_biome_trainer_rule_entry(catalog, biome_id)

	var default_normal_ids = _normalize_trainer_id_list(catalog.get("default_normal_trainer_ids", [])) if typeof(catalog) == TYPE_DICTIONARY else []
	var default_boss_ids = _normalize_trainer_id_list(catalog.get("default_boss_trainer_ids", [])) if typeof(catalog) == TYPE_DICTIONARY else []
	var normal_ids = _normalize_trainer_id_list(rule_entry.get("normal_trainer_ids", default_normal_ids))
	if normal_ids.empty():
		normal_ids = default_normal_ids.duplicate(true)
	var boss_ids = _normalize_trainer_id_list(rule_entry.get("boss_trainer_ids", default_boss_ids))
	if boss_ids.empty():
		boss_ids = default_boss_ids.duplicate(true)

	var decision = {
		"selected": false,
		"reason": "no_normal_trainer_cadence",
		"threshold_percent": 0,
		"roll_seed": 0,
		"roll_value": 0,
		"trainer_pool_kind": "normal",
		"candidate_ids": normal_ids,
		"candidate_count": normal_ids.size(),
		"pool_source": "biome:%s" % biome_id,
		"fallback_used": false,
		"fallback_reason": "",
	}

	if force_first_encounter_trainer and encounter_number == 1:
		decision["selected"] = true
		decision["reason"] = "forced_first_encounter_trainer"
		return decision

	if debug_force_second_encounter_trainer and encounter_number == 2:
		decision["selected"] = true
		decision["reason"] = "debug_forced_second_trainer"
		return decision

	if boss_trainer_encounter_every > 0 and encounter_number % boss_trainer_encounter_every == 0:
		decision["selected"] = true
		decision["reason"] = "boss_trainer_cadence"
		decision["trainer_pool_kind"] = "boss"
		decision["candidate_ids"] = boss_ids
		decision["candidate_count"] = boss_ids.size()
		return decision

	if normal_trainer_encounter_every <= 0 or encounter_number % normal_trainer_encounter_every != 0:
		return decision

	decision["reason"] = "normal_trainer_roll"
	var threshold_percent = 100
	if typeof(catalog) == TYPE_DICTIONARY:
		threshold_percent = int(catalog.get("default_normal_trainer_chance_percent", 100))
	threshold_percent = clamp(int(rule_entry.get("normal_trainer_chance_percent", threshold_percent)), 0, 100)
	decision["threshold_percent"] = threshold_percent

	var floor_index = int(biome_state.get("floor_index", biome_state.get("encounter_index", 0)))
	var root_seed = int(biome_state.get("seed", 0))
	var payload = "trainer|%s|%d|%d|%d|%d" % [biome_id, encounter_number, floor_index, root_seed, threshold_percent]
	var roll_seed = int(hash(payload))
	var roll_value = int(abs(roll_seed)) % 100
	decision["roll_seed"] = roll_seed
	decision["roll_value"] = roll_value
	decision["selected"] = roll_value < threshold_percent
	if not decision["selected"]:
		decision["reason"] = "trainer_roll_failed"

	if normal_ids.empty():
		decision["fallback_used"] = true
		decision["fallback_reason"] = "empty_normal_trainer_pool"
		if not default_normal_ids.empty():
			decision["candidate_ids"] = default_normal_ids
			decision["candidate_count"] = default_normal_ids.size()
			decision["pool_source"] = "default_normal_pool"
		else:
			decision["selected"] = false
			decision["reason"] = "no_buildable_normal_pool"

	if decision["trainer_pool_kind"] == "boss" and boss_ids.empty():
		decision["fallback_used"] = true
		decision["fallback_reason"] = "empty_boss_trainer_pool"
		if not default_boss_ids.empty():
			decision["candidate_ids"] = default_boss_ids
			decision["candidate_count"] = default_boss_ids.size()
			decision["pool_source"] = "default_boss_pool"
		else:
			decision["selected"] = false
			decision["reason"] = "no_buildable_boss_pool"

	return decision

func _get_biome_wild_pool_for_biome(catalog: Dictionary, biome_id: String) -> Dictionary:
	if typeof(catalog) != TYPE_DICTIONARY:
		return {}

	var biomes = catalog.get("biomes", {})
	if typeof(biomes) != TYPE_DICTIONARY:
		return {}

	var normalized_biome_id = _normalize_arena_asset_id(biome_id)
	var default_biome_id = _normalize_arena_asset_id(String(catalog.get("default_biome_id", "grass")))
	if default_biome_id.empty():
		default_biome_id = "grass"

	if biomes.has(normalized_biome_id) and typeof(biomes[normalized_biome_id]) == TYPE_DICTIONARY:
		return biomes[normalized_biome_id]
	if biomes.has(default_biome_id) and typeof(biomes[default_biome_id]) == TYPE_DICTIONARY:
		return biomes[default_biome_id]
	return {}

func _get_biome_pool_tier_weights(catalog: Dictionary) -> Dictionary:
	var default_weights = {
		"common": 70,
		"uncommon": 20,
		"rare": 10,
	}
	if typeof(catalog) != TYPE_DICTIONARY:
		return default_weights

	var raw_weights = catalog.get("default_tier_weights", {})
	if typeof(raw_weights) != TYPE_DICTIONARY:
		return default_weights

	for key in ["common", "uncommon", "rare"]:
		default_weights[key] = max(0, int(raw_weights.get(key, default_weights[key])))
	if int(default_weights["common"]) + int(default_weights["uncommon"]) + int(default_weights["rare"]) <= 0:
		default_weights = {
			"common": 70,
			"uncommon": 20,
			"rare": 10,
		}
	return default_weights

func _normalize_weighted_species_entries(raw_entries) -> Array:
	var normalized_entries := []
	if typeof(raw_entries) != TYPE_ARRAY:
		return normalized_entries

	var species_weights := {}
	for raw_entry in raw_entries:
		if typeof(raw_entry) != TYPE_DICTIONARY:
			continue
		var species_id = String(raw_entry.get("species_id", "")).strip_edges().to_upper()
		if species_id.empty():
			continue
		var weight = max(1, int(raw_entry.get("weight", 1)))
		species_weights[species_id] = int(species_weights.get(species_id, 0)) + weight

	for species_id in species_weights.keys():
		normalized_entries.append({
			"species_id": String(species_id),
			"weight": int(species_weights[species_id]),
		})

	return normalized_entries

func _pick_biome_wild_tier_key(biome_state: Dictionary, encounter_meta: Dictionary, tier_weights: Dictionary) -> Dictionary:
	if bool(encounter_meta.get("is_boss_encounter", false)):
		return {
			"tier_key": "boss",
			"tier_roll_seed": 0,
			"tier_roll_value": 0,
			"tier_total_weight": 0,
		}

	var common_weight = max(0, int(tier_weights.get("common", 70)))
	var uncommon_weight = max(0, int(tier_weights.get("uncommon", 20)))
	var rare_weight = max(0, int(tier_weights.get("rare", 10)))
	var total_weight = common_weight + uncommon_weight + rare_weight
	if total_weight <= 0:
		return {
			"tier_key": "common",
			"tier_roll_seed": 0,
			"tier_roll_value": 0,
			"tier_total_weight": 0,
		}

	var biome_id = String(biome_state.get("current_biome_id", "grass"))
	var floor_index = int(biome_state.get("floor_index", biome_state.get("encounter_index", 0)))
	var transition_trigger = String(encounter_meta.get("transition_trigger", biome_state.get("transition_trigger", "battle_start")))
	var root_seed = int(biome_state.get("seed", 0))
	var payload = "tier|%s|%d|%s|%d|%d|%d|%d" % [
		biome_id,
		floor_index,
		transition_trigger,
		root_seed,
		common_weight,
		uncommon_weight,
		rare_weight,
	]
	var tier_roll_seed = int(hash(payload))
	var tier_roll_value = int(abs(tier_roll_seed)) % total_weight
	if tier_roll_value < common_weight:
		return {
			"tier_key": "common",
			"tier_roll_seed": tier_roll_seed,
			"tier_roll_value": tier_roll_value,
			"tier_total_weight": total_weight,
		}
	if tier_roll_value < common_weight + uncommon_weight:
		return {
			"tier_key": "uncommon",
			"tier_roll_seed": tier_roll_seed,
			"tier_roll_value": tier_roll_value,
			"tier_total_weight": total_weight,
		}
	return {
		"tier_key": "rare",
		"tier_roll_seed": tier_roll_seed,
		"tier_roll_value": tier_roll_value,
		"tier_total_weight": total_weight,
	}

func _build_weighted_species_candidates_for_biome(current_enemy_species_id: String, biome_state: Dictionary, encounter_meta: Dictionary) -> Dictionary:
	var pool = get_enemy_species_pool()
	if pool.empty():
		return {
			"ok": false,
			"reason": "empty_species_catalog_pool",
			"candidates": [],
			"source": "catalog_pool_missing",
		}

	var catalog = _get_biome_wild_pool_catalog()
	if catalog.empty():
		return {
			"ok": false,
			"reason": "biome_pool_catalog_missing",
			"candidates": [],
			"source": "biome_pool_catalog_missing",
		}

	var biome_id = _normalize_arena_asset_id(String(biome_state.get("current_biome_id", "grass")))
	if biome_id.empty():
		biome_id = "grass"
	var biome_pool = _get_biome_wild_pool_for_biome(catalog, biome_id)
	if biome_pool.empty():
		return {
			"ok": false,
			"reason": "biome_pool_entry_missing",
			"candidates": [],
			"source": "biome_pool_entry_missing",
		}

	var tiers = biome_pool.get("tiers", {})
	if typeof(tiers) != TYPE_DICTIONARY:
		return {
			"ok": false,
			"reason": "tiers_payload_invalid",
			"candidates": [],
			"source": "tiers_payload_invalid",
		}

	var tier_weights = _get_biome_pool_tier_weights(catalog)
	var tier_roll = _pick_biome_wild_tier_key(biome_state, encounter_meta, tier_weights)
	var tier_key = String(tier_roll.get("tier_key", "common"))

	var source = "biome:%s tier:%s" % [biome_id, tier_key]
	var raw_entries = tiers.get(tier_key, [])
	var normalized_entries = _normalize_weighted_species_entries(raw_entries)
	if normalized_entries.empty() and tier_key != "common":
		raw_entries = tiers.get("common", [])
		normalized_entries = _normalize_weighted_species_entries(raw_entries)
		source = "biome:%s tier:fallback_common" % biome_id

	var available_species := {}
	for species_id in pool:
		var normalized_species_id = String(species_id).strip_edges().to_upper()
		if normalized_species_id.empty():
			continue
		available_species[normalized_species_id] = true

	var normalized_current = current_enemy_species_id.strip_edges().to_upper()
	var normalized_player = selected_player_species_id.strip_edges().to_upper()
	var filtered_entries := []
	for entry in normalized_entries:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var species_id = String(entry.get("species_id", "")).strip_edges().to_upper()
		if species_id.empty():
			continue
		if not available_species.has(species_id):
			continue
		if species_id == normalized_current:
			continue
		var weight = max(1, int(entry.get("weight", 1)))
		filtered_entries.append({
			"species_id": species_id,
			"weight": weight,
		})

	if filtered_entries.size() > 1 and not normalized_player.empty():
		var without_player := []
		for entry in filtered_entries:
			if String(entry.get("species_id", "")) == normalized_player:
				continue
			without_player.append(entry)
		if not without_player.empty():
			filtered_entries = without_player

	return {
		"ok": not filtered_entries.empty(),
		"reason": "ok" if not filtered_entries.empty() else "filtered_entries_empty",
		"candidates": filtered_entries,
		"source": source,
		"tier_key": tier_key,
		"tier_roll_seed": int(tier_roll.get("tier_roll_seed", 0)),
		"tier_roll_value": int(tier_roll.get("tier_roll_value", 0)),
		"tier_total_weight": int(tier_roll.get("tier_total_weight", 0)),
	}

func _format_weighted_species_candidates(candidates: Array) -> String:
	var parts := []
	for entry in candidates:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		parts.append("%s:%d" % [String(entry.get("species_id", "")), int(entry.get("weight", 1))])
	return "[" + ", ".join(parts) + "]"

func _pick_biome_weighted_enemy_species_id(current_enemy_species_id: String, biome_state: Dictionary, encounter_meta: Dictionary) -> String:
	var weighted_pool = _build_weighted_species_candidates_for_biome(current_enemy_species_id, biome_state, encounter_meta)
	if not bool(weighted_pool.get("ok", false)):
		var fallback_species_id = pick_random_enemy_species_id(current_enemy_species_id)
		_log_transition_checkpoint("biome_pool.fallback", {
			"reason": String(weighted_pool.get("reason", "unknown")),
			"source": String(weighted_pool.get("source", "")),
			"selected_species_id": fallback_species_id,
		})
		return fallback_species_id

	var candidates = weighted_pool.get("candidates", [])
	var total_weight := 0
	for entry in candidates:
		var entry_weight = int(max(1, int(entry.get("weight", 1))))
		total_weight += entry_weight

	if total_weight <= 0:
		var fallback_species = pick_random_enemy_species_id(current_enemy_species_id)
		_log_transition_checkpoint("biome_pool.fallback", {
			"reason": "total_weight_non_positive",
			"source": String(weighted_pool.get("source", "")),
			"selected_species_id": fallback_species,
		})
		return fallback_species

	var biome_id = _normalize_arena_asset_id(String(biome_state.get("current_biome_id", "grass")))
	if biome_id.empty():
		biome_id = "grass"
	var tier_key = String(weighted_pool.get("tier_key", "common"))
	var floor_index = int(biome_state.get("floor_index", biome_state.get("encounter_index", 0)))
	var encounter_index = int(biome_state.get("encounter_index", 0))
	var transition_trigger = String(encounter_meta.get("transition_trigger", biome_state.get("transition_trigger", "battle_start")))
	var root_seed = int(biome_state.get("seed", 0))
	var payload = "pool|%s|%s|%d|%d|%s|%d|%d" % [
		biome_id,
		tier_key,
		floor_index,
		encounter_index,
		transition_trigger,
		root_seed,
		candidates.size(),
	]
	var roll_seed = int(hash(payload))
	var roll_value = int(abs(roll_seed)) % total_weight

	var running_weight := 0
	var selected_species_id := String(candidates[0].get("species_id", "CHARMANDER"))
	for entry in candidates:
		var running_entry_weight = int(max(1, int(entry.get("weight", 1))))
		running_weight += running_entry_weight
		if roll_value < running_weight:
			selected_species_id = String(entry.get("species_id", selected_species_id)).strip_edges().to_upper()
			break

	_log_transition_checkpoint("biome_pool.candidates", {
		"source": String(weighted_pool.get("source", "")),
		"biome_id": biome_id,
		"tier_key": tier_key,
		"candidate_count": candidates.size(),
		"tier_roll_seed": int(weighted_pool.get("tier_roll_seed", 0)),
		"tier_roll_value": int(weighted_pool.get("tier_roll_value", 0)),
		"tier_total_weight": int(weighted_pool.get("tier_total_weight", 0)),
		"candidates": _format_weighted_species_candidates(candidates),
	})
	_log_transition_checkpoint("biome_pool.selected", {
		"selected_species_id": selected_species_id,
		"total_weight": total_weight,
		"roll_seed": roll_seed,
		"roll_value": roll_value,
		"weighting_inputs": "biome=%s tier=%s floor_index=%d encounter_index=%d trigger=%s root_seed=%d" % [
			biome_id,
			tier_key,
			floor_index,
			encounter_index,
			transition_trigger,
			root_seed,
		],
	})

	return selected_species_id

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

func advance_to_next_enemy(fainted_species_id: String, active_turn_token: int = -1, include_fainted_text: bool = true):
	if battle_data == null or not battle_data.has("player") or battle_data["player"] == null:
		end_battle(true, fainted_species_id)
		return
	active_transition_run_id = _next_transition_run_id()
	_log_transition_checkpoint("advance_to_next_enemy.entry", {
		"fainted_species_id": fainted_species_id,
		"active_turn_token": active_turn_token,
		"include_fainted_text": include_fainted_text,
	})

	var transition_context := {
		"aborted": false,
	}
	var phase_runner = battle_phase_runner_script.new()
	phase_runner.push_phase(
		encounter_transition_intro_phase_script.new(
			self,
			transition_context,
			fainted_species_id,
			active_turn_token,
			include_fainted_text
		)
	)
	phase_runner.push_phase(
		encounter_transition_seed_load_phase_script.new(
			self,
			transition_context,
			fainted_species_id,
			active_turn_token,
			include_fainted_text
		)
	)
	phase_runner.push_phase(
		biome_transition_party_restore_phase_script.new(
			self,
			transition_context,
			active_turn_token
		)
	)
	phase_runner.push_phase(
		encounter_transition_presentation_phase_script.new(
			self,
			transition_context,
			fainted_species_id,
			active_turn_token,
			include_fainted_text
		)
	)
	phase_runner.push_phase(
		encounter_transition_finalize_phase_script.new(
			self,
			transition_context,
			fainted_species_id,
			active_turn_token,
			include_fainted_text
		)
	)

	if phase_runner.is_running():
		yield(phase_runner, "queue_idle")
	_log_transition_checkpoint("advance_to_next_enemy.queue_idle")
	active_transition_run_id = ""

	return

func _is_turn_token_cancelled(active_turn_token: int) -> bool:
	return active_turn_token != -1 and active_turn_token != turn_token

func _advance_to_next_enemy_seed_and_load_phase_state(fainted_species_id: String, active_turn_token: int = -1) -> Dictionary:
	_log_transition_checkpoint("seed_load.entry", {
		"fainted_species_id": fainted_species_id,
		"active_turn_token": active_turn_token,
	})
	var transition_state := {
		"ok": false,
		"cancelled": false,
		"early_return": false,
		"trainer_party_switch": _is_active_trainer_encounter(),
		"next_is_seeded_trainer": false,
		"next_trainer_seed_failed": false,
		"next_enemy": null,
		"next_trainer_seed": {},
		"next_biome_state": {},
	}

	var trainer_party_switch = bool(transition_state["trainer_party_switch"])
	var enemy_slide_out = null
	if not trainer_party_switch:
		enemy_slide_out = animate_enemy_layer_to(
			enemy_layer_home_position + Vector2(enemy_switch_slide_distance_px, 0),
			enemy_switch_slide_duration_sec,
			active_turn_token
		)
	_animate_enemy_panel_to(_enemy_panel_hidden_position(), max(0.0, enemy_panel_slide_duration_sec), active_turn_token)
	if enemy_slide_out is GDScriptFunctionState:
		yield(enemy_slide_out, "completed")
		if _is_turn_token_cancelled(active_turn_token):
			transition_state["cancelled"] = true
			_log_transition_checkpoint("seed_load.cancelled_after_slide_out")
			return transition_state

	var next_enemy = null
	var next_biome_state = {}
	var next_encounter_meta := {}
	var next_trainer_seed := {}
	var next_is_seeded_trainer := false
	var next_trainer_seed_failed := false

	if trainer_party_switch:
		next_enemy = _dequeue_next_trainer_enemy()
		next_biome_state = _get_battle_biome_state().duplicate(true)
		next_biome_state["transition_trigger"] = "trainer_party_progress"
		next_encounter_meta = _build_encounter_metadata(next_biome_state, "")
	else:
		next_biome_state = _advance_runtime_biome_state("enemy_defeated")
		next_encounter_meta = _build_encounter_metadata(next_biome_state, "")
		if bool(next_encounter_meta.get("is_trainer_encounter", false)):
			next_trainer_seed = _try_seed_trainer_encounter(next_encounter_meta, next_biome_state)
			if not next_trainer_seed.empty() and next_trainer_seed.has("enemy") and next_trainer_seed["enemy"] != null:
				next_enemy = next_trainer_seed["enemy"]
				next_is_seeded_trainer = true
			else:
				next_trainer_seed_failed = true
		if catalog_loader == null:
			catalog_loader = catalog_loader_script.new()
		if next_enemy == null and catalog_loader != null and catalog_loader.load_catalogs():
			var next_enemy_species_id = _pick_biome_weighted_enemy_species_id(fainted_species_id, next_biome_state, next_encounter_meta)
			var next_enemy_base_level = 5
			var next_enemy_scaling = _resolve_biome_level_scaling(next_encounter_meta, next_enemy_base_level, next_biome_state)
			var next_enemy_level = int(next_enemy_scaling.get("target_level", next_enemy_base_level))
			_log_transition_checkpoint("biome_level_scaling.resolved", {
				"source": "wild_seed_transition",
				"biome_id": String(next_enemy_scaling.get("biome_id", "")),
				"encounter_number": int(next_enemy_scaling.get("encounter_number", 0)),
				"encounter_archetype": String(next_enemy_scaling.get("encounter_archetype", ENCOUNTER_ARCHETYPE_NORMAL_POKEMON)),
				"base_level": next_enemy_base_level,
				"floor_index": int(next_enemy_scaling.get("floor_index", 0)),
				"player_level": int(next_enemy_scaling.get("player_level", 1)),
				"floor_bonus": int(next_enemy_scaling.get("floor_bonus", 0)),
				"archetype_bonus": int(next_enemy_scaling.get("archetype_bonus", 0)),
				"difficulty_delta": int(next_enemy_scaling.get("difficulty_delta", 0)),
				"target_level": next_enemy_level,
			})
			next_enemy = catalog_loader.build_pokemon_data(next_enemy_species_id, next_enemy_level)

	if next_enemy == null:
		enemy_layer.rect_position = enemy_layer_home_position
		end_battle(true, fainted_species_id)
		_log_transition_checkpoint("seed_load.no_next_enemy_end_battle")
		return transition_state

	var biome_changed = _did_biome_change(next_biome_state)

	if trainer_party_switch or not biome_changed:
		battle_data["enemy"] = next_enemy
		if not trainer_party_switch:
			if next_is_seeded_trainer:
				_apply_trainer_seed_to_battle_data(next_trainer_seed)
			else:
				_set_enemy_trainer_state_cleared()
		_apply_biome_state_to_battle_data(next_biome_state)
		if not trainer_party_switch and next_trainer_seed_failed:
			var fallback_meta = battle_data.get("encounter_meta", {}).duplicate(true)
			fallback_meta["encounter_type"] = ENCOUNTER_TYPE_WILD
			fallback_meta["is_trainer_encounter"] = false
			fallback_meta["trainer_id"] = ""
			fallback_meta["trainer_display_name"] = ""
			if bool(fallback_meta.get("is_boss_encounter", false)):
				fallback_meta["encounter_archetype"] = ENCOUNTER_ARCHETYPE_BOSS_POKEMON
			else:
				fallback_meta["encounter_archetype"] = ENCOUNTER_ARCHETYPE_NORMAL_POKEMON
			_apply_encounter_metadata_to_battle_data(fallback_meta)
		if trainer_party_switch:
			enemy_layer.rect_position = enemy_layer_home_position
		else:
			enemy_layer.rect_position = enemy_layer_home_position + Vector2(-enemy_switch_slide_distance_px, 0)
		if enemy_panel != null:
			enemy_panel.rect_position = _enemy_panel_hidden_position()
		load_battle_sprites()
		player_sprite_anim_enabled = true
		enemy_sprite_anim_enabled = true
		restore_battler_sprite_state(player_pokemon_sprite, player_sprite_home_position)
		restore_battler_sprite_state(enemy_pokemon_sprite, enemy_sprite_home_position)
		reset_pokemon_animation_state()
		if trainer_party_switch and enemy_pokemon_sprite != null:
			enemy_pokemon_sprite.visible = false

	transition_state["ok"] = true
	transition_state["next_enemy"] = next_enemy
	transition_state["next_biome_state"] = next_biome_state
	transition_state["next_trainer_seed"] = next_trainer_seed
	transition_state["next_is_seeded_trainer"] = next_is_seeded_trainer
	transition_state["next_trainer_seed_failed"] = next_trainer_seed_failed
	transition_state["biome_changed"] = biome_changed
	_log_transition_checkpoint("seed_load.ready", {
		"trainer_party_switch": trainer_party_switch,
		"next_is_seeded_trainer": next_is_seeded_trainer,
		"next_trainer_seed_failed": next_trainer_seed_failed,
		"biome_changed": bool(transition_state.get("biome_changed", false)),
		"next_enemy_species": String(next_enemy.species_id),
	})
	return transition_state

func _did_biome_change(next_biome_state: Dictionary) -> bool:
	if typeof(next_biome_state) != TYPE_DICTIONARY:
		return false
	var previous_biome_id = String(next_biome_state.get("previous_biome_id", "")).strip_edges().to_lower()
	var current_biome_id = String(next_biome_state.get("current_biome_id", "")).strip_edges().to_lower()
	if previous_biome_id.empty() or current_biome_id.empty():
		return false
	return previous_biome_id != current_biome_id

func _run_biome_transition_party_restore_phase_state(transition_state: Dictionary, active_turn_token: int):
	if typeof(transition_state) != TYPE_DICTIONARY or transition_state.empty():
		return null
	if bool(transition_state.get("cancelled", false)) or not bool(transition_state.get("ok", false)):
		return null
	if bool(transition_state.get("trainer_party_switch", false)):
		return null
	if not bool(transition_state.get("biome_changed", false)):
		return null
	if _is_turn_token_cancelled(active_turn_token):
		transition_state["cancelled"] = true
		return null

	_log_transition_checkpoint("biome_restore.entry", {
		"next_is_seeded_trainer": bool(transition_state.get("next_is_seeded_trainer", false)),
	})

	hide_all_command_menus()
	set_sendout_controls_locked(true)

	var recall_turn_token = active_turn_token if active_turn_token != -1 else turn_token
	var outgoing_species_label = "POKEMON"
	if battle_data != null and battle_data.has("player") and battle_data["player"] != null:
		outgoing_species_label = String(battle_data["player"].species_id).strip_edges().to_upper()
		if outgoing_species_label.empty():
			outgoing_species_label = "POKEMON"
	sync_active_party_member_from_battle()
	set_battle_text("Come back! %s!" % outgoing_species_label)
	var recall_anim = _play_player_switch_withdraw_animation(recall_turn_token)
	if recall_anim is GDScriptFunctionState:
		yield(recall_anim, "completed")
		if _is_turn_token_cancelled(active_turn_token):
			transition_state["cancelled"] = true
			_log_transition_checkpoint("biome_restore.cancelled_after_recall")
			return null
	if biome_transition_post_recall_delay_sec > 0.0:
		yield(get_tree().create_timer(biome_transition_post_recall_delay_sec), "timeout")
		if _is_turn_token_cancelled(active_turn_token):
			transition_state["cancelled"] = true
			_log_transition_checkpoint("biome_restore.cancelled_after_recall_delay")
			return null
	transition_state["biome_transition_recalled"] = true

	var trainer_reentry = _run_player_trainer_reentry_sequence(active_turn_token)
	if trainer_reentry is GDScriptFunctionState:
		yield(trainer_reentry, "completed")
		if _is_turn_token_cancelled(active_turn_token):
			transition_state["cancelled"] = true
			_log_transition_checkpoint("biome_restore.cancelled_after_trainer_reentry")
			return null
	if biome_transition_post_reentry_delay_sec > 0.0:
		yield(get_tree().create_timer(biome_transition_post_reentry_delay_sec), "timeout")
		if _is_turn_token_cancelled(active_turn_token):
			transition_state["cancelled"] = true
			_log_transition_checkpoint("biome_restore.cancelled_after_reentry_delay")
			return null

	var fade_out = _play_transition_fade_to_alpha(1.0, biome_transition_fade_out_duration_sec, active_turn_token)
	if fade_out is GDScriptFunctionState:
		yield(fade_out, "completed")
		if _is_turn_token_cancelled(active_turn_token):
			transition_state["cancelled"] = true
			_log_transition_checkpoint("biome_restore.cancelled_after_fade_out")
			return null

	suppress_arena_bgm_apply = true
	_apply_pending_transition_battle_state(transition_state)
	_apply_full_party_restore_for_biome_transition()
	var heal_wait = _play_biome_transition_heal_sfx_and_wait(active_turn_token)
	if heal_wait is GDScriptFunctionState:
		yield(heal_wait, "completed")
		if _is_turn_token_cancelled(active_turn_token):
			transition_state["cancelled"] = true
			_log_transition_checkpoint("biome_restore.cancelled_during_blackout")
			return null

	var fade_in = _play_transition_fade_to_alpha(0.0, biome_transition_fade_in_duration_sec, active_turn_token)
	if fade_in is GDScriptFunctionState:
		yield(fade_in, "completed")
		if _is_turn_token_cancelled(active_turn_token):
			transition_state["cancelled"] = true
			_log_transition_checkpoint("biome_restore.cancelled_after_fade_in")
			return null
	if biome_transition_post_fade_in_delay_sec > 0.0:
		yield(get_tree().create_timer(biome_transition_post_fade_in_delay_sec), "timeout")
		if _is_turn_token_cancelled(active_turn_token):
			transition_state["cancelled"] = true
			_log_transition_checkpoint("biome_restore.cancelled_after_fade_in_delay")
			return null

	transition_state["biome_transition_restart_opening"] = true

	_log_transition_checkpoint("biome_restore.complete", {
		"next_is_seeded_trainer": bool(transition_state.get("next_is_seeded_trainer", false)),
	})
	return null

func _apply_pending_transition_battle_state(transition_state: Dictionary) -> void:
	if typeof(transition_state) != TYPE_DICTIONARY or transition_state.empty():
		return
	var next_enemy = transition_state.get("next_enemy", null)
	var next_biome_state = transition_state.get("next_biome_state", {})
	var next_trainer_seed = transition_state.get("next_trainer_seed", {})
	var next_is_seeded_trainer = bool(transition_state.get("next_is_seeded_trainer", false))
	var next_trainer_seed_failed = bool(transition_state.get("next_trainer_seed_failed", false))
	if next_enemy == null or battle_data == null:
		return

	battle_data["enemy"] = next_enemy
	if next_is_seeded_trainer:
		_apply_trainer_seed_to_battle_data(next_trainer_seed)
	else:
		_set_enemy_trainer_state_cleared()
	_apply_biome_state_to_battle_data(next_biome_state)
	if next_trainer_seed_failed:
		var fallback_meta = battle_data.get("encounter_meta", {}).duplicate(true)
		fallback_meta["encounter_type"] = ENCOUNTER_TYPE_WILD
		fallback_meta["is_trainer_encounter"] = false
		fallback_meta["trainer_id"] = ""
		fallback_meta["trainer_display_name"] = ""
		if bool(fallback_meta.get("is_boss_encounter", false)):
			fallback_meta["encounter_archetype"] = ENCOUNTER_ARCHETYPE_BOSS_POKEMON
		else:
			fallback_meta["encounter_archetype"] = ENCOUNTER_ARCHETYPE_NORMAL_POKEMON
		_apply_encounter_metadata_to_battle_data(fallback_meta)

	battle_data["force_player_trainer_intro"] = true
	if enemy_panel != null:
		enemy_panel.rect_position = _enemy_panel_hidden_position()
	enemy_layer.rect_position = enemy_layer_home_position + Vector2(-enemy_switch_slide_distance_px, 0)
	load_battle_sprites()
	player_sprite_anim_enabled = true
	enemy_sprite_anim_enabled = true
	restore_battler_sprite_state(player_pokemon_sprite, player_sprite_home_position)
	restore_battler_sprite_state(enemy_pokemon_sprite, enemy_sprite_home_position)
	reset_pokemon_animation_state()
	if player_pokemon_sprite != null:
		player_pokemon_sprite.visible = false
	if enemy_pokemon_sprite != null:
		enemy_pokemon_sprite.visible = false
	if player_trainer_sprite != null:
		player_trainer_sprite.visible = true
		player_trainer_sprite.position = player_trainer_sprite_home_position
		player_trainer_sprite.modulate = Color(1, 1, 1, 1)
	bind_battle_data()

func _apply_full_party_restore_for_biome_transition() -> void:
	if runtime_state_script == null:
		return
	var party = runtime_state_script.get_party(get_tree())
	if party == null:
		return
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()
	if catalog_loader == null or not catalog_loader.load_catalogs():
		return

	for slot_index in range(party.size()):
		var member = party.get_member_at(slot_index)
		if member.empty():
			continue
		var species_id = String(member.get("species_id", "")).strip_edges().to_upper()
		if species_id.empty():
			continue
		var level = max(1, int(member.get("level", 5)))
		var move_ids = member.get("move_ids", [])
		if typeof(move_ids) != TYPE_ARRAY:
			move_ids = []
		var rebuilt_data = catalog_loader.build_pokemon_data(species_id, level, move_ids)
		if rebuilt_data == null:
			continue
		var max_hp = max(1, int(rebuilt_data.get_base_stat("hp")))
		for move in rebuilt_data.moves:
			if move == null:
				continue
			if move.has_method("restore_pp_full"):
				move.restore_pp_full()
		_apply_debug_pp_overrides_to_pokemon(rebuilt_data, "biome_restore.party_slot")
		var restored_pp := []
		for move in rebuilt_data.moves:
			if move == null:
				continue
			restored_pp.append(int(move.current_pp))
		party.update_member_at(slot_index, {
			"current_hp": max_hp,
			"move_pp_current": restored_pp,
		})

	if battle_data == null or not battle_data.has("player") or battle_data["player"] == null:
		return
	var active_index = party.get_active_slot_index()
	var active_member = party.get_member_at(active_index)
	if active_member.empty():
		return
	var active_species_id = String(active_member.get("species_id", "")).strip_edges().to_upper()
	if active_species_id.empty():
		return
	var active_level = max(1, int(active_member.get("level", 5)))
	var active_move_ids = active_member.get("move_ids", [])
	if typeof(active_move_ids) != TYPE_ARRAY:
		active_move_ids = []
	var active_rebuilt = catalog_loader.build_pokemon_data(active_species_id, active_level, active_move_ids)
	if active_rebuilt == null:
		return
	var active_max_hp = max(1, int(active_rebuilt.get_base_stat("hp")))
	for move in active_rebuilt.moves:
		if move == null:
			continue
		if move.has_method("restore_pp_full"):
			move.restore_pp_full()
	_apply_debug_pp_overrides_to_pokemon(active_rebuilt, "biome_restore.active")
	battle_data["player"].current_hp = active_max_hp
	battle_data["player"].moves = active_rebuilt.moves.duplicate(true)
	refresh_hp_ui(battle_data["player"], player_hp_bar, player_hp_value_label)
	refresh_attack_menu()
	sync_active_party_member_from_battle()

func _advance_to_next_enemy_run_presentation_phase_state(transition_state: Dictionary, active_turn_token: int = -1):
	if typeof(transition_state) != TYPE_DICTIONARY or transition_state.empty():
		return null

	var trainer_party_switch = bool(transition_state.get("trainer_party_switch", false))
	var biome_transition_restart_opening = bool(transition_state.get("biome_transition_restart_opening", false))
	var next_is_seeded_trainer = bool(transition_state.get("next_is_seeded_trainer", false))
	var biome_transition_recalled = bool(transition_state.get("biome_transition_recalled", false))
	var next_enemy = transition_state.get("next_enemy", null)
	var next_enemy_species_id = String(next_enemy.species_id) if next_enemy != null else ""

	if trainer_party_switch:
		_log_transition_checkpoint("presentation.branch", {"type": "trainer_party_switch"})
		var trainer_switch_sequence = _run_enemy_trainer_party_switch_sequence(next_enemy_species_id)
		if trainer_switch_sequence is GDScriptFunctionState:
			yield(trainer_switch_sequence, "completed")
			if _is_turn_token_cancelled(active_turn_token):
				transition_state["cancelled"] = true
				_log_transition_checkpoint("presentation.cancelled.trainer_party_switch")
				return null
	elif biome_transition_restart_opening:
		_log_transition_checkpoint("presentation.branch", {"type": "biome_restart_opening"})
		hide_all_command_menus()
		set_sendout_controls_locked(true)
		_set_enemy_next_trainer_presentation_visible(true)
		bind_battle_data()
		var opening_run = _start_battle_opening_sequence()
		if opening_run is GDScriptFunctionState:
			yield(opening_run, "completed")
			if _is_turn_token_cancelled(active_turn_token):
				transition_state["cancelled"] = true
				_log_transition_checkpoint("presentation.cancelled.biome_restart_opening")
				return null
		transition_state["early_return"] = true
		_log_transition_checkpoint("presentation.early_return_to_opening")
		return null
	elif next_is_seeded_trainer:
		_log_transition_checkpoint("presentation.branch", {"type": "next_seeded_trainer"})
		hide_all_command_menus()
		set_sendout_controls_locked(true)
		enemy_layer.rect_position = enemy_layer_home_position
		if enemy_panel != null:
			enemy_panel.rect_position = _enemy_panel_hidden_position()
		_set_enemy_next_trainer_presentation_visible(false)
		var recall_turn_token = active_turn_token if active_turn_token != -1 else turn_token
		if not biome_transition_recalled:
			var recall_anim = _play_player_switch_withdraw_animation(recall_turn_token)
			if recall_anim is GDScriptFunctionState:
				yield(recall_anim, "completed")
				if _is_turn_token_cancelled(active_turn_token):
					transition_state["cancelled"] = true
					_log_transition_checkpoint("presentation.cancelled.seeded_trainer_recall")
					return null
		else:
			_log_transition_checkpoint("presentation.seeded_trainer_recall_skipped_biome_restore")
		var trainer_reentry = _run_player_trainer_reentry_sequence(active_turn_token)
		if trainer_reentry is GDScriptFunctionState:
			yield(trainer_reentry, "completed")
			if _is_turn_token_cancelled(active_turn_token):
				transition_state["cancelled"] = true
				_log_transition_checkpoint("presentation.cancelled.seeded_trainer_reentry")
				return null
		_set_enemy_next_trainer_presentation_visible(true)
		bind_battle_data()
		_start_battle_opening_sequence()
		transition_state["early_return"] = true
		_log_transition_checkpoint("presentation.early_return_to_opening")
		return null
	else:
		_log_transition_checkpoint("presentation.branch", {"type": "wild_slide_in"})
		bind_battle_data()
		if enemy_pokemon_sprite != null:
			enemy_pokemon_sprite.visible = true
		var enemy_slide_in = animate_enemy_layer_to(enemy_layer_home_position, enemy_switch_slide_duration_sec, active_turn_token)
		_animate_enemy_panel_to(enemy_panel_home_position, max(0.0, enemy_panel_slide_duration_sec), active_turn_token)
		if enemy_slide_in is GDScriptFunctionState:
			yield(enemy_slide_in, "completed")
			if _is_turn_token_cancelled(active_turn_token):
				transition_state["cancelled"] = true
				_log_transition_checkpoint("presentation.cancelled.wild_slide_in")
				return null

	if active_turn_token == -1:
		_show_main_controls_unlocked()
	else:
		show_main_controls()
	_log_transition_checkpoint("presentation.complete")

	return null

func _advance_to_next_enemy_finalize_phase_state(transition_state: Dictionary, fainted_species_id: String, include_fainted_text: bool = true) -> void:
	if typeof(transition_state) != TYPE_DICTIONARY or transition_state.empty():
		return
	var next_enemy = transition_state.get("next_enemy", null)
	if next_enemy == null:
		return
	var trainer_party_switch = bool(transition_state.get("trainer_party_switch", false))

	var appeared_message = _build_enemy_appeared_message(String(next_enemy.species_id))
	if include_fainted_text and not fainted_species_id.empty():
		set_battle_text("%s fainted! %s" % [fainted_species_id, appeared_message])
	else:
		set_battle_text(appeared_message)
	if not trainer_party_switch:
		_play_enemy_sendout_cry_once()
	_log_transition_checkpoint("finalize.complete", {
		"trainer_party_switch": trainer_party_switch,
		"next_enemy_species": String(next_enemy.species_id),
	})

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

func _enemy_panel_hidden_position() -> Vector2:
	return enemy_panel_home_position + Vector2(-enemy_panel_slide_distance_px, 0)

func _player_panel_hidden_position() -> Vector2:
	return player_panel_home_position + Vector2(player_panel_switch_slide_distance_px, 0)

func _stop_enemy_panel_tween() -> void:
	if enemy_panel_tween != null and is_instance_valid(enemy_panel_tween):
		enemy_panel_tween.stop_all()
		enemy_panel_tween.queue_free()
	enemy_panel_tween = null

func _animate_enemy_panel_to(target_position: Vector2, duration_sec: float, active_turn_token: int = -1):
	if enemy_panel == null:
		return null
	var hidden_target = _enemy_panel_hidden_position()
	var is_hidden_target = is_equal_approx(target_position.x, hidden_target.x) and is_equal_approx(target_position.y, hidden_target.y)

	_stop_enemy_panel_tween()
	if duration_sec <= 0.0:
		enemy_panel.rect_position = target_position
		enemy_panel.visible = not is_hidden_target
		return null

	if not is_hidden_target:
		enemy_panel.visible = true

	enemy_panel_tween = Tween.new()
	add_child(enemy_panel_tween)
	enemy_panel_tween.interpolate_property(
		enemy_panel,
		"rect_position",
		enemy_panel.rect_position,
		target_position,
		duration_sec,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	enemy_panel_tween.start()
	yield(enemy_panel_tween, "tween_all_completed")

	if enemy_panel_tween != null and is_instance_valid(enemy_panel_tween):
		enemy_panel_tween.queue_free()
	enemy_panel_tween = null

	if active_turn_token != -1 and active_turn_token != turn_token:
		return null

	enemy_panel.rect_position = target_position
	enemy_panel.visible = not is_hidden_target
	return null

func _stop_player_panel_switch_tween() -> void:
	if player_panel_switch_tween != null and is_instance_valid(player_panel_switch_tween):
		player_panel_switch_tween.stop_all()
		player_panel_switch_tween.queue_free()
	player_panel_switch_tween = null

func _animate_player_panel_to(target_position: Vector2, duration_sec: float, active_turn_token: int = -1):
	if player_panel == null:
		return null
	var hidden_target = _player_panel_hidden_position()
	var is_hidden_target = is_equal_approx(target_position.x, hidden_target.x) and is_equal_approx(target_position.y, hidden_target.y)

	_stop_player_panel_switch_tween()
	if duration_sec <= 0.0:
		player_panel.rect_position = target_position
		player_panel.visible = not is_hidden_target
		return null

	if not is_hidden_target:
		player_panel.visible = true

	player_panel_switch_tween = Tween.new()
	add_child(player_panel_switch_tween)
	player_panel_switch_tween.interpolate_property(
		player_panel,
		"rect_position",
		player_panel.rect_position,
		target_position,
		duration_sec,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	player_panel_switch_tween.start()
	yield(player_panel_switch_tween, "tween_all_completed")

	if player_panel_switch_tween != null and is_instance_valid(player_panel_switch_tween):
		player_panel_switch_tween.queue_free()
	player_panel_switch_tween = null

	if active_turn_token != -1 and active_turn_token != turn_token:
		return null

	player_panel.rect_position = target_position
	player_panel.visible = not is_hidden_target
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
	if pokedex_overlay_visible and pokedex_overlay != null:
		var pokedex_focus_owner = get_focus_owner()
		if pokedex_overlay.is_overlay_focus_owner(pokedex_focus_owner):
			return
		pokedex_overlay.focus_default()
		return

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
	if pokedex_overlay_visible and pokedex_overlay != null:
		pokedex_overlay.move_focus(action_name)
		return
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
	if pokedex_overlay_visible and pokedex_overlay != null:
		pokedex_overlay.press_focused()
		return
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
	run_button.text = "Run"

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
	_close_pokedex_overlay_internal()
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

func open_party_menu(skip_fade: bool = false):
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
	_stop_party_menu_fade_tween()
	party_menu_overlay.open_menu(members, active_index)
	if skip_fade:
		_set_party_menu_overlay_alpha(1.0)
		party_menu_visible = true
		set_battle_text("Party menu open.")
		return
	var fade_duration = max(0.0, party_menu_overlay_fade_duration_sec)
	if fade_duration <= 0.0:
		_set_party_menu_overlay_alpha(1.0)
	else:
		_set_party_menu_overlay_alpha(0.0)
		party_menu_fade_tween = Tween.new()
		add_child(party_menu_fade_tween)
		party_menu_fade_tween.interpolate_property(
			party_menu_overlay,
			"modulate:a",
			party_menu_overlay.modulate.a,
			1.0,
			fade_duration,
			Tween.TRANS_SINE,
			Tween.EASE_OUT
		)
		_connect_once(party_menu_fade_tween, "tween_all_completed", "_on_party_menu_fade_in_completed")
		party_menu_fade_tween.start()
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
	var move_pp_current := []
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
			if move.has_method("has_pp"):
				move_pp_current.append(int(move.current_pp))
			else:
				move_pp_current.append(-1)

	var next_level = int(player_data.level)
	var next_current_hp = int(player_data.current_hp)
	var existing_member = party.get_member_at(active_index)
	if not existing_member.empty():
		var existing_level = int(existing_member.get("level", -1))
		var existing_current_hp = int(existing_member.get("current_hp", -1))
		var existing_move_ids = existing_member.get("move_ids", [])
		var existing_move_pp_current = existing_member.get("move_pp_current", [])
		if typeof(existing_move_ids) == TYPE_ARRAY \
				and existing_level == next_level \
				and existing_current_hp == next_current_hp \
				and existing_move_ids == move_ids \
				and existing_move_pp_current == move_pp_current:
			return

	party.update_member_at(active_index, {
		"level": next_level,
		"current_hp": next_current_hp,
		"move_ids": move_ids,
		"move_pp_current": move_pp_current,
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
	var saved_move_pp_current = member.get("move_pp_current", [])
	if typeof(saved_move_pp_current) == TYPE_ARRAY:
		for i in range(min(saved_move_pp_current.size(), player_data.moves.size())):
			var saved_pp = int(saved_move_pp_current[i])
			if saved_pp < 0:
				continue
			var move = player_data.moves[i]
			if move == null:
				continue
			if move.has_method("set_current_pp"):
				move.set_current_pp(saved_pp)

	var saved_hp = int(member.get("current_hp", -1))
	if saved_hp >= 0:
		var max_hp = max(1, int(player_data.get_base_stat("hp")))
		player_data.current_hp = int(clamp(saved_hp, 0, max_hp))

	_apply_debug_pp_overrides_to_pokemon(player_data, "build_player_from_party")

	return player_data

func _play_player_switch_withdraw_animation(active_turn_token: int):
	if player_pokemon_sprite == null:
		return null
	_animate_player_panel_to(
		_player_panel_hidden_position(),
		max(0.0, player_panel_switch_slide_duration_sec),
		active_turn_token
	)

	if not battle_fx_enabled:
		player_pokemon_sprite.visible = false
		return null

	if not _apply_pokeball_frame(POKEBALL_FRAME_CLOSED):
		player_pokemon_sprite.visible = false
		return null

	var ball_target_pos = player_sprite_home_position + Vector2(player_pokeball_target_offset_x, player_pokeball_target_offset_y)
	player_pokeball_sprite.visible = true
	player_pokeball_sprite.rotation_degrees = 0.0
	player_pokeball_sprite.position = ball_target_pos

	var start_pos = player_pokemon_sprite.position
	var start_scale = player_pokemon_sprite.scale
	var target_scale = start_scale * max(0.1, player_pokemon_reveal_start_scale)
	var start_modulate = player_pokemon_sprite.modulate
	var duration = max(0.01, player_pokemon_reveal_scale_duration_sec)

	var recall_tween = Tween.new()
	add_child(recall_tween)
	recall_tween.interpolate_property(player_pokemon_sprite, "position", start_pos, ball_target_pos, duration, Tween.TRANS_SINE, Tween.EASE_IN)
	recall_tween.interpolate_property(player_pokemon_sprite, "scale", start_scale, target_scale, duration, Tween.TRANS_SINE, Tween.EASE_IN)
	recall_tween.interpolate_property(player_pokemon_sprite, "modulate:a", start_modulate.a, 0.0, duration, Tween.TRANS_SINE, Tween.EASE_IN)
	recall_tween.start()
	yield(recall_tween, "tween_all_completed")
	recall_tween.queue_free()
	if active_turn_token != turn_token:
		return null

	player_pokemon_sprite.visible = false
	player_pokemon_sprite.position = player_sprite_home_position
	player_pokemon_sprite.scale = player_sprite_home_scale
	player_pokemon_sprite.modulate = Color(1, 1, 1, 1)
	return null

func _play_player_switch_sendout_animation(active_turn_token: int):
	if player_pokemon_sprite != null:
		player_pokemon_sprite.visible = false
	if not _apply_pokeball_frame(POKEBALL_FRAME_CLOSED):
		if player_pokemon_sprite != null:
			player_pokemon_sprite.visible = true
			player_pokemon_sprite.position = player_sprite_home_position
			player_pokemon_sprite.scale = player_sprite_home_scale
			player_pokemon_sprite.modulate = Color(1, 1, 1, 1)
			_play_player_sendout_cry_once()
		_animate_player_panel_to(player_panel_home_position, max(0.0, player_panel_switch_slide_duration_sec), active_turn_token)
		return null

	var sprite = player_pokeball_sprite
	sprite.visible = true
	sprite.rotation_degrees = 0.0
	var target_pos = player_sprite_home_position + Vector2(player_pokeball_target_offset_x, player_pokeball_target_offset_y)
	var start_pos = Vector2(-24.0, target_pos.y + player_pokeball_start_offset_y)
	var arc_peak_y = min(start_pos.y, target_pos.y) - abs(player_pokeball_arc_height_px)
	var total_duration = max(0.08, player_pokeball_lob_duration_sec)
	var up_duration = clamp(player_pokeball_lob_up_duration_sec, 0.04, total_duration - 0.04)
	var down_duration = max(0.04, total_duration - up_duration)
	sprite.position = start_pos

	var throw_tween = Tween.new()
	add_child(throw_tween)
	throw_tween.interpolate_property(sprite, "position:x", start_pos.x, target_pos.x, total_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	throw_tween.interpolate_property(sprite, "rotation_degrees", 0.0, player_pokeball_spin_degrees, total_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	throw_tween.interpolate_property(sprite, "position:y", start_pos.y, arc_peak_y, up_duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	throw_tween.interpolate_property(sprite, "position:y", arc_peak_y, target_pos.y, down_duration, Tween.TRANS_CUBIC, Tween.EASE_IN, up_duration)
	throw_tween.start()
	yield(throw_tween, "tween_all_completed")
	throw_tween.queue_free()
	if active_turn_token != turn_token:
		return null

	var _opening_frame_applied = _apply_pokeball_frame(POKEBALL_FRAME_OPENING)
	yield(get_tree().create_timer(max(0.01, player_pokeball_opening_hold_sec)), "timeout")
	if active_turn_token != turn_token:
		return null

	var _open_frame_applied = _apply_pokeball_frame(POKEBALL_FRAME_OPEN)
	_play_player_pokeball_release_sfx()
	_spawn_player_pokeball_open_particles(target_pos + Vector2(0, -2))

	if player_pokemon_sprite == null:
		_hide_player_pokeball_sprite()
		return null

	if not battle_fx_enabled:
		player_pokemon_sprite.visible = true
		player_pokemon_sprite.position = player_sprite_home_position
		player_pokemon_sprite.scale = player_sprite_home_scale
		player_pokemon_sprite.modulate = Color(1, 1, 1, 1)
		_animate_player_panel_to(player_panel_home_position, max(0.0, player_panel_switch_slide_duration_sec), active_turn_token)
		_play_player_sendout_cry_once()
		yield(get_tree().create_timer(max(0.01, player_pokeball_open_hold_sec)), "timeout")
		_hide_player_pokeball_sprite()
		return null

	var start_scale_mul = max(0.1, player_pokemon_reveal_start_scale)
	var target_scale = player_sprite_home_scale
	var start_scale = Vector2(target_scale.x * start_scale_mul, target_scale.y * start_scale_mul)
	var tint = player_pokemon_reveal_tint_color
	var flash_mul = max(0.1, player_pokemon_reveal_flash_mul)
	tint.r = clamp(tint.r * flash_mul, 0.0, 2.0)
	tint.g = clamp(tint.g * flash_mul, 0.0, 2.0)
	tint.b = clamp(tint.b * flash_mul, 0.0, 2.0)
	tint.a = clamp(player_pokemon_reveal_alpha_start, 0.0, 1.0)
	player_pokemon_sprite.position = player_sprite_home_position
	player_pokemon_sprite.scale = start_scale
	player_pokemon_sprite.modulate = tint
	player_pokemon_sprite.visible = true
	_animate_player_panel_to(player_panel_home_position, max(0.0, player_panel_switch_slide_duration_sec), active_turn_token)

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
	yield(reveal_tween, "tween_all_completed")
	reveal_tween.queue_free()
	if active_turn_token != turn_token:
		return null

	_play_player_sendout_cry_once()
	yield(get_tree().create_timer(max(0.01, player_pokeball_open_hold_sec)), "timeout")
	_hide_player_pokeball_sprite()
	return null

func _run_enemy_action_after_player_switch(player_data, active_turn_token: int):
	if battle_data == null or not battle_data.has("enemy"):
		return null

	var enemy = battle_data["enemy"]
	if enemy == null or enemy.moves.empty():
		return null

	var enemy_move = _get_first_usable_move(enemy)
	if enemy_move == null:
		enemy_move = _build_struggle_move()

	var enemy_using_struggle = _is_move_struggle(enemy_move)
	if enemy_using_struggle:
		set_battle_text("%s has no moves left that it can use!" % String(enemy.species_id))
		if turn_step_delay_sec > 0.0:
			yield(get_tree().create_timer(turn_step_delay_sec), "timeout")
			if active_turn_token != turn_token:
				return null

	var enemy_move_anim = play_move_animation(enemy_move.move_id, enemy_pokemon_sprite, player_pokemon_sprite, active_turn_token)
	if enemy_move_anim is GDScriptFunctionState:
		yield(enemy_move_anim, "completed")
		if active_turn_token != turn_token:
			return null

	_consume_move_pp(enemy_move)
	var enemy_damage = int(battle_calc_script.calc_damage(enemy, enemy_move, player_data, debug_damage_calculation_enabled))
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

	if enemy_using_struggle:
		var enemy_recoil_damage = _apply_struggle_recoil(enemy)
		if enemy_recoil_damage > 0:
			refresh_hp_ui(enemy, enemy_hp_bar, enemy_hp_value_label)
			set_battle_text("%s was damaged by the recoil!" % String(enemy.species_id))
			if turn_step_delay_sec > 0.0:
				yield(get_tree().create_timer(turn_step_delay_sec), "timeout")
				if active_turn_token != turn_token:
					return null
		if enemy.is_fainted():
			var enemy_faint_anim = play_faint_animation(enemy_pokemon_sprite, false, active_turn_token)
			if enemy_faint_anim is GDScriptFunctionState:
				yield(enemy_faint_anim, "completed")
				if active_turn_token != turn_token:
					return null
			set_battle_text("%s fainted!" % String(enemy.species_id))
			if turn_step_delay_sec > 0.0:
				yield(get_tree().create_timer(turn_step_delay_sec), "timeout")
				if active_turn_token != turn_token:
					return null
			var exp_flow = _award_exp_for_enemy_result(String(enemy.species_id).strip_edges().to_upper(), int(enemy.level), active_turn_token, "defeat")
			if exp_flow is GDScriptFunctionState:
				yield(exp_flow, "completed")
				if active_turn_token != turn_token:
					return null
			var enemy_advance = advance_to_next_enemy(String(enemy.species_id), active_turn_token, false)
			if enemy_advance is GDScriptFunctionState:
				yield(enemy_advance, "completed")
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
	if party_menu_overlay == null:
		return

	_stop_party_menu_fade_tween()
	if not party_menu_overlay.visible:
		party_menu_overlay.close_menu()
		_set_party_menu_overlay_alpha(1.0)
		return

	var fade_duration = max(0.0, party_menu_overlay_fade_duration_sec)
	if fade_duration <= 0.0:
		party_menu_overlay.close_menu()
		_set_party_menu_overlay_alpha(1.0)
		return

	var start_alpha = party_menu_overlay.modulate.a
	if start_alpha <= 0.0:
		party_menu_overlay.close_menu()
		_set_party_menu_overlay_alpha(1.0)
		return

	party_menu_fade_tween = Tween.new()
	add_child(party_menu_fade_tween)
	party_menu_fade_tween.interpolate_property(
		party_menu_overlay,
		"modulate:a",
		start_alpha,
		0.0,
		fade_duration,
		Tween.TRANS_SINE,
		Tween.EASE_IN
	)
	_connect_once(party_menu_fade_tween, "tween_all_completed", "_on_party_menu_fade_out_completed")
	party_menu_fade_tween.start()

func open_pokedex_overlay(species_id: String = "", return_to_party_menu: bool = false) -> void:
	if pokedex_overlay == null:
		set_battle_text("Pokedex entry scene is missing.")
		return

	hide_all_command_menus()
	pokedex_return_to_party_menu = return_to_party_menu
	var selected_species_id = species_id.strip_edges().to_upper()
	if selected_species_id.empty() and typeof(battle_data) == TYPE_DICTIONARY and battle_data.has("player") and battle_data["player"] != null:
		selected_species_id = String(battle_data["player"].species_id).strip_edges().to_upper()

	var is_caught = false
	if runtime_state_script != null:
		is_caught = runtime_state_script.has_caught_species(get_tree(), selected_species_id)

	pokedex_overlay.open_menu(selected_species_id, is_caught)
	pokedex_overlay_visible = true
	set_battle_text("Pokedex entry open.")

func _close_pokedex_overlay_internal() -> void:
	pokedex_overlay_visible = false
	pokedex_return_to_party_menu = false
	if pokedex_overlay != null:
		pokedex_overlay.close_menu()

func close_pokedex_overlay() -> void:
	if not pokedex_overlay_visible:
		return

	var should_return_to_party_menu = pokedex_return_to_party_menu
	_close_pokedex_overlay_internal()

	if should_return_to_party_menu and not battle_ended and not turn_in_progress and not capture_in_progress:
		open_party_menu(true)
		return

	if not battle_ended and not turn_in_progress and not capture_in_progress:
		_show_main_controls_unlocked()
	ensure_button_focus()

func _on_PartyMenu_close_requested():
	if forced_switch_pending:
		set_battle_text("Choose a Pokemon to continue the battle.")
		return
	close_party_menu()

func _on_PartyMenu_pokedex_entry_requested(species_id: String) -> void:
	if battle_ended:
		set_battle_text("Battle has ended. Press Ball to restart.")
		return
	if turn_in_progress or capture_in_progress:
		return
	open_pokedex_overlay(species_id, true)

func _on_Pokedex_close_requested() -> void:
	close_pokedex_overlay()

func _on_PartyMenu_switch_slot_requested(slot_index: int) -> void:
	if battle_ended:
		set_battle_text("Battle has ended. Press Ball to restart.")
		forced_switch_pending = false
		forced_switch_success = false
		forced_switch_active_turn_token = -1
		return

	if forced_switch_pending:
		var forced_result = _perform_player_switch_to_slot(slot_index, forced_switch_active_turn_token, false, false)
		if forced_result is GDScriptFunctionState:
			forced_result = yield(forced_result, "completed")
		if typeof(forced_result) == TYPE_DICTIONARY and bool(forced_result.get("ok", false)):
			forced_switch_success = true
			forced_switch_pending = false
			forced_switch_active_turn_token = -1
			return
		if typeof(forced_result) == TYPE_DICTIONARY and bool(forced_result.get("cancelled", false)):
			forced_switch_success = false
			forced_switch_pending = false
			forced_switch_active_turn_token = -1
			return
		# Keep forced switch pending when validation fails so the user can choose another slot.
		return

	if turn_in_progress or capture_in_progress:
		return

	turn_in_progress = true
	_enter_action_locked_state()
	var active_turn_token = turn_token
	var switch_result = _perform_player_switch_to_slot(slot_index, active_turn_token, true, true)
	if switch_result is GDScriptFunctionState:
		switch_result = yield(switch_result, "completed")

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
			button.disabled = not _can_use_move(move)
			button.text = "OHKO" if _is_debug_ohko_slot(i) else String(move.move_id)
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
	if _is_debug_ohko_slot(move_slot):
		attack_power_label.text = "Power: OHKO"
		attack_pp_label.text = "PP: DEBUG"
		return

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

func _is_debug_ohko_slot(move_slot: int) -> bool:
	if not debug_ohko_enabled:
		return false
	if move_slot < 0:
		return false
	var target_slot = clamp(debug_ohko_move_slot, 1, 4) - 1
	return move_slot == target_slot

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
	if move == null:
		return "-/-"
	if move.has_method("has_pp"):
		if int(move.max_pp) < 0:
			return "-/-"
		return "%d/%d" % [int(move.current_pp), int(move.max_pp)]

	if move is Dictionary:
		if move.has("current_pp") and move.has("max_pp"):
			return "%d/%d" % [int(move["current_pp"]), int(move["max_pp"])]
		if move.has("pp"):
			var pp = int(move["pp"])
			return "%d/%d" % [pp, pp]

	return "-/-"

func _can_use_move(move) -> bool:
	if move == null:
		return false
	if move.has_method("has_pp"):
		return bool(move.has_pp())
	if move is Dictionary and move.has("current_pp"):
		return int(move.get("current_pp", 0)) > 0
	return true

func _consume_move_pp(move, amount: int = 1) -> void:
	if move == null:
		return
	if move.has_method("consume_pp"):
		move.consume_pp(amount)

func _get_first_usable_move(pokemon_data):
	if pokemon_data == null:
		return null
	var moves = []
	if typeof(pokemon_data) == TYPE_DICTIONARY:
		moves = pokemon_data.get("moves", [])
	elif pokemon_data.has_method("get"):
		moves = pokemon_data.get("moves")
	if typeof(moves) != TYPE_ARRAY:
		return null
	for move in moves:
		if _can_use_move(move):
			return move
	return null

func _pokemon_has_any_usable_move(pokemon_data) -> bool:
	return _get_first_usable_move(pokemon_data) != null

func _is_move_struggle(move) -> bool:
	if move == null:
		return false
	return String(move.move_id).strip_edges().to_upper() == "STRUGGLE"

func _build_struggle_move():
	var move = MoveData.new("STRUGGLE", 50, "", MoveData.CATEGORY_PHYSICAL, -1)
	move.current_pp = -1
	return move

func _apply_struggle_recoil(user_data) -> int:
	if user_data == null or not user_data.has_method("get_base_stat"):
		return 0
	var max_hp = max(1, int(user_data.get_base_stat("hp")))
	var recoil_damage = max(1, int(floor(float(max_hp) * 0.25)))
	var applied_damage = min(int(user_data.current_hp), recoil_damage)
	user_data.current_hp = max(0, int(user_data.current_hp) - applied_damage)
	return applied_damage

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

func _build_enemy_appeared_message(enemy_species_id: String) -> String:
	var encounter_meta = battle_data.get("encounter_meta", {}) if typeof(battle_data) == TYPE_DICTIONARY else {}
	var is_trainer_encounter = bool(encounter_meta.get("is_trainer_encounter", false))
	if is_trainer_encounter:
		var trainer_name = String(encounter_meta.get("trainer_display_name", "")).strip_edges()
		var trainer_prefix = "A trainer"
		if not trainer_name.empty():
			trainer_prefix = trainer_name
		var transition_trigger = String(encounter_meta.get("transition_trigger", "")).strip_edges().to_lower()
		if transition_trigger == "trainer_party_progress":
			return "%s sent out %s!" % [trainer_prefix, enemy_species_id]
		if bool(encounter_meta.get("is_boss_encounter", false)):
			return "%s challenges you with %s!" % [trainer_prefix + " (Boss)", enemy_species_id]
		return "%s challenges you with %s!" % [trainer_prefix, enemy_species_id]
	return "A wild %s appeared!" % enemy_species_id

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
	if typeof(data) != TYPE_DICTIONARY:
		log_debug("Atlas payload is not a dictionary: %s" % json_path)
		return []

	var root_scale = _parse_atlas_scale(data.get("meta", {}).get("scale", 1.0))
	# Support both TexturePacker-style atlases (`textures[].frames`) and
	# Aseprite-style atlases (`frames` at the root).
	if data.has("textures"):
		var textures = data["textures"]
		if textures.size() == 0:
			log_debug("Atlas textures list empty: %s" % json_path)
			return []

		var merged_frames := []
		for texture_entry in textures:
			if typeof(texture_entry) != TYPE_DICTIONARY:
				continue
			var texture_scale = _parse_atlas_scale(texture_entry.get("scale", root_scale))
			var texture_frames = _normalize_atlas_frames_container(texture_entry.get("frames", null), texture_scale)
			if texture_frames.empty():
				continue
			for frame in texture_frames:
				merged_frames.append(frame)

		if not merged_frames.empty():
			return merged_frames

	if data.has("frames"):
		var root_frames = _normalize_atlas_frames_container(data.get("frames", null), root_scale)
		if not root_frames.empty():
			return root_frames

	log_debug("Atlas has no usable frames: %s" % json_path)
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
	_load_enemy_trainer_sprite()

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

func _load_enemy_trainer_sprite() -> void:
	enemy_trainer_idle_frame = {}
	enemy_trainer_texture_front = null
	if enemy_trainer_sprite == null:
		return

	if not _is_active_trainer_encounter():
		enemy_trainer_sprite.visible = false
		return

	var sprite_asset_id = String(battle_data.get("enemy_trainer_sprite_asset_id", "")).strip_edges().to_lower()
	if sprite_asset_id.empty():
		enemy_trainer_sprite.visible = false
		return

	var texture_path = "%sassets/images/trainer/%s.png" % [minimal_assets_path, sprite_asset_id]
	var atlas_path = "%sassets/images/trainer/%s.json" % [minimal_assets_path, sprite_asset_id]
	if not resource_exists(texture_path):
		log_debug("Missing enemy trainer texture: %s" % texture_path)
		enemy_trainer_sprite.visible = false
		return

	enemy_trainer_texture_front = load(texture_path)
	var frames = get_all_numeric_frames(atlas_path)
	if frames.empty():
		var fallback_frame = parse_sprite_frame(atlas_path, "0001.png")
		if fallback_frame != null:
			frames.append(fallback_frame)

	if frames.empty():
		enemy_trainer_sprite.texture = enemy_trainer_texture_front
		enemy_trainer_sprite.centered = true
		enemy_trainer_sprite.region_enabled = false
		enemy_trainer_sprite.offset = Vector2.ZERO
		enemy_trainer_sprite.visible = false
		return

	enemy_trainer_idle_frame = {
		"texture": enemy_trainer_texture_front,
		"frame": frames[0],
	}

	enemy_trainer_sprite.texture = enemy_trainer_texture_front
	enemy_trainer_sprite.centered = true
	enemy_trainer_sprite.region_enabled = true
	enemy_trainer_sprite.offset = Vector2.ZERO
	apply_sprite_frame(enemy_trainer_sprite, enemy_trainer_idle_frame["frame"])
	enemy_trainer_sprite.visible = false

func _start_battle_opening_sequence() -> void:
	active_opening_run_id = _next_opening_run_id()
	_log_opening_checkpoint("entry")
	var opening_context := {
		"aborted": false,
	}
	var phase_runner = battle_phase_runner_script.new()
	phase_runner.push_phase(opening_prepare_phase_script.new(self, opening_context))
	phase_runner.push_phase(opening_slide_phase_script.new(self, opening_context))
	phase_runner.push_phase(opening_resolve_phase_script.new(self, opening_context))

	if phase_runner.is_running():
		yield(phase_runner, "queue_idle")
	_log_opening_checkpoint("queue_idle")
	active_opening_run_id = ""

	return

func _prepare_opening_phase_state() -> Dictionary:
	var force_player_trainer_intro = bool(battle_data.get("force_player_trainer_intro", false)) if typeof(battle_data) == TYPE_DICTIONARY else false
	if force_player_trainer_intro and typeof(battle_data) == TYPE_DICTIONARY:
		battle_data.erase("force_player_trainer_intro")
	var use_player_trainer_intro = (_is_active_trainer_encounter() or force_player_trainer_intro) and player_trainer_enabled and player_trainer_sprite != null and not player_trainer_idle_frame.empty()
	if player_trainer_sprite != null:
		player_trainer_choreo_playing = false
		if use_player_trainer_intro:
			player_trainer_sprite.visible = true
			player_trainer_sprite.position = player_trainer_sprite_home_position
			_apply_trainer_frame(player_trainer_idle_frame)
		else:
			player_trainer_sprite.visible = false

	var use_trainer_intro = _is_active_trainer_encounter() and enemy_trainer_intro_enabled and enemy_trainer_sprite != null and not enemy_trainer_idle_frame.empty()
	if use_trainer_intro:
		if player_pokemon_sprite != null:
			player_pokemon_sprite.visible = false
		if enemy_pokemon_sprite != null:
			enemy_pokemon_sprite.visible = false
		enemy_trainer_sprite.visible = true
		enemy_trainer_sprite.position = enemy_trainer_sprite_home_position
	else:
		if enemy_trainer_pb_panel != null:
			enemy_trainer_pb_panel.visible = false
		if player_trainer_pb_panel != null:
			player_trainer_pb_panel.visible = false
		if enemy_trainer_sprite != null:
			enemy_trainer_sprite.visible = false
		if enemy_pokemon_sprite != null:
			enemy_pokemon_sprite.visible = true

	var opening_state := {
		"use_trainer_intro": use_trainer_intro,
		"use_player_trainer_intro": use_player_trainer_intro,
	}
	_log_opening_checkpoint("prepared", opening_state)
	return opening_state

func _run_opening_slide_phase_state(opening_state: Dictionary):
	if typeof(opening_state) != TYPE_DICTIONARY:
		return null
	var use_trainer_intro = bool(opening_state.get("use_trainer_intro", false))
	_log_opening_checkpoint("slide.start", {
		"include_enemy_panel": not use_trainer_intro,
	})

	var slide = _run_enemy_opening_slide_in(not use_trainer_intro)
	if slide is GDScriptFunctionState:
		yield(slide, "completed")
	_log_opening_checkpoint("slide.complete")
	return null


func _run_opening_resolve_phase_state(opening_state: Dictionary):
	if typeof(opening_state) != TYPE_DICTIONARY:
		return null
	var use_trainer_intro = bool(opening_state.get("use_trainer_intro", false))
	_log_opening_checkpoint("resolve.start", {
		"use_trainer_intro": use_trainer_intro,
	})
	if use_trainer_intro:
		var trainer_sequence = _run_opening_trainer_resolve_branch(opening_state)
		if trainer_sequence is GDScriptFunctionState:
			_log_opening_checkpoint("resolve.trainer_sequence_async")
			yield(trainer_sequence, "completed")
	else:
		var non_trainer_sequence = _run_opening_non_trainer_resolve_branch(opening_state)
		if non_trainer_sequence is GDScriptFunctionState:
			yield(non_trainer_sequence, "completed")
	_log_opening_checkpoint("resolve.complete")
	return null

func _run_opening_trainer_resolve_branch(_opening_state: Dictionary):
	var trainer_sequence = _run_enemy_trainer_intro_post_slide_sequence()
	if trainer_sequence is GDScriptFunctionState:
		yield(trainer_sequence, "completed")
	return null

func _run_opening_non_trainer_resolve_branch(opening_state: Dictionary):
	if typeof(opening_state) != TYPE_DICTIONARY:
		return null
	var use_player_trainer_intro = bool(opening_state.get("use_player_trainer_intro", false))
	_log_opening_checkpoint("resolve.non_trainer_branch", {
		"use_player_trainer_intro": use_player_trainer_intro,
		"active_trainer_encounter": _is_active_trainer_encounter(),
	})
	_play_enemy_sendout_cry_once()
	if use_player_trainer_intro:
		start_player_trainer_summon_choreography()
	else:
		if player_pokemon_sprite != null:
			player_pokemon_sprite.visible = true
		if player_panel != null:
			var player_panel_reveal = _animate_player_panel_to(
				player_panel_home_position,
				max(0.0, player_panel_switch_slide_duration_sec)
			)
			if player_panel_reveal is GDScriptFunctionState:
				yield(player_panel_reveal, "completed")
		set_sendout_controls_locked(false)
		_show_main_controls_unlocked()
	return null

func _setup_transition_fade_overlay() -> void:
	if transition_fade_overlay != null and is_instance_valid(transition_fade_overlay):
		return
	transition_fade_overlay = ColorRect.new()
	transition_fade_overlay.name = "TransitionFadeOverlay"
	transition_fade_overlay.color = Color(0, 0, 0, 1)
	transition_fade_overlay.anchor_right = 1.0
	transition_fade_overlay.anchor_bottom = 1.0
	transition_fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_fade_overlay.visible = false
	transition_fade_overlay.modulate = Color(1, 1, 1, 0)
	add_child(transition_fade_overlay)
	transition_fade_overlay.raise()

func _stop_transition_fade_tween() -> void:
	if transition_fade_tween != null and is_instance_valid(transition_fade_tween):
		var _stopped = transition_fade_tween.stop_all()
		transition_fade_tween.queue_free()
	transition_fade_tween = null

func _play_transition_fade_to_alpha(target_alpha: float, duration_sec: float, active_turn_token: int = -1):
	_setup_transition_fade_overlay()
	if transition_fade_overlay == null:
		return null
	_stop_transition_fade_tween()
	transition_fade_overlay.visible = true
	transition_fade_overlay.raise()
	var clamped_alpha = clamp(target_alpha, 0.0, 1.0)
	if duration_sec <= 0.0:
		transition_fade_overlay.modulate.a = clamped_alpha
		transition_fade_overlay.visible = clamped_alpha > 0.0
		return null

	transition_fade_tween = Tween.new()
	add_child(transition_fade_tween)
	var _fade_track = transition_fade_tween.interpolate_property(
		transition_fade_overlay,
		"modulate:a",
		transition_fade_overlay.modulate.a,
		clamped_alpha,
		max(0.01, duration_sec),
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	var _fade_started = transition_fade_tween.start()
	yield(transition_fade_tween, "tween_all_completed")
	transition_fade_tween.queue_free()
	transition_fade_tween = null
	if active_turn_token != -1 and active_turn_token != turn_token:
		return null
	transition_fade_overlay.modulate.a = clamped_alpha
	transition_fade_overlay.visible = clamped_alpha > 0.0
	return null

func _play_biome_transition_heal_sfx_and_wait(active_turn_token: int):
	if not battle_fx_enabled:
		if biome_transition_blackout_hold_sec > 0.0:
			yield(get_tree().create_timer(biome_transition_blackout_hold_sec), "timeout")
		return null
	suppress_arena_bgm_apply = true
	_stop_all_biome_bgm()
	var resolved_path = resolve_audio_asset_path("assets/audio/bgm/bw/heal.mp3")
	if resolved_path.empty():
		if biome_transition_blackout_hold_sec > 0.0:
			yield(get_tree().create_timer(biome_transition_blackout_hold_sec), "timeout")
		suppress_arena_bgm_apply = false
		return null
	var heal_stream = load(resolved_path)
	if heal_stream == null:
		if biome_transition_blackout_hold_sec > 0.0:
			yield(get_tree().create_timer(biome_transition_blackout_hold_sec), "timeout")
		suppress_arena_bgm_apply = false
		return null
	if heal_stream is AudioStreamMP3:
		heal_stream.loop = false
	elif heal_stream is AudioStreamOGGVorbis:
		heal_stream.loop = false
	$UIAudioStreamPlayer.stop()
	$UIAudioStreamPlayer.stream = heal_stream
	$UIAudioStreamPlayer.play()

	var wait_duration = max(biome_transition_blackout_hold_sec, 0.0)
	if heal_stream.has_method("get_length"):
		wait_duration = max(wait_duration, float(heal_stream.get_length()))
	if wait_duration > 0.0:
		yield(get_tree().create_timer(wait_duration), "timeout")
	$UIAudioStreamPlayer.stop()
	suppress_arena_bgm_apply = false
	if active_turn_token != -1 and active_turn_token != turn_token:
		return null
	return null

func _run_enemy_opening_slide_in(include_enemy_panel: bool = true):
	if include_enemy_panel and enemy_panel != null:
		enemy_panel.rect_position = _enemy_panel_hidden_position()
		_animate_enemy_panel_to(enemy_panel_home_position, max(0.0, enemy_panel_slide_duration_sec))
	enemy_layer.rect_position = enemy_layer_home_position + Vector2(-enemy_switch_slide_distance_px, 0)
	var enemy_slide_in = animate_enemy_layer_to(enemy_layer_home_position, enemy_switch_slide_duration_sec)
	if enemy_slide_in is GDScriptFunctionState:
		yield(enemy_slide_in, "completed")
	return null

func _run_player_trainer_reentry_sequence(active_turn_token: int = -1):
	if player_trainer_sprite == null or not player_trainer_enabled or player_trainer_idle_frame.empty():
		return null

	_apply_trainer_frame(player_trainer_idle_frame)
	player_trainer_sprite.visible = true
	player_trainer_sprite.position = player_trainer_sprite_home_position + Vector2(-player_trainer_exit_distance_px, 0)
	var reentry_modulate = player_trainer_sprite.modulate
	player_trainer_sprite.modulate = Color(reentry_modulate.r, reentry_modulate.g, reentry_modulate.b, 0.0)

	var reentry_tween = Tween.new()
	add_child(reentry_tween)
	reentry_tween.interpolate_property(
		player_trainer_sprite,
		"position:x",
		player_trainer_sprite.position.x,
		player_trainer_sprite_home_position.x,
		max(0.01, player_trainer_exit_duration_sec),
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	reentry_tween.interpolate_property(
		player_trainer_sprite,
		"modulate:a",
		player_trainer_sprite.modulate.a,
		1.0,
		max(0.01, player_trainer_exit_duration_sec),
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	reentry_tween.start()
	yield(reentry_tween, "tween_all_completed")
	reentry_tween.queue_free()

	if active_turn_token != -1 and active_turn_token != turn_token:
		return null

	player_trainer_sprite.position = player_trainer_sprite_home_position
	player_trainer_sprite.modulate = Color(1, 1, 1, 1)
	return null

func _run_enemy_trainer_intro_post_slide_sequence():
	if enemy_trainer_sprite == null:
		start_player_trainer_summon_choreography()
		return null
	if enemy_trainer_idle_frame.empty():
		start_player_trainer_summon_choreography()
		return null

	var intro_state = _prepare_enemy_trainer_intro_state()
	var trainer_intro_dialog = _run_enemy_trainer_intro_dialog_phase(intro_state)
	if trainer_intro_dialog is GDScriptFunctionState:
		yield(trainer_intro_dialog, "completed")

	var sendout_sequence = _run_enemy_trainer_intro_sendout_phase(intro_state)
	if sendout_sequence is GDScriptFunctionState:
		yield(sendout_sequence, "completed")
	if enemy_pokemon_reveal_to_player_delay_sec > 0.0:
		yield(get_tree().create_timer(enemy_pokemon_reveal_to_player_delay_sec), "timeout")
	start_player_trainer_summon_choreography()
	return null

func _prepare_enemy_trainer_intro_state() -> Dictionary:
	var enemy_species_id = String(battle_data["enemy"].species_id) if typeof(battle_data) == TYPE_DICTIONARY and battle_data.has("enemy") and battle_data["enemy"] != null else "POKEMON"
	var trainer_name = String(battle_data.get("enemy_trainer_name", "Trainer")).strip_edges() if typeof(battle_data) == TYPE_DICTIONARY else "Trainer"
	if trainer_name.empty():
		trainer_name = "Trainer"

	if enemy_pokemon_sprite != null:
		enemy_pokemon_sprite.visible = false
	if enemy_trainer_sprite != null:
		enemy_trainer_sprite.modulate = Color(1, 1, 1, 1)

	var intro_state := {
		"trainer_name": trainer_name,
		"enemy_species_id": enemy_species_id,
	}
	_log_opening_checkpoint("resolve.trainer_intro_prepared", intro_state)
	return intro_state

func _run_enemy_trainer_intro_dialog_phase(intro_state: Dictionary):
	if typeof(intro_state) != TYPE_DICTIONARY:
		return null
	var trainer_name = String(intro_state.get("trainer_name", "Trainer"))

	if enemy_trainer_pb_panel != null or player_trainer_pb_panel != null:
		var tray_intro = _run_trainer_pb_panel_intro_sequence()
		if tray_intro is GDScriptFunctionState:
			yield(tray_intro, "completed")

	_log_opening_checkpoint("resolve.trainer_intro_dialog", {
		"trainer_name": trainer_name,
	})
	set_battle_text("%s would like to battle!" % trainer_name)
	if enemy_trainer_intro_text_hold_sec > 0.0:
		yield(get_tree().create_timer(enemy_trainer_intro_text_hold_sec), "timeout")
	return null

func _run_enemy_trainer_intro_sendout_phase(intro_state: Dictionary):
	if typeof(intro_state) != TYPE_DICTIONARY:
		return null
	var trainer_name = String(intro_state.get("trainer_name", "Trainer"))
	var enemy_species_id = String(intro_state.get("enemy_species_id", "POKEMON"))
	_log_opening_checkpoint("resolve.trainer_intro_sendout", {
		"trainer_name": trainer_name,
		"enemy_species_id": enemy_species_id,
	})
	var sendout_sequence = _run_enemy_trainer_throw_and_reveal_sequence(trainer_name, enemy_species_id)
	if sendout_sequence is GDScriptFunctionState:
		yield(sendout_sequence, "completed")
	return null

func _run_enemy_trainer_party_switch_sequence(enemy_species_id: String):
	if enemy_trainer_sprite == null or enemy_trainer_idle_frame.empty():
		if enemy_panel != null:
			enemy_panel.rect_position = _enemy_panel_hidden_position()
			_animate_enemy_panel_to(enemy_panel_home_position, max(0.0, enemy_panel_slide_duration_sec))
		_play_enemy_pokemon_sendout_reveal_fx()
		return null

	var trainer_name = String(battle_data.get("enemy_trainer_name", "Trainer")).strip_edges() if typeof(battle_data) == TYPE_DICTIONARY else "Trainer"
	if trainer_name.empty():
		trainer_name = "Trainer"

	if enemy_trainer_idle_frame.has("frame"):
		enemy_trainer_sprite.texture = enemy_trainer_texture_front
		enemy_trainer_sprite.centered = true
		enemy_trainer_sprite.region_enabled = true
		enemy_trainer_sprite.offset = Vector2.ZERO
		apply_sprite_frame(enemy_trainer_sprite, enemy_trainer_idle_frame["frame"])
	enemy_trainer_sprite.visible = true
	enemy_trainer_sprite.position = enemy_trainer_sprite_home_position + Vector2(enemy_trainer_exit_offset_x, enemy_trainer_exit_offset_y)
	var entry_modulate = enemy_trainer_sprite.modulate
	enemy_trainer_sprite.modulate = Color(entry_modulate.r, entry_modulate.g, entry_modulate.b, clamp(enemy_trainer_exit_alpha, 0.0, 1.0))

	var entry_tween = Tween.new()
	add_child(entry_tween)
	entry_tween.interpolate_property(enemy_trainer_sprite, "position:x", enemy_trainer_sprite.position.x, enemy_trainer_sprite_home_position.x, max(0.01, enemy_trainer_exit_duration_sec), Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	entry_tween.interpolate_property(enemy_trainer_sprite, "position:y", enemy_trainer_sprite.position.y, enemy_trainer_sprite_home_position.y, max(0.01, enemy_trainer_exit_duration_sec), Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	entry_tween.interpolate_property(enemy_trainer_sprite, "modulate:a", enemy_trainer_sprite.modulate.a, 1.0, max(0.01, enemy_trainer_exit_duration_sec), Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	entry_tween.start()
	yield(entry_tween, "tween_all_completed")
	entry_tween.queue_free()
	enemy_trainer_sprite.position = enemy_trainer_sprite_home_position
	enemy_trainer_sprite.modulate = Color(1, 1, 1, 1)

	if enemy_trainer_pb_panel != null:
		var tray_intro = _run_trainer_pb_panel_intro_sequence(true, false)
		if tray_intro is GDScriptFunctionState:
			yield(tray_intro, "completed")

	var sendout_sequence = _run_enemy_trainer_throw_and_reveal_sequence(trainer_name, enemy_species_id)
	if sendout_sequence is GDScriptFunctionState:
		yield(sendout_sequence, "completed")

	return null

func _run_enemy_trainer_throw_and_reveal_sequence(trainer_name: String, enemy_species_id: String):
	if enemy_pokemon_sprite != null:
		enemy_pokemon_sprite.visible = false
	set_battle_text("%s sent out %s!" % [trainer_name, enemy_species_id])
	if enemy_trainer_sent_out_text_hold_sec > 0.0:
		yield(get_tree().create_timer(enemy_trainer_sent_out_text_hold_sec), "timeout")

	var exit_tween = Tween.new()
	add_child(exit_tween)
	exit_tween.interpolate_property(
		enemy_trainer_sprite,
		"position:x",
		enemy_trainer_sprite.position.x,
		enemy_trainer_sprite_home_position.x + enemy_trainer_exit_offset_x,
		max(0.01, enemy_trainer_exit_duration_sec),
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	exit_tween.interpolate_property(
		enemy_trainer_sprite,
		"position:y",
		enemy_trainer_sprite.position.y,
		enemy_trainer_sprite_home_position.y + enemy_trainer_exit_offset_y,
		max(0.01, enemy_trainer_exit_duration_sec),
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	exit_tween.interpolate_property(
		enemy_trainer_sprite,
		"modulate:a",
		enemy_trainer_sprite.modulate.a,
		clamp(enemy_trainer_exit_alpha, 0.0, 1.0),
		max(0.01, enemy_trainer_exit_duration_sec),
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	exit_tween.start()

	var enemy_throw_sequence = _run_enemy_pokeball_throw_sequence()
	if enemy_throw_sequence is GDScriptFunctionState:
		yield(enemy_throw_sequence, "completed")

	if exit_tween != null and exit_tween.is_active():
		yield(exit_tween, "tween_all_completed")
	if exit_tween != null:
		exit_tween.queue_free()

	enemy_trainer_sprite.visible = false
	enemy_trainer_sprite.position = enemy_trainer_sprite_home_position
	enemy_trainer_sprite.modulate = Color(1, 1, 1, 1)

	if enemy_panel != null:
		enemy_panel.rect_position = _enemy_panel_hidden_position()
		bind_battle_data()
		_animate_enemy_panel_to(enemy_panel_home_position, max(0.0, enemy_panel_slide_duration_sec))

	_play_enemy_pokemon_sendout_reveal_fx()
	return null

func _ensure_enemy_pokeball_sprite() -> bool:
	if enemy_pokeball_sprite != null:
		return true
	if effects_layer == null:
		return false

	enemy_pokeball_sprite = Sprite.new()
	enemy_pokeball_sprite.centered = true
	enemy_pokeball_sprite.region_enabled = true
	enemy_pokeball_sprite.visible = false
	effects_layer.add_child(enemy_pokeball_sprite)
	return true

func _apply_enemy_pokeball_frame(frame_name: String) -> bool:
	if not _ensure_enemy_pokeball_sprite():
		return false

	var texture_path = minimal_assets_path + POKEBALL_TEXTURE_REL
	var atlas_path = minimal_assets_path + POKEBALL_ATLAS_REL
	if not resource_exists(texture_path):
		return false

	var frame_data = parse_sprite_frame(atlas_path, frame_name)
	if frame_data == null:
		return false

	enemy_pokeball_sprite.texture = load(texture_path)
	enemy_pokeball_sprite.region_enabled = true
	enemy_pokeball_sprite.centered = true
	var frame = frame_data["frame"]
	enemy_pokeball_sprite.region_rect = Rect2(frame["x"], frame["y"], frame["w"], frame["h"])
	return true

func _run_enemy_pokeball_throw_sequence() -> void:
	if not _apply_enemy_pokeball_frame(POKEBALL_FRAME_CLOSED):
		return
	if enemy_pokeball_sprite == null:
		return

	enemy_pokeball_sprite.visible = true
	enemy_pokeball_sprite.rotation_degrees = 0.0
	var start_pos = enemy_trainer_sprite_home_position + Vector2(enemy_pokeball_start_offset_x, enemy_pokeball_start_offset_y)
	if enemy_trainer_sprite != null:
		start_pos = enemy_trainer_sprite.position + Vector2(enemy_pokeball_start_offset_x, enemy_pokeball_start_offset_y)
	var target_pos = enemy_sprite_home_position + Vector2(enemy_pokeball_target_offset_x, enemy_pokeball_target_offset_y)
	var arc_peak_y = target_pos.y - enemy_pokeball_arc_height_px
	enemy_pokeball_sprite.position = start_pos

	var lob_duration = max(0.01, enemy_pokeball_lob_duration_sec)
	var lob_up_duration = clamp(enemy_pokeball_lob_up_duration_sec, 0.01, lob_duration - 0.01)
	var lob_down_duration = max(0.01, lob_duration - lob_up_duration)

	var x_tween = Tween.new()
	add_child(x_tween)
	x_tween.interpolate_property(enemy_pokeball_sprite, "position:x", start_pos.x, target_pos.x, lob_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	x_tween.start()

	var rotate_tween = Tween.new()
	add_child(rotate_tween)
	rotate_tween.interpolate_property(enemy_pokeball_sprite, "rotation_degrees", 0.0, enemy_pokeball_spin_degrees, lob_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	rotate_tween.start()

	var up_tween = Tween.new()
	add_child(up_tween)
	up_tween.interpolate_property(enemy_pokeball_sprite, "position:y", start_pos.y, arc_peak_y, lob_up_duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	up_tween.start()
	yield(up_tween, "tween_all_completed")
	up_tween.queue_free()

	var down_tween = Tween.new()
	add_child(down_tween)
	down_tween.interpolate_property(enemy_pokeball_sprite, "position:y", enemy_pokeball_sprite.position.y, target_pos.y, lob_down_duration, Tween.TRANS_CUBIC, Tween.EASE_IN)
	down_tween.start()
	yield(down_tween, "tween_all_completed")
	down_tween.queue_free()

	if x_tween != null:
		x_tween.queue_free()
	if rotate_tween != null:
		rotate_tween.queue_free()

	if not _apply_enemy_pokeball_frame(POKEBALL_FRAME_OPENING):
		_hide_enemy_pokeball_sprite()
		return
	yield(get_tree().create_timer(max(0.01, enemy_pokeball_opening_hold_sec)), "timeout")

	_play_player_pokeball_release_sfx()
	if _apply_enemy_pokeball_frame(POKEBALL_FRAME_OPEN):
		_spawn_player_pokeball_open_particles(target_pos + Vector2(0, -2))
	yield(get_tree().create_timer(max(0.01, enemy_pokeball_open_hold_sec)), "timeout")
	_hide_enemy_pokeball_sprite()

func _hide_enemy_pokeball_sprite() -> void:
	if enemy_pokeball_sprite != null:
		enemy_pokeball_sprite.visible = false

func _play_enemy_pokemon_sendout_reveal_fx() -> void:
	if enemy_pokemon_sprite == null:
		_play_enemy_sendout_cry_once()
		return

	if not battle_fx_enabled:
		enemy_pokemon_sprite.visible = true
		enemy_pokemon_sprite.scale = enemy_sprite_home_scale
		enemy_pokemon_sprite.modulate = Color(1, 1, 1, 1)
		_play_enemy_sendout_cry_once()
		return

	var start_scale_mul = max(0.1, enemy_pokemon_reveal_start_scale)
	var target_scale = enemy_sprite_home_scale
	var start_scale = Vector2(target_scale.x * start_scale_mul, target_scale.y * start_scale_mul)
	enemy_pokemon_sprite.scale = start_scale
	var tint = enemy_pokemon_reveal_tint_color
	tint.a = clamp(enemy_pokemon_reveal_alpha_start, 0.0, 1.0)
	enemy_pokemon_sprite.modulate = tint
	enemy_pokemon_sprite.visible = true

	var reveal_tween = Tween.new()
	add_child(reveal_tween)
	reveal_tween.interpolate_property(
		enemy_pokemon_sprite,
		"scale",
		start_scale,
		target_scale,
		max(0.01, enemy_pokemon_reveal_scale_duration_sec),
		Tween.TRANS_SINE,
		Tween.EASE_IN
	)
	reveal_tween.interpolate_property(
		enemy_pokemon_sprite,
		"modulate",
		enemy_pokemon_sprite.modulate,
		Color(1, 1, 1, 1),
		max(0.01, enemy_pokemon_reveal_flash_duration_sec),
		Tween.TRANS_SINE,
		Tween.EASE_IN
	)
	reveal_tween.start()
	_connect_once(reveal_tween, "tween_all_completed", "_on_enemy_pokemon_reveal_tween_completed", [reveal_tween])

func _on_enemy_pokemon_reveal_tween_completed(reveal_tween: Tween) -> void:
	_play_enemy_sendout_cry_once()
	if reveal_tween != null:
		reveal_tween.queue_free()

func start_player_trainer_summon_choreography() -> void:
	set_sendout_controls_locked(true)
	if player_trainer_sprite == null or not player_trainer_enabled:
		if player_pokemon_sprite != null:
			player_pokemon_sprite.visible = true
		_animate_player_panel_to(player_panel_home_position, max(0.0, player_panel_switch_slide_duration_sec))
		_play_player_sendout_cry_once()
		_on_player_sendout_settled()
		return
	if player_trainer_idle_frame.empty():
		if player_pokemon_sprite != null:
			player_pokemon_sprite.visible = true
		_animate_player_panel_to(player_panel_home_position, max(0.0, player_panel_switch_slide_duration_sec))
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
		_animate_player_panel_to(player_panel_home_position, max(0.0, player_panel_switch_slide_duration_sec))
		_on_player_sendout_settled()
		return

	if not battle_fx_enabled:
		_animate_player_panel_to(player_panel_home_position, max(0.0, player_panel_switch_slide_duration_sec))
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
	_animate_player_panel_to(player_panel_home_position, max(0.0, player_panel_switch_slide_duration_sec))

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
		return

	var now_msec = OS.get_ticks_msec()
	if player_sendout_cry_key == last_player_cry_key and last_player_cry_played_at_msec >= 0 and (now_msec - last_player_cry_played_at_msec) <= SENDOUT_CRY_DEDUPE_WINDOW_MSEC:
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
		return

	var cry_stream = load(cry_path)
	if cry_stream == null:
		log_debug("Skipping player cry: failed to load stream %s" % cry_path)
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
	player_sendout_cry_played = true
	last_player_cry_key = player_sendout_cry_key
	last_player_cry_played_at_msec = now_msec

func _play_enemy_sendout_cry_once() -> void:
	if enemy_sendout_cry_key.empty():
		log_debug("Skipping enemy cry: no resolved cry key")
		return

	var now_msec = OS.get_ticks_msec()
	if enemy_sendout_cry_key == last_enemy_cry_key and last_enemy_cry_played_at_msec >= 0 and (now_msec - last_enemy_cry_played_at_msec) <= SENDOUT_CRY_DEDUPE_WINDOW_MSEC:
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
		return

	var cry_stream = load(cry_path)
	if cry_stream == null:
		log_debug("Skipping enemy cry: failed to load stream %s" % cry_path)
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
	last_enemy_cry_key = enemy_sendout_cry_key
	last_enemy_cry_played_at_msec = now_msec

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
	_hide_enemy_pokeball_sprite()

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
