---
name: obs-buildkite-jobs
description: Fetch Buildkite job logs and extract failure lines for debugging CI jobs. Use when a user provides build/job ids or requests failure signal from Buildkite.
---

# Obs Buildkite Jobs

Use this as the Buildkite observability base layer.

## Setup

```bash
export BUILDKITE_TOKEN="<token>"
export BUILDKITE_ORG="${BUILDKITE_ORG:-wayve-dot-ai}"
export BUILDKITE_PIPELINE="${BUILDKITE_PIPELINE:-model-ci}"
```

## Commands

Fetch one job log to local files:

```bash
cd /home/borisindelman/.codex/skills/obs-buildkite-jobs
./scripts/fetch_buildkite_job_log.sh <build_number> <job_id> [output_prefix]
```

The command prints:

- `RAW_JSON_PATH=<path>`
- `CLEAN_LOG_PATH=<path>`
- `BUILDKITE_BUILD_URL=<url>`

Extract key failure lines from a log:

```bash
./scripts/extract_error_lines.sh <clean_log_path> [max_lines=120]
```
