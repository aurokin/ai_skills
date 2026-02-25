#!/usr/bin/env bash

# Reproduce this machine's skill setup on another computer.
# - Installs upstream global skills via the `skills` CLI
# - Removes deprecated agent-md-refactor if present
# - Links local custom skills from this repo

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_BIN="${SKILLS_BIN:-skills}"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

install_skill() {
  local spec="$1"
  echo "Installing: $spec"
  "$SKILLS_BIN" add "$spec" -g -a '*' -y
}

main() {
  require_cmd "$SKILLS_BIN"

  # Replace old AGENTS.md refactor skill with Sentry's agents-md.
  "$SKILLS_BIN" remove agent-md-refactor -g -y >/dev/null 2>&1 || true

  local specs=(
    "anthropics/skills@doc-coauthoring"
    "anthropics/skills@frontend-design"
    "anthropics/skills@webapp-testing"
    "expo/skills@building-native-ui"
    "expo/skills@expo-api-routes"
    "expo/skills@expo-cicd-workflows"
    "expo/skills@expo-deployment"
    "expo/skills@expo-dev-client"
    "expo/skills@expo-tailwind-setup"
    "expo/skills@native-data-fetching"
    "expo/skills@upgrading-expo"
    "expo/skills@use-dom"
    "getsentry/skills@agents-md"
    "openai/skills@openai-docs"
    "openai/skills@pdf"
    "openai/skills@playwright"
    "openai/skills@screenshot"
    "openai/skills@security-best-practices"
    "openai/skills@skill-creator"
    "openai/skills@spreadsheet"
    "steipete/clawdis@github"
    "vercel-labs/agent-skills@vercel-composition-patterns"
    "vercel-labs/agent-skills@vercel-react-best-practices"
    "vercel-labs/agent-skills@vercel-react-native-skills"
    "vercel-labs/agent-skills@web-design-guidelines"
    "vercel-labs/skills@find-skills"
  )

  for spec in "${specs[@]}"; do
    install_skill "$spec"
  done

  echo "Linking local repo skills..."
  "$SCRIPT_DIR/link-skills.sh"
  "$SCRIPT_DIR/link-openclaw-skills.sh"

  echo "Done."
}

main "$@"
