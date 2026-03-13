#Requires -Version 5.1
# install.ps1 — copy Guild plugin skills into the current repo
# Usage: .\scripts\install.ps1 [-Target <path>]
#   Target defaults to .github/skills
#
# Requires git 2.25+ (sparse-checkout support)

param(
    [string]$Target = ".github\skills"
)

$ErrorActionPreference = "Stop"

$Tmp = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())

try {
    git clone --depth=1 --filter=blob:none --sparse `
        https://github.com/EmmittJ/guild.git $Tmp

    git -C $Tmp sparse-checkout set `
        plugin/skills/orchestrate `
        plugin/skills/train-agent `
        plugin/skills/train-skill `
        plugin/skills/work-cycle `
        plugin/skills/setup

    New-Item -ItemType Directory -Force -Path $Target | Out-Null
    Copy-Item -Recurse -Force "$Tmp\plugin\skills\*" $Target

    Write-Host "Guild skills installed to $Target"
    Write-Host "Run /setup in any agent chat to scaffold your team."
}
finally {
    if (Test-Path $Tmp) { Remove-Item -Recurse -Force $Tmp }
}
