#Requires -Version 5.1
# setup.ps1 — interactive Guild GitHub Issues backend setup
# Usage: .\setup.ps1 -RepoRoot <path> [-NonInteractive] [-SkillsDir <path>] [-GuildRepo <owner/repo>]
#   -RepoRoot   absolute path to the repository root (required)

param(
    [Parameter(Mandatory=$true)]
    [string]$RepoRoot,
    [switch]$NonInteractive,
    [string]$SkillsDir,
    [string]$GuildRepo
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillRoot = Split-Path -Parent $ScriptDir
$AssetsDir = Join-Path $SkillRoot "assets\skills"

# ── Auth check ───────────────────────────────────────────────────────────────

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "Error: gh CLI is required. Install from https://cli.github.com"
    exit 1
}

$authCheck = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Error: gh CLI is not authenticated. Run: gh auth login"
    exit 1
}

# ── Skills directory ─────────────────────────────────────────────────────────

if (-not $NonInteractive -and -not $SkillsDir) {
    Write-Host ""
    Write-Host "Guild GitHub Setup"
    Write-Host "──────────────────────────────────"
    Write-Host ""
    $input = Read-Host "Skills directory [.github/skills]"
    $SkillsDir = if ($input) { $input } else { ".github/skills" }
} elseif (-not $SkillsDir) {
    $SkillsDir = if ($env:GUILD_SKILLS_DIR) { $env:GUILD_SKILLS_DIR } else { ".github/skills" }
}

$SkillsAbs = Join-Path $RepoRoot $SkillsDir

# ── Repo slug ────────────────────────────────────────────────────────────────

if (-not $NonInteractive -and -not $GuildRepo) {
    $detectedRepo = (gh repo view --json nameWithOwner -q .nameWithOwner 2>$null)
    if ($detectedRepo) {
        $input = Read-Host "Repo (owner/repo) [$detectedRepo]"
        $GuildRepo = if ($input) { $input } else { $detectedRepo }
    } else {
        $GuildRepo = Read-Host "Repo (owner/repo)"
    }
    if (-not $GuildRepo) {
        Write-Error "Error: repo slug is required (e.g. owner/repo)"
        exit 1
    }
} elseif (-not $GuildRepo) {
    $GuildRepo = if ($env:GUILD_REPO) { $env:GUILD_REPO } else { $null }
    if (-not $GuildRepo) {
        Write-Error "Error: GUILD_REPO is required in CI mode (e.g. owner/repo)"
        exit 1
    }
}

# ── Create labels ────────────────────────────────────────────────────────────

Write-Host "`nCreating labels..."
gh label create "open"             --color "#0075ca" --force -R $GuildRepo | Out-Null; Write-Host "  done    open"
gh label create "in-progress"     --color "#e4e669" --force -R $GuildRepo | Out-Null; Write-Host "  done    in-progress"
gh label create "blocked"         --color "#d73a4a" --force -R $GuildRepo | Out-Null; Write-Host "  done    blocked"
gh label create "priority:high"   --color "#b60205" --force -R $GuildRepo | Out-Null; Write-Host "  done    priority:high"
gh label create "priority:medium" --color "#fbca04" --force -R $GuildRepo | Out-Null; Write-Host "  done    priority:medium"
gh label create "priority:low"    --color "#cfd3d7" --force -R $GuildRepo | Out-Null; Write-Host "  done    priority:low"

# ── Install tasks skill ──────────────────────────────────────────────────────

Write-Host "`nInstalling github-issues skill..."
$dest = Join-Path $SkillsAbs "github-issues\SKILL.md"
$destDir = Split-Path $dest
New-Item -ItemType Directory -Path $destDir -Force | Out-Null
$existed = Test-Path $dest
$content = Get-Content (Join-Path $AssetsDir "github-issues\SKILL.md") -Raw
$content = $content.Replace('${github_repo}', $GuildRepo)
Set-Content $dest $content -Encoding UTF8
if ($existed) {
    Write-Host "  replaced $SkillsDir\github-issues\SKILL.md with GitHub Issues backend (repo: $GuildRepo)"
} else {
    Write-Host "  copied   $SkillsDir\github-issues\SKILL.md (repo: $GuildRepo)"
}

# ── Done ─────────────────────────────────────────────────────────────────────

Write-Host "`nDone. Add the installed skill to your plugin.json or AGENTS.md:"
Write-Host ""
Write-Host "  `"skills`": [`"$SkillsDir/github-issues`"]"
Write-Host ""
Write-Host "  Repo: $GuildRepo"
Write-Host ""
Write-Host "For memory and inbox, run: /guild-setup-markdown"
Write-Host ""


