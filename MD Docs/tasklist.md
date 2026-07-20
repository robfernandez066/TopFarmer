TASK-001: Load balance CSVs at startup
Status: ready
Complexity: routine
Files: res://autoload/balance.gd, res://project.godot, res://tests/balance_loader_test.gd
Acceptance:
- `Balance` is registered as an autoload and all seven CSVs in `/data/` parse synchronously at startup without error
- Globals are queryable by `Key`; Crop, Good, and Building rows are queryable by lowercase snake_case `id`; Progression rows are queryable by integer `level`; Order rows are queryable by `order_id`; Currency rows are queryable by currency and flow
- Missing files, missing required headers, duplicate IDs/keys, malformed rows, and invalid numeric fields fail loudly with the source file and row in the diagnostic
- The loader reads files with `FileAccess.open("res://data/<name>.csv")` and does not rely on Godot localization imports
- A first-party headless test demonstrates successful representative queries and expected failure for malformed fixture data; its exact `godot_console` command is recorded in `progress.md`
- No gameplay number or user-facing string is introduced as a literal in code, scenes, or tests
- `godot_console --headless --editor --path . --quit` exits successfully
Human check:
- Open PowerShell in the TopFarmer project folder
- Run `godot_console --headless --path . --script res://tests/balance_loader_test.gd`
- The final line must say `PASS: all 7 balance files loaded; bad test data was rejected`, with no line containing `ERROR` or `FAIL`
Depends on: none
Notes: see DEC-003; preserve the existing keep-file CSV import settings and expected red X icons
