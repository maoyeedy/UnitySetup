[CmdletBinding()]
param()

if (-not (Get-Command -Name 'Get-UnityVersion' -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot\functions.ps1"
}

Write-Host "`nConfiguring UnityYAMLMerge..." -ForegroundColor Yellow
try {
    $yamlMergePath = Get-UnityYAMLMergePath
    if (-not $yamlMergePath) {
        throw "Could not find UnityYAMLMerge.exe"
    }

    git config mergetool.unityyamlmerge.trustExitCode false
    Assert-GitExitCode "Failed to set mergetool.unityyamlmerge.trustExitCode"

    $cmd = "'$yamlMergePath' merge -p `"`$BASE`" `"`$REMOTE`" `"`$LOCAL`" `"`$MERGED`""
    # Write-Host "$cmd" -ForegroundColor DarkGray
    git config mergetool.unityyamlmerge.cmd $cmd
    Assert-GitExitCode "Failed to set mergetool.unityyamlmerge.cmd"
    $configValue = git config --get mergetool.unityyamlmerge.cmd
    if ($configValue) { Write-Verbose $configValue }

    Write-Host "Configured Successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to configure UnityYAMLMerge: $_"
    exit 1
}
