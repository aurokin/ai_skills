# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repository manages custom skills that are symlinked for global availability via `~/.agents/skills`, plus a small set of OpenClaw-only skills.

## Commands

```bash
# Link all global skills to ~/.agents/skills
./link-skills.sh

# Link OpenClaw-only skills
./link-openclaw-skills.sh

# Remove a global skill symlink
rm ~/.agents/skills/<skill-name>
```

## Architecture

Global skills are stored in `skills/<skill-name>/SKILL.md`. The `link-skills.sh` script creates symlinks from `~/.agents/skills/<skill-name>` to each skill directory, making them available across all projects.

OpenClaw-only skills live in `openclaw_skills/<skill-name>/SKILL.md` and are linked separately via `./link-openclaw-skills.sh`.

## Adding a New Skill

1. Create `skills/<skill-name>/SKILL.md` with the skill prompt
2. Run `./link-skills.sh`
3. Update the "Available Skills" table in README.md

For OpenClaw-only skills:

1. Create `openclaw_skills/<skill-name>/SKILL.md`
2. Run `./link-openclaw-skills.sh`
3. Update the "OpenClaw Skills" table in README.md
