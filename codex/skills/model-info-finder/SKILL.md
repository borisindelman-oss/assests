---
name: model-info-finder
description: Find model-catalogue model information by nickname or author and return either basic summaries or deep per-model details. Use when a user asks to look up models, confirm model identity, inspect metadata quickly, fetch expanded model detail, or retrieve checkpoint-level licenses/runs/model-ci status without opening Console.
---

# Model Info Finder

## Overview

Use the shell scripts in this folder. They use `curl` + `jq` and share helpers from `common.sh`.
Do not use Python scripts for this skill.

Capabilities:
- Lookup by model nickname or author
- Deep model summaries (with commit + aggregated license info)
- Checkpoint-level licenses and runs
- Model CI status, failed-job Buildkite logs, Eval Studio execution-id check
- Shadow Gym execution summary for a checkpoint

## Location

All scripts are in the same directory as this `SKILL.md`:

- `common.sh`
- `lookup_by_nickname.sh`
- `lookup_by_author.sh`
- `deep_model_summary.sh`
- `checkpoint_licenses.sh`
- `checkpoint_runs.sh`
- `modelci_evalstudio_shadowgym.sh`

## Setup

```bash
BASE_URL="${BASE_URL:-https://model-catalogue-api.azr.internal.wayve.ai}"
export MODEL_CATALOGUE_TOKEN="<token>"   # optional in some environments
export BUILDKITE_TOKEN="<token>"          # required only for Buildkite log fetch
```

From this folder:

```bash
cd /home/borisindelman/git/assests/codex/skills/model-info-finder
```

## Workflows

### 1) Nickname Lookup (Basic)

```bash
./lookup_by_nickname.sh <model_nickname_or_search> [limit=5]
```

Example:

```bash
./lookup_by_nickname.sh idealistic-opossum-cyan 5
```

Returns columns:
- `id`
- `nickname`
- `author`
- `ingested_at`
- `console_url`

### 2) Author Lookup (Basic)

```bash
./lookup_by_author.sh <author_search> [items_per_page=25]
```

Example:

```bash
./lookup_by_author.sh boris 25
```

Returns columns:
- `id`
- `nickname`
- `author`
- `ingested_at`
- `console_url`

### 3) Deep Model Summary

```bash
./deep_model_summary.sh <model_ref>
```

`<model_ref>` accepts nickname or full `session_*` id.

Example:

```bash
./deep_model_summary.sh yellow-fish-alert
```

Returns columns:
- `id`
- `nickname`
- `author`
- `session_type`
- `created_at`
- `ingested_at`
- `commit_id`
- `license_count`
- `licenses`
- `console_url`

### 4) Checkpoint Licenses

```bash
./checkpoint_licenses.sh <model_ref> [checkpoint_num]
```

If `checkpoint_num` is omitted, latest checkpoint is used.

Example:

```bash
./checkpoint_licenses.sh yellow-fish-alert
```

Returns columns:
- `artefact_id`
- `model_session_id`
- `checkpoint_num`
- `license_type`
- `status`
- `requested_by`
- `created_at`

### 5) Checkpoint Runs

```bash
./checkpoint_runs.sh <model_ref> [checkpoint_num] [limit=20]
```

If `checkpoint_num` is omitted, latest checkpoint is used.

Example:

```bash
./checkpoint_runs.sh yellow-fish-alert 12 20
```

Returns columns:
- `run_id`
- `started_at`
- `driver`
- `run_type`
- `distance_m`
- `disengagement_count`
- `episode_count`
- `on_road_experiment_name`
- `run_url`

### 6) Model CI + Buildkite + Eval Studio + Shadow Gym

```bash
./modelci_evalstudio_shadowgym.sh <model_ref> [checkpoint_num]
```

If `checkpoint_num` is omitted, latest checkpoint is used.

Example:

```bash
./modelci_evalstudio_shadowgym.sh yellow-fish-alert
```

Behavior:
- Prints latest Model CI build summary and per-job statuses
- Prints raw Eval Studio info from `/v2/model/{artefact_id}/eval_studio_info` when available
- If failing jobs exist and `BUILDKITE_TOKEN` is set, fetches Buildkite logs into `/tmp/modelci_<build>_<job>.{json,log}` and prints key error lines
- Prints Shadow Gym execution ids table and latest execution metadata

## Shared Helpers (`common.sh`)

`common.sh` provides:
- `mc_curl`: token-aware curl wrapper
- `resolve_model_id <model_ref>`: resolves nickname/session, errors on ambiguous/no match
- `latest_checkpoint_num <model_id>`: resolves latest checkpoint from `/v3/model/{id}`

## Output Rules

- Always include `console_url` in model summaries.
- For deep summaries, include:
  - `commit_id`
  - `license_count`
  - `licenses` (unique, aggregated)
- For Model CI summaries, include:
  - model id
  - checkpoint
  - latest build number + created time
  - per-job label + status (+ finished time if present)
- If no model matches, report zero results and suggest a broader query.
- Assistant response formatting:
  - prefer plain text (not markdown tables)
  - include clickable model link exactly as:
    - `[Open model in Console](https://console.sso.wayve.ai/model/<id_or_nickname>)`
  - include per-run clickable links when runs are shown:
    - `[Open run](https://console.sso.wayve.ai/run/<run_id>)`
