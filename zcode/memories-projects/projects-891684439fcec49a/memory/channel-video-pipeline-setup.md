---
name: channel-video-pipeline-setup
description: Channel（video-pipeline 短视频自动化管线）仓库的本机环境与配置状态
metadata:
  node_type: memory
  type: project
  originSessionId: sess_e93b0db0-679e-4f8c-aef7-912185d1e500
---

用户的 GitHub 仓库 xjinya-xiangwu/Channel（video-pipeline，0.1.0）已于 2026-09-21 克隆到 `E:/Zcode/Projects/Channel`，并完成本机环境搭建：

- uv 通过 winget 安装，exe 位于 `%LOCALAPPDATA%\Microsoft\WinGet\Packages\astral-sh.uv_...\uv.exe`（不在 Git Bash 默认 PATH 中，需用完整路径或新 shell 调用）。
- ffmpeg 9.0.1 essentials 构建在 `%LOCALAPPDATA%\ffmpeg\bin`（winget 装 Gyan.FFmpeg 因 copy_file Access denied 失败，改手动下载 GyanD/codexffmpeg release），已加入用户 PATH。
- biliup-rs v0.2.4 在仓库 `tools/biliup.exe`，`E:\Zcode\Projects\Channel\tools` 已加入用户 PATH。
- 仓库 `config/platforms.yaml` 曾提交机器专用路径 `C:/Zcode/Projects/video-pipeline/tools/biliup.exe`（旧目录已不存在），导致 test_config.py 失败；已改回可移植默认值 `"biliup"`（通过 PATH 解析）。此改动尚未提交。
- `.env` 已从 `.env.example` 复制（密钥全为空）。`uv sync`（Python 3.12）完成，216 个测试全部通过。

**Why:** 后续会话继续此项目时无需重新调研环境；PATH 约定和 uv 路径较难从仓库推断。

**How to apply:** 在 `E:/Zcode/Projects/Channel` 下运行 `uv run --no-sync pipeline ...`；若 shell 里找不到 ffmpeg/biliup，检查用户 PATH 是否含上述两个目录。尚未做平台授权（`pipeline auth youtube/tiktok`）与 LLM 文案密钥（Phase 3）。

2026-09-21 B 站通路已全链路验证通过（ingest→transcribe→subtitle→edit→publish，BV1FNhv61EnJ，账号 Mr_Kurtosis）：

- biliup cookie 在仓库根 `cookies.json`（biliup-rs v0.2.4 的路径，CWD 相对；已加入 .gitignore）。
- `pipeline auth bilibili` 需要 TTY，本会话（无头）跑不了；已验证的替代流程：`uv run --with pywinpty python data/pty_login.py`（ConPTY 伪终端 + 输出落盘 data/login_pty.log），从菜单首项「短信登录」发 **1 个** ↓ 即到「扫码登录」（我的脚本发了 2 个 ↓ 误选中「浏览器登录」，但该模式会把授权 URL 打进日志，用 qrcode 库渲染成 PNG 让用户扫也一样能登录）。此脚本留在 data/ 下可复用。
- 偶发 `[WinError 5] 拒绝访问`（Defender 锁刚写出的成片导致 os.replace 失败）：重跑即可，处理链幂等。
- whisper small 模型走 HF 镜像下载（设 `HF_ENDPOINT=https://hf-mirror.com`），已缓存。

2026-09-21 新增素材搜索下载模块（`pipeline search`，src/pipeline/ingest/search.py）：

- 设计：yt-dlp flat 搜索候选池（B站 `bilisearchN:` / YouTube `ytsearchN:`）→ 逐候选全量提取 → filter_reject_reason 纯函数筛选（时长/播放量/排除词，未知值从严）→ 复用 ingest_url 入队；搜来的素材默认 content_source=unknown（发布门控拦截）。
- B 站搜索 API 必须带 buvid3 指纹 cookie（否则 HTTP 412）；模块自动向 api.bilibili.com/x/frontend/finger/spi 取指纹写 data/bilibili_cookies.txt 传给 yt-dlp。ingest_url 加了 ydl_extra_opts 透传参数。
- 本机网络可直连 YouTube（搜索与下载均通）。

2026-09-21 README 已重构为 PRD 并推送 GitHub（main，c45a4d0）：产品定位/模块范围基线/Phase 1-4 路线图/维护约定+更新记录表（README 第 10 节）。**约定：每次功能变更必须同步更新 README 第 4 节模块卡片、第 5 节路线图和更新记录表**（用户明确要求"随产品更新而更新"）。

2026-09-21 Phase 3/4 主体交付并推送（main，eb8f197）：`pipeline run`（--once/--watch 无人值守，故意不自动搜索）、LLM 文案+字幕翻译（PIPELINE_LLM_* 环境变量，未配置自动跳过，离线测试覆盖）。

2026-09-22 YouTube 发布通路实测通过（main，4cda5ec）：用户自建 GCP 项目（桌面应用 OAuth 客户端），client secret 与 token 均在 `secrets/`，可续传上传 + 字幕轨附加全链路 OK（youtu.be/XgUbgvXhULw，unlisted）。**platforms.yaml 的 youtube.privacy 临时改为 unlisted，正式启用要改回 public**。授权流程两个坑：后台抓授权 URL 需 `PYTHONUNBUFFERED=1`（oauthlib 的 print 会被块缓冲吞掉）；token 刷新失败会在 publish 时暴露（check_ready 只查文件存在）。至此 B站+YouTube 双通路实测，剩 TikTok 待开发者凭据。

2026-09-22 TTS 配音交付并推送（main，14fb89b）：media/tts.py（edge-tts 逐段合成 + ffmpeg adelay/amix 按原时间戳定位混音；tts.mode replace/mix，音色 zh-CN-YunxiNeural，edge-tts 本机网络可用）、compose(audio_path) 音轨映射（apad+shortest 在 compose 侧，建轨命令不能 apad 否则挂死）、YouTube 自动附加 subtitles.{lang}.srt 翻译轨。260 测试绿，TTS 实网 smoke 通过。**至此 PRD 上所有规划的开发项全部交付**，剩余全部卡用户侧：LLM key 未配、YouTube/TikTok 凭据未给、两条课程视频等内存续跑、任务计划未建。

本机转写环境两个关键修复（已提交）：低内存 Windows 上 ctranslate2 的 MKL 分配器连 base/small 模型都加载失败（tiny 能过），代码里默认 `CT2_USE_MKL=0` + yaml `whisper.compute_type: int8` 后可加载。**本机 15.8GB 内存常剩 <2GB 可用，11+ 分钟视频的特征提取 STFT（约 200MB float64）也会分配失败**——两条搜索来的课程视频（47601ca6/73783b27）停在 failed，等内存空出后 `pipeline process` 自动续跑。

2026-09-22 YouTube→B站 搬运通路本地验证完成（main，0839695），LLM 文案+中文字幕翻译实测通过：用户 LLM 走自建网关 `http://35.220.164.252:3888/v1`（glm-5.3-flash；BASE_URL 必须带 /v1，否则打到网关 Web 首页返回 HTML）。实测踩坑已修：推理模型批量翻译超时（新增 `PIPELINE_LLM_REASONING_EFFORT=low` 透传 reasoning_effort，180s→5s）；whisper 把英语碎成 499 段（batch=10 + 容错解析：个别行格式漂移回退原文）；英语字幕 max_line_chars=18 会切单词（未改全局配置）。新增 `search --sort views`（按播放量选片）。JEV 任务（e916e685/fc99dba8，425K 播放英语片）停在 ready+unknown：用户决定止步本地验证、手工上传（--to manual --force 可生成发布包），不替用户 force 发布无授权搬运。261 测试绿。

2026-09-23 烧录字幕过小修复（main，0308385）：根因是 ASS PlayRes 竖版基准 1080x1920 烧到横版 1920x1080 成片，libass 按 frameH/PlayResY 把 24pt 缩到约 13.5px。改为横版基准 1920x1080 + font_size 40（config.subtitle.font_size 以 PlayResY=1080 为基准，竖版输出 libass 等比放大）。连带修：翻译空译文产生无文本 srt 块被 read_srt 丢弃 → 双语升级因段数不齐静默跳过（现空译文回退原文 + 不齐时显式 notify）。远端曾有另一会话推的 8 个提交（双语烧录/TTS 时间轴 sidechain ducking/百度网盘同步 xpan/无头 biliup 扫码脚本），本地已合并同步。注意多会话并行开发此仓库，动手前先 git fetch。
