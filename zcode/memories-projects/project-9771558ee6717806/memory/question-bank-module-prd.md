---
name: question-bank-module-prd
description: 题库(Benchmark)模块设计 PRD 已完成，位于 E:\Zcode\安全相关\PRD-题库模块设计.md，7 个子模块 + 6
  条用户动线 + 9 个用户故事
metadata:
  node_type: memory
  type: project
  originSessionId: sess_1b504c96-effe-43f0-979b-6d157ac9c97a
---

2026-09-21 完成中心化平台题库模块设计 PRD（V0.1 设计稿），交付于 `E:\Zcode\安全相关\PRD-题库模块设计.md`。

- 依据：三版本 PRD V1.3 评审版（中心化平台版 §12 收敛决策：Benchmark 不单列顶级导航，题库管理收敛在数据中心；两角色）。
- 模块：M1 题库目录与版本 / M2 标签（三层：L1 双层系统标签+L2 治理 facet+L3 项目标签）/ M3 抽样策略（可命名可复用，快照四元组 seed+strategy_version+data_version+label_version）/ M4 上传下载（四段校验管线）/ M5 容器环境（ImageAsset/EnvironmentTemplate/TaskEnvironment 三层 + 四口径 + 预检）/ M6 判分器与兼容矩阵 / M7 审计横切。
- 原型差距：testing-platform 的 data-center.tsx 是纯静态卡片 + 4 个无功能按钮；evaluation-center.tsx 抽样只有本地 state 的 stratified/all。
- 2026-09-21 题库模块前端已实现（本地预览通过）：`src/api/question-bank.ts`（确定性内存 store + 真实候选/去重/抽样/预检计算）、`src/hooks/useQuestionBank.ts`（react-query，轮询 tick 推进预检/导入任务）、`src/locale/question-bank.ts`（gateway 式双语 COPY）、`src/pages/data-center/components/` 面板 + 重写的 data-center.tsx 页签壳。
- 2026-09-21 二轮：页签级权限分野落地——管理员 6 页签（总览/题库目录/标签中心/抽样策略/环境与判分/导入导出），外部用户 4 页签（我的数据集/可用题库/我的抽样策略/导出申请），外部账号无视角切换钮（管理员保留预览切换）。API 层加 owner 归属：项目上传生成自建数据集（ownerProjectId=proj-vendor-a）、策略分 platform/project。PRD §7.5 user story 已按角色重写为 QB-A01~A06 / QB-U01~U05。
- 2026-09-21 三轮（PRD 补齐 + UI 统一）：回流动线落地——`LabelCorrection` 修正建议（复核回流），标签中心新增「复核回流·修正建议」审核卡（采纳草稿版立即生效、已发布版记入下一版本不回写）+ L2 facet 分布卡（CWE/语言/难度 BarList，getVersionFacets）；目录版本详情新增「与上一版本对比」diff（种子加了 ExploitGym v0.9-beta 与 custom-web 2026.08 两个 retired 前代版本，独立 version id 如 ver-custom-web-v08）；总览待办加 pendingCorrections。UI 统一：页头角色徽章（复用 data.center.adminMode/userMode key）、删除旧版死 CSS 227 行（.summary/.catalog/.detailDialog 等）、所有面板统一 qb* 组件体系。PRD 补 QB-A07 故事。相关测试 120 全绿。
- 验证基线：dashboard/review/tasks 等 12 个测试失败为仓库既有问题（git stash 基线复跑同样失败），与题库改动无关。预览 http://127.0.0.1:5188/data。
- 2026-09-22 UI 溢出修复（d218e66，已部署）：dashboard-board.module.less 顶层裸 `table { min-width: 760px }` 全局泄漏（CSS Modules 只哈希类选择器），scope 到 `.tableWrap table` + qbTable 防御性 `min-width: 0`。教训：元素选择器是全局的，顶层裸元素规则会泄漏全应用；用浏览器枚举 styleSheets 找无类前缀规则排查。
- 2026-09-22 双主题改造（4c3e0b0，已部署）：index.css 语义 token 层——:root 亮色默认，html[data-theme='dark'] 暗色；--range-*/--board-* 变量名变为语义 token 别名；~800 处硬编码颜色三遍迁移；index.html 预绘制主题（localStorage 'app-theme'，默认 light）；useTheme hook + 切换按钮；补定义 --range-warning。教训：变量别名层是换主题的杠杆；分类器迁移后必须逐页双主题目检。
- 2026-09-24 移除复现方向（b32a30f，已部署）：产品决定——真实题库无复现类题，评测方向从 4 个收敛为 3 个（发现/利用/修复）。清除范围：EvaluationDirection 联合类型、DIRECTION_ORDER、L1 词表与筛选轨、目录 chip、判分器兼容条目、CyberGym 题库元数据、任务向导方向选项与 CyberGym L1-3 复现数据集行、evaluation-center 文案。「可复现」（质量描述词）不受影响。locale 漏 key 检查教训同前。
- 2026-09-24 目录管理权分野（9e9f1fa，已部署）：管理员=题库增删改+版本管理——「新建题库」（DRAFT 空版本等导入管线）、详情弹窗含编辑信息/版本管理列表（逐版本发布/下线/删除版本）/新建版本/危险区删除题库（守卫：全部版本 draft/retired 且 referencedRuns=0）；外部用户=筛选+只读详情（按钮「查看详情」vs 管理员「管理」）。教训：Dialog 的 aria-label 即标题，确认框用 findByRole('dialog',{name}) 定位最稳；locale 漏 key 时 translate 返回 key 本身。
- 2026-09-23 目录/工作台重设计（e623e2e，已部署）：①全站亮色背景统一为设置页配方——body 用 --page-grid token 画 32px 网格（settings/login 容器改透明）；②题库目录参考 OpenDataLab 重设计——左侧筛选轨（类型/方向/领域/生命周期）+ 卡片网格（名称+code、描述、方向彩色 chip、领域灰 chip、任务/环境/Run 三统计、最新版本行），版本时间线并入详情弹窗；③标签中心重构为 Label Studio 式标注工作台——左题目队列（状态点：绿=已标/蓝=有建议/灰=未标）、中标注画布（dedup key/CWE/语言/难度元数据）、右领域选择面板（保存/保存并下一题/清除），新增 applySampleLabel API（已发布版本拒绝）；④按产品决定移除「环境与判分」页签（面板已删，预检 API 保留供任务管线）。98 测试全绿。注意：Shell PATH 曾被替换为 Windows 分号格式导致 node/python 丢失——恢复方式是显式 export POSIX PATH（/usr/bin:/bin + WinGet node 路径 + Python bin）。
- 2026-09-21 四轮（pm-critic 对抗评审 + 修复）：14 findings（P0×3/P1×5/P2×4/P3×2）。P0 修复——F-01 冻结记录（FrozenTaskList + 面板表 + 去 /tasks?type=code 链接）+ PRD 接口契约节；F-02 外部数据集验证闭环（我的数据集显示「平台验证队列中」+ 管理员环境页待验证队列可直接发起预检）；F-03 授权语义（isVersionAuthorized：published ∧ internal∨本项目所有；目录/策略选择器/导出下拉三处过滤；导出对象改下拉禁自由文本）。P1——外部默认页改「可用题库」+ 卡片展示方向×领域组合 chips；重放校验按钮；多方向 scope 提示；容量演示口径。PRD 补 F-05 回流产生端依赖、F-09 预览切换定位、F-10 KR→验收证据映射表、F-12 P0 清单补 M6。教训：重写 visibleSets 过滤时丢过 setId 匹配导致越权泄漏（测试+浏览器双重复现才抓到）——改权限过滤必须跑 T5 类断言。相关测试 97 全绿。
- 提取的 PRD 文本副本在 `E:\Zcode\安全相关\_prd_*.txt`（来自 docx 附件，供后续会话快速引用）。

相关：[[testing-platform-gateway-refactor]]、[[research-before-refactor-preference]]
