TASK-005: Correct the art recipe and meadow terrain to the square-grid overhead perspective
Status: ready
Complexity: complex
Files: res://assets/source/ai/STYLE-GUIDE.md, res://assets/source/ai/GENERATION-RECIPE.md, remove res://assets/source/ai/reference/meadow_grass_tile_default_256x128.png and its import sidecar, remove res://assets/source/ai/reference/meadow_grass_tile_preview_768x384.png and its import sidecar, remove res://assets/source/ai/reference/meadow_grass_tile_default_256x128.metadata.md, create res://assets/source/ai/reference/meadow_grass_tile_default_256x256.png, res://assets/source/ai/reference/meadow_grass_tile_preview_768x768.png, res://assets/source/ai/reference/meadow_grass_tile_default_256x256.metadata.md
Acceptance:
- `STYLE-GUIDE.md` and `GENERATION-RECIPE.md` identify the recipe as `TF-ART-v1.1` and replace every positive instruction for three-quarter/isometric/diamond presentation with DEC-017's mostly overhead, slightly angled, orthogonal square-grid direction
- The positive prompt template says `mostly overhead top-down farm-game view with a slight downward angle, screen-aligned orthogonal ground plane, visible top surfaces and a small front face where the subject has height`; the negative prompt explicitly rejects `isometric projection, diamond tile, 30-degree isometric axes`
- The style guide and recipe define terrain as a seamless 256x256 square master exported to a 128x128 square runtime tile; no active instruction retains the former 256x128 or 128x64 diamond sizes
- `meadow_grass_tile_default_256x256.png` is an opaque, seamless 256x256 square terrain tile with no border, diamond silhouette, transparent corner, directional perspective lines, object, text, rune, neon glow, hard shadow, or horror imagery
- The square tile retains DEC-016's warm leaf-and-moss grass, sparse sun-gold dry blades, and subtle moon-blue dew flecks without a visually dominant repeated motif
- `meadow_grass_tile_preview_768x768.png` is made only from a direct 3x3 square repetition of the final 256x256 tile and shows no gap, dark seam, mismatched edge color, or diagonal/isometric arrangement
- The new metadata records `TF-ART-v1.1`, the exact resolved prompts, generation tool/model identifier, generation date, new filenames, 256x256 canvas, square-grid seamless-edge method, 3x3 preview method, and every admission-check result
- The former 256x128 diamond tile, 768x384 diamond preview, old metadata, and their Godot import sidecars are absent from the repository
- These are source references only; no file is added under `assets/sprites/` and no game scene or code uses them yet
- The existing project boot and balance-loader checks still pass
Human check:
- Open `STYLE-GUIDE.md` and `GENERATION-RECIPE.md`; both must say `TF-ART-v1.1`, describe a mostly overhead square-grid view, and explicitly say the game is not isometric
- Open `meadow_grass_tile_default_256x256.png`; it must be a full square with no transparent corners, and Windows Properties must report 256 by 256 pixels
- Open `meadow_grass_tile_preview_768x768.png`; it must look like one continuous square field with no diamond pattern, diagonal grid, cracks, or dark seams, and Windows Properties must report 768 by 768 pixels
- Confirm the old filenames containing `256x128` and `768x384` no longer appear in `assets/source/ai/reference/`
Depends on: TASK-004
Notes: see DEC-007, DEC-008, DEC-011, DEC-015, DEC-016, DEC-017, and DEC-018. The Stardew Valley reference is camera framing only; do not copy its art, characters, UI, maps, or assets. Resolve the updated positive prompt with SUBJECT = `meadow grass terrain tile, warm soft turf with small moss clusters, sparse sun-gold dry blades, and a few moon-blue dew flecks that almost form a pattern`; STATE OR VARIANT = `seamless default square farm-ground tile with no objects`; MASTER WIDTH = `256`; MASTER HEIGHT = `256`. The 3x3 preview is diagnostic only and must be assembled from the final single square tile, not separately generated. This task remains active because the completed isometric result in commit `4047321` conflicts with the human's clarified camera direction.
