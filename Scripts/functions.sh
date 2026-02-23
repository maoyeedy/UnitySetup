#!/usr/bin/env bash
# Shared utility functions for macOS Unity project setup
# Sourced by setup scripts — do not run directly

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DARKGRAY='\033[1;30m'
NC='\033[0m' # No Color

get_unity_version() {
    local paths=("./ProjectSettings/ProjectVersion.txt" "../ProjectSettings/ProjectVersion.txt")
    for path in "${paths[@]}"; do
        if [[ -f "$path" ]]; then
            grep 'm_EditorVersion:' "$path" | sed 's/^m_EditorVersion:[[:space:]]*//'
            return 0
        fi
    done
    echo -e "${RED}Error: ProjectSettings/ProjectVersion.txt not found.${NC}" >&2
    return 1
}

get_unity_editor_path() {
    local user_path_file="$HOME/Library/Application Support/UnityHub/secondaryInstallPath.json"
    if [[ ! -f "$user_path_file" ]]; then
        echo -e "${YELLOW}Warning: Unity Hub not installed.${NC}" >&2
        return 1
    fi

    local raw_content
    raw_content=$(<"$user_path_file")

    local user_path=""
    # Try jq first, fallback to manual parsing
    if command -v jq &>/dev/null; then
        user_path=$(echo "$raw_content" | jq -r 'if type == "string" then . elif type == "object" and has("path") then .path else "" end' 2>/dev/null)
    fi

    # Fallback: strip surrounding quotes from raw string
    if [[ -z "$user_path" ]]; then
        user_path=$(echo "$raw_content" | sed 's/^"//;s/"$//' | tr -d '\n\r')
    fi

    if [[ -n "$user_path" && -d "$user_path" ]]; then
        echo "$user_path"
        return 0
    fi

    # Default path for macOS
    local default_path="/Applications/Unity/Hub/Editor"
    if [[ -d "$default_path" ]]; then
        echo "$default_path"
        return 0
    fi

    echo -e "${RED}Error: Could not determine Unity Editor installation path.${NC}" >&2
    return 1
}

get_unity_editor_installation_path() {
    local version
    version=$(get_unity_version) || return 1

    local editor_base
    editor_base=$(get_unity_editor_path) || return 1

    local install_path="$editor_base/$version"
    if [[ -d "$install_path" ]]; then
        echo "$install_path"
        return 0
    fi

    echo -e "${RED}Error: Unity version $version not found in $editor_base${NC}" >&2
    return 1
}

get_unity_yaml_merge_path() {
    local editor_path
    editor_path=$(get_unity_editor_installation_path) || return 1

    local yaml_merge_path="$editor_path/Unity.app/Contents/Tools/UnityYAMLMerge"
    if [[ -x "$yaml_merge_path" ]]; then
        echo "$yaml_merge_path"
        return 0
    fi

    echo -e "${RED}Error: UnityYAMLMerge not found at $yaml_merge_path${NC}" >&2
    return 1
}

get_unity_merge_rules_path() {
    local editor_path
    editor_path=$(get_unity_editor_installation_path) || return 1

    local merge_rules_path="$editor_path/Unity.app/Contents/Tools/mergerules.txt"
    if [[ -f "$merge_rules_path" ]]; then
        echo "$merge_rules_path"
        return 0
    fi

    echo -e "${RED}Error: mergerules.txt not found at $merge_rules_path${NC}" >&2
    return 1
}

# Note: No assert_git_exit_code needed — all scripts use `set -e` which
# aborts on any non-zero exit code automatically.
