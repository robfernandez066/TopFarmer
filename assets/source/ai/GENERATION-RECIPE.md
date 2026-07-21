LOCKED FOR v1 - changes require a new PM decision

# TopFarmer AI Generation Recipe

Recipe version: `TF-ART-v1.2`

This recipe governs reference and bulk raster generation for TopFarmer v1. Any prompt, palette, perspective, light, shadow, pivot, size, alpha, or export-rule change requires a new PM decision and a new recipe version.

DEC-049 and DEC-050 authorize this perspective revision. Flat terrain, paths, water, and ground-flush soil plots use a straight top-down screen-aligned orthogonal square grid with no invented front wall. Crops, props, characters, and buildings use a high-angle front-elevated farm-game sprite presentation: vertical forms rise upward on screen from a bottom-center ground contact; clear front planes carry most of the silhouette; modest top surfaces remain visible; near elements sit lower and larger; rear elements sit higher and smaller; overlaps and foreshortening establish depth.

The supplied Stardew Valley farm screenshot is a reference only for this ground-versus-upright angle relationship. TopFarmer must not copy Stardew Valley's assets, pixel-art rendering, palette, crop designs, layouts, user interface, characters, buildings, or other protected expression. Never use straight-down views of upright subjects, flat radial crop rosettes, evenly spread overhead starbursts, front-facing eye-level views, pure side views, isometric projection, diamond tiles, 30-degree isometric axes, diagonal grid movement, fisheye distortion, or inconsistent perspective.

## Positive Prompt Template

`TopFarmer game sprite of [SUBJECT], [STATE OR VARIANT], 2D hand-painted fantasy cartoon, cozy rural warmth with a restrained mysterious undertone, top-down orthogonal square ground plane with a high-angle front-elevated farm-game sprite presentation for subjects with height, vertical forms rising upward on screen from a bottom-center ground contact, clear readable front planes with modest visible top surfaces, near elements lower and larger and rear elements higher and smaller, readable mobile silhouette, TopFarmer locked v1 palette, key light from upper left at 35 degrees, subtle dark-plum outline, tile-filling opaque square canvas for flat terrain or isolated on transparent background for object sprites, centered on a [MASTER WIDTH] by [MASTER HEIGHT] canvas, no text`

## Negative Prompt Template

`photorealism, 3D render, anime, pixel art, horror, gore, neon, glossy plastic, isometric projection, diamond tile, 30-degree isometric axes, diagonal grid movement, fisheye, straight-down view for upright subjects, flat radial rosette, low eye-level front view, pure side view, inconsistent perspective, multiple objects, scenery, background, baked cast shadow, cropped edges, text, watermark`

## Allowed Placeholder Substitutions

Only these four placeholders may be substituted. Do not otherwise rewrite either template.

| Placeholder | Allowed value |
|---|---|
| `[SUBJECT]` | One specific asset subject identified by its approved lowercase snake_case data ID and plain asset role. |
| `[STATE OR VARIANT]` | One approved state, growth stage, orientation, or variant; use `default state` when no variant applies. |
| `[MASTER WIDTH]` | The exact master width for the asset family: `256`, `512`, or `1024`. |
| `[MASTER HEIGHT]` | The exact master height for the asset family: `256`, `512`, or `1024`. |

Width and height must form one of the locked master canvases: terrain 256 x 256 square; crops, props, characters, and pets 512 x 512; buildings 1024 x 1024; UI icons 256 x 256.

## Required Generation Metadata

Store the following metadata beside every lossless source candidate under `res://assets/source/ai/`:

- Recipe version: `TF-ART-v1.2`
- Approved data ID, asset role, and state or variant
- Complete substituted positive prompt
- Complete negative prompt
- Generation tool and model identifier
- Tool or model version, when available
- Generation date in UTC
- Seed and all reproducibility parameters, when the tool exposes them
- Requested and delivered pixel dimensions
- Original source filename and candidate identifier
- Reviewer, review date, and disposition: accepted, revise, or rejected
- Rejection reason or approved export filenames
- Any permitted downsampling and alpha-processing settings

## Source, Review, and Export

1. **Source:** Confirm the asset is approved for generation, classify it as flat ground or an upright subject, select the locked canvas for its family, substitute only the four allowed placeholders in the exact `TF-ART-v1.2` prompt templates, and save those exact prompts and metadata with the original lossless source.
2. **Review:** Evaluate the untouched source against `STYLE-GUIDE.md` for tone, palette, silhouette, light, outline, separate shadow requirement, pivot, canvas, clean alpha or opaque terrain coverage, and prohibited content. Separately verify a straight top-down square ground plane with no invented front wall for flat ground, or a high-angle front-elevated presentation with readable front planes and near-lower/rear-higher depth for upright subjects. Reject upright crops that read as flat overhead rosettes or evenly spread overhead starbursts even when their canvas and ground point are mathematically correct. Reject failures instead of patching them inconsistently.
3. **Prepare:** Keep flat terrain fully opaque, straight top-down, and seamless across all four square edges; do not invent a front wall. Keep upright object color sprites isolated on transparent canvases while preserving their high-angle front-elevated presentation. Create any soft neutral-cool-gray contact or cast shadow as a separate layer beneath an object, traveling down and right. Align bottom-center ground contact consistently across object states and flips.
4. **Export:** Preserve the approved flat-ground or upright-subject presentation while downsampling with a high-quality Lanczos filter to the exact runtime size: terrain 128 x 128 square; crops, props, characters, and pets 256 x 256; buildings 512 x 512; UI icons 128 x 128 and 64 x 64.
5. **Verify:** Inspect the lossless PNG at the 540 x 960 logical design resolution. Confirm four-edge continuity, full opacity, a straight top-down square ground plane, and no invented front wall for flat terrain; or confirm clean transparent edges, stable bottom-center pivots, clear front planes, modest visible top surfaces, and near-lower/rear-higher depth for upright subjects. Reject any straight-down upright subject or flat radial crop rosette, then name a passing asset with `<data_id>_<role>_<state>_<size>.png` before placing it in the reviewed runtime sprite folder.

## Runtime Asset Admission Checklist

An image must not become a runtime asset until every item passes:

- [ ] The positive prompt uses the exact locked template with only allowed substitutions.
- [ ] The negative prompt uses the exact locked template without additions or removals.
- [ ] Complete `TF-ART-v1.2` generation metadata is stored with the lossless source.
- [ ] Tone, nine-color palette, outline, silhouette, and prohibited-style checks pass.
- [ ] Flat terrain, paths, water, and ground-flush soil plots use a straight top-down screen-aligned orthogonal square grid with no invented front wall.
- [ ] Crops, props, characters, and buildings use a high-angle front-elevated presentation with vertical forms rising from a bottom-center ground contact, clear front planes, modest visible tops, and near-lower/rear-higher depth established by overlap and foreshortening.
- [ ] Upright crops do not read as straight-down flat radial rosettes or evenly spread overhead starbursts, even when their canvas and ground point are mathematically correct.
- [ ] The asset is free of isometric projection, diamond tiles, 30-degree isometric axes, and diagonal grid movement.
- [ ] Light comes from the upper left at 35 degrees.
- [ ] Any soft shadow is separate, partially transparent, and travels down right.
- [ ] Bottom-center ground contact and normalized pivots match every related state and flip.
- [ ] Master and runtime sizes match the asset family exactly.
- [ ] The runtime file is a lossless PNG with no crop, matte, baked shadow, text, or watermark; terrain is opaque and seamless, while object sprites use straight alpha.
- [ ] The runtime filename follows the locked lowercase snake_case naming pattern.
- [ ] The exported sprite has been visually inspected at logical resolution.

## Ready for reference generation

- [ ] The subject, data ID, role, state, and asset family are PM-approved.
- [ ] The subject is classified as flat ground or upright, and the applicable ground-versus-upright perspective checks are ready for review.
- [ ] The exact locked master canvas has been selected.
- [ ] Only the four allowed placeholders have been substituted.
- [ ] Positive and negative prompts match the exact locked `TF-ART-v1.2` templates.
- [ ] The metadata record is ready to capture `TF-ART-v1.2`, tool, model, version, UTC date, seed, parameters, dimensions, ground-versus-upright classification, and review disposition.
- [ ] No image generation begins until every item above is checked.
