---
name: ue-foundations
description: UE concepts and project-object fundamentals. Use to explain or verify UObject, Actor, Component, Asset, Package, World, Level, PIE, World Partition, centimeters/Z-up coordinates, Local/World transforms, materials, lighting, Blueprints, Dirty/Save, and project Agent Skills. Read-only by default.
---

# UE Foundations

Choose only the topic needed for the question; do not load every topic for completeness. For a conceptual question, explain directly without pretending to have read the current project. For project facts, perform a bounded read-only check through live MCP.

## Topics

- Object relationships: UObject to Actor/Component, Asset/Package, World/Level, and the editor-time/runtime distinction between PIE and World Partition.
- Coordinates: UE uses centimeters and Z-up; make X/Y/Z, Pitch/Yaw/Roll, parent-child hierarchy, and Local/World conversion explicit. Check bounds before changing import scale.
- Assets/materials: Content/Object/Package Paths, hard/soft references, Redirectors, Material/Material Instance, texture channels, Normal, VT, and UDIM.
- Lighting/Blueprints: Lumen, Mobility, Sky/Atmosphere/Fog/exposure/color temperature; Blueprint class defaults, CDO, instances, Construction Script, graph/pins, and compile state.
- Persistence: distinguish dirty packages, Save, Undo, World Partition External Actors, and non-persistent PIE state.
- Project knowledge: when project-specific conventions are needed, discover `AgentSkillToolset` skills, list them first, and load only the matching project/engine-version skill. Treat those skills as scoped project knowledge, not as live object facts.

## Verification rules

Read canonical object paths, types, transforms, bounds, materials/references, World/Package, and dirty state. Offline filenames, sizes, or snapshots cannot replace live facts. Prefer narrow named read tools; use the current Toolset Schema.

When using project Agent Skills, obtain the live skill list before loading details and keep the loaded skill limited to the current topic. If no matching skill exists, continue with live MCP inspection and the relevant UE foundation topic.

Use live MCP inspection and the current UE Toolset Schema when a detailed topic requires project-specific facts.
