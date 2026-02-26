#!/usr/bin/env bash
# Unity Project Setup — remote bootstrapper
# Usage: curl -fsSL https://raw.githubusercontent.com/Maoyeedy/UnitySetup/master/install.sh | bash
set -euo pipefail

RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_URL="https://github.com/Maoyeedy/UnitySetup.git"
INSTALL_DIR=".setup"

# --- Preflight checks ---
if ! command -v git &>/dev/null; then
    echo -e "${RED}Error: Git is not installed or not in PATH.${NC}"
    exit 1
fi

if [[ ! -f "./ProjectSettings/ProjectVersion.txt" ]]; then
    echo -e "${RED}Error: Not a Unity project root. Run this from the folder containing ProjectSettings/.${NC}"
    echo -e "${RED}Current directory: $PWD${NC}"
    exit 1
fi

# --- Ensure git repo exists ---
if [[ ! -d ".git" && -t 0 ]]; then
    read -rp "No .git directory found. Initialize a new git repo here? (y/n) " answer
    if [[ "$answer" != "y" ]]; then
        echo -e "${YELLOW}Aborted.${NC}"
        exit 0
    fi
    git init
elif [[ ! -d ".git" ]]; then
    echo -e "${CYAN}No .git directory found. Initializing...${NC}"
    git init
fi

# --- Exclude .setup from git tracking ---
exclude_file=".git/info/exclude"
if ! grep -qx '\.setup' "$exclude_file" 2>/dev/null; then
    echo ".setup" >> "$exclude_file"
    echo -e "${CYAN}Added '.setup' to $exclude_file${NC}"
fi

# --- Download and execute ---
rm -rf "$INSTALL_DIR"
echo -e "${CYAN}Cloning setup scripts into $INSTALL_DIR...${NC}"
git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
rm -rf "$INSTALL_DIR/.git"
bash "$INSTALL_DIR/setup.sh"

echo ""
echo -e "${CYAN}Recommended: Add a .gitattributes and .gitignore tailored for Unity:${NC}"
echo -e "  ${YELLOW}https://github.com/gitattributes/gitattributes/blob/master/Unity.gitattributes${NC}"
echo -e "  ${YELLOW}https://github.com/github/gitignore/blob/main/Unity.gitignore${NC}"
