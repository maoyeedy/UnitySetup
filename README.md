# UnitySetup

Oneliner to setup Unity Project for VCS.

<!-- ![Screenshot](Public/carbon-dark.png) -->
![Screenshot](Public/carbon-light.png)
<!-- ![Screenshot](Public/ScreenshotAlt.png) -->
<!-- ![Screenshot](Public/ScreenshotNu.png) -->

## What they do

- Add [mergetool](Scripts/setup-unityyamlmerge.sh) `unityyamlmerge` to `.git/config` (to be used with `.gitattributes`)
- Add [mergerules](Scripts/mergerules.txt) to make `unityyamlmerge` ignore negligible differences. [(Source)](https://docs.unity3d.com/Manual/SmartMerge.html)

(Details can be found per `Scripts/*.sh`, you may modify them to your liking.)

## How to Use (Step-by-Step)

### Step 1: Open a Terminal in your project
First, you need to open a command line terminal inside your Unity project folder.

* **Windows:** Open your project folder in File Explorer, right-click on an empty space, and select **"Open in Terminal"**.
* **Mac:** Open your project folder in Finder, right-click the path bar at the bottom (or the folder itself), and select **"Open in Terminal"**.

### Step 2: Make sure Git is installed
Type these commands into your terminal and press Enter to check if Git is installed:
```bash
git -v
git lfs version
```
*If you see version numbers, you're good to go! Skip to Step 3.*  
*If you get an error, you need to install Git:*

* **Windows:** Run this command to install Git:
  ```powershell
  winget install Git.Git
  ```
* **Mac:** Install [Homebrew](https://brew.sh/) (if you haven't already), then run:
  ```bash
  brew install git git-lfs
  ```

### Step 3: Run the setup script
Copy and paste the command for your operating system into the terminal and press Enter:

* **Windows (PowerShell):**
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
  irm https://raw.githubusercontent.com/Maoyeedy/UnitySetup/master/install.ps1 | iex
  ```
* **Mac / Linux / Git Bash:**
  ```bash
  curl -fsSL https://raw.githubusercontent.com/Maoyeedy/UnitySetup/master/install.sh | bash
  ```

## Troubleshooting

* **Unity Hub Required:** This script automatically finds your Unity Editor location, but **it only works if you installed Unity via Unity Hub**.
