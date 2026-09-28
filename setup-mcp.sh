#!/usr/bin/env bash
# Generate per-agent MCP configs from mcp/mcp-servers.json. Requires python3.
# Usage: ./setup-mcp.sh [cursor,vscode,opencode,claude] [--include-optional]
set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"
TARGETS="${1:-cursor,vscode,opencode,claude}"
EXTRA="${2:-}"
TARGETS="${TARGETS#-Targets }"; TARGETS="${TARGETS//-Targets /}"
python3 - "$REPO" "$TARGETS" "$EXTRA" "$HOME" <<'PYEOF'
import json, os, re, sys

repo, targets, extra, home = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
include_optional = 'include-optional' in extra
reg = json.load(open(os.path.join(repo, 'mcp', 'mcp-servers.json'), encoding='utf-8'))

def expand(node):
    if isinstance(node, dict):  return {k: expand(v) for k, v in node.items()}
    if isinstance(node, list):  return [expand(v) for v in node]
    if isinstance(node, str):
        node = node.replace('${HOME}', home)
        for t in ('GITHUB_MCP_PAT', 'BAIDU_PAN_MCP_TOKEN'):
            v = os.environ.get(t)
            if v: node = node.replace('${%s}' % t, v)
        return node
    return node

sel = {}
for name, s in reg['servers'].items():
    if s.get('optional') and not include_optional: continue
    if s.get('platforms') and sys.platform != 'win32' and 'windows' in s.get('platforms'): continue
    if s.get('platforms') and sys.platform == 'win32' and s.get('platforms') != ['windows']: continue
    sel[name] = expand(s)

def typed(s):
    o = {'type': s['transport']}
    if s['transport'] == 'stdio': o['command'], o['args'] = s['command'], s['args']
    else:
        o['url'] = s['url']
        if s.get('headers'): o['headers'] = s['headers']
    if s.get('timeoutMs'): o['timeout'] = s['timeoutMs']
    return o

def merge(path, top_key, build):
    data = {}
    if os.path.exists(path):
        with open(path, encoding='utf-8') as f:
            txt = f.read().strip()
            if txt: data = json.loads(txt)
    bucket = dict(data.get(top_key, {}))
    for k, s in sel.items():
        if k not in bucket: bucket[k] = build(s)
    data[top_key] = bucket
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f'  wrote {path}')

def oc_build(s):
    if s['transport'] == 'stdio':
        return {'type': 'local', 'command': [s['command']] + s['args'], 'enabled': True}
    o = {'type': 'remote', 'url': s['url'], 'enabled': True}
    if s.get('headers'): o['headers'] = s['headers']
    return o

for t in [x.strip() for x in targets.split(',') if x.strip()]:
    if t == 'cursor':
        merge(os.path.join(home, '.cursor', 'mcp.json'), 'mcpServers', typed)
    elif t == 'vscode':
        base = os.environ.get('APPDATA') or os.path.join(home, '.config')
        merge(os.path.join(base, 'Code', 'User', 'mcp.json'), 'servers', typed)
    elif t == 'opencode':
        merge(os.path.join(home, '.config', 'opencode', 'opencode.json'), 'mcp', oc_build)
    elif t == 'claude':
        gen = os.path.join(repo, 'mcp', 'generated')
        os.makedirs(gen, exist_ok=True)
        out = {'mcpServers': {k: typed(s) for k, s in sel.items()}}
        with open(os.path.join(gen, 'claude.mcp.json'), 'w', encoding='utf-8') as f:
            json.dump(out, f, ensure_ascii=False, indent=2)
        print(f'  wrote {os.path.join(gen, "claude.mcp.json")} (copy to project root as .mcp.json, or register user-scope:)')
        for k, s in out['mcpServers'].items():
            print(f"    claude mcp add-json {k} '{json.dumps(s)}' -s user")
    else:
        print(f'  unknown target {t!r} (supported: cursor, vscode, opencode, claude)')
PYEOF
echo "NOTE: tokenized output files live outside the repo or under mcp/generated/ (gitignored). Never commit them."
