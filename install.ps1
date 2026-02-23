# Unity Project Setup — remote bootstrapper (Windows)
# Usage: irm https://raw.githubusercontent.com/Maoyeedy/UnitySetup/master/install.ps1 | iex
# Finds Git Bash and delegates to install.sh

$ErrorActionPreference = 'Stop'

# --- Find Git Bash ---
$candidates = @(
    "$env:ProgramFiles\Git\bin\bash.exe"
    "${env:ProgramFiles(x86)}\Git\bin\bash.exe"
) + @(Get-ChildItem "$env:LOCALAPPDATA\Fork\gitInstance\*\bin\bash.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)

$bashExe = $null
foreach ($path in $candidates) {
    if (Test-Path $path) {
        $bashExe = $path
        break
    }
}

if (-not $bashExe) {
    $bashExe = (Get-Command bash -ErrorAction SilentlyContinue).Source
}

if (-not $bashExe) {
    Write-Error "Git for Windows is required (bash.exe not found). Install from https://git-scm.com"
    return
}

# --- Delegate to install.sh via bash ---
& $bashExe --login -c "cd '$(($PWD.Path) -replace '\\','/')' && curl -fsSL https://raw.githubusercontent.com/Maoyeedy/UnitySetup/master/install.sh | bash"
