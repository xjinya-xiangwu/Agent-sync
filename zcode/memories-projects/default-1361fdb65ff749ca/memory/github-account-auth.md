---
name: github-account-auth
description: gh CLI 2.101.0 已装并以 fine-grained PAT 认证为
  xjinya-xiangwu；AI-Range-Demo 与 AI-Native-Cyber-Range 均有 Contents 写权限
metadata:
  node_type: memory
  type: project
  originSessionId: sess_bc4a13cc-abfc-490c-a190-2b740cfb030e
---

2026-09-18 通过 winget 安装 GitHub CLI 2.101.0（路径 `C:\Program Files\GitHub CLI\gh.exe`，本会话 PATH 未刷新，需用全路径调用），用用户提供的 fine-grained PAT（github_pat_...，存于 Windows keyring）完成 `gh auth login`，账号为 **xjinya-xiangwu**。已实测该 token 对 `AI-Range-Demo` 和 `AI-Native-Cyber-Range` 两个公开仓库均有 Contents 写权限（建分支+提交+删分支的写测试通过）；另有 `testing-platform`、`pm-skills` 仓库。前两个即用户所说 "cyber range demo" 相关仓库（AI 攻防演练场，见 [[ai-security-range-prd]] 相关工作）。

**Why:** 后续 GitHub 仓库操作（提交 PRD/文档、建 PR、改 Pages）可直接用 gh，不必重复认证或试探权限。

**How to apply:** 用全路径调 gh；写操作直接做，但 fine-grained PAT 只覆盖已勾选仓库/权限，其他仓库或 Release/secrets 等操作若 403 需提示用户扩 token 范围。
