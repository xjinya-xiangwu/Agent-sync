@echo off
setlocal EnableExtensions
for /f "usebackq tokens=1,* delims==" %%A in ("%~dp0credentials.env") do set "%%A=%%B"
if not defined FEISHU_APP_ID exit /b 1
if not defined FEISHU_APP_SECRET exit /b 1
"C:\Users\xujinya\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe" "C:\Users\xujinya\.codex\mcp-servers\lark-mcp\node_modules\@larksuiteoapi\lark-mcp\dist\cli.js" mcp -a "%FEISHU_APP_ID%" -s "%FEISHU_APP_SECRET%" --token-mode user_access_token --language zh -t "preset.default,wiki.v2.spaceNode.create,bitable.v1.appTable.delete"



