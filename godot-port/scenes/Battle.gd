extends Control

export(int) var ui_font_size := 12
export(int) var control_button_font_size := 16
export(float) var turn_step_delay_sec := 0.6
export(bool) var battle_fx_enabled := true
export(float) var pokemon_anim_frame_sec := 0.1
export(float) var impact_shake_step_sec := 0.03
export(float) var impact_flash_mul := 1.6
export(float) var impact_shake_px := 2.0
export(float) var move_anim_step_sec := 0.05
export(float) var faint_step_sec := 0.05
export(float) var faint_drop_px := 20.0

var pokemon_data_script = load("res://data/PokemonData.gd")
var battle_calc_script = load("res://logic/BattleCalc.gd")

onready var enemy_name_label = $UILayer/EnemyPanel/EnemyNameLabel
onready var enemy_level_label = $UILayer/EnemyPanel/EnemyLevelLabel
onready var enemy_hp_bar = get_node_or_null("UILayer/EnemyPanel/EnemyHpBar")
onready var enemy_hp_value_label = get_node_or_null("UILayer/EnemyPanel/EnemyHpValueLabel")
onready var enemy_pokemon_sprite = $BattlefieldLayer/EnemyLayer/EnemyPokemonSpriteBattle
onready var effects_layer = $BattlefieldLayer/EffectsLayer
onready var player_name_label = $UILayer/PlayerPanel/PlayerNameLabel
onready var player_level_label = $UILayer/PlayerPanel/PlayerLevelLabel
onready var player_hp_bar = get_node_or_null("UILayer/PlayerPanel/PlayerHpBar")
onready var player_hp_value_label = $UILayer/PlayerPanel/PlayerHpValueLabel
onready var player_pokemon_sprite = $BattlefieldLayer/PlayerLayer/PlayerPokemonSprite
onready var battle_text_label = $UILayer/MessagePanel/MessageMargin/BattleTextLabel
onready var move_button = $UILayer/ControlsContainer/VBoxContainer/ControlsPanel1/MoveButton
onready var ball_button = $UILayer/ControlsContainer/VBoxContainer/ControlsPanel1/RestartButton
onready var pokemon_button = $UILayer/ControlsContainer/VBoxContainer/ControlsPanel2/MoveButton
onready var run_button = $UILayer/ControlsContainer/VBoxContainer/ControlsPanel2/RestartButton

var minimal_assets_path = "res://godot-minimal-assets/"
var hp_overlay_json = "assets/images/ui/overlay_hp.json"
var ui_font_path = "res://godot-minimal-assets/assets/fonts/pokemon-emerald-pro.ttf"
var debug_log_path = "user://battle_debug.log"

var battle_data = null
var hp_overlay_frames := {}
var move_sfx_paths := {
	"EMBER": "assets/audio/battle_anims/PRSFX- Ember.wav",
	"TACKLE": "assets/audio/battle_anims/PRSFX- Tackle.wav",
}
var move_anim_texture_paths := {
	"EMBER": "assets/images/battle_anims/PRAS- Fire.png",
	"TACKLE": "assets/images/battle_anims/PRAS- Strike.png",
}
var move_anim_config_paths := {
	"EMBER": "assets/battle-anims/ember.json",
	"TACKLE": "assets/battle-anims/tackle.json",
}
var move_anim_textures := {}
var move_anim_configs := {}
var add_blend_material: CanvasItemMaterial = null
const ANIM_FOCUS_TARGET = 1
const ANIM_FOCUS_USER = 2
const ANIM_FOCUS_USER_TARGET = 3
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
var player_sprite_home_position := Vector2.ZERO
var enemy_sprite_home_position := Vector2.ZERO
var player_sprite_anim_enabled := true
var enemy_sprite_anim_enabled := true

func _ready():
	log_debug("Battle scene ready")
	log_debug("Using minimal assets path: %s" % minimal_assets_path)
	apply_fonts()
	update_run_button_label()
	load_battle_sprites()
	player_sprite_home_position = player_pokemon_sprite.position
	enemy_sprite_home_position = enemy_pokemon_sprite.position
	build_hp_overlay_frames()
	load_audio_assets()
	load_move_anim_textures()
	load_move_anim_configs()
	reset_battle_state("Battle ready.")

	add_blend_material = CanvasItemMaterial.new()
	add_blend_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	setup_keyboard_controls()

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

func bind_battle_data():
	var enemy_data = battle_data["enemy"]
	var player_data = battle_data["player"]

	enemy_name_label.text = enemy_data.species_id
	enemy_level_label.text = "Lv. %d" % enemy_data.level
	player_name_label.text = player_data.species_id
	player_level_label.text = "Lv. %d" % player_data.level

	refresh_hp_ui(enemy_data, enemy_hp_bar, enemy_hp_value_label)
	refresh_hp_ui(player_data, player_hp_bar, player_hp_value_label)

func refresh_hp_ui(pokemon_data, hp_bar, hp_label):
	var max_hp = pokemon_data.get_base_stat("hp")
	var hp_ratio := 0.0
	if max_hp > 0:
		hp_ratio = clamp(float(pokemon_data.current_hp) / float(max_hp), 0.0, 1.0)
	update_hp_bar_sprite(hp_bar, hp_ratio)
	if hp_label != null:
		hp_label.text = "%d / %d" % [pokemon_data.current_hp, max_hp]

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

func _on_MoveButton_pressed():
	if battle_ended:
		set_battle_text("Battle has ended. Press Ball to restart.")
		return

	if turn_in_progress:
		return

	turn_in_progress = true
	set_action_lock(true)
	var active_turn_token = turn_token

	var attacker = battle_data["player"]
	var defender = battle_data["enemy"]
	if attacker == null or defender == null:
		set_battle_text("Battle data missing.")
		_finish_turn()
		return

	if attacker.moves.empty():
		set_battle_text("No move available.")
		_finish_turn()
		return

	var move = attacker.moves[0]
	var player_move_anim = play_move_animation(move.move_id, player_pokemon_sprite, enemy_pokemon_sprite, active_turn_token)
	if player_move_anim is GDScriptFunctionState:
		yield(player_move_anim, "completed")
		if active_turn_token != turn_token:
			return

	var damage = int(battle_calc_script.calc_damage(attacker, move, defender))
	defender.current_hp = max(0, defender.current_hp - damage)

	refresh_hp_ui(defender, enemy_hp_bar, enemy_hp_value_label)
	var player_hit_feedback = play_hit_feedback(enemy_pokemon_sprite, active_turn_token)
	if player_hit_feedback is GDScriptFunctionState:
		yield(player_hit_feedback, "completed")
		if active_turn_token != turn_token:
			return

	var battle_message = "%s used %s! %d damage." % [attacker.species_id, move.move_id, damage]
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
		end_battle(true, defender.species_id)
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
	refresh_hp_ui(attacker, player_hp_bar, player_hp_value_label)
	var enemy_hit_feedback = play_hit_feedback(player_pokemon_sprite, active_turn_token)
	if enemy_hit_feedback is GDScriptFunctionState:
		yield(enemy_hit_feedback, "completed")
		if active_turn_token != turn_token:
			return

	var enemy_message = "%s used %s! %d damage." % [defender.species_id, enemy_move.move_id, enemy_damage]
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
	reset_battle_state("Battle reset.")

func _on_PokemonButton_pressed():
	if battle_ended:
		set_battle_text("Battle has ended. Press Ball to restart.")
		return

	if turn_in_progress:
		return

	set_battle_text("Pokemon menu not implemented yet.")

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
	if not locked and not battle_ended:
		ensure_button_focus()

func _finish_turn():
	turn_in_progress = false
	if not battle_ended:
		set_action_lock(false)

func end_battle(player_won: bool, fainted_species_id: String):
	battle_ended = true
	set_action_lock(true)
	ball_button.disabled = false
	ball_button.grab_focus()
	var result_text = "You win!" if player_won else "You lose!"
	set_battle_text("%s fainted! %s Press Ball to restart." % [fainted_species_id, result_text])

func reset_battle_state(message: String):
	turn_token += 1
	battle_data = pokemon_data_script.create_battle_02_test_data()
	battle_ended = false
	turn_in_progress = false
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

func setup_keyboard_controls():
	ensure_input_action_key("ui_left", KEY_LEFT)
	ensure_input_action_key("ui_right", KEY_RIGHT)
	ensure_input_action_key("ui_up", KEY_UP)
	ensure_input_action_key("ui_down", KEY_DOWN)
	ensure_input_action_key("ui_accept", KEY_SPACE)

	move_button.focus_mode = Control.FOCUS_ALL
	ball_button.focus_mode = Control.FOCUS_ALL
	pokemon_button.focus_mode = Control.FOCUS_ALL
	run_button.focus_mode = Control.FOCUS_ALL

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

	var state_text = "ON" if battle_fx_enabled else "OFF"
	run_button.text = "Run FX: %s" % state_text

func set_battle_text(message: String):
	battle_text_label.text = message

func load_move_anim_textures():
	move_anim_textures.clear()
	for move_id in move_anim_texture_paths.keys():
		var rel_path = String(move_anim_texture_paths[move_id])
		var abs_path = minimal_assets_path + rel_path
		if resource_exists(abs_path):
			move_anim_textures[move_id] = load(abs_path)
		else:
			log_debug("Missing move anim texture: %s" % abs_path)

func load_move_anim_configs():
	move_anim_configs.clear()
	var f = File.new()
	for move_id in move_anim_config_paths.keys():
		var rel_path = String(move_anim_config_paths[move_id])
		var abs_path = minimal_assets_path + rel_path
		if not f.file_exists(abs_path):
			continue

		f.open(abs_path, File.READ)
		var json_text = f.get_as_text()
		f.close()

		var parsed = JSON.parse(json_text)
		if parsed.error != OK:
			continue
		if parsed.result == null:
			continue

		move_anim_configs[move_id] = parsed.result

func play_move_animation(move_id: String, attacker_sprite: Sprite, defender_sprite: Sprite, active_turn_token: int):
	if not battle_fx_enabled:
		return null
	if attacker_sprite == null or defender_sprite == null:
		return null
	if effects_layer == null:
		return null
	if not move_anim_textures.has(move_id):
		return null
	if not move_anim_configs.has(move_id):
		play_move_sfx(move_id)
		return null

	var anim_config = move_anim_configs[move_id]
	var anim_frames = anim_config.get("frames", [])
	if anim_frames.empty():
		play_move_sfx(move_id)
		return null

	var effect = Sprite.new()
	effect.texture = move_anim_textures[move_id]
	effect.region_enabled = true
	effect.centered = true
	effect.z_index = 10
	effects_layer.add_child(effect)

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
			effect.queue_free()
			return null

		var frame_entries = anim_frames[frame_idx]
		var graphic_entry = null
		for frame_entry in frame_entries:
			if int(frame_entry.get("target", 0)) == 2:
				graphic_entry = frame_entry
				break

		if graphic_entry != null:
			apply_move_graphic_frame(
				effect,
				graphic_entry,
				user_x,
				user_y,
				target_x,
				target_y,
				user_half_h,
				target_half_h
			)

		var frame_events = timed_events.get(str(frame_idx), [])
		for evt in frame_events:
			if String(evt.get("eventType", "")) == "AnimTimedSoundEvent":
				play_anim_event_sound(String(evt.get("resourceName", "")))
				played_timed_sound = true

		yield(get_tree().create_timer(move_anim_step_sec), "timeout")

	if not played_timed_sound:
		play_move_sfx(move_id)

	effect.queue_free()
	return null

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

	var sfx_relative_path = String(move_sfx_paths.get(move_id, "assets/audio/ui/select.wav"))
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
	var enemy_texture_path = "assets/images/pokemon/1.png"
	var enemy_json_path = "assets/images/pokemon/1.json"
	var player_texture_path = "assets/images/pokemon/back/4.png"
	var player_json_path = "assets/images/pokemon/back/4.json"

	enemy_sprite_frames = load_sprite_for_node(enemy_pokemon_sprite, enemy_texture_path, enemy_json_path)
	player_sprite_frames = load_sprite_for_node(player_pokemon_sprite, player_texture_path, player_json_path)

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
		var trimmed_cx = sprite_source_size["x"] + frame["w"] / 2.0
		var trimmed_cy = sprite_source_size["y"] + frame["h"] / 2.0
		var orig_cx = source_size["w"] / 2.0
		var orig_cy = source_size["h"] / 2.0
		sprite_node.offset = Vector2(orig_cx - trimmed_cx, orig_cy - trimmed_cy)
	elif sprite_source_size != null:
		sprite_node.offset = Vector2(sprite_source_size["x"], sprite_source_size["y"])
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
