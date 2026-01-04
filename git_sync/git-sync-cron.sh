#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SCRIPT="$SCRIPT_DIR/git-sync.sh"

REPO="${1:-}"
if [[ -z "$REPO" ]]; then
  echo "[git-sync-cron] usage: $0 /path/to/repo" >&2
  exit 1
fi

if [[ ! -x "$SYNC_SCRIPT" ]]; then
  echo "[git-sync-cron] sync script not executable: $SYNC_SCRIPT" >&2
  exit 1
fi

exec "$SYNC_SCRIPT" "$REPO"
