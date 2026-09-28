---
name: pptx-toolchain
description: PPTX build/render toolchain on this machine — LibreOffice 26.8.0
  installed (PATH registered), pptxgenjs + python-pptx available, pptxgenjs pPr
  bug fix pattern
metadata:
  node_type: memory
  type: reference
  originSessionId: sess_1566a8eb-94ad-49ab-881f-e7b6893f05f3
---

Toolchain for the `presentations:pptx` skill on this machine (set up 2026-09-28):

- **LibreOffice 26.8.0** installed via winget (`TheDocumentFoundation.LibreOffice`) at `C:\Program Files\LibreOffice\program\soffice.exe`; registered on user PATH with setx — but already-open shells need the full path. The pptx skill mandates LibreOffice for render/QA (headless pptx→pdf/png) and forbids substituting PowerPoint/WPS.
- Direct single-slide pptx→PNG works: `soffice --headless --convert-to 'png:impress_png_Export:{"PixelWidth":{"type":"long","value":1920},"PixelHeight":{"type":"long","value":1080}}' --outdir . file.pptx` (no pdftoppm/poppler needed; harmless "Could not find platform independent libraries" warning on stderr).
- **pptxgenjs** installed via local npm (was `npc-deck/build/`; global npm require does NOT resolve without NODE_PATH). **python-pptx** installed via pip. Node v24.19, Python 3.14.4.
- pptxgenjs gotcha hit in practice: inline-mixed rich-text arrays (multiple runs, no breakLine) emit one `<a:pPr>` per run → schema-invalid; LibreOffice renders fine but PowerPoint garbles. Fix by post-processing the zip: rewrite slide XML dropping every `<a:pPr>` after the first inside each `<a:p>` (pattern in `npc-deck/build/fix_ppr.py`). Or avoid inline mixing entirely with side-by-side text boxes.
- QA loop that worked: python-pptx walk (out-of-bounds / text-box overlap / leftover placeholders) → LibreOffice render → visual-judge subagent.

Working example: `C:\Users\xujinya\.zcode\workspace\default\npc-deck\` (gen_pptx.js, fix_ppr.py, qa_pptx.py + 智能NPC-游戏AI落地评估.pptx). Related: [[agent-skills-cli]].
