---
name: ue-editor-operations
description: Read and modify objects, Actors, scenes, and common assets in Unreal Editor. Use to inspect selection, move/rotate/scale Actors, create Actors from assets, replace materials or textures, import textures, move Content assets, batch-edit, save, or verify results.
---

# UE Editor Operations

Determine the project, World/Level, object, or canonical /Game/... path first, then read the live Schema and current values. Use a named Tool for a single step; use ue-python-api only for batching, conditional work, or cross-API operations.

## Coverage

- Objects/scenes: read selection, Actor/Component properties and bounds; set transforms, align, array, and create an Actor from a Static Mesh.
- Appearance/assets: replace Static Mesh material slots, change Material Instance textures/colors/scalars, import Texture2D, and move/rename Content assets.
- Batch sessions: group related changes under one explicit scope and result ledger; record before/after, dirty packages, saved state, and rollback availability.

## Execution contract

1. Read-only determine the exact target, current values, scope, and dependencies; never infer an object from its name.
2. Generate the smallest request from the live Schema. A user-requested, named, bounded write executes directly without step-by-step confirmation; ask once only when scope is unclear or expands.
3. Execute in logical batches and perform one structured review: transform/object ownership, materials/references, actual count, and dirty/saved state. For visual work, capture one representative Viewport preview after the batch.
4. If a write times out or the result is uncertain, verify read-only first and do not replay automatically; call something rollbackable only when the live contract explicitly supports a transaction/rollback.

Saving is not the same as modifying: report dirty packages, Save/Save All results, and World Partition External Actor state separately. Use the live Editor state and current Toolset Schema for detailed operation fields.
