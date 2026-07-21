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
- Runtime crop filename: `sunwheat_crop_ready_256.png`
- Runtime shadow filename: `sunwheat_shadow_ready_256.png`
- Source canvases: `512x512` pixels for both source PNGs
- Runtime canvases: `256x256` pixels for both runtime PNGs
- Alpha: lossless straight-alpha transparent PNG with zero RGB wherever alpha is zero
- Shared source ground-contact point: `(256, 465)` pixels, origin at canvas top left
- Shared runtime ground-contact point: `(128, 232.5)` pixels; the fractional y coordinate is intentional and must not be rounded
- Unchanged crop source SHA-256: `1979E084EA5929A510CA15095F814A191DBD0412C7CA2E9D40850D39DD9C25B6`
- Unchanged accepted runtime crop SHA-256: `711D3F1CBC73B9B6031795535CBAF723C6832C03A44EB1BE0DDF45F9156019F4`
- Corrected source shadow SHA-256: `87CDCAD89ED7DC48806C1A586D1B8EFC3558B54A59075276A96BA358977BA5D5`
- Corrected runtime shadow SHA-256: `311BDB3904A9B0BDED80ECEECA80939CC846DF32CF62B30BA72D18E40F6CA633`
- Superseded source shadow SHA-256: `6150B4EEA02B3F24862657198F3E08B090346C30A7EB6C17BBCF15886CF38CF6`
- Superseded runtime shadow SHA-256 from local commit `0eebb1d`: `0DAC069A33F4B8EC2D1A4A0ED39539EDB5FFBDB9ECE0F01318E56FBA4A24725B`
- Reviewer: Coder Agent
- Review date (UTC): `2026-07-21`
- Disposition: approved crop source and accepted runtime crop preserved byte-for-byte; DEC-036 corrected shadow master and derivative pass Coder technical/composite review and await the replacement Human check; local result is not authorized for push yet

## Exact Resolved Positive Prompt

`TopFarmer game sprite of Sunwheat, a magical wheat analogue with plump golden seed heads, a faint warm inner glow, healthy green leaves, and one subtly dulled dusk-tinted seed head, mature harvest-ready crop cluster, 2D hand-painted fantasy cartoon, cozy rural warmth with a restrained mysterious undertone, angled top-down three-quarter orthographic view, readable mobile silhouette, TopFarmer locked v1 palette, key light from upper left at 35 degrees, subtle dark-plum outline, isolated on transparent background, centered on a 512 by 512 canvas, bottom-center ground contact aligned, no text`

## Unchanged Negative Prompt

`photorealism, 3D render, anime, pixel art, horror, gore, neon, glossy plastic, fisheye, front view, side view, inconsistent perspective, multiple objects, scenery, background, baked cast shadow, cropped edges, text, watermark`

## Crop Source and Corrected Shadow Construction

The crop candidate was generated without a cast or contact shadow on a flat magenta chroma-key background. The locked chroma-removal helper sampled the border, applied a soft matte and despill, and produced straight alpha. The approved crop canvas was downsampled with Lanczos to `512x512`.

The former shadow master at SHA-256 `6150B4EEA02B3F24862657198F3E08B090346C30A7EB6C17BBCF15886CF38CF6` produced the exact runtime downsample at SHA-256 `0DAC069A33F4B8EC2D1A4A0ED39539EDB5FFBDB9ECE0F01318E56FBA4A24725B` in local commit `0eebb1d`. The Human check rejected that composite because its broad right-offset oval survived at runtime and made the correctly aligned crop appear to float. DEC-036 supersedes the former shadow only; neither rejected hash is retained as the final shadow file. The crop source and accepted runtime crop remain unchanged.

The corrected `512x512` shadow master was built deterministically in Pillow 12.2.0. A contact ellipse with pre-blur bounds x=`116..396`, y=`412..468` was filled to alpha `78` and softened with Gaussian blur radius `10`. A subordinate cast ellipse with pre-blur bounds x=`184..404`, y=`426..470` was filled to alpha `24` and softened with Gaussian blur radius `14`. The two components overlap across `20,162` positive-alpha pixels and were combined by per-pixel maximum alpha, so the lighter down-right extension remains attached instead of forming a separate lobe. Every occupied source-shadow pixel uses exactly neutral cool gray RGB `(83, 86, 101)`; every pixel remains below full opacity, and RGB is zero wherever alpha is zero.

The corrected source-shadow alpha extrema are `(0, 78)`. Its occupied bounds above alpha `0` are x=`95..427`, y=`389..498`; bounds above alpha `8` are x=`108..404`, y=`399..481`. Alpha at the source ground point `(256, 465)` is `49`, and the meaningful-alpha crop/shadow overlap is `12,068` pixels, placing contact visibly behind the bottom leaves. The edge exposes all `78` positive alpha levels, has fully transparent corners and safe margins, and fades continuously.

The corrected runtime shadow was produced only by one Pillow 12.2.0 `Image.Resampling.LANCZOS` downsample from `512x512` to `256x256`, followed by clearing hidden RGB where alpha is zero. Its alpha extrema are `(0, 78)`, occupied bounds above alpha `0` are x=`47..213`, y=`195..248`, and bounds above alpha `8` are x=`54..202`, y=`200..240`. Runtime shadow alpha at x=`128` is `51` on row `232` and `44` on row `233`, spanning the exact fractional shared ground point `(128, 232.5)`. The unchanged runtime crop overlaps the corrected shadow across `3,037` pixels above alpha `8`.

A temporary native-coordinate review composite directly repeated the approved `128x128` meadow runtime tile `2x2`, then alpha-composited the corrected runtime shadow and unchanged runtime crop at identical `(0, 0)` offsets. Pixel reconstruction was exact. Full and close visual review found contact beginning beneath the leaf base with no hover gap, while the lighter attached extension remained modestly down-right without reading as a platform, puddle, broad offset oval, or detached blob. The diagnostic is not stored in the repository. The rejected crop silhouette from commit `57c9237` is not retained in either reference PNG.

## Ready for Reference Generation Checklist Results

- [x] The Sunwheat subject, `sunwheat` data ID, crop role, mature state, and crop asset family were approved by DEC-013.
- [x] The locked crop master canvas `512x512` was selected.
- [x] Only `[SUBJECT]`, `[STATE OR VARIANT]`, `[MASTER WIDTH]`, and `[MASTER HEIGHT]` were substituted.
- [x] The positive and negative prompts match the locked templates exactly after allowed substitution.
- [x] The metadata record captures the available tool, model identifier status, UTC date, seed status, parameters, dimensions, and review disposition.
- [x] Generation began only after the locked recipe and style guide were committed in TASK-003.

## Reference Admission Checklist Results

- [x] Both source files are lossless straight-alpha PNGs on exact `512x512` canvases; both runtime files are exact `256x256` lossless straight-alpha PNGs.
- [x] Both source layers use shared ground point `(256, 465)`, and full-canvas half-scaling preserves the exact fractional runtime point `(128, 232.5)`.
- [x] The crop uses an obvious angled top-down three-quarter presentation and a clear mobile silhouette.
- [x] The viewer can see top-facing surfaces on the seed heads and leaves.
- [x] The stalks are foreshortened, overlap in depth, and converge into a compact oval ground-plane footprint.
- [x] The crop reads as a low planted farm mound, not a front-facing bouquet, tall fan, or upright display arrangement.
- [x] The crop is palette-led with golden seed heads, healthy green leaves, a faint warm inner glow, and exactly one dulled dusk-tinted seed head.
- [x] Light reads from the upper left at approximately 35 degrees with a subtle dark-plum outline.
- [x] The crop has no face, eyes, text, scenery, clipped edge, background, contact shadow, or baked cast shadow.
- [x] The superseded broad source/runtime shadow hashes are recorded as Human-check rejected under DEC-036 and are absent from the final shadow files.
- [x] The corrected shadow master exactly matches the prescribed two-ellipse construction, maximum-alpha merge, RGB `(83, 86, 101)`, blur radii, bounds, and input alpha values.
- [x] The corrected contact overlaps behind the bottom leaves and shared ground point; the lighter cast extension remains attached and subordinate down-right.
- [x] Every corrected shadow pixel remains partially transparent, the edge fades continuously, and all four corners are transparent.
- [x] The shadow contains no crop color, background, hard black edge, separate oval, platform, puddle, detached lobe, text, watermark, scenery, or extra object.
- [x] The runtime shadow is an exact single Pillow 12.2.0 Lanczos downsample of the corrected master followed only by clearing hidden RGB.
- [x] The crop source and accepted runtime crop remain byte-for-byte unchanged at their recorded hashes.
- [x] The filenames follow the locked lowercase snake_case naming pattern.
- [x] The source, corrected shadow, runtime layers, alpha edges, dimensions, transparent corners, shared ground points, full composite, and close contact view were visually inspected.
- [x] Only the paired Sunwheat runtime crop/shadow files were admitted under `assets/sprites/crops/`; no game scene, script, resource, autoload, project setting, or audio file references either runtime image.
