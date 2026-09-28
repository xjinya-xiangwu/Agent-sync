---
name: ue-connection
description: Connect, start, configure, and diagnose the local Unreal Engine 5.8 MCP. Use for connection failures, first-time setup, empty tools, opening a project, port conflicts, Toolset inspection, logs, or failed UE calls. This skill does not edit scene content.
---

# UE Connection and Discovery

This is the only connection-layer entry point. It covers health checks, project plugin configuration, Editor launch, Toolset/Schema discovery, and log diagnosis. Determine the state first and choose the shortest action; do not repeat the same check.

## State path

- For first connection, failures, or a changed tool surface, run python3 scripts/preflight.py. To write project configuration, use scripts/ue_mcp_ensure.py; it keeps a backup and handles restarts safely.
- If the Editor is not running, run python3 scripts/ue_editor_launcher.py project.uproject --launch --confirm for an explicit project. Ask once only when project, version, or Editor identity is ambiguous; never force-kill a process.
- If the Editor is running, connect to its MCP directly. Read -ModelContextProtocolPort=<port> from the process command line; project endpoints take precedence over the default. On a port conflict, ensure selects the next free loopback port and remembers it.
- Report starting, port-not-listening, port-occupied-or-incompatible, and toolsets-incomplete distinctly. Do not kill or relaunch during a cold start.

## MCP discovery

With Tool Search enabled, `tools/list` may expose only `list_toolsets`, `describe_toolset`, and `call_tool`; individual UE tools may not appear as top-level MCP tools. Discover and dispatch through the live contract:

1. Call `list_toolsets`, then describe the relevant Toolset. If the needed Toolset is already known, `describe_toolset` may be used directly.
2. Use `call_tool` with the discovered `toolset_name`, `tool_name`, and `arguments`; the result returns on the same MCP turn.
3. If the server exposes narrow search tools, prefer `search_tools → describe_tool` before a full Toolset description.

Names, parameters, and results come only from the current live Schema. Rediscover at most once after a Schema error, and never automatically replay a write.

## Project and endpoint

Accept only an explicit project or a uniquely identifiable running project; stop guessing when multiple Editors/projects exist. Endpoints must remain loopback. Resolve them through the shared resolver (explicit argument, environment variable, project config, global config, default). Never change 127.0.0.1 to a LAN address.

## Project Agent Skills

When a task depends on project-specific naming, folder layout, Blueprint conventions, asset-pack rules, or other local knowledge, discover the live Unreal Agent Skills through `AgentSkillToolset` and load only the matching skill. Project Agent Skills supplement live object inspection and Toolset Schema; they do not replace either.

## Diagnosis

Preserve original error text and structured evidence. Distinguish Editor process, TCP, initialize, server identity, tools/list, and Toolset probes. Use the current live Editor and scripts for detailed UE 5.8 facts and diagnostic branches.

## Boundary

This skill performs read-only diagnosis or an explicitly requested connection action. It does not edit scene assets, change Editor Preferences automatically, or store credentials. A request to configure or open a named project is already authorization; do not add another confirmation turn.
