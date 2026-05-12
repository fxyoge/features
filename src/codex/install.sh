#!/usr/bin/env bash

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIFECYCLE_DIR="/usr/local/share/devcontainer-features/fxy-codex"

set -euo pipefail

run_as_user() {
    local user="$1"
    shift
    local cmd="$*"
    
    if command -v runuser > /dev/null; then
        if command -v apk > /dev/null; then
            runuser "$user" -c "$cmd"
        else
            runuser -l "$user" -c "$cmd"
        fi
    elif command -v su > /dev/null; then
        if command -v apk > /dev/null; then
            su "$user" -c "$cmd"
        else
            su --login -c "$cmd" "$user"
        fi
    elif command -v sudo > /dev/null; then
        if command -v apk > /dev/null; then
            sudo -u "$user" sh -c "$cmd"
        else
            sudo -u "$user" -i bash -c "$cmd"
        fi
    else
        echo "Warning: No user switching command available, running as root"
        eval "$cmd"
    fi
}

mkdir -p "${LIFECYCLE_DIR}"
cp "${FEATURE_DIR}/postCreateCommand.sh" "${LIFECYCLE_DIR}/postCreateCommand.sh"
chmod 0755 "${LIFECYCLE_DIR}/postCreateCommand.sh"

mkdir -p "/home/${USERNAME}/.codex"
chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}/.codex"
