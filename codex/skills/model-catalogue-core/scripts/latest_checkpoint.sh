#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./model_catalogue_api_helpers.sh
source "$SCRIPT_DIR/model_catalogue_api_helpers.sh"

if [ "$#" -ne 1 ]; then
  echo "Usage: $(basename "$0") <model_ref (nickname or session_...)>" >&2
  exit 1
fi

preflight_common_requirements
model_id="$(resolve_model_id "$1")"
latest_checkpoint_num "$model_id"
