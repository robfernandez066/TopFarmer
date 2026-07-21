TASK-011: Export the approved Sunwheat crop and shadow for runtime
Status: ready
Complexity: routine
Files: create res://assets/sprites/crops/sunwheat_crop_ready_256.png and its Godot import sidecar, create res://assets/sprites/crops/sunwheat_shadow_ready_256.png and its Godot import sidecar
Acceptance:
- `sunwheat_crop_ready_256.png` is derived only from approved source `assets/source/ai/reference/sunwheat_crop_ready_512.png` at SHA-256 `1979E084EA5929A510CA15095F814A191DBD0412C7CA2E9D40850D39DD9C25B6`, and `sunwheat_shadow_ready_256.png` is derived only from approved source `assets/source/ai/reference/sunwheat_shadow_ready_512.png` at SHA-256 `6150B4EEA02B3F24862657198F3E08B090346C30A7EB6C17BBCF15886CF38CF6`; both source files remain byte-for-byte unchanged
- Each runtime PNG is produced by one Pillow 12.2.0 `Image.Resampling.LANCZOS` downsample from 512x512 to exactly 256x256, followed only by clearing hidden RGB where alpha is zero; there is no crop, stretch, paint-over, recolor, sharpen, blur, regenerated content, or other visual edit
- Both runtime files are lossless straight-alpha PNGs on exact 256x256 transparent canvases with fully transparent corners, clean antialiased edges, comfortable margins, and no matte, background, text, watermark, scenery, or clipped sprite edge
- The runtime crop preserves the approved low planted mound, visible top-facing golden seed heads and green leaves, subtle warm glow, exactly one dulled dusk-tinted seed head, upper-left lighting, restrained detail, and dark-plum outline; it does not become a front-facing bouquet, tall fan, diamond/isometric object, or horror image
- The crop PNG contains no baked contact or cast shadow; the shadow PNG contains only the matching soft partial-alpha neutral cool-gray shadow extending down and right, with no crop color, background, hard black edge, or extra object
- Full-canvas half-scaling preserves the same normalized alignment for both PNGs and maps their shared source ground-contact point `(256, 465)` to runtime point `(128, 232.5)`; the Coder report records this fractional intended pivot without rounding it to a different pixel
- The Coder report shows a temporary composite made by placing the runtime shadow and crop at identical 256x256 canvas coordinates over the approved runtime meadow, plus source/runtime comparisons; the crop must sit on its shadow without jumping, floating, or showing a colored fringe
- The Coder report records Pillow version and filter, both source and runtime SHA-256 values, dimensions, alpha extrema, occupied alpha bounds, hidden-RGB check, shared ground point, and composite method
- Both Godot import sidecars use lossless texture import with mipmap generation disabled, no size limit, no premultiplied alpha, and no normal-map, HDR, or channel-remap alteration
- No other runtime asset is created, and no scene, script, resource, autoload, project setting, or audio file references either runtime PNG yet
- The existing project boot and balance-loader checks still pass
Human check:
- In the Coder's report, inspect the runtime crop placed over its runtime shadow on meadow grass; the crop should look planted on the ground, not floating, and the shadow should remain soft and extend down and right
- Confirm the crop is the same approved low Sunwheat mound with golden heads, green leaves, and one muted purple-tinted head; reject it if it looks stretched, blurry, recolored, front-facing, or surrounded by a colored halo
- In Windows, right-click `sunwheat_crop_ready_256.png` and `sunwheat_shadow_ready_256.png`, choose Properties, then Details; both should report 256 by 256 pixels
- Confirm the Coder report says both 512x512 source files were unchanged, both runtime layers use the same `(128, 232.5)` ground point, and no scene uses them yet
Depends on: TASK-010
Notes: see DEC-007, DEC-014, DEC-015, DEC-017, DEC-031, and DEC-035. This is a paired runtime export because the crop and shadow must retain exact alignment; it is not a new generation task and does not authorize redesigning the approved crop. Use the same Pillow 12.2.0 Lanczos pipeline verified in TASK-010. Do not create a committed diagnostic composite or begin plot, timer, interaction, camera, or UI work in this task.
