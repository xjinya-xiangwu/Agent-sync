@echo off
setlocal EnableExtensions
for /f "usebackq tokens=1,* delims==" %%A in ("%~dp0credentials.env") do set "%%A=%%B"
"C:\Users\xujinya\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe" "C:\Users\xujinya\.codex\mcp-servers\lark-mcp\node_modules\@larksuiteoapi\lark-mcp\dist\cli.js" login -a "%FEISHU_APP_ID%" -s "%FEISHU_APP_SECRET%"
