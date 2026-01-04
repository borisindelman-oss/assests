# Git Sync Tool (cron)

Sync any git repo every minute with local-first conflict resolution.

## What it does
- Runs a `git fetch`, commits local changes if any, merges remote with `-X ours`,
  then pushes.
- Uses a lock file inside the repo to avoid overlapping runs.

## Install (per repo)
```bash
/home/borisindelman/git/assests/vault/git-sync-cron-setup.sh /path/to/repo
```

This installs a cron entry:
```
* * * * * /home/borisindelman/git/assests/vault/git-sync-cron.sh /path/to/repo >/dev/null 2>&1
```

## Run once
```bash
/home/borisindelman/git/assests/vault/git-sync.sh /path/to/repo
```

## Notes
- Conflicts always keep local files (`git merge -X ours`).
- Repo must have an upstream set (e.g., `git push -u origin main`).
- Lock file path: `.git/.git-sync.lock`.
