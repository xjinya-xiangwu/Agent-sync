---
name: win-cmd-shell-quirks
description: This machine's shell is cmd.exe (not bash); PowerShell calls can
  get cancelled; git installed 2026-09-20 (not on PATH in old shells) — use
  curl/tar/robocopy/system node
metadata:
  node_type: memory
  type: project
  originSessionId: sess_791c45e0-35fd-41e2-a964-ad6268e139b2
---

On this Windows 10 machine (xujinya), the Bash tool runs cmd.exe, not bash: `${VAR:+x}` style syntax echoes literally; use `if defined VAR` and `%VAR%` instead. A PowerShell invocation was cancelled once mid-session — prefer cmd built-ins. Git IS now installed (2026-09-20, via winget Git.Git 2.55.0.3) at `C:\Program Files\Git\bin\git.exe` — not on PATH in already-open shells, use full path; global identity configured as xjinya-xiangwu / 51788368+xjinya-xiangwu@users.noreply.github.com (from gh account, see [[github-account-auth]]). GitHub CLI (gh 2.101.0) is installed via winget at `C:\Program Files\GitHub CLI\gh.exe` — also use full path in old shells. For repo downloads use `curl -L` zipball + `tar -xf` (bsdtar handles zip). A WinGet Node LTS exists as `node` (v24) for JSON validation and scripting — paths referenced in ZCode's own MCP config (Codex runtime node.exe) may not exist. Robocopy works well for copying plugin trees (exit codes 0-7 are success). Multi-line `node -e "…"` one-liners silently produce NO output and NO effect under this Bash-tool cmd wrapper (exit 0, nothing runs) — write the script to a temp .js file and run `node file.js` instead (hit 2026-09-20 registering a plugin).

Related: [[zcode-plugin-install-layout]]
