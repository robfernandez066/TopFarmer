TASK-018: Integrate the mature Sunwheat placeholder into FarmPlot READY
Status: ready
Complexity: routine
Files: modify res://scripts/farm/farm_plot.gd and res://tests/farm_plot_visual_state_test.gd
Acceptance:
- Change only the FarmPlot `READY` visual pair to use `res://assets/sprites/crops/sunwheat_crop_ready_placeholder_256.png` and `res://assets/sprites/crops/sunwheat_shadow_ready_placeholder_256.png`; load only these runtime files and never reference either 512x512 candidate source from a game resource
- Place both READY placeholder layers at exactly `(-128, -232.5)` relative to the FarmPlot ground-contact origin, with identical position, scale, rotation, parent, and fixed shadow-below-color z ordering; this maps the authored runtime contact `(128, 232.5)` to the plot origin without a visual-centroid correction
- Preserve the placeholder runtime crop at SHA-256 `5DEFE4D9A6C0FDFDC1F3332C24ABE9BE0DB7C584203CA71E468DD1396CB5B6C2` and shadow at SHA-256 `D0021B2B906ED64F3DB2CC5258D31DB80D5EBCB2DE2D372AFAB1AEBA26DA0F65`; do not modify, rename, move, duplicate, or regenerate any image, metadata, import sidecar, or source asset
- Preserve the `EMPTY` and `GROWING` visuals exactly. EMPTY keeps both crop layers hidden and reset to `(-128, -232.5)`. GROWING keeps its currently committed crop and matching shadow, visibility behavior, and paired position `(-127, -232.5)` unchanged
- Preserve the empty soil base, FarmPlot node hierarchy and identity, all three state names, public state-selection behavior, repeated state-cycle behavior, preview layout, 540x960 portrait display contract, and every nonvisual behavior unchanged
- Do not add planting, harvesting, timers, input, signals, animation, UI, audio, particles, vibration, camera behavior, inventory, balance logic, persistence, or any other gameplay in this task
- Extend the FarmPlot visual-state test to verify the exact placeholder runtime resource paths and hashes for READY, exact paired READY position `(-128, -232.5)`, unchanged EMPTY and GROWING paths and positions, shadow-below-color ordering, identical transforms, visibility in every state, node identity and parenting, and at least two complete `EMPTY -> GROWING -> READY -> EMPTY` cycles without drift
- The test fails if READY loads either old mature runtime file, either 512x512 source candidate, a non-placeholder filename, mismatched crop and shadow positions, or any READY x correction other than `-128`
- Opening the existing `res://tests/visual/farm_plot_states_preview.tscn` and running the current 540x960 preview shows EMPTY at top, the unchanged GROWING state in the middle, and the temporary mature placeholder pair in READY at the bottom; the bottom crop is planted at the plot's center contact with its small approved shadow attached
- `project.godot` remains semantically and byte-for-byte unchanged after normalizing any known editor-only `application/run/main_scene` key reorder caused by the Human check; no file outside the two listed implementation/test files and the append-only Coder report changes
- `godot_console --headless --editor --path . --quit`, `godot_console --headless --path . --script res://tests/portrait_display_contract_test.gd`, `godot_console --headless --path . --script res://tests/farm_plot_visual_state_test.gd`, `godot_console --headless --path . --quit-after 1`, and `godot_console --headless --path . --script res://tests/balance_loader_test.gd` all exit successfully with the existing required PASS and boot lines
Human check:
- In Godot, open `tests/visual/farm_plot_states_preview.tscn` and press F6 to run that scene
- Confirm the window is portrait with three brown plots: empty at the top, the smaller green growing crop in the middle, and the selected temporary mature crop at the bottom
- Confirm the bottom crop is rooted near the horizontal center of its soil, its small shadow touches the lowest leaves, and neither the crop nor shadow jumps sideways or floats
- The mature crop's known front-facing angle is still a temporary compromise. Approve only that the intended placeholder appears in READY, is centered by its planted base, and is visibly grounded
- After closing the preview, confirm the Coder report says `project.godot` and every PNG remained unchanged and the automated FarmPlot test printed its required PASS line
Depends on: TASK-017 and DEC-056
Notes: see DEC-054 through DEC-056. This is explicit reversible placeholder integration for the existing visual-only FarmPlot. Final crop perspective remains deferred, and gameplay interaction still begins only in a later task.
