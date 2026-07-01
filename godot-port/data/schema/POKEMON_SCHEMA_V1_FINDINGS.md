# Pokemon Schema v1 Findings

## Ticket Scope
POKEMON-01 first version defines versioned schemas for species and moves with early alignment to Pokerogue source structures.

## Schema Artifacts
- `godot-port/data/schema/species.schema.v1.json`
- `godot-port/data/schema/moves.schema.v1.json`
- `godot-port/data/schema/species-catalog.schema.v1.json`
- `godot-port/data/schema/moves-catalog.schema.v1.json`

## Pokerogue Source Alignment
Primary source references:
- `dependency/pokerogue/src/data/pokemon-species.ts`
- `dependency/pokerogue/src/data/species-data-registry.ts`
- `dependency/pokerogue/src/data/moves/move.ts`

Field mapping decisions:
- `species_id` aligns to `SpeciesId` enum naming (uppercase snake case).
- `types` aligns to source `type1` + optional `type2` model.
- `base_stats` aligns to source HP/Atk/Def/SpAtk/SpDef/Spd set.
- `move_id` aligns to `MoveId` enum naming (uppercase snake case).
- `category` aligns to move damage category (`PHYSICAL`, `SPECIAL`, `STATUS`).
- `source` metadata fields preserve source enum names for easier round-trip debugging.

## Versioning and Compatibility
- All schemas enforce `schema_version: 1`.
- Catalog wrappers add `generated_from` and `generated_at` to make exports reproducible and auditable.
- Current v1 is intentionally minimal for battle-loop needs; forms, abilities, level moves, and TM lists are deferred to later tickets.

## Constraints and Conventions
- Canonical enum-like fields are uppercase snake case for transition stability.
- Type list allows 1-2 entries; dual-type order is preserved from source (`type1`, then `type2`).
- Optional fields (`accuracy`, `pp`, `priority`, growth/catch metadata) are included early to reduce migration churn in later tickets.

## Follow-up for POKEMON-02
- Export script should normalize source values into this canonical format.
- Export script should emit catalogs (`species-catalog`, `moves-catalog`) and validate each item against v1 entity schemas.
