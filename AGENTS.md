# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repository manages custom skills that are symlinked for global availability in OpenCode, Codex, and Claude.

## Commands

```bash
# Link all skills to supported skill dirs
./link-skills.sh

# Remove a skill symlink
rm ~/.config/opencode/skills/<skill-name>
rm ~/.codex/skills/<skill-name>
rm ~/.claude/skills/<skill-name>
```

## Architecture

Skills are stored in `skills/<skill-name>/SKILL.md`. The `link-skills.sh` script creates symlinks from `~/.config/opencode/skills/<skill-name>`, `~/.codex/skills/<skill-name>`, and `~/.claude/skills/<skill-name>` to each skill directory, making them available across all projects.

## Adding a New Skill

1. Create `skills/<skill-name>/SKILL.md` with the skill prompt
2. Run `./link-skills.sh`
3. Update the "Available Skills" table in README.md
