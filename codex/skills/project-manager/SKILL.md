---
name: project-manager
description: Manage Codex projects in the Obsidian vault (create/list/switch/continue/status/summary) using vault-stored Markdown docs and a registry.
metadata:
  short-description: Vault-based project management
---

# Project Manager (Vault)

Use this skill whenever the user wants to create, switch, continue, list, or summarize projects that live in the Obsidian vault.

## Source of truth
- Template + workflow source: `/home/borisindelman/downloads/claude_project_creator.md`
- Replace any GitHub tracker references with the vault registry + per-project status files.

## Storage layout (fixed)
- Registry root: `/home/borisindelman/git/vault/codex/WayveCode/projects/`
- Registry index: `/home/borisindelman/git/vault/codex/WayveCode/projects/projects.json`
- Active pointer: `/home/borisindelman/git/vault/codex/WayveCode/projects/active-project.txt`

Each project lives in:
`/home/borisindelman/git/vault/codex/WayveCode/projects/<slug>/`

## Registry format
`projects.json` contains:
```
{
  "projects": [
    {
      "name": "Human name",
      "slug": "human-name",
      "path": "/home/borisindelman/git/vault/codex/WayveCode/projects/human-name",
      "status": "active|paused|archived",
      "phase": "Phase 1|Phase 2|Phase 3|Phase 4",
      "last_updated": "YYYY-MM-DD"
    }
  ]
}
```

`active-project.txt` contains a single slug line (no quotes).

## Commands (natural language or slash prompts)
- Create: “create project <name>” / “init project <name>”
- List: “list projects”
- Switch: “switch to <name>” / “set active project <name>”
- Continue: “continue <name>” / “continue active project”
- Status: “project status <name>” / “projects status”
- Summary: “project summary <name>”

## Workflow

### Create project
1. Ask discovery questions from the source doc (problem, users, integrations, constraints, success criteria).
2. Slugify project name (lowercase, dashes, ASCII).
3. Create project folder and scaffold files from templates in `assets/templates/`.
4. Populate `PROJECT_INSTRUCTIONS.md` last, using the doc’s template but adapted to vault registry (no GitHub).
5. Add entry to `projects.json` and set `active-project.txt`.

### Continue project
1. Resolve project by name or `active-project.txt`.
2. Read `PROJECT_INSTRUCTIONS.md`, `STATUS.md`, and `RUN.md` if present.
3. Summarize current phase, priorities, blockers, and ask next action.

### Status / Summary
- **Status**: phase + blockers + last_updated + next priorities.
- **Summary**: high-level overview + current phase + priorities.

## Templates
Use templates from:
`/home/borisindelman/.codex/skills/project-manager/assets/templates/`

Template files:
- `PROJECT_OVERVIEW.md`
- `TECHNICAL_ARCHITECTURE.md`
- `DATABASE_SCHEMA.md`
- `API_INTEGRATIONS.md`
- `UI_SPECIFICATIONS.md`
- `BUILD_PHASES.md`
- `DEBUGGING_GUIDE.md`
- `PROJECT_INSTRUCTIONS.md`
- `STATUS.md`
- `RUN.md`

Only edit content relevant to the current project; keep files concise and Obsidian-friendly.
