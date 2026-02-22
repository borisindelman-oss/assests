---
name: modelci-shadowgym-debug
description: Inspect Model CI status for a model checkpoint, including failed Buildkite job log extraction, Eval Studio info, and Shadow Gym execution metadata. Use when a user asks to debug CI/eval failures for a model.
---

# ModelCI + ShadowGym Debug

Use shell scripts in `scripts/` for Model CI / eval debugging.

## Setup

```bash
BASE_URL="${BASE_URL:-https://model-catalogue-api.azr.internal.wayve.ai}"
export BUILDKITE_TOKEN="<token>"  # required only for Buildkite failing-job logs
```

Required commands:
- `curl`
- `jq`
- `column`

Optional:
- `perl` (ANSI cleanup for Buildkite logs)

## Command

From this skill folder:

```bash
cd /home/borisindelman/.codex/skills/modelci-shadowgym-debug
./scripts/modelci_evalstudio_shadowgym.sh <model_ref> [checkpoint_num]
```

If `checkpoint_num` is omitted, latest checkpoint is used.

## Behavior

- Prints latest Model CI build summary and per-job statuses.
- Prints Eval Studio info from `/v2/model/{artefact_id}/eval_studio_info` when available.
- If failing jobs exist and `BUILDKITE_TOKEN` is set, fetches logs to:
  - `/tmp/modelci_<build>_<job>.json`
  - `/tmp/modelci_<build>_<job>.log`
- Prints key failure lines from fetched Buildkite logs.
- Prints Shadow Gym execution IDs and latest execution metadata.

## Output rules

- Include model id, checkpoint, latest build number, created time, and per-job statuses.
- Prefer plain text over markdown tables.
