<!-- No Coder entries yet. The Coder appends entries in the format defined by Coder-Rules.md; the PM never edits this file after setup. -->

## TASK-001 | 2026-07-20 | done
Files touched: res://autoload/balance.gd, res://project.godot, res://tests/balance_loader_test.gd, res://MD Docs/progress.md
Result: Registered the Balance autoload, synchronously loaded and strictly validated all seven balance CSVs, and exposed read-only keyed queries for every required table. All acceptance criteria verified; `godot_console --headless --editor --path . --quit` and `godot_console --headless --path . --script res://tests/balance_loader_test.gd` both exit successfully, with the test ending in the required PASS line and no ERROR or FAIL output.
Notes: The project still has no main scene, so a generic project launch reports that pre-existing condition. TASK-001 does not authorize adding a scene; the task-specific headless script executes the project and Balance autoload successfully.
Notes continued: The required editor import generated res://autoload/balance.gd.uid and res://tests/balance_loader_test.gd.uid; both companion metadata files are committed with their scripts.

## TASK-002 | 2026-07-20 | done
Files touched: res://project.godot, res://scenes/main.tscn, res://scripts/main.gd, res://scripts/main.gd.uid, res://MD Docs/progress.md
Result: Set the minimal single-Node Main scene as the project boot target and attached a script that emits TOPFARMER_BOOT_OK exactly once. All acceptance criteria verified; `godot_console --headless --path . --quit-after 1` exits successfully with the required diagnostic and no ERROR or FAIL output, and the TASK-001 balance loader test still passes cleanly.
Notes: No UI, gameplay, placeholder art, user-facing text, gameplay numbers, renderer changes, orientation changes, or Balance autoload changes were introduced.

## TASK-003 | 2026-07-20 | done
Files touched: res://assets/source/ai/STYLE-GUIDE.md, res://assets/source/ai/GENERATION-RECIPE.md, res://MD Docs/progress.md
Result: Locked the TF-ART-v1 style guide and AI generation recipe with the approved tone, palette, perspective, lighting, shadows, pivots, sizes, alpha rules, naming, exact prompt templates, metadata, review/export workflow, and admission checklists. All acceptance criteria verified; both files have the exact lock line, all nine palette entries and required phrases are present, both prompts match Notes verbatim, and the target folder contains no generated image files.
Notes: Project boot and the TASK-001 balance loader test both remain clean. No runtime asset or generated image was added.

## TASK-004 | 2026-07-20 | done
Files touched: res://assets/source/ai/reference/sunwheat_crop_ready_512.png, res://assets/source/ai/reference/sunwheat_shadow_ready_512.png, res://assets/source/ai/reference/sunwheat_crop_ready_512.metadata.md, the two Godot-generated PNG import sidecars, res://MD Docs/progress.md
Result: Generated and approved the first TF-ART-v1 mature Sunwheat source reference, removed its chroma background to straight alpha, and separated a matching neutral-cool down-right shadow from the approved crop silhouette. Both PNGs are exact 512x512 canvases with transparent corners, safe margins, and the shared occupied ground-contact pivot `(256, 469)`; metadata and all reference-admission checks are complete.
Notes: Used the built-in imagegen workflow; exact backend model ID and seed were not exposed and are recorded as such. Godot import, project boot, and balance-loader regression checks pass cleanly. No file exists under res://assets/sprites/, and no game scene or code references these source images.
