# Custom Skills

A collection of custom Claude Code skills that can be linked to `~/.claude/skills`.

## Usage

Link all skills to your Claude configuration:

```bash
./link-skills.sh
```

This creates symlinks from `~/.claude/skills/<skill-name>` to the skills in this repository.

## Available Skills

- **update-agents-md** - Reminds to update AGENTS.md files with reusable learnings before committing

## Adding New Skills

1. Create a new directory under `skills/` with your skill name
2. Add a `SKILL.md` file with your skill prompt
3. Run `./link-skills.sh` to link it

## Skill Structure

```
skills/
  my-skill/
    SKILL.md    # Required: The skill prompt
```
