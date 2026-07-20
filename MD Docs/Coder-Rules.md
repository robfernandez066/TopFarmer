# Coder Agent Rules

## Role

Implement exactly the one active task in `tasklist.md`. Nothing else. Do not refactor adjacent code, implement anticipated future tasks, or fix unrelated bugs. Record unrelated findings in `progress.md`.

## Before Starting

Run `git status`. If there are uncommitted changes you did not make, STOP and report them. Both agents share one working folder; unknown changes mean concurrent work or an unknown repository state.

## Reading the Task

Tasks use this structure:

```text
TASK-XXX: Checkable outcome title
Status: ready | in-progress | blocked | review
Complexity: routine | complex
Files: explicit repository paths
Acceptance:
- Observable criterion
Depends on: task ID or none
Notes: relevant DEC references and implementation constraints
```

The Complexity field is informational. A task is complex when it includes a system-wide architectural choice, a save-format change, timing or concurrency logic, or more than four touched files. If any acceptance criterion is ambiguous, stop rather than guess, append a `blocked` or `needs-decision` entry to `progress.md`, push that documentation update, and wait for the PM.

## Scope Discipline

- Implement only the active task and its acceptance criteria.
- Do not refactor adjacent code or implement future work.
- Do not fix unrelated bugs; report them in `progress.md`.
- Follow the naming, architecture, data, save, asset, and localization rules in `project-context.md`.
- No user-facing string may be hardcoded in a scene or script.
- No gameplay number may be hardcoded in code or scenes.

## Definition of Done

All conditions are required:

- The project builds.
- The game runs.
- Every acceptance criterion is demonstrably met.
- No hardcoded gameplay numbers were introduced.
- No user-facing strings were hardcoded.
- `progress.md` is updated.

## Data and Dependencies

`/data` is read-only. If a number is wrong or missing, request a PM change through `progress.md`; never edit a CSV, `.csv.import`, script, or workbook there. Adding any third-party addon or library requires PM approval. Request approval through `progress.md` and wait; do not add it first and mention it afterward.

`Roadmap.md`, `tasklist.md`, `decisions.md`, and `completedtasks.md` are read-only. `progress.md` is the only PM-document file you write.

## Git

Commit directly to `main`; do not create branches. Prefix commits with `TASK-XXX:`. Push before stopping. The agents share one folder and only one runs at a time, so branching adds overhead without benefit.

## Progress Log

Writing to `progress.md` is mandatory when you finish a task, become blocked, need a decision, or notice anything the PM should know. Append entries in this format and select exactly one status from `done`, `blocked`, or `needs-decision`:

```text
TASK-001 | 2026-07-21 | done | blocked | needs-decision

Files touched: res://data/loader.gd, res://autoload/balance.gd
Result: what was built, in two lines
Notes: anything the PM should know
Blocker: what is preventing progress, if applicable
```
