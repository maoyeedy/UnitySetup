[CmdletBinding()]
param(
    [string]$ProjectRoot
)

if (-not (Get-Command -Name 'Get-UnityVersion' -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot\functions.ps1"
}

if ($ProjectRoot) {
    Set-Location -LiteralPath $ProjectRoot
}

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`nConfiguring MergeRules requires admin privileges." -ForegroundColor Yellow
    $mergeRulesPath = Get-UnityMergeRulesPath
    if ($mergeRulesPath) {
        Write-Verbose "Changes will be applied to: $mergeRulesPath"
    }
    $scriptPath = $MyInvocation.MyCommand.Path
    try {
        $proc = Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -ProjectRoot `"$($PWD.Path)`"" -Wait -PassThru
        if ($proc.ExitCode -ne 0) {
            Write-Warning "MergeRules setup failed in elevated process. Run manually from an admin shell."
        } else {
            Write-Host "Configured Successfully." -ForegroundColor Green
        }
    }
    catch {
        Write-Warning "Could not elevate for MergeRules (UAC declined?). Run manually from an admin shell."
    }
    exit 0
}

Write-Host "`nConfiguring MergeRules..." -ForegroundColor Yellow
try {
    $mergeRulesPath = Get-UnityMergeRulesPath
    if (-not $mergeRulesPath) {
        throw "Could not find Unity mergerules.txt"
    }

    $marker = "# Custom rules added by setup script - do not remove this line"
    $targetContent = Get-Content $mergeRulesPath -Raw

    if ($targetContent -match [regex]::Escape($marker)) {
        Write-Host "Custom rules appear to already exist (marker found). Skipping append." -ForegroundColor Cyan
    } else {
        $localRules = Get-Content "$PSScriptRoot\mergerules.txt" -Raw
        Add-Content -Path $mergeRulesPath -Value "`n$localRules" -Encoding utf8
        Write-Host "Appended custom rules successfully." -ForegroundColor Green
    }
}
catch {
    Write-Error "Failed to configure MergeRules: $_"
    exit 1
}
