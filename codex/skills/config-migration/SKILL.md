---
name: config-migration
description: Resolve BC/RL config migration conflicts and add new migrations by bumping versions, updating migrate_to_v* methods/maps, regenerating sample snapshots, and validating tests.
---

# Config Migration

Use this skill when:
- a merge/rebase causes migration version conflicts in BC or RL, or
- you changed config schema and need to add a new migration method/version.

## Goal

When two branches both add migration version `vN`, do not force-merge into the same `vN`.

Resolve by:
1. Bumping your branch to `vN+1`
2. Moving your migration logic from `migrate_to_vN` to `migrate_to_vN_plus_1`
3. Updating migration dict mapping to the new version
4. Accepting incoming existing sample snapshot(s)
5. Generating a new sample snapshot for the new version
6. Updating reference configs and migration tests

## Paths

### BC

- Version source of truth:
  - `wayve/ai/si/config.py` (`bc_version.version_number`)
- Migration file:
  - `wayve/ai/si/configs/versioning/bc_migrations.py`
  - function map: `BC_CONFIG_MIGRATION_FUNCTIONS`
- Sample snapshots:
  - `wayve/ai/si/test/data/sample_configs/bc/v*.yaml`
- Reference configs:
  - `wayve/ai/si/test/test_config_inputs/reference_bc.yaml`
  - `wayve/ai/si/test/test_config_inputs/reference_bc_alpha2.yaml`
- Migration tests:
  - `wayve/ai/si/test/configs/test_bc_migrations.py`

### RL

- Version source of truth:
  - `wayve/ai/si/configs/store/offline_rl.py` (`rl_config_version.version_number`)
- Migration file:
  - `wayve/ai/si/configs/versioning/rl_migrations.py`
  - function map: `RL_CONFIG_MIGRATION_FUNCTIONS`
- Sample snapshots:
  - `wayve/ai/si/test/data/sample_configs/rl/v*.yaml`
- Reference configs:
  - `wayve/ai/si/test/test_config_inputs/reference_rl.yaml`
  - `wayve/ai/si/test/test_config_inputs/reference_rl_alpha2.yaml`
- Migration tests:
  - `wayve/ai/si/test/configs/test_rl_migrations.py`

## Conflict Resolution Workflow

### 1) Determine incoming highest version

Check current version in source-of-truth file and migration map.

### 2) Bump version number

- BC: bump `bc_version.version_number` in `wayve/ai/si/config.py`
- RL: bump `rl_config_version.version_number` in `wayve/ai/si/configs/store/offline_rl.py`

### 3) Renumber migration function

If your logic was in `migrate_to_vN` and incoming already uses `vN`:
- Keep incoming `migrate_to_vN`
- Move your logic to `migrate_to_vN_plus_1`
- Update mapping dict (`...MIGRATION_FUNCTIONS`) to point new version to your new function

### 4) Accept incoming sample config for existing versions

For conflicted existing snapshots (e.g. `vN.yaml`): accept incoming.

Rule: do not rewrite historical incoming snapshots during conflict resolution.

### 5) Generate new sample config for your new version

- BC:
  - `bazel run //wayve/ai/si/scripts:dump_sample_cfg_for_migration_checks -- --training_stage=bc`
- RL:
  - `bazel run //wayve/ai/si/scripts:dump_sample_cfg_for_migration_checks -- --training_stage=rl`

This writes:
- `wayve/ai/si/test/data/sample_configs/bc/v<new>.yaml` or
- `wayve/ai/si/test/data/sample_configs/rl/v<new>.yaml`

### 6) Update reference config version fields

Update only top-level stage version field to the new version:
- BC refs:
  - `reference_bc.yaml`
  - `reference_bc_alpha2.yaml`
- RL refs:
  - `reference_rl.yaml`
  - `reference_rl_alpha2.yaml`

### 7) Update migration tests if function names changed

Important BC vs RL difference:
- BC tests mostly validate through `migrate_bc_config_to_latest`; function-specific renumber changes are rare.
- RL tests may import specific functions (e.g. `migrate_to_v20`) in `test_rl_migrations.py`; if you renumber, update imports/test names accordingly.

## Validation

Run targeted validation first:

- BC:
  - `bazel test //wayve/ai/si:test_config_py_test --test_output=errors --test_arg='-k=bc_migrations'`
- RL:
  - `bazel test //wayve/ai/si:test_config_py_test --test_output=errors --test_arg='-k=rl_migrations'`

Then full config checks:
- `bazel test //wayve/ai/si:test_config --test_output=errors`

## New Migration Workflow (No Existing `migrate_to_v*` Yet)

Use this when you made a config-schema change and need to add a fresh migration.

### 1) Pick the next version

- Read current version from source-of-truth:
  - BC: `wayve/ai/si/config.py` (`bc_version.version_number`)
  - RL: `wayve/ai/si/configs/store/offline_rl.py` (`rl_config_version.version_number`)
- New version is `current + 1`.

### 2) Bump version source of truth

- BC: update `bc_version.version_number`
- RL: update `rl_config_version.version_number`

### 3) Add a new migration method

- BC file: `wayve/ai/si/configs/versioning/bc_migrations.py`
- RL file: `wayve/ai/si/configs/versioning/rl_migrations.py`

Add:
- `def migrate_to_v<new>(config: <CfgType>) -> <CfgType>:`
- Implement schema transition for your new fields/renames/removals.
- Return migrated config.

Template:

```python
def migrate_to_v23(config: RLCfg) -> RLCfg:
    # Example: add default for a new field if missing.
    if config.some_block.new_field is None:
        config.some_block.new_field = "default_value"
    return config
```

### 4) Register it in migration map

- BC: add entry to `BC_CONFIG_MIGRATION_FUNCTIONS`
- RL: add entry to `RL_CONFIG_MIGRATION_FUNCTIONS`

Example:

```python
RL_CONFIG_MIGRATION_FUNCTIONS = {
    ...
    23: migrate_to_v23,
}
```

### 5) Regenerate sample snapshot for new version

- BC:
  - `bazel run //wayve/ai/si/scripts:dump_sample_cfg_for_migration_checks -- --training_stage=bc`
- RL:
  - `bazel run //wayve/ai/si/scripts:dump_sample_cfg_for_migration_checks -- --training_stage=rl`

### 6) Update reference configs

Bump top-level version field in:
- BC: `reference_bc.yaml`, `reference_bc_alpha2.yaml`
- RL: `reference_rl.yaml`, `reference_rl_alpha2.yaml`

### 7) Update migration tests

- If tests import/version-pin specific methods (common in RL), update imports and expected version/method references.
- Run stage-specific migration tests, then full config tests.

## Common Mistakes

- Keeping your new logic in a version number already claimed by incoming.
- Modifying old incoming snapshot (`vN.yaml`) instead of adding `vN+1.yaml`.
- Forgetting to update reference config version fields.
- For RL: forgetting to update function-specific imports/tests in `test_rl_migrations.py` after renumbering.
- Adding new config fields but forgetting to create/register a new `migrate_to_v*` method.

## Quick Checklist

- [ ] Version bumped in source-of-truth file
- [ ] Migration function renumbered
- [ ] Migration dict updated
- [ ] Incoming old snapshots accepted
- [ ] New snapshot generated (`v<new>.yaml`)
- [ ] Reference files bumped to new version
- [ ] Stage-specific migration tests pass
