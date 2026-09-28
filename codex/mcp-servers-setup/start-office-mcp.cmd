@echo off
cd /d "C:\Users\xujinya\.codex\mcp-servers\microsoft-semanticworkbench\mcp-servers\mcp-server-office"
py -m uv run -m mcp_server.start --transport stdio
