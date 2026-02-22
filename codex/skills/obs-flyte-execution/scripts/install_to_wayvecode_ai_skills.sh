#!/usr/bin/env bash
set -euo pipefail

DEST_ROOT="${1:-/workspace/WayveCode/.ai/skills}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL_NAME="$(basename "$SKILL_DIR")"
DEST_DIR="${DEST_ROOT}/${SKILL_NAME}"

mkdir -p "$DEST_ROOT"
mkdir -p "$DEST_DIR"

cp -f "$SKILL_DIR/SKILL.md" "$DEST_DIR/SKILL.md"

if [ -d "$SKILL_DIR/agents" ]; then
  mkdir -p "$DEST_DIR/agents"
  cp -R "$SKILL_DIR/agents/." "$DEST_DIR/agents/"
fi

if [ -d "$SKILL_DIR/scripts" ]; then
  mkdir -p "$DEST_DIR/scripts"
  cp -R "$SKILL_DIR/scripts/." "$DEST_DIR/scripts/"
fi

if [ -d "$SKILL_DIR/references" ]; then
  mkdir -p "$DEST_DIR/references"
  cp -R "$SKILL_DIR/references/." "$DEST_DIR/references/"
fi

echo "Installed skill '${SKILL_NAME}' to: ${DEST_DIR}"
