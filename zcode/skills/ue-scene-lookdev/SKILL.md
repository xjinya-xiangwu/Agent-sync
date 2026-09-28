---
name: ue-scene-lookdev
description: UE scene composition, lighting Lookdev, and level health checks. Use for arrays, random or spline scattering, dusk/night/fog/exposure/color temperature, overlap/floating/scale checks, World Partition, or lighting conflicts.
---

# UE Scene and Lookdev

Determine the Editor World, Persistent/Streaming Level, Data Layer, and target region first. PIE, unloaded cells, and hidden Layers are not a complete map. Read the current lighting/sky/fog/exposure system before choosing native, Ultra Dynamic Sky, or a project-specific weather system.

## Composition and execution

- Make target region, count limit, spacing/collision, random Seed, Spline/Surface, Transform, exclusion zones, and owning Level/Data Layer explicit.
- For visual parameters, produce the smallest change set. Batch scene writes under one edit scope, call the live Schema serially, and never generate unbounded content.
- Support a dry run or named preset where available. After execution, read object properties, actual count, bounds, overlap/floating state, dirty packages, and capture one representative preview after the batch.

## Level health

Read-only check Actor/Component references, duplicate names, transforms, spatial overlap/grounding/out-of-bounds, World Partition External Actors/Data Layers, primary-light/sky-controller conflicts, and persistence state. Report unloaded scope and confidence. If no proven spatial query exists, do not fabricate a conclusion.

Use the current live lighting, Lookdev, scene, and level data for detailed principles and domain rules.
