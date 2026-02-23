#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/functions.sh"

echo -e "\n${YELLOW}Configuring UnityYAMLMerge...${NC}"

yaml_merge_path=$(get_unity_yaml_merge_path) || {
    echo -e "${RED}Error: Could not find UnityYAMLMerge${NC}"
    exit 1
}

git config mergetool.unityyamlmerge.trustExitCode false
git config mergetool.unityyamlmerge.cmd "'$yaml_merge_path' merge -p \"\$BASE\" \"\$REMOTE\" \"\$LOCAL\" \"\$MERGED\""

echo -e "${GREEN}Configured Successfully.${NC}"
