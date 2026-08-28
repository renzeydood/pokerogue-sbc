#!/usr/bin/env python3
import argparse
import json
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[1]
ASSET_LIST_FILE = Path(__file__).resolve().with_name("minimal-asset-list.json")
OUT_DIR = REPO_ROOT / "godot-port" / "godot-minimal-assets" / "data"
ROUTE_GRAPH_OUT_FILE = REPO_ROOT / "godot-port" / "data" / "biome-route-graph.v1.json"
ITEM_MODEL_OUT_FILE = REPO_ROOT / "godot-port" / "data" / "item-model-catalog.v1.json"
ITEM_EFFECTS_OUT_FILE = REPO_ROOT / "godot-port" / "data" / "item-effects-catalog.v1.json"
POKEROGUE_ROOT = REPO_ROOT / "dependency" / "pokerogue"
POKEROGUE_BIOMES_DIR = POKEROGUE_ROOT / "src" / "data" / "balance" / "biomes"

LOCAL_BIOME_ID_ALIASES = {
    "mountain": "mountains",
    "mountains": "mountains",
}


def _coerce_str_list(values: Any, field_name: str) -> list[str]:
    if values is None:
        return []
    if not isinstance(values, list):
        raise ValueError(f"'{field_name}' must be a JSON array")
    out: list[str] = []
    for item in values:
        if isinstance(item, (int, float)):
            out.append(str(int(item)))
        elif isinstance(item, str):
            out.append(item)
        else:
            raise ValueError(f"'{field_name}' entries must be strings or numbers")
    return out


def _try_parse_int(value: Any) -> int | None:
    if isinstance(value, bool):
        return None
    if isinstance(value, int):
        return value
    if isinstance(value, float):
        return int(value)
    if isinstance(value, str):
        stripped = value.strip()
        if stripped.isdigit():
            return int(stripped)
    return None


def _parse_attack_selector(values: Any) -> tuple[list[str], int | None]:
    """
    Backward compatible selector modes:
    - attacks: ["tackle", "ember"] => explicit move selectors
    - attacks: [4] or attacks: 4 => derive first 4 level-up moves for each selected species
    """
    if values is None:
        return [], None

    single_numeric = _try_parse_int(values)
    if single_numeric is not None:
        return [], max(0, single_numeric)

    if not isinstance(values, list):
        raise ValueError("'attacks' must be a JSON array, number, or null")

    if len(values) == 1:
        list_numeric = _try_parse_int(values[0])
        if list_numeric is not None:
            return [], max(0, list_numeric)

    return _coerce_str_list(values, "attacks"), None


def _normalize_biome_slug(value: str) -> str:
    normalized = value.strip().lower().replace("_", "-").replace(" ", "-")
    return LOCAL_BIOME_ID_ALIASES.get(normalized, normalized)


def _slug_to_enum_name(value: str) -> str:
    return value.strip().upper().replace("-", "_").replace(" ", "_")


def _enum_name_to_title(value: str) -> str:
    return value.replace("_", " ").title()


def _parse_ts_enum(enum_file: Path, enum_name: str) -> dict[str, int]:
    text = enum_file.read_text(encoding="utf-8")
    enum_match = re.search(rf"export enum {enum_name}\s*\{{(?P<body>[\s\S]*?)\n\}}", text)
    if not enum_match:
        raise ValueError(f"Could not parse enum {enum_name} from {enum_file}")

    body = enum_match.group("body")
    entries: dict[str, int] = {}
    current = -1

    for raw_line in body.splitlines():
        line = raw_line.split("//", 1)[0].strip().rstrip(",")
        if not line or line.startswith("/**") or line.startswith("*"):
            continue
        if "=" in line:
            name, value = [s.strip() for s in line.split("=", 1)]
            if not name.isidentifier() and "_" not in name:
                continue
            current = int(value)
            entries[name] = current
        else:
            if not re.match(r"^[A-Z0-9_]+$", line):
                continue
            current += 1
            entries[line] = current

    return entries


def _extract_species_fields(species_body: str) -> dict[str, Any]:
    def field_num(name: str, default: int | None = None) -> int | None:
        match = re.search(rf"\b{name}:\s*(-?\d+(?:\.\d+)?)", species_body)
        if match:
            value = match.group(1)
            return int(float(value))
        return default

    type1_match = re.search(r"\btype1:\s*PokemonType\.([A-Z_]+)", species_body)
    if not type1_match:
        raise ValueError("Missing type1 in species block")

    type2_match = re.search(r"\btype2:\s*PokemonType\.([A-Z_]+)", species_body)
    types = [type1_match.group(1)]
    if type2_match:
        types.append(type2_match.group(1))

    growth_rate_match = re.search(r"\bgrowthRate:\s*GrowthRate\.([A-Z_]+)", species_body)

    return {
        "types": types,
        "base_stats": {
            "hp": field_num("baseHp", 1),
            "atk": field_num("baseAtk", 1),
            "def": field_num("baseDef", 1),
            "sp_atk": field_num("baseSpatk", 1),
            "sp_def": field_num("baseSpdef", 1),
            "spd": field_num("baseSpd", 1),
        },
        "catch_rate": field_num("catchRate"),
        "base_friendship": field_num("baseFriendship"),
        "base_exp": field_num("baseExp"),
        "growth_rate": growth_rate_match.group(1) if growth_rate_match else None,
        "generation": field_num("generation"),
        "level_moves": [],
    }


def _extract_array_literal(source: str, field_name: str) -> str | None:
    marker = f"{field_name}:"
    marker_index = source.find(marker)
    if marker_index < 0:
        return None

    array_start = source.find("[", marker_index)
    if array_start < 0:
        return None

    depth = 0
    for index in range(array_start, len(source)):
        char = source[index]
        if char == "[":
            depth += 1
        elif char == "]":
            depth -= 1
            if depth == 0:
                return source[array_start + 1:index]

    return None


def _extract_balanced_literal(source: str, start_index: int, open_char: str, close_char: str) -> str | None:
    depth = 0
    for index in range(start_index, len(source)):
        char = source[index]
        if char == open_char:
            depth += 1
        elif char == close_char:
            depth -= 1
            if depth == 0:
                return source[start_index : index + 1]
    return None


def _extract_shop_progression_tiers(modifier_type_ts: str) -> list[list[dict[str, Any]]]:
    marker = "const options = ["
    marker_index = modifier_type_ts.find(marker)
    if marker_index < 0:
        raise ValueError("Could not find shop options array in modifier-type.ts")

    list_start = modifier_type_ts.find("[", marker_index)
    if list_start < 0:
        raise ValueError("Could not locate opening '[' for shop options array")

    options_literal = _extract_balanced_literal(modifier_type_ts, list_start, "[", "]")
    if options_literal is None:
        raise ValueError("Could not parse balanced shop options array")

    tiers: list[list[dict[str, Any]]] = []
    depth = 0
    tier_start = -1

    for index, char in enumerate(options_literal):
        if char == "[":
            depth += 1
            if depth == 2:
                tier_start = index
        elif char == "]":
            if depth == 2 and tier_start >= 0:
                tier_literal = options_literal[tier_start : index + 1]
                tier_items: list[dict[str, Any]] = []
                for match in re.finditer(
                    r"new\s+ModifierTypeOption\(modifierTypeInitObj\.([A-Z0-9_]+)\(\),\s*0,\s*baseCost(?:\s*\*\s*([0-9.]+))?\)",
                    tier_literal,
                ):
                    modifier_id = match.group(1)
                    multiplier = float(match.group(2)) if match.group(2) is not None else 1.0
                    item_id = modifier_id.strip().lower()
                    tier_items.append(
                        {
                            "modifier_id": modifier_id,
                            "id": item_id,
                            "label": _enum_name_to_title(modifier_id),
                            "icon": item_id,
                            "cost_mult": multiplier,
                        }
                    )

                if tier_items:
                    tiers.append(tier_items)
                tier_start = -1
            depth -= 1

    if not tiers:
        raise ValueError("Parsed shop options array but found no tier entries")

    return tiers


def _normalize_item_selector_token(value: str) -> str:
    return value.strip().upper().replace("-", "_")


def _build_item_effect_metadata(modifier_id: str, item_id: str, usage: str) -> dict[str, Any]:
    effect_by_modifier = {
        "POTION": {
            "effect_key": "effect.heal.hp_flat_20",
            "target_hint": "self_party_single",
            "trigger_hint": "on_use",
            "effect_type": "heal_hp_flat",
            "params": {"amount": 20},
        },
        "SUPER_POTION": {
            "effect_key": "effect.heal.hp_flat_50",
            "target_hint": "self_party_single",
            "trigger_hint": "on_use",
            "effect_type": "heal_hp_flat",
            "params": {"amount": 50},
        },
        "HYPER_POTION": {
            "effect_key": "effect.heal.hp_flat_200",
            "target_hint": "self_party_single",
            "trigger_hint": "on_use",
            "effect_type": "heal_hp_flat",
            "params": {"amount": 200},
        },
        "MAX_POTION": {
            "effect_key": "effect.heal.hp_full",
            "target_hint": "self_party_single",
            "trigger_hint": "on_use",
            "effect_type": "heal_hp_percent",
            "params": {"percent": 100},
        },
        "FULL_RESTORE": {
            "effect_key": "effect.heal.hp_full_and_status",
            "target_hint": "self_party_single",
            "trigger_hint": "on_use",
            "effect_type": "heal_hp_and_status",
            "params": {"percent": 100, "heal_status": True},
        },
        "REVIVE": {
            "effect_key": "effect.revive.hp_percent_50",
            "target_hint": "self_party_single",
            "trigger_hint": "on_use",
            "effect_type": "revive",
            "params": {"percent": 50},
        },
        "MAX_REVIVE": {
            "effect_key": "effect.revive.hp_percent_100",
            "target_hint": "self_party_single",
            "trigger_hint": "on_use",
            "effect_type": "revive",
            "params": {"percent": 100},
        },
        "SACRED_ASH": {
            "effect_key": "effect.revive.party_full",
            "target_hint": "self_party_all",
            "trigger_hint": "on_use",
            "effect_type": "party_revive",
            "params": {"percent": 100},
        },
        "FULL_HEAL": {
            "effect_key": "effect.heal.status_clear",
            "target_hint": "self_party_single",
            "trigger_hint": "on_use",
            "effect_type": "heal_status",
            "params": {},
        },
        "ETHER": {
            "effect_key": "effect.pp.single_restore_10",
            "target_hint": "self_party_single_move",
            "trigger_hint": "on_use",
            "effect_type": "restore_pp_single",
            "params": {"amount": 10},
        },
        "MAX_ETHER": {
            "effect_key": "effect.pp.single_restore_full",
            "target_hint": "self_party_single_move",
            "trigger_hint": "on_use",
            "effect_type": "restore_pp_single",
            "params": {"amount": -1},
        },
        "ELIXIR": {
            "effect_key": "effect.pp.all_restore_10",
            "target_hint": "self_party_single",
            "trigger_hint": "on_use",
            "effect_type": "restore_pp_all",
            "params": {"amount": 10},
        },
        "MAX_ELIXIR": {
            "effect_key": "effect.pp.all_restore_full",
            "target_hint": "self_party_single",
            "trigger_hint": "on_use",
            "effect_type": "restore_pp_all",
            "params": {"amount": -1},
        },
        "ORAN_BERRY": {
            "effect_key": "effect.held.low_hp_heal_flat_10",
            "target_hint": "holder",
            "trigger_hint": "on_low_hp",
            "effect_type": "held_low_hp_heal",
            "params": {"amount": 10},
            "max_stack": 2,
        },
        "SHELL_BELL": {
            "effect_key": "effect.held.hit_heal_fraction",
            "target_hint": "holder",
            "trigger_hint": "on_hit",
            "effect_type": "held_on_hit_heal",
            "params": {"fraction": "1/8"},
            "max_stack": 4,
        },
        "LEFTOVERS": {
            "effect_key": "effect.held.turn_heal_fraction",
            "target_hint": "holder",
            "trigger_hint": "turn_end",
            "effect_type": "held_turn_heal",
            "params": {"fraction": "1/16"},
            "max_stack": 4,
        },
    }

    normalized_modifier = _normalize_item_selector_token(modifier_id)
    base = effect_by_modifier.get(normalized_modifier)
    if base is not None:
        return {
            "usage": usage,
            "effect_key": base["effect_key"],
            "target_hint": base["target_hint"],
            "trigger_hint": base["trigger_hint"],
            "effect_type": base["effect_type"],
            "effect_params": base["params"],
            "max_stack": int(base.get("max_stack", 1)),
        }

    if usage == "held":
        return {
            "usage": usage,
            "effect_key": f"effect.held.todo.{item_id}",
            "target_hint": "holder",
            "trigger_hint": "passive",
            "effect_type": "todo_held_effect",
            "effect_params": {},
            "max_stack": 1,
        }

    return {
        "usage": usage,
        "effect_key": f"effect.use.todo.{item_id}",
        "target_hint": "self_party_single",
        "trigger_hint": "on_use",
        "effect_type": "todo_use_effect",
        "effect_params": {},
        "max_stack": 1,
    }


def _annotate_item_contract_entries(entries: list[dict[str, Any]], default_usage: str) -> list[dict[str, Any]]:
    annotated: list[dict[str, Any]] = []
    for entry in entries:
        modifier_id = str(entry.get("modifier_id", "")).strip()
        item_id = str(entry.get("id", "")).strip().lower()
        if not item_id:
            continue
        usage = str(entry.get("usage", default_usage)).strip().lower() or default_usage
        metadata = _build_item_effect_metadata(modifier_id, item_id, usage)
        enriched = dict(entry)
        enriched["usage"] = metadata["usage"]
        enriched["effect_key"] = metadata["effect_key"]
        enriched["target_hint"] = metadata["target_hint"]
        enriched["trigger_hint"] = metadata["trigger_hint"]
        enriched["effect_type"] = metadata["effect_type"]
        enriched["effect_params"] = metadata["effect_params"]
        enriched["max_stack"] = metadata["max_stack"]
        annotated.append(enriched)
    return annotated


def _build_item_effects_catalog(generated_at: str, item_model_catalog: dict[str, Any]) -> dict[str, Any]:
    effect_index: dict[str, dict[str, Any]] = {}

    free_defaults = item_model_catalog.get("free_reward_defaults", [])
    if isinstance(free_defaults, list):
        for entry in free_defaults:
            if not isinstance(entry, dict):
                continue
            effect_key = str(entry.get("effect_key", "")).strip()
            if not effect_key:
                continue
            effect = effect_index.setdefault(
                effect_key,
                {
                    "effect_key": effect_key,
                    "usage": str(entry.get("usage", "consumable")),
                    "effect_type": str(entry.get("effect_type", "todo")),
                    "target_hint": str(entry.get("target_hint", "self_party_single")),
                    "trigger_hint": str(entry.get("trigger_hint", "on_use")),
                    "params": entry.get("effect_params", {}),
                    "max_stack": int(entry.get("max_stack", 1)),
                    "source_item_ids": [],
                },
            )
            item_id = str(entry.get("id", "")).strip().lower()
            if item_id and item_id not in effect["source_item_ids"]:
                effect["source_item_ids"].append(item_id)

    shop_tiers = item_model_catalog.get("shop_progression_tiers", [])
    if isinstance(shop_tiers, list):
        for tier_entries in shop_tiers:
            if not isinstance(tier_entries, list):
                continue
            for entry in tier_entries:
                if not isinstance(entry, dict):
                    continue
                effect_key = str(entry.get("effect_key", "")).strip()
                if not effect_key:
                    continue
                effect = effect_index.setdefault(
                    effect_key,
                    {
                        "effect_key": effect_key,
                        "usage": str(entry.get("usage", "consumable")),
                        "effect_type": str(entry.get("effect_type", "todo")),
                        "target_hint": str(entry.get("target_hint", "self_party_single")),
                        "trigger_hint": str(entry.get("trigger_hint", "on_use")),
                        "params": entry.get("effect_params", {}),
                        "max_stack": int(entry.get("max_stack", 1)),
                        "source_item_ids": [],
                    },
                )
                item_id = str(entry.get("id", "")).strip().lower()
                if item_id and item_id not in effect["source_item_ids"]:
                    effect["source_item_ids"].append(item_id)

    effect_items = [effect_index[key] for key in sorted(effect_index.keys())]

    return {
        "schema_version": 1,
        "generated_from": "godot-port/data/item-model-catalog.v1.json",
        "generated_at": generated_at,
        "items": effect_items,
    }


def _build_item_model_catalog(generated_at: str, modifier_type_ts: str, selected_items: list[str] | None = None) -> dict[str, Any]:
    shop_tiers = _extract_shop_progression_tiers(modifier_type_ts)
    holdable_seed_items = [
        {
            "modifier_id": "ORAN_BERRY",
            "id": "oran_berry",
            "label": "Oran Berry",
            "icon": "oran_berry",
            "cost_mult": 0.6,
            "usage": "held",
        },
        {
            "modifier_id": "SHELL_BELL",
            "id": "shell_bell",
            "label": "Shell Bell",
            "icon": "shell_bell",
            "cost_mult": 1.8,
            "usage": "held",
        },
        {
            "modifier_id": "LEFTOVERS",
            "id": "leftovers",
            "label": "Leftovers",
            "icon": "leftovers",
            "cost_mult": 2.6,
            "usage": "held",
        },
    ]

    if shop_tiers:
        target_tiers = [0, min(2, len(shop_tiers) - 1), min(4, len(shop_tiers) - 1)]
        for holdable, tier_index in zip(holdable_seed_items, target_tiers):
            tier_items = shop_tiers[tier_index]
            if not any(str(item.get("id", "")).strip().lower() == holdable["id"] for item in tier_items):
                tier_items.append(holdable)

    free_reward_defaults = [
        {
            "modifier_id": "POTION",
            "id": "potion",
            "label": "Potion",
            "icon": "potion",
            "inventory_key": "potion",
            "kind": "free",
            "usage": "consumable",
        }
    ]

    selected_item_set = {
        _normalize_item_selector_token(item)
        for item in (selected_items or [])
        if item.strip()
    }

    if selected_item_set:
        matched_item_tokens: set[str] = set()

        filtered_free_reward_defaults: list[dict[str, Any]] = []
        for entry in free_reward_defaults:
            modifier_token = _normalize_item_selector_token(str(entry.get("modifier_id", "")))
            id_token = _normalize_item_selector_token(str(entry.get("id", "")))
            if modifier_token in selected_item_set or id_token in selected_item_set:
                filtered_free_reward_defaults.append(entry)
                if modifier_token:
                    matched_item_tokens.add(modifier_token)
                if id_token:
                    matched_item_tokens.add(id_token)
        free_reward_defaults = filtered_free_reward_defaults

        filtered_shop_tiers: list[list[dict[str, Any]]] = []
        for tier_entries in shop_tiers:
            filtered_tier_entries: list[dict[str, Any]] = []
            for entry in tier_entries:
                modifier_token = _normalize_item_selector_token(str(entry.get("modifier_id", "")))
                id_token = _normalize_item_selector_token(str(entry.get("id", "")))
                if modifier_token in selected_item_set or id_token in selected_item_set:
                    filtered_tier_entries.append(entry)
                    if modifier_token:
                        matched_item_tokens.add(modifier_token)
                    if id_token:
                        matched_item_tokens.add(id_token)
            if filtered_tier_entries:
                filtered_shop_tiers.append(filtered_tier_entries)
        shop_tiers = filtered_shop_tiers

        unknown_items = sorted(token for token in selected_item_set if token not in matched_item_tokens)
        for item_token in unknown_items:
            print(f"Warning: selected item '{item_token}' was not found in extracted free/shop model entries")

    free_reward_defaults = _annotate_item_contract_entries(free_reward_defaults, "consumable")
    shop_tiers = [_annotate_item_contract_entries(tier_entries, "consumable") for tier_entries in shop_tiers]

    return {
        "schema_version": 1,
        "generated_from": "dependency/pokerogue/src/modifier/modifier-type.ts#getPlayerShopModifierTypeOptionsForWave",
        "generated_at": generated_at,
        "free_reward_defaults": free_reward_defaults,
        "shop_progression_tiers": shop_tiers,
    }


def _get_field_value_kind(source: str, field_name: str) -> str | None:
    marker = f"{field_name}:"
    marker_index = source.find(marker)
    if marker_index < 0:
        return None

    index = marker_index + len(marker)
    while index < len(source) and source[index].isspace():
        index += 1
    if index >= len(source):
        return None

    if source[index] == "[":
        return "array"
    if source[index] == "{":
        return "object"
    return None


def _extract_object_literal(source: str, field_name: str) -> str | None:
    marker = f"{field_name}:"
    marker_index = source.find(marker)
    if marker_index < 0:
        return None

    object_start = source.find("{", marker_index)
    if object_start < 0:
        return None

    depth = 0
    for index in range(object_start, len(source)):
        char = source[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return source[object_start + 1:index]

    return None


def _extract_constructor_object_literals(source: str, constructor_name: str) -> list[str]:
    literals: list[str] = []
    cursor = 0

    while True:
        constructor_index = source.find(constructor_name, cursor)
        if constructor_index < 0:
            break

        object_start = source.find("{", constructor_index)
        if object_start < 0:
            break

        depth = 0
        object_end = -1
        for index in range(object_start, len(source)):
            char = source[index]
            if char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
                if depth == 0:
                    object_end = index
                    break

        if object_end < 0:
            break

        literals.append(source[object_start + 1:object_end])
        cursor = object_end + 1

    return literals


def _extract_braced_object_literals(source: str) -> list[str]:
    literals: list[str] = []
    object_start = -1
    depth = 0

    for index, char in enumerate(source):
        if char == "{":
            if depth == 0:
                object_start = index
            depth += 1
        elif char == "}":
            if depth <= 0:
                continue
            depth -= 1
            if depth == 0 and object_start >= 0:
                literals.append(source[object_start + 1:index])
                object_start = -1

    return literals


def _parse_enum_value(body: str, field_name: str, enum_prefix: str) -> str | None:
    match = re.search(rf"\b{field_name}:\s*{enum_prefix}\.([A-Z0-9_]+)", body)
    return match.group(1) if match else None


def _parse_enum_array(body: str, field_name: str, enum_prefix: str) -> list[str]:
    array_body = _extract_array_literal(body, field_name)
    if array_body is None:
        return []
    values = re.findall(rf"{enum_prefix}\.([A-Z0-9_]+)", array_body)
    return list(dict.fromkeys(values))


def _parse_string_or_null_value(body: str, field_name: str) -> str | None:
    match = re.search(rf"\b{field_name}:\s*(null|\"([^\"]*)\")", body)
    if not match:
        return None
    if match.group(1) == "null":
        return None
    return match.group(2)


def _parse_int_array_value(body: str, field_name: str) -> list[int]:
    array_body = _extract_array_literal(body, field_name)
    if array_body is None:
        return []
    values: list[int] = []
    for raw in re.findall(r"-?\d+", array_body):
        try:
            values.append(int(raw))
        except ValueError:
            continue
    return values


def _parse_evolution_condition_object(condition_body: str) -> dict[str, Any] | None:
    key = _parse_enum_value(condition_body, "key", "EvoCondKey")
    if key is None:
        return None

    condition: dict[str, Any] = {
        "key": key,
    }

    value_match = re.search(r"\bvalue:\s*(-?\d+)", condition_body)
    if value_match:
        condition["value"] = int(value_match.group(1))

    move_id = _parse_enum_value(condition_body, "move", "MoveId")
    if move_id is not None:
        condition["move_id"] = move_id

    species_id = _parse_enum_value(condition_body, "speciesCaught", "SpeciesId")
    if species_id is not None:
        condition["species_id"] = species_id

    gender = _parse_enum_value(condition_body, "gender", "Gender")
    if gender is not None:
        condition["gender"] = gender

    pokemon_type = _parse_enum_value(condition_body, "pkmnType", "PokemonType")
    if pokemon_type is not None:
        condition["pokemon_type"] = pokemon_type

    item_key = None
    item_key_match = re.search(r"\bitemKey:\s*([A-Za-z_][A-Za-z0-9_\.]+)", condition_body)
    if item_key_match:
        item_key = item_key_match.group(1).split(".")[-1].strip().upper()
    if item_key is not None:
        condition["item_key"] = item_key

    time_of_day = _parse_enum_array(condition_body, "time", "TimeOfDay")
    if time_of_day:
        condition["time_of_day"] = time_of_day

    biomes = _parse_enum_array(condition_body, "biome", "BiomeId")
    if biomes:
        condition["biomes"] = biomes

    weather = _parse_enum_array(condition_body, "weather", "WeatherType")
    if weather:
        condition["weather"] = weather

    natures = _parse_enum_array(condition_body, "nature", "Nature")
    if natures:
        condition["natures"] = natures

    condition["raw"] = " ".join(condition_body.split())
    return condition


def _parse_evolution_conditions(evolution_body: str) -> list[dict[str, Any]]:
    conditions: list[dict[str, Any]] = []
    var_kind = _get_field_value_kind(evolution_body, "condition")
    if var_kind == "array":
        conditions_array = _extract_array_literal(evolution_body, "condition")
        if conditions_array is None:
            return conditions
        for condition_body in _extract_braced_object_literals(conditions_array):
            parsed = _parse_evolution_condition_object(condition_body)
            if parsed is not None:
                conditions.append(parsed)
        return conditions

    if var_kind == "object":
        condition_object = _extract_object_literal(evolution_body, "condition")
        if condition_object is None:
            return conditions
        parsed = _parse_evolution_condition_object(condition_object)
        if parsed is not None:
            conditions.append(parsed)

    return conditions


def _parse_evolution_rules(evolutions_body: str) -> list[dict[str, Any]]:
    evolution_rules: list[dict[str, Any]] = []
    for rule_body in _extract_constructor_object_literals(evolutions_body, "new SpeciesEvolution"):
        target_species_id = _parse_enum_value(rule_body, "speciesId", "SpeciesId")
        if target_species_id is None:
            continue

        level_match = re.search(r"\blevel:\s*(\d+)", rule_body)
        min_level = int(level_match.group(1)) if level_match else 1

        item = _parse_enum_value(rule_body, "item", "EvolutionItem")
        evo_delay_levels = _parse_int_array_value(rule_body, "evoDelay")
        pre_form_key = _parse_string_or_null_value(rule_body, "preFormKey")
        evo_form_key = _parse_string_or_null_value(rule_body, "evoFormKey")
        conditions = _parse_evolution_conditions(rule_body)

        evolution_rule: dict[str, Any] = {
            "target_species_id": target_species_id,
            "min_level": max(1, min_level),
            "conditions": conditions,
        }

        if item is not None:
            evolution_rule["item"] = item
        if evo_delay_levels:
            evolution_rule["evo_delay_levels"] = evo_delay_levels
        if pre_form_key is not None:
            evolution_rule["pre_form_key"] = pre_form_key
        if evo_form_key is not None:
            evolution_rule["evo_form_key"] = evo_form_key

        evolution_rules.append(evolution_rule)

    return evolution_rules


def _first_n_unique(values: list[str], count: int) -> list[str]:
    if count <= 0:
        return []
    seen: set[str] = set()
    out: list[str] = []
    for value in values:
        if value in seen:
            continue
        seen.add(value)
        out.append(value)
        if len(out) >= count:
            break
    return out


def _extract_species_entry(species_name: str, source_files: list[Path]) -> dict[str, Any] | None:
    block_pattern = re.compile(
        rf"generation\w+SpeciesData\[SpeciesId\.{species_name}\]\s*=\s*\{{(?P<body>[\s\S]*?)\n\s*\}};",
    )
    pokemon_species_pattern = re.compile(r"species:\s*new PokemonSpecies\(\{(?P<species>[\s\S]*?)\}\),")

    for source_file in source_files:
        text = source_file.read_text(encoding="utf-8")
        block_match = block_pattern.search(text)
        if not block_match:
            continue

        body = block_match.group("body")
        species_match = pokemon_species_pattern.search(body)
        if not species_match:
            continue

        parsed = _extract_species_fields(species_match.group("species"))

        starter_match = re.search(r"\bstarter:\s*SpeciesId\.([A-Z0-9_]+)", body)
        prevolution_match = re.search(r"\bprevolution:\s*SpeciesId\.([A-Z0-9_]+)", body)
        starter_cost_match = re.search(r"\bstarterCost:\s*(\d+)", body)

        evolutions_body = _extract_array_literal(body, "evolutions")
        evolution_rules: list[dict[str, Any]] = []
        if evolutions_body is not None:
            evolution_rules = _parse_evolution_rules(evolutions_body)

        evolution_species_ids = [rule["target_species_id"] for rule in evolution_rules if "target_species_id" in rule]

        parsed["starter_species_id"] = starter_match.group(1) if starter_match else species_name
        parsed["prevolution_species_id"] = prevolution_match.group(1) if prevolution_match else None
        parsed["evolution_species_ids"] = list(dict.fromkeys(evolution_species_ids))
        parsed["evolution_rules"] = evolution_rules
        parsed["starter_cost"] = int(starter_cost_match.group(1)) if starter_cost_match else None

        level_moves_body = _extract_array_literal(body, "levelMoves")
        if level_moves_body is not None:
            parsed["level_moves"] = re.findall(r"MoveId\.([A-Z0-9_]+)", level_moves_body)
        return parsed

    return None


def _extract_move_entry(move_name: str, move_ts: str) -> dict[str, Any] | None:
    attack_pattern = re.compile(
        rf"new\s+\w+Move\(\s*MoveId\.{move_name},\s*PokemonType\.([A-Z_]+),\s*MoveCategory\.([A-Z_]+),\s*(-?\d+),\s*(-?\d+),\s*(-?\d+),\s*(-?\d+),\s*(-?\d+),\s*(-?\d+)"
    )
    attack_match = attack_pattern.search(move_ts)
    if attack_match:
        return {
            "type": attack_match.group(1),
            "category": attack_match.group(2),
            "power": int(attack_match.group(3)),
            "accuracy": int(attack_match.group(4)),
            "pp": int(attack_match.group(5)),
            "priority": int(attack_match.group(7)),
            "generation": int(attack_match.group(8)),
        }

    status_pattern = re.compile(
        rf"new\s+(?:StatusMove|SelfStatusMove)\(\s*MoveId\.{move_name},\s*PokemonType\.([A-Z_]+),\s*(-?\d+),\s*(-?\d+),\s*(-?\d+),\s*(-?\d+),\s*(-?\d+)"
    )
    status_match = status_pattern.search(move_ts)
    if status_match:
        return {
            "type": status_match.group(1),
            "category": "STATUS",
            "power": 0,
            "accuracy": int(status_match.group(2)),
            "pp": int(status_match.group(3)),
            "priority": int(status_match.group(5)),
            "generation": int(status_match.group(6)),
        }

    return None


def _extract_biome_id_from_source(source: str) -> str | None:
    match = re.search(r"\bbiomeId:\s*BiomeId\.([A-Z0-9_]+)", source)
    if not match:
        return None
    return _normalize_biome_slug(match.group(1))


def _extract_biome_links_from_source(source: str) -> list[dict[str, Any]]:
    links_body = _extract_array_literal(source, "biomeLinks")
    if links_body is None:
        return []

    links: list[dict[str, Any]] = []
    weighted_by_target: dict[str, int] = {}
    pattern = re.compile(r"\[\s*BiomeId\.([A-Z0-9_]+)\s*,\s*(\d+)\s*\]|BiomeId\.([A-Z0-9_]+)")
    for match in pattern.finditer(links_body):
        weighted_target = match.group(1)
        weighted_value = match.group(2)
        plain_target = match.group(3)

        target_enum_name = weighted_target if weighted_target is not None else plain_target
        if target_enum_name is None:
            continue
        target_biome_id = _normalize_biome_slug(target_enum_name)
        if not target_biome_id:
            continue

        weight = 1
        if weighted_value is not None:
            weight = max(1, int(weighted_value))

        weighted_by_target[target_biome_id] = weighted_by_target.get(target_biome_id, 0) + weight

    for target_biome_id, weight in weighted_by_target.items():
        links.append({
            "target_biome_id": target_biome_id,
            "weight": weight,
        })
    return links


def _load_allowed_biome_ids(config: dict[str, Any]) -> set[str]:
    arenas = _coerce_str_list(config.get("arenas", []), "arenas")
    allowed = {_normalize_biome_slug(item) for item in arenas if item.strip()}
    return {item for item in allowed if item}


def _load_biome_ids_from_local_catalog(path: Path) -> set[str]:
    if not path.exists():
        return set()
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return set()

    if not isinstance(payload, dict):
        return set()
    biomes = payload.get("biomes", {})
    if not isinstance(biomes, dict):
        return set()

    out: set[str] = set()
    for biome_id in biomes.keys():
        if not isinstance(biome_id, str):
            continue
        normalized = _normalize_biome_slug(biome_id)
        if normalized:
            out.add(normalized)
    return out


def _resolve_filtered_biome_scope(config: dict[str, Any]) -> set[str]:
    allowed = _load_allowed_biome_ids(config)

    local_pool_biomes = _load_biome_ids_from_local_catalog(REPO_ROOT / "godot-port" / "data" / "biome-wild-pools.v1.json")
    local_trainer_biomes = _load_biome_ids_from_local_catalog(REPO_ROOT / "godot-port" / "data" / "biome-trainer-rules.v1.json")

    if allowed and local_pool_biomes:
        allowed = allowed.intersection(local_pool_biomes)
    if allowed and local_trainer_biomes:
        allowed = allowed.intersection(local_trainer_biomes)

    # Keep route export usable even when local curation temporarily drifts.
    if not allowed:
        fallback_allowed = _load_allowed_biome_ids(config)
        if fallback_allowed:
            return fallback_allowed

    return allowed


def _build_biome_route_graph(config: dict[str, Any], generated_at: str) -> dict[str, Any]:
    allowed_biome_ids = _resolve_filtered_biome_scope(config)

    route_entries: dict[str, dict[str, Any]] = {}
    for biome_file in sorted(POKEROGUE_BIOMES_DIR.glob("*.ts")):
        source = biome_file.read_text(encoding="utf-8")
        biome_id = _extract_biome_id_from_source(source)
        if biome_id is None:
            continue
        if allowed_biome_ids and biome_id not in allowed_biome_ids:
            continue

        parsed_links = _extract_biome_links_from_source(source)
        filtered_links: list[dict[str, Any]] = []
        for link in parsed_links:
            target_biome_id = _normalize_biome_slug(str(link.get("target_biome_id", "")))
            if not target_biome_id:
                continue
            if allowed_biome_ids and target_biome_id not in allowed_biome_ids:
                continue
            filtered_links.append({
                "target_biome_id": target_biome_id,
                "weight": max(1, int(link.get("weight", 1))),
            })

        route_entries[biome_id] = {
            "linked_biomes": filtered_links,
        }

    for biome_id in sorted(allowed_biome_ids):
        if biome_id not in route_entries:
            route_entries[biome_id] = {"linked_biomes": []}

    default_biome_id = "grass"
    if default_biome_id not in route_entries and route_entries:
        default_biome_id = sorted(route_entries.keys())[0]

    sorted_biomes = {
        biome_id: route_entries[biome_id]
        for biome_id in sorted(route_entries.keys())
    }

    return {
        "schema_version": 1,
        "generated_from": "dependency/pokerogue",
        "generated_at": generated_at,
        "default_biome_id": default_biome_id,
        "fallback_mode": "rotation_next",
        "biomes": sorted_biomes,
    }


def _build_species_catalog(
    pokemon_ids: list[str],
    species_enum_by_value: dict[int, str],
    source_files: list[Path],
    starter_moves_count: int | None,
) -> list[dict[str, Any]]:
    items: list[dict[str, Any]] = []

    for pokemon_id in pokemon_ids:
        try:
            dex_num = int(pokemon_id)
        except ValueError:
            print(f"Warning: invalid pokemon id '{pokemon_id}', skipping")
            continue

        species_name = species_enum_by_value.get(dex_num)
        if not species_name:
            print(f"Warning: no SpeciesId enum entry for pokemon id {dex_num}, skipping")
            continue

        parsed = _extract_species_entry(species_name, source_files)
        if not parsed:
            print(f"Warning: could not find species definition for {species_name}")
            continue

        item = {
            "schema_version": 3,
            "species_id": species_name,
            "starter_species_id": parsed["starter_species_id"],
            "prevolution_species_id": parsed["prevolution_species_id"],
            "evolution_species_ids": parsed["evolution_species_ids"],
            "evolution_rules": parsed.get("evolution_rules", []),
            "pokedex_number": dex_num,
            "name": _enum_name_to_title(species_name),
            "types": parsed["types"],
            "base_stats": parsed["base_stats"],
            "source": {
                "repo": "dependency/pokerogue",
                "species_enum_name": species_name,
                "generation": parsed["generation"],
                "form_key": "DEFAULT",
            },
        }

        if parsed["catch_rate"] is not None:
            item["catch_rate"] = parsed["catch_rate"]
        if parsed["base_friendship"] is not None:
            item["base_friendship"] = parsed["base_friendship"]
        if parsed["base_exp"] is not None:
            item["base_exp"] = parsed["base_exp"]
        if parsed["growth_rate"] is not None:
            item["growth_rate"] = parsed["growth_rate"]
        if parsed["starter_cost"] is not None:
            item["starter_cost"] = parsed["starter_cost"]

        if starter_moves_count is not None and starter_moves_count > 0:
            starter_moves = _first_n_unique(parsed.get("level_moves", []), starter_moves_count)
            item["starter_moves"] = starter_moves

        items.append(item)

    return items


def _build_moves_catalog(attacks: list[str], move_enum: dict[str, int], move_ts: str) -> list[dict[str, Any]]:
    items: list[dict[str, Any]] = []

    for attack in attacks:
        move_name = _slug_to_enum_name(attack)
        if move_name not in move_enum:
            print(f"Warning: no MoveId enum entry for '{attack}' ({move_name}), skipping")
            continue

        parsed = _extract_move_entry(move_name, move_ts)
        if not parsed:
            print(f"Warning: could not parse move definition for {move_name}")
            continue

        item = {
            "schema_version": 1,
            "move_id": move_name,
            "name": _enum_name_to_title(move_name),
            "type": parsed["type"],
            "category": parsed["category"],
            # Source data may use -1 as a sentinel; normalize to 0 for stable minimal schema.
            "power": max(0, parsed["power"]),
            "source": {
                "repo": "dependency/pokerogue",
                "move_enum_name": move_name,
                "generation": parsed["generation"],
            },
        }

        item["accuracy"] = parsed["accuracy"]
        item["pp"] = parsed["pp"]
        item["priority"] = parsed["priority"]

        items.append(item)

    return items


def _parse_export_targets(raw_targets: str) -> set[str]:
    allowed = {"species", "moves", "biomes", "item-model", "all"}
    parts = {part.strip().lower() for part in raw_targets.split(",") if part.strip()}
    if not parts:
        return {"all"}
    unknown = parts - allowed
    if unknown:
        raise ValueError(f"Unknown export targets: {', '.join(sorted(unknown))}")
    if "all" in parts:
        return {"species", "moves", "biomes", "item-model"}
    return parts


def main() -> None:
    parser = argparse.ArgumentParser(description="Export minimal Pokemon/move/item model data catalogs from pokerogue dependency selectors")
    parser.add_argument(
        "--item-model",
        dest="item_model_only",
        action="store_true",
        help="Export only item model catalog (shortcut for --only item-model)",
    )
    parser.add_argument(
        "--only",
        default="all",
        help="Comma-separated export targets: species,moves,biomes,item-model (or all)",
    )
    args = parser.parse_args()
    targets = {"item-model"} if args.item_model_only else _parse_export_targets(args.only)

    pokerogue_root = POKEROGUE_ROOT
    config = json.loads(ASSET_LIST_FILE.read_text(encoding="utf-8"))
    if not isinstance(config, dict):
        raise ValueError("minimal data export requires object-style minimal-asset-list.json with pokemon/attacks fields")

    pokemon_ids = _coerce_str_list(config.get("pokemon", []), "pokemon")
    attacks, attack_count_selector = _parse_attack_selector(config.get("attacks", []))
    item_selectors = _coerce_str_list(config.get("items", []), "items")

    generated_at = datetime.now(timezone.utc).isoformat()

    if "species" in targets or "moves" in targets:
        species_enum = _parse_ts_enum(pokerogue_root / "src" / "enums" / "species-id.ts", "SpeciesId")
        species_enum_by_value = {value: key for key, value in species_enum.items()}
        move_enum = _parse_ts_enum(pokerogue_root / "src" / "enums" / "move-id.ts", "MoveId")
        species_source_files = sorted((pokerogue_root / "src" / "data" / "balance" / "species").glob("generation-*.ts"))
        move_ts = (pokerogue_root / "src" / "data" / "moves" / "move.ts").read_text(encoding="utf-8")

        species_items = _build_species_catalog(
            pokemon_ids,
            species_enum_by_value,
            species_source_files,
            attack_count_selector,
        )

        derived_attacks: set[str] = set()
        if attack_count_selector is not None and attack_count_selector > 0:
            for species_item in species_items:
                for move_id in species_item.get("starter_moves", []):
                    if isinstance(move_id, str) and move_id.strip():
                        derived_attacks.add(move_id.strip())

        combined_attacks = list(dict.fromkeys(attacks + sorted(derived_attacks)))
        move_items = _build_moves_catalog(combined_attacks, move_enum, move_ts)

        OUT_DIR.mkdir(parents=True, exist_ok=True)
        species_out = OUT_DIR / "species-catalog.v3.json"
        moves_out = OUT_DIR / "moves-catalog.v1.json"

        if "species" in targets:
            species_catalog = {
                "schema_version": 3,
                "generated_from": "dependency/pokerogue",
                "generated_at": generated_at,
                "items": species_items,
            }
            species_out.write_text(json.dumps(species_catalog, indent=2), encoding="utf-8")
            print(f"Exported {len(species_items)} species entries -> {species_out}")

        if "moves" in targets:
            moves_catalog = {
                "schema_version": 1,
                "generated_from": "dependency/pokerogue",
                "generated_at": generated_at,
                "items": move_items,
            }
            moves_out.write_text(json.dumps(moves_catalog, indent=2), encoding="utf-8")
            print(f"Exported {len(move_items)} move entries -> {moves_out}")

    if "biomes" in targets:
        biome_route_graph = _build_biome_route_graph(config, generated_at)
        ROUTE_GRAPH_OUT_FILE.parent.mkdir(parents=True, exist_ok=True)
        ROUTE_GRAPH_OUT_FILE.write_text(json.dumps(biome_route_graph, indent=2), encoding="utf-8")
        print(f"Exported {len(biome_route_graph.get('biomes', {}))} biome route entries -> {ROUTE_GRAPH_OUT_FILE}")

    if "item-model" in targets:
        modifier_type_ts = (pokerogue_root / "src" / "modifier" / "modifier-type.ts").read_text(encoding="utf-8")
        item_model_catalog = _build_item_model_catalog(generated_at, modifier_type_ts, item_selectors)
        item_effects_catalog = _build_item_effects_catalog(generated_at, item_model_catalog)
        ITEM_MODEL_OUT_FILE.parent.mkdir(parents=True, exist_ok=True)
        ITEM_MODEL_OUT_FILE.write_text(json.dumps(item_model_catalog, indent=2), encoding="utf-8")
        ITEM_EFFECTS_OUT_FILE.write_text(json.dumps(item_effects_catalog, indent=2), encoding="utf-8")
        print(f"Exported {len(item_model_catalog.get('shop_progression_tiers', []))} item model shop tiers -> {ITEM_MODEL_OUT_FILE}")
        print(f"Exported {len(item_effects_catalog.get('items', []))} item effect entries -> {ITEM_EFFECTS_OUT_FILE}")


if __name__ == "__main__":
    main()
