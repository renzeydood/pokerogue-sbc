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

## Python minimal data export

Run from the repository root:

```powershell
python .\asset-tooling\export_minimal_data.py
```

This will read `minimal-asset-list.json` selectors (`pokemon`, `attacks`) and generate:

- `godot-minimal-assets/data/species-catalog.v1.json`
- `godot-minimal-assets/data/moves-catalog.v1.json`

## Asset pipeline wrapper

A small wrapper script is provided to optionally run upstream preprocessing scripts and then execute the Python exporter. This keeps the Godot port cleanup simple while allowing reuse of existing `pokerogue` asset tooling when needed.

Usage (from the future `godot-port` root you mentioned):

```powershell
py asset-tooling\asset_pipeline.py --pokerogue-root "..\pokerogue" --preprocess --export
```

Useful export modes:

```powershell
py asset-tooling\asset_pipeline.py --export
py asset-tooling\asset_pipeline.py --export-data
py asset-tooling\asset_pipeline.py --export-all
```

Use `--pokerogue-root` to point to the original repo when `godot-port` becomes the new root and `pokerogue` is a submodule.

A dry run is available to print the planned pipeline steps without executing them:

```powershell
py asset-tooling\asset_pipeline.py --preprocess --export --dry-run
```

## Asset list format

The source list in `minimal-asset-list.json` supports two formats:

1. Legacy flat array of relative paths.
2. Structured object that links gameplay selectors to assets.

Structured format example:

```json
{
	"pokemon": ["1", "4"],
	"attacks": ["tackle", "ember"],
	"general_assets": [
		"assets/images/logo.png"
	]
}
```

Expansion rules used by the exporter:

- `pokemon`: auto-discovers matching files for each id in:
	- `assets/images/pokemon/`
	- `assets/images/pokemon/back/`
- `attacks`: adds `assets/battle-anims/<attack-slug>.json` (lowercase kebab-case), then parses that json and also pulls:
	- `graphic` -> assets from `assets/images/battle_anims/` (png/json/webp)
	- `resourceName` -> audio from `assets/audio/battle_anims/` (with filename fallback search under `assets/`)
- `general_assets`: copied as-is

This keeps minimal export focused while allowing a single reference list to drive both selected entities and shared assets.

