TASK-003: Lock the v1 art style guide and AI generation recipe
Status: ready
Complexity: routine
Files: res://assets/source/ai/STYLE-GUIDE.md, res://assets/source/ai/GENERATION-RECIPE.md
Acceptance:
- Both files begin with `LOCKED FOR v1 - changes require a new PM decision` and identify the recipe as version `TF-ART-v1`
- `STYLE-GUIDE.md` defines the cozy-with-quiet-wrongness tone, angled top-down three-quarter perspective, the nine-color palette from DEC-011, outline and shape language, upper-left 35-degree light, separate soft down-right shadows, bottom-center pivots, master/runtime sizes, PNG alpha rules, sprite naming, and an asset rejection checklist
- `GENERATION-RECIPE.md` contains the exact positive and negative prompt templates from Notes, the allowed placeholder substitutions, required generation metadata, source-review-export steps, and a checklist that must pass before an image becomes a runtime asset
- The size and pivot rules match `project-context.md` exactly and neither file introduces a conflicting art rule
- No PNG, JPG, WEBP, or other generated image is added in this task; the recipe must be locked before reference or bulk asset generation
Human check:
- Open `assets/source/ai/STYLE-GUIDE.md` and `assets/source/ai/GENERATION-RECIPE.md` in any text viewer
- Both files must start with `LOCKED FOR v1 - changes require a new PM decision`; the style guide must show a nine-color table plus the words `light from upper left` and `shadow down right`; the recipe must show one positive prompt, one negative prompt, and a final `Ready for reference generation` checklist
- Open `assets/source/ai/` in File Explorer; it must contain the two Markdown files and no generated image files
Depends on: TASK-002
Notes: see DEC-007, DEC-008, and DEC-011. Positive prompt template: `TopFarmer game sprite of [SUBJECT], [STATE OR VARIANT], 2D hand-painted fantasy cartoon, cozy rural warmth with a restrained mysterious undertone, angled top-down three-quarter orthographic view, readable mobile silhouette, TopFarmer locked v1 palette, key light from upper left at 35 degrees, subtle dark-plum outline, isolated on transparent background, centered on a [MASTER WIDTH] by [MASTER HEIGHT] canvas, bottom-center ground contact aligned, no text`. Negative prompt template: `photorealism, 3D render, anime, pixel art, horror, gore, neon, glossy plastic, fisheye, front view, side view, inconsistent perspective, multiple objects, scenery, background, baked cast shadow, cropped edges, text, watermark`.
