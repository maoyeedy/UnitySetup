[CmdletBinding()]
param()

if (-not (Get-Command -Name 'Get-UnityVersion' -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot\functions.ps1"
}

Write-Host "`nConfiguring Git Options for Unity Cross-Platform (Win + Mac)..." -ForegroundColor Yellow

try {
    # Line endings: input is best for cross-platform with .gitattributes eol=lf
    git config core.autocrlf input
    Assert-GitExitCode "Failed to set core.autocrlf"
    Write-Verbose "core.autocrlf set to input"

    # Disable safecrlf to prevent false positives on Unity YAML files (.meta, .unity, .anim etc.)
    git config core.safecrlf false
    Assert-GitExitCode "Failed to set core.safecrlf"
    Write-Verbose "core.safecrlf set to false (recommended for Unity)"

    # Enable long paths (essential on Windows for deep Unity project structures)
    git config core.longpaths true
    Assert-GitExitCode "Failed to set core.longpaths"
    Write-Verbose "core.longpaths set to true"

    # Make pull default to rebase (cleaner history)
    git config pull.rebase true
    Assert-GitExitCode "Failed to set pull.rebase"
    Write-Verbose "pull.rebase set to true"

    # Extra friendly settings for daily work (recommended for team, low risk)
    git config rebase.autoStash true
    Assert-GitExitCode "Failed to set rebase.autoStash"
    Write-Verbose "rebase.autoStash set to true"

    git config fetch.prune true
    Assert-GitExitCode "Failed to set fetch.prune"
    Write-Verbose "fetch.prune set to true"

    git config rerere.enabled true
    Assert-GitExitCode "Failed to set rerere.enabled"
    Write-Verbose "rerere.enabled set to true (reuse conflict resolutions)"

    git config rerere.autoUpdate true
    Assert-GitExitCode "Failed to set rerere.autoUpdate"
    Write-Verbose "rerere.autoUpdate set to true (auto-stage rerere-resolved files)"

    git config core.filemode false
    Assert-GitExitCode "Failed to set core.filemode"
    Write-Verbose "core.filemode set to false (ignore executable bit changes across OS)"

    Write-Host "Git configurations updated successfully!" -ForegroundColor Green
    Write-Host "Note: These are LOCAL repo settings (--local). For global, use --global instead." -ForegroundColor Cyan
}
catch {
    Write-Error "Failed to set Git configurations: $_"
    exit 1
}
