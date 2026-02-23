#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/functions.sh"

echo -e "\n${YELLOW}Configuring Git LFS...${NC}"

filter=$(git config --get filter.lfs.process 2>/dev/null || true)
hook_path="$(git rev-parse --git-dir)/hooks/post-merge"
has_lfs_hook=false
if [[ -f "$hook_path" ]] && grep -q 'git-lfs' "$hook_path" 2>/dev/null; then
    has_lfs_hook=true
fi

if [[ -n "$filter" && "$has_lfs_hook" == true ]]; then
    echo -e "${DARKGRAY}Git LFS is already configured, skipping.${NC}"
else
    git lfs install
    echo -e "  ${DARKGRAY}Hook: $hook_path${NC}"
    echo -e "${GREEN}Configured Successfully.${NC}"
fi
