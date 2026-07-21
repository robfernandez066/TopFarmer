TASK-006: Generate the first Flourmill building visual reference
Status: ready
Complexity: routine
Files: create res://assets/source/ai/reference/flourmill_building_idle_1024.png, res://assets/source/ai/reference/flourmill_shadow_idle_1024.png, res://assets/source/ai/reference/flourmill_building_idle_1024.metadata.md
Acceptance:
- `flourmill_building_idle_1024.png` is a lossless straight-alpha PNG on an exact 1024x1024 transparent canvas, with clean transparent edges and no opaque background, matte, text, watermark, scenery, or baked cast shadow
- The Flourmill matches DEC-020: compact warm weathered timber and moss-touched stone, broad weathered shingle roof, short four-sail wheel mounted high on the small front face, small door and window, sun-gold grain accents, and one faint dusk-purple reflection in the window
- The color sprite reads as a mostly overhead top-down farm building angled down slightly: the roof top dominates, only a small front face is visible, and the footprint aligns to the screen rather than forming a diamond or using 30-degree isometric axes
- The Flourmill remains legible at mobile size with one clear building silhouette, restrained surface detail, upper-left lighting, subtle dark-plum outline, no horror framing, and no copied Stardew Valley art or design
- `flourmill_shadow_idle_1024.png` is a lossless 1024x1024 transparent PNG containing only a soft partially transparent neutral cool-gray shadow that falls down and right; it has no building pixels, background, hard black edge, text, or watermark
- The color and shadow PNGs use the same bottom-center ground-contact point on their canvases so they align without either image jumping, and neither file is tightly cropped against a canvas edge
- The metadata records `TF-ART-v1.1`, the exact resolved positive and negative prompts, generation tool/model identifier and available version, UTC generation date, seed and parameters or their unavailability, source candidate, filenames, dimensions, straight-alpha preparation, separate-shadow method, bottom-center alignment, reviewer, review date, disposition, and every admission-check result
- These files are source references only; no file is added under `assets/sprites/` and no game scene or code uses them yet
- The existing project boot and balance-loader checks still pass
Human check:
- Open `flourmill_building_idle_1024.png`; it should show a cozy little mill viewed mostly from above, with much more roof top than front wall. It must not look like a diamond-shaped isometric building or a straight-on front view
- Check that the mill has a broad shingle roof, a small front wall with a door and window, a short four-sail wheel, warm wood and stone, and only a faint purple reflection in one window; it should feel gently magical, not scary
- Open `flourmill_shadow_idle_1024.png`; it should contain only a soft gray shadow extending toward the lower right, with no visible mill or background. When the Coder places it under the mill for the report, both images should meet at the same spot on the ground
- In Windows, right-click each PNG, choose Properties, then Details; both images should report 1024 by 1024 pixels
Depends on: TASK-005
Notes: see DEC-007, DEC-008, DEC-015, DEC-017, DEC-019, and DEC-020. The Stardew Valley reference is camera framing only; do not copy its buildings, art, palette, maps, or other assets. Use `sunwheat_crop_ready_512.png` and `meadow_grass_tile_default_256x256.png` only as approved style, palette, brushwork, and lighting references. Resolve the exact TF-ART-v1.1 positive prompt with SUBJECT = `flourmill building, a compact warm weathered-timber and moss-touched-stone windmill with a broad weathered shingle roof, a short four-sail wheel mounted high on its small front face, a small door and window, sun-gold grain accents, and one faint dusk-purple reflection in the window`; STATE OR VARIANT = `idle newly built production building`; MASTER WIDTH = `1024`; MASTER HEIGHT = `1024`. Use the locked negative prompt unchanged. Generate or prepare the separate shadow from the approved color silhouette without adding it to the color PNG. Do not create runtime exports in this task.
