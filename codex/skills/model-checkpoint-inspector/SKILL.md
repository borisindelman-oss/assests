---
name: model-checkpoint-inspector
description: Inspect checkpoint-level data for a model, including checkpoint licenses and run history. Use when a user asks for licenses or run-level evidence for a specific model/checkpoint.
---

# Model Checkpoint Inspector

Use shell scripts in `scripts/` for checkpoint-level inspection.

## Setup

```bash
BASE_URL="${BASE_URL:-https://model-catalogue-api.azr.internal.wayve.ai}"
```

Required commands:
- `curl`
- `jq`
- `column`

## Commands

From this skill folder:

```bash
cd /home/borisindelman/.codex/skills/model-checkpoint-inspector
```

Checkpoint licenses:

```bash
./scripts/checkpoint_licenses.sh <model_ref> [checkpoint_num]
```

Checkpoint runs:

```bash
./scripts/checkpoint_runs.sh <model_ref> [checkpoint_num] [limit=20]
```

If `checkpoint_num` is omitted, scripts use latest checkpoint.

## Expected columns

Licenses:
- `artefact_id`
- `model_session_id`
- `checkpoint_num`
- `license_type`
- `status`
- `requested_by`
- `created_at`

Runs:
- `run_id`
- `started_at`
- `driver`
- `run_type`
- `distance_m`
- `disengagement_count`
- `episode_count`
- `on_road_experiment_name`
- `run_url`

## Output rules

- Include clickable run links when reporting runs:
  - `[Open run](https://console.sso.wayve.ai/run/<run_id>)`
- Prefer plain text over markdown tables.
