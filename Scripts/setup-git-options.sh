#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/functions.sh"

echo -e "\n${YELLOW}Configuring Git Options for Unity Cross-Platform (Win + Mac)...${NC}"

# Line endings: input is best for cross-platform with .gitattributes eol=lf
git config core.autocrlf input

# Disable safecrlf to prevent false positives on Unity YAML files (.meta, .unity, .anim etc.)
git config core.safecrlf false

# Enable long paths (essential on Windows for deep Unity project structures)
if [[ "$PLATFORM" == "windows" ]]; then
    git config core.longpaths true
fi

# Make pull default to rebase (cleaner history)
git config pull.rebase true

# Extra friendly settings for daily work
git config rebase.autoStash true
git config fetch.prune true
git config rerere.enabled true
git config rerere.autoUpdate true
git config core.filemode false

echo -e "${GREEN}Git configurations updated successfully!${NC}"
echo -e "${CYAN}Note: These are LOCAL repo settings (--local). For global, use --global instead.${NC}"
