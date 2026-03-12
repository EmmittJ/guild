#Requires -Version 5.1
# sync-skills.ps1 — copy skills from plugin sources to .github/skills/
# Usage: .\sync-skills.ps1
# Finds the repo root by walking up from CWD until it finds a .git directory.

$ErrorActionPreference = "Stop"

# ── Find repo root ────────────────────────────────────────────────────────────

$RepoRoot = (Get-Location).Path
while ($RepoRoot -ne (Split-Path -Qualifier $RepoRoot) + '\') {
    if (Test-Path (Join-Path $RepoRoot ".git") -PathType Container) {
        break
    }
    $RepoRoot = Split-Path -Parent $RepoRoot
}

if (-not (Test-Path (Join-Path $RepoRoot ".git") -PathType Container)) {
    Write-Error "Error: could not find repo root (no .git directory found in any parent directory)"
    exit 1
}

# ── Paths ─────────────────────────────────────────────────────────────────────

$DstDir = Join-Path $RepoRoot ".github\skills"

# Map: skill name -> source directory (relative to repo root)
$SkillSources = [ordered]@{
    "orchestrate"  = "plugin\skills\orchestrate"
    "train-agent"  = "plugin\skills\train-agent"
    "train-skill"  = "plugin\skills\train-skill"
    # beads is synced here because this is the guild source repo. End-users who install
    # via /guild:setup get beads as a host-owned copy and do NOT have these sync scripts —
    # their copy won't be overwritten.
    "beads"        = "plugin\skills\setup\assets\skills\beads"
}

# ── Verify sources ────────────────────────────────────────────────────────────

foreach ($skill in $SkillSources.Keys) {
    $srcPath = Join-Path $RepoRoot $SkillSources[$skill]
    if (-not (Test-Path $srcPath -PathType Container)) {
        Write-Error "Error: source directory not found: $srcPath"
        exit 1
    }
}

# ── Ensure destination exists ─────────────────────────────────────────────────

if (-not (Test-Path $DstDir)) {
    New-Item -ItemType Directory -Path $DstDir | Out-Null
}

# ── Stamp metadata.asset in installed SKILL.md copies ────────────────────────

function Add-AssetToFrontmatter {
    param([string]$SkillMd, [string]$AssetPath)
    if (-not (Test-Path $SkillMd)) { return }
    $lines = Get-Content $SkillMd
    $delim = 0; $metaIdx = -1; $assetIdx = -1; $closeIdx = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -eq '---') {
            $delim++
            if ($delim -eq 2) { $closeIdx = $i; break }
        }
        if ($delim -eq 1) {
            if ($lines[$i] -match '^metadata:') { $metaIdx  = $i }
            if ($lines[$i] -match '^  asset:')  { $assetIdx = $i }
        }
    }
    $assetLine = "  asset: $AssetPath"
    if ($assetIdx -ge 0) {
        $lines[$assetIdx] = $assetLine
    } elseif ($metaIdx -ge 0) {
        $lines = $lines[0..$metaIdx] + $assetLine + $lines[($metaIdx + 1)..($lines.Count - 1)]
    } elseif ($closeIdx -ge 0) {
        $lines = $lines[0..($closeIdx - 1)] + 'metadata:' + $assetLine + $lines[$closeIdx..($lines.Count - 1)]
    } else { return }
    Set-Content $SkillMd $lines
}

# ── Compute relative path from dest SKILL.md to source SKILL.md ──────────────

function Get-AssetRelPath {
    param([string]$SrcRelToRepo)
    # dest is .github/skills/{name}/SKILL.md — 3 dirs up reaches repo root
    $prefix = ((1..3) | ForEach-Object { ".." }) -join '/'
    return "$prefix/$($SrcRelToRepo -replace '\\','/')/SKILL.md"
}

# ── Copy skills ───────────────────────────────────────────────────────────────

foreach ($skill in $SkillSources.Keys) {
    $srcPath = Join-Path $RepoRoot $SkillSources[$skill]
    Copy-Item -Recurse -Force -Path $srcPath -Destination $DstDir
    $skillMd  = Join-Path $DstDir "$skill\SKILL.md"
    $assetRel = Get-AssetRelPath $SkillSources[$skill]
    Add-AssetToFrontmatter $skillMd $assetRel
    Write-Host "Synced $skill -> .github/skills/$skill"
}

exit 0
