extends Control

signal sequence_completed(success)

export(float) var ui_scale := 2.0
export(float) var pre_hold_sec := 0.2
export(float) var cycle_step_sec := 0.12
export(int) var cycle_count := 10
export(float) var flash_in_sec := 0.14
export(float) var flash_out_sec := 0.26
export(float) var resolve_hold_sec := 0.2
export(float) var bg_overlay_fade_in_sec := 0.0
export(float) var bg_overlay_settle_sec := 0.0
export(float) var pre_cycle_delay_sec := 0.2
export(float) var particle_clear_delay_sec := 1.2
export(float) var min_total_sequence_sec := 12.0
export(float) var min_video_play_sec := 10.8
export(bool) var wait_for_video_to_end := true
export(float) var max_video_wait_sec := 14.0
export(float) var video_aspect_width := 367.0
export(float) var video_aspect_height := 152.0
export(bool) var video_keep_aspect_covered := true
export(float) var bg_overlay_max_alpha := 0.55
export(float) var morph_start_after_video_sec := 0.25
export(float) var restore_background_hold_sec := 0.4
export(float) var evolve_message_hold_sec := 1.0
export(float) var evolved_message_hold_sec := 1.5
export(float) var silhouette_charge_sec := 2.0
export(float) var arc_down_phase_sec := 1.1
export(float) var morph_start_scale := 0.25
export(float) var morph_cycle_step := 0.5
export(float) var ring_inward_phase_sec := 0.9
export(float) var reveal_phase_sec := 2.0
export(float) var particle_scale_multiplier := 3.0
export(int) var spiral_lanes := 8

const DEFAULT_TEXTURE_REL := "assets/images/pokemon/1.png"
const DEFAULT_ATLAS_REL := "assets/images/pokemon/1.json"
const EVO_BG_VIDEO_REL_OGV := "assets/images/effects/evo_bg.ogv"
const EVO_BG_VIDEO_REL_MP4 := "assets/images/effects/evo_bg.mp4"
const EVO_SPARKLE_TEXTURE_REL := "assets/images/effects/evo_sparkle.png"

onready var ui_scale_root = get_node_or_null("Backdrop/Panel/UiScaleRoot")
onready var backdrop = get_node_or_null("Backdrop")
onready var panel_root = get_node_or_null("Backdrop/Panel")
onready var modal_root = get_node_or_null("Backdrop/Panel/UiScaleRoot/ModalRoot")
onready var current_pokemon_sprite = get_node_or_null("Backdrop/Panel/UiScaleRoot/ModalRoot/CurrentPokemonSprite")
onready var target_pokemon_sprite = get_node_or_null("Backdrop/Panel/UiScaleRoot/ModalRoot/TargetPokemonSprite")
onready var current_silhouette_sprite = get_node_or_null("Backdrop/Panel/UiScaleRoot/ModalRoot/CurrentPokemonSilhouetteSprite")
onready var target_silhouette_sprite = get_node_or_null("Backdrop/Panel/UiScaleRoot/ModalRoot/TargetPokemonSilhouetteSprite")
onready var message_panel = get_node_or_null("Backdrop/Panel/UiScaleRoot/ModalRoot/MessagePanel")
onready var evo_video_player = get_node_or_null("Backdrop/EvolutionBgVideoPlayer")
onready var battle_text_label = get_node_or_null("Backdrop/Panel/UiScaleRoot/ModalRoot/MessagePanel/MessageMargin/BattleTextLabel")

var flash_rect: ColorRect = null
var bg_overlay_rect: ColorRect = null
var particle_layer: Node2D = null
var ui_audio_player: AudioStreamPlayer = null
var evo_sparkle_texture = null
var _sequence_started_msec := -1
var _video_started_msec := -1
var _from_species_id := ""
var _to_species_id := ""

var catalog_loader_script = load("res://logic/CatalogDataLoader.gd")
var catalog_loader = null
var minimal_assets_path := "res://godot-minimal-assets/"
var sequence_running := false
var _silhouette_shader_material: ShaderMaterial = null

func _ready() -> void:
	randomize()
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	if ui_scale_root != null:
		ui_scale_root.rect_scale = Vector2(ui_scale, ui_scale)
	_ensure_runtime_nodes()
	_update_video_layout()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_video_layout()

func open_sequence(from_species_id: String, to_species_id: String) -> void:
	if sequence_running:
		emit_signal("sequence_completed", false)
		return

	_ensure_runtime_nodes()
	if current_pokemon_sprite == null or target_pokemon_sprite == null:
		emit_signal("sequence_completed", false)
		return

	var from_payload = _load_species_sprite_payload(from_species_id)
	var to_payload = _load_species_sprite_payload(to_species_id)
	if from_payload.empty() or to_payload.empty():
		emit_signal("sequence_completed", false)
		return

	_apply_sprite_payload(current_pokemon_sprite, from_payload)
	_apply_sprite_payload(target_pokemon_sprite, to_payload)
	_apply_sprite_payload(current_silhouette_sprite, from_payload)
	_apply_sprite_payload(target_silhouette_sprite, to_payload)
	_from_species_id = from_species_id.strip_edges().to_upper()
	_to_species_id = to_species_id.strip_edges().to_upper()

	current_pokemon_sprite.visible = true
	target_pokemon_sprite.visible = false
	current_silhouette_sprite.visible = false
	target_silhouette_sprite.visible = false
	current_pokemon_sprite.modulate = Color(1, 1, 1, 1)
	target_pokemon_sprite.modulate = Color(1, 1, 1, 1)
	current_silhouette_sprite.modulate = Color(1, 1, 1, 0)
	target_silhouette_sprite.modulate = Color(1, 1, 1, 0)
	current_pokemon_sprite.scale = Vector2.ONE
	target_pokemon_sprite.scale = Vector2.ONE
	current_silhouette_sprite.scale = Vector2.ONE
	target_silhouette_sprite.scale = Vector2.ONE
	flash_rect.color = Color(1, 1, 1, 0)
	bg_overlay_rect.color = Color(0.149, 0.149, 0.149, 0)
	if evo_video_player != null:
		evo_video_player.visible = false
		evo_video_player.stop()
	_clear_particles()

	visible = true
	sequence_running = true
	_sequence_started_msec = OS.get_ticks_msec()
	_video_started_msec = -1
	_set_overlay_text("What? %s is evolving!" % _from_species_id)
	call_deferred("_run_sequence")

func _run_sequence() -> void:
	if evolve_message_hold_sec > 0.0:
		yield(get_tree().create_timer(evolve_message_hold_sec), "timeout")

	if pre_hold_sec > 0.0:
		yield(get_tree().create_timer(pre_hold_sec), "timeout")

	_play_evo_sfx(["exp.wav", "level_up.wav"])

	var bg_fade_in_time = max(0.0, bg_overlay_fade_in_sec)
	var bg_fade_in: Tween = null
	if bg_fade_in_time > 0.0:
		bg_fade_in = Tween.new()
		add_child(bg_fade_in)
		var overlay_alpha = clamp(bg_overlay_max_alpha, 0.0, 1.0)
		var _fade_in_interp = bg_fade_in.interpolate_property(bg_overlay_rect, "color:a", bg_overlay_rect.color.a, overlay_alpha, bg_fade_in_time, Tween.TRANS_SINE, Tween.EASE_OUT)
		var _fade_in_start = bg_fade_in.start()
	else:
		var c = bg_overlay_rect.color
		c.a = clamp(bg_overlay_max_alpha, 0.0, 1.0)
		bg_overlay_rect.color = c

	var video_started = _start_evo_video_with_fallbacks()
	if video_started is GDScriptFunctionState:
		video_started = yield(video_started, "completed")
	if bg_fade_in != null:
		yield(bg_fade_in, "tween_all_completed")
		bg_fade_in.queue_free()
	if not bool(video_started):
		print("[EvolutionOverlay] Evolution background video failed to start; using particle-only fallback.")

	var morph_wait_state = _wait_for_morph_start_window()
	if morph_wait_state is GDScriptFunctionState:
		yield(morph_wait_state, "completed")

	var charge_state = _run_silhouette_charge_phase()
	if charge_state is GDScriptFunctionState:
		yield(charge_state, "completed")

	_play_evo_sfx(["pb_rel.wav", "hit.wav"])
	var arc_state = _run_arc_downward_phase()
	if arc_state is GDScriptFunctionState:
		yield(arc_state, "completed")

	_clear_particles()
	if pre_cycle_delay_sec > 0.0:
		yield(get_tree().create_timer(pre_cycle_delay_sec), "timeout")

	var morph_state = _run_accelerating_morph_phase()
	if morph_state is GDScriptFunctionState:
		yield(morph_state, "completed")

	_spawn_circle_particles(max(0.12, ring_inward_phase_sec), 16, 190.0, 2.0)
	yield(get_tree().create_timer(max(0.12, ring_inward_phase_sec)), "timeout")
	_play_evo_sfx(["level_up.wav", "hit_strong.wav"])

	var flash_in = Tween.new()
	add_child(flash_in)
	flash_in.interpolate_property(flash_rect, "color:a", 0.0, 1.0, max(0.01, flash_in_sec), Tween.TRANS_SINE, Tween.EASE_OUT)
	flash_in.start()
	yield(flash_in, "tween_all_completed")
	flash_in.queue_free()

	var flash_out = Tween.new()
	add_child(flash_out)
	flash_out.interpolate_property(flash_rect, "color:a", 1.0, 0.0, max(0.01, flash_out_sec), Tween.TRANS_SINE, Tween.EASE_IN)
	flash_out.start()
	yield(flash_out, "tween_all_completed")
	flash_out.queue_free()

	var reveal_state = _run_reveal_phase()
	if reveal_state is GDScriptFunctionState:
		yield(reveal_state, "completed")

	var bg_fade_out_time = max(0.0, flash_out_sec)
	if bg_fade_out_time > 0.0:
		var bg_fade_out = Tween.new()
		add_child(bg_fade_out)
		bg_fade_out.interpolate_property(bg_overlay_rect, "color:a", bg_overlay_rect.color.a, 0.0, bg_fade_out_time, Tween.TRANS_SINE, Tween.EASE_IN)
		bg_fade_out.start()
		yield(bg_fade_out, "tween_all_completed")
		bg_fade_out.queue_free()
	else:
		var co = bg_overlay_rect.color
		co.a = 0.0
		bg_overlay_rect.color = co

	if resolve_hold_sec > 0.0:
		yield(get_tree().create_timer(resolve_hold_sec), "timeout")

	if particle_clear_delay_sec > 0.0:
		yield(get_tree().create_timer(particle_clear_delay_sec), "timeout")

	if wait_for_video_to_end:
		var wait_state = _wait_until_video_stops_or_timeout()
		if wait_state is GDScriptFunctionState:
			yield(wait_state, "completed")

	_ensure_min_video_play_time()
	_ensure_min_total_sequence_time()
	if evo_video_player != null:
		evo_video_player.stop()
		evo_video_player.visible = false
	if restore_background_hold_sec > 0.0:
		yield(get_tree().create_timer(restore_background_hold_sec), "timeout")
	_set_overlay_text("Congratulations! Your %s evolved into %s!" % [_from_species_id, _to_species_id])
	if evolved_message_hold_sec > 0.0:
		yield(get_tree().create_timer(evolved_message_hold_sec), "timeout")
	_clear_particles()

	visible = false
	sequence_running = false
	emit_signal("sequence_completed", true)

func _set_overlay_text(text_value: String) -> void:
	if battle_text_label == null:
		return
	battle_text_label.text = text_value

func _ensure_min_total_sequence_time() -> void:
	if _sequence_started_msec < 0:
		return
	var min_msec = int(max(0.0, min_total_sequence_sec) * 1000.0)
	if min_msec <= 0:
		return
	var elapsed_msec = OS.get_ticks_msec() - _sequence_started_msec
	var remaining_msec = min_msec - elapsed_msec
	if remaining_msec > 0:
		yield(get_tree().create_timer(float(remaining_msec) / 1000.0), "timeout")

func _ensure_min_video_play_time() -> void:
	if _video_started_msec < 0:
		return
	if evo_video_player == null or not evo_video_player.visible:
		return
	var min_msec = int(max(0.0, min_video_play_sec) * 1000.0)
	if min_msec <= 0:
		return
	var elapsed_msec = OS.get_ticks_msec() - _video_started_msec
	var remaining_msec = min_msec - elapsed_msec
	if remaining_msec > 0:
		yield(get_tree().create_timer(float(remaining_msec) / 1000.0), "timeout")

func _wait_for_morph_start_window() -> void:
	if _video_started_msec < 0:
		return
	var min_msec = int(max(0.0, morph_start_after_video_sec) * 1000.0)
	if min_msec <= 0:
		return
	var elapsed_msec = OS.get_ticks_msec() - _video_started_msec
	var remaining_msec = min_msec - elapsed_msec
	if remaining_msec > 0:
		yield(get_tree().create_timer(float(remaining_msec) / 1000.0), "timeout")

func _ensure_runtime_nodes() -> void:
	if modal_root == null or current_pokemon_sprite == null:
		return

	if target_pokemon_sprite == null or not is_instance_valid(target_pokemon_sprite):
		target_pokemon_sprite = Sprite.new()
		target_pokemon_sprite.name = "TargetPokemonSprite"
		target_pokemon_sprite.centered = true
		target_pokemon_sprite.region_enabled = true
		target_pokemon_sprite.position = current_pokemon_sprite.position
		target_pokemon_sprite.offset = current_pokemon_sprite.offset
		modal_root.add_child(target_pokemon_sprite)

	if current_silhouette_sprite == null or not is_instance_valid(current_silhouette_sprite):
		current_silhouette_sprite = Sprite.new()
		current_silhouette_sprite.name = "CurrentPokemonSilhouetteSprite"
		current_silhouette_sprite.centered = true
		current_silhouette_sprite.region_enabled = true
		current_silhouette_sprite.position = current_pokemon_sprite.position
		current_silhouette_sprite.offset = current_pokemon_sprite.offset
		current_silhouette_sprite.material = _get_silhouette_material()
		modal_root.add_child(current_silhouette_sprite)

	if target_silhouette_sprite == null or not is_instance_valid(target_silhouette_sprite):
		target_silhouette_sprite = Sprite.new()
		target_silhouette_sprite.name = "TargetPokemonSilhouetteSprite"
		target_silhouette_sprite.centered = true
		target_silhouette_sprite.region_enabled = true
		target_silhouette_sprite.position = target_pokemon_sprite.position
		target_silhouette_sprite.offset = target_pokemon_sprite.offset
		target_silhouette_sprite.material = _get_silhouette_material()
		modal_root.add_child(target_silhouette_sprite)

	if particle_layer == null or not is_instance_valid(particle_layer):
		particle_layer = Node2D.new()
		particle_layer.name = "ParticleLayer"
		modal_root.add_child(particle_layer)
		if message_panel != null and message_panel.get_parent() == modal_root:
			modal_root.move_child(particle_layer, message_panel.get_index())

	if bg_overlay_rect == null or not is_instance_valid(bg_overlay_rect):
		bg_overlay_rect = ColorRect.new()
		bg_overlay_rect.name = "EvolutionBgOverlayRect"
		bg_overlay_rect.anchor_right = 1.0
		bg_overlay_rect.anchor_bottom = 1.0
		bg_overlay_rect.color = Color(0.149, 0.149, 0.149, 0)
		if backdrop != null:
			backdrop.add_child(bg_overlay_rect)

	if evo_video_player == null or not is_instance_valid(evo_video_player):
		evo_video_player = VideoPlayer.new()
		evo_video_player.name = "EvolutionBgVideoPlayer"
		evo_video_player.anchor_left = 0.0
		evo_video_player.anchor_top = 0.0
		evo_video_player.anchor_right = 0.0
		evo_video_player.anchor_bottom = 0.0
		evo_video_player.margin_left = 0.0
		evo_video_player.margin_top = 0.0
		evo_video_player.margin_right = 0.0
		evo_video_player.margin_bottom = 0.0
		evo_video_player.expand = true
		evo_video_player.visible = false
		if backdrop != null:
			backdrop.add_child(evo_video_player)

	if evo_video_player != null and evo_video_player.stream == null:
		var default_stream = _load_first_existing_video_stream()
		if default_stream != null:
			evo_video_player.stream = default_stream
	_ensure_background_layer_order()
	_update_video_layout()

	if ui_audio_player == null or not is_instance_valid(ui_audio_player):
		ui_audio_player = AudioStreamPlayer.new()
		ui_audio_player.name = "EvolutionOverlayAudioPlayer"
		add_child(ui_audio_player)

	if evo_sparkle_texture == null:
		var sparkle_path = minimal_assets_path + EVO_SPARKLE_TEXTURE_REL
		if ResourceLoader.exists(sparkle_path):
			evo_sparkle_texture = load(sparkle_path)

	if flash_rect == null or not is_instance_valid(flash_rect):
		flash_rect = ColorRect.new()
		flash_rect.name = "FlashRect"
		flash_rect.anchor_right = 1.0
		flash_rect.anchor_bottom = 1.0
		flash_rect.color = Color(1, 1, 1, 0)
		if backdrop != null:
			backdrop.add_child(flash_rect)
	_ensure_background_layer_order()

func _ensure_background_layer_order() -> void:
	if backdrop == null or panel_root == null:
		return
	if evo_video_player != null and evo_video_player.get_parent() == backdrop:
		backdrop.move_child(evo_video_player, 0)
	if bg_overlay_rect != null and bg_overlay_rect.get_parent() == backdrop:
		backdrop.move_child(bg_overlay_rect, 1)
	if flash_rect != null and flash_rect.get_parent() == backdrop:
		backdrop.move_child(flash_rect, 2)

func _get_silhouette_material() -> ShaderMaterial:
	if _silhouette_shader_material == null:
		var shader = Shader.new()
		shader.code = "shader_type canvas_item;\nvoid fragment() {\n\tvec4 tex = texture(TEXTURE, UV);\n\tCOLOR = vec4(1.0, 1.0, 1.0, tex.a * COLOR.a);\n}\n"
		_silhouette_shader_material = ShaderMaterial.new()
		_silhouette_shader_material.shader = shader
	return _silhouette_shader_material

func _run_silhouette_charge_phase() -> void:
	current_pokemon_sprite.visible = true
	target_pokemon_sprite.visible = false
	current_silhouette_sprite.visible = true
	target_silhouette_sprite.visible = false
	current_silhouette_sprite.scale = Vector2.ONE
	current_silhouette_sprite.modulate = Color(1, 1, 1, 0)

	var fade_tint = Tween.new()
	add_child(fade_tint)
	fade_tint.interpolate_property(current_silhouette_sprite, "modulate:a", 0.0, 1.0, max(0.2, silhouette_charge_sec), Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	fade_tint.start()

	var batch_count := 9
	var batch_delay := max(0.06, silhouette_charge_sec / float(batch_count))
	var lane_count: int = int(max(2, spiral_lanes))
	for cycle in range(batch_count):
		for i in range(lane_count):
			_spawn_source_spiral_particle(16.0 * float(cycle) + float(i) * 64.0, cycle, i, lane_count, false)
		yield(get_tree().create_timer(batch_delay), "timeout")

	if is_instance_valid(fade_tint):
		if fade_tint.is_active():
			yield(fade_tint, "tween_all_completed")
		fade_tint.queue_free()
	current_pokemon_sprite.visible = false

func _run_arc_downward_phase() -> void:
	var strand_particle_count := 6
	var strand_particle_delay := 0.03
	var strand_offsets = [-4.0, 4.0]
	for i in range(9):
		for strand_offset in strand_offsets:
			for strand_particle_index in range(strand_particle_count):
				var start_delay = float(strand_particle_index) * strand_particle_delay
				_spawn_source_arc_particle(16.0 * float(i), i, float(strand_offset), start_delay, false)
	var pass_duration = max(0.14, arc_down_phase_sec * 0.62) + float(strand_particle_count - 1) * strand_particle_delay
	yield(get_tree().create_timer(pass_duration), "timeout")

func _run_accelerating_morph_phase() -> void:
	_clear_particles()
	current_silhouette_sprite.visible = true
	target_silhouette_sprite.visible = true
	current_silhouette_sprite.modulate = Color(1, 1, 1, 1)
	target_silhouette_sprite.modulate = Color(1, 1, 1, 1)
	current_silhouette_sprite.scale = Vector2.ONE
	target_silhouette_sprite.scale = Vector2(morph_start_scale, morph_start_scale)

	var current_cycle := 1.0
	var final_cycle := max(1.0, float(cycle_count))
	while current_cycle <= final_cycle + 0.001:
		var is_final = current_cycle >= final_cycle
		var duration = max(0.03, 0.5 / current_cycle)
		var tw = Tween.new()
		add_child(tw)
		tw.interpolate_property(current_silhouette_sprite, "scale", current_silhouette_sprite.scale, Vector2(morph_start_scale, morph_start_scale), duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tw.interpolate_property(target_silhouette_sprite, "scale", target_silhouette_sprite.scale, Vector2.ONE, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		if not is_final:
			tw.interpolate_property(current_silhouette_sprite, "scale", Vector2(morph_start_scale, morph_start_scale), Vector2.ONE, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, duration)
			tw.interpolate_property(target_silhouette_sprite, "scale", Vector2.ONE, Vector2(morph_start_scale, morph_start_scale), duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, duration)
		tw.start()
		yield(tw, "tween_all_completed")
		tw.queue_free()
		current_cycle += max(0.1, morph_cycle_step)

	current_silhouette_sprite.visible = false
	target_silhouette_sprite.visible = true
	target_silhouette_sprite.scale = Vector2.ONE
	target_silhouette_sprite.modulate = Color(1, 1, 1, 1)
	target_pokemon_sprite.visible = false

func _run_reveal_phase() -> void:
	target_pokemon_sprite.visible = true
	target_pokemon_sprite.modulate = Color(1, 1, 1, 0)
	target_silhouette_sprite.visible = true
	target_silhouette_sprite.modulate = Color(1, 1, 1, 1)

	_spawn_fountain_particles(max(0.2, reveal_phase_sec), 52)
	var reveal_tween = Tween.new()
	add_child(reveal_tween)
	reveal_tween.interpolate_property(target_pokemon_sprite, "modulate:a", 0.0, 1.0, max(0.2, reveal_phase_sec), Tween.TRANS_SINE, Tween.EASE_IN)
	reveal_tween.interpolate_property(target_silhouette_sprite, "modulate:a", 1.0, 0.0, max(0.2, reveal_phase_sec), Tween.TRANS_SINE, Tween.EASE_OUT)
	reveal_tween.start()
	yield(reveal_tween, "tween_all_completed")
	reveal_tween.queue_free()
	target_silhouette_sprite.visible = false
	target_pokemon_sprite.modulate = Color(1, 1, 1, 1)
	target_pokemon_sprite.scale = Vector2.ONE

func _load_species_sprite_payload(species_id: String) -> Dictionary:
	var sprite_paths = _get_species_sprite_paths(species_id)
	if sprite_paths.empty():
		sprite_paths = {
			"texture_rel": DEFAULT_TEXTURE_REL,
			"atlas_rel": DEFAULT_ATLAS_REL,
		}

	var texture_path = minimal_assets_path + String(sprite_paths.get("texture_rel", ""))
	var atlas_path = minimal_assets_path + String(sprite_paths.get("atlas_rel", ""))
	if not ResourceLoader.exists(texture_path):
		return {}

	var texture = load(texture_path)
	if texture == null:
		return {}

	var frame = _parse_sprite_frame(atlas_path, "0001.png")
	if frame == null:
		var numeric_frames = _get_all_numeric_frames(atlas_path)
		if not numeric_frames.empty():
			frame = numeric_frames[0]
	if frame == null:
		var all_frames = _parse_all_sprite_frames(atlas_path)
		if not all_frames.empty():
			frame = all_frames[0]

	if frame == null:
		return {
			"texture": texture,
			"region": Rect2(0, 0, texture.get_size().x, texture.get_size().y),
		}

	var frame_rect = frame.get("frame", {})
	if typeof(frame_rect) != TYPE_DICTIONARY:
		return {}
	var frame_w = int(frame_rect.get("w", 0))
	var frame_h = int(frame_rect.get("h", 0))
	if frame_w <= 0 or frame_h <= 0:
		return {}

	return {
		"texture": texture,
		"region": Rect2(frame_rect.get("x", 0), frame_rect.get("y", 0), frame_w, frame_h),
	}

func _apply_sprite_payload(sprite_node: Sprite, payload: Dictionary) -> void:
	if sprite_node == null or payload.empty():
		return
	sprite_node.texture = payload.get("texture", null)
	sprite_node.region_enabled = true
	sprite_node.region_rect = payload.get("region", Rect2(0, 0, 1, 1))

func _spawn_source_spiral_particle(trig_index: float, cycle_index: int, lane_index: int, lane_count: int, _inward_after: bool) -> void:
	if particle_layer == null or evo_sparkle_texture == null:
		return
	var center = current_pokemon_sprite.position
	var lane_count_safe: int = int(max(2, lane_count))
	var lane_t: float = float(lane_index) / float(lane_count_safe - 1)
	var lane_basis_x: float = lerp(-2.5, 2.5, lane_t)
	var lane_width = 5.0 + float(cycle_index) * 0.35
	var lane_offset_y = -24.0 + float(lane_index) * 1.0 - float(cycle_index) * 0.15
	var lane_phase: float = lane_basis_x * 22.0 + float(cycle_index) * 6.0
	var particle = Sprite.new()
	particle.texture = evo_sparkle_texture
	particle.centered = true
	particle.position = center + Vector2(0.0, lane_offset_y)
	particle.modulate = Color(1.0, 1.0, 1.0, 1.0)
	particle.scale = Vector2(0.22, 0.22) * particle_scale_multiplier
	particle_layer.add_child(particle)

	var f := 0
	var amp := 28.0
	var local_trig := trig_index
	var elapsed := 0.0
	var total := max(0.18, silhouette_charge_sec * 0.75)
	while elapsed < total and is_instance_valid(particle):
		var t: float = elapsed / total
		var t_apex: float = t * t
		var width_scale: float = lerp(3.0, 0.5, t)
		var wobble_scale: float = lerp(1.2, 0.4, t)
		var cone_radius: float = abs(lane_basis_x) * lane_width * width_scale
		var swirl_radius: float = cone_radius + amp * wobble_scale
		var phase: float = local_trig + lane_phase
		var depth := 44.0 - (float(f) * float(f)) / 45.0
		particle.position = center + Vector2(_particle_cos(phase, swirl_radius), depth + lane_offset_y)
		particle.position.y += _particle_sin(phase, amp * 0.5) / 4.0
		particle.scale = Vector2.ONE * particle_scale_multiplier * lerp(0.34, 0.08, t_apex)
		particle.modulate.a = 0.98 - t * 0.70
		local_trig += 3.0
		if (f % 2) == 1:
			amp -= 1.0
		f += 1
		yield(get_tree().create_timer(0.016), "timeout")
		elapsed += 0.016
	if is_instance_valid(particle):
		particle.queue_free()

func _spawn_source_arc_particle(trig_index: float, lane_index: int, strand_offset: float, start_delay: float, _unused := false) -> void:
	if particle_layer == null or evo_sparkle_texture == null:
		return
	if start_delay > 0.0:
		yield(get_tree().create_timer(start_delay), "timeout")
	var center = current_pokemon_sprite.position
	var lane_offset = (float(lane_index) - 4.0) * 6.5
	var initial_x = center.x + lane_offset + strand_offset
	var lane_sign := sign(lane_offset)
	if lane_sign == 0.0:
		lane_sign = sign(strand_offset)
	if lane_sign == 0.0:
		lane_sign = -1.0 if int(trig_index) < 64 else 1.0
	var particle = Sprite.new()
	particle.texture = evo_sparkle_texture
	particle.centered = true
	particle.position = Vector2(initial_x, center.y - 54.0)
	particle.modulate = Color(1.0, 1.0, 1.0, 1.0)
	particle.scale = Vector2(0.19, 0.19) * particle_scale_multiplier
	particle_layer.add_child(particle)

	var f := 0
	var amp := 8.0
	var local_trig := trig_index
	var elapsed := 0.0
	var total := max(0.14, arc_down_phase_sec * 0.62)
	var y_start: float = center.y - 66.0
	var y_end: float = center.y + 28.0
	var y_span: float = y_end - y_start
	var base_bow: float = 2.5 + abs(lane_offset) * 0.11 + abs(strand_offset) * 0.45
	while elapsed < total and is_instance_valid(particle):
		var t: float = min(1.0, elapsed / total)
		var t_curve: float = pow(t, 1.45)
		var depth: float = y_start + y_span * pow(t, 1.08)
		var bow_profile: float = sin(t_curve * PI)
		var bow_out: float = lane_sign * (base_bow * bow_profile)
		var outward_falloff: float = max(0.0, 1.0 - pow(t, 1.6))
		var outward_jitter: float = lane_sign * abs(_particle_cos(local_trig, amp)) * (0.10 + 0.28 * outward_falloff)
		particle.position = Vector2(initial_x + bow_out + outward_jitter, depth)
		particle.position.y += _particle_sin(local_trig, amp) / 6.0
		amp = 8.0 + _particle_sin(float(f) * 4.0, 30.0)
		particle.modulate.a = 1.0 - min(0.78, t * 0.78)
		local_trig += 1.0
		f += 1
		yield(get_tree().create_timer(0.016), "timeout")
		elapsed += 0.016
	if is_instance_valid(particle):
		particle.queue_free()

func _spawn_source_spray_particles() -> void:
	if particle_layer == null or evo_sparkle_texture == null:
		return
	for i in range(8):
		_animate_spray_particle(float(i), 0)
	for i in range(1, 50):
		yield(get_tree().create_timer(0.016), "timeout")
		_animate_spray_particle(float(randi() % 8), i)

func _spawn_source_circle_inward_particles(speed: int, radius: float) -> void:
	if particle_layer == null or evo_sparkle_texture == null:
		return
	var center = current_pokemon_sprite.position
	for i in range(16):
		var angle = TAU * float(i) / 16.0
		var particle = Sprite.new()
		particle.texture = evo_sparkle_texture
		particle.centered = true
		particle.position = center + Vector2(cos(angle), sin(angle)) * radius
		particle.modulate = Color(1.0, 1.0, 1.0, 1.0)
		particle.scale = Vector2(0.22, 0.22) * particle_scale_multiplier
		particle_layer.add_child(particle)
		_animate_circle_inward_particle(particle, center, angle * 128.0, speed)

func _animate_circle_inward_particle(sprite: Sprite, center: Vector2, trig_index: float, speed: int) -> void:
	var amp := 120.0
	var local_trig := trig_index
	while amp > 8.0 and is_instance_valid(sprite):
		sprite.position = center + Vector2(_particle_cos(local_trig, amp), _particle_sin(local_trig, amp))
		amp -= float(speed)
		local_trig += 4.0
		sprite.scale = Vector2.ONE * particle_scale_multiplier * (0.22 + amp / 800.0)
		yield(get_tree().create_timer(0.016), "timeout")
	if is_instance_valid(sprite):
		sprite.queue_free()

func _animate_spray_particle(trig_index: float, _frame_index: int) -> void:
	if particle_layer == null or evo_sparkle_texture == null:
		return
	var center = current_pokemon_sprite.position
	var particle = Sprite.new()
	particle.texture = evo_sparkle_texture
	particle.centered = true
	particle.position = center
	particle.modulate = Color(1.0, 1.0, 1.0, 1.0)
	particle.scale = Vector2(0.18, 0.18) * particle_scale_multiplier
	particle_layer.add_child(particle)

	var f := 0
	var y_offset := 0.0
	var speed := 3 - int(randi() % 8)
	var amp := 48 + int(randi() % 64)
	var local_trig := trig_index
	var elapsed := 0.0
	var total := 0.9
	while elapsed < total and is_instance_valid(particle):
		if (f % 4) == 0:
			y_offset += 1.0
		particle.position = center + Vector2((float(speed) * float(f)) / 3.0, y_offset)
		particle.position.y += -_particle_sin(local_trig, amp)
		if f > 108:
			particle.scale = Vector2.ONE * particle_scale_multiplier * (1.0 - (float(f) - 108.0) / 20.0)
		local_trig += 1.0
		f += 1
		yield(get_tree().create_timer(0.016), "timeout")
		elapsed += 0.016
	if is_instance_valid(particle):
		particle.queue_free()

func _play_evo_sfx(candidates: Array) -> void:
	if ui_audio_player == null or candidates.empty():
		return
	for file_name in candidates:
		var sfx_path = minimal_assets_path + "assets/audio/se/" + String(file_name)
		if not ResourceLoader.exists(sfx_path):
			continue
		var stream = load(sfx_path)
		if stream == null:
			continue
		ui_audio_player.stream = stream
		ui_audio_player.play()
		return

func _load_first_existing_video_stream():
	for rel_path in [EVO_BG_VIDEO_REL_OGV, EVO_BG_VIDEO_REL_MP4]:
		var video_path = minimal_assets_path + rel_path
		if not ResourceLoader.exists(video_path):
			continue
		var stream = load(video_path)
		if stream != null:
			return stream
	return null

func _start_evo_video_with_fallbacks():
	if evo_video_player == null:
		return false

	for rel_path in [EVO_BG_VIDEO_REL_OGV, EVO_BG_VIDEO_REL_MP4]:
		var video_path = minimal_assets_path + rel_path
		if not ResourceLoader.exists(video_path):
			continue
		var stream = load(video_path)
		if stream == null:
			continue

		evo_video_player.stop()
		evo_video_player.stream = stream
		_update_video_layout()
		evo_video_player.visible = true
		evo_video_player.play()
		for _i in range(6):
			yield(get_tree().create_timer(0.05), "timeout")
			if evo_video_player.is_playing():
				_video_started_msec = OS.get_ticks_msec()
				return true

	print("[EvolutionOverlay] Unable to decode evolution video stream from OGV/MP4 candidates.")
	evo_video_player.visible = false
	return false

func _wait_until_video_stops_or_timeout():
	if evo_video_player == null or not evo_video_player.visible:
		return
	if _video_started_msec < 0:
		return

	var timeout_msec = int(max(0.0, max_video_wait_sec) * 1000.0)
	if timeout_msec <= 0:
		return

	while evo_video_player.is_playing():
		var elapsed_msec = OS.get_ticks_msec() - _video_started_msec
		if elapsed_msec >= timeout_msec:
			break
		yield(get_tree().create_timer(0.1), "timeout")

func _update_video_layout() -> void:
	if evo_video_player == null:
		return

	var container_size = rect_size
	if backdrop != null:
		container_size = backdrop.rect_size
	if container_size.x <= 0.0 or container_size.y <= 0.0:
		return

	var src_w = max(1.0, video_aspect_width)
	var src_h = max(1.0, video_aspect_height)
	var src_aspect = src_w / src_h
	var dst_aspect = container_size.x / container_size.y

	var target_w = container_size.x
	var target_h = container_size.y
	if video_keep_aspect_covered:
		if dst_aspect > src_aspect:
			target_w = container_size.x
			target_h = target_w / src_aspect
		else:
			target_h = container_size.y
			target_w = target_h * src_aspect
	else:
		if dst_aspect > src_aspect:
			target_h = container_size.y
			target_w = target_h * src_aspect
		else:
			target_w = container_size.x
			target_h = target_w / src_aspect

	evo_video_player.margin_left = floor((container_size.x - target_w) * 0.5)
	evo_video_player.margin_top = floor((container_size.y - target_h) * 0.5)
	evo_video_player.margin_right = evo_video_player.margin_left + floor(target_w)
	evo_video_player.margin_bottom = evo_video_player.margin_top + floor(target_h)

func _clear_particles() -> void:
	if particle_layer == null:
		return
	for child in particle_layer.get_children():
		if child != null:
			child.queue_free()

func _spawn_spiral_particles(duration: float, count: int, outward: bool) -> void:
	if particle_layer == null or evo_sparkle_texture == null:
		return
	var center = current_pokemon_sprite.position
	for i in range(max(1, count)):
		var angle = (TAU * float(i)) / float(max(1, count))
		var radius = 10.0 + float(i % 4) * 3.0
		var sprite = Sprite.new()
		sprite.texture = evo_sparkle_texture
		sprite.centered = true
		sprite.position = center + Vector2(cos(angle), sin(angle)) * radius
		sprite.modulate = Color(1.0, 1.0, 1.0, 0.9)
		sprite.scale = Vector2(0.26, 0.26) * particle_scale_multiplier
		particle_layer.add_child(sprite)
		_animate_spiral_particle(sprite, center, angle * 128.0, duration, outward)

func _spawn_arc_particles(duration: float, count: int) -> void:
	if particle_layer == null or evo_sparkle_texture == null:
		return
	var center = current_pokemon_sprite.position
	for i in range(max(1, count)):
		var t = float(i) / float(max(1, count - 1))
		var start = center + Vector2(-70.0 + 140.0 * t, -12.0)
		var sprite = Sprite.new()
		sprite.texture = evo_sparkle_texture
		sprite.centered = true
		sprite.position = start
		sprite.modulate = Color(1.0, 1.0, 1.0, 0.95)
		sprite.scale = Vector2(0.18, 0.18) * particle_scale_multiplier
		particle_layer.add_child(sprite)
		_animate_arc_particle(sprite, center, i * 16, duration)

func _spawn_circle_particles(duration: float, count: int, start_radius := 92.0, target_radius := 26.0) -> void:
	if particle_layer == null or evo_sparkle_texture == null:
		return
	var center = current_pokemon_sprite.position
	for i in range(max(1, count)):
		var angle = (TAU * float(i)) / float(max(1, count))
		var start = center + Vector2(cos(angle), sin(angle)) * start_radius
		var target = center + Vector2(cos(angle), sin(angle)) * target_radius
		var sprite = Sprite.new()
		sprite.texture = evo_sparkle_texture
		sprite.centered = true
		sprite.position = start
		sprite.modulate = Color(1.0, 1.0, 1.0, 0.98)
		sprite.scale = Vector2(0.24, 0.24) * particle_scale_multiplier
		particle_layer.add_child(sprite)
		var tw = Tween.new()
		sprite.add_child(tw)
		tw.interpolate_property(sprite, "position", start, target, duration, Tween.TRANS_SINE, Tween.EASE_OUT)
		tw.interpolate_property(sprite, "modulate:a", sprite.modulate.a, 0.0, duration, Tween.TRANS_SINE, Tween.EASE_IN)
		tw.interpolate_callback(sprite, duration, "queue_free")
		tw.start()

func _animate_spiral_particle(sprite: Sprite, center: Vector2, trig_index: float, duration: float, outward: bool) -> void:
	var f := 0
	var amp := 48.0
	var elapsed := 0.0
	var total := max(0.12, duration)
	while elapsed < total and is_instance_valid(sprite):
		var t := elapsed / total
		var depth := 88.0 - (float(f) * float(f)) / 80.0
		if outward:
			depth = 18.0 - (float(f) * float(f)) / 160.0
		sprite.position = center + Vector2(0.0, depth)
		sprite.position.y += _particle_sin(trig_index, amp) / 4.0
		sprite.position.x += _particle_cos(trig_index, amp)
		sprite.scale = Vector2.ONE * particle_scale_multiplier * (0.30 - t * 0.20)
		sprite.modulate.a = 0.90 - t * 0.90
		trig_index += 4.0
		if (f % 2) == 1:
			amp -= 1.0
		f += 1
		yield(get_tree().create_timer(0.016), "timeout")
		elapsed += 0.016
	if is_instance_valid(sprite):
		sprite.queue_free()

func _animate_arc_particle(sprite: Sprite, center: Vector2, trig_index: float, duration: float) -> void:
	var f := 0
	var amp := 8.0
	var elapsed := 0.0
	var total := max(0.12, duration)
	while elapsed < total and is_instance_valid(sprite):
		var depth := 8.0 + (float(f) * float(f)) / 5.0
		sprite.position = center + Vector2(0.0, depth)
		sprite.position.y += _particle_sin(trig_index, amp) / 4.0
		sprite.position.x += _particle_cos(trig_index, amp)
		amp = 8 + _particle_sin(f * 4, 40)
		sprite.scale = Vector2.ONE * particle_scale_multiplier * (0.22 - min(0.12, elapsed / total * 0.10))
		trig_index += 1.0
		f += 1
		yield(get_tree().create_timer(0.016), "timeout")
		elapsed += 0.016
	if is_instance_valid(sprite):
		sprite.queue_free()

func _spawn_spray_particles(duration: float, count: int) -> void:
	if particle_layer == null or evo_sparkle_texture == null:
		return
	var center = current_pokemon_sprite.position
	for _i in range(max(1, count)):
		var angle = rand_range(-PI, PI)
		var dist = rand_range(36.0, 132.0)
		var target = center + Vector2(cos(angle), sin(angle)) * dist
		var sprite = Sprite.new()
		sprite.texture = evo_sparkle_texture
		sprite.centered = true
		sprite.position = center
		sprite.modulate = Color(1.0, 1.0, 1.0, 0.98)
		sprite.scale = Vector2(0.18, 0.18) * particle_scale_multiplier
		particle_layer.add_child(sprite)
		var tw = Tween.new()
		sprite.add_child(tw)
		tw.interpolate_property(sprite, "position", center, target, duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
		tw.interpolate_property(sprite, "modulate:a", sprite.modulate.a, 0.0, duration, Tween.TRANS_SINE, Tween.EASE_IN)
		tw.interpolate_property(sprite, "scale", sprite.scale, Vector2(0.08, 0.08) * particle_scale_multiplier, duration, Tween.TRANS_SINE, Tween.EASE_IN)
		tw.interpolate_callback(sprite, duration, "queue_free")
		tw.start()

func _spawn_fountain_particles(duration: float, count: int) -> void:
	if particle_layer == null or evo_sparkle_texture == null:
		return
	var center = current_pokemon_sprite.position
	var mouth = center + Vector2(0, -22)
	for _i in range(max(1, count)):
		var spread = rand_range(-140.0, 140.0)
		var end_y = mouth.y + rand_range(8.0, 24.0)
		var target = Vector2(mouth.x + spread, end_y)
		var arc_height = rand_range(72.0, 128.0)
		var travel_time = max(0.18, duration * rand_range(0.72, 1.0))
		var sprite = Sprite.new()
		sprite.texture = evo_sparkle_texture
		sprite.centered = true
		var start = mouth + Vector2(rand_range(-12.0, 12.0), rand_range(-4.0, 4.0))
		sprite.position = start
		sprite.modulate = Color(1.0, 1.0, 1.0, 0.95)
		sprite.scale = Vector2(0.16, 0.16) * particle_scale_multiplier
		particle_layer.add_child(sprite)
		_animate_fountain_particle(sprite, start, target, arc_height, travel_time)

func _animate_fountain_particle(sprite: Sprite, start: Vector2, target: Vector2, arc_height: float, travel_time: float) -> void:
	var elapsed := 0.0
	var total := max(0.18, travel_time)
	while elapsed < total and is_instance_valid(sprite):
		var t: float = min(1.0, elapsed / total)
		var smooth_t: float = t * t * (3.0 - 2.0 * t)
		var pos: Vector2 = start.linear_interpolate(target, smooth_t)
		pos.y -= sin(t * PI) * arc_height
		sprite.position = pos
		sprite.scale = Vector2.ONE * particle_scale_multiplier * lerp(0.16, 0.05, t)
		sprite.modulate.a = 0.95 * (1.0 - pow(t, 1.2))
		yield(get_tree().create_timer(0.016), "timeout")
		elapsed += 0.016
	if is_instance_valid(sprite):
		sprite.queue_free()

func _spawn_morph_cycle_particles(duration: float, count: int, toward_target: bool) -> void:
	if particle_layer == null or evo_sparkle_texture == null:
		return
	var center = current_pokemon_sprite.position
	var y_bias = -1.0 if toward_target else 1.0
	for i in range(max(1, count)):
		var t = float(i) / float(max(1, count - 1))
		var start = center + Vector2(-54.0 + 108.0 * t, 16.0 * y_bias)
		var target = center + Vector2(-20.0 + 40.0 * t, -76.0 * y_bias)
		var sprite = Sprite.new()
		sprite.texture = evo_sparkle_texture
		sprite.centered = true
		sprite.position = start
		sprite.modulate = Color(1.0, rand_range(0.9, 1.0), rand_range(0.7, 0.92), 0.95)
		sprite.scale = Vector2(rand_range(0.1, 0.18), rand_range(0.1, 0.18)) * particle_scale_multiplier
		sprite.rotation = rand_range(-PI, PI)
		particle_layer.add_child(sprite)

		var tw = Tween.new()
		sprite.add_child(tw)
		tw.interpolate_property(sprite, "position", start, target, duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tw.interpolate_property(sprite, "modulate:a", sprite.modulate.a, 0.0, duration, Tween.TRANS_SINE, Tween.EASE_IN)
		tw.interpolate_property(sprite, "scale", sprite.scale, sprite.scale * 0.55, duration, Tween.TRANS_SINE, Tween.EASE_IN)
		tw.interpolate_property(sprite, "rotation", sprite.rotation, sprite.rotation + rand_range(0.8, 2.4), duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tw.interpolate_callback(sprite, duration, "queue_free")
		tw.start()

func _particle_sin(index: float, amplitude: float) -> float:
	return amplitude * sin(index * (PI / 128.0))

func _particle_cos(index: float, amplitude: float) -> float:
	return amplitude * cos(index * (PI / 128.0))

func _get_species_sprite_paths(species_id: String) -> Dictionary:
	if species_id.strip_edges().empty():
		return {}
	if catalog_loader == null:
		catalog_loader = catalog_loader_script.new()
	if catalog_loader == null or not catalog_loader.load_catalogs():
		return {}
	return catalog_loader.build_sprite_resource_paths(species_id.strip_edges().to_upper(), false)

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
		var frame_index = _extract_numeric_frame_index(String(frame["filename"]))
		if frame_index < 0:
			continue
		indexed.append({"index": frame_index, "frame": frame})
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
