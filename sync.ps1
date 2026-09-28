# Agent-sync daily sync. Usage: .\sync.ps1 pull | push
param([Parameter(Mandatory=$true)][ValidateSet('pull','push')][string]$Action)
$ErrorActionPreference = 'Stop'
$Repo = Split-Path -Parent $MyInvocation.MyCommand.Path
$rc_ok = { if ($LASTEXITCODE -ge 8) { throw "robocopy failed: $LASTEXITCODE" } }

if ($Action -eq 'pull') {
    git -C $Repo pull --ff-only
    if ($LASTEXITCODE -ne 0) { throw "git pull failed" }
    & (Join-Path $Repo 'install.ps1')
    return
}

# ---- push: collect local-newer artifacts back into the repo ----
# skills live inside the repo already (junction), nothing to collect.
robocopy "$HOME\.zcode\cli\memories\projects" "$Repo\zcode\memories-projects" /E /XC /XN /XO /NJH /NJS /NDL /NFL | Out-Null; & $rc_ok
robocopy "$HOME\.codex\memories" "$Repo\codex\memories" /E /XC /XN /XO /NJH /NJS /NDL /NFL | Out-Null; & $rc_ok
# workspace: never copy .git dirs (nested repos become broken gitlinks); dirs in
# WorkspaceExcludes are independent git repos with their own GitHub remote — they sync themselves.
$WorkspaceExcludes = @('ai-coldstart')
$xd = (@('.git') + $WorkspaceExcludes) | ForEach-Object { $_ }
robocopy "$HOME\.zcode\workspace\default" "$Repo\projects\workspace-default" /E /XC /XN /XO /NJH /NJS /NDL /NFL `
    /XF debug.log nul kurt-login-qrcode.png xiangwu-init-qrcode.png /XD @xd | Out-Null; & $rc_ok

git -C $Repo add -A
if (git -C $Repo diff --cached --quiet) { Write-Host "nothing to push"; return }
git -C $Repo commit -m "sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm') from $env:COMPUTERNAME"
git -C $Repo push
Write-Host "pushed."