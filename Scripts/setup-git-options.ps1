[CmdletBinding()]
param()

if (-not (Get-Command -Name 'Get-UnityVersion' -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot\functions.ps1"
}

Write-Host "`nConfiguring Git Options..." -ForegroundColor Yellow
try {
    git config core.autocrlf input
    Write-Verbose "core.autocrlf set to input"
    git config core.safecrlf true
    Write-Verbose "core.safecrlf set to true"
    git config core.longpaths true
    Write-Verbose "core.longpaths set to true"
    git config pull.rebase true
    Write-Verbose "pull.rebase set to true"

    Write-Host "Configured Successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to set Git configurations: $_"
    exit 1
}
