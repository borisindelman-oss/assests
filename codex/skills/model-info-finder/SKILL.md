---
name: model-info-finder
description: Find model-catalogue model information by nickname or author and return either basic summaries or deep per-model details. Use when a user asks to look up models, confirm model identity, inspect metadata quickly, or fetch expanded model detail without opening Console.
---

# Model Info Finder

## Overview

Resolve model information from model-catalogue with a predictable workflow.
Support two query paths now: `nickname` and `author`, with `basic` or `deep` output depth.

## Quick Start

Run the helper script:

```bash
python3 scripts/model_info.py --by nickname --query idealistic-opossum-cyan --mode basic --limit 5
python3 scripts/model_info.py --by author --query boris --mode deep --limit 3
```

Optional auth:

```bash
export MODEL_CATALOGUE_TOKEN="<token>"
```

## Workflow

1. Parse request intent:
- Query type `nickname` or `author`.
- Output depth `basic` or `deep`.

2. Execute helper script:
- Prefer `scripts/model_info.py`.
- Use `--by`, `--query`, `--mode`, and `--limit`.

3. Present result:
- For `basic`, return compact summaries.
- For `deep`, return detailed model payloads per matched model.
- If nothing matches, say so explicitly and suggest a broader query.

## Commands

Nickname lookup:

```bash
python3 scripts/model_info.py --by nickname --query "<nickname>" --mode basic
```

Author lookup:

```bash
python3 scripts/model_info.py --by author --query "<author_substring>" --mode basic
```

Deep details:

```bash
python3 scripts/model_info.py --by nickname --query "<nickname>" --mode deep --limit 3
```

JSON output:

```bash
python3 scripts/model_info.py --by author --query "<author>" --mode deep --json
```

## Reference

Read `references/model-catalogue-endpoints.md` when endpoint behavior, payload shape, or troubleshooting details are needed.

## Scope

Current scope:
- Lookup by `nickname` and `author`.
- Output depth `basic` and `deep`.

Future expansion:
- Add lookup by model ID and tags.
- Add richer filtering and sorting options.
