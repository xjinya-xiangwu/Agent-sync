---
name: ue-content-systems
description: UE Blueprint, Niagara, and PCG content systems. Use to inspect or modify Blueprint graphs or compile state, particles/VFX, Niagara parameters, PCG Graph/Volume/Spline assets, tree scattering, or generation failures.
---

# UE Content Systems

Confirm the project, canonical asset/component paths, and the current live Toolset first. Read the current state before writing; never guess nodes, pins, parameters, or outputs when a tool is missing, the Schema is incomplete, or a field is unclear.

## Blueprint

Distinguish class defaults/CDO from instance values. Read the Generated Class, Construction Script, graph nodes/pins, references, and compile errors; after writing, compile again and read errors and dirty state.

## Niagara

Distinguish System/Emitter, bound components, exposed parameters, bounds, collision/simulation, visibility, and compile state. After changes, verify parameters, activation, bounds, compile messages, and package state.

## PCG

Distinguish a regenerable Graph edit from one-off Actor placement. Make inputs (Surface/Spline/Volume), filters, density/count limits, deterministic Seed, Transform, collision/slope rules, and output ownership explicit. Bound generation or cleanup and verify the actual result.

Prefer named MCP tools for single steps. Read ue-python-api only for batching, graph topology, or conditional work. Use the current live Toolset Schema for detailed Blueprint, Niagara, and PCG fields.
