---
name: dilbert_notes_librarian
description: Orchestrate OpenCode to manage notes in ~/notes, following ~/notes/AGENTS.md. OpenCode-only, fixed workdir.
metadata:
  {
    "openclaw": { "emoji": "🗒️", "requires": { "anyBins": ["opencode"] } },
  }
---

# Dilbert Notes Librarian (OpenCode-only)

Notes handling source of truth: `~/notes/`.

Instructions live in: `~/notes/AGENTS.md`.

This skill is an orchestrator:

- For notes work, spawn an OpenCode coding agent with `opencode run` using `workdir:~/notes`.
- Let OpenCode read and follow `~/notes/AGENTS.md`.
- Do **not** load `~/notes/AGENTS.md` (or any notes skill) directly in this session.

---

## Bash Tool Parameters

| Parameter    | Type    | Description                                               |
| ------------ | ------- | --------------------------------------------------------- |
| `command`    | string  | The shell command to run                                  |
| `pty`        | boolean | PTY for interactive CLIs (recommended for OpenCode)       |
| `workdir`    | string  | Working directory (MUST be `~/notes` for this skill)      |
| `background` | boolean | Run in background, returns sessionId for monitoring       |
| `timeout`    | number  | Timeout in seconds (kills process on expiry)              |
| `elevated`   | boolean | Run on host instead of sandbox (if allowed by your setup) |

---

## Non-Negotiable Rules

1. **OpenCode only**: do not use Codex/Claude/Pi for notes tasks.
2. **Fixed workdir**: always run with `workdir:~/notes`.
3. **AGENTS.md authority**: `~/notes/AGENTS.md` is the instruction source of truth.
4. **No direct loading here**: do not open/read `~/notes/AGENTS.md` in this session; delegate to OpenCode.

If these constraints make the task impossible, stop and ask the user to adjust constraints.

---

## How To Run OpenCode

Always use:

- `opencode run`
- `workdir:~/notes`
- (recommended) `pty:true`

### Prompt Preamble (Required)

Every OpenCode prompt must start with a short preamble that instructs it to read and follow `AGENTS.md` in `~/notes`:

```bash
bash pty:true workdir:~/notes command:"opencode run 'First: read and follow AGENTS.md in this directory. Do not paste it verbatim; just comply with it.\n\nNow do:\n<task here>'"
```

If you run OpenCode in the background, you must monitor it and surface only milestone updates to the user.

---

## What To Ask OpenCode To Do

Common tasks:

- capture: turn user input into notes per `~/notes/AGENTS.md`
- retrieve: search and answer questions using existing notes
- refactor: reorganize notes, dedupe, add cross-links
- summarize: create brief digests for a timeframe/topic
- hygiene: redaction checks, remove sensitive data per `AGENTS.md`

If a request is ambiguous, ask OpenCode to propose 2-3 options consistent with `AGENTS.md`, then present those options to the user.

---

## Output Contract (This Session)

When reporting results back to the user:

- cite what changed (files created/edited, note titles/IDs if applicable)
- keep responses concise; do not paste large note bodies unless the user requests
- never paste secrets; redact if they exist

Do not claim you read `~/notes/AGENTS.md` here; only OpenCode did.
