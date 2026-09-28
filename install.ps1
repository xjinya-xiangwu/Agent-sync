# Agent-sync installer (Windows). Run: .\install.ps1 [-ForceMergeMemories]
param(
    [switch]$ForceMergeMemories
)
$ErrorActionPreference = 'Stop'
$Repo = Split-Path -Parent $MyInvocation.MyCommand.Path
$Home2 = $HOME
$ts = Get-Date -Format 'yyyyMMdd-HHmmss'

function Backup-IfExists($path) {
    if (Test-Path $path) { Move-Item $path "$path.backup-$ts" }
}

Write-Host "== Agent-sync install from $Repo =="

# 1) ZCode skills -> junction (edits go straight into the repo checkout)
$skillsSrc = Join-Path $Repo 'zcode\skills'
$skillsDst = Join-Path $Home2 '.zcode\skills'
New-Item -ItemType Directory -Force -Path (Split-Path $skillsDst) | Out-Null
$item = Get-Item $skillsDst -ErrorAction SilentlyContinue
if ($item -and $item.LinkType -eq 'Junction' -and $item.Target -eq $skillsSrc) {
    Write-Host "skills junction already OK"
} else {
    Backup-IfExists $skillsDst
    New-Item -ItemType Junction -Path $skillsDst -Target $skillsSrc | Out-Null
    Write-Host "skills junction created (old dir backed up if any)"
}

# 2) Unified AGENTS.md -> ~/.codex/AGENTS.md
$agentsDst = Join-Path $Home2 '.codex\AGENTS.md'
New-Item -ItemType Directory -Force -Path (Split-Path $agentsDst) | Out-Null
$agentsSrc = Join-Path $Repo 'global\AGENTS.md'
if ((Test-Path $agentsDst) -and ((Get-FileHash $agentsDst).Hash -ne (Get-FileHash $agentsSrc).Hash)) {
    Backup-IfExists $agentsDst
}
Copy-Item $agentsSrc $agentsDst -Force
Write-Host "AGENTS.md deployed to ~/.codex"

# 3) ZCode memories: copy only missing project keys (never overwrite local-newer)
$memSrc = Join-Path $Repo 'zcode\memories-projects'
$memDst = Join-Path $Home2 '.zcode\cli\memories\projects'
New-Item -ItemType Directory -Force -Path $memDst | Out-Null
Get-ChildItem $memSrc -Directory | ForEach-Object {
    $dst = Join-Path $memDst $_.Name
    if (-not (Test-Path $dst)) {
        Copy-Item $_.FullName $dst -Recurse; Write-Host "zcode memory added: $($_.Name)"
    } elseif ($ForceMergeMemories) {
        robocopy $_.FullName $dst /E /XC /XN /XO /NJH /NJS /NDL /NFL | Out-Null
        Write-Host "zcode memory merged: $($_.Name)"
    } else { Write-Host "zcode memory exists, skipped (use -ForceMergeMemories): $($_.Name)" }
}

# 4) Codex memories: add missing files only
$cmSrc = Join-Path $Repo 'codex\memories'
$cmDst = Join-Path $Home2 '.codex\memories'
if (-not (Test-Path $cmDst)) {
    Copy-Item $cmSrc $cmDst -Recurse; Write-Host "codex memories installed"
} else {
    robocopy $cmSrc $cmDst /E /XC /XN /XO /NJH /NJS /NDL /NFL | Out-Null
    Write-Host "codex memories merged (missing files only)"
}

# 5) Codex hooks.json (only if absent — hooks usually already configured locally)
$hooksDst = Join-Path $Home2 '.codex\hooks.json'
if (-not (Test-Path $hooksDst)) {
    Copy-Item (Join-Path $Repo 'codex\hooks.json') $hooksDst
    Write-Host "codex hooks.json installed"
} else { Write-Host "codex hooks.json exists, skipped" }

# 6) Workspace documents: add missing files
$wsSrc = Join-Path $Repo 'projects\workspace-default'
$wsDst = Join-Path $Home2 '.zcode\workspace\default'
New-Item -ItemType Directory -Force -Path $wsDst | Out-Null
robocopy $wsSrc $wsDst /E /XC /XN /XO /NJH /NJS /NDL /NFL | Out-Null
Write-Host "workspace documents merged (missing files only)"

Write-Host @"

== Manual steps required (contain secrets, NOT auto-applied) ==
 1. zcode\cli.config.template.json -> merge into ~\.zcode\cli\config.json
    (replace `$GITHUB_MCP_PAT / `$BAIDU_PAN_MCP_TOKEN with real values)
 2. codex\config.toml.template -> ~\.codex\config.toml
    (replace `$CODEX_BEARER_TOKEN with real value)
 3. Local MCP servers: see codex\mcp-servers-setup\README.md
"@