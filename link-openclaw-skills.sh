#!/bin/bash

# Link OpenClaw-only skills from this repository.
#
# Usage:
#   ./link-openclaw-skills.sh                # links to default target dir
#   ./link-openclaw-skills.sh /path/to/dir   # links to explicit target dir
#
# Override default target dir via env var:
#   OPENCLAW_SKILLS_DIR=~/.config/openclaw/skills ./link-openclaw-skills.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/openclaw_skills"

DEFAULT_TARGET_DIR="$HOME/.config/openclaw/skills"
TARGET_DIR="${1:-${OPENCLAW_SKILLS_DIR:-$DEFAULT_TARGET_DIR}}"

mkdir -p "$TARGET_DIR"

if [ ! -d "$SKILLS_DIR" ]; then
  echo "No openclaw_skills/ directory found: $SKILLS_DIR"
  exit 0
fi

for skill in "$SKILLS_DIR"/*/; do
  [ -d "$skill" ] || continue
  skill_name=$(basename "$skill")
  target="$TARGET_DIR/$skill_name"

  if [ -L "$target" ]; then
    echo "Updating link: $skill_name -> $TARGET_DIR"
    rm "$target"
  elif [ -e "$target" ]; then
    echo "Skipping $skill_name in $TARGET_DIR: already exists and is not a symlink"
    continue
  else
    echo "Linking: $skill_name -> $TARGET_DIR"
  fi

  ln -s "$skill" "$target"
done

echo "Done!"
