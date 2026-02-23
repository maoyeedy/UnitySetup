# Unity Project Setup — remote bootstrapper
# Usage: irm https://raw.githubusercontent.com/Maoyeedy/UnityProjectSetupScripts/master/install.ps1 | iex

$ErrorActionPreference = 'Stop'
$RepoUrl = "https://github.com/Maoyeedy/UnityProjectSetupScripts.git"
$InstallDir = ".setup"

# --- Check git is installed ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git is not installed or not in PATH."
    return
}

# --- Validate Unity project root ---
if (-not (Test-Path ".\ProjectSettings\ProjectVersion.txt")) {
    Write-Error "Not a Unity project root. Run this from the folder containing ProjectSettings/."
    Write-Host "Current directory: $PWD" -ForegroundColor Red
    return
}

# --- Ensure git repo exists ---
if (-not (Test-Path ".git")) {
    $answer = Read-Host "No .git directory found. Initialize a new git repo here? (y/n)"
    if ($answer -ne 'y') { Write-Host "Aborted." -ForegroundColor Yellow; return }
    git init
    if ($LASTEXITCODE -ne 0) { Write-Error "git init failed."; return }
}

# --- Exclude .setup from git tracking ---
$excludeFile = ".git\info\exclude"
$excludeEntry = ".setup"
if (-not (Select-String -Path $excludeFile -Pattern "^\.setup$" -Quiet -ErrorAction SilentlyContinue)) {
    Add-Content -Path $excludeFile -Value $excludeEntry
    Write-Host "Added '$excludeEntry' to $excludeFile" -ForegroundColor Cyan
}

# --- Download ---
if (Test-Path $InstallDir) {
    Remove-Item $InstallDir -Recurse -Force
}
Write-Host "Cloning setup scripts into $InstallDir..." -ForegroundColor Cyan
git clone --depth 1 --quiet $RepoUrl $InstallDir
if ($LASTEXITCODE -ne 0) { Write-Error "git clone failed."; return }
Remove-Item "$InstallDir\.git" -Recurse -Force

# --- Find Git Bash and execute ---
$candidates = @(
    "$env:ProgramFiles\Git\bin\bash.exe"
    "${env:ProgramFiles(x86)}\Git\bin\bash.exe"
)

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

$setupScript = "$InstallDir/setup.sh"
& $bashExe --login -c "cd '$(($PWD.Path) -replace '\\','/')' && bash '$(($setupScript) -replace '\\','/')'"
