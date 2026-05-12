#!/usr/bin/env bash

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIFECYCLE_DIR="/usr/local/share/devcontainer-features/fxy-godot"

set -euo pipefail

apt-get update
apt-get install -y --no-install-recommends \
    libx11-6 libx11-xcb1 libxrender1 libxfixes3 libxi6 libxkbcommon0 libsm6 libice6 libxext6 \
    libxcb1 libxcb-dri3-0 libxcb-present0 libxcb-randr0 libxcb-shm0 libxcb-sync1 libxcb-xfixes0 \
    libgl1 libfontconfig1 libxcursor1 libxinerama1 libxrandr2 \
    libvulkan1 mesa-vulkan-drivers vulkan-tools \
    libdbus-1-3 libasound2t64 libpulse0 \
    xvfb

dotnet tool install --tool-path /usr/local/bin Chickensoft.GodotEnv

mkdir -p "${LIFECYCLE_DIR}"
cp "${FEATURE_DIR}/postCreateCommand.sh" "${LIFECYCLE_DIR}/postCreateCommand.sh"
chmod 0755 "${LIFECYCLE_DIR}/postCreateCommand.sh"

mkdir -p "/home/${USERNAME}/.config/godotenv"
chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}/.config/godotenv"
