---
name: unreal-engine
description: Unreal Engine entry point. Use for Unreal Engine/UE5 projects and live Editor work involving Actors, Blueprints, Materials, Niagara, Sequencer, Control Rig, UMG, Gameplay Ability System, Static/Skeletal Meshes, Content Browser assets, Outliner objects, PlayerStart, or .uproject files. Also trigger on UE asset prefixes such as BP_, WBP_, M_, MI_, NS_, CR_, SK_, SM_, and ABP_, or UE C++ types such as UObject and UPROPERTY. Use for project understanding, inspection, configuration, startup, and operation; select one relevant UE skill and do not load every skill.
---

# Unreal Engine Entry Point

This is a lightweight router, not a complete operations manual. Once enabled, the plugin's MCP gateway tools are available. There is no sessionStart preload: load only the narrowest relevant entry and add one operations skill for a complex task. Use this UE context even when the user does not explicitly say "Unreal" but the request contains the signals above.

## Routing

- First connection, unopened Editor, port/tool failure, project configuration, logs, or Toolset/Schema: ue-connection
- Actors, materials, textures, imports, saves, or batch scene writes: ue-editor-operations
- UE objects, coordinates, materials, Blueprints, or persistence concepts: ue-foundations
- Post-import takeover, dependencies, bounds, pivots, LOD/Nanite, or collision: ue-assets
- Arrays/scattering, dusk/night, lighting, or level-space health: ue-scene-lookdev
- Blueprint, Niagara, or PCG: ue-content-systems
- Sequencer, Cine Camera, or MetaHuman: ue-cinematics-characters
- Project profile, audit, or delivery checks: ue-project-quality
- Complex batching, conditional work, or explicit Python: ue-python-api

## Shared call principles

Confirm tools and parameters through the live Schema. Discover tools through list_toolsets → search_tools → describe_tool → call_tool. Separate reads and writes; perform a structured review after writes; do not automatically replay an uncertain write. Follow manifest skillInstructions for authorization, loopback, saving, and confirmation rules.

Do not treat offline metadata or Schema snapshots as current UE facts. Do not parse or modify .uasset or .umap directly, force-kill the Editor, or replace a loopback endpoint with a remote address.
