#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-}"
if [[ -z "$REPO" ]]; then
  echo "[git-sync] usage: $0 /path/to/repo" >&2
  exit 1
fi

if [[ ! -d "$REPO/.git" ]]; then
  echo "[git-sync] expected a git repo at: $REPO" >&2
  exit 1
fi

cd "$REPO"

# Prevent overlapping runs (e.g., rapid filesystem events)
exec 9>.git/.git-sync.lock
flock -n 9 || exit 0

# Fetch and merge with local wins on conflict
if ! git fetch --prune; then
  echo "[git-sync] git fetch failed; resolve manually" >&2
  exit 1
fi

UPSTREAM_REF="$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || true)"

# Commit local changes first
if [[ -n "$(git status --porcelain)" ]]; then
  git add -A
  git commit -m "git sync $(date -u +'%Y-%m-%dT%H:%M:%SZ')" || true
fi

if [[ -n "$UPSTREAM_REF" ]]; then
  if ! git merge --no-edit -X ours "$UPSTREAM_REF"; then
    echo "[git-sync] git merge failed; resolve manually" >&2
    git merge --abort || true
    exit 1
  fi
else
  echo "[git-sync] no upstream configured; skipping merge/push" >&2
  exit 0
fi

git push
