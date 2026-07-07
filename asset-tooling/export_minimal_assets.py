#!/usr/bin/env python3
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import shutil as py_shutil
import os
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[1]
ASSET_LIST_FILE = Path(__file__).resolve().with_name("minimal-asset-list.json")

OUT_DIR = REPO_ROOT / "godot-port" / "godot-minimal-assets"
POKEROGUE_ROOT = REPO_ROOT / "dependency" / "pokerogue"
MOVES_CATALOG_FILE = OUT_DIR / "data" / "moves-catalog.v1.json"


def _find_ffmpeg_executable() -> str:
    env_ffmpeg = os.environ.get("FFMPEG_EXE", "").strip()
    if env_ffmpeg and Path(env_ffmpeg).exists():
        return env_ffmpeg

    ffmpeg_path = py_shutil.which("ffmpeg")
    if ffmpeg_path:
        return ffmpeg_path

    # Winget installs ffmpeg under LocalAppData, sometimes without PATH updates.
    local_app_data = os.environ.get("LOCALAPPDATA", "").strip()
    if local_app_data:
        winget_packages = Path(local_app_data) / "Microsoft" / "WinGet" / "Packages"
        if winget_packages.exists():
            matches = sorted(winget_packages.rglob("ffmpeg.exe"))
            if matches:
                return str(matches[-1])

    try:
        import imageio_ffmpeg  # type: ignore

        return imageio_ffmpeg.get_ffmpeg_exe()
    except Exception:
        return ""


def _map_export_path(relative_path: str, cry_ffmpeg_path: str) -> str:
    lower_rel = relative_path.lower()
    if lower_rel.startswith("assets/audio/cry/") and lower_rel.endswith(".m4a"):
        return relative_path[:-4] + ".ogg"
    return relative_path


def _transcode_audio_to_ogg(source: Path, destination: Path, ffmpeg_path: str) -> bool:
    cmd = [
        ffmpeg_path,
        "-y",
        "-v",
        "error",
        "-i",
        str(source),
        "-ac",
        "1",
        "-ar",
        "44100",
        "-c:a",
        "libvorbis",
        "-q:a",
        "4",
        str(destination),
    ]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
    except Exception as err:
        print(f"Warning: failed to run ffmpeg for cry conversion: {err}")
        return False

    if result.returncode != 0:
        stderr = (result.stderr or "").strip()
        print(f"Warning: cry conversion failed for {source.name}: {stderr}")
        return False

    return True


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


def _enum_name_to_attack_slug(value: str) -> str:
    return value.strip().lower().replace("_", "-")


def _load_exported_move_slugs(path: Path) -> list[str]:
    if not path.exists():
        return []

    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except Exception as err:
        print(f"Warning: failed to parse moves catalog for count-mode attack assets: {err}")
        return []

    if not isinstance(payload, dict):
        return []

    items = payload.get("items")
    if not isinstance(items, list):
        return []

    slugs: list[str] = []
    for item in items:
        if not isinstance(item, dict):
            continue
        move_id = item.get("move_id")
        if not isinstance(move_id, str) or not move_id.strip():
            continue
        slugs.append(_enum_name_to_attack_slug(move_id))
    return list(dict.fromkeys(slugs))


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

    # Pull the base cry for each selected species id.
    # Variant cries (mega/gigantamax/etc.) are intentionally not auto-included.
    cry_rel = f"assets/audio/cry/{pokemon_id}.m4a"
    if (pokerogue_root / cry_rel).exists():
        assets.append(cry_rel)

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

    attacks, attack_count_selector = _parse_attack_selector(raw_data.get("attacks", []))
    attack_slugs: list[str] = []

    if attack_count_selector is None:
        attack_slugs = [_normalize_attack_slug(attack) for attack in attacks]
    else:
        attack_slugs = _load_exported_move_slugs(MOVES_CATALOG_FILE)
        if not attack_slugs:
            print(
                "Warning: attacks is in count mode but no generated moves catalog was found; "
                "run 'asset_pipeline.py --export-data' (or '--export-all') before '--export'"
            )

    for slug in attack_slugs:
        if not slug:
            continue
        assets.extend(_collect_move_assets(slug, pokerogue_root, name_index))

    # Preserve order but remove duplicates.
    return list(dict.fromkeys(assets))


def main() -> None:
    parser = argparse.ArgumentParser(description="Copy minimal assets from pokerogue dependency to godot-minimal-assets")
    parser.parse_args()

    POKEROGUE_ASSETS_DIR = POKEROGUE_ROOT
    cry_ffmpeg_path = _find_ffmpeg_executable()
    if cry_ffmpeg_path:
        print(f"Using ffmpeg for cry conversion: {cry_ffmpeg_path}")
    else:
        print("Warning: ffmpeg not found; cry files will be skipped (ogg-only export policy)")

    # Keep output clean: cry assets should be ogg-only.
    cry_output_dir = OUT_DIR / "assets" / "audio" / "cry"
    if cry_output_dir.exists():
        for stale_m4a in cry_output_dir.glob("*.m4a"):
            try:
                stale_m4a.unlink()
            except Exception as err:
                print(f"Warning: failed removing stale cry file {stale_m4a}: {err}")

    asset_list_raw = json.loads(ASSET_LIST_FILE.read_text(encoding="utf-8"))
    asset_paths = load_asset_paths(asset_list_raw, pokerogue_root=POKEROGUE_ASSETS_DIR)
    copied = []

    for relative_path in asset_paths:
        source = POKEROGUE_ASSETS_DIR / relative_path
        export_relative_path = _map_export_path(relative_path, cry_ffmpeg_path)
        destination = OUT_DIR / export_relative_path

        if not source.exists():
            print(f"Warning: source asset not found: {relative_path}")
            continue

        destination.parent.mkdir(parents=True, exist_ok=True)
        is_cry_m4a = relative_path.lower().startswith("assets/audio/cry/") and relative_path.lower().endswith(".m4a")
        if is_cry_m4a:
            if not cry_ffmpeg_path:
                print(f"Warning: skipping cry (ffmpeg unavailable): {relative_path}")
                continue
            if not _transcode_audio_to_ogg(source, destination, cry_ffmpeg_path):
                print(f"Warning: skipping cry after failed conversion: {relative_path}")
                continue
            copied.append(export_relative_path)
            continue

        shutil.copy2(source, destination)
        copied.append(export_relative_path)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    manifest_path = OUT_DIR / "asset-list.json"
    manifest_path.write_text(json.dumps(copied, indent=2), encoding="utf-8")

    print(f"Copied {len(copied)} minimal assets to {OUT_DIR}")


if __name__ == "__main__":
    main()
