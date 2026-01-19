# Custom Skills

A collection of forked and custom Claude Code skills that are symlinked to `~/.claude/skills` for use across all projects.

## Setup

Run the link script to symlink all skills to your Claude configuration:

```bash
./link-skills.sh
```

This creates symlinks from `~/.claude/skills/<skill-name>` pointing to the skills in this repository, making them available globally in Claude Code.

## Available Skills

| Skill | Description |
|-------|-------------|
| `update-agents-md` | Reminds to update AGENTS.md files with reusable learnings before committing |

## Adding New Skills

1. Create a new directory under `skills/` with your skill name
2. Add a `SKILL.md` file containing the skill prompt
3. Run `./link-skills.sh` to create the symlink

### Skill Structure

```
skills/
  my-skill/
    SKILL.md    # Required: The skill prompt
```

## Unlinking Skills

To remove a skill symlink:

```bash
rm ~/.claude/skills/<skill-name>
```
