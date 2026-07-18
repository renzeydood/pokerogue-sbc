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
POKEROGUE_ROOT = REPO_ROOT / "dependency" / "pokerogue"


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


def main() -> None:
    parser = argparse.ArgumentParser(description="Export minimal Pokemon/move data catalogs from pokerogue dependency selectors")
    parser.parse_args()

    pokerogue_root = POKEROGUE_ROOT
    config = json.loads(ASSET_LIST_FILE.read_text(encoding="utf-8"))
    if not isinstance(config, dict):
        raise ValueError("minimal data export requires object-style minimal-asset-list.json with pokemon/attacks fields")

    pokemon_ids = _coerce_str_list(config.get("pokemon", []), "pokemon")
    attacks, attack_count_selector = _parse_attack_selector(config.get("attacks", []))

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

    generated_at = datetime.now(timezone.utc).isoformat()

    species_catalog = {
        "schema_version": 3,
        "generated_from": "dependency/pokerogue",
        "generated_at": generated_at,
        "items": species_items,
    }

    moves_catalog = {
        "schema_version": 1,
        "generated_from": "dependency/pokerogue",
        "generated_at": generated_at,
        "items": move_items,
    }

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    species_out = OUT_DIR / "species-catalog.v3.json"
    moves_out = OUT_DIR / "moves-catalog.v1.json"

    species_out.write_text(json.dumps(species_catalog, indent=2), encoding="utf-8")
    moves_out.write_text(json.dumps(moves_catalog, indent=2), encoding="utf-8")

    print(f"Exported {len(species_items)} species entries -> {species_out}")
    print(f"Exported {len(move_items)} move entries -> {moves_out}")


if __name__ == "__main__":
    main()
