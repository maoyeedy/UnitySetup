#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If setup.sh lives inside .setup/ at the project root, cd up to the Unity project root
if [[ ! -f "./ProjectSettings/ProjectVersion.txt" && -f "$SCRIPT_DIR/../ProjectSettings/ProjectVersion.txt" ]]; then
    cd "$SCRIPT_DIR/.."
fi

if [[ ! -f "./ProjectSettings/ProjectVersion.txt" ]]; then
    echo -e "\033[0;31mError: Not a Unity project root (ProjectSettings/ProjectVersion.txt not found).\033[0m"
    echo -e "\033[0;31mCurrent directory: $PWD\033[0m"
    exit 1
fi

source "$SCRIPT_DIR/Scripts/functions.sh"

echo -e "\n${CYAN}Starting Project setup for:${NC}"
echo "$PWD"

bash "$SCRIPT_DIR/Scripts/setup-git-lfs.sh"
bash "$SCRIPT_DIR/Scripts/setup-git-options.sh"
bash "$SCRIPT_DIR/Scripts/setup-unityyamlmerge.sh"
bash "$SCRIPT_DIR/Scripts/setup-merge-rules.sh"

echo -e "\n${CYAN}Project setup completed!${NC}"
