[CmdletBinding()]
param()

if (-not (Get-Command -Name 'Get-UnityVersion' -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot\functions.ps1"
}

Write-Host "`nConfiguring Git LFS..." -ForegroundColor Yellow
try {
    git lfs install
    Write-Host "Configured Successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to install Git LFS: $_"
    exit 1
}
