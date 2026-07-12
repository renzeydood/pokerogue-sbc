extends Control

const TITLE_BGM_CANDIDATE_PATHS := [
	"res://godot-minimal-assets/assets/audio/bgm/title.mp3",
	"res://assets/audio/bgm/title.mp3",
]
const POKEMON_SELECT_SCENE_PATH := "res://scenes/PokemonSelectScreen.tscn"
const BATTLE_SCENE_PATH := "res://scenes/BattleScreen.tscn"
const POKEDEX_SCENE_PATH := "res://scenes/PokedexScreen.tscn"
const POKEDEX_ENTRY_OVERLAY_PATH := "res://scenes/PokedexEntryOverlay.tscn"
const PARTY_MENU_OVERLAY_PATH := "res://scenes/PartyMenuOverlay.tscn"

var entry_scene_path := "res://scenes/BattleScreen.tscn"
var runtime_state_script = load("res://logic/RuntimeState.gd")

export(bool) var debug_seed_full_party_for_ui := false
export(int) var debug_seed_party_level := 5
export(bool) var use_debug_seed_profile := false
export(String) var debug_seed_profile_id := "ui_party_showcase"
export(bool) var play_title_bgm := true
export(String) var title_bgm_path := "res://godot-minimal-assets/assets/audio/bgm/title.mp3"
export(bool) var open_overlay_buttons_as_preview := true

onready var pokemon_select_button = get_node_or_null("Backdrop/Panel/UiScaleRoot/ModalRoot/MenuWindow/ActionContentMargin/ActionButtonList/PokemonSelectButton")
onready var battle_button = get_node_or_null("Backdrop/Panel/UiScaleRoot/ModalRoot/MenuWindow/ActionContentMargin/ActionButtonList/BattleButton")
onready var pokedex_button = get_node_or_null("Backdrop/Panel/UiScaleRoot/ModalRoot/MenuWindow/ActionContentMargin/ActionButtonList/PokedexButton")
onready var pokedex_entry_button = get_node_or_null("Backdrop/Panel/UiScaleRoot/ModalRoot/MenuWindow/ActionContentMargin/ActionButtonList/PokedexEntryButton")
onready var party_button = get_node_or_null("Backdrop/Panel/UiScaleRoot/ModalRoot/MenuWindow/ActionContentMargin/ActionButtonList/PartyButton")

var title_bgm_player: AudioStreamPlayer = null
var active_debug_overlay: Control = null

func _ready():
	_prepare_debug_runtime_state()
	_wire_menu_buttons()
	_play_title_bgm_if_enabled()
	_focus_default_button()

func _prepare_debug_runtime_state() -> void:
	if runtime_state_script != null:
		if use_debug_seed_profile:
			var seed_result = runtime_state_script.apply_debug_seed_profile(get_tree(), debug_seed_profile_id, true, true)
			if not bool(seed_result.get("ok", false)):
				push_warning("Debug seed profile failed (%s). Falling back to starter seed." % String(seed_result.get("reason", "unknown")))
				runtime_state_script.ensure_party_with_starter(get_tree(), "BULBASAUR", debug_seed_party_level)
		elif debug_seed_full_party_for_ui:
			_seed_debug_full_party(get_tree())
		else:
			runtime_state_script.ensure_party_with_starter(get_tree(), "BULBASAUR", debug_seed_party_level)

func _wire_menu_buttons() -> void:
	_connect_button_scene(pokemon_select_button, POKEMON_SELECT_SCENE_PATH)
	_connect_button_scene(battle_button, BATTLE_SCENE_PATH)
	_connect_button_scene(pokedex_button, POKEDEX_SCENE_PATH)
	if open_overlay_buttons_as_preview:
		_connect_button_action(pokedex_entry_button, "pokedex_entry_preview")
		_connect_button_action(party_button, "party_preview")
	else:
		_connect_button_scene(pokedex_entry_button, POKEDEX_ENTRY_OVERLAY_PATH)
		_connect_button_scene(party_button, PARTY_MENU_OVERLAY_PATH)

func _connect_button_scene(button: Button, scene_path: String) -> void:
	if button == null:
		return
	if button.is_connected("pressed", self, "_on_scene_button_pressed"):
		return
	button.connect("pressed", self, "_on_scene_button_pressed", [scene_path])

func _connect_button_action(button: Button, action_name: String) -> void:
	if button == null:
		return
	if button.is_connected("pressed", self, "_on_debug_action_button_pressed"):
		return
	button.connect("pressed", self, "_on_debug_action_button_pressed", [action_name])

func _on_scene_button_pressed(scene_path: String) -> void:
	_close_debug_overlay()
	entry_scene_path = scene_path
	_debug_log("Changing scene to %s" % entry_scene_path)
	if title_bgm_player != null and title_bgm_player.playing:
		title_bgm_player.stop()
	var result = get_tree().change_scene(entry_scene_path)
	if result != OK:
		push_error("Failed to open entry scene: %s" % entry_scene_path)

func _on_debug_action_button_pressed(action_name: String) -> void:
	if action_name == "party_preview":
		_open_party_overlay_preview()
		return
	if action_name == "pokedex_entry_preview":
		_open_pokedex_entry_overlay_preview()
		return
	_debug_log("Unknown debug action: %s" % action_name)

func _open_party_overlay_preview() -> void:
	var overlay_scene = load(PARTY_MENU_OVERLAY_PATH)
	if overlay_scene == null:
		push_warning("Party overlay preview scene missing: %s" % PARTY_MENU_OVERLAY_PATH)
		return

	var overlay = overlay_scene.instance()
	if overlay == null:
		push_warning("Failed to instance party overlay preview.")
		return

	_close_debug_overlay()
	add_child(overlay)
	overlay.raise()
	active_debug_overlay = overlay

	if overlay.has_signal("close_requested"):
		overlay.connect("close_requested", self, "_on_debug_overlay_close_requested", [overlay])

	var party_members = _get_debug_party_members()
	var active_slot_index = _get_debug_active_slot_index(party_members)
	if overlay.has_method("open_menu"):
		overlay.open_menu(party_members, active_slot_index)
	if overlay.has_method("focus_default"):
		overlay.focus_default()
	_debug_log("Opened Party overlay preview with %d member(s)." % party_members.size())

func _open_pokedex_entry_overlay_preview() -> void:
	var overlay_scene = load(POKEDEX_ENTRY_OVERLAY_PATH)
	if overlay_scene == null:
		push_warning("Pokedex entry overlay preview scene missing: %s" % POKEDEX_ENTRY_OVERLAY_PATH)
		return

	var overlay = overlay_scene.instance()
	if overlay == null:
		push_warning("Failed to instance pokedex entry overlay preview.")
		return

	_close_debug_overlay()
	add_child(overlay)
	overlay.raise()
	active_debug_overlay = overlay

	if overlay.has_signal("close_requested"):
		overlay.connect("close_requested", self, "_on_debug_overlay_close_requested", [overlay])

	var species_id = _get_debug_preview_species_id()
	var is_caught = true
	if runtime_state_script != null:
		is_caught = runtime_state_script.has_caught_species(get_tree(), species_id)
	if overlay.has_method("open_menu"):
		overlay.open_menu(species_id, is_caught)
	if overlay.has_method("focus_default"):
		overlay.focus_default()
	_debug_log("Opened Pokedex Entry overlay preview for %s (caught=%s)." % [species_id, str(is_caught)])

func _on_debug_overlay_close_requested(overlay) -> void:
	if overlay != null:
		overlay.queue_free()
	if overlay == active_debug_overlay:
		active_debug_overlay = null
	_focus_default_button()

func _close_debug_overlay() -> void:
	if active_debug_overlay != null:
		active_debug_overlay.queue_free()
		active_debug_overlay = null

func _get_debug_party_members() -> Array:
	if runtime_state_script == null:
		return _build_fallback_preview_party()
	var party = runtime_state_script.get_party(get_tree())
	if party != null and party.has_method("get_members_copy"):
		var members = party.get_members_copy()
		if typeof(members) == TYPE_ARRAY and not members.empty():
			return members
	return _build_fallback_preview_party()

func _get_debug_active_slot_index(party_members: Array) -> int:
	if party_members.empty():
		return 0
	if runtime_state_script != null:
		var party = runtime_state_script.get_party(get_tree())
		if party != null and party.has_method("get_active_slot_index"):
			var active_index = int(party.get_active_slot_index())
			if active_index >= 0 and active_index < party_members.size():
				return active_index
	return 0

func _get_debug_preview_species_id() -> String:
	if runtime_state_script != null:
		var caught_species = runtime_state_script.get_caught_species_ids(get_tree())
		if typeof(caught_species) == TYPE_ARRAY and not caught_species.empty():
			return String(caught_species[0]).strip_edges().to_upper()

	var fallback_party = _get_debug_party_members()
	if not fallback_party.empty() and typeof(fallback_party[0]) == TYPE_DICTIONARY:
		var species_id = String(fallback_party[0].get("species_id", "")).strip_edges().to_upper()
		if not species_id.empty():
			return species_id

	return "BULBASAUR"

func _build_fallback_preview_party() -> Array:
	return [
		{"species_id": "BULBASAUR", "level": 5, "current_hp": -1, "move_ids": []},
		{"species_id": "CHARMANDER", "level": 5, "current_hp": -1, "move_ids": []},
		{"species_id": "SQUIRTLE", "level": 5, "current_hp": -1, "move_ids": []},
	]

func _play_title_bgm_if_enabled() -> void:
	if not play_title_bgm:
		_debug_log("Title BGM disabled by play_title_bgm flag.")
		return

	var resolved_bgm_path = _resolve_title_bgm_path()
	if resolved_bgm_path.empty():
		push_warning("Title BGM not found. Set Main.title_bgm_path or add title.mp3 to project assets.")
		_debug_log("Title BGM missing. Checked preferred + candidate paths.")
		return

	var stream = load(resolved_bgm_path)
	if stream == null:
		push_warning("Failed to load title BGM stream: %s" % resolved_bgm_path)
		_debug_log("Title BGM load failed at %s" % resolved_bgm_path)
		return

	if title_bgm_player == null:
		title_bgm_player = AudioStreamPlayer.new()
		title_bgm_player.name = "TitleAudioPlayer"
		add_child(title_bgm_player)
		if not title_bgm_player.is_connected("finished", self, "_on_title_bgm_finished"):
			title_bgm_player.connect("finished", self, "_on_title_bgm_finished")

	title_bgm_player.stream = stream
	title_bgm_player.play()
	_debug_log("Title BGM playing from %s" % resolved_bgm_path)

func _resolve_title_bgm_path() -> String:
	var preferred_path = title_bgm_path.strip_edges()
	if not preferred_path.empty() and ResourceLoader.exists(preferred_path):
		return preferred_path

	for candidate_path in TITLE_BGM_CANDIDATE_PATHS:
		if ResourceLoader.exists(candidate_path):
			return candidate_path

	return ""

func _on_title_bgm_finished() -> void:
	if title_bgm_player != null and title_bgm_player.stream != null:
		_debug_log("Title BGM finished; restarting loop.")
		title_bgm_player.play()

func _debug_log(message: String) -> void:
	print("[Main] %s" % message)

func _focus_default_button() -> void:
	if pokemon_select_button != null:
		pokemon_select_button.grab_focus()

func _seed_debug_full_party(tree) -> void:
	if tree == null:
		return
	var seed_result = runtime_state_script.apply_debug_seed_profile(tree, "ui_party_showcase", true, true)
	if not bool(seed_result.get("ok", false)):
		# Legacy fallback path for sessions where profile data is unavailable.
		runtime_state_script.ensure_party_with_starter(tree, "BULBASAUR", debug_seed_party_level)
