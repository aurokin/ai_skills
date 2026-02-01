#!/bin/bash

# Link all skills from this repository to ~/.config/opencode/skills

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
OPENCODE_SKILLS_DIR="$HOME/.config/opencode/skills"

# Create OpenCode skills directory if it doesn't exist
mkdir -p "$OPENCODE_SKILLS_DIR"

# Link each skill
for skill in "$SKILLS_DIR"/*/; do
    skill_name=$(basename "$skill")
    target="$OPENCODE_SKILLS_DIR/$skill_name"

    if [ -L "$target" ]; then
        echo "Updating link: $skill_name"
        rm "$target"
    elif [ -e "$target" ]; then
        echo "Skipping $skill_name: already exists and is not a symlink"
        continue
    else
        echo "Linking: $skill_name"
    fi

    ln -s "$skill" "$target"
done

echo "Done!"
