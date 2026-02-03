---
name: tmux
description: Remote-control tmux sessions for interactive CLIs by sending keystrokes and scraping pane output.
metadata:
  { "tmux": { "emoji": "🧵", "os": ["darwin", "linux"], "requires": { "bins": ["tmux"] } } }
---

# tmux Skill

Use tmux only when you need an interactive TTY. Prefer exec background mode for long-running, non-interactive tasks.

## Quickstart (exec tool)

```bash
SESSION=tmux-python

tmux new -d -s "$SESSION" -n shell
tmux send-keys -t "$SESSION":0.0 -- 'PYTHON_BASIC_REPL=1 python3 -q'
tmux send-keys -t "$SESSION":0.0 Enter
tmux capture-pane -p -J -t "$SESSION":0.0 -S -200
```

After starting a session, always print monitor commands:

```
To monitor:
  tmux attach -t "$SESSION"
  tmux capture-pane -p -J -t "$SESSION":0.0 -S -200
```

## Targeting panes and naming

- Target format: `session:window.pane` (defaults to `:0.0`).
- Keep names short; avoid spaces.
- Inspect: `tmux list-sessions`, `tmux list-panes -a`.

## Finding sessions

- List sessions: `{baseDir}/scripts/find-sessions.sh`.
- Filter sessions: `{baseDir}/scripts/find-sessions.sh -q 'name'`.

## Sending input safely

- Prefer literal sends: `tmux send-keys -t target -l -- "$cmd"`.
- Send Enter as its own command: `tmux send-keys -t target Enter`.
- Control keys: `tmux send-keys -t target C-c`.

## Watching output

- Capture recent history: `tmux capture-pane -p -J -t target -S -200`.
- Wait for prompts: `{baseDir}/scripts/wait-for-text.sh -t session:0.0 -p 'pattern'`.
- Attaching is OK; detach with `Ctrl+b d`.

## Spawning processes

- For python REPLs, set `PYTHON_BASIC_REPL=1` (non-basic REPL breaks send-keys flows).

## Windows / WSL

- tmux is supported on macOS/Linux. On Windows, use WSL and install tmux inside WSL.
- This skill is gated to `darwin`/`linux` and requires `tmux` on PATH.

## Orchestrating Coding Agents (Codex, Claude Code)

tmux excels at running multiple coding agents in parallel:

```bash
# Create multiple sessions
for i in 1 2 3 4 5; do
  tmux new-session -d -s "agent-$i"
done

# Launch agents in different workdirs
tmux send-keys -t agent-1 "cd /tmp/project1 && codex --yolo 'Fix bug X'"
tmux send-keys -t agent-1 Enter
tmux send-keys -t agent-2 "cd /tmp/project2 && codex --yolo 'Fix bug Y'"
tmux send-keys -t agent-2 Enter

# Poll for completion (check if prompt returned)
for sess in agent-1 agent-2; do
  if tmux capture-pane -p -t "$sess" -S -3 | grep -q "❯"; then
    echo "$sess: DONE"
  else
    echo "$sess: Running..."
  fi
done

# Get full output from completed session
tmux capture-pane -p -t agent-1 -S -500
```

**Tips:**

- Use separate git worktrees for parallel fixes (no branch conflicts)
- `pnpm install` first before running codex in fresh clones
- Check for shell prompt (`❯` or `$`) to detect completion
- Codex needs `--yolo` or `--full-auto` for non-interactive fixes

## Cleanup

- Kill a session: `tmux kill-session -t "$SESSION"`.
- Kill all sessions: `tmux list-sessions -F '#{session_name}' | xargs -r -n1 tmux kill-session -t`.
- Remove everything: `tmux kill-server`.

## Helper: wait-for-text.sh

`{baseDir}/scripts/wait-for-text.sh` polls a pane for a regex (or fixed string) with a timeout.

```bash
{baseDir}/scripts/wait-for-text.sh -t session:0.0 -p 'pattern' [-F] [-T 20] [-i 0.5] [-l 2000]
```

- `-t`/`--target` pane target (required)
- `-p`/`--pattern` regex to match (required); add `-F` for fixed string
- `-T` timeout seconds (integer, default 15)
- `-i` poll interval seconds (default 0.5)
- `-l` history lines to search (integer, default 1000)
