TASK-005: Generate the seamless meadow grass terrain reference
Status: ready
Complexity: routine
Files: res://assets/source/ai/reference/meadow_grass_tile_default_256x128.png, res://assets/source/ai/reference/meadow_grass_tile_preview_768x384.png, res://assets/source/ai/reference/meadow_grass_tile_default_256x128.metadata.md
Acceptance:
- `meadow_grass_tile_default_256x128.png` is exactly 256x128 with transparent pixels outside a clean 2:1 diamond whose four points meet the canvas edge midpoints; its placement pivot is the bottom point `(128, 127)`
- The tile follows TF-ART-v1 and DEC-016: warm leaf-and-moss grass, sparse sun-gold dry blades, and a few subtle moon-blue dew flecks that almost form a pattern, with no object, text, rune, neon glow, scenery, hard cast shadow, square background, or horror imagery
- The tile edges are constructed for seamless isometric repetition without visible gaps, dark seams, mismatched edge color, or a dominant repeated motif
- `meadow_grass_tile_preview_768x384.png` is a transparent diagnostic preview made only from a staggered 3x3 repetition of the approved 256x128 tile; all nine diamonds align into one continuous grassy patch
- The metadata file records TF-ART-v1, the exact resolved positive prompt and unchanged negative prompt, generation tool/model identifier, generation date, source and preview filenames, generation/downsampling method, 256x128 canvas, pivot coordinates, seamless-edge method, and every reference-admission checklist result
- These are source references only; no file is added under `assets/sprites/` and no game scene or code uses them yet
- The existing project boot and balance-loader checks still pass
Human check:
- Open `meadow_grass_tile_default_256x128.png` and `meadow_grass_tile_preview_768x384.png` in an image viewer with transparency visible
- The first image must be one clean grass diamond with no square background; Windows Properties must report 256 by 128 pixels
- The preview must show nine aligned diamonds as one continuous grassy patch with no cracks, dark lines, or obvious edge mismatch; Windows Properties must report 768 by 384 pixels
- The blue dew flecks should be subtle and nearly patterned, never a bright symbol or rune
Depends on: TASK-004
Notes: see DEC-007, DEC-008, DEC-011, DEC-015, and DEC-016. Resolve the locked positive prompt with SUBJECT = `meadow grass terrain tile, warm soft turf with small moss clusters, sparse sun-gold dry blades, and a few moon-blue dew flecks that almost form a pattern`; STATE OR VARIANT = `seamless default farm-ground diamond with no objects`; MASTER WIDTH = `256`; MASTER HEIGHT = `128`. Use the negative prompt unchanged. The 3x3 preview is diagnostic only and must be assembled from the final single tile, not separately generated.
