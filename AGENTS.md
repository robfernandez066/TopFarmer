# TopFarmer Agent Routing

TopFarmer is a mobile-first, portrait, direct-touch 2D farming simulation in Godot 4.7.1, with an angled top-down cozy-fantasy presentation and a quiet undercurrent of mystery; the PM Agent owns planning and balance data, while the Coder Agent implements exactly one approved task at a time.

If you are the PM Agent: read MD Docs/PM-Rules.md. Do not read Coder-Rules.md. Do not write game code.
If you are the Coder Agent: read MD Docs/Coder-Rules.md and MD Docs/project-context.md. Do not read PM-Rules.md. Do not edit Roadmap.md, tasklist.md, decisions.md, completedtasks.md, or anything in /data/.

| File or area | PM reads | PM writes | Coder reads | Coder writes |
|---|---:|---:|---:|---:|
| `AGENTS.md` | Yes | Yes | Yes | No |
| `MD Docs/AGENTS-ROUTING.md` | Yes | Yes | Yes | No |
| `MD Docs/Roadmap.md` | Yes | Once only | Yes | No |
| `MD Docs/PM-Rules.md` | Yes | Yes | No | No |
| `MD Docs/Coder-Rules.md` | Setup only | Setup only | Yes | No |
| `MD Docs/project-context.md` | Yes | Yes | Yes | No |
| `MD Docs/decisions.md` | Yes | Append only | Yes | No |
| `MD Docs/tasklist.md` | Yes | Yes | Yes | No |
| `MD Docs/completedtasks.md` | Yes | Append only | Yes | No |
| `MD Docs/progress.md` | Yes | Setup only | Yes | Append only |
| `/data/balance.xlsx`, `/data/*.csv`, balance scripts | Yes | PM only | Yes | No |
| `project.godot`, `.gitignore`, and other project configuration | No | No | Yes | Coder only within active task |
| Game code, scenes, tests, localization, runtime assets | No | No | Yes | Coder only within active task |

This repository is already cloned from `https://github.com/robfernandez066/TopFarmer.git`; `main` exists locally and remotely, credentials are cached, and pushes work. The Godot 4.7.1 project already exists at the root with Compatibility rendering and portrait orientation. Matching Windows x86_64 and Android export templates are installed. `/data` already contains the tracked v0 workbook, seven CSVs, seven keep-import files, and three balance scripts. A red X on those CSVs is correct. `.gitignore` covers `.godot/`, `/android/`, `export_presets.cfg`, `*.translation`, and OS junk. Never initialize, clone, or recreate this project.

## Godot Human-Check Configuration Churn

When the human explicitly says they opened or ran Godot for a Human check and the next Coder session finds `project.godot` as the only dirty file, inspecting that diff is pre-authorized. Do not stop to ask permission merely to inspect it.

- If the diff only reorders an existing key with the identical value, changes whitespace, or otherwise makes no semantic setting change, normalize just that text back to the committed form, verify that `project.godot` is clean, mention the cleanup in the Coder report, and continue the active task.
- If every semantic change is expressly authorized by the active task and has the exact required value, preserve it, include it in that task's commit when required, and continue.
- Stop and request direction only when a setting value changes outside the active task, an authorized value is wrong, additional files are unexpectedly dirty, or normalizing the file would discard a meaningful human change.
- Never use this exception to discard gameplay, balance, import, renderer, main-scene, autoload, input, export, or signing changes. Always report the inspected keys and the action taken.
