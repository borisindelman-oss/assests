---
name: obs-datadog-logs
description: Build Datadog Logs Explorer URLs from a raw query or Kubernetes pod/namespace filters. Use when a user asks for Datadog log links scoped to execution, pod, or service failures.
---

# Obs Datadog Logs

Use this as the Datadog observability base layer.

## Setup

```bash
export DATADOG_SITE="${DATADOG_SITE:-datadoghq.eu}"
```

## Commands

Build a link from a direct query:

```bash
cd /home/borisindelman/.codex/skills/obs-datadog-logs
./scripts/build_datadog_logs_url.sh --query 'service:model-ci status:error'
```

Build a pod-scoped link:

```bash
./scripts/build_datadog_logs_url.sh --namespace <k8s_namespace> --pod <pod_name> [--cluster <cluster_name>]
```

## Notes

- Returns a Datadog Logs Explorer URL to share/open directly.
- Combine `--query` with pod fields when both free-text and strict selectors are needed.
