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

# Merge driver — runs automatically during git merge/pull for files with
# merge=unityyamlmerge in .gitattributes. Resolves conflicts silently when possible.
git config merge.unityyamlmerge.name "UnityYAMLMerge"
git config merge.unityyamlmerge.driver "'$yaml_merge_path' merge -p %O %B %A %A"
echo -e "  ${DARKGRAY}merge.unityyamlmerge.driver configured${NC}"

# Mergetool — manual fallback via `git mergetool` for conflicts the driver couldn't resolve.
git config mergetool.unityyamlmerge.trustExitCode false
cmd="'$yaml_merge_path' merge -p \"\$BASE\" \"\$REMOTE\" \"\$LOCAL\" \"\$MERGED\""
git config mergetool.unityyamlmerge.cmd "$cmd"
echo -e "  ${DARKGRAY}mergetool.unityyamlmerge.cmd configured${NC}"

echo -e "${GREEN}Configured Successfully.${NC}"
