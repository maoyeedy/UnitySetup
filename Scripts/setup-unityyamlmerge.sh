#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/functions.sh"

echo -e "\n${YELLOW}Configuring UnityYAMLMerge...${NC}"

yaml_merge_path=$(get_unity_yaml_merge_path) || {
    echo -e "${RED}Error: Could not find UnityYAMLMerge${NC}"
    exit 1
}

echo -e "  ${DARKGRAY}Binary: $yaml_merge_path${NC}"

git config mergetool.unityyamlmerge.trustExitCode false
echo -e "  ${DARKGRAY}mergetool.unityyamlmerge.trustExitCode = false${NC}"

cmd="'$yaml_merge_path' merge -p \"\$BASE\" \"\$REMOTE\" \"\$LOCAL\" \"\$MERGED\""
git config mergetool.unityyamlmerge.cmd "$cmd"
echo -e "  ${DARKGRAY}mergetool.unityyamlmerge.cmd = $cmd${NC}"

echo -e "${GREEN}Configured Successfully.${NC}"
