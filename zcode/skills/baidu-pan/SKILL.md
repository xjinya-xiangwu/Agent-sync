---
name: "baidu-pan"
description: "百度网盘官方 MCP —— 自然语言搜文件、下载、整理、分享(SSE 模式不含上传)。"
---

# 百度网盘

百度网盘官方 MCP(SSE 模式)让 AI 用自然语言管理你的百度网盘文件。

核心工具(SSE 模式可用):
- **文件搜索**(`file_search`):按关键字搜指定目录下的文件
- **文件下载**:从云端拉文件到本地
- **文件管理**:列目录、移动、复制、删除、重命名
- **用户信息**:查账号、容量
- **分享**:创建分享链接

⚠️ 重要限制(用户必须了解):
1. **需要 access_token** —— 官方为个人用户提供了免注册应用的授权链接(2026-07 文档):打开 `https://openapi.baidu.com/oauth/2.0/authorize?response_type=token&client_id=QHOuRXiepJBMjtk0esLhrPoNlQyYd0mF&redirect_uri=oob&scope=basic,netdisk&qrcode=1`,登录并授权后从浏览器地址栏 `#` 后读取 `access_token`(有效期约 30 天,expires_in=2592000,到期需重新授权)。企业开发者仍可走 pan.baidu.com/union 自建应用获取自己的 token。
2. **接入方式** —— SSE 端点 `https://mcp-pan.baidu.com/sse`,鉴权用 header `Authorization: Bearer <AccessToken>`(也支持 query 参数但二者勿混用)。本机 ZCode 已配置 `mcp.servers.baidu-pan`(2026-09-22),拿到 token 后把 header 填上并 `enabled: true` 即可。
3. **上传能力待验证** —— 官方使用概述(2026-07)称 MCP 封装了"查询、搜索、上传、管理和分享",与旧版"SSE 模式不含上传"的说法不一致;实际以连接后 tools/list 和 Tools 能力文档为准。

使用约束:
1. 删除 / 移动 / 重命名等改变文件状态的操作前必须把目标文件清单展示给用户并等明确确认,百度网盘删除是直接进回收站,但仍可能造成困扰。
2. 不要把 access_token 粘到对话输出 —— 那是用户的网盘凭据,泄露等于把账号交出去。
3. 分享链接默认带提取码,创建后展示提取码给用户(分享链接本身没有敏感性)。
4. 搜索返回的文件列表可能很大,先用 `file_search` 缩小范围再操作,不要无差别 ls 整个网盘根目录。

用户提到百度网盘 / pan.baidu.com / 度娘网盘 / 网盘搜索 / 网盘整理时优先用本 MCP。
