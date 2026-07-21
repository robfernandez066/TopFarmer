TASK-004: Generate the first Sunwheat visual reference
Status: ready
Complexity: routine
Files: res://assets/source/ai/reference/sunwheat_crop_ready_512.png, res://assets/source/ai/reference/sunwheat_shadow_ready_512.png, res://assets/source/ai/reference/sunwheat_crop_ready_512.metadata.md
Acceptance:
- Both PNGs are exactly 512x512 with transparent backgrounds and share the same bottom-center ground-contact pivot
- `sunwheat_crop_ready_512.png` follows TF-ART-v1 and DEC-013: an angled top-down mature Sunwheat cluster with a readable mobile silhouette, palette-led golden seed heads and green leaves, a faint warm inner glow, one subtly dulled dusk-tinted seed head, upper-left lighting, subtle dark-plum outline, no face or eyes, no text, no scenery, no clipped edge, and no baked cast shadow
- `sunwheat_shadow_ready_512.png` contains only the matching soft neutral-cool shadow on transparency, aligned to the crop pivot and extending down right; it contains no crop color, background, text, or extra object
- The metadata file records TF-ART-v1, the exact resolved positive prompt and unchanged negative prompt, generation tool/model identifier, generation date, source and shadow filenames, 512x512 canvas, pivot coordinates, shadow-separation method, and every reference-admission checklist result
- These are source references only; no file is added under `assets/sprites/` and no game scene or code uses them yet
- The existing project boot and balance-loader checks still pass
Human check:
- Open both PNGs in an image viewer with transparency visible and place them side by side at the same zoom
- The crop must look like warm magical wheat viewed from above at an angle, with one slightly dull purple-brown seed head but nothing scary; it must have no background or shadow baked into it
- The shadow image must show only a soft shadow falling down and right from the same ground point; in Windows Properties, both images must report 512 by 512 pixels
Depends on: TASK-003
Notes: see DEC-007, DEC-008, DEC-011, and DEC-013. Resolve the locked positive prompt with SUBJECT = `Sunwheat, a magical wheat analogue with plump golden seed heads, a faint warm inner glow, healthy green leaves, and one subtly dulled dusk-tinted seed head`; STATE OR VARIANT = `mature harvest-ready crop cluster`; MASTER WIDTH = `512`; MASTER HEIGHT = `512`. Use the negative prompt unchanged. The shadow must be separated from the approved crop source, not generated as a different plant silhouette.
