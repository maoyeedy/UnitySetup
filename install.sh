#!/usr/bin/env bash
# Unity Project Setup — remote bootstrapper
# Usage: curl -fsSL https://raw.githubusercontent.com/Maoyeedy/UnitySetup/master/install.sh | bash
set -euo pipefail

REPO_URL="https://github.com/Maoyeedy/UnityProjectSetupScripts.git"
INSTALL_DIR=".setup"

# --- Check git is installed ---
if ! command -v git &>/dev/null; then
    echo -e "\033[0;31mError: Git is not installed or not in PATH.\033[0m"
    exit 1
fi

# --- Validate Unity project root ---
if [[ ! -f "./ProjectSettings/ProjectVersion.txt" ]]; then
    echo -e "\033[0;31mError: Not a Unity project root. Run this from the folder containing ProjectSettings/.\033[0m"
    echo -e "\033[0;31mCurrent directory: $PWD\033[0m"
    exit 1
fi

# --- Ensure git repo exists ---
if [[ ! -d ".git" ]]; then
    if [[ -t 0 ]]; then
        read -rp "No .git directory found. Initialize a new git repo here? (y/n) " answer
        if [[ "$answer" != "y" ]]; then
            echo -e "\033[1;33mAborted.\033[0m"
            exit 0
        fi
    else
        echo -e "\033[0;36mNo .git directory found. Initializing...\033[0m"
    fi
    git init
fi

# --- Exclude .setup from git tracking ---
exclude_file=".git/info/exclude"
if ! grep -qx '\.setup' "$exclude_file" 2>/dev/null; then
    echo ".setup" >> "$exclude_file"
    echo -e "\033[0;36mAdded '.setup' to $exclude_file\033[0m"
fi

# --- Download ---
if [[ -d "$INSTALL_DIR" ]]; then
    rm -rf "$INSTALL_DIR"
fi
echo -e "\033[0;36mCloning setup scripts into $INSTALL_DIR...\033[0m"
git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
rm -rf "$INSTALL_DIR/.git"

# --- Execute ---
chmod +x "$INSTALL_DIR/setup.sh"
bash "$INSTALL_DIR/setup.sh"
