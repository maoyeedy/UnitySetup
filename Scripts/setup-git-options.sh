#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/functions.sh"

echo -e "\n${YELLOW}Configuring Git Options for Unity...${NC}"

set_config() {
    git config "$1" "$2"
    echo -e "  ${DARKGRAY}$1 = $2${NC}"
}

set_config core.autocrlf input
set_config core.safecrlf false
set_config core.filemode false
set_config pull.rebase true
set_config rebase.autoStash true
set_config fetch.prune true
set_config rerere.enabled true

if [[ "$PLATFORM" == "windows" ]]; then
    set_config core.longpaths true
fi

echo -e "${GREEN}Git configurations updated successfully.${NC}"
echo -e "${CYAN}Note: These are LOCAL repo settings (--local). For global, use --global instead.${NC}"
