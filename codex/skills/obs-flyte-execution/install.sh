#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_ROOT="${1:-/workspace/WayveCode/.ai/skills}"
DEST_DIR="${DEST_ROOT}/obs-flyte-execution"

mkdir -p "$DEST_DIR"

cp -f "$SCRIPT_DIR/BUILD" "$DEST_DIR/BUILD"
cp -f "$SCRIPT_DIR/inspect_execution_logs_cli.py" "$DEST_DIR/inspect_execution_logs_cli.py"

echo "Installed runtime files to: $DEST_DIR"
echo "Copied:"
echo "  - BUILD"
echo "  - inspect_execution_logs_cli.py"
