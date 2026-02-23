@echo off
set "VERBOSE_FLAG="
if "%~1"=="--verbose" set "VERBOSE_FLAG= -Verbose"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$moduleName='Microsoft.PowerShell.Security'; $moduleLoaded=$false; if (Get-Module -ListAvailable -Name $moduleName) { try { Import-Module -Name $moduleName -ErrorAction Stop; $moduleLoaded=$true } catch {} }; if (-not $moduleLoaded -and (Get-Command Install-Module -ErrorAction SilentlyContinue)) { try { Install-Module -Name $moduleName -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop; Import-Module -Name $moduleName -ErrorAction Stop; $moduleLoaded=$true } catch {} }; if (Get-Command Set-ExecutionPolicy -ErrorAction SilentlyContinue) { Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force } else { Write-Warning 'Set-ExecutionPolicy is unavailable. Please verify Microsoft.PowerShell.Security.' }"
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
powershell -Command "Start-Process powershell -Verb RunAs -Args '-noe -nop -c \"cd ''%SCRIPT_DIR%''; & ''%SCRIPT_DIR%\Scripts\setup-all.ps1''%VERBOSE_FLAG%\"'"
