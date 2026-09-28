# Agent-sync

跨端、**跨 agent** 的工作环境同步仓库（私有）。任何 agent（ZCode / Codex / Claude Code / Cursor / OpenCode / Gemini CLI / Kimi CLI / DSH 等）在新机器上 clone 本仓库后，按 `AGENTS.md` 引导即可恢复统一的工作环境。

同步：用户级 Skills、MCP 配置、hooks、全局指令、memory、workspace 项目文档。
不同步：会话原始记录、插件缓存、凭证密钥（见下）。

## 仓库结构

```
Agent-sync/
├── AGENTS.md                    # ★ 仓库引导：任何 agent 打开本仓库的入口说明书
├── CLAUDE.md / GEMINI.md / KIMI.md / .cursor/rules/
│                                # 各 agent 的入口薄指针（都指向 AGENTS.md）
├── global/AGENTS.md             # 统一全局指令（用户画像/偏好/纪律/环境速查，去重融合版）
├── zcode/
│   ├── skills/                  # 96 个用户级 skills（SKILL.md 开放标准）
│   ├── cli.config.template.json # ZCode 配置模板（plugins/mcp/hooks，占位符脱敏）
│   └── memories-projects/       # ZCode 项目 memory（4 个 key）
├── codex/
│   ├── config.toml.template     # Codex 配置模板（占位符脱敏）
│   ├── hooks.json               # Codex hooks（ai-memory）
│   ├── memories/                # Codex memory（含 rollout_summaries 会话提炼）
│   ├── imported-memories/       # kimi-work 导入记忆
│   └── mcp-servers-setup/       # lark-mcp / office MCP 重装说明与启动脚本
├── mcp/
│   ├── mcp-servers.json         # ★ canonical MCP 注册表（唯一事实源）
│   └── FORMATS.md               # 各 agent 的 MCP 配置格式对照 + 通用片段
├── projects/
│   ├── workspace-default/       # workspace 业务文档
│   └── trusted-projects.md      # 两端项目目录索引
├── install.ps1 / install.sh     # 一次安装（junction + 指令分发 + memory 补齐），幂等
├── setup-mcp.ps1 / setup-mcp.sh # 从注册表生成 cursor/vscode/opencode/claude 的 MCP 配置
└── sync.ps1                     # 日常 push/pull
```

## 新机器部署（三条路径任选）

**路径 A —— 交给任何 agent（推荐）**：clone 后对 agent 说"按本仓库 AGENTS.md 恢复环境"。ZCode / Codex / Claude Code / OpenCode / Kimi CLI 会自动读取 AGENTS.md；Cursor 读 `.cursor/rules/`；Gemini 读 GEMINI.md；其余 agent 手动把 AGENTS.md 喂给它即可。

**路径 B —— 跑脚本**：

```powershell
# Windows
powershell -ExecutionPolicy Bypass -File install.ps1     # skills junction + 全局指令 + memory
.\setup-mcp.ps1 -Targets cursor,vscode,opencode,claude   # 生成各 agent MCP 配置
```
```bash
# macOS / Linux
./install.sh && ./setup-mcp.sh
```

**路径 C —— 纯手动**：按根 `AGENTS.md` 的表格逐项复制/链接。

部署后手动填密钥（脚本不会自动做）：模板中的 `${GITHUB_MCP_PAT}`、`${BAIDU_PAN_MCP_TOKEN}`、`${CODEX_BEARER_TOKEN}` 占位符换成真实值，再合并到各 agent 的配置文件。

## 兼容矩阵

### 全局指令（`global/AGENTS.md` 分发到哪）

| Agent | 部署位置 | install 脚本覆盖 |
|---|---|---|
| Codex | `~/.codex/AGENTS.md` | ✅ |
| Claude Code | `~/.claude/CLAUDE.md` | ✅ |
| Gemini CLI | `~/.gemini/GEMINI.md` | ✅ |
| OpenCode | `~/.config/opencode/AGENTS.md` | ✅ |
| Cursor | 项目 `.cursor/rules/` 或 User Rules（全局无文件约定） | 项目级（本仓库自带） |
| Kimi CLI / DSH / 其他 | 项目根 `AGENTS.md`/`KIMI.md` 均被识别；或把 `global/AGENTS.md` 粘贴进其 instructions 设置 | 项目级（本仓库自带） |
| ZCode | 自带 auto-memory 体系，数据即 `zcode/memories-projects/` | ✅（数据补齐） |

### Skills（`zcode/skills/` 链接到哪）

| Agent | 位置 | install 脚本覆盖 | 备选 |
|---|---|---|---|
| ZCode | `~/.zcode/skills` | ✅ junction/symlink | — |
| Codex | `~/.codex/skills` | ✅ | — |
| Claude Code | `~/.claude/skills` | ✅ | — |
| Cursor | `~/.cursor/skills` | ✅ | — |
| OpenCode / Kimi CLI / 其他 | 无统一全局目录 | ❌ | `npx skills add <本地路径> -a <agent>`，或复制所需 skill 的 SKILL.md 目录 |

Skills 是 SKILL.md 开放标准（纯 markdown + 资源文件），任何支持该标准或支持"读取 markdown 指令"的 agent 都能直接用。

### MCP 配置

所有 agent 以 `mcp/mcp-servers.json` 为唯一事实源，翻译规则见 `mcp/FORMATS.md`（含每个 agent 的配置文件位置、格式差异、通用片段）。`setup-mcp.ps1` 自动生成 cursor / vscode / opencode / claude 四种格式；Codex 与 ZCode 用各自的模板。

### Memory / 项目信息

- ZCode 项目 memory：`zcode/memories-projects/` → `~/.zcode/cli/memories/projects/`（只增不覆盖）
- Codex memory（含 12+ 份会话提炼 rollout_summaries）：`codex/memories/` → `~/.codex/memories/`
- 其他 agent 没有文件型 memory 的，跨 agent 上下文由 `global/AGENTS.md` 承载（用户画像、偏好、工作纪律、环境速查已全部提炼在内）
- workspace 业务文档与项目索引：`projects/`

## 日常同步

```powershell
.\sync.ps1 pull   # git pull + 重跑 install（分发最新 skills/指令/memory）
.\sync.ps1 push   # 收集本机 memories / workspace 回仓库 + commit + push
```

config 模板手动维护：本机 plugins/MCP/hooks 实质变更后，diff 更新模板再 push。**永远不要把真实 token 写进本仓库。**

## 明确不同步的内容

- 会话原始记录（sessions / archived_sessions / rollout 原文）——有价值的结论已提炼进 `codex/memories/rollout_summaries/` 与各 memory；
- 插件缓存与运行时——插件启用列表在 config 模板里，本体按需重装；
- 凭证（`~/.zcode/v2/`、`~/.codex/secrets/`、`credentials.env`、各 token）——新机器登录/重配一次；
- `E:\Zcode\skills-archive`（66 个商业 skill 归档）——体量与授权原因，按需手动搬。
