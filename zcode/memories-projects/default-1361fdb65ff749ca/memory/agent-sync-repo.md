---
name: agent-sync-repo
description: ZCode/Codex 跨端环境同步仓库 Agent-sync 的位置、结构与日常用法
metadata:
  node_type: memory
  type: project
  originSessionId: sess_bbba03cb-5532-4f6f-9046-f70ad3e42d4c
---

GitHub 私有仓库 **xjinya-xiangwu/Agent-sync**（本机 checkout 于 `C:\Users\xujinya\Agent-sync`），2026-09-28 建成，用于跨端、**跨 agent**（ZCode/Codex/Claude Code/Cursor/OpenCode/Gemini/Kimi/DSH）同步工作环境。

**Why:** 用户多端多 agent 使用，需要 skills/MCP/hooks/全局指令/memory 的统一同步机制；会话历史与插件缓存不同步（有价值结论已提炼为 rollout_summaries 与 memory）。

**How to apply:**
- skills 单源四端 junction：`~/.zcode|/.codex|/.claude|/.cursor/skills` → `~/Agent-sync/zcode/skills`——增删 skill 直接改仓库工作区，`sync.ps1 push` 即上传
- 全局指令四端部署：`global/AGENTS.md` → `~/.codex/AGENTS.md`、`~/.claude/CLAUDE.md`、`~/.gemini/GEMINI.md`、`~/.config/opencode/AGENTS.md`（改动应改仓库源再跑 install）
- MCP 唯一事实源：`mcp/mcp-servers.json`，各家格式翻译规则在 `mcp/FORMATS.md`；`setup-mcp.ps1 -Targets cursor,vscode,opencode,claude` 自动生成
- 仓库根 `AGENTS.md` 是任意 agent 的部署引导——新机器 clone 后对任何 agent 说"按 AGENTS.md 恢复环境"即可
- 日常：`~/Agent-sync/sync.ps1 pull|push`；**用户指示：内容更新完后直接 push 到 GitHub，无需再确认**
- 新机器：clone → install.ps1/sh → 手动填三处密钥（`${GITHUB_MCP_PAT}`/`${BAIDU_PAN_MCP_TOKEN}`/`${CODEX_BEARER_TOKEN}`）→ lark-mcp 等按 mcp-servers-setup/README 重装
- 真实 token 永不进仓库；`mcp/generated/` 已 gitignore
- workspace 里的独立 git 仓库（如 ai-coldstart → AI-cold-start）不入 Agent-sync，由各自远端同步（sync.ps1 已用 /XD 排除，防止 gitlink 空指针）

相关：[[zcode-plugin-install-layout]]、[[github-account-auth]]、[[new-provider-relay-mimo]]
