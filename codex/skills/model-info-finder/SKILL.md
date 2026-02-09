---
name: model-info-finder
description: Find model-catalogue model information by nickname or author and return either basic summaries or deep per-model details. Use when a user asks to look up models, confirm model identity, inspect metadata quickly, fetch expanded model detail, or retrieve checkpoint-level licenses/runs/model-ci status without opening Console.
---

# Model Info Finder

## Overview

Use `curl` only. Do not use Python scripts for this skill.

This skill supports:
- lookup by model nickname or author
- deep model summaries (with commit + license info)
- checkpoint-level licenses and runs
- Model CI status, failed-job Buildkite logs, Eval Studio execution-id check
- Shadow Gym execution summary for a checkpoint

## Quick Start

```bash
BASE_URL="https://model-catalogue-api.azr.internal.wayve.ai"
export MODEL_CATALOGUE_TOKEN="<token>"   # optional in some environments
export BUILDKITE_TOKEN="<token>"          # required for Buildkite job logs
```

## Shared Helpers

Use these helpers before running the workflows below.

```bash
set -euo pipefail

BASE_URL="${BASE_URL:-https://model-catalogue-api.azr.internal.wayve.ai}"

mc_curl() {
  if [ -n "${MODEL_CATALOGUE_TOKEN:-}" ]; then
    curl -sS -H "Authorization: Bearer $MODEL_CATALOGUE_TOKEN" "$@"
  else
    curl -sS "$@"
  fi
}

resolve_model_id() {
  # Accepts nickname or full model_session_id, prints model id.
  local model_ref="$1"

  if [[ "$model_ref" == session_* ]]; then
    echo "$model_ref"
    return 0
  fi

  local search_json exact_count row_count
  search_json="$(mc_curl -G "$BASE_URL/v2/models/search" \
    --data-urlencode "search=$model_ref" \
    --data-urlencode "limit=20" \
    --data-urlencode "ingested_only=true")"

  exact_count="$(echo "$search_json" | jq -r '
    def rows:
      if type=="array" then .
      elif type=="object" then (.rows // .items // .results // .models // .data // [])
      else [] end;
    (rows | map(select((.nickname // "") == "'"$model_ref"'")) | length)
  ')"

  if [ "$exact_count" = "1" ]; then
    echo "$search_json" | jq -r '
      def rows:
        if type=="array" then .
        elif type=="object" then (.rows // .items // .results // .models // .data // [])
        else [] end;
      (rows | map(select((.nickname // "") == "'"$model_ref"'")) | .[0])
      | (.id // .model_session_id // .session_id)
    '
    return 0
  fi

  row_count="$(echo "$search_json" | jq -r '
    def rows:
      if type=="array" then .
      elif type=="object" then (.rows // .items // .results // .models // .data // [])
      else [] end;
    rows | length
  ')"

  if [ "$row_count" = "1" ]; then
    echo "$search_json" | jq -r '
      def rows:
        if type=="array" then .
        elif type=="object" then (.rows // .items // .results // .models // .data // [])
        else [] end;
      rows[0] | (.id // .model_session_id // .session_id)
    '
    return 0
  fi

  if [ "$row_count" = "0" ]; then
    echo "ERROR: no model found for '$model_ref'" >&2
    return 1
  fi

  echo "ERROR: ambiguous model ref '$model_ref'. Multiple matches found." >&2
  echo "$search_json" | jq -r '
    def rows:
      if type=="array" then .
      elif type=="object" then (.rows // .items // .results // .models // .data // [])
      else [] end;
    (["id","nickname","author","ingested_at"] | @tsv),
    (rows[] | [
      (.id // .model_session_id // .session_id // ""),
      (.nickname // ""),
      (.author // ""),
      (.ingested_at // "")
    ] | @tsv)
  ' | column -t -s $'\t' >&2
  return 2
}

latest_checkpoint_num() {
  local model_id="$1"
  mc_curl "$BASE_URL/v3/model/$model_id" | jq -r '[.checkpoints[]?.checkpoint_num] | max // 1'
}
```

## Nickname Lookup (Basic)

```bash
MODEL_NICKNAME="idealistic-opossum-cyan"
mc_curl -G "$BASE_URL/v2/models/search" \
  --data-urlencode "search=$MODEL_NICKNAME" \
  --data-urlencode "limit=5" \
  --data-urlencode "ingested_only=true" \
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

## Author Lookup (Basic)

```bash
SEARCH="boris"
mc_curl "$BASE_URL/v2/models" \
  -H "Content-Type: application/json" \
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

## Deep Model Summary

```bash
MODEL_REF="yellow-fish-alert"     # nickname or full model_session_id
MODEL_ID="$(resolve_model_id "$MODEL_REF")"
details_json="$(mc_curl "$BASE_URL/v3/model/$MODEL_ID")"

session_path="$(echo "$details_json" | jq -r '.metadata.session_path // empty')"
commit_id=""
if [ -n "$session_path" ] && [ -f "$session_path/git.hash" ]; then
  commit_id="$(tr -d '[:space:]' < "$session_path/git.hash")"
else
  commit_id="$(echo "$details_json" | jq -r '.metadata.run_command // ""' \
    | sed -n 's/.*+_provenance_metadata.git_commit_hash=\([0-9a-f]\{40\}\).*/\1/p')"
fi
[ -z "$commit_id" ] && commit_id="unknown"

licenses="$(echo "$details_json" | jq -r '[.checkpoints[]?.artefacts[]?.licenses[]?] | unique | join(",")')"
license_count="$(echo "$details_json" | jq -r '[.checkpoints[]?.artefacts[]?.licenses[]?] | unique | length')"
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

## Checkpoint Licenses

```bash
MODEL_REF="yellow-fish-alert"
MODEL_ID="$(resolve_model_id "$MODEL_REF")"
CHECKPOINT_NUM="$(latest_checkpoint_num "$MODEL_ID")"

mc_curl "$BASE_URL/v2/model/$MODEL_ID/$CHECKPOINT_NUM/licenses" \
| jq -r '
(["artefact_id","model_session_id","checkpoint_num","license_type","status","requested_by","created_at"] | @tsv),
(.[]? | [
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

## Checkpoint Runs

```bash
MODEL_REF="yellow-fish-alert"
MODEL_ID="$(resolve_model_id "$MODEL_REF")"
CHECKPOINT_NUM="$(latest_checkpoint_num "$MODEL_ID")"

mc_curl "$BASE_URL/v2/model/$MODEL_ID/$CHECKPOINT_NUM/runs" \
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

## Model CI + Buildkite Logs + Eval Studio + Shadow Gym

```bash
MODEL_REF="yellow-fish-alert"       # nickname or full model_session_id
MODEL_ID="$(resolve_model_id "$MODEL_REF")"
CHECKPOINT_NUM="$(latest_checkpoint_num "$MODEL_ID")"

builds_json="$(mc_curl "$BASE_URL/v2/model/$MODEL_ID/$CHECKPOINT_NUM/modelci_builds")"
build_count="$(echo "$builds_json" | jq -r 'if type=="array" then length else 0 end')"
if [ "$build_count" = "0" ]; then
  echo "Model: $MODEL_ID"
  echo "Checkpoint: $CHECKPOINT_NUM"
  echo "No Model CI builds found."
else
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

  latest_model_artefact_id="$(echo "$builds_json" | jq -r '
    sort_by(.buildkite_build_number // 0) | reverse | .[0].model_artefact_id // empty
  ')"

  if [ -n "$latest_model_artefact_id" ]; then
    echo "Eval Studio Info:"
    mc_curl "$BASE_URL/v2/model/$latest_model_artefact_id/eval_studio_info" | jq -r .
  fi

  latest_build_num="$(echo "$builds_json" | jq -r '
    sort_by(.buildkite_build_number // 0) | reverse | .[0].buildkite_build_number // empty
  ')"

  failed_job_ids="$(echo "$builds_json" | jq -r '
    sort_by(.buildkite_build_number // 0) | reverse | .[0].jobs[]?
    | select((.status // "") == "failure")
    | .buildkite_job_id
  ' | tr -d "\r")"

  echo "$failed_job_ids" | sed '/^$/d' | while IFS= read -r job_id; do
    echo "---- failing job: $job_id ----"
    if [ -z "${BUILDKITE_TOKEN:-}" ]; then
      echo "BUILDKITE_TOKEN not set; skipping Buildkite log fetch."
      continue
    fi

    curl -sS -H "Authorization: Bearer $BUILDKITE_TOKEN" \
      "https://api.buildkite.com/v2/organizations/wayve-dot-ai/pipelines/model-ci/builds/$latest_build_num/jobs/$job_id/log" \
      > "/tmp/modelci_${latest_build_num}_${job_id}.json"

    jq -r '.content' "/tmp/modelci_${latest_build_num}_${job_id}.json" \
      | perl -pe 's/\e\[[0-9;]*[A-Za-z]//g; s/\x1b_bk;t=\d+\x07//g' \
      > "/tmp/modelci_${latest_build_num}_${job_id}.log"

    rg -n "FAILED|failed|ERROR|Exception|Traceback|Timeout|ForwardPassException|exit code" \
      "/tmp/modelci_${latest_build_num}_${job_id}.log" | head -120 || true
  done
fi

sg_ids_json="$(mc_curl "$BASE_URL/v2/model/$MODEL_ID/$CHECKPOINT_NUM/shadow_gym_execution_ids")"
echo "$sg_ids_json" | jq -r '
  def rows: if type=="array" then . else [] end;
  (["shadow_gym_execution_id","created_at","suite_type","version_id"] | @tsv),
  (rows[] | [.id // "", .created_at // "", .suite_type // "", .version_id // ""] | @tsv)
' | column -t -s $'\t'

latest_sg_id="$(echo "$sg_ids_json" | jq -r '
  def rows: if type=="array" then . else [] end;
  (rows | sort_by(.created_at // "") | reverse | .[0].id) // empty
')"
if [ -n "$latest_sg_id" ]; then
  echo "Latest Shadow Gym metadata:"
  mc_curl "$BASE_URL/v2/shadow-gym/executions/$latest_sg_id/metadata" | jq -r .
fi
```

## Output Rules

- Always include `console_url` in model/run summaries.
- For deep summaries, always include:
  - `commit_id`
  - `license_count`
  - `licenses` (unique, aggregated)
- For Model CI summaries, always include:
  - model id
  - checkpoint
  - latest build number + created time
  - per-job label + status (+ finished time when present)
- If any job failed and `BUILDKITE_TOKEN` is present, fetch Buildkite logs and report key error lines.
- For Eval Studio checks, report raw output from `/v2/model/{artefact_id}/eval_studio_info`.
- For Shadow Gym checks, report execution ids table and latest metadata when available.
- If no model matches, report zero results and suggest a broader query.
- In assistant responses:
  - prefer plain text (not markdown tables)
  - include clickable model link exactly as:
    - `[Open model in Console](https://console.sso.wayve.ai/model/<id_or_nickname>)`
  - include per-run clickable links when runs are shown:
    - `[Open run](https://console.sso.wayve.ai/run/<run_id>)`
