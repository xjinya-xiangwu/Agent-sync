---
name: agent-sync-repo
description: ZCode/Codex 跨端环境同步仓库 Agent-sync 的位置、结构与日常用法
metadata:
  node_type: memory
  type: project
  originSessionId: sess_bbba03cb-5532-4f6f-9046-f70ad3e42d4c
---

GitHub 私有仓库 **xjinya-xiangwu/Agent-sync**（本机 checkout 于 `C:\Users\xujinya\Agent-sync`），2026-09-28 建成，用于跨端同步 ZCode 与 Codex 工作环境。

**Why:** 用户多端使用 ZCode/Codex，需要 skills/MCP/hooks/全局指令/memory 的同步机制；会话历史与插件缓存不同步（有价值结论已提炼为 rollout_summaries 与 memory）。

**How to apply:**
- 本机 `~/.zcode/skills` 是指向 `~/Agent-sync/zcode/skills` 的 **junction**——增删 skill 直接改仓库工作区，`sync.ps1 push` 即上传
- `~/.codex/AGENTS.md` 是仓库 `global/AGENTS.md` 的部署副本（统一融合版全局指令），改动应改仓库源再部署
- 日常：`~/Agent-sync/sync.ps1 pull|push`；新机器：clone 后跑 `install.ps1` + 手动填三处密钥（`${GITHUB_MCP_PAT}`/`${BAIDU_PAN_MCP_TOKEN}`/`${CODEX_BEARER_TOKEN}`）
- 配置模板手动维护；真实 token 永不进仓库（ZCode `cli/config.json` 内有明文 PAT/token，属本机文件不入库）
- 原 skills 目录备份于 `~/.zcode/skills.backup-20260928-174500`，确认无问题后可删

相关：[[zcode-plugin-install-layout]]、[[github-account-auth]]、[[new-provider-relay-mimo]]
