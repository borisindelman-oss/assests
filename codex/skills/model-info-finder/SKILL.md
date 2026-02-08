---
name: model-info-finder
description: Find model-catalogue model information by nickname or author and return either basic summaries or deep per-model details. Use when a user asks to look up models, confirm model identity, inspect metadata quickly, or fetch expanded model detail without opening Console.
---

# Model Info Finder

## Overview

Use curl only. Do not use Python scripts for this skill.
Support lookup by `nickname` or `author`, and output either `basic` search results or `deep` model details.
For every summary, always include a Console link and pretty-print as a table.

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
  ${MODEL_CATALOGUE_TOKEN:+-H "Authorization: Bearer $MODEL_CATALOGUE_TOKEN"} \
| jq -r '
def rows:
  if type=="array" then .
  elif type=="object" then (.rows // .items // .results // .models // .data // [])
  else [] end;
(["id","nickname","author","ingested_at","console_url"] | @tsv),
(rows[] | [
  (.id // .model_session_id // .session_id // ""),
  (.nickname // ""),
  (.author // ""),
  (.ingested_at // ""),
  ("https://console.sso.wayve.ai/model/" + (.id // .model_session_id // .session_id // .nickname // ""))
] | @tsv)
' | column -t -s $'\t'
```

Deep:
- Run the basic command.
- Copy one model id from the response (`id` or `model_session_id`).
- Fetch details and print as a one-row table:

```bash
curl -sS "$BASE_URL/v3/model/<model_id>" \
  ${MODEL_CATALOGUE_TOKEN:+-H "Authorization: Bearer $MODEL_CATALOGUE_TOKEN"} \
| jq -r '
(["id","nickname","author","session_type","created_at","ingested_at","console_url"] | @tsv),
([
  (.id // ""),
  (.nickname // ""),
  (.author // ""),
  (.session_type // ""),
  (.created_at // ""),
  (.ingested_at // ""),
  ("https://console.sso.wayve.ai/model/" + (.id // .nickname // ""))
] | @tsv)
' | column -t -s $'\t'
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
  }" \
| jq -r '
def rows:
  if type=="array" then .
  elif type=="object" then (.rows // .items // .results // .models // .data // [])
  else [] end;
(["id","nickname","author","ingested_at","console_url"] | @tsv),
(rows[] | [
  (.id // .model_session_id // .session_id // ""),
  (.nickname // ""),
  (.author // ""),
  (.ingested_at // ""),
  ("https://console.sso.wayve.ai/model/" + (.id // .model_session_id // .session_id // .nickname // ""))
] | @tsv)
' | column -t -s $'\t'
```

Deep:
- Run the basic command.
- Copy one model id from the response.
- Fetch details and print as a one-row table:

```bash
curl -sS "$BASE_URL/v3/model/<model_id>" \
  ${MODEL_CATALOGUE_TOKEN:+-H "Authorization: Bearer $MODEL_CATALOGUE_TOKEN"} \
| jq -r '
(["id","nickname","author","session_type","created_at","ingested_at","console_url"] | @tsv),
([
  (.id // ""),
  (.nickname // ""),
  (.author // ""),
  (.session_type // ""),
  (.created_at // ""),
  (.ingested_at // ""),
  ("https://console.sso.wayve.ai/model/" + (.id // .nickname // ""))
] | @tsv)
' | column -t -s $'\t'
```

## Output Rules

- Always pretty-print summaries as tables.
- Always include `console_url` in the table.
- Build `console_url` as `https://console.sso.wayve.ai/model/<id_or_nickname>`.
- `basic`: return a table from search response rows.
- `deep`: search first, then fetch `/v3/model/<model_id>` and return a table.
- If there are no matches, report zero results and suggest broader query text.
