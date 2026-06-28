# Godot Port Asset Tooling

This folder contains the minimal Python asset pipeline for extracting a small subset of PokéRogue assets for the Godot port.

## Python asset export

Run from the repository root:

```powershell
python .\godot-port\asset-tooling\export_minimal_assets.py
```

This will:

- copy the files listed in `minimal-asset-list.json`
- create `godot-minimal-assets/`
- write `godot-minimal-assets/asset-list.json`

## Asset pipeline wrapper

A small wrapper script is provided to optionally run upstream preprocessing scripts and then execute the Python exporter. This keeps the Godot port cleanup simple while allowing reuse of existing `pokerogue` asset tooling when needed.

Usage (from the future `godot-port` root you mentioned):

```powershell
py asset-tooling\asset_pipeline.py --pokerogue-root "..\pokerogue" --preprocess --export
```

Use `--pokerogue-root` to point to the original repo when `godot-port` becomes the new root and `pokerogue` is a submodule.

A dry run is available to print the planned pipeline steps without executing them:

```powershell
py asset-tooling\asset_pipeline.py --preprocess --export --dry-run
```

## Asset list format

The source list is stored in `minimal-asset-list.json` as a simple array of relative file paths.

