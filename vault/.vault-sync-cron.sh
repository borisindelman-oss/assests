#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SCRIPT="$SCRIPT_DIR/.vault-sync.sh"

if [[ ! -x "$SYNC_SCRIPT" ]]; then
  echo "[vault-sync-cron] sync script not executable: $SYNC_SCRIPT" >&2
  exit 1
fi

exec "$SYNC_SCRIPT"
