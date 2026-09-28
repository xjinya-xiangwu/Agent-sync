# Agent-sync

ZCode 与 Codex 的跨端工作环境同步仓库（私有）。同步**用户级 Skills / MCP 配置 / hooks / 全局指令 / memory / workspace 项目文档**；不同步会话原始记录、插件缓存、凭证密钥。

## 仓库结构

```
Agent-sync/
├── install.ps1 / install.sh     # 新机器一次安装（junction + 按需 copy）
├── sync.ps1                     # push / pull 日常同步
├── global/AGENTS.md             # 统一全局指令（融合 Codex AGENTS.md + memory_summary + ZCode memory，已去重）
├── zcode/
│   ├── skills/                  # 96 个用户级 skills（junction 挂载源）
│   ├── cli.config.template.json # ~/.zcode/cli/config.json 脱敏模板（plugins/mcp/hooks）
│   └── memories-projects/       # ~/.zcode/cli/memories/projects/（4 个项目 key）
├── codex/
│   ├── config.toml.template     # ~/.codex/config.toml 脱敏模板（provider/plugins/trust）
│   ├── hooks.json               # ~/.codex/hooks.json（ai-memory hooks）
│   ├── memories/                # ~/.codex/memories/（含 rollout_summaries 会话提炼）
│   ├── imported-memories/       # kimi-work 导入记忆
│   └── mcp-servers-setup/       # lark-mcp / office MCP 重装说明与启动脚本
└── projects/
    ├── workspace-default/       # ~/.zcode/workspace/default 业务文档（家族A/B、npc-deck 等）
    └── trusted-projects.md      # 两端项目目录索引
```

## 新机器四步

1. 安装 ZCode / Codex CLI 并登录一次（凭证不走本仓库）。
2. `git clone git@github.com:xjinya-xiangwu/Agent-sync.git`（建议 clone 到 `~/Agent-sync`，脚本按此默认路径）。
3. PowerShell 运行 `.\install.ps1`（Mac/Linux 用 `./install.sh`）：建立 skills junction、分发 AGENTS.md 与 memories、补齐 workspace 文档。
4. 手动应用配置模板（**含密钥，不自动写入**）：
   - ZCode：把 `zcode/cli.config.template.json` 中 `${GITHUB_MCP_PAT}`、`${BAIDU_PAN_MCP_TOKEN}` 换成真实值后，合并进 `~/.zcode/cli/config.json`；
   - Codex：把 `codex/config.toml.template` 中 `${CODEX_BEARER_TOKEN}` 换成真实值后保存为 `~/.codex/config.toml`；
   - MCP 本地 server 按 `codex/mcp-servers-setup/README.md` 重装。

## 日常同步

```powershell
.\sync.ps1 pull   # git pull + 重放 install（分发最新 skills/AGENTS.md/memories）
.\sync.ps1 push   # 收集本机 memories / workspace 文档回仓库 + commit + push
```

config 模板是**手动维护**的：本机 plugins/MCP/hooks 有实质变更（且不含密钥）时，自己 diff 后更新模板再 push。**永远不要**把真实 token 写进本仓库。

## 明确不同步的内容

- 会话原始记录（`~/.codex/sessions`、`archived_sessions`、ZCode rollout/db）——有价值的结论已在 rollout_summaries 与各 memory 中；
- 插件缓存（`~/.zcode/cli/plugins/cache`、Codex runtimes）——插件启用列表在 config 模板里，本体重装；
- 凭证（`~/.zcode/v2/`、`~/.codex/secrets/`、`credentials.env`、各 token）——新机器登录/重配一次；
- `E:\Zcode\skills-archive`（66 个商业 skill 归档）——体量与授权原因，按需手动搬。
