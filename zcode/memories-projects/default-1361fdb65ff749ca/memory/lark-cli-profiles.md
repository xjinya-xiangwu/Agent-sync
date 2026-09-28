---
name: lark-cli-profiles
description: lark-cli 双 profile 配置：shanghai-ai（徐劲亚工作号）与 xiangwu（kurt，测独立游戏知识库）
metadata:
  node_type: memory
  type: project
  originSessionId: sess_36860cbc-c44b-4d4b-bd5e-d27064d691a8
---

用户本机 lark-cli（v1.0.94+）配置了两个 profile（配置文件 `C:\Users\xujinya\.lark-cli\config.json`）：

- `shanghai-ai`：应用 `cli_a952004b847b1cd2`，用户身份徐劲亚（工作账号，上海AI实验室），可访问约 75 个 wiki 空间。
- `xiangwu`：应用 `cli_aa0a9a169ef89bea`（2026-09-18 由用户直接提供 App ID/Secret 配置，App Secret 已在聊天中暴露过一次），目标身份是 xiangwu 组织下的 **kurt** 账号。该应用已启用 455 个 user scope（wiki/docx 读写齐全）。

2026-09-18 已验证：kurt（openId `ou_56f0c20cae4f1f764e493e414b133382`）设备流登录成功，可访问 xiangwu 组织的 **"独立游戏项目"** wiki（space_id `7657770623653825743`，8 个顶级节点：项目概述/前期调研/Steam游戏分析/玩法设计主文档 v6.7/素材池 bitable/项目管理表/任务表/会议纪要），文档读取与编辑（append + block_delete 回滚）均通过。注意：kurt 授权的 scope 未包含 `wiki:node:delete`，无法删除 wiki 节点，测试内容只能用 block 级操作回滚。切换 profile 用 `--profile <name>`，用户身份调用要显式 `--as user`。

**Why:** 用户有多租户身份，跨租户访问必须用对应租户的应用，不能用工作租户的应用代替。
**How to apply:** 涉及 xiangwu/独立游戏知识库的飞书操作一律加 `--profile xiangwu`；涉及工作知识库的用默认或 `--profile shanghai-ai`。不要向用户索要或复述 App Secret。相关：[[win-cmd-shell-quirks]]
