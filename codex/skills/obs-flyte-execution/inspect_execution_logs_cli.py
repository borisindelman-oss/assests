"""CLI to inspect Flyte execution status and task log URIs from a console URL."""

from __future__ import annotations

import argparse
import json
from typing import Any

from flytekit.models.core.execution import NodeExecutionPhase, TaskExecutionPhase, WorkflowExecutionPhase

from wayve.prototypes.robotics.vehicle_dynamics.common.flyte.inspect import parse_flyte_console_url
from wayve.services.data.pipelines.flyte.common.flyte_remote import (
    get_flyte_remote,
    read_node_execution_info_recursively,
)


def _phase_to_string(phase: Any, enum_cls: type) -> str:
    """Convert a Flyte phase enum to string safely."""
    try:
        return enum_cls.enum_to_string(phase)
    except Exception:
        return str(phase)


def collect_execution_status_and_logs(
    flyte_execution_url: str,
    max_launchplan_depth: int,
    max_node_depth: int | None,
    include_successful_task_logs: bool,
) -> dict[str, Any]:
    parsed = parse_flyte_console_url(flyte_execution_url)
    if parsed is None:
        raise ValueError(f"Invalid Flyte execution URL: {flyte_execution_url}")

    remote = get_flyte_remote(
        project=parsed["project"],
        env=parsed["env"],
        domain=parsed["domain"],
    )
    execution = remote.fetch_execution(name=parsed["name"])
    workflow_phase = _phase_to_string(execution.closure.phase, WorkflowExecutionPhase)
    workflow_error = execution.closure.error.message if execution.closure.error else None

    node_reports: list[dict[str, Any]] = []
    for node_info, launchplan_depth, node_depth in read_node_execution_info_recursively(
        remote=remote,
        workflow_execution_identifier=execution.id,
        max_node_depth=max_node_depth,
        max_launchplan_depth=max_launchplan_depth,
        fetch_task_executions=True,
    ):
        node_execution = node_info.node_execution
        node_phase = (
            _phase_to_string(node_execution.closure.phase, NodeExecutionPhase) if node_execution is not None else "UNKNOWN"
        )

        attempts: list[dict[str, Any]] = []
        for task_execution in node_info.task_executions or ():
            task_phase = _phase_to_string(task_execution.closure.phase, TaskExecutionPhase)
            if not include_successful_task_logs and task_phase == "SUCCEEDED":
                continue

            logs = []
            for log in task_execution.closure.logs or []:
                uri = getattr(log, "uri", None)
                if not uri:
                    continue
                logs.append({"name": getattr(log, "name", ""), "uri": uri})

            if not logs:
                continue

            attempts.append(
                {
                    "task_id": task_execution.id.task_id.name,
                    "retry_attempt": task_execution.id.retry_attempt,
                    "phase": task_phase,
                    "logs": logs,
                }
            )

        if not attempts:
            continue

        node_reports.append(
            {
                "spec_id": node_info.spec_id,
                "phase": node_phase,
                "node_depth": node_depth,
                "launchplan_depth": launchplan_depth,
                "attempts": attempts,
            }
        )

    return {
        "execution_url": remote.generate_console_url(execution),
        "project": parsed["project"],
        "domain": parsed["domain"],
        "execution_name": parsed["name"],
        "workflow_phase": workflow_phase,
        "workflow_error": workflow_error,
        "nodes_with_logs": len(node_reports),
        "node_reports": node_reports,
    }


def _print_text_report(report: dict[str, Any]) -> None:
    print(f"Execution URL: {report['execution_url']}")
    print(f"Project/Domain: {report['project']}/{report['domain']}")
    print(f"Execution Name: {report['execution_name']}")
    print(f"Workflow Phase: {report['workflow_phase']}")
    if report["workflow_error"]:
        print(f"Workflow Error: {report['workflow_error']}")
    print(f"Nodes with log URIs: {report['nodes_with_logs']}")

    if not report["node_reports"]:
        print("No task execution log URIs found for this execution.")
        return

    for node in report["node_reports"]:
        print(
            f"\nNode {node['spec_id']} (phase={node['phase']}, "
            f"node_depth={node['node_depth']}, launchplan_depth={node['launchplan_depth']})"
        )
        for attempt in node["attempts"]:
            print(
                f"  Attempt retry={attempt['retry_attempt']} "
                f"phase={attempt['phase']} task_id={attempt['task_id']}"
            )
            for log in attempt["logs"]:
                print(f"    - {log['name']}: {log['uri']}")


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Read Flyte execution status and task log URIs from a Flyte console execution URL."
    )
    parser.add_argument("flyte_execution_url", help="Flyte console URL for an execution.")
    parser.add_argument(
        "--max-launchplan-depth",
        type=int,
        default=3,
        help="Maximum nested launchplan depth to inspect. Default: 3.",
    )
    parser.add_argument(
        "--max-node-depth",
        type=int,
        default=None,
        help="Maximum dynamic node depth to inspect. Default: unlimited.",
    )
    parser.add_argument(
        "--include-successful-task-logs",
        action="store_true",
        help="Include task execution logs from successful task attempts.",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Print JSON instead of text.",
    )
    return parser.parse_args()


def main() -> int:
    args = _parse_args()
    report = collect_execution_status_and_logs(
        flyte_execution_url=args.flyte_execution_url,
        max_launchplan_depth=args.max_launchplan_depth,
        max_node_depth=args.max_node_depth,
        include_successful_task_logs=args.include_successful_task_logs,
    )

    if args.json:
        print(json.dumps(report, indent=2, sort_keys=True))
    else:
        _print_text_report(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
