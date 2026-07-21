# Agent Routing Reference

`/AGENTS.md` is the authoritative auto-loaded routing file. This document explains the same ownership model for humans and future sessions; it does not override `/AGENTS.md`.

## PM Agent Route

Read `PM-Rules.md`, `project-context.md`, `progress.md`, `Roadmap.md`, `decisions.md`, `tasklist.md`, and `completedtasks.md`. Own prioritization, acceptance criteria, decisions, and `/data`. Never write game code. Do not consult `Coder-Rules.md` during normal PM loops.

## Coder Agent Route

Read `Coder-Rules.md`, `project-context.md`, `tasklist.md`, `decisions.md`, `Roadmap.md`, and `completedtasks.md`. Implement only the single active task. Write game implementation files only when named or necessarily implied by that task, and append status to `progress.md`. Never edit PM-owned documents or `/data`.

## Ownership Map

| Artifact | Reader(s) | Writer | Mutation rule |
|---|---|---|---|
| `/AGENTS.md` | Both | PM | Keep concise and routing-only |
| `Roadmap.md` | Both | PM at setup | Immutable after first write |
| `PM-Rules.md` | PM | PM | PM operating contract |
| `Coder-Rules.md` | Coder | PM at setup | Coder operating contract |
| `project-context.md` | Both | PM | Shared technical decisions |
| `decisions.md` | Both | PM | Append-only, one decision per line |
| `tasklist.md` | Both | PM | Exactly one active task |
| `completedtasks.md` | Both | PM | Append-only after verified completion |
| `progress.md` | Both | Coder | Append-only; PM never edits after setup |
| `/data` | Both | PM | Balance workbook is authoritative; CSVs are exports |
| Runtime code/scenes/tests/assets | Coder | Coder | Only within the active task |

## Session Safety

Only one agent operates in the shared working folder at a time. Both agents begin with `git status`. Unknown changes stop the session. The PM closes a completed task by appending it to `completedtasks.md`, verifying the append, and only then clearing/replacing `tasklist.md`. The Coder commits directly to `main`, pushes, and records the result in `progress.md` before stopping.

One narrow exception applies after the human explicitly opens or runs Godot for a Human check: when `project.godot` is the only dirty file, the Coder inspects it without asking again. Non-semantic key reordering or whitespace churn is normalized to the committed form and reported; exact active-task-authorized settings are preserved. Any out-of-scope semantic value change or additional dirty file still stops the session.
