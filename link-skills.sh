#!/bin/bash

# Link all skills from this repository to ~/.claude/skills

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"

# Create Claude skills directory if it doesn't exist
mkdir -p "$CLAUDE_SKILLS_DIR"

# Link each skill
for skill in "$SKILLS_DIR"/*/; do
    skill_name=$(basename "$skill")
    target="$CLAUDE_SKILLS_DIR/$skill_name"

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
