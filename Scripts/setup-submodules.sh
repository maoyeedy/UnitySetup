#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/functions.sh"

echo -e "\n${YELLOW}Configuring Git submodules...${NC}"

post_merge_hook=".git/hooks/post-merge"
hook_content="echo -e '\033[1;33mUpdating Submodules...\033[0m'
git submodule update --init --recursive
echo -e '\033[1;32mUpdate Complete\033[0m'"

if [[ -f "$post_merge_hook" ]]; then
    if ! grep -q 'git submodule update --init --recursive' "$post_merge_hook"; then
        printf '\n%s\n' "$hook_content" >> "$post_merge_hook"
    fi
else
    printf '#!/usr/bin/env bash\n%s\n' "$hook_content" > "$post_merge_hook"
fi
chmod +x "$post_merge_hook"

echo "Fetching remote submodules..."
git submodule update --init --recursive --remote

echo -e "${GREEN}Configured Successfully.${NC}"
