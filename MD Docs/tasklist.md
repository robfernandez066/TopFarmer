TASK-012: Export the approved Sunwheat seed-bag UI icon for runtime
Status: ready
Complexity: complex
Files: preserve res://assets/source/ai/reference/sunwheat_ui_icon_seed_bag_256.png unchanged; create res://assets/sprites/ui/sunwheat_ui_icon_seed_bag_128.png and its Godot import sidecar; create res://assets/sprites/ui/sunwheat_ui_icon_seed_bag_64.png and its Godot import sidecar
Acceptance:
- Preserve the approved 256x256 source byte-for-byte at SHA-256 `39CCB0D72DE061C279951E56706D948A42477667D03966F47E30B43ACC4E375D`; do not regenerate, crop, repaint, sharpen, recolor, move, or otherwise alter it
- Using Pillow 12.2.0, create each runtime PNG directly from the approved 256x256 source with one `Image.Resampling.LANCZOS` resize: source to 128x128 for `sunwheat_ui_icon_seed_bag_128.png`, and source directly to 64x64 for `sunwheat_ui_icon_seed_bag_64.png`; do not derive the 64x64 file from the 128x128 file
- After each resize, clear RGB wherever alpha is zero; both outputs are lossless straight-alpha RGBA PNGs with exact square dimensions, four transparent corners, clean antialiased edges, and no matte, background, shadow, glow, frame, text, or added pixels
- Both runtime sizes preserve the approved compact moss-green tied pouch, warm tan cord, recognizable sun-gold wheat-head stitch, and subordinate dusk-purple repair thread without stretch, crop, positional jump, or competing detail
- Reconstruct a temporary 512x256 diagnostic on solid highlight color `#F6E7C1` using only the unchanged 256x256 source at `(0, 0)`, the stored 128x128 runtime file at `(288, 64)`, and the stored 64x64 runtime file at `(432, 96)`; its decoded pixels must exactly match the approved source preview `sunwheat_ui_icon_seed_bag_preview_512x256.png`
- The Coder report includes the temporary diagnostic at normal size and records Pillow version, source and runtime SHA-256 hashes, decoded modes and dimensions, alpha extrema, alpha bounds, transparent-corner checks, hidden-RGB checks, direct-source reconstruction results, and exact diagnostic comparison; do not commit the temporary diagnostic
- Both Godot import sidecars use lossless texture import with mipmap generation disabled, no size limit, no premultiplied alpha, and no normal-map, HDR, or channel-remap alteration
- No other source or runtime image is created or changed, and no scene, script, resource, autoload, project setting, audio file, or balance file references the runtime icons yet
- `godot_console --headless --editor --path . --quit`, `godot_console --headless --path . --quit-after 1`, and `godot_console --headless --path . --script res://tests/balance_loader_test.gd` all exit successfully; boot prints `TOPFARMER_BOOT_OK`, and the balance test ends with `PASS: all 7 balance files loaded; bad test data was rejected`
Human check:
- Open the diagnostic shown in the Coder's report at normal size; all three pictures should clearly be the same tied green seed bag, and the gold wheat-head mark should still be recognizable in the smallest picture
- Reject the task if either smaller picture looks stretched, clipped, blurry enough to lose the wheat mark, surrounded by a colored box or glow, or different from the approved large icon
- In Windows, right-click `sunwheat_ui_icon_seed_bag_128.png`, choose Properties and then Details; it should report 128 by 128 pixels. Repeat for `sunwheat_ui_icon_seed_bag_64.png`; it should report 64 by 64 pixels
- Confirm the Coder report says the reconstructed diagnostic exactly matches the approved preview and that no game screen uses these icons yet
Depends on: TASK-011
Notes: see DEC-007, DEC-017, DEC-023, DEC-025, DEC-033, and DEC-038. This is controlled runtime admission of the already Human-approved icon only. Do not begin UI layout, planting logic, plot art, camera work, audio integration, or any other runtime asset in this task.
