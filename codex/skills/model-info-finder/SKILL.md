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

## Model CI + Shadow Gym Debugging

Use this flow when the user asks for model build status, failing job logs, Flyte/Eval link checks, or Shadow Gym info.

### Resolve model from nickname or model id

```bash
BASE_URL="https://model-catalogue-api.azr.internal.wayve.ai"
INPUT_MODEL="yellow-fish-alert"  # nickname or full model_session_id

AUTH_ARGS=()
if [ -n "${MODEL_CATALOGUE_TOKEN:-}" ]; then
  AUTH_ARGS=(-H "Authorization: Bearer $MODEL_CATALOGUE_TOKEN")
fi

# If INPUT_MODEL is already a full model id, use it directly.
if [[ "$INPUT_MODEL" == session_* ]]; then
  MODEL_ID="$INPUT_MODEL"
else
  search_json=$(curl -sS -G "$BASE_URL/v2/models/search" \
    --data-urlencode "search=$INPUT_MODEL" \
    --data-urlencode "limit=10" \
    --data-urlencode "ingested_only=true" \
    "${AUTH_ARGS[@]}")
  MODEL_ID=$(echo "$search_json" | jq -r '
    def rows:
      if type=="array" then .
      elif type=="object" then (.rows // .items // .results // .models // .data // [])
      else [] end;
    ((rows | map(select((.nickname // "") == "'"$INPUT_MODEL"'")) | .[0])
      // (rows[0] // {}))
    | (.id // .model_session_id // .session_id // empty)
  ')
fi
echo "MODEL_ID=$MODEL_ID"
```

### Resolve latest checkpoint and model artefact

```bash
details_json=$(curl -sS "$BASE_URL/v3/model/$MODEL_ID" "${AUTH_ARGS[@]}")
CHECKPOINT_NUM=$(echo "$details_json" | jq -r '[.checkpoints[]?.checkpoint_num] | max // 1')
MODEL_ARTEFACT_ID=$(echo "$details_json" | jq -r '
  (.checkpoints // [])
  | map(select(.checkpoint_num == '"$CHECKPOINT_NUM"'))
  | .[0].artefacts[0].id // empty
')
echo "CHECKPOINT_NUM=$CHECKPOINT_NUM"
echo "MODEL_ARTEFACT_ID=$MODEL_ARTEFACT_ID"
```

### Model CI build summary (latest build + jobs)

```bash
builds_json=$(curl -sS "$BASE_URL/v2/model/$MODEL_ID/$CHECKPOINT_NUM/modelci_builds" "${AUTH_ARGS[@]}")
echo "$builds_json" | jq -r '
  (sort_by(.buildkite_build_number // 0) | reverse | .[0]) as $b
  | "Model: " + ($b.model_session_id // ""),
    "Checkpoint: " + (($b.model_checkpoint_num // "")|tostring),
    "Latest Model CI build: " + (($b.buildkite_build_number // "")|tostring)
      + " (created " + ($b.created_at // "unknown") + ")",
    "Jobs:",
    ($b.jobs[]? | "  - " + (.label // "unknown")
      + ": " + (.status // "unknown")
      + (if .finished_at then " (finished " + .finished_at + ")" else "" end))
'
```

### Eval Studio / Flyte execution id check

```bash
# Use model artefact id from modelci_builds first, then fallback to details_json artefact.
LATEST_MODEL_ARTEFACT_ID=$(echo "$builds_json" | jq -r '
  sort_by(.buildkite_build_number // 0) | reverse | .[0].model_artefact_id // empty
')
[ -z "$LATEST_MODEL_ARTEFACT_ID" ] && LATEST_MODEL_ARTEFACT_ID="$MODEL_ARTEFACT_ID"

curl -sS "$BASE_URL/v2/model/$LATEST_MODEL_ARTEFACT_ID/eval_studio_info" "${AUTH_ARGS[@]}" | jq -r .
```

### If a Model CI job failed, pull Buildkite logs (requires `BUILDKITE_TOKEN`)

```bash
LATEST_BUILD_NUM=$(echo "$builds_json" | jq -r 'sort_by(.buildkite_build_number // 0) | reverse | .[0].buildkite_build_number // empty')
FAILED_JOB_IDS=$(echo "$builds_json" | jq -r '
  sort_by(.buildkite_build_number // 0) | reverse | .[0].jobs[]?
  | select((.status // "") == "failure")
  | .buildkite_job_id
' | tr -d "\r")

for JOB_ID in $FAILED_JOB_IDS; do
  echo "---- failing job: $JOB_ID ----"
  if [ -z "${BUILDKITE_TOKEN:-}" ]; then
    echo "BUILDKITE_TOKEN not set; cannot fetch Buildkite logs."
    continue
  fi

  curl -sS -H "Authorization: Bearer $BUILDKITE_TOKEN" \
    "https://api.buildkite.com/v2/organizations/wayve-dot-ai/pipelines/model-ci/builds/$LATEST_BUILD_NUM/jobs/$JOB_ID/log" \
    > "/tmp/modelci_${LATEST_BUILD_NUM}_${JOB_ID}.json"

  jq -r '.content' "/tmp/modelci_${LATEST_BUILD_NUM}_${JOB_ID}.json" \
    | perl -pe 's/\e\[[0-9;]*[A-Za-z]//g; s/\x1b_bk;t=\d+\x07//g' \
    > "/tmp/modelci_${LATEST_BUILD_NUM}_${JOB_ID}.log"

  rg -n "FAILED|failed|ERROR|Exception|Traceback|Timeout|exit code" \
    "/tmp/modelci_${LATEST_BUILD_NUM}_${JOB_ID}.log" | head -120 || true
done
```

### Shadow Gym summary for the checkpoint

```bash
sg_ids_json=$(curl -sS "$BASE_URL/v2/model/$MODEL_ID/$CHECKPOINT_NUM/shadow_gym_execution_ids" "${AUTH_ARGS[@]}")
echo "$sg_ids_json" | jq -r '
  ["shadow_gym_execution_id","created_at","suite_type","version_id"] | @tsv,
  (.[]? | [.id, .created_at, .suite_type, .version_id] | @tsv)
' | column -t -s $'\t'

LATEST_SG_ID=$(echo "$sg_ids_json" | jq -r 'sort_by(.created_at // "") | reverse | .[0].id // empty')
if [ -n "$LATEST_SG_ID" ]; then
  curl -sS "$BASE_URL/v2/shadow-gym/executions/$LATEST_SG_ID/metadata" "${AUTH_ARGS[@]}" | jq -r .
fi
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
- For Model CI status summaries:
- Always include model id, checkpoint, latest build number + created_at, and each job label/status.
- If a job has status `failure`, attempt Buildkite log fetch when `BUILDKITE_TOKEN` is present.
- For Buildkite log summaries, include the top failing test/exception line and at least one key timeout/error signal.
- For Flyte/Eval checks, always report the raw response from `/v2/model/{artefact_id}/eval_studio_info`.
- For Shadow Gym checks, include execution ids table and latest execution metadata when available.
- If there are no matches, report zero results and suggest broader query text.
- In assistant responses, do not use Markdown tables by default. Prefer terminal-friendly plain text.
- In assistant responses, include a clickable Console link using this exact format:
- `[Open model in Console](https://console.sso.wayve.ai/model/<id_or_nickname>)`
