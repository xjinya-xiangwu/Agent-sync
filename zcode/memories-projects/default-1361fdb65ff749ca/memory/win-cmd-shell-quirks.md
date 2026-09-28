---
name: win-cmd-shell-quirks
description: Shell history — ZCode Bash tool ran cmd.exe in older sessions, runs
  Git Bash since ~2026-09-28; git/winget node installed; multi-line node -e fails
  under cmd wrapper — write .js file instead
metadata:
  node_type: memory
  type: project
  originSessionId: sess_791c45e0-35fd-41e2-a964-ad6268e139b2
---

On this Windows 10 machine (xujinya), the Bash tool's shell varies by session: in older sessions (2026-09-20 era) it ran cmd.exe — `${VAR:+x}` style syntax echoed literally, PowerShell invocations could get cancelled, and multi-line `node -e "…"` one-liners silently produced NO output under the cmd wrapper (exit 0, nothing runs) — write the script to a temp .js file and run `node file.js` instead. Since ~2026-09-28 ZCode reports **Git Bash** as the shell: bash syntax, `/c/...` paths, awk/sed pipelines all work normally; the cmd-specific caveats above apply only if a session again runs cmd.exe.

Git IS installed (2026-09-20, via winget Git.Git 2.55.0.3) at `C:\Program Files\Git\bin\git.exe`; global identity configured as xjinya-xiangwu / 51788368+xjinya-xiangwu@users.noreply.github.com (from gh account, see [[github-account-auth]]). GitHub CLI (gh 2.101.0) is installed via winget at `C:\Program Files\GitHub CLI\gh.exe` — use full path in old shells. For repo downloads use `curl -L` zipball + `tar -xf` (bsdtar handles zip). A WinGet Node LTS exists as `node` (v24) for JSON validation and scripting. Robocopy works well for copying plugin trees (exit codes 0-7 are success).

Related: [[zcode-plugin-install-layout]]
