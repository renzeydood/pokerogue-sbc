#!/usr/bin/env python3
import argparse
import difflib
import json
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = REPO_ROOT / "godot-port" / "godot-minimal-assets" / "data"
FIXTURE_FILE = REPO_ROOT / "godot-port" / "data" / "fixtures" / "regression-prototype.v2.fixture.json"
SPECIES_CATALOG_FILE = DATA_DIR / "species-catalog.v2.json"
MOVES_CATALOG_FILE = DATA_DIR / "moves-catalog.v1.json"

EXPECTED_SPECIES_IDS = [
    "BULBASAUR",
    "IVYSAUR",
    "CHARMANDER",
    "CHARMELEON",
    "CHARIZARD",
]
EXPECTED_MOVE_IDS = ["TACKLE", "EMBER", "WATER_GUN"]


def _load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def _write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def _normalize_snapshot(payload: Any) -> Any:
    if not isinstance(payload, dict):
        return payload

    normalized = dict(payload)
    normalized.pop("generated_at", None)
    normalized["species"] = sorted(normalized.get("species", []), key=lambda item: item.get("species_id", ""))
    normalized["moves"] = sorted(normalized.get("moves", []), key=lambda item: item.get("move_id", ""))
    return normalized


def _project_species_item(item: dict[str, Any]) -> dict[str, Any]:
    return {
        "schema_version": item.get("schema_version"),
        "species_id": item.get("species_id"),
        "starter_species_id": item.get("starter_species_id"),
        "prevolution_species_id": item.get("prevolution_species_id"),
        "evolution_species_ids": item.get("evolution_species_ids"),
        "pokedex_number": item.get("pokedex_number"),
        "name": item.get("name"),
        "types": item.get("types"),
        "base_stats": item.get("base_stats"),
        "source": item.get("source"),
        "catch_rate": item.get("catch_rate"),
        "base_friendship": item.get("base_friendship"),
        "base_exp": item.get("base_exp"),
        "growth_rate": item.get("growth_rate"),
        "starter_cost": item.get("starter_cost"),
    }


def _project_move_item(item: dict[str, Any]) -> dict[str, Any]:
    return {
        "schema_version": item.get("schema_version"),
        "move_id": item.get("move_id"),
        "name": item.get("name"),
        "type": item.get("type"),
        "category": item.get("category"),
        "power": item.get("power"),
        "source": item.get("source"),
        "accuracy": item.get("accuracy"),
        "pp": item.get("pp"),
        "priority": item.get("priority"),
    }


def _select_items(payload: Any, id_key: str, expected_ids: list[str], context: str, errors: list[str]) -> list[dict[str, Any]]:
    if not isinstance(payload, dict):
        errors.append(f"{context}: expected object")
        return []

    items = payload.get("items")
    if not isinstance(items, list):
        errors.append(f"{context}.items: expected array")
        return []

    indexed: dict[str, dict[str, Any]] = {}
    duplicate_ids: set[str] = set()
    for item in items:
        if not isinstance(item, dict):
            continue
        item_id = item.get(id_key)
        if isinstance(item_id, str):
            if item_id in indexed:
                duplicate_ids.add(item_id)
            indexed[item_id] = item

    for duplicate_id in sorted(duplicate_ids):
        errors.append(f"{context}: duplicate id '{duplicate_id}'")

    selected: list[dict[str, Any]] = []
    for expected_id in expected_ids:
        item = indexed.get(expected_id)
        if item is None:
            errors.append(f"{context}: missing expected id '{expected_id}'")
            continue
        selected.append(item)
    return selected


def _build_snapshot(species_payload: Any, moves_payload: Any, errors: list[str]) -> dict[str, Any]:
    species_items = _select_items(species_payload, "species_id", EXPECTED_SPECIES_IDS, "species", errors)
    move_items = _select_items(moves_payload, "move_id", EXPECTED_MOVE_IDS, "moves", errors)

    return {
        "schema_version": 2,
        "generated_from": "dependency/pokerogue",
        "species": [_project_species_item(item) for item in species_items],
        "moves": [_project_move_item(item) for item in move_items],
    }


def _dump_snapshot(payload: Any) -> str:
    return json.dumps(_normalize_snapshot(payload), indent=2, sort_keys=True)


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate focused prototype regression snapshots for species and moves")
    parser.add_argument("--refresh-fixtures", action="store_true", help="Overwrite the regression snapshot fixture with current catalog output")
    args = parser.parse_args()

    errors: list[str] = []
    if not SPECIES_CATALOG_FILE.exists():
        errors.append(f"missing species catalog: {SPECIES_CATALOG_FILE}")
    if not MOVES_CATALOG_FILE.exists():
        errors.append(f"missing moves catalog: {MOVES_CATALOG_FILE}")
    if errors:
        for error in errors:
            print(error)
        return 1

    species_payload = _load_json(SPECIES_CATALOG_FILE)
    moves_payload = _load_json(MOVES_CATALOG_FILE)
    snapshot = _build_snapshot(species_payload, moves_payload, errors)

    if errors:
        for error in errors:
            print(error)
        return 1

    normalized_snapshot = _normalize_snapshot(snapshot)

    if args.refresh_fixtures:
        _write_json(FIXTURE_FILE, normalized_snapshot)
        print(f"Updated fixture: {FIXTURE_FILE}")
        return 0

    if not FIXTURE_FILE.exists():
        print(f"missing regression fixture: {FIXTURE_FILE}")
        print("Run with --refresh-fixtures after generating catalogs.")
        return 1

    fixture_payload = _load_json(FIXTURE_FILE)
    normalized_fixture = _normalize_snapshot(fixture_payload)

    if normalized_snapshot != normalized_fixture:
        print("Regression snapshot mismatch detected.")
        diff = difflib.unified_diff(
            _dump_snapshot(normalized_fixture).splitlines(),
            _dump_snapshot(normalized_snapshot).splitlines(),
            fromfile=str(FIXTURE_FILE),
            tofile="current catalogs",
            lineterm="",
        )
        for line in diff:
            print(line)
        return 1

    print("Regression passed: prototype species and move snapshots match the fixture.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
