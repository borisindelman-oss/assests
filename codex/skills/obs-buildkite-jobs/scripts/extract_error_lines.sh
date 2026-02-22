#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $(basename "$0") <log_path> [max_lines=120]" >&2
  exit 1
fi

log_path="$1"
max_lines="${2:-120}"
pattern="FAILED|failed|ERROR|Exception|Traceback|Timeout|ForwardPassException|exit code"

if [ ! -f "$log_path" ]; then
  echo "ERROR: log file not found: $log_path" >&2
  exit 1
fi

if command -v rg >/dev/null 2>&1; then
  rg -n "$pattern" "$log_path" | head -n "$max_lines" || true
else
  grep -En "$pattern" "$log_path" | head -n "$max_lines" || true
fi
