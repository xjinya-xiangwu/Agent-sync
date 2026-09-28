# 用户长期记忆与协作指令（全局统一版）

> 本文件由 Agent-sync 仓库分发，同时供 ZCode 与 Codex 使用。
> 这些是背景性记忆，用于减少重复询问、保持连续性；与用户当前说法冲突时，以用户当前说法为准。

## 用户画像

- **Kurt（徐劲亚）**，AI 产品经理，关注安全可信的 AI 产品与网络安全产品。职业履历：AI 实验室 → 伏羲 → 蚂蚁 → CBNData（详见 ZCode memory `kurt-professional-background`）。
- 兼职独立游戏制作人，正在制作一款 Steam 发售的 friendslop 类独立游戏（Sail Off，工作目录 `E:\GAME`，先读该目录下的 AGENTS.md）。
- 具备医学信息检索能力和基因检测报告解读能力，能基于专业检测结果提出针对性治疗选项问题。
- 运营"一人 + Agent"数字产品副业：AI PM 文档线、政企 AI 项目文档包、金融营销案例包等产品矩阵（详见 ZCode memory `digital-product-business`）。
- 常用工作范围：`E:\GAME`、`C:\Users\xujinya\Documents\AI LAB\安全`、`C:\Users\xujinya\Documents\AI LAB\GPT`、`E:\Codex\Software`、`E:\Zcode`。

## 沟通与思维偏好

- 主要使用中文交流。面对信息不透明的复杂议题时理性审慎，从宏观渠道逐步深入到可行性验证与个性化方案；对风险信息主动要求证据支撑，对非正规渠道保持审视。
- **文学-哲学交叉分析**：习惯把具体文学作品对接哲学框架（存在主义／海德格尔），追问存在论意义而非情节复述，呈现「抽象概念 → 作品印证 → 哲学深化」的递进结构。
- 偏好结构化输出：信息检索类问题希望得到可核查的来源与渠道，而非笼统结论；重视真实交付链接与明确的状态边界。

## 工作方式与纪律

- **工具优先级**：用用户指定的连接器／CLI／MCP，而不是用浏览器替代；更新实际源页面／表格，提供可访问的交付 URL，然后回读所写内容。
- **Mock 边界**：把文档／原型／demo 的完成与灰盒、QA、后端、真实数据、部署、玩家验证证据分开表述；绝不把 Mock／仿真结果当作真实能力呈现。
- **PRD 工作法**：按要求使用只读专家 subagent；按「角色 × 功能/流程 × 权限 × 输入/输出 × 范围」组织需求；安全术语与 Mock 边界显式化。"Not review-ready" 意味着要补用户故事、验收标准、红队假设、依赖、交付门、页面/状态/事件/数据契约，而不是表面润色。
- **配置与安装**：执行允许的安装与具体验证，而不是只返回指令；保留配置备份；密钥不进 config 文件、输出和记忆。当配置 workaround 牺牲了某项能力时，端到端测试可用回退并报告遗留项。
- **证据边界**：静态代码/README/历史分析 ≠ 运行时/E2E/真实平台验证，表述时显式区分。架构对比时先比实际功能边界与实现成本，再给架构选择，而非泛泛的特性罗列。
- **权限与凭证**：权限/SSO 错误和过期设备码是边界，不重试过期路径；重新生成凭证或改用可访问的批准回退。

## Windows 环境速查

- 本机 shell 为 cmd／Git Bash；git 2.55.0.3 已装（老 shell 需全路径调用）。杀软是 360（Defender 停用）。
- gh CLI 2.101.0 已认证为 **xjinya-xiangwu**；可写仓库包括 AI-Range-Demo、AI-Native-Cyber-range（AI 攻防演练场），另有 testing-platform、pm-skills。PAT 存于 Windows keyring，不落 config。
- Windows 上验证 DOCX：从干净源新建版本，用 Word COM 导出 PDF，转图片逐页检查；不要依赖 LibreOffice 或系统 python-docx 已安装。
- ZCode 插件手动安装目录与三个配置文件位置见 ZCode memory `zcode-plugin-install-layout`；66 个商业 skill 已归档于 `E:\Zcode\skills-archive`。
- Lark CLI 双 profile：shanghai-ai（徐劲亚）／ xiangwu（kurt，测"独立游戏"知识库）。
- 供应商：Boyue 中转配置在 `~/.zcode/v2/provider_config.json`；mimo-v2.6-pro 的 max_tokens 上限 131072，超出会报 400 "Param Incorrect"。

## 领域笔记：RMC-6236 与临床试验查询渠道

- **RMC-6236（通用名 Daraxonrasib）**：Revolution Medicines 开发的口服泛 RAS 抑制剂，靶向多种 RAS 突变亚型；2025 年获 FDA 批准用于 KRAS G12C 突变的非小细胞肺癌，后续适应症扩展至胰腺癌等实体瘤。曾就保险覆盖、原料药获取进行多轮深入调研。参考：https://www.revolutionmedicines.com/pipeline/daraxonrasib/
- **药物临床试验登记与信息公示平台**（NMPA 主办）：https://www.chinadrugtrials.org.cn/
- **中国临床试验注册中心（ChiCTR）**（WHO ICTRP 认证一级注册机构）：http://www.chictr.org.cn/
- 完整调研主线（临床试验／保险／原料药／基因检测）见 ZCode memory `rmc-6236-research`。

## 领域笔记：文学与哲学

- **《漫长的告别》**：雷蒙德·钱德勒 1953 年代表作，硬汉派侦探小说经典。围绕私家侦探菲利普·马洛与落魄贵族特里·伦诺克斯的友谊展开，核心主题是信任的瓦解与告别的代价。曾从海德格尔存在主义视角分析，特别关注「说一声再见，就是死去一点点」与「向死而在」「此在」「常人」等概念的关联。
- **雷蒙德·钱德勒**：美国硬汉派侦探小说大师，以冷冷硬派文风、洛杉矶 noir 背景和对战后美国社会腐败的批判著称。

## 记忆维护

- 相关主题出现时，主动结合以上背景，避免重复询问已知信息。
- 发现新的稳定偏好或事实时，与这些记忆合并，而不是另起一份。
- 用户若明确否认某条记忆，应停止使用该条并更新本文件。
- 会话原始记录（sessions／archived_sessions／rollout）不跨端同步；有长期价值的结论应沉淀到本文件或各端 memory。
