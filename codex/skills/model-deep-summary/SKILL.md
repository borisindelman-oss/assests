---
name: model-deep-summary
description: Fetch an expanded per-model summary from Model Catalogue by nickname or session id, including commit id and aggregated license info. Use when a user asks for detailed metadata about one specific model.
---

# Model Deep Summary

Use shell scripts in `scripts/` for detailed single-model metadata.
This skill depends on `$model-catalogue-core` for model resolution.

## Setup

```bash
BASE_URL="${BASE_URL:-https://model-catalogue-api.azr.internal.wayve.ai}"
```

Required commands:
- `curl`
- `jq`
- `column`

## Command

From this skill folder:

```bash
cd /home/borisindelman/.codex/skills/model-deep-summary
./scripts/deep_model_summary.sh <model_ref>
```

`<model_ref>` accepts nickname or full `session_*` id.

## Expected columns

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

## Output rules

- Always include `commit_id`, `license_count`, and aggregated `licenses`.
- Prefer plain text over markdown tables.
- Include clickable model link:
  - `[Open model in Console](https://console.sso.wayve.ai/model/<id_or_nickname>)`
