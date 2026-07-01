#!/usr/bin/env python3
import argparse
import json
import re
from datetime import datetime
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[1]
ASSET_LIST_FILE = Path(__file__).resolve().with_name("minimal-asset-list.json")
DATA_DIR = REPO_ROOT / "godot-port" / "godot-minimal-assets" / "data"
FIXTURE_DIR = REPO_ROOT / "godot-port" / "data" / "fixtures"

SPECIES_CATALOG_FILE = DATA_DIR / "species-catalog.v1.json"
MOVES_CATALOG_FILE = DATA_DIR / "moves-catalog.v1.json"
SPECIES_FIXTURE_FILE = FIXTURE_DIR / "species-catalog.v1.fixture.json"
MOVES_FIXTURE_FILE = FIXTURE_DIR / "moves-catalog.v1.fixture.json"

TYPE_VALUES = {
    "NORMAL", "FIRE", "WATER", "ELECTRIC", "GRASS", "ICE", "FIGHTING", "POISON", "GROUND", "FLYING",
    "PSYCHIC", "BUG", "ROCK", "GHOST", "DRAGON", "DARK", "STEEL", "FAIRY", "UNKNOWN",
}
MOVE_CATEGORY_VALUES = {"PHYSICAL", "SPECIAL", "STATUS"}
GROWTH_RATE_VALUES = {"ERRATIC", "FAST", "MEDIUM_FAST", "MEDIUM_SLOW", "SLOW", "FLUCTUATING"}


def _coerce_str_list(values: Any, field_name: str, errors: list[str]) -> list[str]:
    if values is None:
        return []
    if not isinstance(values, list):
        errors.append(f"{field_name}: must be an array")
        return []

    out: list[str] = []
    for index, item in enumerate(values):
        if isinstance(item, str):
            out.append(item)
        elif isinstance(item, (int, float)):
            out.append(str(int(item)))
        else:
            errors.append(f"{field_name}[{index}]: must be a string or number")
    return out


def _load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def _is_int(value: Any) -> bool:
    return isinstance(value, int) and not isinstance(value, bool)


def _validate_iso_datetime(value: Any, context: str, errors: list[str]) -> None:
    if not isinstance(value, str):
        errors.append(f"{context}: expected string date-time")
        return
    try:
        normalized = value.replace("Z", "+00:00")
        datetime.fromisoformat(normalized)
    except ValueError:
        errors.append(f"{context}: invalid ISO date-time '{value}'")


def _require_keys(obj: dict[str, Any], required: set[str], context: str, errors: list[str]) -> None:
    for key in sorted(required):
        if key not in obj:
            errors.append(f"{context}: missing required key '{key}'")


def _reject_unknown_keys(obj: dict[str, Any], allowed: set[str], context: str, errors: list[str]) -> None:
    for key in sorted(obj.keys()):
        if key not in allowed:
            errors.append(f"{context}: unexpected key '{key}'")


def _validate_int_range(value: Any, min_value: int, max_value: int, context: str, errors: list[str]) -> None:
    if not _is_int(value):
        errors.append(f"{context}: expected integer")
        return
    if value < min_value or value > max_value:
        errors.append(f"{context}: expected {min_value}..{max_value}, got {value}")


def _validate_species_item(item: Any, index: int, errors: list[str]) -> None:
    context = f"species.items[{index}]"
    if not isinstance(item, dict):
        errors.append(f"{context}: expected object")
        return

    required = {"schema_version", "species_id", "name", "types", "base_stats"}
    allowed = required | {
        "pokedex_number", "catch_rate", "base_friendship", "base_exp", "growth_rate", "source",
    }
    _require_keys(item, required, context, errors)
    _reject_unknown_keys(item, allowed, context, errors)

    if item.get("schema_version") != 1:
        errors.append(f"{context}.schema_version: expected 1")

    species_id = item.get("species_id")
    if not isinstance(species_id, str) or not re.fullmatch(r"^[A-Z0-9_]+$", species_id):
        errors.append(f"{context}.species_id: expected uppercase enum string")

    name = item.get("name")
    if not isinstance(name, str) or not name.strip():
        errors.append(f"{context}.name: expected non-empty string")

    types = item.get("types")
    if not isinstance(types, list):
        errors.append(f"{context}.types: expected array")
    else:
        if len(types) < 1 or len(types) > 2:
            errors.append(f"{context}.types: expected 1..2 entries")
        for type_index, type_name in enumerate(types):
            if type_name not in TYPE_VALUES:
                errors.append(f"{context}.types[{type_index}]: invalid type '{type_name}'")

    base_stats = item.get("base_stats")
    if not isinstance(base_stats, dict):
        errors.append(f"{context}.base_stats: expected object")
    else:
        stat_keys = {"hp", "atk", "def", "sp_atk", "sp_def", "spd"}
        _require_keys(base_stats, stat_keys, f"{context}.base_stats", errors)
        _reject_unknown_keys(base_stats, stat_keys, f"{context}.base_stats", errors)
        for stat_name in sorted(stat_keys):
            if stat_name in base_stats:
                _validate_int_range(base_stats[stat_name], 1, 255, f"{context}.base_stats.{stat_name}", errors)

    if "pokedex_number" in item:
        _validate_int_range(item["pokedex_number"], 1, 99999, f"{context}.pokedex_number", errors)
    if "catch_rate" in item:
        _validate_int_range(item["catch_rate"], 1, 255, f"{context}.catch_rate", errors)
    if "base_friendship" in item:
        _validate_int_range(item["base_friendship"], 0, 255, f"{context}.base_friendship", errors)
    if "base_exp" in item:
        _validate_int_range(item["base_exp"], 1, 99999, f"{context}.base_exp", errors)
    if "growth_rate" in item and item["growth_rate"] not in GROWTH_RATE_VALUES:
        errors.append(f"{context}.growth_rate: invalid value '{item['growth_rate']}'")

    if "source" in item:
        source = item["source"]
        source_context = f"{context}.source"
        if not isinstance(source, dict):
            errors.append(f"{source_context}: expected object")
        else:
            source_required = {"repo", "species_enum_name"}
            source_allowed = source_required | {"generation", "form_key"}
            _require_keys(source, source_required, source_context, errors)
            _reject_unknown_keys(source, source_allowed, source_context, errors)

            if source.get("repo") != "dependency/pokerogue":
                errors.append(f"{source_context}.repo: expected 'dependency/pokerogue'")

            species_enum_name = source.get("species_enum_name")
            if not isinstance(species_enum_name, str) or not re.fullmatch(r"^[A-Z0-9_]+$", species_enum_name):
                errors.append(f"{source_context}.species_enum_name: expected uppercase enum string")

            if "generation" in source:
                _validate_int_range(source["generation"], 1, 9, f"{source_context}.generation", errors)


def _validate_move_item(item: Any, index: int, errors: list[str]) -> None:
    context = f"moves.items[{index}]"
    if not isinstance(item, dict):
        errors.append(f"{context}: expected object")
        return

    required = {"schema_version", "move_id", "name", "type", "category", "power"}
    allowed = required | {"accuracy", "pp", "priority", "source"}
    _require_keys(item, required, context, errors)
    _reject_unknown_keys(item, allowed, context, errors)

    if item.get("schema_version") != 1:
        errors.append(f"{context}.schema_version: expected 1")

    move_id = item.get("move_id")
    if not isinstance(move_id, str) or not re.fullmatch(r"^[A-Z0-9_]+$", move_id):
        errors.append(f"{context}.move_id: expected uppercase enum string")

    name = item.get("name")
    if not isinstance(name, str) or not name.strip():
        errors.append(f"{context}.name: expected non-empty string")

    if item.get("type") not in TYPE_VALUES:
        errors.append(f"{context}.type: invalid value '{item.get('type')}'")

    if item.get("category") not in MOVE_CATEGORY_VALUES:
        errors.append(f"{context}.category: invalid value '{item.get('category')}'")

    _validate_int_range(item.get("power"), 0, 999, f"{context}.power", errors)

    if "accuracy" in item:
        _validate_int_range(item["accuracy"], -1, 100, f"{context}.accuracy", errors)
    if "pp" in item:
        _validate_int_range(item["pp"], 1, 64, f"{context}.pp", errors)
    if "priority" in item:
        _validate_int_range(item["priority"], -10, 10, f"{context}.priority", errors)

    if "source" in item:
        source = item["source"]
        source_context = f"{context}.source"
        if not isinstance(source, dict):
            errors.append(f"{source_context}: expected object")
        else:
            source_required = {"repo", "move_enum_name"}
            source_allowed = source_required | {"generation"}
            _require_keys(source, source_required, source_context, errors)
            _reject_unknown_keys(source, source_allowed, source_context, errors)

            if source.get("repo") != "dependency/pokerogue":
                errors.append(f"{source_context}.repo: expected 'dependency/pokerogue'")

            move_enum_name = source.get("move_enum_name")
            if not isinstance(move_enum_name, str) or not re.fullmatch(r"^[A-Z0-9_]+$", move_enum_name):
                errors.append(f"{source_context}.move_enum_name: expected uppercase enum string")

            if "generation" in source:
                _validate_int_range(source["generation"], 1, 9, f"{source_context}.generation", errors)


def _validate_catalog_wrapper(payload: Any, context: str, errors: list[str]) -> list[Any]:
    if not isinstance(payload, dict):
        errors.append(f"{context}: expected object")
        return []

    required = {"schema_version", "generated_from", "generated_at", "items"}
    _require_keys(payload, required, context, errors)
    _reject_unknown_keys(payload, required, context, errors)

    if payload.get("schema_version") != 1:
        errors.append(f"{context}.schema_version: expected 1")

    if payload.get("generated_from") != "dependency/pokerogue":
        errors.append(f"{context}.generated_from: expected 'dependency/pokerogue'")

    _validate_iso_datetime(payload.get("generated_at"), f"{context}.generated_at", errors)

    items = payload.get("items")
    if not isinstance(items, list):
        errors.append(f"{context}.items: expected array")
        return []

    return items


def _validate_selector_alignment(species_items: list[Any], move_items: list[Any], errors: list[str]) -> None:
    config = _load_json(ASSET_LIST_FILE)
    if not isinstance(config, dict):
        errors.append("minimal-asset-list.json: expected object format for selector alignment checks")
        return

    selector_errors: list[str] = []
    pokemon_selectors = _coerce_str_list(config.get("pokemon", []), "pokemon", selector_errors)
    attack_selectors = _coerce_str_list(config.get("attacks", []), "attacks", selector_errors)
    errors.extend([f"selector.{msg}" for msg in selector_errors])

    selected_pokedex_numbers: set[int] = set()
    for value in pokemon_selectors:
        try:
            selected_pokedex_numbers.add(int(value))
        except ValueError:
            errors.append(f"selector.pokemon: invalid dex number '{value}'")

    selected_move_ids = {value.strip().upper().replace("-", "_").replace(" ", "_") for value in attack_selectors if value.strip()}

    species_by_dex: dict[int, int] = {}
    for item in species_items:
        if isinstance(item, dict) and _is_int(item.get("pokedex_number")):
            dex_num = item["pokedex_number"]
            species_by_dex[dex_num] = species_by_dex.get(dex_num, 0) + 1

    for dex_num in sorted(selected_pokedex_numbers):
        count = species_by_dex.get(dex_num, 0)
        if count == 0:
            errors.append(f"selector.pokemon: selected id {dex_num} produced no species entry")
        elif count > 1:
            errors.append(f"selector.pokemon: selected id {dex_num} produced {count} species entries")

    exported_species_set = {dex for dex, count in species_by_dex.items() if count > 0}
    extra_species = sorted(exported_species_set - selected_pokedex_numbers)
    if extra_species:
        errors.append(f"selector.pokemon: exported unexpected species ids {extra_species}")

    move_by_id: dict[str, int] = {}
    for item in move_items:
        if isinstance(item, dict) and isinstance(item.get("move_id"), str):
            move_id = item["move_id"]
            move_by_id[move_id] = move_by_id.get(move_id, 0) + 1

    for move_id in sorted(selected_move_ids):
        count = move_by_id.get(move_id, 0)
        if count == 0:
            errors.append(f"selector.attacks: selected attack {move_id} produced no move entry")
        elif count > 1:
            errors.append(f"selector.attacks: selected attack {move_id} produced {count} move entries")

    exported_move_set = {move_id for move_id, count in move_by_id.items() if count > 0}
    extra_moves = sorted(exported_move_set - selected_move_ids)
    if extra_moves:
        errors.append(f"selector.attacks: exported unexpected move ids {extra_moves}")


def _refresh_fixtures(species_payload: Any, moves_payload: Any) -> None:
    FIXTURE_DIR.mkdir(parents=True, exist_ok=True)
    SPECIES_FIXTURE_FILE.write_text(json.dumps(species_payload, indent=2), encoding="utf-8")
    MOVES_FIXTURE_FILE.write_text(json.dumps(moves_payload, indent=2), encoding="utf-8")
    print(f"Updated fixture: {SPECIES_FIXTURE_FILE}")
    print(f"Updated fixture: {MOVES_FIXTURE_FILE}")


def _normalized_catalog_for_compare(payload: Any) -> Any:
    if not isinstance(payload, dict):
        return payload
    normalized = dict(payload)
    # generated_at is expected to change per run; exclude it from fixture drift checks.
    normalized.pop("generated_at", None)
    return normalized


def _validate_fixture_match(species_payload: Any, moves_payload: Any, errors: list[str]) -> None:
    if not SPECIES_FIXTURE_FILE.exists() or not MOVES_FIXTURE_FILE.exists():
        errors.append("fixtures: missing fixture files; run validator with --refresh-fixtures")
        return

    species_fixture = _load_json(SPECIES_FIXTURE_FILE)
    moves_fixture = _load_json(MOVES_FIXTURE_FILE)

    if _normalized_catalog_for_compare(species_payload) != _normalized_catalog_for_compare(species_fixture):
        errors.append("fixtures: species catalog differs from fixture; run with --refresh-fixtures after intentional changes")

    if _normalized_catalog_for_compare(moves_payload) != _normalized_catalog_for_compare(moves_fixture):
        errors.append("fixtures: moves catalog differs from fixture; run with --refresh-fixtures after intentional changes")


def main() -> None:
    parser = argparse.ArgumentParser(description="Validate minimal species/move data catalogs and fixture snapshots")
    parser.add_argument("--refresh-fixtures", action="store_true", help="Overwrite fixture files with current catalog outputs")
    args = parser.parse_args()

    errors: list[str] = []

    if not SPECIES_CATALOG_FILE.exists() or not MOVES_CATALOG_FILE.exists():
        missing = []
        if not SPECIES_CATALOG_FILE.exists():
            missing.append(str(SPECIES_CATALOG_FILE))
        if not MOVES_CATALOG_FILE.exists():
            missing.append(str(MOVES_CATALOG_FILE))
        raise SystemExit("Missing catalog files. Run export-data first:\n" + "\n".join(missing))

    species_payload = _load_json(SPECIES_CATALOG_FILE)
    moves_payload = _load_json(MOVES_CATALOG_FILE)

    species_items = _validate_catalog_wrapper(species_payload, "species_catalog", errors)
    moves_items = _validate_catalog_wrapper(moves_payload, "moves_catalog", errors)

    for index, item in enumerate(species_items):
        _validate_species_item(item, index, errors)

    for index, item in enumerate(moves_items):
        _validate_move_item(item, index, errors)

    _validate_selector_alignment(species_items, moves_items, errors)

    if args.refresh_fixtures:
        _refresh_fixtures(species_payload, moves_payload)
    else:
        _validate_fixture_match(species_payload, moves_payload, errors)

    if errors:
        print("Validation failed:")
        for entry in errors:
            print(f"- {entry}")
        raise SystemExit(1)

    print("Validation passed: catalog schemas, selector alignment, and fixture checks are all valid.")


if __name__ == "__main__":
    main()
