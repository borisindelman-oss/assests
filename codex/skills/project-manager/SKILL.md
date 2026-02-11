---
name: project-manager
description: Manage Codex projects in the Obsidian vault (create/list/switch/continue/status/summary) using a single Markdown file per project plus a registry.
metadata:
  short-description: Vault-based project management
---

# Project Manager (Vault)

Use this skill whenever the user wants to create, switch, continue, list, or summarize projects that live in the Obsidian vault.

## Source of truth
- Template + workflow source: `/home/borisindelman/downloads/claude_project_creator.md`
- Replace any GitHub tracker references with the vault registry + per-project status section.
- The project template is intentionally minimal; keep sections to Overview, Status, Requirements, Design, Build Phases, Decisions, Notes.

## Storage layout (fixed)
- Registry root: `/home/borisindelman/git/vault/WayveCode/projects/`
- Registry index: `/home/borisindelman/git/vault/WayveCode/projects/projects.json`
- Active pointer: `/home/borisindelman/git/vault/WayveCode/projects/active-project.txt`
- Projects index (human-friendly): `/home/borisindelman/git/vault/WayveCode/projects.md`

Each project lives in a single file:
`/home/borisindelman/git/vault/WayveCode/projects/<slug>.md`

## Registry format
`projects.json` contains:
```
{
  "projects": [
    {
      "name": "Human name",
      "slug": "human-name",
      "path": "/home/borisindelman/git/vault/WayveCode/projects/human-name.md",
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
3. Create project file `<slug>.md` from the template in `assets/templates/project.md`.
4. Populate the Overview, Status, and Requirements sections with initial answers.
5. Add entry to `projects.json` and set `active-project.txt`.
6. Update `projects.md` with a row for the project and put the link on the project name using Markdown link syntax to avoid table pipe issues: `[Project Name](WayveCode/projects/<slug>)`.

### Continue project
1. Resolve project by name or `active-project.txt`.
2. Read `<slug>.md`.
3. Summarize current phase, priorities, blockers, and ask next action.

### Status / Summary
- **Status**: phase + blockers + last_updated + next priorities (from Status section).
- **Summary**: high-level overview + current phase + priorities.

## Template
Use the single-file template:
`/home/borisindelman/.codex/skills/project-manager/assets/templates/project.md`

Only one project file (`<slug>.md`) is kept per project; legacy template fragments were removed to keep the skill minimal.

Keep the file Obsidian-friendly, concise, and updated per session. Do not reintroduce the removed sections (Quality Checklist, Runbook, UI specs, etc.).
