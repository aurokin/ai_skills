# Custom Skills

A collection of forked and custom skills that are symlinked for use across all projects via the shared `~/.agents/skills` directory.

## Setup

Run the link script to symlink all global skills:

```bash
./link-skills.sh
```

OpenClaw-only skills are linked separately:

```bash
./link-openclaw-skills.sh
```

By default this links into `~/.openclaw/skills`. Override with:

```bash
OPENCLAW_SKILLS_DIR=~/.openclaw/skills ./link-openclaw-skills.sh
# or
./link-openclaw-skills.sh /custom/skills/dir
```

This creates symlinks in the shared global directory:

- `~/.agents/skills/<skill-name>`

## Available Skills

| Skill | Description |
|-------|-------------|
| `update-agents-md` | Reminds to update AGENTS.md files with reusable learnings before committing |

## OpenClaw Skills

| Skill | Description |
|-------|-------------|
| `bilbo_coding_agent_manager` | Runs/continues Codex/Claude/OpenCode/Pi via PTY/background and tracks ongoing sessions in a markdown registry |
| `dilbert_notes_librarian` | Uses OpenCode-only in `~/notes` and delegates to `~/notes/AGENTS.md` for notes rules (does not load that file directly here) |

## Adding New Skills

Global skills:

1. Create a new directory under `skills/` with your skill name
2. Add a `SKILL.md` file containing the skill prompt
3. Run `./link-skills.sh` to create the symlink

OpenClaw-only skills:

1. Create a new directory under `openclaw_skills/` with your skill name
2. Add a `SKILL.md` file containing the skill prompt
3. Run `./link-openclaw-skills.sh` to create the symlink

### Skill Structure

```
skills/
  my-skill/
    SKILL.md    # Required: The skill prompt

openclaw_skills/
  my-openclaw-skill/
    SKILL.md    # Required: The skill prompt
```

## Unlinking Skills

To remove a global skill symlink:

```bash
rm ~/.agents/skills/<skill-name>

# If linked via link-openclaw-skills.sh (default target dir)
rm ~/.openclaw/skills/<skill-name>
```
