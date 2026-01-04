#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${1:-}"
CRON_SCRIPT="$SCRIPT_DIR/git-sync-cron.sh"
SYNC_SCRIPT="$SCRIPT_DIR/git-sync.sh"

if [[ -z "$REPO_DIR" ]]; then
  echo "[git-sync-cron-setup] usage: $0 /path/to/repo" >&2
  exit 1
fi

if [[ ! -d "$REPO_DIR/.git" ]]; then
  echo "[git-sync-cron-setup] expected a git repo at: $REPO_DIR" >&2
  exit 1
fi

if [[ ! -f "$CRON_SCRIPT" || ! -f "$SYNC_SCRIPT" ]]; then
  echo "[git-sync-cron-setup] missing sync scripts in: $SCRIPT_DIR" >&2
  exit 1
fi

chmod +x "$SYNC_SCRIPT" "$CRON_SCRIPT"

REPO_DIR="$(cd "$REPO_DIR" && pwd)"
CRON_LINE="* * * * * $CRON_SCRIPT $REPO_DIR >/dev/null 2>&1"
EXISTING_CRON="$(crontab -l 2>/dev/null || true)"

if echo "$EXISTING_CRON" | grep -F "$CRON_SCRIPT $REPO_DIR" >/dev/null 2>&1; then
  echo "[git-sync-cron-setup] cron entry already present"
  exit 0
fi

{ echo "$EXISTING_CRON"; echo "$CRON_LINE"; } | crontab -
echo "[git-sync-cron-setup] installed: $CRON_LINE"
