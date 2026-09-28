# MCP Servers 重装说明

本目录保存 ZCode / Codex 共用的本地 MCP server 启动脚本模板。**331MB 的运行时主体（node_modules 等）不入库**，新机器按下述步骤重装。

## lark-mcp（飞书）

1. 准备目录：`%USERPROFILE%\.codex\mcp-servers\lark-mcp`
2. 安装主体（任选其一）：
   ```powershell
   cd $env:USERPROFILE\.codex\mcp-servers\lark-mcp
   pnpm init
   pnpm add @larksuiteoapi/lark-mcp
   ```
3. 从本目录复制 `start-lark-mcp.cmd`、`login-lark-mcp.cmd`，把其中的 node.exe 绝对路径改为本机实际路径（原机器用的是 Codex runtime 自带 node）。
4. 在同目录创建 `credentials.env`（**不进 git**）：
   ```bat
   FEISHU_APP_ID=<你的 app id>
   FEISHU_APP_SECRET=<你的 app secret>
   ```
5. ZCode / Codex 的 MCP 配置里按模板引用 start 脚本（见各 config 模板）。

## microsoft-office（semanticworkbench office server）

源仓库 https://github.com/microsoft/semanticworkbench ，office server 在 `mcp-servers/mcp-server-office/`：

```powershell
git clone https://github.com/microsoft/semanticworkbench.git $env:USERPROFILE\.codex\mcp-servers\microsoft-semanticworkbench
cd $env:USERPROFILE\.codex\mcp-servers\microsoft-semanticworkbench\mcp-servers\mcp-server-office
py -m uv sync
```

启动即 `start-office-mcp.cmd`（已在本目录，路径含用户名，跨端同用户名可直接用）。

## ai-memory（ZCode/Codex hooks 共用）

hooks 引用 `C:\Users\<user>\AppData\Local\ai-memory\ai-memory.exe`，属于本机安装的独立程序，新机器重装 ai-memory 后 hooks.json / cli.config 模板即可用。ZCode 端 hooks 内置于 `cli.config.template.json`，Codex 端见 `../hooks.json`。
