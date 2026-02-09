# AGENTS.MD

Boris owns this.

## Agent Protocol
- Contact: Boris Indleman (@boris, boris.indelman@wayve.ai).
- Workspace: '/workspace/WayveCode'
- PRs: use `gh pr view/diff` (no URLs).
- Need upstream file: stage in `/tmp/`, then cherry-pick; never overwrite tracked.
- Bugs: add regression test when it fits.
- Keep files <~500 LOC; split/refactor as needed.
- Commits: Conventional Commits (`feat|fix|refactor|build|ci|chore|docs|style|perf|test`).
- Subagents: read `docs/subagent.md`.
- Editor: `cursor <path>`.
- Slash cmds: `~/.codex/prompts/`.
- Web: search early; quote exact errors; prefer 2024–2025 sources; fallback Firecrawl (`pnpm mcp:*`) / `mcporter`.
- Task progress: document in the vault for significant/code tasks only (see "When to log").
- Todo / task list: keep under the vault.
- Avoid using code fallbacks to cruteforce solutsion, like using try catch statements. Notify user if used.
- ExecPlans: When writing complex features or significant refactors, use an ExecPlan (as described in ~/.codex/PLANS.md) from design to implementation.

## Important Locations
- Obsidian vault: `~/git/vault`

## PR Feedback
- Active PR: `gh pr view --json number,title,url --jq '"PR #\\(.number): \\(.title)\\n\\(.url)"'`.
- PR comments: `gh pr view …` + `gh api …/comments --paginate`.
- Replies: cite fix + file/line; resolve threads only after fix lands.

## Flow & Runtime
- Use bazel from workspace dir; no swaps w/o approval.
- Use Codex background for long jobs; tmux only for interactive/persistent (debugger/server).


## Git
- Safe by default: `git status/diff/log`. Push only when user asks.
- `git checkout` ok for PR review / explicit request.
- Branch changes require user consent.
- Destructive ops forbidden unless explicit (`reset --hard`, `clean`, `restore`, `rm`, …).
- Don’t delete/rename unexpected stuff; stop + ask.
- No repo-wide S/R scripts; keep edits small/reviewable.
- Avoid manual `git stash`; if Git auto-stashes during pull/rebase, that’s fine (hint, not hard guardrail).
- If user types a command (“pull and push”), that’s consent for that command.
- No amend unless asked.
- Big review: `git --no-pager diff --color=never`.
- Multi-agent: check `git status/diff` before edits; ship small commits.


## Critical Thinking
- Fix root cause (not band-aid).
- Unsure: read more code; if still stuck, ask w/ short options.
- Conflicts: call out; pick safer path.
- Unrecognized changes: assume other agent; keep going; focus your changes. If it causes issues, stop + ask user.
- Leave breadcrumb notes in thread.

## Tools
### gh
- GitHub CLI for PRs/CI/releases. Given issue/PR URL (or `/pull/5`): use `gh`, not web search.
- Examples: `gh issue view <url> --comments -R owner/repo`, `gh pr view <url> --comments --files -R owner/repo`.


### tmux
- Use only when you need persistence/interaction (debugger/server).
- Quick refs: `tmux new -d -s codex-shell`, `tmux attach -t codex-shell`, `tmux list-sessions`, `tmux kill-session -t codex-shell`.

## Codex Vault Instructions

### Vault location
- Root: `~/git/vault`
- Codex notes: `~/git/vault/codex/WayveCode/`

### When to log
- Log only for significant tasks: code/content changes, non-trivial implementations/refactors/designs, running build/test/CI, or executing an ExecPlan.
- Do not log for simple questions/definitions, quick examples, or one-off command explanations.
- If unsure, ask: "Log this task?"

### Structure & naming
- Organize notes by month and week:
  - `YYYY/MM/Week-N/`
- File names must begin with the date:
  - `YYYY-MM-DD-<short-title>.md`

Example:
- `2025/12/Week-5/2025-12-29-release-bc-model-summary.md`

### Change log
- Main log: `~/git/vault/codex/WayveCode/agents-change-log.md`
- Every task summary must be linked from the change log.
- Change log entries should include:
  - Topic
  - Labels
  - Branch
  - PR
  - Change type
  - Areas
  - Changes (bulleted)

### Obsidian formatting
- Use Obsidian callouts for collapsible month sections.
- Table of contents should link to month headings using markdown anchors.

### Todo list
- location: Main log: `~/git/vault/codex/WayveCode/todo-list.md`
- store as bulletpoints
- clear task after finished

### Project Writeups
- Store project writeups in the vault, separate from the main logs.
- Place `how_to_[topic].md` files under `~/git/vault/codex/WayveCode/how_to/`.
- For every project, write a detailed `how_to_[topic].md` file that explains the whole project in plain language.
- Explain the technical architecture, the structure of the codebase and how the various parts are connected, the technologies used, why we made these technical decisions, and lessons I can learn from it (this should include the bugs we ran into and how we fixed them, potential pitfalls and how to avoid them in the future, new technologies used, how good engineers think and work, best practices, etc).
- It should be very engaging to read; don't make it sound like boring technical documentation/textbook. Where appropriate, use analogies and anecdotes to make it more understandable and memorable.
- Create a dedicated index page (table of contents) that links all project writeups and reads like a book with chapters on different topics to learn about our code.

<frontend_aesthetics>
Avoid “AI slop” UI. Be opinionated + distinctive.

Do:
- Typography: pick a real font; avoid Inter/Roboto/Arial/system defaults.
- Theme: commit to a palette; use CSS vars; bold accents > timid gradients.
- Motion: 1–2 high-impact moments (staggered reveal beats random micro-anim).
- Background: add depth (gradients/patterns), not flat default.

Avoid: purple-on-white clichés, generic component grids, predictable layouts.
</frontend_aesthetics>
