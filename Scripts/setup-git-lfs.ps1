[CmdletBinding()]
param()

if (-not (Get-Command -Name 'Get-UnityVersion' -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot\functions.ps1"
}

Write-Host "`nConfiguring Git LFS..." -ForegroundColor Yellow
try {
    $filter = git config --get filter.lfs.process 2>$null
    if ($filter) {
        Write-Host "Git LFS is already configured, skipping." -ForegroundColor DarkGray
    } else {
        git lfs install
        Assert-GitExitCode "Failed to install Git LFS"
        Write-Host "Configured Successfully." -ForegroundColor Green
    }
}
catch {
    Write-Error "Failed to install Git LFS: $_"
    exit 1
}
