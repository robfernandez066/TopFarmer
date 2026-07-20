LOCKED FOR v1 - changes require a new PM decision

# TopFarmer AI Generation Recipe

Recipe version: `TF-ART-v1`

This recipe governs reference and bulk raster generation for TopFarmer v1. Any prompt, palette, perspective, light, shadow, pivot, size, alpha, or export-rule change requires a new PM decision and a new recipe version.

## Positive Prompt Template

`TopFarmer game sprite of [SUBJECT], [STATE OR VARIANT], 2D hand-painted fantasy cartoon, cozy rural warmth with a restrained mysterious undertone, angled top-down three-quarter orthographic view, readable mobile silhouette, TopFarmer locked v1 palette, key light from upper left at 35 degrees, subtle dark-plum outline, isolated on transparent background, centered on a [MASTER WIDTH] by [MASTER HEIGHT] canvas, bottom-center ground contact aligned, no text`

## Negative Prompt Template

`photorealism, 3D render, anime, pixel art, horror, gore, neon, glossy plastic, fisheye, front view, side view, inconsistent perspective, multiple objects, scenery, background, baked cast shadow, cropped edges, text, watermark`

## Allowed Placeholder Substitutions

Only these four placeholders may be substituted. Do not otherwise rewrite either template.

| Placeholder | Allowed value |
|---|---|
| `[SUBJECT]` | One specific asset subject identified by its approved lowercase snake_case data ID and plain asset role. |
| `[STATE OR VARIANT]` | One approved state, growth stage, orientation, or variant; use `default state` when no variant applies. |
| `[MASTER WIDTH]` | The exact master width for the asset family: `256`, `512`, or `1024`. |
| `[MASTER HEIGHT]` | The exact master height for the asset family: `128`, `256`, `512`, or `1024`. |

Width and height must form one of the locked master canvases: terrain 256 x 128; crops, props, characters, and pets 512 x 512; buildings 1024 x 1024; UI icons 256 x 256.

## Required Generation Metadata

Store the following metadata beside every lossless source candidate under `res://assets/source/ai/`:

- Recipe version: `TF-ART-v1`
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

1. **Source:** Confirm the asset is approved for generation, select the locked canvas for its family, substitute only the four allowed placeholders, and save the exact prompts and metadata with the original lossless source.
2. **Review:** Evaluate the untouched source against `STYLE-GUIDE.md` for tone, palette, perspective, silhouette, light, outline, separate shadow requirement, pivot, canvas, clean alpha, and prohibited content. Reject failures instead of patching them inconsistently.
3. **Prepare:** Keep the color sprite isolated on transparent canvas. Create any soft neutral-cool-gray contact or cast shadow as a separate layer beneath it, traveling down and right. Align bottom-center ground contact consistently across states and flips.
4. **Export:** Downsample with a high-quality Lanczos filter to the exact runtime size: terrain 128 x 64; crops, props, characters, and pets 256 x 256; buildings 512 x 512; UI icons 128 x 128 and 64 x 64.
5. **Verify:** Inspect the lossless straight-alpha PNG at the 540 x 960 logical design resolution, confirm transparent edges and stable pivots, then name it with `<data_id>_<role>_<state>_<size>.png` before placing it in the reviewed runtime sprite folder.

## Runtime Asset Admission Checklist

An image must not become a runtime asset until every item passes:

- [ ] The positive prompt uses the exact locked template with only allowed substitutions.
- [ ] The negative prompt uses the exact locked template without additions or removals.
- [ ] Complete `TF-ART-v1` generation metadata is stored with the lossless source.
- [ ] Tone, perspective, nine-color palette, outline, silhouette, and prohibited-style checks pass.
- [ ] Light comes from the upper left at 35 degrees.
- [ ] Any soft shadow is separate, partially transparent, and travels down right.
- [ ] Bottom-center ground contact and normalized pivots match every related state and flip.
- [ ] Master and runtime sizes match the asset family exactly.
- [ ] The runtime file is lossless straight-alpha PNG with no crop, matte, baked shadow, text, or watermark.
- [ ] The runtime filename follows the locked lowercase snake_case naming pattern.
- [ ] The exported sprite has been visually inspected at logical resolution.

## Ready for reference generation

- [ ] The subject, data ID, role, state, and asset family are PM-approved.
- [ ] The exact locked master canvas has been selected.
- [ ] Only the four allowed placeholders have been substituted.
- [ ] Positive and negative prompts match the locked templates exactly.
- [ ] The metadata record is ready to capture tool, model, version, UTC date, seed, parameters, dimensions, and review disposition.
- [ ] No image generation begins until every item above is checked.
