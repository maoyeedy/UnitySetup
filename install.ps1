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

# --- Download ---
if (Test-Path "$InstallDir\Scripts\setup-all.ps1") {
    Write-Host "$InstallDir already present, skipping download." -ForegroundColor DarkGray
} else {
    if (Test-Path $InstallDir) {
        Remove-Item $InstallDir -Recurse -Force
    }
    Write-Host "Cloning setup scripts into $InstallDir..." -ForegroundColor Cyan
    git clone --depth 1 --quiet $RepoUrl $InstallDir
    if ($LASTEXITCODE -ne 0) { Write-Error "git clone failed."; return }
    Remove-Item "$InstallDir\.git" -Recurse -Force
}

# --- Execute ---
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force -ErrorAction SilentlyContinue
& "$InstallDir\Scripts\setup-all.ps1"
