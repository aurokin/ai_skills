#!/bin/bash

# Link all skills from this repository to supported skill dirs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
SKILL_TARGET_DIRS=(
    "$HOME/.config/opencode/skills"
    "$HOME/.codex/skills"
    "$HOME/.claude/skills"
    "$HOME/.gemini/skills"
)

# Create skill directories if they don't exist
for target_dir in "${SKILL_TARGET_DIRS[@]}"; do
    mkdir -p "$target_dir"
done

# Link each skill
for skill in "$SKILLS_DIR"/*/; do
    skill_name=$(basename "$skill")

    for target_dir in "${SKILL_TARGET_DIRS[@]}"; do
        target="$target_dir/$skill_name"

        if [ -L "$target" ]; then
            echo "Updating link: $skill_name -> $target_dir"
            rm "$target"
        elif [ -e "$target" ]; then
            echo "Skipping $skill_name in $target_dir: already exists and is not a symlink"
            continue
        else
            echo "Linking: $skill_name -> $target_dir"
        fi

        ln -s "$skill" "$target"
    done
done

echo "Done!"
