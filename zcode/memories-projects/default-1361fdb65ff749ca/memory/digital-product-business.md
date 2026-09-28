---
name: digital-product-business
description: 2026-09 起探索的"一人+Agent"数字产品副业方向，已收敛的产品矩阵、关键裁决与最新转向（AI 冷启动包）
metadata:
  node_type: memory
  type: project
  originSessionId: sess_682c71d1-9b0a-4953-883f-15a8a3d9eb06
---

用户在探索纯信息/软件交付、可重复售卖、高专业性、不做定制、接受薄利多销的数字产品生意（一人+Agent，在职副业）。资源：跨行业专业能力（见 [[kurt-professional-background]]）+ 近乎无限 token + AI knowhow + 充分空闲时间。

## 当前主推（2026-09-28 第二轮转向后）

**家族 A（新版）：AI 冷启动包**（用户拍板，取代原题库/PRD/作品集文档线；方案已迭代至 v1.2）——≤30 元买断"AI 工具从零到能干活"。架构（v1.1 起升级为"asp 迷你包管理器 + 每周更新源"三层）：静态托管 registry（index.json + 版本化包）/ 用户侧 asp 命令（install/update，零依赖）/ 适配器部署到各 agent。按职业分包（AI 产品经理/开发者/内容创作三包首发），每包 = 精选 skills(10-15) + 角色 AGENTS.md + prompts + **MCP 配置层**（v1.2 纳入；零 key 原则：默认只装零 key 本地 MCP，key 类注释态）。

用户硬性要求（v1.2 确认）：①每周更新 + 用户一键 update；②兼容主流 agent：Claude Code、Zcode、Codex、Cursor、opencode、Kimi(Kimiwork)、DSH=**DeepSeek Harness**（DSH/Kimi/Codex/Cursor/opencode 路径待 W2 实测）；③自动探测 agent；④一键安装无视环境零用户操作（zip 解压双击即装，内置离线快照，Win 用 .bat 拉 PowerShell，mac/linux 用 .command/.sh）。适配器=adapters/<agent>.json（探测路径+skills 目录+AGENTS.md 变换+MCP 配置格式），新 agent 加 JSON 即可且可经 index.json 远程下发；发版前全 agent 冒烟测试，不过则降级"仅 AGENTS.md 模式"。防盗：URL 不宣传+更新通知只发付费群+买家 ID 水印；v2 再上 license key API。定价 29.9 含 3 个月周更 / 早鸟 19.9 / 续更 9.9/季。PM 包首发；旧家族 A 知识降维复用为 PM 包自产 skills。Sourcing：自产≥50%，license gate 进周更流水线（白名单 MIT/Apache/CC0/CC-BY），不可再分发只给链接，MCP 只收官方/高星仓库。执行方案：`C:\Users\xujinya\.zcode\workspace\default\家族A-AI冷启动包-执行方案.md`（含 §3 用户旅程七步与安装/更新时序图、§9 指标：update 活跃率≥50% 为续费先行指标、MCP 零报错率单列监控）。

**家族 B：政企 AI 项目文档包**（执行方案已写：同目录`家族B-政企AI项目文档包-执行方案.md`）——SKU1 验收标准与评测指标模板(399/999)首发 → SKU2 技术方案书模板(499/1999，含虚构能源集团示例+评标注解) → SKU3 POC 模板(299)。获客核心杠杆：标书代写商 30% 佣金分销。B 线合规红线：评标注解仅限公开评标办法+个人判断，发布前过在职利益冲突自查。

**首发确认**：金融营销内容审核对照清单+合成案例包（《金融产品网络营销管理办法》2026-09-30 实施窗口）。

## 关键市场信号（2026-09-28 检索）

- AGENTS.md 于 2026-09-18（Claude Code v2.1.277）起成 Codex/Cursor/Claude Code 三家事实标准——"一份 agents.md 通用"的产品承诺刚成立，本身是首发营销点。
- 付费精选 Skill 包尚是市场空白（公开生态全是免费库）；付费点必须立在策划筛选+开箱即用+安装体验+持续更新，非内容本身。
- 2026 政务 AI 招标增长且标准转向合规性/可追溯/实际效果（家族 B 的需求依据）。

## 已否决方向

Agent 评测中心原型套件（用户明确砍掉：技术重、需求弱、付费意愿低）；Steam 情报；定制服务类（申报辅导/标书代做/工作流搭建，违背零定制约束）。原家族 A 高价文档线（99-499 元）被用户以"定价过高"否决，转向 30 元以下冷启动包。

## 方法论（融合自 ChatGPT 报告）

定价是测试价非市场均价；第 4 周验证门槛 = 5-10 笔非友情购买 + 3 人无协助使用；买家普遍要求"改成我们公司用" = 模式失败信号，换客户不接定制；授权分层（个人/团队/嵌入/再分发）；token 用于找反例和交叉检查而非堆页数。

## 托管选型结论（已向用户说明其意义）

registry 托管 = "每周一键更新"承诺的物理载体，asp update 可用性 = 托管地可达性。建议：OSS+CDN 主源（月 5-20 元、防盗链、需个人实名）+ GitHub Pages 备源，asp 双源 failover（主源 3s 超时切备）。待用户确认。

## Notion 项目库（2026-09-28 建）

Notion「个人知识库」下建「🚀 AI冷启动」目录（page 3e962c74-ab72-815b-9fe7-f963fa70e7b2）：01 项目背景与市场分析 / 02 产品方案 v1.2（主文档）/ 03 家族B-政企AI项目文档包 + 待决策 checklist（可勾选）。方案迭代后需同步更新 Notion 版本。

## 决策与进度（2026-09-28 六项决策落定 + W1 基建完成）

六项已决：托管 OSS 主源+GH Pages 备源；MCP 零 key 原则（key/OAuth 类注释态+注册引导，不代办不收 key）；无 agent 用引导面板；定价 29.9/早鸟 19.9/续更 9.9 季/全家桶 59.9 做；lite 上 GitHub；DSH/Kimi 授权自行调研。**遗留唯一决策：商品页专业身份口径（W3 前定）**。

DSH 调研回填：`~/.dsh/`（$DSH_HOME 官方确认）、AGENTS.md 原生支持、MCP 默认不启用（沙箱设计）→ 适配器用 template-only 策略。Kimi 形态 = KimiWork + Kimi CLI（支持 MCP），路径 W2 实测。

**W1 基建完成**：开发仓库 `C:\Users\xujinya\.zcode\workspace\default\ai-coldstart\`——asp.ps1/asp.sh（install/update/detect/agents/status）、3 适配器（claude-code/zcode/dsh）、registry/index.json 协议 v0.1、双击入口。沙箱实测全过：探测、skills 部署、AGENTS.md managed-section 幂等（`<!-- asp:begin/end -->` 标记）、MCP merge 仅新增不覆盖、备份回滚。Zcode 实证：skills=`~/.zcode/skills/`、MCP=`~/.zcode/cli/config.json` 的 `mcp.servers` 键。**开发坑**：①asp.ps1 必须带 UTF-8 BOM（PS5.1 无 BOM 按 ANSI 解析中文会语法错误）；②写用户 JSON 配置必须无 BOM（[IO.File]::WriteAllText + UTF8Encoding($false)）；③Git Bash /tmp 与 PS 解析不一致，跨 shell 用 Windows 绝对路径。W2 待办：PM 包 6 skills 生产、Codex/Cursor/opencode/Kimi 适配器实测、mac 侧 asp.sh 实测、OSS 开通填 mirrors、发版脚本。
