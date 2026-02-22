#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $(basename "$0") <flyte_execution_url> [extra args for CLI]" >&2
  echo "Example: $(basename "$0") \"https://flyte.data.wayve.ai/console/projects/p/domains/d/executions/e\" --json" >&2
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$REPO_ROOT" ]; then
  echo "ERROR: not inside a git workspace." >&2
  exit 1
fi

cd "$REPO_ROOT"
bazel run //.ai/skills/obs-flyte-execution:inspect_execution_logs_cli -- "$@"
