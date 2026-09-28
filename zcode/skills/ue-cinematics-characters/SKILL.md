---
name: ue-cinematics-characters
description: UE Sequencer, Cine Camera, and MetaHuman workflows. Use for orbit, dolly, tracking, shot cuts, keyframes, focus, or MetaHuman eye, makeup, skin, body Conform, assembly, and auto-rig changes.
---

# UE Cinematics and Characters

Read the target Level Sequence or character's canonical path, version, current bindings/structure, and live Schema first. Never infer tracks, bindings, channels, or MetaHuman parts from asset names.

## Sequencer

Read Display Rate, Tick Resolution, Playback/Work Range, bindings, tracks/sections, Camera Cut, subject/camera transforms, focal length, sensor, focus, and dirty state. Convert seconds to explicit frame numbers. State center/radius/height/arc/revolutions, keyframe values, interpolation, and composition constraints. After writing, recheck tracks, frames, Camera Cut, ranges, and errors, then preview a few representative frames.

## MetaHuman

List and inspect the character, appearance components, materials/textures, and project plugins before planning eye, makeup, skin, body, or assembly changes. Distinguish direct character-asset writes, an Editor-side commit, and external asynchronous work. For async work use submit/status/cancel; submission is not completion. Return changed objects and fields, dirty/saved state, rollback availability, and external-job status.

Use ue-python-api only when named tools are insufficient or batching is required. Follow the current live Schema for detailed Sequencer and MetaHuman fields.
