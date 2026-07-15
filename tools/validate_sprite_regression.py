#!/usr/bin/env python3
import argparse
import json
import statistics
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[1]
ASSET_ROOT = REPO_ROOT / "godot-port" / "godot-minimal-assets" / "assets" / "images" / "pokemon"
BACK_ASSET_ROOT = ASSET_ROOT / "back"
SPECIES_CATALOG = REPO_ROOT / "godot-port" / "godot-minimal-assets" / "data" / "species-catalog.v1.json"
DEFAULT_OUTPUT = REPO_ROOT / "godot-port" / "data" / "reports" / "sprite-regression-report.json"


def _load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def _as_float(value: Any, fallback: float = 1.0) -> float:
    try:
        f = float(value)
    except (TypeError, ValueError):
        return fallback
    return f if f > 0 else fallback


def _parse_numeric_frame_index(filename: str) -> int:
    name = filename.strip()
    if name.lower().endswith(".png"):
        name = name[:-4]
    return int(name) if name.isdigit() else -1


def _normalize_frame_container(frames_container: Any, atlas_scale: float) -> list[dict[str, Any]]:
    normalized: list[dict[str, Any]] = []
    if isinstance(frames_container, list):
        for frame in frames_container:
            if not isinstance(frame, dict):
                continue
            entry = dict(frame)
            entry["_atlas_scale"] = atlas_scale
            normalized.append(entry)
    elif isinstance(frames_container, dict):
        for key in sorted(frames_container.keys()):
            frame = frames_container[key]
            if not isinstance(frame, dict):
                continue
            entry = dict(frame)
            entry.setdefault("filename", str(key))
            entry["_atlas_scale"] = atlas_scale
            normalized.append(entry)
    return normalized


def _parse_atlas(path: Path) -> dict[str, Any]:
    payload = _load_json(path)
    if not isinstance(payload, dict):
        return {"frames": [], "image": "", "kind": "invalid"}

    root_scale = _as_float(payload.get("meta", {}).get("scale", 1.0)) if isinstance(payload.get("meta"), dict) else 1.0

    if isinstance(payload.get("textures"), list):
        frames: list[dict[str, Any]] = []
        image_name = ""
        for tex in payload["textures"]:
            if not isinstance(tex, dict):
                continue
            tex_scale = _as_float(tex.get("scale", root_scale))
            tex_frames = _normalize_frame_container(tex.get("frames"), tex_scale)
            frames.extend(tex_frames)
            if not image_name:
                image_name = str(tex.get("image", "")).strip()
        return {"frames": frames, "image": image_name, "kind": "texturepacker"}

    if "frames" in payload:
        image_name = ""
        meta = payload.get("meta")
        if isinstance(meta, dict):
            image_name = str(meta.get("image", "")).strip()
        frames = _normalize_frame_container(payload.get("frames"), root_scale)
        return {"frames": frames, "image": image_name, "kind": "aseprite"}

    return {"frames": [], "image": "", "kind": "unknown"}


def _compute_offset_metrics(frame: dict[str, Any]) -> dict[str, float] | None:
    frame_rect = frame.get("frame")
    sprite_source = frame.get("spriteSourceSize")
    source = frame.get("sourceSize")
    if not isinstance(frame_rect, dict) or not isinstance(sprite_source, dict) or not isinstance(source, dict):
        return None

    fw = _as_float(frame_rect.get("w", 0), 0.0)
    fh = _as_float(frame_rect.get("h", 0), 0.0)
    sx = _as_float(sprite_source.get("x", 0), 0.0)
    sy = _as_float(sprite_source.get("y", 0), 0.0)
    sw = _as_float(source.get("w", 0), 0.0)
    sh = _as_float(source.get("h", 0), 0.0)
    if sw <= 0 or sh <= 0:
        return None

    trimmed_cx = sx + fw / 2.0
    trimmed_cy = sy + fh / 2.0
    anchor_x = sw / 2.0
    anchor_y = sh  # Battle default anchor mode: bottom
    offset_x = trimmed_cx - anchor_x
    offset_y = trimmed_cy - anchor_y

    return {
        "offset_x": offset_x,
        "offset_y": offset_y,
        "offset_x_norm": offset_x / sw,
        "offset_y_norm": offset_y / sh,
        "source_w": sw,
        "source_h": sh,
        "frame_w": fw,
        "frame_h": fh,
    }


def _list_atlas_files() -> list[tuple[str, Path]]:
    files: list[tuple[str, Path]] = []
    for root, view in ((ASSET_ROOT, "front"), (BACK_ASSET_ROOT, "back")):
        if not root.exists():
            continue
        for path in sorted(root.glob("*.json")):
            files.append((view, path))
    return files


def _build_species_map() -> dict[int, str]:
    if not SPECIES_CATALOG.exists():
        return {}
    payload = _load_json(SPECIES_CATALOG)
    items = payload.get("items", []) if isinstance(payload, dict) else []
    mapping: dict[int, str] = {}
    for item in items:
        if not isinstance(item, dict):
            continue
        dex = item.get("pokedex_number")
        sid = item.get("species_id")
        if isinstance(dex, int) and isinstance(sid, str):
            mapping[dex] = sid
    return mapping


def _primary_frame(frames: list[dict[str, Any]]) -> tuple[dict[str, Any] | None, bool]:
    if not frames:
        return None, False
    indexed: list[tuple[int, dict[str, Any]]] = []
    for frame in frames:
        name = str(frame.get("filename", ""))
        idx = _parse_numeric_frame_index(name)
        if idx >= 0:
            indexed.append((idx, frame))
    if indexed:
        indexed.sort(key=lambda item: item[0])
        return indexed[0][1], True
    return frames[0], False


def _is_special_form_atlas(stem: str) -> bool:
    lowered = stem.lower()
    return (
        "-mega" in lowered
        or "-gmax" in lowered
        or "-gigantamax" in lowered
        or "_mega" in lowered
        or "_gmax" in lowered
    )


def _compute_frame_set_metrics(frames: list[dict[str, Any]]) -> dict[str, Any] | None:
    frame_metrics = [m for m in (_compute_offset_metrics(f) for f in frames) if m is not None]
    if not frame_metrics:
        return None
    y_norm_values = [m["offset_y_norm"] for m in frame_metrics]
    return {
        "frame_count": len(frame_metrics),
        "offset_y_norm_min": min(y_norm_values),
        "offset_y_norm_max": max(y_norm_values),
        "offset_y_norm_median": statistics.median(y_norm_values),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate Pokemon sprite atlas consistency and anchoring outliers")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT, help="Path to write JSON report")
    parser.add_argument("--strict", action="store_true", help="Return non-zero on high-severity issues")
    parser.add_argument("--z-threshold", type=float, default=2.5, help="Outlier z-score threshold for normalized Y offsets")
    parser.add_argument(
        "--include-special-forms",
        action="store_true",
        help="Include mega/gmax/gigantamax atlases in checks (default: excluded to reduce noise)",
    )
    args = parser.parse_args()

    species_by_dex = _build_species_map()
    atlas_files = _list_atlas_files()
    excluded_special_forms = 0

    records: list[dict[str, Any]] = []
    issues: list[dict[str, Any]] = []

    for view, atlas_path in atlas_files:
        stem = atlas_path.stem
        if not args.include_special_forms and _is_special_form_atlas(stem):
            excluded_special_forms += 1
            continue
        dex_text = stem.split("-", 1)[0]
        dex = int(dex_text) if dex_text.isdigit() else -1
        species_id = species_by_dex.get(dex, "")

        parsed = _parse_atlas(atlas_path)
        frames = parsed["frames"]
        image_name = str(parsed.get("image", "")).strip()

        texture_path = atlas_path.with_suffix(".png")
        if image_name:
            texture_path = atlas_path.parent / image_name

        if not texture_path.exists():
            issues.append({
                "severity": "high",
                "kind": "missing_texture",
                "view": view,
                "atlas": str(atlas_path.relative_to(REPO_ROOT)).replace("\\", "/"),
                "expected_texture": str(texture_path.relative_to(REPO_ROOT)).replace("\\", "/"),
                "species_id": species_id,
                "dex_number": dex,
                "action": "Verify atlas image field and ensure referenced PNG is exported/copied.",
            })

        if not frames:
            issues.append({
                "severity": "high",
                "kind": "no_frames",
                "view": view,
                "atlas": str(atlas_path.relative_to(REPO_ROOT)).replace("\\", "/"),
                "species_id": species_id,
                "dex_number": dex,
                "action": "Atlas parsed but yielded no frames; check JSON format and frame container keys.",
            })
            continue

        frame, has_numeric = _primary_frame(frames)
        if frame is None:
            continue

        if not has_numeric:
            issues.append({
                "severity": "medium",
                "kind": "non_numeric_frame_names",
                "view": view,
                "atlas": str(atlas_path.relative_to(REPO_ROOT)).replace("\\", "/"),
                "species_id": species_id,
                "dex_number": dex,
                "action": "Animation selection currently prefers numeric frame names; confirm runtime fallback behavior.",
            })

        metrics = _compute_offset_metrics(frame)
        frame_set_metrics = _compute_frame_set_metrics(frames)
        record = {
            "view": view,
            "atlas": str(atlas_path.relative_to(REPO_ROOT)).replace("\\", "/"),
            "texture": str(texture_path.relative_to(REPO_ROOT)).replace("\\", "/") if texture_path.exists() else "",
            "atlas_kind": parsed.get("kind", ""),
            "species_id": species_id,
            "dex_number": dex,
            "frame": str(frame.get("filename", "")),
            "has_numeric_frames": has_numeric,
            "metrics": metrics,
            "frame_set_metrics": frame_set_metrics,
        }
        records.append(record)

        if metrics is None:
            issues.append({
                "severity": "medium",
                "kind": "missing_trim_metadata",
                "view": view,
                "atlas": record["atlas"],
                "species_id": species_id,
                "dex_number": dex,
                "action": "Missing frame/source trim metadata; runtime falls back to zero offset.",
            })
            continue

        if frame_set_metrics is not None and frame_set_metrics["offset_y_norm_max"] > 0.05:
            issues.append({
                "severity": "high",
                "kind": "below_baseline_offset",
                "view": view,
                "atlas": record["atlas"],
                "species_id": species_id,
                "dex_number": dex,
                "offset_y_norm_max": round(frame_set_metrics["offset_y_norm_max"], 4),
                "action": "One or more frames appear below expected baseline; verify sourceSize/spriteSourceSize and anchor calculation.",
            })

    # Robust outlier detection by view using normalized Y offset.
    for view in ("front", "back"):
        samples = [r for r in records if r.get("view") == view and isinstance(r.get("metrics"), dict)]
        values = [r["frame_set_metrics"]["offset_y_norm_median"] for r in samples if isinstance(r.get("frame_set_metrics"), dict)]
        if len(values) < 10:
            continue
        mean = statistics.mean(values)
        stdev = statistics.pstdev(values)
        if stdev <= 1e-6:
            continue
        for r in samples:
            if not isinstance(r.get("frame_set_metrics"), dict):
                continue
            y = r["frame_set_metrics"]["offset_y_norm_median"]
            z = abs((y - mean) / stdev)
            if z >= args.z_threshold:
                issues.append({
                    "severity": "medium",
                    "kind": "offset_outlier",
                    "view": view,
                    "atlas": r["atlas"],
                    "species_id": r["species_id"],
                    "dex_number": r["dex_number"],
                    "offset_y_norm": round(y, 4),
                    "z_score": round(z, 3),
                    "action": "Review against baseline overlay/debug cycle; likely candidate for per-species anchor drift.",
                })

    severity_rank = {"high": 0, "medium": 1, "low": 2}
    issues.sort(key=lambda it: (severity_rank.get(it.get("severity", "low"), 3), it.get("atlas", "")))

    summary = {
        "atlas_count": len(atlas_files),
        "scanned_atlas_count": len(records),
        "excluded_special_forms": excluded_special_forms,
        "record_count": len(records),
        "issue_count": len(issues),
        "high_issues": sum(1 for i in issues if i.get("severity") == "high"),
        "medium_issues": sum(1 for i in issues if i.get("severity") == "medium"),
    }

    report = {
        "schema_version": 1,
        "summary": summary,
        "issues": issues,
        "records": records,
    }

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    print(f"Sprite regression report written: {args.output}")
    print(
        "Summary: "
        f"atlases={summary['atlas_count']} "
        f"scanned={summary['scanned_atlas_count']} "
        f"excluded_special={summary['excluded_special_forms']} "
        f"records={summary['record_count']} "
        f"issues={summary['issue_count']} "
        f"high={summary['high_issues']} "
        f"medium={summary['medium_issues']}"
    )

    if issues:
        print("Top issues:")
        for issue in issues[:12]:
            sid = issue.get("species_id") or "UNKNOWN"
            print(f"- [{issue.get('severity')}] {issue.get('kind')} {sid} :: {issue.get('atlas')}")

    if args.strict and summary["high_issues"] > 0:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
