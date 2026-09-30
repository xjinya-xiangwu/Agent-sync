# AGENTS.md — Agent-sync 仓库引导（任何 agent 在本仓库工作时必读）

本仓库是 **SIAE（Self-Improving Agent Environment，github.com/xjinya-xiangwu/SIAE）的 L3b 跨端同步底座**（决策 D14），同时服务**跨端、跨 agent 的工作环境同步**（ZCode / Codex / Claude Code / Cursor / OpenCode / Gemini CLI / Kimi CLI / DSH / WorkBuddy 等通用）。你（agent）在新机器上被要求"恢复/同步工作环境"时，按本文件执行。

**SIAE 语境下的职责**（顶层设计单一事实源：AIHOT fork `planning/sync-plane-design.md`）：

1. **跨端凭证加密同步**：凭证只以 age 加密形态存在于 `credentials/*.enc`；解密只发生在设备端本地配置，**明文永不入库、永不进对话、永不进日志**。agent 只执行"解密→填充→校验"，不回显任何值。
2. **MCP 能力快速拉齐**：`mcp/mcp-servers.json` 是 SIAE 全项目 MCP 的 canonical 注册表（唯一事实源）；`mcp/FORMATS.md` 是翻译规则。与 asp（AI-cold-start）的契约：**asp 写结构（服务器条目，token 留占位符），本仓库填值（解密后填充占位符）**——字段级互斥，都不覆盖对方写入。
3. **既有同步职能**：skills / 全局指令 / memory / workspace（workspace 同步范围须过 SIAE §4.0 数据边界：工作层 W 可同步，私人层 P 禁止）。

## 仓库是什么

| 路径 | 内容 | 部署方式 |
|---|---|---|
| `global/AGENTS.md` | 统一全局指令（用户画像/偏好/工作纪律/环境速查，已去重融合） | 复制或链接到各 agent 的全局指令位置 |
| `zcode/skills/` | 96 个用户级 skills（SKILL.md 标准） | junction/symlink 到各 agent 的 skills 目录 |
| `zcode/cli.config.template.json` | ZCode 配置模板（plugins/mcp/hooks，含占位符） | 填密钥后合并到 `~/.zcode/cli/config.json` |
| `zcode/memories-projects/` | ZCode 项目 memory（4 个 key） | 复制到 `~/.zcode/cli/memories/projects/`（缺啥补啥，不覆盖已有） |
| `codex/config.toml.template` | Codex 配置模板（provider/plugins/trust，含占位符） | 填密钥后存为 `~/.codex/config.toml` |
| `codex/memories/`、`codex/imported-memories/` | Codex memory（含会话提炼 rollout_summaries） | 复制到 `~/.codex/`（缺啥补啥） |
| `codex/hooks.json` | Codex hooks（ai-memory） | 本机无则复制 |
| `codex/mcp-servers-setup/` | lark-mcp / office MCP 重装说明与启动脚本 | 按其 README 重装（运行时不入库） |
| `mcp/mcp-servers.json` | **canonical MCP 注册表**（所有 agent 的唯一事实源） | 按 `mcp/FORMATS.md` 翻译成各 agent 格式，或跑 `setup-mcp.ps1` |
| `projects/workspace-default/`、`projects/trusted-projects.md` | workspace 业务文档与两端项目索引 | 复制到 `~/.zcode/workspace/default/`（缺啥补啥） |

## 在新机器上部署（按顺序）

1. **跑安装脚本**（推荐）：Windows `powershell -ExecutionPolicy Bypass -File install.ps1`；macOS/Linux `./install.sh`。脚本做：skills junction、全局指令分发、memory/workspace 补齐。幂等，可重复跑。
2. **填密钥**（脚本不会自动做，含密钥）：两个 config 模板里的 `${GITHUB_MCP_PAT}`、`${BAIDU_PAN_MCP_TOKEN}`、`${CODEX_BEARER_TOKEN}` 占位符换成真实值（值来自用户/密码管理器，**不要让用户把 token 粘贴到对话里**）。
3. **MCP 配置**：按 `mcp/FORMATS.md` 把 `mcp/mcp-servers.json` 翻译成当前 agent 的格式；或跑 `setup-mcp.ps1 -Targets cursor,vscode,opencode,claude` 自动生成。
4. **本地 MCP server**：需要 lark-mcp / office MCP 时按 `codex/mcp-servers-setup/README.md` 安装。

## 硬性规则

- **密钥永不入库、永不进对话**：任何真实 token/PAT/secret（含**任何片段**）不得写入本仓库任何文件、commit 信息或 agent 输出。模板里只允许完整 `${PLACEHOLDER}` 占位——禁止为"方便对照"内嵌真实片段（2026-09-30 事件教训，见 sync-plane-design §8）。凭证跨端一律走 `credentials/*.enc`（age 加密，M-S2）。
- **不覆盖原则**：memory 与 workspace 文件只增不覆盖（本机已有的可能比仓库新）；config 模板需用户确认后再合并。
- **幂等**：所有安装/同步操作必须可重复执行不产生副作用。
- 明确**不同步**：会话原始记录（sessions/rollout 原文）、插件缓存、`~/.zcode/v2/` 凭证。

## 各 agent 的文件去向（速查）

| Agent | 全局指令 | Skills | MCP |
|---|---|---|---|
| Codex | `~/.codex/AGENTS.md` | `~/.codex/skills` | `~/.codex/config.toml` |
| Claude Code | `~/.claude/CLAUDE.md` | `~/.claude/skills` | `claude mcp add-json` / `.mcp.json` |
| Cursor | `.cursor/rules/*.mdc`（项目）或 User Rules | `~/.cursor/skills` | `~/.cursor/mcp.json` |
| OpenCode | `~/.config/opencode/AGENTS.md`（项目根 `AGENTS.md` 同样生效） | `npx skills add -a opencode` 或手动 | `~/.config/opencode/opencode.json` |
| Gemini CLI | `~/.gemini/GEMINI.md` | 无原生 skills，用 MCP/提示 | VS Code 风格 mcp 配置 |
| Kimi CLI | 项目 `KIMI.md`/`AGENTS.md` | `npx skills` 或手动 | `.kimi/mcp.json`（CC 格式） |
| ZCode | 自带 auto-memory（本仓库 `zcode/memories-projects` 即其数据） | `~/.zcode/skills` | `~/.zcode/cli/config.json` |
| DSH/其他 | 把 `global/AGENTS.md` 内容粘贴进其 instructions/系统提示 | 手动复制 SKILL.md 目录 | 支持 MCP 标准则用 CC 格式片段 |

若你的 agent 不在上表：读 `global/AGENTS.md` 与 `mcp/FORMATS.md`，按其通用片段接入即可——仓库里全部是纯 markdown/JSON，无专有格式依赖。

## 日常同步

- 本机改动入库：`sync.ps1 push`（Windows）
- 拉取最新到本机：`sync.ps1 pull`（= git pull + 重跑 install.ps1）
- config 模板手动维护：本机 plugins/MCP/hooks 实质变更后 diff 更新模板再 push。
