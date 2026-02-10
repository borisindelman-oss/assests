#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $(basename "$0") <model_nickname_or_search> [limit=5]" >&2
  exit 1
fi

model_nickname="$1"
limit="${2:-5}"

mc_curl -G "$BASE_URL/v2/models/search" \
  --data-urlencode "search=$model_nickname" \
  --data-urlencode "limit=$limit" \
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
