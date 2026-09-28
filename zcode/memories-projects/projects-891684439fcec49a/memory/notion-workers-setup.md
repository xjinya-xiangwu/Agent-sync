---
name: notion-workers-setup
description: Notion Workers 环境与已部署的 notion-worker（ntn CLI、worker ID、更新方式）
metadata:
  node_type: memory
  type: project
  originSessionId: sess_9777c2a3-ee0b-4331-9c40-6839e212e100
---

2026-09-24 按 Notion 官方 quickstart 完成部署：

- `ntn` CLI v0.23.9 通过 `npm install -g ntn` 全局安装（Windows 下用 npm，勿用文档里的 `curl | bash`）。npm allow-scripts 拦截了 preinstall，但 CLI 正常可用。
- Worker 项目在 `E:/Zcode/Projects/notion-worker`（脚手架模板 `@notionhq/workers`，入口 `src/index.ts`，示例工具 `sayHello`）。
- 已部署到工作区 "jinya Xu's Notion"，worker ID `01a0d204-4249-714b-967a-62b3243dd63e`。管理页：https://www.notion.so/developers/workers
- 更新流程：改 `src/index.ts` → 在项目目录跑 `ntn workers deploy`（更新时不要再带 `--name`，该参数仅创建时使用）。本地测试：`ntn workers exec sayHello -d '{"name": "X"}'`。
- 登录过期时用 `ntn login --no-browser`（打印带 verificationCode 的 URL 让用户点击确认），然后 `ntn login poll`。
