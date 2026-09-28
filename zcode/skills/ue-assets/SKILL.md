---
name: ue-assets
description: UE asset data, post-import takeover, and asset quality checks. Use when the user has imported Fab/Launcher assets or asks to inspect dependencies, size, pivot, materials, collision, LOD, Nanite, asset paths, Redirectors, or scene readiness.
---

# UE Assets

First scope the project and the `/Game/...` range. A Content-file baseline/diff only finds candidates; verify asset type, dependencies, bounds, pivot, materials, collision, LOD, and Nanite with the live Asset Registry or official Toolset.

## Post-import takeover

1. Use a path supplied by the user, or the Asset Registry difference before and after import. Do not poll the entire Content tree indefinitely or claim that a candidate came from Fab.
2. Read-only inspect type, canonical Object/Package Path, dependencies, size/bounds, pivot, materials/textures, collision, LOD, Nanite, Virtual Texture, naming, and ownership.
3. Produce a placement/integration plan with scale, orientation, ground height, material parameters, and target Level. A user-requested, bounded integration may execute directly.
4. Execute through `ue-editor-operations`, then perform a live check and Viewport preview. Report dirty and saved state separately.

## Quality checks

Check missing references/Redirectors, abnormal naming, oversized textures/compression, missing collision, LOD/Nanite, unused material slots, duplicate candidates, and dependency anomalies. Report evidence, scope, coverage, severity, and unchecked items; keep repair suggestions separate from repairs actually performed.

Use the live Asset Registry and Toolset Schema for detailed fields and current offline boundaries; do not rely on stale local snapshots.
