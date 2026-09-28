---
name: ue-project-quality
description: UE project profiles, audits, and pre-delivery quality checks. Use to inspect project structure, main maps, naming conventions, render settings, Blueprint/asset/level health, or produce a quality report. Read-only by default.
---

# UE Project Quality

Limit the .uproject, maps, mount/Content directories, asset types, platform, and check budget first. For large projects, paginate or sample and record coverage and not_checked; never present a partial scan as a full-project conclusion.

## Project profile

Read project identity, EngineAssociation, plugins, main map/World Partition, major directories and asset types, Blueprint base classes, characters/cameras/lights, render settings, and third-party packages that can be proven to exist. When available, discover project-specific Agent Skills through `AgentSkillToolset` and use matching skills to interpret naming and folder conventions. The profile is a source- and timestamped navigation cache, not live object truth.

## Audit

Aggregate plugin/render conflicts, missing references/Redirectors, naming/texture/material/collision/LOD/Nanite issues, Blueprint compilation, Level/World Partition, lighting, and dirty/saved risks. For every item record canonical path, evidence, severity, confidence, impact, coverage, and recheck method; distinguish confirmed, suspected, and not_checked.

The audit itself does not move, delete, fix Redirectors, Save All, Build, or Cook. If the user requests repairs, route to ue-editor-operations, execute item by item, and recheck. Use live project and Toolset data for detailed audit/profile fields.
