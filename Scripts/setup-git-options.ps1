[CmdletBinding()]
param()

if (-not (Get-Command -Name 'Get-UnityVersion' -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot\functions.ps1"
}

Write-Host "`nConfiguring Git Options..." -ForegroundColor Yellow
try {
    git config core.autocrlf input
    Assert-GitExitCode "Failed to set core.autocrlf"
    Write-Verbose "core.autocrlf set to input"
    git config core.safecrlf true
    Assert-GitExitCode "Failed to set core.safecrlf"
    Write-Verbose "core.safecrlf set to true"
    git config core.longpaths true
    Assert-GitExitCode "Failed to set core.longpaths"
    Write-Verbose "core.longpaths set to true"
    git config pull.rebase true
    Assert-GitExitCode "Failed to set pull.rebase"
    Write-Verbose "pull.rebase set to true"

    Write-Host "Configured Successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to set Git configurations: $_"
    exit 1
}
