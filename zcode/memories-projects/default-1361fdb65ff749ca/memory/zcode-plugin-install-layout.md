---
name: zcode-plugin-install-layout
description: How ZCode plugin installation is laid out on disk and which files
  to edit for a manual (file-level) plugin install
metadata:
  node_type: memory
  type: reference
  originSessionId: sess_791c45e0-35fd-41e2-a964-ad6268e139b2
---

ZCode (xujinya's machine) plugin install layout, learned 2026-09-18:

- Plugin cache: `C:\Users\xujinya\.zcode\cli\plugins\cache\<marketplace>\<plugin-name>\<version>\`
- Registration: `C:\Users\xujinya\.zcode\cli\plugins\installed_plugins.json` (fields: id `name@marketplace`, name, marketplace, version, installPath, installedAt/updatedAt ISO, scope "user", source, cacheTransactionId)
- Enable state: `plugins.enabledPlugins` in `C:\Users\xujinya\.zcode\cli\config.json`
- Marketplaces: `C:\Users\xujinya\.zcode\cli\plugins\known_marketplaces.json`; marketplace copies under `plugins\marketplaces\<id>\marketplace.json`
- Known marketplaces: `zcode-plugins-official` (CDN zips) and `claude-plugins-official` (anthropics repo; plugin sources may be git URLs, `"source": "url"` with `.git` url + pinned `sha`)
- Claude Code-style plugins (`.claude-plugin/plugin.json`, `.mcp.json` at root) are recognized; MCP servers contributed via `.mcp.json`
- MCP user config: `config.json` → `mcp.servers`. Schema is **strict — unknown keys silently drop the whole server** (log shows `config.mcp_server.skipped` / `config_mcp_server_invalid`). Valid http fields: `type:"http"`, `url`, `headers`, `enabled`, `timeoutMs`; stdio: `command`/`args`/`cwd`/`env`. **No `bearer_token_env_var` key** (that format broke the github server until 2026-09-18; auth goes in `headers.Authorization`). **Config-file servers do NOT expand `${...}` templates** — only plugin-provided servers do — so secrets must be inlined into `headers` (github token: env var `GITHUB_PAT_TOKEN`, endpoint https://api.githubcopilot.com/mcp/ — verified HTTP 200). ZCode MCP logs: `~\.zcode\cli\log\zcode-<date>.jsonl`.
- OAuth MCP servers (e.g. Notion `https://mcp.notion.com/mcp`): client initiates flow via Settings → MCP; user must click authorize in browser. Notion OAuth discovery verified standard (`/.well-known/oauth-protected-resource`, auth server = mcp.notion.com).

- Hugging Face official MCP (installed 2026-09-22): remote server `https://huggingface.co/mcp` added to `config.json` → `mcp.servers.huggingface` as `type:"http"`, timeoutMs 60000, **no auth needed for Hub search/read tools** (anonymous initialize + tools/list verified HTTP 200 from this network; huggingface.co reachable, ~1s). Authenticated/write tools need OAuth via Settings → MCP or a PAT in `headers.Authorization`.
- Baidu Pan official MCP (activated 2026-09-22): SSE endpoint `https://mcp-pan.baidu.com/sse` in `config.json` → `mcp.servers.baidu-pan` as `type:"sse"`, **enabled with `Authorization: Bearer` header token — verified working**: tools/call `get_quota` returned errno 0 (used ~3.2 TB of ~18 TB). Token obtained via official personal authorize link `https://openapi.baidu.com/oauth/2.0/authorize?response_type=token&client_id=QHOuRXiepJBMjtk0esLhrPoNlQyYd0mF&redirect_uri=oob&scope=basic,netdisk&qrcode=1` (no app registration needed); token read from address-bar fragment, **expires ~2026-10-22 (30 days)** — re-run the link (ZCode IAB flow works: open link, user scans QR, agent reads URL) and update the header. Never echo the token in conversation output. Note `https://openapi.baidu.com/pan/mcp` (circulating in search results) is 404 — the real endpoint is mcp-pan.baidu.com.

**Why:** installing plugins without the client UI requires replicating this exact structure.
**How to apply:** copy plugin tree into cache path, add installed_plugins entry mirroring the marketplace source block, add enabledPlugins key, validate JSON with `node -e`, restart client to load. This full flow was verified end-to-end 2026-09-20 installing `i-have-adhd@i-have-adhd` 0.3.0 from GitHub repo ayghri/i-have-adhd: repo acts as its own marketplace (id = repo name, marketplace `source: {source:"github", repo:"owner/repo"}`, plugin source `{source:"url", url:"…​.git", sha:"<pinned>"}` like notion's entry). Repo's marketplace.json lives in `.claude-plugin/`, so also copy it to the marketplace-cache root (`plugins\marketplaces\<id>\marketplace.json`) for safety. JSON edits must go through a temp .js file, not inline `node -e` (see [[win-cmd-shell-quirks]]).

- **Skills（非插件）安装**（2026-09-28）：用户级 skills 目录是 `C:\Users\xujinya\.zcode\skills\<skill-name>\SKILL.md`（启动时加载，装完需重启会话生效）。Vercel 的 `skills` CLI（`npx skills add <github-url> --skill <name> -g -a zcode -y`）**原生识别 "ZCode" 这个 agent**，会以 copy 模式（非符号链接）落到 `~\.zcode\skills\`，无需手动搬运。已装：`find-skills`（来自 vercel-labs/skills，skill 发现入口，触发词"有没有 XX 的 skill"）。CLI 常用 flag：`-l` 只列出仓库 skills、`-a '*'` 全部 agent、`--copy`、`--json`。

- **PPT skill 现状盘点**（2026-09-28）：本地已装 `presentations:pptx`（官方插件，创建/编辑/转 PDF/PNG，日常够用）与 `utility-slideshow-creator`（JSON 规格→18 版式）。生态候选（skills.sh，未装）：`op7418/guizang-ppt-skill`（2.7 万安装，HTML 渲染路线视觉强，中文社区热门）、`anthropics/skills@pptx`（与本地同源不重复装）、`hugohe3/ppt-master`、`bytedance/deer-flow@ppt-generation`。用户如要"好看"的展示型 PPT，候选是 guizang-ppt-skill。

Related: [[win-cmd-shell-quirks]]
