#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/functions.sh"

echo -e "\n${YELLOW}Configuring MergeRules...${NC}"

merge_rules_path=$(get_unity_merge_rules_path) || {
    echo -e "${RED}Error: Could not find Unity mergerules.txt${NC}"
    exit 1
}

marker="# Custom rules added by setup script - do not remove this line"
local_rules="$SCRIPT_DIR/mergerules.txt"

if grep -qF "$marker" "$merge_rules_path" 2>/dev/null; then
    echo -e "${CYAN}Custom rules appear to already exist (marker found). Skipping append.${NC}"
else
    if [[ ! -r "$local_rules" ]]; then
        echo -e "${RED}Error: Local mergerules.txt not found at $local_rules${NC}"
        exit 1
    fi

    # Unity install dir is typically owned by root on macOS
    if [[ -w "$merge_rules_path" ]]; then
        printf '\n' >> "$merge_rules_path"
        cat "$local_rules" >> "$merge_rules_path"
    else
        echo -e "${YELLOW}sudo required to modify Unity's mergerules.txt${NC}"
        sudo sh -c "printf '\n' >> '$merge_rules_path' && cat '$local_rules' >> '$merge_rules_path'"
    fi
    echo -e "${GREEN}Appended custom rules successfully.${NC}"
fi
