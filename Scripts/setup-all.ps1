[CmdletBinding()]
param()

if (Test-Path -Path ".\Setup.bat") {
    # Ensure runs at Unity project root
    Set-Location "$PSScriptRoot\..\.."
}

if (-not (Test-Path -Path ".\ProjectSettings\ProjectVersion.txt")) {
    Write-Error "Not a Unity project root (ProjectSettings/ProjectVersion.txt not found)."
    Write-Host "Current directory: $PWD" -ForegroundColor Red
    exit 1
}

. "$PSScriptRoot\functions.ps1"

$IsVerbose = $true

Write-Host "`nStarting Project setup for:" -ForegroundColor Cyan
Write-Host $PWD

& "$PSScriptRoot\setup-git-lfs.ps1" -Verbose:$IsVerbose

& "$PSScriptRoot\setup-git-options.ps1" -Verbose:$IsVerbose

# & "$PSScriptRoot\setup-submodules.ps1" -Verbose:$IsVerbose

& "$PSScriptRoot\setup-unityyamlmerge.ps1" -Verbose:$IsVerbose

& "$PSScriptRoot\setup-merge-rules.ps1" -Verbose:$IsVerbose

Write-Host "`nProject setup completed!" -ForegroundColor Cyan
