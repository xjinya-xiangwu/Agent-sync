---
name: blender-health-check
description: Blender 连接与环境的只读分层诊断。当用户说 Blender/MCP 连不上、插件没反应、想检查环境状态时使用。六层检查逐层定位（Blender 本体/uvx/server 缓存/官方插件/运行与端口/端到端握手），每层给出修复指引；全程只读，不做任何修改。
---

# Blender Health Check — 六层诊断（只读）

> **运行目录**：以下命令中的 `scripts/...` 为相对路径，请在插件根目录（`kimi.plugin.json` 所在目录）下执行，或改用绝对路径；skill 目录内没有 `scripts/` 子目录。

## 执行

```bash
python3 scripts/blender_health.py              # 人读文本，含端到端握手
python3 scripts/blender_health.py --json       # 结构化
python3 scripts/blender_health.py --skip-mcp   # 快速版，不拉起 server
```

## 六层含义与修复路由

| 层 | 检查内容 | fail 的含义 | 修复 |
|---|---|---|---|
| L1 | Blender 已安装且 ≥ 5.1 | 没装 / 版本旧 | → setup-guide A / B |
| L2 | uvx 可用 | uv 未装或不在已知位置 | → setup-guide C（自动装） |
| L3 | server 缓存已预热 | 首次调用会超时 | → setup-guide D（自动预热） |
| L4 | 官方插件已安装启用 | Blender 侧没有接听方 | → setup-guide E（明确安装请求则自动装） |
| L5 | Blender 运行中 + 9876 可连 | 没开 / 插件未启用 / 端口被改 | → setup-guide F |
| L6 | MCP initialize + tools/list 握手成功 | launcher 或 server 层问题 | 看 stderr；先补 L2/L3 再试 |

## 汇报规范

- 按层列出 ✅/❌/⏭，fail 层附一句人话修复指引
- L6 成功时报告官方 server 实际暴露的工具数量（tools/list 实时结果）
- 前几层 fail 时更深层标 ⏭ skip，不把连带失败当成多个问题
- 全程只读：本技能不安装、不修改、不重启任何东西；修复动作一律路由到 blender-setup-guide
