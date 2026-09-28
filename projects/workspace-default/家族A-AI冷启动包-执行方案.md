# 家族 A：AI 冷启动包 — 执行方案 v1.3

> 定位一句话：≤30 元买断"AI 工具从零到能干活"——自动识别你机器上的 agent，一键装好精选 skills + 通用 agents.md + 常用 MCP 配置 + prompts，每周自动更新。
> v1.3 变更（2026-09-28 六项决策落定）：①托管确认 OSS 主源 + GitHub Pages 备源；②MCP 零 key 原则确认 + OAuth/注册引导细化；③未检测到 agent 用引导面板；④定价确认（29.9/19.9/9.9 季/全家桶 59.9 做）；⑤lite 版上 GitHub；⑥DSH 调研回填（Kimi 部分回填，具体路径留 W2 实测）。W1 基建已启动。

## 决策记录（2026-09-28）

| 决策项 | 结论 |
|---|---|
| 托管 | OSS+CDN 主源 + GitHub Pages 备源，asp 双源 failover（用户已确认） |
| MCP 原则 | 零 key 默认启用；key/OAuth 类注释态 + **引导用户自行注册/授权**（README 一页式引导：去哪注册、哪个字段填哪） |
| 无 agent 环境 | 引导面板（各 agent 官网链接 + 重跑提示），不替装 |
| 定价 | 29.9 含 3 个月周更；早鸟 19.9；续更 9.9/季；**全家桶 59.9 做** |
| lite 版 | GitHub（star 资产累积，复刻者拿不走更新） |
| DSH/Kimi | 已自行调研（见 §1.2 回填）；Kimi 配置目录待 W2 实测 |
| 商品页身份口径 | **未决**（W3 上架前必须定） |

---

## 0. 市场信号（2026-09-28 检索，结论不变）

1. 付费精选 Skill 包无人占位；付费点 = **策划筛选 + 一键安装/更新 + 开箱即用 + 持续更新**。
2. AGENTS.md 自 2026-09-18 起成为跨工具事实标准——"一份 agents.md 通用"是首发卖点。

---

## 1. 产品架构：asp + registry + MCP 层

```
┌─ registry（静态托管，周更）────────────────────────────┐
│ index.json（版本/清单/哈希/适配器下发）                  │
│ packs/<role>/vX.Y.Z/（skills、AGENTS.md、prompts、mcp/） │
└─────────────────────────────────────────────────────┘
        ↑ asp update（增量拉取，30 秒）
┌─ asp（用户侧，零依赖、双击即用）────────────────────────┐
│ 购买交付物 = 一个 zip：asp 安装器 + 当前版本离线快照      │
│ Windows: 双击 setup.bat（引导 PowerShell，系统自带）      │
│ mac/linux: 双击 setup.command / setup.sh                 │
└─────────────────────────────────────────────────────┘
        ↓ 自动探测 → 部署
   CC / Zcode / Codex / Cursor / opencode / Kimi / DeepSeek Harness
   （skills 目录 + AGENTS.md 落位 + MCP 服务器配置）
```

### 1.1 "无视环境、零用户操作"的安装设计

- **交付物即安装器**：买家拿到 zip → 解压 → 双击 → 完成。不要求装 Python/Node/Git，不要求开终端敲命令（终端自动拉起）。
- **离线快照优先**：zip 内置当前版本全量内容，首次安装不依赖网络（不赌 registry 当时的可达性）；装完才提示"以后双击 update 即可周更"。
- **探测→默认全装**：扫描全部已知 agent 特征路径，检测到的默认全装（可交互选择）；一个都没检测到 → 给出引导面板（各 agent 官网一键链接 + "装好后重新运行本包"），不自动替用户装 agent（边界）。
- **MCP 依赖检测**：MCP 服务器多依赖 npx/uvx。asp 检测到缺失时：默认只装"零依赖零 key"的 MCP；检测到 node/uv 的机器上才启用 npx/uvx 类；缺失时在完成报告里给出一行官方安装命令（winget/brew 一键可装），不静默替装系统级软件（安全边界）。
- 更新同样零操作：双击 `update.bat/.command` 或（进阶用户）`asp update`。

### 1.2 多 Agent 适配器矩阵（含 MCP）

适配器 = `adapters/<agent>.json`：探测特征 + skills 部署路径 + AGENTS.md/规则落位与变换 + MCP 配置文件格式与写入方式。新增 agent = 加一个 JSON，可经 index.json 周更远程下发。

| Agent | 探测特征 | skills 路径 | 指令文件 | MCP 配置 | 状态 |
|---|---|---|---|---|---|
| Claude Code | `~/.claude/` | `~/.claude/skills/` | `~/.claude/CLAUDE.md`（项目 AGENTS.md 亦读） | `.mcp.json` / 全局 mcpServers | 已知可用 |
| Zcode | `~/.zcode/` | `~/.zcode/skills/` | 全局 agents.md | Zcode MCP 配置 | 已知可用（自有实测床） |
| Codex | `~/.codex/` | 待实测 | `~/.codex/AGENTS.md` | config（toml）待实测 | W2 实测 |
| Cursor | `~/.cursor/` | 规则目录/兼容开关 | `.cursor/rules/*.mdc` | `~/.cursor/mcp.json` | W2 实测 |
| opencode | `~/.config/opencode/` | opencode skills 目录待实测 | 原生 AGENTS.md | opencode.json mcp 字段 | W2 实测 |
| Kimi (Kimiwork) | `~/.kimi/`（待实测确认） | 待实测 | AGENTS.md 待确认 | Kimi CLI 支持 MCP（官方确认），配置格式待实测 | W2 实测（形态已明：KimiWork agent 产品 + Kimi CLI 编码助手） |
| DeepSeek Harness (DSH) | `~/.dsh/`（**官方确认** `$DSH_HOME` 默认值） | `.dsh/skills/`（第三方信息，全局 vs 项目级 W2 实测） | **AGENTS.md 原生支持**（官方确认，workspace 根；CLAUDE.md 亦读） | patch 机制（`~/.dsh/cordis.patch.yml`）；**MCP 默认不启用**（沙箱安全设计）→ 只提供模板+启用引导，不自动写入 | 2026-09-28 官方文档调研回填；仓库 deepseek-ai/deepseek-harness |

> 兼容性保障机制：适配器矩阵本身作为"支持列表"每周更新并展示在商品页；每个 agent 的每次发版都在真实环境冒烟测试（W2 起建立 8 个 agent 的测试环境清单），未通过测试的 agent 在该版本自动降级为"仅 AGENTS.md 模式"而不是装一半失败。

### 1.3 MCP 层设计

每个角色包含 `mcp/` 目录：该角色的推荐 MCP 清单 + 各 agent 格式的配置片段模板。

**零 key 原则（默认启用 vs 模板注释 + 引导）**：
- 默认启用：零 API key、本地可跑的 MCP（context7 文档查询、sequential-thinking、memory、filesystem/git/sqlite 等）——保证"装完即能跑，零配置零报错"。
- 引导启用（2026-09-28 决策细化）：需要 key/OAuth 的（搜索类、图片类）写进配置模板但保持注释状态；README 提供**一页式注册引导**——去哪注册、免费额度多少、拿到 key 后填在配置文件第几行、改完重启生效。引导用户自行完成注册/授权，我们不代办、不收 key。
- DSH 特例：其 MCP 默认不启用（安全设计），适配器只提供 cordis.patch.yml 片段模板 + 启用步骤说明。

**分角色 MCP 清单（v1 草案）**：
- AI 产品经理包：context7、sequential-thinking、memory、filesystem
- AI 开发者包：context7、sequential-thinking、git、filesystem、playwright（浏览器，npx）
- AI 内容创作包：memory、filesystem +（注释态）搜索/图片类

**安全与合规**：只收录官方仓库或高星知名 MCP；manifest 记录仓库、star 数、抓取日期、license；MCP 更新同 skills 走周更流水线与 license gate。

---

## 2. 每周更新机制

生产侧（稳态每周 1–2 小时人时）：周四 Agent 自动抓源（awesome 清单/GitHub trending/官方插件市场/MCP 生态）→ license 白名单自动过滤 → 质量粗评 diff 报告 → 周五人工周审 → 发版（bump 版本、打包、更新 index.json、推送托管）→ 更新群通知。

用户侧：双击 update → 拉 index.json → 版本对比 → 增量下载 → 哈希校验 → 部署到全部已装环境。MCP 清单与适配器也随版本下发。

版本：minor=每周内容，major=年度大版（重新收费）。

---

## 3. 用户旅程与产品交互链路（核心专节）

### 3.1 旅程七步与每步的系统支撑

| # | 旅程阶段 | 用户体验 | 背后产品组件 |
|---|---|---|---|
| 1 | **触达** | 刷到小红书帖"AI 工具装完就不会用？"／知乎"AGENTS.md 通用时代"科普／GitHub 搜到 lite 版 | 内容系统（周更帖）、lite 免费版（GitHub）、同事.skill 仓库导流 |
| 2 | **决策** | 点进商品页：30 秒终端演示 GIF（自动探测 3 个 agent→进度条→完成）、支持矩阵表、周更日志截图、价格 29.9 | 商品页素材（自己录制的 asp install 实况）、UPDATES.md 作为"产品活着"的证据 |
| 3 | **购买** | 闲鱼/淘宝下单 → 自动发货：zip 下载链接 + 进群卡片（水印=买家ID） | 电商平台自动发货、更新群（私域底仓） |
| 4 | **安装** | 解压 → 双击 setup → 看到探测结果（"发现 Claude Code ✓ Cursor ✓"）→ skills/AGENTS.md/MCP 全部落位 → 完成报告 + "重启 agent 生效" | asp 安装器（离线快照）、适配器矩阵、MCP 配置生成器 |
| 5 | **首用** | 打开 README"装完后第一件事"：三条示例指令（如 PM 包："用 prd-drafting 帮我起草一个 XX 功能的 PRD"）→ 立刻看到效果 | 各 skill 的 SKILL.md 内置引导、prompts.md 精选条目 |
| 6 | **周更** | 群里收到"v1.3 已发布：新增 2 个 skills，淘汰 1 个" → 双击 update → 30 秒完成 | registry + index.json + asp update、更新群推送 |
| 7 | **续费/复购** | 3 个月后收到 9.9/季 续更邀请（附更新历史=价值证据）；"AI 求职包上新"推送老客优惠 | UPDATES.md 版本历史、扩展包上新、群运营 |

### 3.2 背后交互链路（安装一次的完整时序）

```
用户双击 setup.bat
  → asp 启动（PowerShell，零依赖）
  → 扫描 adapters/*.json 的探测路径（~/.claude、~/.zcode、~/.dsh…）
  → 命中：CC ✓ Zcode ✓ DSH ✓（未命中：Kimi、Cursor…）
  → 读取 packs/ai-pm/（本地离线快照，不联网）
  → 对每个命中 agent：
      ① 复制 skills/<12个> → 该 agent 的 skills 目录
      ② AGENTS.md 变换落位（Cursor→mdc 包装，CC→CLAUDE.md 或 AGENTS.md）
      ③ MCP：检测 node/uv → 写入零 key MCP 配置；key 类保持注释
  → 生成完成报告（装了什么/在哪/怎么回滚）+ 桌面留 update 快捷方式
  → 提示重启 agent 生效
```

```
用户双击 update.bat（每周）
  → 拉 registry index.json（主源 OSS，3 秒超时切备源 GitHub Pages）
  → 对比本地 _state.json 版本
  → 增量下载变更文件（含新适配器）
  → 哈希校验 → 部署到全部已装环境 → 报告"本周新增/淘汰"
```

### 3.3 旅程设计的两个转化关键点

- **第 4→5 步是口碑形成点**：装完 5 分钟内跑出第一个好结果，决定好评/退款。所以"三条示例指令"必须开箱即惊艳——每包的示例要实测挑选，不是凑数。
- **第 6 步是续费形成点**：update 活跃率 ≥50% 是核心指标（§9），每周让用户"看见"更新价值（群通知写清"新增了什么、淘汰了什么、为什么"）。

---

## 4. 三个首发包内容（v1.2 含 MCP）

### 4.1 AI 产品经理包（首发）
自产 skills ×6：prd-drafting（12 章模板树）、prd-review（30 项自查）、competitor-analysis、user-story、metric-design、ai-eval-design（复用旧家族 A 知识资产）。收集 3–5 个 MIT skills。AGENTS.md：PM 工作流。prompts ≈40 条。MCP：context7、sequential-thinking、memory、filesystem。

### 4.2 AI 开发者包
自产 ×5：commit-convention、code-review-checklist、debugging-workflow、api-design-review、test-generation。AGENTS.md：工程规范。prompts ≈40 条。MCP：context7、sequential-thinking、git、filesystem、playwright。

### 4.3 AI 内容创作包
自产 ×5：xiaohongshu-post、wechat-longform、title-generator、content-calendar、image-prompt。AGENTS.md：人设/平台规范。prompts ≈50 条。MCP：memory、filesystem +（注释态）搜索/图片。

### 4.4 扩展 roadmap：AI 求职 / AI 销售 / AI 学生 / AI 运营包。

---

## 5. Sourcing 合规与安全

1. 自产 ≥50%；收集仅限 MIT/Apache/CC0/CC-BY，保留版权声明，manifest 记录来源/日期/哈希。
2. license gate 进流水线（自动白名单过滤，非白名单拒入）。
3. 不可再分发内容：manifest 链接推荐制，不打包。
4. MCP 只收官方/高星仓库，同受 license gate；不静默安装系统级软件（node/uv 缺失只提示官方安装命令）。
5. 疑似搬运仓库一律不收。

---

## 6. 托管选型的意义（专节回答）

**registry 托管地 = "每周一键更新"这个核心承诺的物理载体。asp update 的可用性，等于托管地的可达性。**选型影响的四件事：

| 影响维度 | 说明 |
|---|---|
| 更新成功率 | GitHub Pages 国内访问不稳——用户双击 update 却超时失败，核心卖点直接变差评来源。这是选型的第一意义：**用每月 5–20 元买"更新承诺的可用性"** |
| 防盗能力 | OSS+CDN 支持 Referer 防盗链/签名 URL（v2 可升级按 license key 签名），纯静态免费托管没有这层控制 |
| 合规成本 | OSS 需实名（个人可办）；Gitee Pages 免费但有人工审核与历史停服风险；境内托管内容本身需自查（我们全部内容自有/开源合规，风险低） |
| 成本 | OSS+CDN 月成本约 5–20 元（百级用户规模内），相对 29.9 客单可忽略 |

**结论（建议）**：OSS+CDN 做主源（快、稳、防盗链、可演进）+ GitHub Pages 做备源（海外用户与灾备），asp 内置双源 failover（主源 3 秒超时自动切备源）。这个架构让"托管选错"的后果被兜底，但主源仍选体验最好的。

---

## 7. 生产排期（v1.2）

| 周 | 动作 | 人工 |
|---|---|---|
| W1 | 架构基建：registry/index.json 协议、适配器框架（CC+Zcode 先行）、asp 双脚本（install/update/离线快照）、MCP 配置生成器、OSS+备源开通 | 15h |
| W2 | PM 包生产 + 端到端实测；**8 agent 测试环境搭建**（重点补 DSH/Kimi/Codex/Cursor/opencode 路径实测）；冒烟机制 | 14h |
| W3 | PM 包上架早鸟 + lite 版 + 首发内容 3 篇；开发者包、创作包生产 | 14h |
| W4 | 两包上架 + 全家桶 + 周更首跑（v1.1 发版）+ 复盘 | 8h |

稳态：每周五 1–2h 周审发版；每 4 周一个新角色包。

---

## 8. 获客链路

1. lite 免费版（GitHub/网盘）引流。
2. 小红书/即刻每周 3 帖；知乎"AGENTS.md 通用时代"科普吃信息差。
3. 同事.skill 流量池（只推 lite 版，口径兼容开源社区）。
4. 闲鱼/淘宝成交，自动发货。
5. asp install 终端演示 GIF = 商品页主图；周更帖（"本周新增 5 个，筛掉 3 个"）持续暗示产品活着。

---

## 9. 验证指标与淘汰信号（W4 复盘）

继续信号：
- PM 包早鸟 50 份 ≤2 周；三包合计 ≥120 单；
- 安装成功率 ≥90%（含 MCP 零报错率 ≥80%——MCP 是最容易翻车的环节，单列监控）；
- update 活跃率：发版 7 天内 ≥50% 买家执行更新（续费先行指标）；
- lite→付费 ≥5%；入群率 ≥60%。

淘汰/调整信号：
- 安装求助集中于某 agent（>40%）→ 修适配器，不代装；
- MCP 报错集中（node/uv 缺失）→ 收紧默认 MCP 清单到纯零依赖；
- update 活跃率 <20% → 改双周发版或强化更新可见性；
- "有没有 XX 包"集中 → 排产扩展包。

---

## 10. 决策状态（v1.3：六项已决，一项遗留）

已决（见开头决策记录表）：托管（OSS+备源）、MCP 零 key+引导、引导面板、定价（含全家桶做）、lite 上 GitHub、DSH/Kimi 授权调研（DSH 已回填）。

**遗留**：商品页专业身份口径（真名背书 vs 匿名品牌）——W3 上架前必须定。Kimi/Codex/Cursor/opencode 的具体路径 W2 实测。
