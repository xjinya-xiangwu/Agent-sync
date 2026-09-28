# MCP 配置格式对照（跨 agent）

任何 agent 都能按本文件把 `mcp/mcp-servers.json`（canonical 注册表）翻译成自己需要的原生格式。
`setup-mcp.ps1 -Targets cursor,vscode,opencode`（Windows）或 `setup-mcp.sh`（macOS/Linux）可自动完成 JSON 类目标的转换。

## 各 agent 原生 MCP 配置位置与格式

| Agent | 配置文件 | 格式要点 |
|---|---|---|
| **Claude Code** | 项目 `.mcp.json`，或 `claude mcp add-json <name> '<json>' -s user` | `{"mcpServers": {"<name>": {"type":"stdio"/"http"/"sse", "command","args","env","url","headers"}}}`；支持 `${VAR}` 环境变量展开 |
| **Codex** | `~/.codex/config.toml` | `[mcp_servers.<name>]` 段：`command`/`args`/`env`；http 型 server 需用支持 http 的版本（本仓库 `codex/config.toml.template` 已含现成段） |
| **Cursor** | `~/.cursor/mcp.json`（全局）或项目 `.cursor/mcp.json` | `{"mcpServers": {...}}`，同 CC stdio/http 格式，支持 `${env:VAR}` |
| **VS Code** | `%APPDATA%\Code\User\mcp.json`（全局）或 `.vscode/mcp.json` | `{"servers": {"<name>": {...}}}`，键名是 `servers` 不是 `mcpServers`；支持 `${env:VAR}` |
| **OpenCode** | `~/.config/opencode/opencode.json`（Windows 也在 `~/.config/`） | `{"mcp": {"<name>": {"type":"local","command":["exe","arg",...],"environment":{},"enabled":true}}}`；remote 型 `{"type":"remote","url":"..."}`——**command 是数组**，不是 command+args 分离 |
| **ZCode** | `~/.zcode/cli/config.json` | `{"mcp":{"servers":{...}}}`，见 `zcode/cli.config.template.json` |
| **Kimi CLI / Kimiwork** | 项目根 `.kimi/mcp.json` 或其设置界面 | 兼容 `{"mcpServers": {...}}` 约定时直接用 CC 格式；否则在设置界面粘贴 |
| **DSH / 其他** | 各自设置 | 若支持 MCP 标准格式，用 CC 的 `{"mcpServers": ...}` 片段作为通用交换格式 |

## stdio 型通用片段（从注册表展开后）

```json
{
  "mcpServers": {
    "lark-mcp": {
      "command": "cmd.exe",
      "args": ["/d", "/s", "/c", "<HOME>\\.codex\\mcp-servers\\lark-mcp\\start-lark-mcp.cmd"]
    }
  }
}
```

http/sse 型通用片段（CC / Cursor / ZCode / DSH 通用）：

```json
{
  "mcpServers": {
    "huggingface": { "type": "http", "url": "https://huggingface.co/mcp" },
    "baidu-pan": {
      "type": "sse",
      "url": "https://mcp-pan.baidu.com/sse",
      "headers": { "Authorization": "Bearer <BAIDU_PAN_MCP_TOKEN>" }
    }
  }
}
```

OpenCode 翻译示例（注意 command 合并为数组）：

```json
{
  "mcp": {
    "lark-mcp": { "type": "local", "command": ["cmd.exe", "/d", "/s", "/c", "<HOME>\\.codex\\mcp-servers\\lark-mcp\\start-lark-mcp.cmd"], "enabled": true },
    "huggingface": { "type": "remote", "url": "https://huggingface.co/mcp", "enabled": true }
  }
}
```

VS Code 翻译要点：仅键名不同——顶层 `{"servers": {...}}`，server 内部字段与 CC 一致。

## 安全规则

- 注册表里 `${GITHUB_MCP_PAT}` / `${BAIDU_PAN_MCP_TOKEN}` 是占位符，生成后**在本机填真实值**，生成文件与真实 token 永不 commit。
- `optional: true` 的 server（github / ai-memory / microsoft-office）默认不写入生成配置，显式传 `-IncludeOptional` 才包含。
