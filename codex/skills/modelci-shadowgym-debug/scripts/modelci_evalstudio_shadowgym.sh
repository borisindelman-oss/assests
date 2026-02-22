#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=/dev/null
source "$SKILLS_ROOT/model-catalogue-core/scripts/model_catalogue_api_helpers.sh"

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $(basename "$0") <model_ref (nickname or session_...)> [checkpoint_num]" >&2
  exit 1
fi

preflight_common_requirements

model_ref="$1"
model_id="$(resolve_model_id "$model_ref")"
checkpoint_num="${2:-$(latest_checkpoint_num "$model_id")}"

builds_json="$(mc_curl "$BASE_URL/v2/model/$model_id/$checkpoint_num/modelci_builds")"
build_count="$(echo "$builds_json" | jq -r 'if type=="array" then length else 0 end')"

if [ "$build_count" = "0" ]; then
  echo "Model: $model_id"
  echo "Checkpoint: $checkpoint_num"
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

  while IFS= read -r job_id; do
    [ -z "$job_id" ] && continue

    echo "---- failing job: $job_id ----"
    if [ -z "${BUILDKITE_TOKEN:-}" ]; then
      echo "BUILDKITE_TOKEN not set; cannot fetch Buildkite logs for failed jobs." >&2
      echo "Set it and rerun:" >&2
      echo "  export BUILDKITE_TOKEN=\"<token>\"" >&2
      continue
    fi

    fetch_output="$(
      BUILDKITE_ORG="${BUILDKITE_ORG:-wayve-dot-ai}" \
      BUILDKITE_PIPELINE="${BUILDKITE_PIPELINE:-model-ci}" \
      "$SKILLS_ROOT/obs-buildkite-jobs/scripts/fetch_buildkite_job_log.sh" \
        "$latest_build_num" \
        "$job_id" \
        "/tmp/modelci_${latest_build_num}_${job_id}"
    )"
    echo "$fetch_output"

    log_path="$(echo "$fetch_output" | awk -F= '/^CLEAN_LOG_PATH=/{print $2}')"
    if [ -n "$log_path" ] && [ -f "$log_path" ]; then
      "$SKILLS_ROOT/obs-buildkite-jobs/scripts/extract_error_lines.sh" "$log_path" 120 || true
    fi
  done <<< "$failed_job_ids"
fi

sg_ids_json="$(mc_curl "$BASE_URL/v2/model/$model_id/$checkpoint_num/shadow_gym_execution_ids")"
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
