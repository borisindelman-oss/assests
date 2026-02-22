#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=/dev/null
source "$SKILLS_ROOT/model-catalogue-core/scripts/model_catalogue_api_helpers.sh"

if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
  echo "Usage: $(basename "$0") <model_ref (nickname or session_...)> [checkpoint_num] [limit=20]" >&2
  exit 1
fi

preflight_common_requirements

model_ref="$1"
model_id="$(resolve_model_id "$model_ref")"
checkpoint_num="${2:-$(latest_checkpoint_num "$model_id")}"
limit="${3:-20}"

mc_curl "$BASE_URL/v2/model/$model_id/$checkpoint_num/runs" \
| jq -r --argjson limit "$limit" '
  (["run_id","started_at","driver","run_type","distance_m","disengagement_count","episode_count","on_road_experiment_name","run_url"] | @tsv),
  ((sort_by(.started_at) | reverse | .[:$limit])[] | [
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
