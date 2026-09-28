---
name: blender-setup-guide
description: Blender 插件的装机与开通引导。当用户问"怎么用/怎么装/第一次用/连不上/没反应"或健康检查发现缺组件（没装 Blender、版本太旧、没装 uv、server 未预热、官方插件未装、Blender 没开）时使用。用户明确要求安装/接入时，能自动完成的步骤直接执行；只有装 Blender 本体和关闭正在运行的 Blender 需要用户自己动手。
---

# Blender Setup Guide — 装机引导（缺什么补什么）

> **运行目录**：以下命令中的 `scripts/...` 为相对路径，请在插件根目录（`kimi.plugin.json` 所在目录）下执行，或改用绝对路径；skill 目录内没有 `scripts/` 子目录。

## 总原则

- **只让用户做当前缺的那一步**，不要把完整教程甩给用户
- 用户明确要求安装/接入时，能脚本完成的步骤（装 uv、预热 server、装官方插件）直接执行
- 全程先跑只读状态：`python3 scripts/blender_setup.py status`

## 状态 → 指引矩阵

### A. 完全没装 Blender

给链接 https://www.blender.org/download/ ，说明需要 **5.1 或更新**。装好后让用户回来，自动接续后续步骤。

### B. Blender 版本 < 5.1

说明官方 MCP 插件仅支持 5.1+（`blender_version_min=5.1.0`），引导升级；旧版本项目文件升级后不受影响。

### C. uvx 不可用（L2 fail）

```bash
python3 scripts/blender_setup.py ensure-uv
```

自动安装 uv，无需用户操作。失败给手动链接。

### D. server 未预热（L3 fail）

```bash
python3 scripts/blender_setup.py warm
```

预热官方 server 缓存（首次 clone+build 可能超过 MCP 启动超时，预热后无此问题）。无需用户操作。

### E. 官方插件未安装（L4 fail）—— 唯一要写用户配置的一步

1. 确认 Blender 已关闭（运行中安装会被退出时的偏好覆写吃掉；`blender_running=true` 时先请用户关闭）
2. 向用户说明："我帮你把 Blender 官方 MCP 插件装好并启用，约 10 秒，可以吗？"
3. 用户已明确要求安装时：

```bash
python3 scripts/blender_setup.py install-addon --yes
```

`--yes` 是机器级写入开关；用户原始安装/接入请求已构成授权，不要求新增用户回合。

4. 成功后告诉用户"打开 Blender 就能用了"；可主动帮开（macOS `open -a Blender`）
5. 自动安装失败时退到手动兜底：Blender → Edit → Preferences → Add-ons → Install from Disk，zip 已缓存在 `~/.kimi-blender-bridge/blender_mcp_official_addon.zip`；装完勾选启用，看到 "Server is running" 即可

### F. 插件装了但连不上（L5 fail）

Blender 没开 → 提示打开。开着但 9876 不通 → 让用户检查 Preferences → Add-ons 里 MCP 是否勾选、偏好面板里 Auto-start 与端口（默认 9876）。

### G. 一条龙（首次使用）

```bash
python3 scripts/blender_setup.py all --yes
```

= ensure-uv → warm → install-addon。跑完后引导打开 Blender，跑 `blender_health.py` 全绿即完成。

## 边界

- 全程不替用户下载 Blender 本体（系统级安装，引导优于代劳）
- 安装插件前必须确认 Blender 已关闭
- 任何脚本 fail：保留原始 stderr 展示给用户，按 hint 走，不重试超过一次
