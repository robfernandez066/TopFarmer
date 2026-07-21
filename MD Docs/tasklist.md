TASK-007: Generate the Sunwheat seed-bag UI visual reference
Status: ready
Complexity: routine
Files: create res://assets/source/ai/reference/sunwheat_ui_icon_seed_bag_256.png, res://assets/source/ai/reference/sunwheat_ui_icon_seed_bag_preview_512x256.png, res://assets/source/ai/reference/sunwheat_ui_icon_seed_bag_256.metadata.md
Acceptance:
- `sunwheat_ui_icon_seed_bag_256.png` is a lossless straight-alpha PNG on an exact 256x256 transparent canvas with clean antialiased edges, fully transparent corners, comfortable margins, and no opaque background or matte
- The icon matches DEC-023: one compact moss-green cloth seed pouch, warm tan tied cord, one simple sun-gold wheat-head stitch, and one tiny subordinate dusk-purple repair thread
- The pouch is a single centered mobile-readable silhouette with restrained hand-painted detail, subtle dark-plum outline, and upper-left form lighting; it contains no words, letters, numbers, extra objects, face, scenery, button frame, cast shadow, glow, watermark, copied Stardew Valley design, or horror imagery
- The approved 256x256 source downscales with Lanczos to exact 128x128 and 64x64 versions in memory; at both sizes the pouch, tied top, and gold wheat symbol remain recognizable without zooming, while the tiny purple repair thread may remain a subtle accent rather than a required identifying feature
- `sunwheat_ui_icon_seed_bag_preview_512x256.png` is a diagnostic presentation made only from the approved source and its 128x128 and 64x64 Lanczos reductions, placed without stretching on one plain locked-palette background and labeled only in the metadata, not with text inside the PNG
- The preview places the 256x256 source at x=0, the 128x128 reduction centered in x=288..415 and y=64..191, and the 64x64 reduction centered in x=432..495 and y=96..159; all remaining preview pixels use solid highlight `#F6E7C1` so transparency and edge quality are visible
- The metadata records `TF-ART-v1.1`, data ID `sunwheat`, UI-icon role, seed-bag state, exact resolved positive and negative prompts, generation tool/model and available version, UTC generation date, seed and parameters or their unavailability, source candidate, dimensions, straight-alpha preparation, preview construction, SHA-256 values, reviewer, review date, disposition, and every admission-check result
- These files are source references only; no file is added under `assets/sprites/` and no game scene or code uses them yet
- The existing project boot and balance-loader checks still pass
Human check:
- Open `sunwheat_ui_icon_seed_bag_preview_512x256.png` at its normal size; it should show the same seed bag three times, getting smaller from left to right, on a light cream background
- Without zooming in, confirm the middle and smallest versions still look like a tied green seed bag with a simple gold wheat mark; reject it if the smallest version looks like an unclear blob or unrelated object
- Confirm there is no writing, number, button border, scenery, or shadow in the picture and that the tiny purple thread does not overpower the gold wheat mark
- In Windows, right-click `sunwheat_ui_icon_seed_bag_256.png`, choose Properties, then Details; it should report 256 by 256 pixels
Depends on: TASK-006
Notes: see DEC-007, DEC-008, DEC-015, DEC-017, DEC-022, and DEC-023. Resolve the exact TF-ART-v1.1 positive prompt with SUBJECT = `sunwheat seed bag UI icon, a compact moss-green cloth pouch tied with warm tan cord and marked by one simple sun-gold wheat-head stitch, with one tiny dusk-purple repair thread`; STATE OR VARIANT = `default plant-selection symbol`; MASTER WIDTH = `256`; MASTER HEIGHT = `256`. Use the locked negative prompt unchanged. Use approved Sunwheat, meadow, and Flourmill references only for palette, brushwork, outline, and lighting consistency. A UI icon has no ground contact and requires no separate shadow. The preview is diagnostic only and must be assembled from the final source and its exact reductions, not independently generated; do not create runtime exports in this task.
