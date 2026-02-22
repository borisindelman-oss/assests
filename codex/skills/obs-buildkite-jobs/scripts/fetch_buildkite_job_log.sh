#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "Usage: $(basename "$0") <build_number> <job_id> [output_prefix]" >&2
  exit 1
fi

build_number="$1"
job_id="$2"
output_prefix="${3:-/tmp/buildkite_${build_number}_${job_id}}"

buildkite_org="${BUILDKITE_ORG:-wayve-dot-ai}"
buildkite_pipeline="${BUILDKITE_PIPELINE:-model-ci}"

if ! command -v curl >/dev/null 2>&1; then
  echo "ERROR: missing required command 'curl'." >&2
  exit 127
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: missing required command 'jq'." >&2
  exit 127
fi

if [ -z "${BUILDKITE_TOKEN:-}" ]; then
  echo "ERROR: BUILDKITE_TOKEN is not set." >&2
  echo "Set it and retry: export BUILDKITE_TOKEN=\"<token>\"" >&2
  exit 1
fi

raw_json_path="${output_prefix}.json"
clean_log_path="${output_prefix}.log"

curl -f -sS -H "Authorization: Bearer ${BUILDKITE_TOKEN}" \
  "https://api.buildkite.com/v2/organizations/${buildkite_org}/pipelines/${buildkite_pipeline}/builds/${build_number}/jobs/${job_id}/log" \
  > "$raw_json_path"

if command -v perl >/dev/null 2>&1; then
  jq -r '.content // ""' "$raw_json_path" \
    | perl -pe 's/\e\[[0-9;]*[A-Za-z]//g; s/\x1b_bk;t=\d+\x07//g' \
    > "$clean_log_path"
else
  jq -r '.content // ""' "$raw_json_path" > "$clean_log_path"
fi

echo "RAW_JSON_PATH=$raw_json_path"
echo "CLEAN_LOG_PATH=$clean_log_path"
echo "BUILDKITE_BUILD_URL=https://buildkite.com/${buildkite_org}/${buildkite_pipeline}/builds/${build_number}#${job_id}"
