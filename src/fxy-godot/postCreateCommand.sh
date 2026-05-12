#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="/workspaces"

# Install all Godot versions required by projects in this repo.
# Versions are read from .godotrc files (GodotEnv convention).
find "${WORKSPACE_DIR}" -name ".godotrc" -type f \
    | xargs cat \
    | tr -d '\r' \
    | sort -u \
    | while read -r version; do
        [[ -n "$version" ]] && godotenv godot install "$version"
    done

# Apply editor settings for each major Godot version found in this repo.
upsert_setting() {
    local file="$1" key="$2" value="$3"
    if grep -q "^${key} = " "$file" 2>/dev/null; then
        sed -i "s|^${key} = .*|${key} = ${value}|" "$file"
    else
        echo "${key} = ${value}" >> "$file"
    fi
}

declare -A processed_majors
while IFS= read -r version; do
    [[ -z "$version" ]] && continue
    major_minor="${version%.*}"
    [[ -n "${processed_majors[$major_minor]+_}" ]] && continue
    processed_majors[$major_minor]=1

    settings_file="$HOME/.config/godot/editor_settings-${major_minor}.tres"
    mkdir -p "$(dirname "$settings_file")"

    if [[ ! -f "$settings_file" ]]; then
        printf '[gd_resource type="EditorSettings" format=3]\n\n[resource]\n' > "$settings_file"
    fi

    upsert_setting "$settings_file" "text_editor/behavior/files/trim_final_newlines_on_save" "false"
    upsert_setting "$settings_file" "text_editor/behavior/files/convert_indent_on_save" "false"
    echo "Applied Godot ${major_minor} editor settings to $settings_file"
done < <(find "${WORKSPACE_DIR}" -name ".godotrc" -type f | xargs cat | tr -d '\r' | sort -u)
