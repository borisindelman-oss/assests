---
name: model-catalogue-core
description: Shared Model Catalogue primitives (resolve model refs, find latest checkpoint, call API helpers) used by model lookup/summary/checkpoint/modelci skills. Use when model references must be normalized before downstream analysis.
---

# Model Catalogue Core

Use this as the base layer for all model-catalogue skills.

## When To Use

- A request includes a model nickname but downstream code needs a `session_*` id.
- A request asks for "latest checkpoint" and model ref may be ambiguous.
- Another skill needs shared shell helpers instead of duplicating API plumbing.

## Commands

From this skill folder:

```bash
cd /home/borisindelman/.codex/skills/model-catalogue-core
```

Resolve nickname/ID to canonical model session id:

```bash
./scripts/resolve_model.sh <model_ref>
```

Get latest checkpoint number for a model ref:

```bash
./scripts/latest_checkpoint.sh <model_ref>
```

## Shared Helper Contract

`scripts/model_catalogue_api_helpers.sh` exports:

- `preflight_common_requirements`
- `mc_curl`
- `resolve_model_id`
- `latest_checkpoint_num`
- `model_console_url`

Downstream model skills should source this file instead of maintaining local copies.
