---
name: bilbo_coding_agent_manager
description: Manage Codex CLI, Claude Code, OpenCode, or Pi via PTY/background processes, tracked in a markdown session registry.
metadata:
  {
    "openclaw": { "emoji": "🧩", "requires": { "anyBins": ["claude", "codex", "opencode", "pi"] } },
  }
---

# Bilbo Coding Agent Manager (bash-first)

Use **bash** (with optional background mode) for all coding agent work, and keep a durable markdown list of the sessions you're managing.

## ⚠️ PTY Mode Required!

Coding agents (Codex, Claude Code, Pi) are **interactive terminal applications** that need a pseudo-terminal (PTY) to work correctly. Without PTY, you'll get broken output, missing colors, or the agent may hang.

**Always use `pty:true`** when running coding agents:

```bash
# ✅ Correct - with PTY
bash pty:true command:"codex exec 'Your prompt'"

# ❌ Wrong - no PTY, agent may break
bash command:"codex exec 'Your prompt'"
```

### Bash Tool Parameters

| Parameter    | Type    | Description                                                                 |
| ------------ | ------- | --------------------------------------------------------------------------- |
| `command`    | string  | The shell command to run                                                    |
| `pty`        | boolean | **Use for coding agents!** Allocates a pseudo-terminal for interactive CLIs |
| `workdir`    | string  | Working directory (agent sees only this folder's context)                   |
| `background` | boolean | Run in background, returns sessionId for monitoring                         |
| `timeout`    | number  | Timeout in seconds (kills process on expiry)                                |
| `elevated`   | boolean | Run on host instead of sandbox (if allowed)                                 |

### Process Tool Actions (for background sessions)

| Action      | Description                                          |
| ----------- | ---------------------------------------------------- |
| `list`      | List all running/recent sessions                     |
| `poll`      | Check if session is still running                    |
| `log`       | Get session output (with optional offset/limit)      |
| `write`     | Send raw data to stdin                               |
| `submit`    | Send data + newline (like typing and pressing Enter) |
| `send-keys` | Send key tokens or hex bytes                         |
| `paste`     | Paste text (with optional bracketed mode)            |
| `kill`      | Terminate the session                                |

---

## Managed Sessions (Markdown DB)

Keep a single markdown file as the source of truth for all sessions this manager is responsible for. Treat it as a lightweight database for:

- listing sessions (what exists, where it's running, what tool it uses)
- tracking progress over time (status + timestamps)
- continuing work (store the last output and feed it into the next prompt)
- cleanup (remove all evidence when the user explicitly ends a session)

Note: `process action:list` only shows running/recent background process sessions. The markdown Session DB is the durable, canonical list of managed sessions.

When the user asks to list sessions, read the Session DB and present the table (plus any `status: blocked` notes).

### Session DB Location

Default location (safe from accidental git commits):

- `~/.local/state/bilbo_coding_agent_manager/sessions.md`

If you need per-repo tracking, use a repo-local path like `./BILBO_SESSIONS.md`.

Bootstrap the DB (create if missing):

```bash
DB="$HOME/.local/state/bilbo_coding_agent_manager/sessions.md"
mkdir -p "$(dirname "$DB")"

if [ ! -f "$DB" ]; then
  cat >"$DB" <<'EOF'
# Bilbo Coding Agent Sessions

<!-- bilbo_coding_agent_manager:session-db:v1 -->

| id | tool | status | workdir | session_url | process_session_id | last_update | note |
|----|------|--------|---------|-------------|--------------------|------------|------|
EOF
fi
```

### Session DB Format (v1)

Maintain this structure:

````markdown
# Bilbo Coding Agent Sessions

<!-- bilbo_coding_agent_manager:session-db:v1 -->

| id | tool | status | workdir | session_url | process_session_id | last_update | note |
|----|------|--------|---------|-------------|--------------------|------------|------|
| bam-0001 | codex | idle | ~/project | https://... | 123 | 2026-02-07 13:20 | Build snake |

## bam-0001

- tool: codex
- status: idle
- workdir: /home/you/project
- session_url: https://...
- process_session_id: 123
- last_prompt: Build a snake game
- last_output_tail:

```text
<tail/excerpt of last agent output>
```

- next_prompt_seed:

```text
Context (last output):
<paste last_output_tail here>

Now do:
<your next instruction>
```
````

### Session Lifecycle Rules (Critical)

1. When a prompt completes, **the session is still ongoing**. Mark it `idle` and keep it in the DB.
2. For Codex/OpenCode, always capture and store the **session URL** they emit at the end of a run.
3. Always store enough of the last output (tail/excerpt + 1-3 line note) so the next prompt can continue deterministically.
4. Sessions live until the user explicitly asks for them to be ended. When ending:
   - kill any related background process session (if one exists)
   - delete the session's row + detail section from the markdown DB (no archive)
5. Treat the Session DB as local state, not a transcript: avoid storing secrets verbatim; redact tokens/keys and prefer short excerpts + a note.

## Quick Start: One-Shot Runs

For quick prompts/chats, create a temp git repo and run:

```bash
# Quick chat (Codex needs a git repo!)
SCRATCH=$(mktemp -d) && cd $SCRATCH && git init && codex exec "Your prompt here"

# Or in a real project - with PTY!
bash pty:true workdir:~/Projects/myproject command:"codex exec 'Add error handling to the API calls'"
```

After it finishes, capture the session URL (Codex/OpenCode often print one at the end) and write a new row + detail section into your Session DB, including `last_output_tail`. Mark it `idle` (not ended).

**Why git init?** Codex refuses to run outside a trusted git directory. Creating a temp repo solves this for scratch work.

---

## The Pattern: workdir + background + pty

For longer tasks, use background mode with PTY:

```bash
# Start agent in target directory (with PTY!)
bash pty:true workdir:~/project background:true command:"codex exec --full-auto 'Build a snake game'"
# Returns sessionId for tracking (store as process_session_id in the Session DB)

# Monitor progress
process action:log sessionId:XXX

# Check if done
process action:poll sessionId:XXX

# Send input (if agent asks a question)
process action:write sessionId:XXX data:"y"

# Submit with Enter (like typing "yes" and pressing Enter)
process action:submit sessionId:XXX data:"yes"

# Kill if needed
process action:kill sessionId:XXX
```

DB updates to do during/after a background run:

- start: create the session row; set `status: running`; store `process_session_id`
- finish: set `status: idle`; store the tool-emitted `session_url` (if present) and `last_output_tail`
- questions/errors: set `status: blocked` or `status: error` and note what input is needed

**Why workdir matters:** Agent wakes up in a focused directory, doesn't wander off reading unrelated files (like your soul.md 😅).

---

## Continuing a Managed Session (use last output)

When you run a follow-up prompt for an existing session `id`:

1. Read the session entry from the Session DB.
2. Build the next prompt by pasting `last_output_tail` (or `next_prompt_seed`) first, then your new instruction.
3. Run the agent in the same `workdir` and (usually) the same tool.
4. If the CLI supports resuming by session URL/ID, pass the stored `session_url` (discover flags via `--help` by searching for "resume", "continue", or "session").
5. Update the session entry: `last_prompt`, `last_output_tail`, `last_update`, and keep it `idle` unless it's blocked on user input.

Do NOT remove the session from the DB unless the user explicitly asks to end it.

---

## Codex CLI

**Model:** `gpt-5.2-codex` is the default (set in ~/.codex/config.toml)

### Flags

| Flag            | Effect                                             |
| --------------- | -------------------------------------------------- |
| `exec "prompt"` | One-shot execution, exits when done                |
| `--full-auto`   | Sandboxed but auto-approves in workspace           |
| `--yolo`        | NO sandbox, NO approvals (fastest, most dangerous) |

### Building/Creating

```bash
# Quick one-shot (auto-approves) - remember PTY!
bash pty:true workdir:~/project command:"codex exec --full-auto 'Build a dark mode toggle'"

# Background for longer work
bash pty:true workdir:~/project background:true command:"codex --yolo 'Refactor the auth module'"
```

### Reviewing PRs

**⚠️ CRITICAL: Never review PRs in OpenClaw's own project folder!**
Clone to temp folder or use git worktree.

```bash
# Clone to temp for safe review
REVIEW_DIR=$(mktemp -d)
git clone https://github.com/user/repo.git $REVIEW_DIR
cd $REVIEW_DIR && gh pr checkout 130
bash pty:true workdir:$REVIEW_DIR command:"codex review --base origin/main"
# Clean up after: trash $REVIEW_DIR

# Or use git worktree (keeps main intact)
git worktree add /tmp/pr-130-review pr-130-branch
bash pty:true workdir:/tmp/pr-130-review command:"codex review --base main"
```

### Batch PR Reviews (parallel army!)

```bash
# Fetch all PR refs first
git fetch origin '+refs/pull/*/head:refs/remotes/origin/pr/*'

# Deploy the army - one Codex per PR (all with PTY!)
bash pty:true workdir:~/project background:true command:"codex exec 'Review PR #86. git diff origin/main...origin/pr/86'"
bash pty:true workdir:~/project background:true command:"codex exec 'Review PR #87. git diff origin/main...origin/pr/87'"

# Monitor all
process action:list

# Post results to GitHub
gh pr comment <PR#> --body "<review content>"
```

---

## Claude Code

```bash
# With PTY for proper terminal output
bash pty:true workdir:~/project command:"claude 'Your task'"

# Background
bash pty:true workdir:~/project background:true command:"claude 'Your task'"
```

---

## OpenCode

```bash
bash pty:true workdir:~/project command:"opencode run 'Your task'"
```

---

## Pi Coding Agent

```bash
# Install: npm install -g @mariozechner/pi-coding-agent
bash pty:true workdir:~/project command:"pi 'Your task'"

# Non-interactive mode (PTY still recommended)
bash pty:true command:"pi -p 'Summarize src/'"

# Different provider/model
bash pty:true command:"pi --provider openai --model gpt-4o-mini -p 'Your task'"
```

**Note:** Pi now has Anthropic prompt caching enabled (PR #584, merged Jan 2026)!

---

## Parallel Issue Fixing with git worktrees

For fixing multiple issues in parallel, use git worktrees:

```bash
# 1. Create worktrees for each issue
git worktree add -b fix/issue-78 /tmp/issue-78 main
git worktree add -b fix/issue-99 /tmp/issue-99 main

# 2. Launch Codex in each (background + PTY!)
bash pty:true workdir:/tmp/issue-78 background:true command:"pnpm install && codex --yolo 'Fix issue #78: <description>. Commit and push.'"
bash pty:true workdir:/tmp/issue-99 background:true command:"pnpm install && codex --yolo 'Fix issue #99: <description>. Commit and push.'"

# 3. Monitor progress
process action:list
process action:log sessionId:XXX

# 4. Create PRs after fixes
cd /tmp/issue-78 && git push -u origin fix/issue-78
gh pr create --repo user/repo --head fix/issue-78 --title "fix: ..." --body "..."

# 5. Cleanup
git worktree remove /tmp/issue-78
git worktree remove /tmp/issue-99
```

---

## ⚠️ Rules

1. **Always use pty:true** - coding agents need a terminal!
2. **Maintain the Session DB** - every managed session gets a row + detail section; prompts finishing do not end sessions; remove evidence only when the user explicitly ends a session.
3. **Respect tool choice** - if user asks for Codex, use Codex.
   - Orchestrator mode: do NOT hand-code patches yourself.
   - If an agent fails/hangs, respawn it or ask the user for direction, but don't silently take over.
4. **Be patient** - don't kill sessions because they're "slow"
5. **Monitor with process:log** - check progress without interfering
6. **--full-auto for building** - auto-approves changes
7. **vanilla for reviewing** - no special flags needed
8. **Parallel is OK** - run many Codex processes at once for batch work
9. **NEVER start Codex in ~/clawd/** - it'll read your soul docs and get weird ideas about the org chart!
10. **NEVER checkout branches in ~/Projects/openclaw/** - that's the LIVE OpenClaw instance!

---

## Progress Updates (Critical)

When you spawn coding agents in the background, keep the user in the loop and keep the Session DB up to date.

- Send 1 short message when you start (what's running + where).
- Then only update again when something changes:
  - a milestone completes (build finished, tests passed)
  - the agent asks a question / needs input
  - you hit an error or need user action
  - the agent finishes (include what changed + where)
- Also update the Session DB on those same events (status, timestamps, last_output_tail, session_url).
- If you kill a background process session, immediately say you killed it and why, and update the Session DB entry (do not delete it unless the user asked to end it).

This prevents the user from seeing only "Agent failed before reply" and having no idea what happened.

---

## Auto-Notify on Completion

For long-running background tasks, append a wake trigger to your prompt so OpenClaw gets notified immediately when the agent finishes (instead of waiting for the next heartbeat):

```
... your task here.

When completely finished, run this command to notify me:
openclaw gateway wake --text "Done: [brief summary of what was built]" --mode now
```

**Example:**

```bash
bash pty:true workdir:~/project background:true command:"codex --yolo exec 'Build a REST API for todos.

When completely finished, run: openclaw gateway wake --text \"Done: Built todos REST API with CRUD endpoints\" --mode now'"
```

This triggers an immediate wake event — Skippy gets pinged in seconds, not 10 minutes.

---

## Learnings (Jan 2026)

- **PTY is essential:** Coding agents are interactive terminal apps. Without `pty:true`, output breaks or agent hangs.
- **Git repo required:** Codex won't run outside a git directory. Use `mktemp -d && git init` for scratch work.
- **exec is your friend:** `codex exec "prompt"` runs and exits cleanly - perfect for one-shots.
- **submit vs write:** Use `submit` to send input + Enter, `write` for raw data without newline.
- **Sass works:** Codex responds well to playful prompts. Asked it to write a haiku about being second fiddle to a space lobster, got: _"Second chair, I code / Space lobster sets the tempo / Keys glow, I follow"_ 🦞
