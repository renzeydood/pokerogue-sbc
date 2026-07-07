tool
extends Reference
class_name EditorPreviewSync

# Generic editor-preview utility for scene-authored UI.
# - If no preview state exists, call the seed method once.
# - Otherwise call refresh methods to keep scene visuals in sync.
static func sync_scene(owner: Object, preview_enabled: bool, has_preview_state: bool, seed_method: String, refresh_method_a: String = "", refresh_method_b: String = "") -> void:
	if owner == null:
		return
	if not Engine.editor_hint:
		return
	if not preview_enabled:
		return

	if not has_preview_state:
		if owner.has_method(seed_method):
			owner.call(seed_method)
		return

	if not refresh_method_a.empty() and owner.has_method(refresh_method_a):
		owner.call(refresh_method_a)
	if not refresh_method_b.empty() and owner.has_method(refresh_method_b):
		owner.call(refresh_method_b)
