#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: find-sessions.sh [-q pattern]

List tmux sessions on the default server.

Options:
  -q, --query        case-insensitive substring to filter session names
  -h, --help         show this help
USAGE
}

query=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -q|--query) query="${2-}"; shift 2 ;;
    -h|--help)  usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux not found in PATH" >&2
  exit 1
fi

list_sessions() {
  local sessions

  if ! sessions="$(tmux list-sessions -F '#{session_name}\t#{session_attached}\t#{session_created_string}' 2>/dev/null)"; then
    echo "No tmux server found" >&2
    return 1
  fi

  if [[ -n "$query" ]]; then
    sessions="$(printf '%s\n' "$sessions" | grep -i -- "$query" || true)"
  fi

  if [[ -z "$sessions" ]]; then
    echo "No sessions found"
    return 0
  fi

  echo "Sessions:"
  printf '%s\n' "$sessions" | while IFS=$'\t' read -r name attached created; do
    attached_label=$([[ "$attached" == "1" ]] && echo "attached" || echo "detached")
    printf '  - %s (%s, started %s)\n' "$name" "$attached_label" "$created"
  done
}

list_sessions
