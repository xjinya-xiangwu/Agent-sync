# Generate per-agent MCP configs from mcp/mcp-servers.json (canonical registry).
# Usage: .\setup-mcp.ps1 -Targets cursor,vscode,opencode,claude [-IncludeOptional]
# claude target: writes mcp/generated/claude.mcp.json AND prints `claude mcp add-json` commands.
#   Real tokens: set env GITHUB_MCP_PAT / BAIDU_PAN_MCP_TOKEN before running, or fill generated files locally.
param(
    [string[]]$Targets = @('cursor', 'vscode', 'opencode', 'claude'),
    [switch]$IncludeOptional
)
$ErrorActionPreference = 'Stop'
$Repo = Split-Path -Parent $MyInvocation.MyCommand.Path
$registry = Get-Content (Join-Path $Repo 'mcp\mcp-servers.json') -Raw | ConvertFrom-Json
$GenDir = Join-Path $Repo 'mcp\generated'
New-Item -ItemType Directory -Force -Path $GenDir | Out-Null

# expand placeholders; tokens resolve from env if set, else stay literal
function Expand-Templates([object]$node) {
    if ($node -is [System.Management.Automation.PSCustomObject]) {
        $o = [ordered]@{}
        foreach ($p in $node.PSObject.Properties) { $o[$p.Name] = Expand-Templates $p.Value }
        return $o
    }
    if ($node -is [array]) { return ,@($node | ForEach-Object { Expand-Templates $_ }) }
    if ($node -is [string]) {
        $s = $node -replace '\$\{HOME\}', $HOME
        foreach ($t in @('GITHUB_MCP_PAT', 'BAIDU_PAN_MCP_TOKEN')) {
            $v = [Environment]::GetEnvironmentVariable($t)
            if ($v) { $s = $s -replace ("\$\{" + $t + "\}"), $v }
        }
        return $s
    }
    return $node
}

$sel = @{}
foreach ($p in $registry.servers.PSObject.Properties) {
    if ($p.Value.optional -and -not $IncludeOptional) { continue }
    if ($p.Value.platforms -and $p.Value.platforms -notcontains 'windows') { continue }
    $sel[$p.Name] = Expand-Templates $p.Value
}
Write-Host "servers included: $($sel.Keys -join ', ')"

# CC/ZCode-style stdio def -> {command, args, env}
function To-Stdio($s) {
    $o = [ordered]@{ command = $s.command; args = $s.args }
    if ($s.headers) { $o.headers = $s.headers }
    return $o
}
function To-Typed($s) {
    $o = [ordered]@{ type = $s.transport; }
    if ($s.transport -eq 'stdio') { $o.command = $s.command; $o.args = $s.args }
    else { $o.url = $s.url; if ($s.headers) { $o.headers = $s.headers } }
    if ($s.timeoutMs) { $o.timeout = $s.timeoutMs }
    return $o
}

function Merge-JsonFile($path, $topKey, $buildValue) {
    $json = if (Test-Path $path) { Get-Content $path -Raw | ConvertFrom-Json } else { $null }
    if (-not $json) { $json = [PSCustomObject]@{} }
    elseif ($json.$topKey) { Write-Host "  $path : '$topKey' already has entries, merging (existing keys win)"; }
    $bucket = @{}
    if ($json.$topKey) { foreach ($p in $json.$topKey.PSObject.Properties) { $bucket[$p.Name] = $p.Value } }
    foreach ($k in $sel.Keys) { if (-not $bucket.ContainsKey($k)) { $bucket[$k] = & $buildValue $sel[$k] } }
    $json | Add-Member -Force -MemberType NoteProperty -Name $topKey -Value ([PSCustomObject]$bucket)
    $out = $json | ConvertTo-Json -Depth 10
    # preserve existing file if it only gained entries we just wrote (idempotent-ish)
    [IO.File]::WriteAllText($path, $out)
    Write-Host "  wrote $path"
}

foreach ($t in $Targets) {
    switch ($t) {
        'cursor' {
            $dir = Join-Path $HOME '.cursor'; New-Item -ItemType Directory -Force -Path $dir | Out-Null
            Merge-JsonFile (Join-Path $dir 'mcp.json') 'mcpServers' { param($s) To-Typed $s }
        }
        'vscode' {
            $path = Join-Path $env:APPDATA 'Code\User\mcp.json'
            New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
            Merge-JsonFile $path 'servers' { param($s) To-Typed $s }
        }
        'opencode' {
            $dir = Join-Path $HOME '.config\opencode'; New-Item -ItemType Directory -Force -Path $dir | Out-Null
            # opencode: local -> command array; remote/sse -> {type,url,headers}
            Merge-JsonFile (Join-Path $dir 'opencode.json') 'mcp' {
                param($s)
                if ($s.transport -eq 'stdio') {
                    $cmd = @($s.command) + @($s.args)
                    [ordered]@{ type = 'local'; command = $cmd; enabled = $true }
                } else {
                    $o = [ordered]@{ type = 'remote'; url = $s.url; enabled = $true }
                    if ($s.headers) { $o.headers = $s.headers }
                    $o
                }
            }
        }
        'claude' {
            $servers = [ordered]@{}
            foreach ($k in $sel.Keys) { $servers[$k] = To-Typed $sel[$k] }
            $proj = [ordered]@{ mcpServers = $servers }
            $genPath = Join-Path $GenDir 'claude.mcp.json'
            [IO.File]::WriteAllText($genPath, ($proj | ConvertTo-Json -Depth 10))
            Write-Host "  wrote $genPath (copy to a project root as .mcp.json, or register user-scope via:)"
            foreach ($k in $sel.Keys) {
                $j = ($servers[$k] | ConvertTo-Json -Depth 10 -Compress)
                Write-Host "    claude mcp add-json $k '$j' -s user"
            }
        }
        default { Write-Host "  unknown target '$t' (supported: cursor, vscode, opencode, claude)" }
    }
}
Write-Host "`nNOTE: if env tokens were set, generated/user files now contain real tokens - they live outside the repo or under mcp/generated/ (gitignored). Never move them into the repo."