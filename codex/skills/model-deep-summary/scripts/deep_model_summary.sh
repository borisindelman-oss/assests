#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=/dev/null
source "$SKILLS_ROOT/model-catalogue-core/scripts/model_catalogue_api_helpers.sh"

if [ "$#" -ne 1 ]; then
  echo "Usage: $(basename "$0") <model_ref (nickname or session_...)>" >&2
  exit 1
fi

preflight_common_requirements

model_ref="$1"
model_id="$(resolve_model_id "$model_ref")"
details_json="$(mc_curl "$BASE_URL/v3/model/$model_id")"

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

echo "$details_json" | jq -r \
  --arg commit_id "$commit_id" \
  --arg licenses "$licenses" \
  --arg license_count "$license_count" '
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
