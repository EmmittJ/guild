#Requires -Version 5.1
# setup.ps1 — interactive Guild markdown backend setup
# Usage: .\setup.ps1 -RepoRoot <path> [-NonInteractive] [-Components memory|tasks|inbox|all] [-SkillsDir <path>]
#   -RepoRoot   absolute path to the repository root (required)

param(
    [Parameter(Mandatory=$true)]
    [string]$RepoRoot,
    [switch]$NonInteractive,
    [ValidateSet("memory","tasks","inbox","all")]
    [string]$Components,
    [string]$SkillsDir
)

$ErrorActionPreference = "Stop"

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillRoot  = Split-Path -Parent $ScriptDir
$AssetsDir  = Join-Path $SkillRoot "assets\skills"

# ── Component selection ──────────────────────────────────────────────────────

if (-not $NonInteractive -and -not $Components) {
    Write-Host ""
    Write-Host "Guild Markdown Setup"
    Write-Host "──────────────────────────────────"
    Write-Host "Which components do you want to install?"
    Write-Host "  1) memory  — decisions, insights, context"
    Write-Host "  2) tasks   — open/in_progress/closed task files"
    Write-Host "  3) inbox   — async agent-to-agent messaging"
    Write-Host "  4) all     (default)"
    Write-Host ""
    $choice = Read-Host "Select [1/2/3/4]"
    $Components = switch ($choice) {
        "1" { "memory" }
        "2" { "tasks" }
        "3" { "inbox" }
        default { "all" }
    }
} elseif (-not $Components) {
    $Components = if ($env:GUILD_COMPONENTS) { $env:GUILD_COMPONENTS } else { "all" }
}

# ── Skills directory ─────────────────────────────────────────────────────────

if (-not $NonInteractive -and -not $SkillsDir) {
    $input = Read-Host "`nSkills directory [.github/skills]"
    $SkillsDir = if ($input) { $input } else { ".github/skills" }
} elseif (-not $SkillsDir) {
    $SkillsDir = if ($env:GUILD_SKILLS_DIR) { $env:GUILD_SKILLS_DIR } else { ".github/skills" }
}

$SkillsAbs = Join-Path $RepoRoot $SkillsDir

# ── Helpers ──────────────────────────────────────────────────────────────────

function Ensure-Dir($path) {
    if (Test-Path $path) { return }
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    Write-Host "  created $path"
}

function Copy-Skill($name, $rootPath) {
    $dest = Join-Path $SkillsAbs "$name\SKILL.md"
    if (Test-Path $dest) {
        Write-Host "  skipped $SkillsDir\$name\SKILL.md (already exists)"
        return
    }
    $destDir = Split-Path $dest
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    $content = Get-Content (Join-Path $AssetsDir "$name\SKILL.md") -Raw
    $content = $content.Replace("`${${name}_root}", $rootPath)
    Set-Content $dest $content -Encoding UTF8
    Write-Host "  copied  $SkillsDir\$name\SKILL.md (root: $rootPath)"
}

function Add-GitignoreEntry($entry) {
    $gitignore   = Join-Path $RepoRoot ".gitignore"
    $markerStart = "# guild-managed"
    $markerEnd   = "# end guild-managed"

    # Already present anywhere — skip
    if ((Test-Path $gitignore) -and (Select-String -Path $gitignore -SimpleMatch $entry -Quiet)) { return }

    if ((Test-Path $gitignore) -and (Select-String -Path $gitignore -SimpleMatch $markerStart -Quiet)) {
        # Block exists — insert entry before the end marker
        $lines = Get-Content $gitignore
        $out   = foreach ($line in $lines) {
            if ($line -eq $markerEnd) { $entry }
            $line
        }
        Set-Content $gitignore $out -Encoding UTF8
    } else {
        # No block yet — append one
        Add-Content $gitignore -Value "" -Encoding UTF8
        Add-Content $gitignore -Value $markerStart -Encoding UTF8
        Add-Content $gitignore -Value $entry -Encoding UTF8
        Add-Content $gitignore -Value $markerEnd -Encoding UTF8
    }
    Write-Host "  added   $entry to .gitignore"
}

# ── Install memory ───────────────────────────────────────────────────────────

function Install-Memory {
    Write-Host "`nInstalling memory..."
    if (-not $NonInteractive) {
        $input = Read-Host "  Memory root [.guild/memory]"
        $MemoryRoot = if ($input) { $input } else { ".guild/memory" }
    } else {
        $MemoryRoot = if ($env:GUILD_MEMORY_ROOT) { $env:GUILD_MEMORY_ROOT } else { ".guild/memory" }
    }
    Ensure-Dir (Join-Path $RepoRoot "$MemoryRoot\decisions")
    Ensure-Dir (Join-Path $RepoRoot "$MemoryRoot\insights")
    Ensure-Dir (Join-Path $RepoRoot "$MemoryRoot\context")

    # Keep dirs in git
    foreach ($dir in @("decisions","insights")) {
        $keep = Join-Path $RepoRoot "$MemoryRoot\$dir\.gitkeep"
        if (-not (Test-Path $keep)) {
            New-Item -ItemType File -Path $keep -Force | Out-Null
            Write-Host "  created $MemoryRoot\$dir\.gitkeep"
        }
    }

    # Context files are ephemeral — keep out of git
    Add-GitignoreEntry "$MemoryRoot/context/"

    $summary = Join-Path $RepoRoot "$MemoryRoot\decisions\_summary.md"
    if (-not (Test-Path $summary)) {
        "# Decision Summary`n`n_No decisions recorded yet._" | Set-Content $summary -Encoding UTF8
        Write-Host "  created $MemoryRoot\decisions\_summary.md"
    }

    $script:MemoryRootOut = $MemoryRoot
    Copy-Skill "memory" $MemoryRoot
}

# ── Install tasks ────────────────────────────────────────────────────────────

function Install-Tasks {
    Write-Host "`nInstalling tasks..."
    if (-not $NonInteractive) {
        $input = Read-Host "  Tasks root [.guild/tasks]"
        $TasksRoot = if ($input) { $input } else { ".guild/tasks" }
    } else {
        $TasksRoot = if ($env:GUILD_TASKS_ROOT) { $env:GUILD_TASKS_ROOT } else { ".guild/tasks" }
    }
    foreach ($dir in @("open","in_progress","closed")) {
        $dirPath = Join-Path $RepoRoot "$TasksRoot\$dir"
        Ensure-Dir $dirPath
        $keep = Join-Path $dirPath ".gitkeep"
        if (-not (Test-Path $keep)) {
            New-Item -ItemType File -Path $keep -Force | Out-Null
            Write-Host "  created $TasksRoot\$dir\.gitkeep"
        }
    }
    $script:TasksRootOut = $TasksRoot
    Copy-Skill "tasks" $TasksRoot
}

# ── Install inbox ────────────────────────────────────────────────────────────

function Install-Inbox {
    Write-Host "`nInstalling inbox..."
    if (-not $NonInteractive) {
        $input = Read-Host "  Inbox root [.guild/inbox]"
        $InboxRoot = if ($input) { $input } else { ".guild/inbox" }
    } else {
        $InboxRoot = if ($env:GUILD_INBOX_ROOT) { $env:GUILD_INBOX_ROOT } else { ".guild/inbox" }
    }
    $inboxDir = Join-Path $RepoRoot $InboxRoot
    Ensure-Dir $inboxDir

    # Inbox messages are ephemeral — keep out of git
    Add-GitignoreEntry "$InboxRoot/"

    $script:InboxRootOut = $InboxRoot
    Copy-Skill "inbox" $InboxRoot
}

# ── Run ──────────────────────────────────────────────────────────────────────

switch ($Components) {
    "memory" { Install-Memory }
    "tasks"  { Install-Tasks }
    "inbox"  { Install-Inbox }
    default  { Install-Memory; Install-Tasks; Install-Inbox }
}

Write-Host "`nDone. Next: add the installed skills to your plugin.json or AGENTS.md:"
Write-Host ""
switch ($Components) {
    "memory" { Write-Host "  `"skills`": [`"$SkillsDir/memory`"]"
               Write-Host ""
               Write-Host "  Memory root: $script:MemoryRootOut" }
    "tasks"  { Write-Host "  `"skills`": [`"$SkillsDir/tasks`"]"
               Write-Host ""
               Write-Host "  Tasks root:  $script:TasksRootOut" }
    "inbox"  { Write-Host "  `"skills`": [`"$SkillsDir/inbox`"]"
               Write-Host ""
               Write-Host "  Inbox root:  $script:InboxRootOut" }
    default  { Write-Host "  `"skills`": [`"$SkillsDir/memory`", `"$SkillsDir/tasks`", `"$SkillsDir/inbox`"]"
               Write-Host ""
               Write-Host "  Memory root: $script:MemoryRootOut"
               Write-Host "  Tasks root:  $script:TasksRootOut"
               Write-Host "  Inbox root:  $script:InboxRootOut" }
}
Write-Host ""
