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

# beads lives in a different source location
$BeadsSrc = Join-Path $RepoRoot "plugin\skills\setup\assets\skills\beads"

# ── Verify sources ────────────────────────────────────────────────────────────

foreach ($skill in $Skills) {
    $srcPath = Join-Path $SrcDir $skill
    if (-not (Test-Path $srcPath -PathType Container)) {
        Write-Error "Error: source directory not found: $srcPath"
        exit 1
    }
}
if (-not (Test-Path $BeadsSrc -PathType Container)) {
    Write-Error "Error: source directory not found: $BeadsSrc"
    exit 1
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

# ── Copy skills ───────────────────────────────────────────────────────────────

foreach ($skill in $Skills) {
    $srcPath = Join-Path $SrcDir $skill
    Copy-Item -Recurse -Force -Path $srcPath -Destination $DstDir
    $skillMd  = Join-Path $DstDir "$skill\SKILL.md"
    $assetRel = "../../../plugin/skills/$skill/SKILL.md"
    Add-AssetToFrontmatter $skillMd $assetRel
    Write-Host "Synced $skill -> .github/skills/$skill"
}

# Sync beads from its asset location
Copy-Item -Recurse -Force -Path $BeadsSrc -Destination $DstDir
$beadsSkillMd = Join-Path $DstDir "beads\SKILL.md"
$beadsAssetRel = "../../../plugin/skills/setup/assets/skills/beads/SKILL.md"
Add-AssetToFrontmatter $beadsSkillMd $beadsAssetRel
Write-Host "Synced beads -> .github/skills/beads"

exit 0
