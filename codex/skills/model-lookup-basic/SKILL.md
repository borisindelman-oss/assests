---
name: model-lookup-basic
description: Lookup model-catalogue sessions by nickname or author and return basic model identity details. Use when a user asks to find a model, confirm model identity, or list candidate models by nickname/author before deeper inspection.
---

# Model Lookup Basic

Use shell scripts in `scripts/` for lightweight model discovery.

## Overview

This skill provides fast lookups by nickname or author using Model Catalogue API.
Keep output concise and plain text.

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
cd /home/borisindelman/.codex/skills/model-lookup-basic
```

Lookup by nickname/search:

```bash
./scripts/lookup_by_nickname.sh <model_nickname_or_search> [limit=5]
```

Lookup by author:

```bash
./scripts/lookup_by_author.sh <author_search> [items_per_page=25]
```

## Expected columns

- `id`
- `nickname`
- `author`
- `ingested_at`
- `console_url`

## Output rules

- If no matches: report zero results and suggest broader search.
- Prefer plain text over markdown tables.
- Include clickable model link when reporting a chosen model:
  - `[Open model in Console](https://console.sso.wayve.ai/model/<id_or_nickname>)`
