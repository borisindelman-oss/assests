#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./model_catalogue_helpers.sh
source "$SCRIPT_DIR/model_catalogue_helpers.sh"

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $(basename "$0") <author_search> [items_per_page=25]" >&2
  exit 1
fi

search="$1"
items_per_page="${2:-25}"

payload="$(jq -n \
  --arg search "$search" \
  --argjson items_per_page "$items_per_page" \
  '{
    page: 0,
    items_per_page: $items_per_page,
    sort: "ingested_at",
    sort_direction: "DESC",
    archived: false,
    filters: [
      {
        items: [
          {
            id: 0,
            columnField: "author",
            operatorValue: "contains",
            value: $search
          }
        ],
        linkOperator: "or"
      }
    ]
  }'
)"

mc_curl "$BASE_URL/v2/models" \
  -H "Content-Type: application/json" \
  -d "$payload" \
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
