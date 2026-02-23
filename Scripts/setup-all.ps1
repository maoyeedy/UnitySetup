[CmdletBinding()]
param()

if (Test-Path -Path ".\Setup.bat") {
    # Ensure runs at Unity project root
    Set-Location "$PSScriptRoot\..\.."
}

. "$PSScriptRoot\functions.ps1"

$IsVerbose = $VerbosePreference -eq 'Continue'

Write-Host "`nStarting Project setup for:" -ForegroundColor Cyan
Write-Host $PWD

& "$PSScriptRoot\setup-git-lfs.ps1" -Verbose:$IsVerbose

& "$PSScriptRoot\setup-git-options.ps1" -Verbose:$IsVerbose

& "$PSScriptRoot\setup-submodules.ps1" -Verbose:$IsVerbose

& "$PSScriptRoot\setup-unityyamlmerge.ps1" -Verbose:$IsVerbose

& "$PSScriptRoot\setup-merge-rules.ps1" -Verbose:$IsVerbose

Write-Host "`nProject setup completed!" -ForegroundColor Cyan
