# Troubleshooting

## Invalid URL

Use full execution URLs with this pattern:

- `https://flyte.data.wayve.ai/console/projects/<project>/domains/<domain>/executions/<name>`
- `https://flyte.data.wayve.dev/console/projects/<project>/domains/<domain>/executions/<name>`

## Auth errors

The CLI uses FlyteRemote auth config from `get_flyte_remote`.
If auth fails, re-authenticate in the local environment before retrying.

## No logs returned

If execution/task metadata has no `closure.logs` entries, the tool will return status without log URIs.
Use `--include-successful-task-logs` to include logs from successful attempts too.
