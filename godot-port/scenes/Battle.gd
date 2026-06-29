extends Control

export(int) var ui_font_size := 12
export(int) var control_button_font_size := 16

var pokemon_data_script = load("res://data/PokemonData.gd")

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
onready var restart_button = $UILayer/ControlsContainer/VBoxContainer/ControlsPanel1/RestartButton
onready var pokemon_button = $UILayer/ControlsContainer/VBoxContainer/ControlsPanel2/MoveButton
onready var run_button = $UILayer/ControlsContainer/VBoxContainer/ControlsPanel2/RestartButton

var minimal_assets_path = "res://godot-minimal-assets/"
var sprite_atlas_json = "assets/images/pokemon/1.json"
var sprite_frame_name = "0001.png"
var ui_font_path = "res://godot-minimal-assets/assets/fonts/pokemon-emerald-pro.ttf"

var battle_data = null

func _ready():
	battle_data = pokemon_data_script.create_battle_02_test_data()
	apply_fonts()
	load_battle_sprites()
	load_audio_assets()
	bind_battle_data()
	set_battle_text("Battle ready.")

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
	restart_button.add_font_override("font", button_font)
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
	if hp_bar != null:
		hp_bar.min_value = 0
		hp_bar.max_value = max_hp
		hp_bar.value = pokemon_data.current_hp
	if hp_label != null:
		hp_label.text = "%d / %d" % [pokemon_data.current_hp, max_hp]

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
	if Input.is_action_just_pressed("ui_accept"):
		set_battle_text("Battle scene ready. Press the move button to continue.")

func _on_MoveButton_pressed():
	set_battle_text("Tackle is ready for BATTLE-03.")

func _on_RestartButton_pressed():
	battle_data = pokemon_data_script.create_battle_02_test_data()
	bind_battle_data()
	set_battle_text("Battle reset.")

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
