# UnitySetup

Oneliner to setup Unity Project for VCS.

<!-- ![Screenshot](Public/carbon-dark.png) -->
![Screenshot](Public/carbon-light.png)
<!-- ![Screenshot](Public/ScreenshotAlt.png) -->
<!-- ![Screenshot](Public/ScreenshotNu.png) -->

## What they do

- Add [mergetool](Scripts/setup-unityyamlmerge.sh) `unityyamlmerge` to `.git/config` (to be used with `.gitattributes`)
- Add [mergerules](Scripts/mergerules.txt) to make `unityyamlmerge` ignore negligible differences. [(Source)](https://docs.unity3d.com/Manual/SmartMerge.html)

(Details can be found in each `Scripts/*.sh`, you may modify them to your liking.)

## Install

First `cd` to a Unity project root (the folder containing `ProjectSettings/`), then run:

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/Maoyeedy/UnitySetup/master/install.ps1 | iex
```

**macOS / Linux (Bash):**
```bash
curl -fsSL https://raw.githubusercontent.com/Maoyeedy/UnitySetup/master/install.sh | bash
```

The merge rules script will prompt for `sudo` on macOS/Linux (Unity's install directory is owned by root). On Windows, run from an admin Git Bash if needed.

## Troubleshooting

### Windows
- Git for Windows must be installed (the scripts run in Git Bash). Install from https://git-scm.com.
- Unity Hub should be installed. The scripts read `%APPDATA%\UnityHub\secondaryInstallPath.json` to resolve editor paths.
- If merge rules fail to write, run from an admin Git Bash.

### macOS
- Unity Hub should be installed. The scripts read `~/Library/Application Support/UnityHub/secondaryInstallPath.json` to resolve editor paths.
- If Unity is installed in a non-default location without Unity Hub, the scripts may not find it.

### Linux
- Unity Editor is expected at `~/Unity/Hub/Editor/<version>/`.
