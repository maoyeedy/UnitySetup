# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

UnitySetup is a cross-platform one-liner that configures Unity projects for Git version control. It sets up Git LFS, UnityYAMLMerge as a merge tool, custom merge rules for floating-point tolerances, and Unity-optimized Git options.

## Running the Scripts

There is no build system or test suite. To test changes locally, run from within a Unity project directory:

```bash
bash ./setup.sh
```

Remote installation uses `install.sh` (bash) or `install.ps1` (PowerShell) as entry points.

## Architecture

**Execution flow:** `install.ps1`/`install.sh` → `setup.sh` → individual setup scripts

- **install.ps1** — Windows entry point. Finds Git Bash and delegates to `install.sh`.
- **install.sh** — Unix entry point. Validates environment, clones repo into `.setup/`, runs `setup.sh`.
- **setup.sh** — Orchestrator. Sources `Scripts/functions.sh`, then runs each setup module in sequence.

**Setup modules** (each handles one concern, skips if already configured):
- `Scripts/setup-git-lfs.sh` — Initializes Git LFS
- `Scripts/setup-git-options.sh` — Sets local Git config (autocrlf, rebase, longpaths, etc.)
- `Scripts/setup-unityyamlmerge.sh` — Configures UnityYAMLMerge as the Git merge tool
- `Scripts/setup-merge-rules.sh` — Appends custom floating-point tolerance rules to Unity's `mergerules.txt`

**Shared utilities:**
- `Scripts/functions.sh` — Platform detection (Windows/macOS/Linux), Unity Hub path resolution, Unity version parsing from `ProjectSettings/ProjectVersion.txt`, color constants

## Conventions

- All shell scripts use `set -euo pipefail` (strict mode).
- `.gitattributes` enforces LF line endings for `*.sh` files.
- Git config is set with `--local` (per-repo, not global).
- Scripts are idempotent — they check for marker comments or existing config before modifying.
- `Scripts/mergerules.txt` contains custom merge rules appended to Unity's system-level `mergerules.txt`.

## Platform-Specific Paths

Unity Editor paths are resolved via `functions.sh`:
- **Windows:** `$PROGRAMFILES/Unity/Hub/Editor` or UnityHub's `secondaryInstallPath.json` in `$APPDATA`
- **macOS:** `/Applications/Unity/Hub/Editor` or `~/Library/Application Support/UnityHub/secondaryInstallPath.json`
- **Linux:** `$HOME/Unity/Hub/Editor`
