---
name: model-info-finder
description: Find model-catalogue model information by nickname or author and return either basic summaries or deep per-model details. Use when a user asks to look up models, confirm model identity, inspect metadata quickly, or fetch expanded model detail without opening Console.
---

# Model Info Finder

## Overview

Use curl only. Do not use Python scripts for this skill.
Support lookup by `nickname` or `author`, and output either `basic` search results or `deep` model details.

## Quick Start

Set base URL and optional token:

```bash
BASE_URL="https://model-catalogue-api.azr.internal.wayve.ai"
export MODEL_CATALOGUE_TOKEN="<token>"
```

If auth is not required in your environment, skip `MODEL_CATALOGUE_TOKEN`.

## Nickname Lookup

Basic:

```bash
curl -sS -G "$BASE_URL/v2/models/search" \
  --data-urlencode "search=idealistic-opossum-cyan" \
  --data-urlencode "limit=5" \
  --data-urlencode "ingested_only=true" \
  ${MODEL_CATALOGUE_TOKEN:+-H "Authorization: Bearer $MODEL_CATALOGUE_TOKEN"}
```

Deep:
- Run the basic command.
- Copy one model id from the response (`id` or `model_session_id`).
- Fetch details:

```bash
curl -sS "$BASE_URL/v3/model/<model_id>" \
  ${MODEL_CATALOGUE_TOKEN:+-H "Authorization: Bearer $MODEL_CATALOGUE_TOKEN"}
```

## Author Lookup

Basic:

```bash
SEARCH="boris"
curl -sS "$BASE_URL/v2/models" \
  -H "Content-Type: application/json" \
  ${MODEL_CATALOGUE_TOKEN:+-H "Authorization: Bearer $MODEL_CATALOGUE_TOKEN"} \
  -d "{
    \"page\": 0,
    \"items_per_page\": 25,
    \"sort\": \"ingested_at\",
    \"sort_direction\": \"DESC\",
    \"archived\": false,
    \"filters\": [
      {
        \"items\": [
          {\"id\": 0, \"columnField\": \"author\", \"operatorValue\": \"contains\", \"value\": \"$SEARCH\"}
        ],
        \"linkOperator\": \"or\"
      }
    ]
  }"
```

Deep:
- Run the basic command.
- Copy one model id from the response.
- Fetch details:

```bash
curl -sS "$BASE_URL/v3/model/<model_id>" \
  ${MODEL_CATALOGUE_TOKEN:+-H "Authorization: Bearer $MODEL_CATALOGUE_TOKEN"}
```

## Output Rules

- `basic`: return the search response directly.
- `deep`: search first, then fetch `/v3/model/<model_id>` for chosen model(s).
- If there are no matches, report zero results and suggest broader query text.
