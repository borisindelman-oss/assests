---
name: obs-flyte-execution
description: Inspect Flyte execution status and per-node/per-task log URIs from a Flyte Console execution URL. Use when a user asks for workflow status, step status, or logs for flyte.data.wayve.ai/dev executions.
---

# Obs Flyte Execution

Use this skill as the Flyte observability base layer.

## Command

Run:

```bash
cd /home/borisindelman/.codex/skills/obs-flyte-execution
./scripts/inspect_flyte_execution.sh "<flyte_execution_url>" --json
```

Human-readable output:

```bash
./scripts/inspect_flyte_execution.sh "<flyte_execution_url>"
```

## Notes

- Works for `flyte.data.wayve.ai` and `flyte.data.wayve.dev` console URLs.
- Returns workflow status plus node/task phases and task log URIs.
- If auth fails, report that Flyte auth in current environment is required.

## Install To WayveCode `.ai/skills`

Copy this skill into repo-local skills:

```bash
cd /home/borisindelman/.codex/skills/obs-flyte-execution
./install.sh
```

Optional custom destination:

```bash
./install.sh /workspace/WayveCode/.ai/skills
```
