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

(Details can be found in each `Scripts/*.ps1`, you may modify them to your liking.)

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

## Usage

### Recommended
Double-click `Setup.bat` - it'll launch powershell with admin rights and run everything.

### Manually
```powershell
# Launch new admin powershell with this
& ./.setup/Setup.bat

# Run each script separately
powershell -NoProfile ./.setup/Scripts/setup-unityyamlmerge.ps1
```

## Troubleshooting

- Run `powershell -Command "Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force"` if script can't execute.
- If `Microsoft.PowerShell.Security` fails to autoload, run `powershell -Command "Import-Module Microsoft.PowerShell.Security -ErrorAction SilentlyContinue; if (-not (Get-Command Set-ExecutionPolicy -ErrorAction SilentlyContinue) -and (Get-Command Install-Module -ErrorAction SilentlyContinue)) { Install-Module Microsoft.PowerShell.Security -Scope CurrentUser -Force -AllowClobber }; Import-Module Microsoft.PowerShell.Security"`.
- Unity Hub should be installed, as I use `$env:APPDATA\UnityHub\secondaryInstallPath.json` to retrieve installation paths.
- Unity and Git need to be installed, of course.

## TODO
- [ ] Add `--verbose` argument.
- [ ] Add more null/return checks.
- [ ] Make `Setup.bat` has interactive 'which scripts to run' toggles.
- [ ] Make it work on Linux and MacOS.
- [ ] Make it able to run with `irm | iex`
