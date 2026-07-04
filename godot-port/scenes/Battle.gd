extends Control

export(int) var ui_font_size := 12
export(int) var control_button_font_size := 16
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
const SELECTED_SPECIES_META_KEY := "selected_species_id"
const SELECTION_SCENE_PATH := "res://scenes/PokemonSelect.tscn"
const ATTACK_TYPE_TEXTURE_REL := "assets/images/types.png"
const ATTACK_TYPE_ATLAS_REL := "assets/images/types.json"
const ATTACK_CATEGORY_TEXTURE_REL := "assets/images/categories.png"
const ATTACK_CATEGORY_ATLAS_REL := "assets/images/categories.json"

var pokemon_data_script = load("res://data/PokemonData.gd")
var battle_calc_script = load("res://logic/BattleCalc.gd")
var catalog_loader_script = load("res://logic/CatalogDataLoader.gd")
var runtime_state_script = load("res://logic/RuntimeState.gd")

onready var enemy_name_label = $UILayer/EnemyPanel/EnemyNameLabel
onready var enemy_level_label = $UILayer/EnemyPanel/EnemyLevelLabel
onready var enemy_hp_bar = get_node_or_null("UILayer/EnemyPanel/EnemyHpBar")
onready var enemy_hp_value_label = get_node_or_null("UILayer/EnemyPanel/EnemyHpValueLabel")
onready var enemy_type1_sprite = get_node_or_null("UILayer/EnemyPanel/EnemyType1Sprite")
onready var enemy_type2_sprite = get_node_or_null("UILayer/EnemyPanel/EnemyType2Sprite")
onready var enemy_layer = $BattlefieldLayer/EnemyLayer
onready var enemy_pokemon_sprite = $BattlefieldLayer/EnemyLayer/EnemyPokemonSpriteBattle
onready var effects_layer = $BattlefieldLayer/EffectsLayer
onready var player_name_label = $UILayer/PlayerPanel/PlayerNameLabel
onready var player_level_label = $UILayer/PlayerPanel/PlayerLevelLabel
onready var player_hp_bar = get_node_or_null("UILayer/PlayerPanel/PlayerHpBar")
onready var player_hp_value_label = $UILayer/PlayerPanel/PlayerHpValueLabel
onready var player_type1_sprite = get_node_or_null("UILayer/PlayerPanel/PlayerType1Sprite")
onready var player_type2_sprite = get_node_or_null("UILayer/PlayerPanel/PlayerType2Sprite")
onready var player_pokemon_sprite = $BattlefieldLayer/PlayerLayer/PlayerPokemonSprite
onready var battle_text_label = $UILayer/MessagePanel/MessageMargin/BattleTextLabel
onready var controls_container = $UILayer/ControlsContainer
onready var move_button = $UILayer/ControlsContainer/ControlWindowSprite/ContentMargin/VBoxContainer/ControlsPanel1/MoveButton
onready var ball_button = $UILayer/ControlsContainer/ControlWindowSprite/ContentMargin/VBoxContainer/ControlsPanel1/RestartButton
onready var pokemon_button = $UILayer/ControlsContainer/ControlWindowSprite/ContentMargin/VBoxContainer/ControlsPanel2/MoveButton
onready var run_button = $UILayer/ControlsContainer/ControlWindowSprite/ContentMargin/VBoxContainer/ControlsPanel2/RestartButton
onready var attack_menu_container = $UILayer/AttackMenuContainer
onready var attack_move_button_1 = $UILayer/AttackMenuContainer/HBoxContainer/AttackWindowSprite/AttackMovesGrid/AttackMoveButton1
onready var attack_move_button_2 = $UILayer/AttackMenuContainer/HBoxContainer/AttackWindowSprite/AttackMovesGrid/AttackMoveButton2
onready var attack_move_button_3 = $UILayer/AttackMenuContainer/HBoxContainer/AttackWindowSprite/AttackMovesGrid/AttackMoveButton3
onready var attack_move_button_4 = $UILayer/AttackMenuContainer/HBoxContainer/AttackWindowSprite/AttackMovesGrid/AttackMoveButton4
onready var attack_type_sprite = $UILayer/AttackMenuContainer/HBoxContainer/AttackWindowSprite2/AttackMoveDetails/AttackTypeSprite
onready var attack_power_label = $UILayer/AttackMenuContainer/HBoxContainer/AttackWindowSprite2/AttackMoveDetails/AttackPowerLabel
onready var attack_category_sprite = $UILayer/AttackMenuContainer/HBoxContainer/AttackWindowSprite2/AttackMoveDetails/AttackCategorySprite
onready var attack_pp_label = $UILayer/AttackMenuContainer/HBoxContainer/AttackWindowSprite2/AttackMoveDetails/AttackPpLabel

var minimal_assets_path = "res://godot-minimal-assets/"
var hp_overlay_json = "assets/images/ui/overlay_hp.json"
var ui_font_path = "res://godot-minimal-assets/assets/fonts/pokemon-emerald-pro.ttf"
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
var enemy_sprite_home_position := Vector2.ZERO
var player_sprite_anim_enabled := true
var enemy_sprite_anim_enabled := true
var catalog_loader = null
var selected_player_species_id := ""
var attack_menu_visible := false
var enemy_species_pool := []

func _ready():
	randomize()
	log_debug("Battle scene ready")
	log_debug("Using minimal assets path: %s" % minimal_assets_path)
	ensure_ui_signal_connections()
	apply_fonts()
	update_run_button_label()
	enemy_layer_home_position = enemy_layer.rect_position
	player_sprite_home_position = player_pokemon_sprite.position
	enemy_sprite_home_position = enemy_pokemon_sprite.position
	build_hp_overlay_frames()
	load_audio_assets()
	setup_type_sprite_placeholders()
	setup_attack_detail_sprites()
	reset_battle_state("Battle ready.")

	add_blend_material = CanvasItemMaterial.new()
	add_blend_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	setup_keyboard_controls()

func ensure_ui_signal_connections():
	if move_button != null and not move_button.is_connected("pressed", self, "_on_MoveButton_pressed"):
		move_button.connect("pressed", self, "_on_MoveButton_pressed")

	if ball_button != null and not ball_button.is_connected("pressed", self, "_on_RestartButton_pressed"):
		ball_button.connect("pressed", self, "_on_RestartButton_pressed")

	if pokemon_button != null and not pokemon_button.is_connected("pressed", self, "_on_PokemonButton_pressed"):
		pokemon_button.connect("pressed", self, "_on_PokemonButton_pressed")

	if run_button != null and not run_button.is_connected("pressed", self, "_on_RunButton_pressed"):
		run_button.connect("pressed", self, "_on_RunButton_pressed")

func log_debug(message: String):
	var f = File.new()
	var open_error = f.open(debug_log_path, File.READ_WRITE)
	if open_error != OK:
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

func make_font(path: String, size: int) -> DynamicFont:
	var font = DynamicFont.new()
	var font_data = DynamicFontData.new()
	font_data.font_path = path
	font.font_data = font_data
	font.size = size
	return font

func apply_fonts():
	if not resource_exists(ui_font_path):
		log_debug("Missing UI font resource: %s" % ui_font_path)
		return

	var ui_font = make_font(ui_font_path, ui_font_size)
	enemy_name_label.add_font_override("font", ui_font)
	enemy_level_label.add_font_override("font", ui_font)
	if enemy_hp_value_label != null:
		enemy_hp_value_label.add_font_override("font", ui_font)
	player_name_label.add_font_override("font", ui_font)
	player_level_label.add_font_override("font", ui_font)
	if player_hp_value_label != null:
		player_hp_value_label.add_font_override("font", ui_font)
	var button_font = make_font(ui_font_path, control_button_font_size)
	battle_text_label.add_font_override("font", button_font)
	move_button.add_font_override("font", button_font)
	ball_button.add_font_override("font", button_font)
	pokemon_button.add_font_override("font", button_font)
	run_button.add_font_override("font", button_font)
	attack_move_button_1.add_font_override("font", button_font)
	attack_move_button_2.add_font_override("font", button_font)
	attack_move_button_3.add_font_override("font", button_font)
	attack_move_button_4.add_font_override("font", button_font)
	attack_power_label.add_font_override("font", ui_font)
	attack_pp_label.add_font_override("font", ui_font)

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
	var bgm_path = minimal_assets_path + "assets/audio/bgm/title.mp3"
	if resource_exists(bgm_path):
		$AudioStreamPlayer.stream = load(bgm_path)
	else:
		log_debug("Missing BGM resource: %s" % bgm_path)

	var select_path = minimal_assets_path + "assets/audio/ui/select.wav"
	if resource_exists(select_path):
		$UIAudioStreamPlayer.stream = load(select_path)
	else:
		log_debug("Missing UI SFX resource: %s" % select_path)

func _process(_delta):
	update_pokemon_animations(_delta)

	if Input.is_action_just_pressed("ui_accept") and get_focus_owner() == null and not turn_in_progress and not battle_ended:
		set_battle_text("Battle scene ready. Press the move button to continue.")

func _unhandled_input(event):
	if not (event is InputEventKey):
		return
	if not event.pressed or event.echo:
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
	hide_all_command_menus()
	set_action_lock(true)
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

func _on_RestartButton_pressed():
	if battle_ended:
		reset_battle_state("Battle reset.")
		return

	if turn_in_progress:
		return

	if attack_menu_visible:
		hide_attack_menu()

	set_battle_text("Ball menu not implemented yet.")

func _on_PokemonButton_pressed():
	if battle_ended:
		set_battle_text("Battle has ended. Press Ball to restart.")
		return

	if turn_in_progress:
		return

	if attack_menu_visible:
		hide_attack_menu()

	var party_size = 0
	if runtime_state_script != null:
		var party = runtime_state_script.get_party(get_tree())
		if party != null:
			party_size = party.size()

	set_battle_text("Pokemon menu (PARTY-02) not implemented yet. Party slots: %d/6" % party_size)

func _on_RunButton_pressed():
	if turn_in_progress:
		return

	battle_fx_enabled = not battle_fx_enabled
	reset_pokemon_animation_state()
	update_run_button_label()
	var state_text = "ON" if battle_fx_enabled else "OFF"
	set_battle_text("Battle FX toggled %s." % state_text)

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
		show_main_controls()
		set_action_lock(false)

func end_battle(player_won: bool, fainted_species_id: String):
	battle_ended = true
	if player_won:
		show_main_controls()
		set_action_lock(true)
		ball_button.disabled = false
		ball_button.grab_focus()
		set_battle_text("%s fainted! You win! Press Ball to restart." % fainted_species_id)
		return

	# Defeat recovery path: return to starter selection.
	hide_all_command_menus()
	set_action_lock(true)
	set_battle_text("%s fainted! You lose! Returning to selection..." % fainted_species_id)
	var timer = get_tree().create_timer(max(0.0, defeat_return_delay_sec))
	timer.connect("timeout", self, "_return_to_selection_scene")

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

	var next_enemy_species_id = pick_random_enemy_species_id("")
	battle_data = build_battle_seed(active_player_species_id, next_enemy_species_id, active_party_member)
	enemy_layer.rect_position = enemy_layer_home_position
	load_battle_sprites()
	battle_ended = false
	turn_in_progress = false
	hide_attack_menu()
	refresh_attack_menu()
	player_sprite_anim_enabled = true
	enemy_sprite_anim_enabled = true
	set_action_lock(false)
	ball_button.disabled = false
	update_run_button_label()
	bind_battle_data()
	restore_battler_sprite_state(player_pokemon_sprite, player_sprite_home_position)
	restore_battler_sprite_state(enemy_pokemon_sprite, enemy_sprite_home_position)
	reset_pokemon_animation_state()
	ensure_button_focus()
	set_battle_text(message)

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

	battle_data["enemy"] = next_enemy
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
	ensure_button_focus()
	var focus_owner = get_focus_owner()
	if focus_owner == null:
		return

	if attack_menu_visible:
		move_attack_menu_focus(action_name, focus_owner)
		return

	if action_name == "ui_left":
		if focus_owner == ball_button:
			move_button.grab_focus()
		elif focus_owner == run_button:
			pokemon_button.grab_focus()
		return

	if action_name == "ui_right":
		if focus_owner == move_button:
			ball_button.grab_focus()
		elif focus_owner == pokemon_button:
			run_button.grab_focus()
		return

	if action_name == "ui_up":
		if focus_owner == pokemon_button:
			move_button.grab_focus()
		elif focus_owner == run_button:
			ball_button.grab_focus()
		return

	if action_name == "ui_down":
		if focus_owner == move_button:
			pokemon_button.grab_focus()
		elif focus_owner == ball_button:
			run_button.grab_focus()
		return

func move_attack_menu_focus(action_name: String, focus_owner):
	if action_name == "ui_left":
		if focus_owner == attack_move_button_2:
			attack_move_button_1.grab_focus()
		elif focus_owner == attack_move_button_4:
			attack_move_button_3.grab_focus()
		return

	if action_name == "ui_right":
		if focus_owner == attack_move_button_1:
			attack_move_button_2.grab_focus()
		elif focus_owner == attack_move_button_3:
			attack_move_button_4.grab_focus()
		return

	if action_name == "ui_up":
		if focus_owner == attack_move_button_3:
			attack_move_button_1.grab_focus()
		elif focus_owner == attack_move_button_4:
			attack_move_button_2.grab_focus()
		return

	if action_name == "ui_down":
		if focus_owner == attack_move_button_1:
			attack_move_button_3.grab_focus()
		elif focus_owner == attack_move_button_2:
			attack_move_button_4.grab_focus()
		return

func press_focused_button():
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

func show_attack_menu():
	refresh_attack_menu()
	attack_menu_visible = true
	attack_menu_container.visible = true
	controls_container.visible = false
	refresh_attack_move_details(0)
	focus_first_attack_move_button()

func hide_attack_menu():
	show_main_controls()

func show_main_controls():
	attack_menu_visible = false
	attack_menu_container.visible = false
	controls_container.visible = true
	set_main_command_prompt()

func hide_all_command_menus():
	attack_menu_visible = false
	attack_menu_container.visible = false
	controls_container.visible = false

func set_main_command_prompt():
	if battle_data == null or not battle_data.has("player") or battle_data["player"] == null:
		set_battle_text("What will Pokemon do?")
		return

	var player_species = String(battle_data["player"].species_id)
	set_battle_text("What will %s do?" % player_species)

func refresh_attack_menu():
	var attacker = battle_data["player"] if battle_data != null and battle_data.has("player") else null
	var moves = []
	if attacker != null:
		moves = attacker.moves

	var move_buttons = [
		attack_move_button_1,
		attack_move_button_2,
		attack_move_button_3,
		attack_move_button_4,
	]

	for i in range(move_buttons.size()):
		var button = move_buttons[i]
		if i < moves.size():
			var move = moves[i]
			button.disabled = false
			button.text = String(move.move_id)
		else:
			button.disabled = true
			button.text = "-"

	refresh_attack_move_details(0)

func set_attack_menu_enabled(enabled: bool):
	attack_move_button_1.disabled = (not enabled) or attack_move_button_1.text == "-"
	attack_move_button_2.disabled = (not enabled) or attack_move_button_2.text == "-"
	attack_move_button_3.disabled = (not enabled) or attack_move_button_3.text == "-"
	attack_move_button_4.disabled = (not enabled) or attack_move_button_4.text == "-"

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

func focus_first_attack_move_button():
	if not attack_move_button_1.disabled:
		attack_move_button_1.grab_focus()
		return
	if not attack_move_button_2.disabled:
		attack_move_button_2.grab_focus()
		return
	if not attack_move_button_3.disabled:
		attack_move_button_3.grab_focus()
		return
	if not attack_move_button_4.disabled:
		attack_move_button_4.grab_focus()
		return

func is_attack_menu_button(focus_owner) -> bool:
	return focus_owner == attack_move_button_1 \
		or focus_owner == attack_move_button_2 \
		or focus_owner == attack_move_button_3 \
		or focus_owner == attack_move_button_4

func set_battle_text(message: String):
	battle_text_label.text = message

func build_type_effectiveness_text(type_multiplier: float) -> String:
	# Pokerogue-style thresholds: >=2 super effective, <=0.5 not very effective.
	if type_multiplier >= 2.0:
		return " It's super effective!"
	if type_multiplier <= 0.5 and type_multiplier > 0.0:
		return " It's not very effective..."
	return ""

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

func play_anim_event_sound(resource_name: String):
	if not battle_fx_enabled:
		return

	var file_name = resource_name.strip_edges()
	if file_name.empty():
		return

	var sfx_path = minimal_assets_path + "assets/audio/battle_anims/" + file_name
	if not resource_exists(sfx_path):
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

	var sfx_path = minimal_assets_path + sfx_relative_path
	if not resource_exists(sfx_path):
		log_debug("Missing move SFX resource: %s" % sfx_path)
		sfx_path = minimal_assets_path + "assets/audio/ui/select.wav"
		if not resource_exists(sfx_path):
			log_debug("Missing fallback select SFX: %s" % sfx_path)
			return

	$UIAudioStreamPlayer.stream = load(sfx_path)
	$UIAudioStreamPlayer.play()

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
	target_sprite.modulate = Color(1, 1, 1, 1)

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

	if not player_sprite_frames.empty():
		apply_sprite_frame(player_pokemon_sprite, player_sprite_frames[0])
	if not enemy_sprite_frames.empty():
		apply_sprite_frame(enemy_pokemon_sprite, enemy_sprite_frames[0])

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
