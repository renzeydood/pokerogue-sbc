extends Reference

static func parse_sprite_frame(json_path: String, frame_name: String):
	var frames = parse_all_sprite_frames(json_path)
	if frames.empty():
		return null

	for frame in frames:
		if frame.has("filename") and frame["filename"] == frame_name:
			return frame

	return null

static func parse_all_sprite_frames(json_path: String) -> Array:
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
	if typeof(data) != TYPE_DICTIONARY:
		return []

	var root_scale = _parse_atlas_scale(data.get("meta", {}).get("scale", 1.0))
	if data.has("textures"):
		var textures = data["textures"]
		if textures.size() == 0:
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

	return []

static func _normalize_atlas_frames_container(frames_container, atlas_scale: float = 1.0) -> Array:
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

static func _parse_atlas_scale(value) -> float:
	var scale = float(value)
	if scale <= 0.0:
		return 1.0
	return scale
