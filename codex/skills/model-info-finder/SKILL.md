---
name: model-info-finder
description: Route model-catalogue questions to focused model skills. Use when a request is model-related but ambiguous about whether it needs lookup, deep summary, checkpoint inspection, or ModelCI/Shadow Gym debugging.
---

# Model Info Finder (Router)

This skill now acts as a router to focused skills.

## Choose the focused skill

- Use `$model-lookup-basic` for nickname/author discovery.
- Use `$model-deep-summary` for one-model metadata (commit/licenses).
- Use `$model-checkpoint-inspector` for checkpoint licenses/runs.
- Use `$modelci-shadowgym-debug` for ModelCI, Buildkite, Eval Studio, Shadow Gym troubleshooting.

## Backward compatibility

Legacy scripts remain in this folder for compatibility:
- `lookup_by_nickname.sh`
- `lookup_by_author.sh`
- `deep_model_summary.sh`
- `checkpoint_licenses.sh`
- `checkpoint_runs.sh`
- `modelci_evalstudio_shadowgym.sh`
- `model_catalogue_api_helpers.sh`

Prefer the focused skills for new work.
