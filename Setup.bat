@echo off
set "VERBOSE_FLAG="
if "%~1"=="--verbose" set "VERBOSE_FLAG=-Verbose"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Scripts\setup-all.ps1" %VERBOSE_FLAG%
