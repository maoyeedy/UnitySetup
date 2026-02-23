[CmdletBinding()]
param()

if (-not (Get-Command -Name 'Get-UnityVersion' -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot\functions.ps1"
}

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Verbose "Not admin — spawning elevated process for MergeRules..."
    $scriptPath = $MyInvocation.MyCommand.Path
    $proc = Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        Write-Error "Elevated MergeRules setup failed (exit code: $($proc.ExitCode))."
        exit 1
    }
    exit 0
}

Write-Host "`nConfiguring MergeRules..." -ForegroundColor Yellow
try {
    $mergeRulesPath = Get-UnityMergeRulesPath
    if (-not $mergeRulesPath) {
        throw "Could not find Unity mergerules.txt"
    }

    $localRules = Get-Content "$PSScriptRoot\mergerules.txt" -Raw

    Write-Verbose $localRules

    Add-Content -Path $mergeRulesPath -Value "`n$localRules"

    Write-Host "Configured Successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to configure MergeRules: $_"
    exit 1
}
