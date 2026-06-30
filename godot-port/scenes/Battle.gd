extends Control

export(int) var ui_font_size := 12
export(int) var control_button_font_size := 16
export(float) var turn_step_delay_sec := 0.6
export(bool) var battle_fx_enabled := true

var pokemon_data_script = load("res://data/PokemonData.gd")
var battle_calc_script = load("res://logic/BattleCalc.gd")

onready var enemy_name_label = $UILayer/EnemyPanel/EnemyNameLabel
onready var enemy_level_label = $UILayer/EnemyPanel/EnemyLevelLabel
onready var enemy_hp_bar = get_node_or_null("UILayer/EnemyPanel/EnemyHpBar")
onready var enemy_hp_value_label = get_node_or_null("UILayer/EnemyPanel/EnemyHpValueLabel")
onready var enemy_pokemon_sprite = $BattlefieldLayer/EnemyLayer/EnemyPokemonSpriteBattle
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
var sprite_atlas_json = "assets/images/pokemon/1.json"
var sprite_frame_name = "0001.png"
var hp_overlay_json = "assets/images/ui/overlay_hp.json"
var ui_font_path = "res://godot-minimal-assets/assets/fonts/pokemon-emerald-pro.ttf"

var battle_data = null
var hp_overlay_frames := {}
var battle_ended := false
var turn_in_progress := false
var turn_token := 0

func _ready():
	apply_fonts()
	update_run_button_label()
	load_battle_sprites()
	build_hp_overlay_frames()
	load_audio_assets()
	reset_battle_state("Battle ready.")

	if not InputMap.has_action("ui_select"):
		InputMap.add_action("ui_select")
		var ev = InputEventKey.new()
		ev.scancode = KEY_S
		InputMap.action_add_event("ui_select", ev)

func make_font(path: String, size: int) -> DynamicFont:
	var font = DynamicFont.new()
	var font_data = DynamicFontData.new()
	font_data.font_path = path
	font.font_data = font_data
	font.size = size
	return font

func apply_fonts():
	var f = File.new()
	if not f.file_exists(ui_font_path):
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

func load_battle_sprites():
	load_sprite_for_node(enemy_pokemon_sprite, "assets/images/pokemon/1.png", "assets/images/pokemon/1.json")
	load_sprite_for_node(player_pokemon_sprite, "assets/images/pokemon/back/4.png", "assets/images/pokemon/back/4.json")

func load_sprite_for_node(sprite_node: Sprite, sprite_relative_path: String, atlas_json: String):
	var sprite_path = minimal_assets_path + sprite_relative_path
	var json_path = minimal_assets_path + atlas_json
	var f = File.new()
	if not f.file_exists(sprite_path):
		return

	sprite_node.texture = load(sprite_path)
	sprite_node.centered = true
	sprite_node.region_enabled = true
	sprite_node.offset = Vector2.ZERO

	var frame_rect = Rect2(0, 0, 64, 64)
	var sprite_info = parse_sprite_frame(json_path, sprite_frame_name)
	if sprite_info != null:
		var frame = sprite_info["frame"]
		frame_rect = Rect2(frame["x"], frame["y"], frame["w"], frame["h"])
		sprite_node.region_rect = frame_rect

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
		sprite_node.region_rect = frame_rect

func load_audio_assets():
	var bgm_path = minimal_assets_path + "assets/audio/bgm/title.mp3"
	var f = File.new()
	if f.file_exists(bgm_path):
		$AudioStreamPlayer.stream = load(bgm_path)

	var select_path = minimal_assets_path + "assets/audio/ui/select.wav"
	if f.file_exists(select_path):
		$UIAudioStreamPlayer.stream = load(select_path)

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") and not turn_in_progress and not battle_ended:
		set_battle_text("Battle scene ready. Press the move button to continue.")

func _on_MoveButton_pressed():
	if battle_ended:
		set_battle_text("Battle has ended. Press Ball or Run to restart.")
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
	var damage = int(battle_calc_script.calc_damage(attacker, move, defender))
	defender.current_hp = max(0, defender.current_hp - damage)

	refresh_hp_ui(defender, enemy_hp_bar, enemy_hp_value_label)
	var battle_message = "%s used %s! %d damage." % [attacker.species_id, move.move_id, damage]
	set_battle_text(battle_message)
	if turn_step_delay_sec > 0.0:
		yield(get_tree().create_timer(turn_step_delay_sec), "timeout")
		if active_turn_token != turn_token:
			return

	if defender.is_fainted():
		end_battle(true, defender.species_id)
		_finish_turn()
		return

	if defender.moves.empty():
		set_battle_text("%s has no move." % defender.species_id)
		_finish_turn()
		return

	var enemy_move = defender.moves[0]
	var enemy_damage = int(battle_calc_script.calc_damage(defender, enemy_move, attacker))
	attacker.current_hp = max(0, attacker.current_hp - enemy_damage)
	refresh_hp_ui(attacker, player_hp_bar, player_hp_value_label)

	var enemy_message = "%s used %s! %d damage." % [defender.species_id, enemy_move.move_id, enemy_damage]
	set_battle_text(enemy_message)
	if turn_step_delay_sec > 0.0:
		yield(get_tree().create_timer(turn_step_delay_sec), "timeout")
		if active_turn_token != turn_token:
			return

	if attacker.is_fainted():
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
	update_run_button_label()
	var state_text = "ON" if battle_fx_enabled else "OFF"
	set_battle_text("Battle FX toggled %s." % state_text)

func set_action_lock(locked: bool):
	move_button.disabled = locked
	pokemon_button.disabled = locked
	run_button.disabled = locked

func _finish_turn():
	turn_in_progress = false
	if not battle_ended:
		set_action_lock(false)

func end_battle(player_won: bool, fainted_species_id: String):
	battle_ended = true
	set_action_lock(true)
	var result_text = "You win!" if player_won else "You lose!"
	set_battle_text("%s fainted! %s Press Ball to restart." % [fainted_species_id, result_text])

func reset_battle_state(message: String):
	turn_token += 1
	battle_data = pokemon_data_script.create_battle_02_test_data()
	battle_ended = false
	turn_in_progress = false
	set_action_lock(false)
	update_run_button_label()
	bind_battle_data()
	set_battle_text(message)

func update_run_button_label():
	if run_button == null:
		return

	var state_text = "ON" if battle_fx_enabled else "OFF"
	run_button.text = "Run FX: %s" % state_text

func set_battle_text(message: String):
	battle_text_label.text = message

func parse_sprite_frame(json_path: String, frame_name: String):
	var f = File.new()
	if not f.file_exists(json_path):
		return null

	f.open(json_path, File.READ)
	var json_text = f.get_as_text()
	f.close()

	var result = JSON.parse(json_text)
	if result.error != OK:
		return null

	var data = result.result
	if not data.has("textures"):
		return null

	var textures = data["textures"]
	if textures.size() == 0:
		return null

	var frames = textures[0].get("frames", null)
	if frames == null:
		return null

	for frame in frames:
		if frame.has("filename") and frame["filename"] == frame_name:
			return frame

	return null
