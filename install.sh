#!/usr/bin/env bash
# Agent-sync installer (macOS/Linux). Run: ./install.sh
set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"
ts=$(date +%Y%m%d-%H%M%S)

echo "== Agent-sync install from $REPO =="

# 1) Skills -> symlink to repo checkout, for every agent that supports the SKILL.md standard
skills_src="$REPO/zcode/skills"
for dst in "$HOME/.zcode/skills" "$HOME/.codex/skills" "$HOME/.claude/skills" "$HOME/.cursor/skills"; do
    mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$skills_src" ]; then
        echo "skills symlink already OK: $dst"
    else
        [ -e "$dst" ] && mv "$dst" "$dst.backup-$ts"
        ln -s "$skills_src" "$dst"
        echo "skills symlink created: $dst"
    fi
done

# 2) Unified global instructions -> each agent's global memory/instruction file
agents_src="$REPO/global/AGENTS.md"
for dst in "$HOME/.codex/AGENTS.md" "$HOME/.claude/CLAUDE.md" "$HOME/.gemini/GEMINI.md" "$HOME/.config/opencode/AGENTS.md"; do
    mkdir -p "$(dirname "$dst")"
    [ -f "$dst" ] && ! cmp -s "$dst" "$agents_src" && mv "$dst" "$dst.backup-$ts"
    cp "$agents_src" "$dst"
done
echo "global instructions deployed (codex/claude/gemini/opencode)"

# 3) ZCode memories: copy only missing project keys
mkdir -p "$HOME/.zcode/cli/memories/projects"
for d in "$REPO/zcode/memories-projects"/*/; do
    name=$(basename "$d"); dst="$HOME/.zcode/cli/memories/projects/$name"
    if [ ! -e "$dst" ]; then cp -r "$d" "$dst"; echo "zcode memory added: $name"
    else echo "zcode memory exists, skipped: $name"; fi
done

# 4) Codex memories: add missing files (rsync keeps local-newer)
if [ -d "$HOME/.codex/memories" ] && command -v rsync >/dev/null; then
    rsync -a --ignore-existing "$REPO/codex/memories/" "$HOME/.codex/memories/"
    echo "codex memories merged (missing files only)"
else
    mkdir -p "$HOME/.codex"
    [ -d "$HOME/.codex/memories" ] || cp -r "$REPO/codex/memories" "$HOME/.codex/memories"
    echo "codex memories installed"
fi

# 5) Codex hooks.json (only if absent)
[ -f "$HOME/.codex/hooks.json" ] || cp "$REPO/codex/hooks.json" "$HOME/.codex/hooks.json"

# 6) Workspace documents: add missing files
mkdir -p "$HOME/.zcode/workspace/default"
if command -v rsync >/dev/null; then
    rsync -a --ignore-existing --exclude 'debug.log' "$REPO/projects/workspace-default/" "$HOME/.zcode/workspace/default/"
fi

echo
echo "== Manual steps (secrets, NOT auto-applied) =="
echo " 1. Merge zcode/cli.config.template.json into ~/.zcode/cli/config.json (fill \$GITHUB_MCP_PAT / \$BAIDU_PAN_MCP_TOKEN)"
echo " 2. Save codex/config.toml.template as ~/.codex/config.toml (fill \$CODEX_BEARER_TOKEN)"
echo " 3. MCP for other agents: ./setup-mcp.sh (see mcp/FORMATS.md)"
echo " 4. Local MCP servers: see codex/mcp-servers-setup/README.md"
