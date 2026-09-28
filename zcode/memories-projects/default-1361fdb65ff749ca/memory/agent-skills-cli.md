---
name: agent-skills-cli
description: npx skills CLI (skills.sh) natively recognizes ZCode; installs into
  ~/.zcode/skills — usage flags and which skills are installed (find-skills,
  guizang-ppt-skill)
metadata:
  node_type: memory
  type: reference
  originSessionId: sess_1566a8eb-94ad-49ab-881f-e7b6893f05f3
---

The vercel-labs `skills` CLI (skills.sh, run via `npx -y skills …`) **natively recognizes ZCode** as an agent.

Install pattern that works here: `npx -y skills add <github-repo> --skill <name> -g -a zcode -y` — `-g` global (user-level), `-a zcode` targets ZCode, `-y` skips prompts. Files land **copied** (not symlinked) into `C:\Users\xujinya\.zcode\skills\<name>\`, which is exactly where ZCode loads user skills from; they appear in the skill list only after restarting the session. `npx skills find "<query>"` searches the ecosystem; `--skill <name> -l` lists a repo's skills without installing.

Installed (2026-09-28): `find-skills` (vercel-labs/skills — skill-discovery entry point) and `guizang-ppt-skill` (op7418 — 歸藏's deck skill).

**guizang-ppt-skill outputs web HTML only** (horizontal-swipe single-file deck; style B "Swiss" = template-swiss.html with 22 locked S-layouts, IKB/柠檬黄/柠檬绿/安全橙 themes; full workflow in its SKILL.md). It **cannot produce .pptx**. When the user asks for a PPT, they mean an editable **.pptx file** (stated explicitly 2026-09-28: "最后的输出要是一个pptx文件") — build it with the `presentations:pptx` skill; guizang is only for web decks or design reference. PPTX toolchain see [[pptx-toolchain]].
