# Scene and Script Conventions (POLISH-06)

This document defines the baseline conventions for scene and script cleanup tickets:
- POLISH-05A (audit only)
- POLISH-05B (mechanical safe cleanup)
- POLISH-05C (targeted refactors)

## 0. Lock Status
- Status: LOCKED (v1.3)
- Effective date: 2026-07-08
- Owner: gameplay architecture track (POLISH-06)
- Applies to: scene and script cleanup in active Godot gameplay/menu flows.

### Change Control
- During POLISH-05A/B/C, treat this document as frozen baseline.
- Convention updates require a dedicated roadmap/task note and a short rationale entry in the Decision Log below.
- If an audit finding conflicts with this baseline, log it as `defer` or `risky-refactor` until the convention update is approved.

### Decision Log
| Date | Version | Change Summary | Rationale |
|------|---------|----------------|-----------|
| 2026-07-08 | v1 | Initial convention baseline locked | Stabilize POLISH-05A audit criteria and prevent cleanup drift |
| 2026-07-08 | v1.1 | Added stable node-access patterns | Reduce breakage from node rename/reparent operations |
| 2026-07-08 | v1.2 | Added UI scaling and editor/runtime sync conventions | Preserve editor/runtime parity and avoid layout drift in new scenes |
| 2026-07-08 | v1.3 | Added typography convention for editor theme fonts | Reduce runtime font boilerplate and keep style ownership in scene/theme assets |

## 1. Scope and Intent
- Goal: improve maintainability without accidental gameplay regressions.
- Default rule: behavior changes are out of scope unless explicitly tracked in a behavior-risky ticket.

## 2. Naming Conventions
- Scene files:
  - Full screens use the suffix Screen.
  - Overlays use the suffix Overlay.
  - Reusable UI containers use Panel or Widget.
- Node names:
  - Use purpose-based names (example: EnemyHpBar, ActionMenuRoot).
  - Avoid positional names (Node2, Panel3, LeftThing).
- Script files:
  - Match the primary scene/component purpose.
  - Keep one script per major responsibility.

## 3. Scene Structure Rules
- Prefer container-driven layout over manual anchor tuning.
- Keep scene trees shallow enough to navigate quickly in the editor.
- Group related nodes with clear parent ownership.
- Remove stale placeholder nodes only after reference checks.

### 3.1 UI Scaling and Editor/Runtime Parity Rules
- New UI-heavy scenes should include a dedicated `UiScaleRoot` and apply scaling there instead of scaling many leaf nodes.
- Keep runtime layout overrides explicit behind an opt-in flag (for example `use_runtime_layout_overrides`) so editor preview remains controllable.
- Reuse the established editor preview sync helper (`res://logic/EditorPreviewSync.gd`) for tool scripts that need live preview updates.
- Prefer template-first scene setup for scaled overlays/modals using `scenes/templates/UiScaledModalTemplate.tscn` and `scenes/templates/UiScaledModalTemplate.gd`.
- If a scene has tool-mode preview data, seed and refresh it through one sync path instead of ad-hoc editor-only branches.
- For data-driven UI (for example starter/party lists), provide representative editor placeholder rows/items so spacing and clipping can be tuned without runtime data loading.

Required pattern for tool preview scenes:
1. `tool` script with `editor_preview_enabled` toggle.
2. One preview seed method (initial demo state) and one or two refresh methods.
3. `EditorPreviewSync.sync_scene(...)` call in `_process` while `Engine.editor_hint` is true.
4. Runtime-only behavior must be skipped when in editor hint mode.
5. Placeholder preview data should cover both key sprites and list items for layout work, and remain editor-only.

Parity checks for cleanup and review:
1. Layout composition is visually consistent between editor and runtime.
2. Scale is applied at the intended root, not duplicated at multiple hierarchy levels.
3. Preview mode can be disabled without affecting runtime behavior.
4. No hidden editor-only state leaks into runtime scene behavior.

### 3.2 Typography and Theme Rules
- Prefer editor-configured Theme font resources and inspector overrides for UI typography.
- Avoid runtime `DynamicFont` creation for standard scene UI labels/buttons.
- Script-side font overrides are allowed only for clearly dynamic/runtime-generated surfaces where theme assignment is not practical.
- New scene templates should expose typography through theme assets first, then optional script hooks only when required.

Typography checks for cleanup and review:
1. Primary UI labels and buttons resolve fonts from scene/theme configuration.
2. No unnecessary per-node runtime font construction remains in scene scripts.
3. Runtime-generated controls inherit or receive theme fonts without duplicating font build code.

## 4. Script Ownership and Boundaries
- Root scene script orchestrates flow/state transitions.
- Reusable widget scripts handle local widget behavior only.
- Keep transient UI state separate from runtime domain state.
- Avoid hidden cross-scene coupling via deep node paths.

## 5. Node Reference and Signal Rules
- Prefer cached onready references for frequently used nodes.
- Avoid repeated deep string-based path lookups in hot paths.
- Centralize signal connections in predictable setup blocks.
- Keep signal naming explicit and domain-readable.

### 5.1 Stable Node-Access Pattern (rename/reparent resilient)
- Use a scene "API surface" approach:
  - Keep a small set of stable anchor nodes near scene root.
  - Resolve deep children relative to anchors, not from root each time.
- For volatile hierarchy areas, use exported NodePath fields set in the editor.
- Always resolve references once in setup (`_ready`) and store in cached variables.
- Validate required refs early with assertions or explicit null checks.
- Prefer signal-based communication between siblings instead of direct deep lookups.

Recommended pattern:
1. Required refs: cached once, fail fast if missing.
2. Optional refs: use `get_node_or_null` and guard usage.
3. Volatile refs: expose as exported NodePath and assign in scene inspector.

Example:
```gdscript
export(NodePath) var enemy_panel_path

onready var enemy_panel = get_node(enemy_panel_path)
onready var enemy_hp_bar = enemy_panel.get_node("EnemyHpBar")

func _ready() -> void:
	assert(enemy_panel != null)
	assert(enemy_hp_bar != null)
```

### 5.2 Refactor Safety Rule
- When renaming/reparenting nodes, update and verify in this order:
  1. scene references (inspector NodePath values)
  2. script cached refs
  3. signal connections
  4. animation/tween track bindings
- Any change that breaks this chain is classified at least `manual-safe-fix`, and escalates to `risky-refactor` if behavior could shift.

## 6. Cleanup Safety Gates
Before removing a node or logic path, verify all checks pass:
1. No runtime references remain.
2. No signal connections depend on it.
3. No animation track references depend on it.
4. No editor workflow dependence is documented.
5. Regression checklist still passes.

## 7. Ticket Mapping
- POLISH-05A:
  - Audit only. Produce findings report at godot-port/SCENE_AUDIT_FINDINGS.md.
  - No structural edits.
- POLISH-05B:
  - Apply only safe-auto-fix and approved manual-safe-fix findings.
  - No intentional behavior changes.
- POLISH-05C:
  - Refactors that may affect behavior.
  - Require explicit before/after notes and focused test evidence.

## 8. Review Checklist (Quick)
- Naming follows conventions.
- Scene hierarchy has clear ownership.
- Signal wiring is centralized and readable.
- Removed nodes/paths pass safety gates.
- No unintended UI flow or battle flow regressions observed.
