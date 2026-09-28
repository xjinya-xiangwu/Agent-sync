---
name: ue-python-api
description: Use the Unreal Editor's built-in unreal Python API for complex, batched, or conditional edits that named MCP Tools cannot handle. Distinguish the ProgrammaticToolset orchestration sandbox from a real Editor Python execution channel. Use for explicit Python requests, cross-API batching, or a missing named Tool.
---

# Unreal Python API

Commands using scripts/... are relative to the plugin root, the directory containing kimi.plugin.json, or should use absolute paths. The skill directory has no scripts subdirectory.

This skill uses the unreal module inside the Unreal Editor process. It is not helper Python in the Kimi plugin directory and not runtime code for a packaged game. UE 5.8 ships embedded Python; the project must enable PythonScriptPlugin and EditorScriptingUtilities, with an Editor restart after the first change. ue-connection checks this with the MCP plugin; users do not need to toggle Plugins-panel settings manually.

## Route selection

1. Prefer a named MCP Tool for one or a few objects when it provides clear types, reads, writes, and verification. Use list_toolsets → search_tools → describe_tool → call_tool; use full describe_toolset only when narrow discovery is unavailable.
2. Probe ProgrammaticToolset. It normally orchestrates registered MCP tools. Treat execute_tool_script as an Editor-Python executor only when its live description explicitly promises Editor Python, the unreal module, or import unreal. Tool existence alone is not evidence.
3. If named Tools are insufficient and the Programmatic contract does not prove Python capability, use only an Editor Python/Console bridge already installed and explicitly exposed by the project. Without such a bridge, report the capability gap. Never claim that plugin helper Python, system Python, or direct .uasset/.umap edits are an Editor Python endpoint.
4. Use the task and live Schema as the source of truth. Choose the route with fewer calls and more direct verification when both work.
5. Do not run two capability routes concurrently. Unreal MCP Tools execute serially on the Game Thread.

## Preflight and execution

On connection failure or an unconfigured project, run scripts/preflight.py and load ue-connection. Check ModelContextProtocol, AllToolsets, MCPClientToolset, PythonScriptPlugin, and EditorScriptingUtilities.

Resolve current Editor Python capability read-only with:

macOS: python3 scripts/ue_capability_router.py resolve unreal-python-api
Windows: python scripts/ue_capability_router.py resolve unreal-python-api

Read the current ProgrammaticToolset Schema and description. Only an explicit Editor-Python/unreal-module contract permits import unreal. If the Toolset is absent, recheck AllToolsets, Python plugin state, and the required restart.

When Python capability is proven, use current Editor APIs, set_editor_property for UObject changes, Asset/Editor APIs for assets, exact Actor refs and /Game/... paths, bounded batches, and structured results with status, changed, skipped, failed, paths, old/new values, dirty packages, and errors. Never use os.rename, shutil.move, binary writes, or direct .uasset/.umap edits.

Use ScopedEditorTransaction where supported. Do not assume API, compile, import, save, or external outputs are rollbackable.

## Verification

Before a write, state the actual channel, target, count, script summary, and expected impact. Manifest and ue-editor-operations define authorization; do not repeat policy for every item. Execute serially once, include channel in the result, and never automatically rerun an uncertain write. Verify with independent named read tools or a proven read-only Python query; screenshots supplement but do not replace structured results. Report dirty packages and do not default to Save All.

Unreal Python is Editor-only, not PIE, Standalone, or cooked-build runtime Python. Preserve raw tracebacks, MCP isError values, and structured returns.
