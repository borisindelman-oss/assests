---
name: flyte-status-logs
description: Inspect a Flyte execution from its console URL and return workflow status plus task log URIs. Use when a user shares a Flyte execution URL (flyte.data.wayve.ai or flyte.data.wayve.dev) and asks for failure status, node-level state, or logs.
---

# Flyte Status + Logs

Use this skill when the user provides a Flyte execution URL and wants status/log details.
For new workflows, prefer the foundational `$obs-flyte-execution` skill (this skill is kept as a compatibility alias).

## Command

Run:

```bash
/workspace/WayveCode/.ai/skills/flyte-status-logs/scripts/inspect_flyte_status_logs.sh "<flyte_execution_url>" --json
```

Text output (human-readable):

```bash
/workspace/WayveCode/.ai/skills/flyte-status-logs/scripts/inspect_flyte_status_logs.sh "<flyte_execution_url>"
```

## What It Uses In Code

- URL parsing and execution lookup: `wayve/prototypes/robotics/vehicle_dynamics/common/flyte/inspect.py`
- Recursive node/task execution traversal: `wayve/services/data/pipelines/flyte/common/flyte_remote.py`
- Task log URI extraction CLI: `wayve/prototypes/robotics/vehicle_dynamics/tools/flyte_status_logs/inspect_execution_logs_cli.py`

## Notes

- This returns Flyte task log URIs and workflow/node/task phases.
- If no log URIs are present, report that explicitly.
- If auth fails, tell the user they need valid Flyte auth in the current environment.
- Prefer `--json` when you need to post-process or summarize failures programmatically.
- For common failures, see `references/troubleshooting.md`.
