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

mc_curl "$BASE_URL/v2/model/$model_id/$checkpoint_num/licenses" \
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
