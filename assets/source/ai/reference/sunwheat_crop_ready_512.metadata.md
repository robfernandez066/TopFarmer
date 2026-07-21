LOCKED FOR v1 - changes require a new PM decision

# Sunwheat Mature Crop Reference Metadata

## Generation Metadata

- Recipe version: `TF-ART-v1`
- Approved data ID: `sunwheat`
- Asset role: `crop`
- State or variant: `mature harvest-ready crop cluster`
- Generation tool/model identifier: OpenAI built-in `image_gen` / built-in imagegen backend; the exact backend model ID was not exposed by the tool response
- Generation date (UTC): `2026-07-21T09:53:23Z`
- Seed and reproducibility parameters: not exposed by the built-in tool
- Original generated candidate: `exec-c42ec952-53f2-4541-b66f-05d6438fe8f2.png`
- Original delivered dimensions: `1254x1254`
- Source filename: `sunwheat_crop_ready_512.png`
- Shadow filename: `sunwheat_shadow_ready_512.png`
- Final canvas: `512x512` pixels for both PNGs
- Alpha: straight-alpha transparent PNG
- Shared pivot coordinates: `(256, 465)` pixels, origin at canvas top left
- Reviewer: Coder Agent
- Review date (UTC): `2026-07-21`
- Disposition: accepted replacement source reference after DEC-014 rework; not admitted as a runtime asset

## Exact Resolved Positive Prompt

`TopFarmer game sprite of Sunwheat, a magical wheat analogue with plump golden seed heads, a faint warm inner glow, healthy green leaves, and one subtly dulled dusk-tinted seed head, mature harvest-ready crop cluster, 2D hand-painted fantasy cartoon, cozy rural warmth with a restrained mysterious undertone, angled top-down three-quarter orthographic view, readable mobile silhouette, TopFarmer locked v1 palette, key light from upper left at 35 degrees, subtle dark-plum outline, isolated on transparent background, centered on a 512 by 512 canvas, bottom-center ground contact aligned, no text`

## Unchanged Negative Prompt

`photorealism, 3D render, anime, pixel art, horror, gore, neon, glossy plastic, fisheye, front view, side view, inconsistent perspective, multiple objects, scenery, background, baked cast shadow, cropped edges, text, watermark`

## Source and Shadow Separation

The crop candidate was generated without a cast or contact shadow on a flat magenta chroma-key background. The locked chroma-removal helper sampled the border, applied a soft matte and despill, and produced straight alpha. The approved crop canvas was downsampled with Lanczos to `512x512`.

The shadow was separated deterministically from the approved replacement crop alpha rather than generated as a different plant silhouette. The crop alpha was projected from the shared `(256, 465)` ground-contact pivot with a compressed affine cast down and right, softened with a Gaussian blur, combined with a soft contact component at the same pivot, and rendered in neutral cool gray RGB `(83, 86, 101)` at partial alpha. No crop color or extra object was copied into the shadow PNG. The rejected silhouette from commit `57c9237` is not retained in either reference PNG.

## Ready for Reference Generation Checklist Results

- [x] The Sunwheat subject, `sunwheat` data ID, crop role, mature state, and crop asset family were approved by DEC-013.
- [x] The locked crop master canvas `512x512` was selected.
- [x] Only `[SUBJECT]`, `[STATE OR VARIANT]`, `[MASTER WIDTH]`, and `[MASTER HEIGHT]` were substituted.
- [x] The positive and negative prompts match the locked templates exactly after allowed substitution.
- [x] The metadata record captures the available tool, model identifier status, UTC date, seed status, parameters, dimensions, and review disposition.
- [x] Generation began only after the locked recipe and style guide were committed in TASK-003.

## Reference Admission Checklist Results

- [x] Both files are lossless straight-alpha PNGs on exact `512x512` canvases.
- [x] Both files use the shared bottom-center ground-contact pivot `(256, 465)`.
- [x] The crop uses an obvious angled top-down three-quarter presentation and a clear mobile silhouette.
- [x] The viewer can see top-facing surfaces on the seed heads and leaves.
- [x] The stalks are foreshortened, overlap in depth, and converge into a compact oval ground-plane footprint.
- [x] The crop reads as a low planted farm mound, not a front-facing bouquet, tall fan, or upright display arrangement.
- [x] The crop is palette-led with golden seed heads, healthy green leaves, a faint warm inner glow, and exactly one dulled dusk-tinted seed head.
- [x] Light reads from the upper left at approximately 35 degrees with a subtle dark-plum outline.
- [x] The crop has no face, eyes, text, scenery, clipped edge, background, contact shadow, or baked cast shadow.
- [x] The shadow contains only a matching soft neutral-cool partial-alpha silhouette aligned at the crop pivot and extending down right.
- [x] The shadow contains no crop color, background, text, or extra object.
- [x] The filenames follow the locked lowercase snake_case naming pattern.
- [x] The source, shadow, alpha edges, canvas dimensions, transparent corners, shared pivot, and side-by-side alignment were visually inspected.
- [x] No file was added under `assets/sprites/`, and no game scene or code references either source image.
