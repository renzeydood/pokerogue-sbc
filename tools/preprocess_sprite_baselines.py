#!/usr/bin/env python3
import argparse
import json
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[1]
MINIMAL_ASSET_ROOT = REPO_ROOT / "godot-port" / "godot-minimal-assets"
ASSET_ROOT = MINIMAL_ASSET_ROOT / "assets" / "images" / "pokemon"
TARGET_MIN_Dex = 906
TARGET_MAX_Dex = 925
DEFAULT_MARGIN = 0
DEFAULT_REPORT = REPO_ROOT / "godot-port" / "data" / "reports" / "sprite-baseline-preprocess-report.json"
DEFAULT_OVERRIDES_CONFIG = REPO_ROOT / "tools" / "sprite-offset-overrides.json"


def _load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def _write_json(path: Path, payload: Any) -> None:
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def _parse_dex_from_stem(stem: str) -> int:
    prefix = stem.split("-", 1)[0].strip()
    return int(prefix) if prefix.isdigit() else -1


def _iter_frame_entries(payload: dict[str, Any]):
    if isinstance(payload.get("textures"), list):
        for tex_index, texture in enumerate(payload["textures"]):
            if not isinstance(texture, dict):
                continue
            frames = texture.get("frames")
            if isinstance(frames, list):
                for frame_index, frame in enumerate(frames):
                    if isinstance(frame, dict):
                        yield texture, frames, frame_index, frame
            elif isinstance(frames, dict):
                for key in sorted(frames.keys()):
                    frame = frames[key]
                    if isinstance(frame, dict):
                        yield texture, frames, key, frame
    elif isinstance(payload.get("frames"), list):
        frames = payload["frames"]
        for frame_index, frame in enumerate(frames):
            if isinstance(frame, dict):
                yield payload, frames, frame_index, frame
    elif isinstance(payload.get("frames"), dict):
        frames = payload["frames"]
        for key in sorted(frames.keys()):
            frame = frames[key]
            if isinstance(frame, dict):
                yield payload, frames, key, frame


def _bottom_align_frame(frame: dict[str, Any], margin: int, allow_crop: bool = False) -> dict[str, Any] | None:
    sprite_source = frame.get("spriteSourceSize")
    source = frame.get("sourceSize")
    frame_rect = frame.get("frame")
    if not isinstance(sprite_source, dict) or not isinstance(source, dict) or not isinstance(frame_rect, dict):
        return None

    source_h = source.get("h")
    frame_h = frame_rect.get("h")
    current_y = sprite_source.get("y")
    if not isinstance(source_h, int) or not isinstance(frame_h, int) or not isinstance(current_y, int):
        return None

    target_y = int(source_h) - int(frame_h) - int(margin)
    if allow_crop:
        target_y = int(target_y)
    else:
        target_y = max(0, min(int(source_h) - int(frame_h), target_y))
    if target_y == current_y:
        return None

    sprite_source["y"] = target_y
    return {
        "mode": "bottom_align",
        "old_y": current_y,
        "new_y": target_y,
        "source_h": int(source_h),
        "frame_h": int(frame_h),
    }


def _set_fixed_frame_y(frame: dict[str, Any], fixed_y: int, allow_crop: bool = False) -> dict[str, Any] | None:
    sprite_source = frame.get("spriteSourceSize")
    source = frame.get("sourceSize")
    frame_rect = frame.get("frame")
    if not isinstance(sprite_source, dict) or not isinstance(source, dict) or not isinstance(frame_rect, dict):
        return None

    source_h = source.get("h")
    frame_h = frame_rect.get("h")
    current_y = sprite_source.get("y")
    if not isinstance(source_h, int) or not isinstance(frame_h, int) or not isinstance(current_y, int):
        return None

    max_y = max(0, int(source_h) - int(frame_h))
    if allow_crop:
        target_y = int(fixed_y)
    else:
        target_y = max(0, min(int(fixed_y), max_y))
    if target_y == current_y:
        return None

    sprite_source["y"] = target_y
    return {
        "mode": "fixed_y",
        "old_y": current_y,
        "new_y": target_y,
        "source_h": int(source_h),
        "frame_h": int(frame_h),
    }


def _shift_frame_y(frame: dict[str, Any], delta_y: int, allow_crop: bool = False) -> dict[str, Any] | None:
    sprite_source = frame.get("spriteSourceSize")
    source = frame.get("sourceSize")
    frame_rect = frame.get("frame")
    if not isinstance(sprite_source, dict) or not isinstance(source, dict) or not isinstance(frame_rect, dict):
        return None

    source_h = source.get("h")
    frame_h = frame_rect.get("h")
    current_y = sprite_source.get("y")
    if not isinstance(source_h, int) or not isinstance(frame_h, int) or not isinstance(current_y, int):
        return None

    max_y = max(0, int(source_h) - int(frame_h))
    if allow_crop:
        target_y = int(current_y) + int(delta_y)
    else:
        target_y = max(0, min(int(current_y) + int(delta_y), max_y))
    if target_y == current_y:
        return None

    sprite_source["y"] = target_y
    return {
        "mode": "shift_y",
        "old_y": current_y,
        "new_y": target_y,
        "delta_y": int(delta_y),
        "source_h": int(source_h),
        "frame_h": int(frame_h),
    }


def _get_frame_shift_bounds(frame: dict[str, Any]) -> tuple[int, int] | None:
    sprite_source = frame.get("spriteSourceSize")
    source = frame.get("sourceSize")
    frame_rect = frame.get("frame")
    if not isinstance(sprite_source, dict) or not isinstance(source, dict) or not isinstance(frame_rect, dict):
        return None

    source_h = source.get("h")
    frame_h = frame_rect.get("h")
    current_y = sprite_source.get("y")
    if not isinstance(source_h, int) or not isinstance(frame_h, int) or not isinstance(current_y, int):
        return None

    max_y = max(0, int(source_h) - int(frame_h))
    min_delta = -int(current_y)
    max_delta = int(max_y - int(current_y))
    return min_delta, max_delta


def _resolve_consistent_shift_delta(frames: list[dict[str, Any]], requested_delta: int, allow_crop: bool = False) -> tuple[int, str | None]:
    if allow_crop:
        return int(requested_delta), None

    min_allowed = -10**9
    max_allowed = 10**9
    valid_count = 0

    for frame in frames:
        bounds = _get_frame_shift_bounds(frame)
        if bounds is None:
            continue
        valid_count += 1
        min_allowed = max(min_allowed, bounds[0])
        if not allow_crop:
            max_allowed = min(max_allowed, bounds[1])

    if valid_count == 0:
        return 0, "No valid frames with spriteSourceSize/sourceSize/frame metadata; shift_y skipped."

    if min_allowed > max_allowed:
        return 0, "No common shift range across frames; shift_y skipped."

    effective = max(min_allowed, min(max_allowed, int(requested_delta)))
    if effective != int(requested_delta):
        reason = (
            "Requested shift_y delta was clamped to a common feasible range "
            f"[{min_allowed}, {max_allowed}] to keep all frames consistent."
        )
        return effective, reason

    return effective, None


def _is_target_file(path: Path) -> bool:
    dex = _parse_dex_from_stem(path.stem)
    return TARGET_MIN_Dex <= dex <= TARGET_MAX_Dex


def _resolve_override_path(path_text: str) -> Path | None:
    path_text = path_text.strip()
    if not path_text:
        return None

    path = Path(path_text)
    candidates: list[Path] = []

    if path.is_absolute():
        candidates.append(path)
    else:
        candidates.append(REPO_ROOT / path)
        if path_text.startswith("assets/"):
            candidates.append(MINIMAL_ASSET_ROOT / path)
        if path_text.startswith("pokemon/"):
            trimmed = path_text[len("pokemon/") :]
            candidates.append(ASSET_ROOT / trimmed)

    for candidate in candidates:
        if candidate.exists() and candidate.is_file():
            return candidate
    return None


def _load_override_targets(config_path: Path) -> dict[Path, dict[str, Any]]:
    targets: dict[Path, dict[str, Any]] = {}
    if not config_path.exists():
        return targets

    payload = _load_json(config_path)
    if not isinstance(payload, dict):
        print(f"Warning: override config is not a JSON object: {config_path}")
        return targets

    entries = payload.get("overrides", [])
    if not isinstance(entries, list):
        print(f"Warning: override config 'overrides' is not a JSON array: {config_path}")
        return targets

    for entry in entries:
        if not isinstance(entry, dict):
            continue
        if entry.get("enabled", True) is False:
            continue

        atlas = str(entry.get("atlas", "")).strip()
        if not atlas:
            print(f"Warning: enabled override entry is missing 'atlas': {entry}")
            continue

        mode = str(entry.get("mode", "bottom_align")).strip().lower()
        if not mode:
            mode = "bottom_align"

        rule: dict[str, Any] = {"mode": mode}
        rule["allow_crop"] = bool(entry.get("allow_crop", False))
        if mode == "fixed_y":
            fixed_y_raw = entry.get("fixed_y", 0)
            fixed_y = int(fixed_y_raw) if isinstance(fixed_y_raw, (int, float)) else 0
            rule["fixed_y"] = max(0, fixed_y)
        elif mode == "shift_y":
            delta_y_raw = entry.get("delta_y", 0)
            delta_y = int(delta_y_raw) if isinstance(delta_y_raw, (int, float)) else 0
            rule["delta_y"] = int(delta_y)
        else:
            margin_raw = entry.get("margin", DEFAULT_MARGIN)
            margin = int(margin_raw) if isinstance(margin_raw, (int, float)) else DEFAULT_MARGIN
            if margin < 0 and not bool(rule.get("allow_crop", False)):
                print(f"Warning: negative margin is clamped to 0 for atlas '{atlas}'")
            rule["mode"] = "bottom_align"
            rule["margin"] = margin if bool(rule.get("allow_crop", False)) else max(0, margin)

        resolved = _resolve_override_path(atlas)
        if resolved is None:
            print(f"Warning: override atlas not found: {atlas}")
            continue
        targets[resolved] = rule

    return targets


def main() -> int:
    parser = argparse.ArgumentParser(description="Normalize Gen 9 sprite atlas metadata so visible art sits on the bottom baseline")
    parser.add_argument("--apply", action="store_true", help="Write metadata changes back to disk")
    parser.add_argument("--margin", type=int, default=DEFAULT_MARGIN, help="Keep this many transparent pixels below the sprite after alignment")
    parser.add_argument("--report", type=Path, default=DEFAULT_REPORT, help="Path to write JSON report")
    parser.add_argument("--overrides-config", type=Path, default=DEFAULT_OVERRIDES_CONFIG, help="JSON file with per-sprite baseline overrides")
    parser.add_argument("--disable-gen9-batch", action="store_true", help="Disable built-in Gen 9 bulk baseline normalization (906-925)")
    parser.add_argument("--disable-overrides", action="store_true", help="Disable per-sprite overrides from the overrides config file")
    parser.add_argument("--allow-crop", action="store_true", help="Allow offsets to exceed lower frame-bound (intentional crop at bottom)")
    args = parser.parse_args()

    if not ASSET_ROOT.exists():
        raise SystemExit(f"Sprite asset root not found: {ASSET_ROOT}")

    changed_files: list[dict[str, Any]] = []
    target_files: dict[Path, dict[str, Any]] = {}

    if not args.disable_gen9_batch:
        for json_path in sorted(ASSET_ROOT.rglob("*.json")):
            if _is_target_file(json_path):
                target_files[json_path] = {
                    "mode": "bottom_align",
                    "margin": max(0, args.margin),
                    "allow_crop": args.allow_crop,
                }

    if not args.disable_overrides:
        override_targets = _load_override_targets(args.overrides_config)
        for path, rule in override_targets.items():
            target_files[path] = rule

    if args.allow_crop:
        for path in list(target_files.keys()):
            target_files[path]["allow_crop"] = True

    inspected_files = len(target_files)

    for json_path in sorted(target_files.keys()):
        rule = target_files[json_path]

        payload = _load_json(json_path)
        if not isinstance(payload, dict):
            continue

        frames_for_consistent_shift: list[dict[str, Any]] = []
        for _container, _frames, _key, frame in _iter_frame_entries(payload):
            frames_for_consistent_shift.append(frame)

        effective_shift_delta = None
        effective_shift_note = None
        mode = str(rule.get("mode", "bottom_align"))
        if mode == "shift_y":
            allow_crop = bool(rule.get("allow_crop", False))
            effective_shift_delta, effective_shift_note = _resolve_consistent_shift_delta(
                frames_for_consistent_shift,
                int(rule.get("delta_y", 0)),
                allow_crop,
            )
            requested_delta = int(rule.get("delta_y", 0))
            if effective_shift_delta != requested_delta:
                rel = str(json_path.relative_to(REPO_ROOT)).replace("\\", "/")
                print(
                    "Info: shift_y adjusted for %s (requested=%d effective=%d). %s"
                    % (rel, requested_delta, int(effective_shift_delta), effective_shift_note if effective_shift_note is not None else "")
                )

        frame_changes: list[dict[str, Any]] = []
        for _container, _frames, _key, frame in _iter_frame_entries(payload):
            change = None
            if mode == "fixed_y":
                change = _set_fixed_frame_y(frame, int(rule.get("fixed_y", 0)), bool(rule.get("allow_crop", False)))
            elif mode == "shift_y":
                change = _shift_frame_y(frame, int(effective_shift_delta), bool(rule.get("allow_crop", False)))
            else:
                change = _bottom_align_frame(frame, int(rule.get("margin", DEFAULT_MARGIN)), bool(rule.get("allow_crop", False)))
            if change is not None:
                frame_changes.append(change)

        if not frame_changes:
            if mode == "shift_y" and effective_shift_note is not None:
                rel = str(json_path.relative_to(REPO_ROOT)).replace("\\", "/")
                print("Info: no shift_y changes applied for %s. %s" % (rel, effective_shift_note))
            continue

        changed_entry = {
            "file": str(json_path.relative_to(REPO_ROOT)).replace("\\", "/"),
            "rule": rule,
            "frame_changes": frame_changes,
        }
        if mode == "shift_y":
            changed_entry["effective_delta_y"] = int(effective_shift_delta)
            if effective_shift_note is not None:
                changed_entry["note"] = effective_shift_note
        changed_files.append(changed_entry)

        if args.apply:
            _write_json(json_path, payload)

    report = {
        "schema_version": 1,
        "inspected_files": inspected_files,
        "changed_files": len(changed_files),
        "default_margin": max(0, args.margin),
        "disable_gen9_batch": args.disable_gen9_batch,
        "disable_overrides": args.disable_overrides,
        "overrides_config": str(args.overrides_config),
        "changes": changed_files,
    }

    args.report.parent.mkdir(parents=True, exist_ok=True)
    _write_json(args.report, report)

    print(f"Sprite baseline report written: {args.report}")
    print(
        "Summary: "
        f"inspected={inspected_files} "
        f"changed={len(changed_files)} "
        f"default_margin={max(0, args.margin)} "
        f"gen9_batch={not args.disable_gen9_batch} "
        f"overrides={not args.disable_overrides} "
        f"apply={args.apply}"
    )
    for item in changed_files[:12]:
        print(f"- {item['file']} ({len(item['frame_changes'])} frame(s))")

    if not args.apply and changed_files:
        print("Dry run only. Re-run with --apply to write the metadata changes.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())