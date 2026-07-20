TASK-002: Create a minimal verified project boot scene
Status: ready
Complexity: routine
Files: res://project.godot, res://scenes/main.tscn, res://scripts/main.gd
Acceptance:
- `project.godot` sets `res://scenes/main.tscn` as the main scene without changing the Compatibility renderer, portrait orientation, or existing Balance autoload
- `main.tscn` contains a single root Node named `Main` with `res://scripts/main.gd` attached; it contains no UI, gameplay, placeholder art, or user-facing text
- On startup, `main.gd` emits the developer-only diagnostic `TOPFARMER_BOOT_OK` exactly once and introduces no gameplay number or user-facing string
- `godot_console --headless --path . --quit-after 1` exits successfully, prints `TOPFARMER_BOOT_OK`, and prints no line containing `ERROR` or `FAIL`
- The existing TASK-001 balance loader test still exits successfully with its required PASS line
Human check:
- Open PowerShell in the TopFarmer project folder
- Run `godot_console --headless --path . --quit-after 1`
- The output must contain `TOPFARMER_BOOT_OK`, contain no line with `ERROR` or `FAIL`, and return to the PowerShell prompt by itself
Depends on: TASK-001
Notes: see DEC-012. This closes the remaining Phase 0 project-boot gap reported in TASK-001; do not begin Phase 1 art or gameplay work in this task.
