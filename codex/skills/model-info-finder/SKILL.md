---
name: model-info-finder
description: Find model-catalogue model information by nickname or author and return either basic summaries or deep per-model details. Use when a user asks to look up models, confirm model identity, inspect metadata quickly, fetch expanded model detail, or retrieve checkpoint-level licenses/runs without opening Console.
---

# Model Info Finder

## Overview

Use curl only. Do not use Python scripts for this skill.
Support lookup by `nickname` or `author`, and output either `basic` search results or `deep` model details.
For every summary, always include a Console link and pretty-print as a table.
For deep summaries, always include `commit_id` resolved from `metadata.session_path/git.hash` when available.
For deep summaries, always include licensing info: `license_count` and `licenses`.

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
MODEL_ID="<model_id>"
details_json=$(curl -sS "$BASE_URL/v3/model/$MODEL_ID" \
  ${MODEL_CATALOGUE_TOKEN:+-H "Authorization: Bearer $MODEL_CATALOGUE_TOKEN"})

session_path=$(echo "$details_json" | jq -r '.metadata.session_path // empty')
commit_id=""
if [ -n "$session_path" ] && [ -f "$session_path/git.hash" ]; then
  commit_id=$(tr -d '[:space:]' < "$session_path/git.hash")
else
  commit_id=$(echo "$details_json" | jq -r '.metadata.run_command // ""' \
    | sed -n 's/.*+_provenance_metadata.git_commit_hash=\([0-9a-f]\{40\}\).*/\1/p')
fi
[ -z "$commit_id" ] && commit_id="unknown"
licenses=$(echo "$details_json" | jq -r '[.checkpoints[]?.artefacts[]?.licenses[]?] | unique | join(",")')
license_count=$(echo "$details_json" | jq -r '[.checkpoints[]?.artefacts[]?.licenses[]?] | unique | length')
[ -z "$licenses" ] && licenses="none"

echo "$details_json" | jq -r --arg commit_id "$commit_id" --arg licenses "$licenses" --arg license_count "$license_count" '
(["id","nickname","author","session_type","created_at","ingested_at","commit_id","license_count","licenses","console_url"] | @tsv),
([
  (.id // ""),
  (.nickname // ""),
  (.author // ""),
  (.session_type // ""),
  (.created_at // ""),
  (.ingested_at // ""),
  $commit_id,
  $license_count,
  $licenses,
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
MODEL_ID="<model_id>"
details_json=$(curl -sS "$BASE_URL/v3/model/$MODEL_ID" \
  ${MODEL_CATALOGUE_TOKEN:+-H "Authorization: Bearer $MODEL_CATALOGUE_TOKEN"})

session_path=$(echo "$details_json" | jq -r '.metadata.session_path // empty')
commit_id=""
if [ -n "$session_path" ] && [ -f "$session_path/git.hash" ]; then
  commit_id=$(tr -d '[:space:]' < "$session_path/git.hash")
else
  commit_id=$(echo "$details_json" | jq -r '.metadata.run_command // ""' \
    | sed -n 's/.*+_provenance_metadata.git_commit_hash=\([0-9a-f]\{40\}\).*/\1/p')
fi
[ -z "$commit_id" ] && commit_id="unknown"
licenses=$(echo "$details_json" | jq -r '[.checkpoints[]?.artefacts[]?.licenses[]?] | unique | join(",")')
license_count=$(echo "$details_json" | jq -r '[.checkpoints[]?.artefacts[]?.licenses[]?] | unique | length')
[ -z "$licenses" ] && licenses="none"

echo "$details_json" | jq -r --arg commit_id "$commit_id" --arg licenses "$licenses" --arg license_count "$license_count" '
(["id","nickname","author","session_type","created_at","ingested_at","commit_id","license_count","licenses","console_url"] | @tsv),
([
  (.id // ""),
  (.nickname // ""),
  (.author // ""),
  (.session_type // ""),
  (.created_at // ""),
  (.ingested_at // ""),
  $commit_id,
  $license_count,
  $licenses,
  ("https://console.sso.wayve.ai/model/" + (.id // .nickname // ""))
] | @tsv)
' | column -t -s $'\t'
```

## Checkpoint Options

Use these when the user asks for checkpoint-specific licensing or runs.

Resolve latest checkpoint number (optional helper):

```bash
MODEL_ID="<model_id>"
details_json=$(curl -sS "$BASE_URL/v3/model/$MODEL_ID" \
  ${MODEL_CATALOGUE_TOKEN:+-H "Authorization: Bearer $MODEL_CATALOGUE_TOKEN"})
CHECKPOINT_NUM=$(echo "$details_json" | jq -r '[.checkpoints[]?.checkpoint_num] | max')
```

Get checkpoint licenses:

```bash
MODEL_ID="<model_id>"
CHECKPOINT_NUM="<checkpoint_num>"
curl -sS "$BASE_URL/v2/model/$MODEL_ID/$CHECKPOINT_NUM/licenses" \
  ${MODEL_CATALOGUE_TOKEN:+-H "Authorization: Bearer $MODEL_CATALOGUE_TOKEN"} \
| jq -r '
(["artefact_id","model_session_id","checkpoint_num","license_type","status","requested_by","created_at"] | @tsv),
(.[] | [
  (.artefact_id // ""),
  (.model_session_id // ""),
  (.model_checkpoint_num // ""),
  (.license_type // ""),
  (.status // ""),
  (.requested_by // ""),
  (.created_at // "")
] | @tsv)
' | column -t -s $'\t'
```

Get checkpoint runs (show latest 20 rows):

```bash
MODEL_ID="<model_id>"
CHECKPOINT_NUM="<checkpoint_num>"
curl -sS "$BASE_URL/v2/model/$MODEL_ID/$CHECKPOINT_NUM/runs" \
  ${MODEL_CATALOGUE_TOKEN:+-H "Authorization: Bearer $MODEL_CATALOGUE_TOKEN"} \
| jq -r '
(["run_id","started_at","driver","run_type","distance_m","disengagement_count","episode_count","on_road_experiment_name","run_url"] | @tsv),
((sort_by(.started_at) | reverse | .[:20])[] | [
  (.id // ""),
  (.started_at // ""),
  (.driver // ""),
  (.run_type // ""),
  (.total_distance_travelled_m // ""),
  (.disengagement_count // ""),
  (.episode_count // ""),
  (.on_road_experiment_name // ""),
  ("https://console.sso.wayve.ai/run/" + (.id // ""))
] | @tsv)
' | column -t -s $'\t'
```

## Output Rules

- Always pretty-print summaries as tables.
- Always include `console_url` in the table.
- Always include `commit_id` in deep model summaries.
- Always include licensing in deep model summaries:
- `license_count` and `licenses` (unique list aggregated across model artefacts/checkpoints).
- Build `console_url` as `https://console.sso.wayve.ai/model/<id_or_nickname>`.
- `basic`: return a table from search response rows.
- `deep`: search first, then fetch `/v3/model/<model_id>` and return a table.
- If user asks for checkpoint licenses, call:
- `GET /v2/model/{model_id}/{checkpoint_num}/licenses`
- If user asks for checkpoint runs, call:
- `GET /v2/model/{model_id}/{checkpoint_num}/runs`
- For checkpoint runs output:
- Always include `run_url` in the table as `https://console.sso.wayve.ai/run/<run_id>`.
- In assistant responses, include one clickable link per run using:
- `[Open run](https://console.sso.wayve.ai/run/<run_id>)`
- Resolve `commit_id` in this order:
- 1) read `<metadata.session_path>/git.hash`
- 2) fallback: parse `+_provenance_metadata.git_commit_hash=<sha>` from `metadata.run_command`
- 3) fallback: `unknown`
- If there are no matches, report zero results and suggest broader query text.
- In assistant responses, do not use Markdown tables by default. Prefer terminal-friendly plain text.
- In assistant responses, include a clickable Console link using this exact format:
- `[Open model in Console](https://console.sso.wayve.ai/model/<id_or_nickname>)`
