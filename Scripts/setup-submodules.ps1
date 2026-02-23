[CmdletBinding()]
param()

if (-not (Get-Command -Name 'Get-UnityVersion' -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot\functions.ps1"
}

Write-Host "`nConfiguring Git submodules..." -ForegroundColor Yellow
try{
    # git config submodule.recurse true
    # git config fetch.recurseSubmodules true
    # git config pull.recurseSubmodules true

    $postMergeHookPath = ".git/hooks/post-merge"
    $lineToAdd = @"
echo -e '\033[1;33mUpdating Submodules...\033[0m'
git submodule update --init --recursive
echo -e '\033[1;32mUpdate Complete\033[0m'
"@

    if (Test-Path $postMergeHookPath) {
        $content = Get-Content $postMergeHookPath
        if ($content -notcontains 'git submodule update --init --recursive --remote') {
            Add-Content -Path $postMergeHookPath -Value "`n$lineToAdd"
        }
    }

    Write-Verbose "Fetching remote submodules..."
    git submodule update --init --recursive --remote

    Write-Host "Configured Successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to set Git submodule configurations: $_"
    exit 1
}
