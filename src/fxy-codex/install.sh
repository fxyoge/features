#!/usr/bin/env bash

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"

set -euo pipefail

mkdir -p "/home/${USERNAME}/.codex"
chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}/.codex"
