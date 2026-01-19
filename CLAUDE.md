# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repository manages custom Claude Code skills that are symlinked to `~/.claude/skills/` for global availability.

## Commands

```bash
# Link all skills to ~/.claude/skills
./link-skills.sh

# Remove a skill symlink
rm ~/.claude/skills/<skill-name>
```

## Architecture

Skills are stored in `skills/<skill-name>/SKILL.md`. The `link-skills.sh` script creates symlinks from `~/.claude/skills/<skill-name>` to each skill directory, making them available across all projects.

## Adding a New Skill

1. Create `skills/<skill-name>/SKILL.md` with the skill prompt
2. Run `./link-skills.sh`
3. Update the "Available Skills" table in README.md
