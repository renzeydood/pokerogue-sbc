# Godot Port Asset Tooling

This folder contains the minimal Python asset pipeline for extracting a small subset of PokéRogue assets for the Godot port.

## Python asset export

Run from the repository root:

```powershell
python .\tools\export_minimal_assets.py
```

This will:

- copy the files listed in `minimal-asset-list.json`
- create `godot-port/godot-minimal-assets/`
- write `godot-port/godot-minimal-assets/asset-list.json`

## Python minimal data export

Run from the repository root:

```powershell
python .\tools\export_minimal_data.py
```

This will read `minimal-asset-list.json` selectors (`pokemon`, `attacks`) and generate:

- `godot-port/godot-minimal-assets/data/species-catalog.v1.json`
- `godot-port/godot-minimal-assets/data/moves-catalog.v1.json`

## Asset pipeline wrapper

A small wrapper script is provided to optionally run upstream preprocessing scripts and then execute the Python exporter. This keeps the Godot port cleanup simple while allowing reuse of existing `pokerogue` asset tooling when needed.

Usage (from repository root):

```powershell
py tools\asset_pipeline.py --preprocess --export
```

Useful export modes:

```powershell
py tools\asset_pipeline.py --export
py tools\asset_pipeline.py --export-data
py tools\asset_pipeline.py --export-all
py tools\asset_pipeline.py --normalize-sprite-baselines
py tools\asset_pipeline.py --validate-data
py tools\asset_pipeline.py --validate-data --refresh-fixtures
py tools\asset_pipeline.py --validate-sprites
py tools\asset_pipeline.py --validate-sprites --validate-sprites-strict
```

The tooling is now pinned to `dependency/pokerogue` inside this workspace.

Sprite baseline preprocessing is handled as an asset-pipeline step, not at runtime:

```powershell
py tools\asset_pipeline.py --normalize-sprite-baselines
```

That step bottom-aligns Gen 9 sprite atlas metadata in `godot-port/godot-minimal-assets/assets/images/pokemon/` so the visible art sits on the battle baseline without any runtime offset hack.

For one-off outliers (for example specific back sprites that still float), add per-sprite overrides in:

- `tools/sprite-offset-overrides.json`

Each override entry supports:

- `enabled`: true/false
- `atlas`: path to the atlas JSON file
- `mode`: `bottom_align` (default), `fixed_y`, or `shift_y`
- `margin`: bottom transparent pixel margin after alignment (`0` means fully bottom-aligned, used with `bottom_align`)
- `fixed_y`: constant `spriteSourceSize.y` to apply to all frames (used with `fixed_y`)
- `delta_y`: add a constant Y delta to every frame (used with `shift_y`)
- `allow_crop`: when true, permits offsets beyond normal frame bounds (intentional top/bottom crop)

Use `fixed_y` for sprites where strict bottom alignment causes visual artifacts (for example tails/appendages that extend below the feet in some frames).
Use `shift_y` when you want to preserve frame-to-frame relative motion but move the entire sprite up/down by a fixed amount.
`shift_y` is applied consistently across all frames in an atlas using one effective delta; if some frames would clip at bounds, the requested delta is clamped (or skipped) to avoid per-frame bounce artifacts.
Enable `allow_crop` when you explicitly want to move a sprite lower even after it reaches the nominal lower frame-bound.

Then run the same pipeline command again:

```powershell
py tools\asset_pipeline.py --normalize-sprite-baselines
```

Advanced options when running the script directly:

```powershell
py tools\preprocess_sprite_baselines.py --apply
py tools\preprocess_sprite_baselines.py --apply --disable-gen9-batch
py tools\preprocess_sprite_baselines.py --apply --disable-overrides
py tools\preprocess_sprite_baselines.py --apply --disable-gen9-batch --allow-crop
```

A dry run is available to print the planned pipeline steps without executing them:

```powershell
py tools\asset_pipeline.py --preprocess --export --dry-run
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

Count-mode example for starter moves:

```json
{
	"pokemon": ["1", "4", "7"],
	"attacks": [4],
	"general_assets": []
}
```

When `attacks` is a single number (or single numeric string), data export interprets it as:

- pull first `N` unique `levelMoves` from each selected species
- store those per-species move ids in `species-catalog.v1.json` as `starter_moves`
- include the union of those move ids in `moves-catalog.v1.json`

If `attacks` is a list of names/slugs, explicit mode is preserved.

Expansion rules used by the exporter:

- `pokemon`: auto-discovers matching files for each id in:
	- `assets/images/pokemon/`
	- `assets/images/pokemon/back/`
	- also auto-includes base cries: `assets/audio/cry/<id>.m4a`
	- variant cries (`-mega`, `-gigantamax`, etc.) are not auto-included
- `attacks`: adds `assets/battle-anims/<attack-slug>.json` (lowercase kebab-case), then parses that json and also pulls:
	- `graphic` -> assets from `assets/images/battle_anims/` (png/json/webp)
	- `resourceName` -> audio from `assets/audio/battle_anims/` (with filename fallback search under `assets/`)
	- in count mode (`attacks: [N]`), attack slugs are sourced from `godot-minimal-assets/data/moves-catalog.v1.json` and then expanded the same way
	- if that moves catalog does not exist yet, run `py tools/asset_pipeline.py --export-data` (or `--export-all`) first
- `general_assets`: copied as-is

This keeps minimal export focused while allowing a single reference list to drive both selected entities and shared assets.

## Sprite regression workflow

When sprite rendering looks inconsistent (wrong baseline, weird trim, non-animating atlas), run:

```powershell
py tools\validate_sprite_regression.py
```

By default this excludes mega/gmax/gigantamax atlas files to reduce noise while base-form parity is in progress.
To include them explicitly:

```powershell
py tools\validate_sprite_regression.py --include-special-forms
```

or via pipeline:

```powershell
py tools\asset_pipeline.py --validate-sprites
```

Report output:

- `godot-port/data/reports/sprite-regression-report.json`

Issue categories include:

- `missing_texture`: atlas references a texture that was not exported/copied.
- `no_frames`: atlas exists but produced no usable frames.
- `non_numeric_frame_names`: frame naming may not match animation-frame selection assumptions.
- `below_baseline_offset`: computed bottom-anchor offset suggests sprite sits below expected baseline.
- `offset_outlier`: normalized Y offset is statistically unusual compared to other sprites.

Use strict mode to fail CI/local checks when high-severity sprite issues are present:

```powershell
py tools\asset_pipeline.py --validate-sprites --validate-sprites-strict
```

## Data validation and fixtures

`validate_minimal_data.py` validates generated catalog files for:

- required fields and unknown fields
- enum/range constraints (types, categories, stats, PP, priority, etc.)
- selector alignment with `minimal-asset-list.json` (`pokemon` and `attacks`)
- regression drift against checked-in fixtures

Fixture files:

- `godot-port/data/fixtures/species-catalog.v1.fixture.json`
- `godot-port/data/fixtures/moves-catalog.v1.fixture.json`

Typical workflow:

```powershell
py tools\asset_pipeline.py --export-data --validate-data
```

When changes are intentional, refresh fixtures:

```powershell
py tools\asset_pipeline.py --export-data --validate-data --refresh-fixtures
```

