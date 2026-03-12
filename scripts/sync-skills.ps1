#Requires -Version 5.1
# sync-skills.ps1 — copy orchestrate, train-agent, and train-skill from plugin/skills/ to .github/skills/
# Usage: .\sync-skills.ps1
# Finds the repo root by walking up from CWD until it finds a directory containing plugin.json.

$ErrorActionPreference = "Stop"

# ── Find repo root ────────────────────────────────────────────────────────────

$RepoRoot = (Get-Location).Path
while ($RepoRoot -ne (Split-Path -Qualifier $RepoRoot) + '\') {
    if (Test-Path (Join-Path $RepoRoot "plugin.json")) {
        break
    }
    $RepoRoot = Split-Path -Parent $RepoRoot
}

if (-not (Test-Path (Join-Path $RepoRoot "plugin.json"))) {
    Write-Error "Error: could not find repo root (no plugin.json found in any parent directory)"
    exit 1
}

# ── Paths ─────────────────────────────────────────────────────────────────────

$SrcDir = Join-Path $RepoRoot "plugin\skills"
$DstDir = Join-Path $RepoRoot ".github\skills"
$Skills = @("orchestrate", "train-agent", "train-skill")

# ── Verify sources ────────────────────────────────────────────────────────────

foreach ($skill in $Skills) {
    $srcPath = Join-Path $SrcDir $skill
    if (-not (Test-Path $srcPath -PathType Container)) {
        Write-Error "Error: source directory not found: $srcPath"
        exit 1
    }
}

# ── Ensure destination exists ─────────────────────────────────────────────────

if (-not (Test-Path $DstDir)) {
    New-Item -ItemType Directory -Path $DstDir | Out-Null
}

# ── Copy skills ───────────────────────────────────────────────────────────────

foreach ($skill in $Skills) {
    $srcPath = Join-Path $SrcDir $skill
    Copy-Item -Recurse -Force -Path $srcPath -Destination $DstDir
    Write-Host "Synced $skill -> .github/skills/$skill"
}

exit 0
