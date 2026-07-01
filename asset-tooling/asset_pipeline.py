#!/usr/bin/env python3
import argparse
import subprocess
import sys
from pathlib import Path
import platform


def run_command(cmd, cwd=None, dry_run=False):
    print("Running:", " ".join(cmd))
    if dry_run:
        return
    res = subprocess.run(cmd, cwd=cwd)
    if res.returncode != 0:
        raise SystemExit(res.returncode)


def run_powershell(script_path: Path, dry_run=False, cwd=None):
    if platform.system() == "Windows":
        cmd = ["powershell", "-ExecutionPolicy", "Bypass", "-File", str(script_path)]
    else:
        # Try pwsh on non-Windows
        cmd = ["pwsh", "-File", str(script_path)]
    run_command(cmd, cwd=cwd, dry_run=dry_run)


def run_batch(script_path: Path, dry_run=False, cwd=None):
    cmd = ["cmd", "/c", str(script_path)]
    run_command(cmd, cwd=cwd, dry_run=dry_run)


def run_exporter(exporter_path: Path, dry_run=False):
    cmd = [sys.executable, str(exporter_path)]
    run_command(cmd, dry_run=dry_run)


def main():
    repo_root = Path(__file__).resolve().parents[1]
    pokerogue_root = repo_root / "dependency" / "pokerogue"

    parser = argparse.ArgumentParser(description="Asset pipeline wrapper for godot-port")
    parser.add_argument("--preprocess", action="store_true", help="Run sprite preprocessing scripts in the submodule before export (only needed if you have raw sprite sources)")
    parser.add_argument("--export", action="store_true", help="Run the Python exporter to copy minimal assets")
    parser.add_argument("--export-data", action="store_true", help="Run the Python exporter to generate minimal species/move data catalogs")
    parser.add_argument("--validate-data", action="store_true", help="Run validation checks on generated minimal species/move catalogs")
    parser.add_argument("--refresh-fixtures", action="store_true", help="Update checked-in data fixtures from current generated catalogs (requires --validate-data)")
    parser.add_argument("--export-all", action="store_true", help="Run both minimal asset and minimal data exporters")
    parser.add_argument("--skip-missing-scripts", action="store_true", default=True, help="Skip preprocessing scripts if source files don't exist (default: True)")
    parser.add_argument("--dry-run", action="store_true", help="Print the preprocessing/export steps without executing them")
    parser.add_argument("--scripts", nargs="*", help="Specific preprocessing script names to run (relative to asset-tooling). Example: sprites/convert.ps1")

    args = parser.parse_args()

    asset_tooling_root = repo_root / "asset-tooling"

    if args.export_all:
        args.export = True
        args.export_data = True
        args.validate_data = True

    if args.refresh_fixtures:
        args.validate_data = True

    if not args.preprocess and not args.export and not args.export_data and not args.validate_data:
        # Default to export if neither flag specified
        args.export = True
    
    if args.preprocess:
        scripts = args.scripts or [
            "sprites/convert.ps1",
            "sprites/convert-ebdx.ps1",
            "update-exp-sprites.ps1",
        ]
        # Preprocessing scripts live in the pokerogue submodule's scripts/asset-tooling/
        submodule_asset_tooling = pokerogue_root / "scripts" / "asset-tooling"

        for s in scripts:
            script_path = submodule_asset_tooling / s
            if not script_path.exists():
                print(f"Skipping missing script: {script_path}")
                continue

            # Legacy scripts depend heavily on relative paths from the pokerogue root.
            script_cwd = pokerogue_root

            if script_path.suffix.lower() == ".ps1":
                run_powershell(script_path, dry_run=args.dry_run, cwd=script_cwd)
            elif script_path.suffix.lower() == ".bat":
                run_batch(script_path, dry_run=args.dry_run, cwd=script_cwd)
            else:
                print(f"Unknown script type, attempting to run: {script_path}")
                run_command([str(script_path)], cwd=script_cwd, dry_run=args.dry_run)

    if args.export:
        exporter = asset_tooling_root / "export_minimal_assets.py"
        if not exporter.exists():
            raise SystemExit(f"Exporter not found: {exporter}")
        run_exporter(exporter, dry_run=args.dry_run)

    if args.export_data:
        exporter = asset_tooling_root / "export_minimal_data.py"
        if not exporter.exists():
            raise SystemExit(f"Exporter not found: {exporter}")
        run_exporter(exporter, dry_run=args.dry_run)

    if args.validate_data:
        validator = asset_tooling_root / "validate_minimal_data.py"
        if not validator.exists():
            raise SystemExit(f"Validator not found: {validator}")
        if args.refresh_fixtures:
            cmd = [sys.executable, str(validator), "--refresh-fixtures"]
            run_command(cmd, dry_run=args.dry_run)
        else:
            run_exporter(validator, dry_run=args.dry_run)

    if not args.preprocess and not args.export and not args.export_data and not args.validate_data:
        parser.print_help()


if __name__ == "__main__":
    main()
