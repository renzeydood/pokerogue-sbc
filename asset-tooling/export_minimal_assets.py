#!/usr/bin/env python3
import argparse
import json
from pathlib import Path
import shutil
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[1]
ASSET_LIST_FILE = Path(__file__).resolve().with_name("minimal-asset-list.json")

OUT_DIR = REPO_ROOT / "godot-port" / "godot-minimal-assets"
POKEROGUE_ROOT = REPO_ROOT / "dependency" / "pokerogue"


def _normalize_attack_slug(value: str) -> str:
    return value.strip().lower().replace("_", "-").replace(" ", "-")


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


def _matches_pokemon_file(stem: str, pokemon_id: str) -> bool:
    return stem == pokemon_id or stem.startswith(f"{pokemon_id}-") or stem.startswith(f"{pokemon_id}_")


def _collect_pokemon_assets(pokemon_id: str, pokerogue_root: Path) -> list[str]:
    assets: list[str] = []
    pokemon_dirs = [
        pokerogue_root / "assets" / "images" / "pokemon",
        pokerogue_root / "assets" / "images" / "pokemon" / "back",
    ]

    for directory in pokemon_dirs:
        if not directory.exists():
            continue
        for file_path in directory.glob("*"):
            if not file_path.is_file():
                continue
            if _matches_pokemon_file(file_path.stem, pokemon_id):
                assets.append(file_path.relative_to(pokerogue_root).as_posix())

    return assets


def _extract_string_values(node: Any, key_name: str) -> list[str]:
    values: list[str] = []
    if isinstance(node, dict):
        for key, value in node.items():
            if key == key_name and isinstance(value, str) and value.strip():
                values.append(value.strip())
            values.extend(_extract_string_values(value, key_name))
    elif isinstance(node, list):
        for item in node:
            values.extend(_extract_string_values(item, key_name))
    return values


def _build_file_name_index(pokerogue_root: Path) -> dict[str, list[str]]:
    index: dict[str, list[str]] = {}
    assets_root = pokerogue_root / "assets"
    if not assets_root.exists():
        return index

    for file_path in assets_root.rglob("*"):
        if not file_path.is_file():
            continue
        rel = file_path.relative_to(pokerogue_root).as_posix()
        index.setdefault(file_path.name.lower(), []).append(rel)

    return index


def _collect_move_assets(attack_slug: str, pokerogue_root: Path, name_index: dict[str, list[str]]) -> list[str]:
    assets: list[str] = []
    move_json_rel = f"assets/battle-anims/{attack_slug}.json"
    move_json_path = pokerogue_root / move_json_rel
    assets.append(move_json_rel)

    if not move_json_path.exists():
        print(f"Warning: move animation json not found: {move_json_rel}")
        return assets

    try:
        move_payload = json.loads(move_json_path.read_text(encoding="utf-8"))
    except Exception as err:
        print(f"Warning: failed to parse {move_json_rel}: {err}")
        return assets

    for graphic_name in set(_extract_string_values(move_payload, "graphic")):
        found_for_graphic = False
        for ext in (".png", ".json", ".webp"):
            rel = f"assets/images/battle_anims/{graphic_name}{ext}"
            if (pokerogue_root / rel).exists():
                assets.append(rel)
                found_for_graphic = True
        if not found_for_graphic:
            print(f"Warning: graphic asset not found for move '{attack_slug}': {graphic_name}")

    for resource_name in set(_extract_string_values(move_payload, "resourceName")):
        rel = f"assets/audio/battle_anims/{resource_name}"
        if (pokerogue_root / rel).exists():
            assets.append(rel)
            continue

        # Fallback: locate by exact filename under assets if a move event points elsewhere.
        fallback = name_index.get(resource_name.lower(), [])
        if fallback:
            assets.extend(fallback)
        else:
            print(f"Warning: audio resource not found for move '{attack_slug}': {resource_name}")

    return assets


def load_asset_paths(raw_data: Any, pokerogue_root: Path) -> list[str]:
    # Legacy format: ["assets/path/a.png", "assets/path/b.json", ...]
    if isinstance(raw_data, list):
        return _coerce_str_list(raw_data, "root")

    # Structured format:
    # {
    #   "pokemon": ["1", "4"],
    #   "attacks": ["tackle", "ember"],
    #   "general_assets": ["assets/images/logo.png", ...]
    # }
    if not isinstance(raw_data, dict):
        raise ValueError("minimal-asset-list.json must be an array or an object")

    known_fields = {"pokemon", "attacks", "general_assets"}
    unknown_fields = sorted(set(raw_data.keys()) - known_fields)
    if unknown_fields:
        print(f"Warning: unknown fields in minimal-asset-list.json: {', '.join(unknown_fields)}")

    assets: list[str] = []
    name_index = _build_file_name_index(pokerogue_root)

    assets.extend(_coerce_str_list(raw_data.get("general_assets", []), "general_assets"))

    for pokemon_id in _coerce_str_list(raw_data.get("pokemon", []), "pokemon"):
        pid = pokemon_id.strip()
        if not pid:
            continue
        assets.extend(_collect_pokemon_assets(pid, pokerogue_root))

    for attack in _coerce_str_list(raw_data.get("attacks", []), "attacks"):
        slug = _normalize_attack_slug(attack)
        if not slug:
            continue
        assets.extend(_collect_move_assets(slug, pokerogue_root, name_index))

    # Preserve order but remove duplicates.
    return list(dict.fromkeys(assets))


def main() -> None:
    parser = argparse.ArgumentParser(description="Copy minimal assets from pokerogue dependency to godot-minimal-assets")
    parser.parse_args()

    POKEROGUE_ASSETS_DIR = POKEROGUE_ROOT
    asset_list_raw = json.loads(ASSET_LIST_FILE.read_text(encoding="utf-8"))
    asset_paths = load_asset_paths(asset_list_raw, pokerogue_root=POKEROGUE_ASSETS_DIR)
    copied = []

    for relative_path in asset_paths:
        source = POKEROGUE_ASSETS_DIR / relative_path
        destination = OUT_DIR / relative_path

        if not source.exists():
            print(f"Warning: source asset not found: {relative_path}")
            continue

        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)
        copied.append(relative_path)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    manifest_path = OUT_DIR / "asset-list.json"
    manifest_path.write_text(json.dumps(copied, indent=2), encoding="utf-8")

    print(f"Copied {len(copied)} minimal assets to {OUT_DIR}")


if __name__ == "__main__":
    main()
