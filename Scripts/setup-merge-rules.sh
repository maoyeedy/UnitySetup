#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/functions.sh"

echo -e "\n${YELLOW}Configuring MergeRules...${NC}"

merge_rules_path=$(get_unity_merge_rules_path) || {
    echo -e "${RED}Error: Could not find Unity mergerules.txt${NC}"
    exit 1
}

echo -e "  ${DARKGRAY}Target: $merge_rules_path${NC}"

marker="# Custom rules added by setup script - do not remove this line"
local_rules="$SCRIPT_DIR/mergerules.txt"

if grep -qF "$marker" "$merge_rules_path" 2>/dev/null; then
    echo -e "${CYAN}Custom rules already exist (marker found). Skipping.${NC}"
else
    if [[ ! -r "$local_rules" ]]; then
        echo -e "${RED}Error: Local mergerules.txt not found at $local_rules${NC}"
        exit 1
    fi

    echo -e "  ${DARKGRAY}Source: $local_rules${NC}"

    # Try writing directly first; fall back to sudo (macOS/Linux) or error message (Windows)
    # Use a subshell so redirect failures don't abort under set -e
    if (printf '\n' >> "$merge_rules_path" && cat "$local_rules" >> "$merge_rules_path") 2>/dev/null; then
        : # success
    elif [[ "$PLATFORM" == "macos" || "$PLATFORM" == "linux" ]]; then
        echo -e "${YELLOW}sudo required to modify Unity's mergerules.txt${NC}"
        sudo sh -c "printf '\n' >> '$merge_rules_path' && cat '$local_rules' >> '$merge_rules_path'"
    else
        echo -e "${YELLOW}Cannot write to $merge_rules_path — please run from an admin shell.${NC}"
        exit 0
    fi
    echo -e "${GREEN}Appended custom rules successfully.${NC}"
fi
