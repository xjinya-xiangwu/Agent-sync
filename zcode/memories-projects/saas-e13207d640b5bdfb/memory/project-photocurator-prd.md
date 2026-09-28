---
name: project-photocurator-prd
description: PhotoCurator（服装照片智能分组整理 App）：API 版已上线于 pic-classifier；本地模型版（MLX/Qwen3-VL）已真机跑通于 pic-classifier-local，持续学习（Prompt 模块+few-shot 纠错沉淀）已上线；L1 剩余为准确率实测校准
metadata:
  node_type: memory
  type: project
  originSessionId: sess_826a2cf9-3734-41f0-920d-f2bc59f373bf
---

用户正在开发 PhotoCurator：macOS 15.1 本地运行的服装照片整理 App。项目目录 `E:\Zcode\SaaS`（开发机为 Windows，目标用户是 macOS，代码需跨平台）。

核心需求：批量处理 500–1000 张拍摄照片（HEIC/JPG/JPEG/PNG），调用视觉模型识别，**只**按模特姿势、拍照角度、衣着三项做相似度分组（忽略背景/光线/表情），整批约 10 组，人工每组挑 1 张保留；分组文件按内容差异化命名 + 数字后缀。

技术路线：VLM 输出结构化标签（受控枚举 JSON，temperature=0）+ 本地标签聚类；标签按文件内容哈希缓存，重分组不重复计费/推理；图片压到长边 1024px。技术栈：单文件 Python（stdlib http.server + SQLite）+ 单文件浏览器界面（原生 JS，兼容老 Safari——弹窗用 div 不用 `<dialog>`）。

**仓库拆分（2026-09-22）**：
- `pic-classifier`（private）：API 版 v1，已上线可用，不再接收 v2 提交
- `pic-classifier-local`（private）：本地模型版 v2，main 分支，origin 指向它；旧仓以 upstream remote 留存

2026-09-21 已拍板决策（v1）：GLM 5.3 flash 经 boyue 中转站（`http://35.220.164.252:3888/v1`，Key 存于 ZCode `provider_config.json` 的 Boyue provider 下）；原位重命名源文件（`G01_白连衣裙_叉腰_正面全身_001.png`，保留张加 `_精选`，撞名绝不覆盖，undo 存 `~/.photocurator/`）；不兼容 RAW；不申请 Apple 开发者账号，一键安装器 `install_mac.sh`（下载到 `~/PhotoCurator` + 生成 /Applications 的 .app + 后台拉起服务）。

v2 本地模型版（PRD-PhotoCurator-v2-本地模型版.md）2026-09-22 拍板：
1. 识别后端 = 本机 MLX 推理（mlx_vlm.server 子进程，OpenAI 兼容 HTTP，随机端口），架构上只换 base_url，v1 客户端/分组/重命名代码零改动复用
2. 模型默认最小 MVP 档 **Qwen3-VL-4B-Instruct-4bit（3.1GB）**，实测后用户手动升级 8B/30B-A3B（30B 需 ≥48GB 内存）；内存预检只做上限拦截不主动推荐大档
3. **安装器只装程序本体**：MLX 依赖 + 模型权重由 App 内「下载所选」一键自动安装（hf-mirror 默认源，断点续传），模型存 `~/.photocurator/models/`（不放程序目录 `~/PhotoCurator`——安装器升级会 rm -rf，防误删）
4. API 模式保留为可切换选项；v2 默认 local 模式

实施状态：L2 已完成（local_engine.py 模型管理+服务子进程；app.py 接线 /api/local/* 端点、串行调度、JSON 修复重试、content 字符串/对象双兼容；设置页本地模式界面）。测试三套全绿：test_smoke / test_e2e_mock / test_local_engine（伪装推理端验证本地模式全链路，无需真机）。已修关键 bug：shlex Windows 反斜杠、非字符串 content 崩溃、模型目录防误删。

待办（L1 真机实测，需 M4 Max）：适配 mlx_vlm.server 实际启动命令与健康检查端点（现为可配置模板 `{python} -m mlx_vlm.server --model {model_path} --host 127.0.0.1 --port {port}`）、实测三档耗时/JSON 遵从率、金标准集 200 张分组 F1 ≥ 0.85 → 回填 PRD 6.3 性能预算表 → L3 打磨发版。

**2026-09-24 增补**：
- 双版本共存（用户要求与 API 版彻底区分）：本地版 = **PhotoCurator Local**（.app 标识 local.photocurator.local）+ 目录 `~/PhotoCuratorLocal` + **端口 8776-8785 专用段**（API 版占 8765-8775）+ 页面绿色 Local 标识；数据目录 `~/.photocurator/` 两版共用（请勿同folder同时整理）；index.html 响应加 no-cache 防旧页面。根因教训：两版曾同端口段/同名/同目录，旧服务占 8765 时新版 probe_existing_port 误判"已在运行"把浏览器指到旧页面、安装器就绪检测也撞旧服务报假成功。
- 模型下载失败排查链路（真实用户案例：pip 装 requirements-mlx.txt 退出码1 无详情，根因是 macOS 自带 Python 3.9 不满足 MLX ≥3.10）：_ensure_mlx_deps 加版本预检+中文修复指引、pip 输出捕获（尾部400字符入报错，完整日志 `~/.photocurator/mlx_deps_pip.log`）；install_mac.sh 优先选 python3.10-3.14、旧 venv 自动重建；README/设置页含手动下载模型步骤（hf-mirror 文件直链放入 `~/.photocurator/models/<模型名>/`，App 校验 config.json+safetensors 即认已装）。
- HF 调研结论（PRD 附录10）：分数来源 InternVL3.5 技术报告 (arXiv:2508.18265) 跨模型对比表；L1 实测名单：Qwen3-VL-4B 基线 → GLM-4.1V-9B-Thinking（MIT，MMMU 68.0）→ MiniCPM-V-4.6 → Kimi-VL-A3B-Thinking-2506（16B/3B MoE）→ Qwen3-VL-8B；InternVL3.5 同尺寸分数最高但无官方 MLX 移植（观望）；Gemma（中文 JSON 弱+许可条款）/Mistral（视觉链路存疑）/Phi-4/Llama3.2-Vision 排除。Qwen3-VL 官方基准仅图表无文本表格。
- 仓库有并行会话同时开发（出现过远端同名提交 + "模型一键切换"功能 6d5c5e2），操作前需 fetch/pull --rebase，push 被拒时先核对远端变化再处理。

**2026-09-28 增补**：
- **本地推理已在用户真机跑通**（远端并行会话完成 mlx-vlm 0.7.x 适配：模型缓存按 --model 启动路径精确匹配、识别请求回传完整路径、就绪判定含真实小图探针 `_probe`、代次令牌防竞态、环回绕过系统代理 `_LOOPBACK_OPENER`）。L1 的大半已被并行会话完成。
- 用户（ziyiwu 的 MacBook Pro，69GB 内存）已下载 4B 模型并实测，**反馈识别准确率过低**。已给出的优化路径（待用户选定后实施）：① 改 Prompt 补枚举判定细则（景别/朝向基准，零成本）→ ② few-shot 校准（错例回喂进 system prompt，4B 对此敏感）→ ③ 孤立标签低置信度复核 → ④ 切 8B/30B-A3B（其 69GB 内存可跑 30B）。候选模型清单见 PRD 附录10。
- 已完成 UI 修复/增强：顶栏模型状态按钮（8 状态机：就绪绿/加载下载橙/失败未装未加载红闪，2s poll 刷新）、设置弹窗可滚动 + sticky ✕ 关闭（对比框曾把取消/保存顶出视口）、所见即所得（弹窗改过模式未保存时 startTag/toggleServer 先静默保存 syncFormIfTouched）、**模型管理模块**（设置内表格：状态/实际占用 disk_usage 30s 缓存/批量删除 delete_models，使用中自动跳过；`/api/local/delete` 兼容 {names:[...]} 批量）。

**2026-09-28 晚增补（持续学习功能，commit f52ebfc）**：针对"4B 准确率过低"已实施 Prompt+few-shot 方案并上线：
1. **Prompt 模块**：设置页 `custom_prompt` 可整段编辑标注提示词，留空用内置 PROMPT；
2. **Few-shot 沉淀**：照片卡片悬停「纠错」按钮 → fixDlg 弹窗 6 字段枚举下拉选正确值 → `submit_feedback`：立即修正该照片标签 + 同 content_hash 连拍图同步修 + 写 `tag_feedback` 表（wrong_field/wrong_value/correct_value/prompt_version）；
3. **动态注入**：`build_system_prompt(cfg, project_id)` 在 start_tagging 时构建（cfg._sys_prompt → vlm_tag），项目内错例优先→跨项目沉淀，每类错例最多 2 条/总量 ≤ MAX_FEWSHOT=8，`fewshot_enabled` 可关。前端 FIX_ENUMS 硬编码枚举，**须与 app.py PROMPT 枚举同步修改**。photo 表迁移加 prompt_version/feedback 列。
单测 8 项（入库/缓存修复/注入/自定义/开关/上限/兄弟同步/vlm 链路）+ 三套回归全绿。待用户实测：纠错几条规则后重跑 151 张验证准确率改善；不够再切 8B/30B。
