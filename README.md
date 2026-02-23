# Unity Project Setup Scripts

Make Unity Projects work better with VCS.

<!-- ![Screenshot](Public/carbon-dark.png) -->
![Screenshot](Public/carbon-light.png)
<!-- ![Screenshot](Public/ScreenshotAlt.png) -->
<!-- ![Screenshot](Public/ScreenshotNu.png) -->

## What they do

- Add [mergetool](Scripts/setup-unityyamlmerge.ps1) `unityyamlmerge` to `.git/config` (to be used with `.gitattributes`)
- Add [mergerules](Scripts/mergerules.txt) to make `unityyamlmerge` ignore negligible differences. [(Source)](https://docs.unity3d.com/Manual/SmartMerge.html)
- Add [hook](Scripts/setup-submodules.ps1) to auto-update submodules after `git pull/merge`
<!-- - ~~Make submodules also get fetched when you execute `git pull/fetch`~~ -->

(Details can be found in each `Scripts/*.ps1` or `Scripts/*.sh`, you may modify them to your liking.)

## Installation

Download as zip, and extract to Unity project root.

Or clone the repository:
```powershell
cd $UnityProjectRoot
git clone https://www.github.com/Maoyeedy/UnityProjectSetupScripts.git .setup
rm -r -fo .setup/.git
```

Or add as submodule:
```powershell
git submodule add https://www.github.com/Maoyeedy/UnityProjectSetupScripts.git .setup
```

Or use degit:
```powershell
degit Maoyeedy/UnityProjectSetupScripts .setup
```

Or use a one-liner:

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/Maoyeedy/UnitySetup/master/install.ps1 | iex
```

**macOS (Terminal):**
```bash
curl -fsSL https://raw.githubusercontent.com/Maoyeedy/UnitySetup/master/install.sh | bash
```

## Usage

### Windows
Double-click `Setup.bat` - it'll launch powershell with admin rights and run everything.

```powershell
# Launch new admin powershell with this
& ./.setup/Setup.bat

# Run each script separately
powershell -NoProfile ./.setup/Scripts/setup-unityyamlmerge.ps1
```

### macOS
```bash
# Run everything
bash ./.setup/setup.sh

# Run each script separately
bash ./.setup/Scripts/setup-unityyamlmerge.sh
```

The merge rules script will prompt for `sudo` when needed (Unity's install directory is owned by root on macOS).

## Troubleshooting

### Windows
- Run `powershell -Command "Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force"` if script can't execute.
- If `Microsoft.PowerShell.Security` fails to autoload, run `powershell -Command "Import-Module Microsoft.PowerShell.Security -ErrorAction SilentlyContinue; if (-not (Get-Command Set-ExecutionPolicy -ErrorAction SilentlyContinue) -and (Get-Command Install-Module -ErrorAction SilentlyContinue)) { Install-Module Microsoft.PowerShell.Security -Scope CurrentUser -Force -AllowClobber }; Import-Module Microsoft.PowerShell.Security"`.
- Unity Hub should be installed, as I use `$env:APPDATA\UnityHub\secondaryInstallPath.json` to retrieve installation paths.

### macOS
- Unity Hub should be installed. The scripts read `~/Library/Application Support/UnityHub/secondaryInstallPath.json` to resolve editor paths.
- If Unity is installed in a non-default location without Unity Hub, the scripts may not find it.

### General
- Unity and Git need to be installed, of course.

## TODO
- [x] Add `--verbose` argument.
- [x] Add more null/return checks.
- [ ] Make `Setup.bat` has interactive 'which scripts to run' toggles.
- [x] Make it work on MacOS.
- [x] Make it able to run with `irm | iex`
