---
name: model-info-finder
description: Top-level model diagnostics router. Use when a request spans model lookup, checkpoint inspection, CI/debug, or observability and you need to choose/compose the right lower-level model and observability skills.
---

# Model Info Finder (Skill Tree Router)

This skill is the top node in a skill tree.

## Foundation Skills (Base Layer)

- `$model-catalogue-core`: model id and checkpoint primitives.
- `$obs-buildkite-jobs`: Buildkite job log fetch + failure extraction.
- `$obs-flyte-execution`: Flyte execution status + step logs.
- `$obs-datadog-logs`: Datadog logs URL construction.

## Composite Model Skills (Middle Layer)

- Use `$model-lookup-basic` for nickname/author discovery.
- Use `$model-deep-summary` for one-model metadata (commit/licenses).
- Use `$model-checkpoint-inspector` for checkpoint licenses/runs.
- Use `$modelci-shadowgym-debug` for ModelCI, Buildkite, Eval Studio, Shadow Gym troubleshooting.

## Routing Examples

Use one composite skill when the request is narrow:

- "Find model by nickname" -> `$model-lookup-basic`
- "Show licenses/runs for checkpoint" -> `$model-checkpoint-inspector`

Compose skills when request crosses domains:

- "Model CI failed and I need job logs + Flyte status" ->
  `$modelci-shadowgym-debug` + `$obs-flyte-execution`
- "Give me Datadog link for this failing pod from CI run" ->
  `$obs-buildkite-jobs` + `$obs-datadog-logs`

## Backward Compatibility

Legacy scripts remain in this folder, but prefer routed skills:
- `lookup_by_nickname.sh`
- `lookup_by_author.sh`
- `deep_model_summary.sh`
- `checkpoint_licenses.sh`
- `checkpoint_runs.sh`
- `modelci_evalstudio_shadowgym.sh`
- `model_catalogue_api_helpers.sh`

Prefer the focused skills for new work.
