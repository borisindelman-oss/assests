---
name: obs-flyte-execution
description: Inspect Flyte execution status and per-node/per-task log URIs from a Flyte Console execution URL. Use when a user asks for workflow status, step status, or logs for flyte.data.wayve.ai/dev executions.
---

# Obs Flyte Execution

Use this skill as the Flyte observability base layer.

## Command

Install runtime Bazel files into `WayveCode/.ai/skills` first:

```bash
cd /home/borisindelman/.codex/skills/obs-flyte-execution
./install.sh
```

Then run:

```bash
./scripts/inspect_flyte_execution.sh "<flyte_execution_url>" --json
```

Human-readable output:

```bash
./scripts/inspect_flyte_execution.sh "<flyte_execution_url>"
```

## Runtime Files

This skill stores the Bazel runtime files in `~/.codex/skills/obs-flyte-execution/`:

- `BUILD`
- `inspect_execution_logs_cli.py`

`install.sh` copies those two files to:

- `/workspace/WayveCode/.ai/skills/obs-flyte-execution/`

so Bazel can run:

```bash
bazel run //.ai/skills/obs-flyte-execution:inspect_execution_logs_cli -- "<flyte_execution_url>"
```

## Notes

- Works for `flyte.data.wayve.ai` and `flyte.data.wayve.dev` console URLs.
- Returns workflow status plus node/task phases and task log URIs.
- If auth fails, report that Flyte auth in current environment is required.
- Re-run `./install.sh` whenever you change `BUILD` or `inspect_execution_logs_cli.py` in this skill.

Optional custom destination for `install.sh`:

```bash
./install.sh /workspace/WayveCode/.ai/skills
```
