extends Reference

const ITEM_MODEL_CATALOG_PATH := "res://data/item-model-catalog.v1.json"

var _catalog_loaded := false
var _catalog := {}
var _catalog_error := ""

func resolve_post_battle_model(run_context: Dictionary, item_inventory: Dictionary) -> Dictionary:
	_ensure_catalog_loaded()

	var free_items = _build_free_reward_items(item_inventory)
	var shop_items = _build_shop_reward_items(run_context)
	var skip_menu = free_items.empty() and shop_items.empty()

	return {
		"free_items": free_items,
		"shop_items": shop_items,
		"skip_menu": skip_menu,
		"meta": {
			"schema_version": int(_catalog.get("schema_version", 1)),
			"source": String(_catalog.get("generated_from", "catalog")),
			"catalog_error": _catalog_error,
		},
	}

func _build_free_reward_items(item_inventory: Dictionary) -> Array:
	var defaults = _catalog.get("free_reward_defaults", [])
	if typeof(defaults) != TYPE_ARRAY or defaults.empty():
		return []

	var free_items := []
	for entry in defaults:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var inventory_key = String(entry.get("inventory_key", entry.get("id", ""))).strip_edges().to_lower()
		if inventory_key.empty():
			continue
		var count = max(0, int(item_inventory.get(inventory_key, 0)))
		if count <= 0:
			continue

		var label_base = String(entry.get("label", _title_case_id(inventory_key)))
		free_items.append({
			"id": String(entry.get("id", inventory_key)).strip_edges().to_lower(),
			"label": "%s x%d" % [label_base, count],
			"enabled": true,
			"cost": 0,
			"icon": String(entry.get("icon", inventory_key)).strip_edges().to_lower(),
			"kind": String(entry.get("kind", "free")),
			"usage": String(entry.get("usage", "consumable")),
			"effect_key": String(entry.get("effect_key", "")),
			"target_hint": String(entry.get("target_hint", "self_party_single")),
			"trigger_hint": String(entry.get("trigger_hint", "on_use")),
		})

	return free_items

func _build_shop_reward_items(run_context: Dictionary) -> Array:
	var wave_index = int(run_context.get("wave_index", 1))
	if wave_index % 10 == 0:
		return []

	var encounter_number = int(run_context.get("encounter_number", 1))
	var base_cost = int(max(100, run_context.get("base_cost", encounter_number * 100)))

	var tiers = _catalog.get("shop_progression_tiers", [])
	if typeof(tiers) != TYPE_ARRAY or tiers.empty():
		return []

	var tier_count = int(clamp(ceil(float(max(0, wave_index + 10)) / 30.0), 0, tiers.size()))
	var shop_items := []

	for tier_index in range(tier_count):
		var tier_entries = tiers[tier_index]
		if typeof(tier_entries) != TYPE_ARRAY:
			continue
		for item_entry in tier_entries:
			if typeof(item_entry) != TYPE_DICTIONARY:
				continue

			var item_id = String(item_entry.get("id", "")).strip_edges().to_lower()
			if item_id.empty():
				continue
			var cost_mult = float(item_entry.get("cost_mult", 1.0))
			shop_items.append({
				"id": item_id,
				"label": String(item_entry.get("label", _title_case_id(item_id))),
				"enabled": true,
				"cost": int(round(float(base_cost) * cost_mult)),
				"icon": String(item_entry.get("icon", item_id)).strip_edges().to_lower(),
				"kind": "shop",
				"usage": String(item_entry.get("usage", "consumable")),
				"effect_key": String(item_entry.get("effect_key", "")),
				"target_hint": String(item_entry.get("target_hint", "self_party_single")),
				"trigger_hint": String(item_entry.get("trigger_hint", "on_use")),
			})

	return shop_items

func _ensure_catalog_loaded() -> void:
	if _catalog_loaded:
		return
	_catalog_loaded = true
	_catalog = {}
	_catalog_error = "catalog-not-loaded"

	var file = File.new()
	if file.open(ITEM_MODEL_CATALOG_PATH, File.READ) != OK:
		_catalog_error = "catalog-open-failed"
		return
	var parsed = JSON.parse(file.get_as_text())
	file.close()
	if parsed.error != OK or typeof(parsed.result) != TYPE_DICTIONARY:
		_catalog_error = "catalog-parse-failed"
		return

	if typeof(parsed.result.get("free_reward_defaults", null)) != TYPE_ARRAY:
		_catalog_error = "catalog-missing-free-reward-defaults"
		return
	if typeof(parsed.result.get("shop_progression_tiers", null)) != TYPE_ARRAY:
		_catalog_error = "catalog-missing-shop-progression-tiers"
		return

	_catalog = parsed.result
	_catalog_error = ""

func _title_case_id(value: String) -> String:
	var words = value.strip_edges().split("_", false)
	for i in range(words.size()):
		var word = String(words[i])
		if word.empty():
			continue
		words[i] = word.substr(0, 1).to_upper() + word.substr(1).to_lower()
	return " ".join(words)
