#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $(basename "$0") <flyte_execution_url> [extra args for CLI]" >&2
  echo "Example: $(basename "$0") \"https://flyte.data.wayve.ai/console/projects/p/domains/d/executions/e\" --json" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
exec "$SKILLS_ROOT/obs-flyte-execution/scripts/inspect_flyte_execution.sh" "$@"
