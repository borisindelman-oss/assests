#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_DIR="${1:-$SCRIPT_DIR}"
CRON_SCRIPT="$VAULT_DIR/.vault-sync-cron.sh"

if [[ ! -d "$VAULT_DIR/.git" ]]; then
  echo "[vault-sync-cron-setup] expected a git repo at: $VAULT_DIR" >&2
  echo "Usage: $0 /path/to/vault" >&2
  exit 1
fi

if [[ ! -f "$CRON_SCRIPT" ]]; then
  echo "[vault-sync-cron-setup] missing $CRON_SCRIPT" >&2
  exit 1
fi

chmod +x "$VAULT_DIR/.vault-sync.sh" "$CRON_SCRIPT"

CRON_LINE="* * * * * $CRON_SCRIPT >/dev/null 2>&1"
EXISTING_CRON="$(crontab -l 2>/dev/null || true)"

if echo "$EXISTING_CRON" | grep -F "$CRON_SCRIPT" >/dev/null 2>&1; then
  echo "[vault-sync-cron-setup] cron entry already present"
  exit 0
fi

{ echo "$EXISTING_CRON"; echo "$CRON_LINE"; } | crontab -
echo "[vault-sync-cron-setup] installed: $CRON_LINE"
