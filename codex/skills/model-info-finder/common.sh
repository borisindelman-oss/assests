#!/usr/bin/env bash
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
  local model_ref="${1:?model reference is required}"

  if [[ "$model_ref" == session_* ]]; then
    echo "$model_ref"
    return 0
  fi

  local search_json exact_count row_count
  search_json="$(mc_curl -G "$BASE_URL/v2/models/search" \
    --data-urlencode "search=$model_ref" \
    --data-urlencode "limit=20" \
    --data-urlencode "ingested_only=true")"

  exact_count="$(echo "$search_json" | jq -r --arg model_ref "$model_ref" '
    def rows:
      if type=="array" then .
      elif type=="object" then (.rows // .items // .results // .models // .data // [])
      else [] end;
    (rows | map(select((.nickname // "") == $model_ref)) | length)
  ')"

  if [ "$exact_count" = "1" ]; then
    echo "$search_json" | jq -r --arg model_ref "$model_ref" '
      def rows:
        if type=="array" then .
        elif type=="object" then (.rows // .items // .results // .models // .data // [])
        else [] end;
      (rows | map(select((.nickname // "") == $model_ref)) | .[0])
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
  local model_id="${1:?model id is required}"
  mc_curl "$BASE_URL/v3/model/$model_id" | jq -r '[.checkpoints[]?.checkpoint_num] | max // 1'
}
