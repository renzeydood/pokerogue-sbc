#!/usr/bin/env python3
import argparse
import json
from pathlib import Path
import shutil

REPO_ROOT = Path(__file__).resolve().parents[1]
ASSET_LIST_FILE = Path(__file__).resolve().with_name("minimal-asset-list.json")

OUT_DIR = REPO_ROOT / "godot-port" / "godot-minimal-assets"


def main() -> None:
    parser = argparse.ArgumentParser(description="Copy minimal assets from pokerogue to godot-minimal-assets")
    parser.add_argument("--pokerogue-root", type=Path, default=REPO_ROOT / "dependency" / "pokerogue",
                        help="Path to the pokerogue repo root")
    args = parser.parse_args()

    POKEROGUE_ASSETS_DIR = args.pokerogue_root
    asset_paths = json.loads(ASSET_LIST_FILE.read_text(encoding="utf-8"))
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
