# Agent-sync

> **SIAE · L3b 跨端同步底座**（[Self-Improving Agent Environment](https://github.com/xjinya-xiangwu/SIAE) 子模块，决策 D14）。
> 两大重点职责：①跨端凭证**加密**安全同步（age 信封加密，明文永不入库/入对话）；②各端各 agent 的 **MCP 能力快速拉齐**（canonical 注册表 → 按端生成 → 值填充 → doctor 体检）。
> 同时保留原有职能：用户级 Skills、全局指令、hooks、memory、workspace 项目文档的跨端同步。
> 顶层设计（单一事实源）：[AIHOT fork `planning/sync-plane-design.md`](https://github.com/xjinya-xiangwu/AIHOT/blob/main/planning/sync-plane-design.md)。

任何 agent（ZCode / Codex / Claude Code / Cursor / OpenCode / Gemini CLI / Kimi CLI / DSH / WorkBuddy 等）在新机器上 clone 本仓库后，按 `AGENTS.md` 引导即可恢复统一的工作环境。

## 与 asp（AI-cold-start）的分工契约

| | asp（AI-cold-start） | agent-sync（本仓库） |
|---|---|---|
| 职责 | **装什么、装到哪**：skills / AGENTS.md / MCP 服务器条目（结构） | **值怎么安全跨端**：凭证加密同步、占位符填充、连通体检 |
| 凭证 | 安装器永不收集 key，token 留占位符 | 加密同步的唯一通道；解密只发生在设备端 |

字段级互斥：asp 写结构、agent-sync 填值；两边都"只增不覆盖 + 备份可回滚"。新机器标准顺序：**先 asp 部署包（结构就位）→ 再 agent-sync `open` 填值 → `doctor` 体检**。

同步：用户级 Skills、MCP 配置结构、hooks、全局指令、memory、workspace 项目文档、**凭证（仅 age 加密形态，`credentials/*.enc`）**。
不同步：会话原始记录、插件缓存、任何明文凭证、私人层 P 数据（SIAE §4.0）。

## 仓库结构

```
Agent-sync/
├── AGENTS.md                    # ★ 仓库引导：任何 agent 打开本仓库的入口说明书
├── CLAUDE.md / GEMINI.md / KIMI.md / .cursor/rules/
│                                # 各 agent 的入口薄指针（都指向 AGENTS.md）
├── global/AGENTS.md             # 统一全局指令（用户画像/偏好/纪律/环境速查，去重融合版）
├── credentials/                 # ★ 凭证加密同步分区（M-S2）：age 公钥 / inventory / *.enc
├── zcode/
│   ├── skills/                  # 用户级 skills（SKILL.md 开放标准）
│   ├── cli.config.template.json # ZCode 配置模板（plugins/mcp/hooks，纯占位符脱敏）
│   └── memories-projects/       # ZCode 项目 memory
├── codex/
│   ├── config.toml.template     # Codex 配置模板（纯占位符脱敏）
│   ├── hooks.json               # Codex hooks
│   ├── memories/                # Codex memory（含会话提炼 rollout_summaries）
│   ├── imported-memories/       # kimi-work 导入记忆
│   └── mcp-servers-setup/       # lark-mcp / office MCP 重装说明与启动脚本
├── mcp/
│   ├── mcp-servers.json         # ★ canonical MCP 注册表（唯一事实源，全 SIAE 共用）
│   └── FORMATS.md               # 各 agent 的 MCP 配置格式对照 + 通用片段
├── projects/
│   ├── workspace-default/       # workspace 业务文档（同步范围须过 SIAE §4.0 数据边界）
│   └── trusted-projects.md      # 两端项目目录索引
├── install.ps1 / install.sh     # 一次安装（junction + 指令分发 + memory 补齐），幂等
├── setup-mcp.ps1 / setup-mcp.sh # 从注册表生成各端 MCP 配置（M-S3 扩至 8 端）
└── sync.ps1                     # 日常 push/pull；M-S2 起 + seal/open/doctor（凭证加密同步）
```

## 新机器部署（三条路径任选）

**路径 A —— 交给任何 agent（推荐）**：clone 后对 agent 说"按本仓库 AGENTS.md 恢复环境"。ZCode / Codex / Claude Code / OpenCode / Kimi CLI 会自动读取 AGENTS.md；Cursor 读 `.cursor/rules/`；Gemini 读 GEMINI.md；其余 agent 手动把 AGENTS.md 喂给它即可。

**路径 B —— 跑脚本**：

```powershell
# Windows
powershell -ExecutionPolicy Bypass -File install.ps1     # skills junction + 全局指令 + memory
.\setup-mcp.ps1 -Targets cursor,vscode,opencode,claude   # 生成各 agent MCP 配置
# M-S2 起追加：
.\sync.ps1 open                                          # 解密凭证 → 填充占位符
.\sync.ps1 doctor                                        # 各服务连通体检
```
```bash
# macOS / Linux
./install.sh && ./setup-mcp.sh
```

**路径 C —— 纯手动**：按根 `AGENTS.md` 的表格逐项复制/链接。

凭证恢复（M-S2 起的正规通道）：`sync.ps1 open` 解密 `credentials/*.enc` 并填充；私钥通过一次性渠道带到新设备（当面 / 密码管理器安全笔记 / 分两段传输），**永不入库**。详见 `credentials/README.md`（M-S2 落地时创建）与 [加密同步设计](https://github.com/xjinya-xiangwu/AIHOT/blob/main/planning/sync-plane-design.md)。

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

所有 agent 以 `mcp/mcp-servers.json` 为唯一事实源，翻译规则见 `mcp/FORMATS.md`（含每个 agent 的配置文件位置、格式差异、通用片段）。`setup-mcp.ps1` 现生成 cursor / vscode / opencode / claude 四种格式（M-S3 扩至含 zcode / codex / workbuddy 共 8 端）；Codex 与 ZCode 亦可用各自模板。**与 asp 的关系**：asp 也可写 MCP 结构（adapter 矩阵），两边同源 canonical registry；本仓库负责值填充与体检。

### Memory / 项目信息

- ZCode 项目 memory：`zcode/memories-projects/` → `~/.zcode/cli/memories/projects/`（只增不覆盖）
- Codex memory（含 12+ 份会话提炼 rollout_summaries）：`codex/memories/` → `~/.codex/memories/`
- 其他 agent 没有文件型 memory 的，跨 agent 上下文由 `global/AGENTS.md` 承载（用户画像、偏好、工作纪律、环境速查已全部提炼在内）
- workspace 业务文档与项目索引：`projects/`（同步范围须过 SIAE §4.0 数据边界——工作层 W 可同步，私人层 P 禁止）

## 日常同步

```powershell
.\sync.ps1 pull   # git pull + 重跑 install（分发最新 skills/指令/memory）
.\sync.ps1 push   # 收集本机 memories / workspace 回仓库 + commit + push
# M-S2 起：
.\sync.ps1 seal   # 凭证暂存 → age 加密封存 → push（暂存即删）
.\sync.ps1 open   # 拉取 → 解密 → 占位符填充各端配置
.\sync.ps1 doctor # 凭据验证 + 端点握手，逐服务 PASS/FAIL/WARN + 过期提醒
```

config 模板手动维护：本机 plugins/MCP/hooks 实质变更后，diff 更新模板再 push。**永远不要把真实 token（或任何真实片段）写进本仓库——模板只允许完整占位符。**

## 明确不同步的内容

- 会话原始记录（sessions / archived_sessions / rollout 原文）——有价值的结论已提炼进 `codex/memories/rollout_summaries/` 与各 memory；
- 插件缓存与运行时——插件启用列表在 config 模板里，本体按需重装；
- **任何明文凭证**（`~/.zcode/v2/`、`~/.codex/secrets/`、`credentials.env`、各 token）——凭证只以 age 加密形态存在于 `credentials/*.enc`（M-S2 起）；
- 私人层 P 数据（健康信息、敏感偏好等，SIAE §4.0）；
- `E:\Zcode\skills-archive`（商业 skill 归档）——体量与授权原因，按需手动搬。

## 里程碑

| 里程碑 | 内容 | 状态 |
|---|---|---|
| M-S1 仓库转型 | SIAE L3b 定位、模板去密钥残留、转私有 | ✅ 2026-10-01 |
| M-S2 加密同步 v0 | age 集成、credentials/ 分区、seal/open，两台真机互测 | 待排 |
| M-S3 MCP 拉齐 | setup-mcp 扩 8 端 + open 填值 + doctor 体检 | 待排 |
| M-S4 接入主线 | 与 ONBOARDING-V2 W2 凭据钱包联通 | 随 W2 |

## 许可

私有仓库，SIAE 内部约定；不对外分发。
