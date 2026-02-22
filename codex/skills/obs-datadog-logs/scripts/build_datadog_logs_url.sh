#!/usr/bin/env bash
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: missing required command 'jq'." >&2
  exit 127
fi

datadog_site="${DATADOG_SITE:-datadoghq.eu}"
query=""
namespace=""
pod=""
cluster=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --query)
      query="${2:-}"
      shift 2
      ;;
    --namespace)
      namespace="${2:-}"
      shift 2
      ;;
    --pod)
      pod="${2:-}"
      shift 2
      ;;
    --cluster)
      cluster="${2:-}"
      shift 2
      ;;
    *)
      echo "Usage: $(basename "$0") [--query <query>] [--namespace <ns> --pod <pod>] [--cluster <cluster>]" >&2
      exit 1
      ;;
  esac
done

if [ -n "$namespace" ] || [ -n "$pod" ] || [ -n "$cluster" ]; then
  pod_query_parts=()
  [ -n "$namespace" ] && pod_query_parts+=("kube_namespace:${namespace}")
  [ -n "$pod" ] && pod_query_parts+=("pod_name:${pod}")
  [ -n "$cluster" ] && pod_query_parts+=("cluster_name:${cluster}")
  pod_query="$(IFS=' '; echo "${pod_query_parts[*]}")"

  if [ -n "$query" ]; then
    query="${query} ${pod_query}"
  else
    query="$pod_query"
  fi
fi

if [ -z "$query" ]; then
  echo "ERROR: provide either --query or pod selectors (--namespace/--pod)." >&2
  exit 1
fi

encoded_query="$(jq -rn --arg v "$query" '$v|@uri')"
echo "https://app.${datadog_site}/logs?query=${encoded_query}"
