---
name: zcode-performance-tuning
description: ZCode 卡顿优化记录:实际杀软是 360(Defender 停用)、66 个商业 skill 已归档、遗留优化项
metadata:
  node_type: memory
  type: project
  originSessionId: sess_eb6939ae-2856-449f-b8ef-104a1df9aea6
---

2026-09-21 为 ZCode 卡顿做的优化(用户确认执行):

- **实际杀软是 360 终端安全管理系统**,Windows Defender 服务已停用(0x800106ba),Defender 排除项无效;文件 I/O 白名单须在 360 信任区加 `C:\Users\xujinya\.zcode` 和 `E:\Zcode`(手动,若为企业管控版需管理后台下发)。
- **66 个商业分析/PM 流程 skills 已归档**到 `E:\Zcode\skills-archive`(含 list-2026-09-21.txt 清单和恢复说明)。保留未归档:`create-prd`(db 中有 2 次调用)、`user-story`、`utility-pm-critic`、`utility-pm-skill-auditor`、`utility-pm-skill-builder`、`ai-security-prd-maintainer`。恢复 = 把目录移回 `C:\Users\xujinya\.zcode\skills`。
- 桌面有 `ZCode数据库整理.bat`:关闭 ZCode 后双击,备份并 VACUUM `~/.zcode/cli/db/db.sqlite`。
- **遗留的最大优化项**(用户未确认,勿擅自改 config.json):ai-memory.exe 的 PreToolUse/PostToolUse/UserPromptSubmit 等 6 个事件 hook(每次工具调用都 spawn 进程)、5 个 stdio MCP 服务器(node_repl/lark-mcp/microsoft-office/github/ai-memory)、cli/log+v2/logs 日志量大(约 8MB/天)。

相关:[[user-profile]]、[[zcode-plugin-install-layout]]
