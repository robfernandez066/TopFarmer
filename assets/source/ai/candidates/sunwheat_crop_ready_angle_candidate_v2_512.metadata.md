LOCKED FOR v1 - changes require a new PM decision

# Sunwheat Mature Rooted-Angle Candidate v2 Metadata

## Generation Metadata

- Recipe version: `TF-ART-v1.2`
- Authority: DEC-049, DEC-050, DEC-051, DEC-052, and DEC-053
- Approved data ID: `sunwheat`
- Asset role: source-only mature crop perspective and rooted-base replacement candidate
- State or variant: harvest-ready high-angle perspective replacement candidate
- Candidate identifier: `exec-d98eb05d-d4b6-45e9-8d6a-feed46020d92.png`
- Generation tool/model identifier: OpenAI built-in `image_gen` / built-in imagegen backend; the exact backend model ID and version were not exposed by the tool response
- Generation date (UTC): `2026-07-21T16:46:41Z`
- Seed and reproducibility parameters: not exposed by the built-in tool
- Requested dimensions: `512x512` in the locked positive prompt
- Delivered dimensions and mode: `1254x1254` RGB
- Accepted delivered-source SHA-256: `DE2CB646A969C88FD1AA9B1267E625DBDB8BF1E78827B4678F81D4A89E9ED2ED`
- Prepared source filename: `sunwheat_crop_ready_angle_candidate_v2_512.png`
- Prepared source dimensions and mode: exact `512x512` lossless straight-alpha RGBA PNG
- Prepared source SHA-256: `6AA30424C639B34B9ACC74509B6218DEB6522C6D80011F1D98A655923A2AEBD8`
- Reviewer: Coder Agent
- Review date (UTC): `2026-07-21`
- Disposition: accepted as a source-only Human-review replacement candidate; it does not replace approved source/runtime art and is not referenced by any game resource

DEC-053 preserves the first candidate from commit `ce38776` unchanged for traceability. That candidate remains rejected because several blunt, evenly cut, exposed stalk bottoms read as a severed bundle despite its correct numerical alignment and accepted high-angle relationship. This separately named v2 candidate replaces neither that record nor any game asset.

## Exact Positive Prompt

`TopFarmer game sprite of a single naturally rooted mature Sunwheat plant with five to seven plump sun-gold grain heads, healthy green upright stalks and overlapping basal leaves, exactly one subordinate dusk-purple grain head, and stems that taper and disappear together behind the basal leaves into one continuous organic soil contact with no exposed cut stalk ends, harvest-ready high-angle perspective replacement candidate, 2D hand-painted fantasy cartoon, cozy rural warmth with a restrained mysterious undertone, top-down orthogonal square ground plane with a high-angle front-elevated farm-game sprite presentation for subjects with height, vertical forms rising upward on screen from a bottom-center ground contact, clear readable front planes with modest visible top surfaces, near elements lower and larger and rear elements higher and smaller, readable mobile silhouette, TopFarmer locked v1 palette, key light from upper left at 35 degrees, subtle dark-plum outline, tile-filling opaque square canvas for flat terrain or isolated on transparent background for object sprites, centered on a 512 by 512 canvas, no text`

## Exact Negative Prompt

`photorealism, 3D render, anime, pixel art, horror, gore, neon, glossy plastic, isometric projection, diamond tile, 30-degree isometric axes, diagonal grid movement, fisheye, straight-down view for upright subjects, flat radial rosette, low eye-level front view, pure side view, inconsistent perspective, multiple objects, scenery, background, baked cast shadow, cropped edges, text, watermark`

The locked positive and negative strings above were passed verbatim to every built-in generation attempt. No word was added to or removed from either string. They were labeled separately from the operational chroma instruction and task-derived rejection criteria.

## Operational Chroma-Key Instruction

`Render exactly one isolated opaque crop subject on a perfectly flat solid #ff00ff chroma-key background for lossless background removal. The background must be one uniform color with no shadows, gradients, texture, reflections, floor plane, or lighting variation. Keep the crop fully separated from the background with crisp edges and generous safe padding. Do not use #ff00ff anywhere in the crop. No cast shadow, no contact shadow, no reflection, no watermark, and no text.`

The magenta key was selected because Sunwheat requires healthy green stalks and leaves. It was an operational extraction background only, not an addition to either locked prompt.

## References and Limited Purposes

No existing image was supplied to the built-in generation tool. In particular, the rejected candidate from commit `ce38776` was not supplied, preventing its cut-bundle anatomy from leaking into the replacement.

- Existing approved TopFarmer art was inspected only after generation for palette, material, upper-left lighting, high-angle rendering, and plot-preview context; no existing shape or content was copied.
- `res://assets/sprites/terrain/meadow_grass_tile_default_128.png` and `res://assets/sprites/plots/tilled_soil_plot_empty_256.png` were used only to construct the temporary portrait diagnostic.
- No Stardew Valley image was supplied. DEC-049 informed only the abstract ground-versus-upright angle relationship; no protected expression was copied.

## Generation Attempts

1. Rejected `exec-dda75904-9275-4248-bc25-24dcad1f902d.png`, generated `2026-07-21T16:45:24Z`, delivered as `1254x1254` RGB, SHA-256 `7BFF8B662DC18544F4EB8406A691A49E66B91DF0491BF1296EC50A97ECF0B8C7`. Its leaf-covered crown corrected the cut-stalk problem, but the very tall silhouette and mostly frontal heads read as an eye-level bouquet with insufficient high-angle compression.
2. Accepted `exec-d98eb05d-d4b6-45e9-8d6a-feed46020d92.png`, generated `2026-07-21T16:46:41Z`, delivered as `1254x1254` RGB, SHA-256 `DE2CB646A969C88FD1AA9B1267E625DBDB8BF1E78827B4678F81D4A89E9ED2ED`. It has six sun-gold heads, exactly one subordinate purple head, the strongest compact near-to-far overlap of the attempts, and one dense irregular leaf-covered crown with no exposed stem bottoms.
3. Rejected `exec-c2ce84c9-5193-49c4-b231-743169bb74c1.png`, generated `2026-07-21T16:48:04Z`, delivered as `1254x1254` RGB, SHA-256 `BE3B2093EC53827606A448E02E6D1B689CBC38461132EB66D2A08B0FE8BC0FDA`. Its base remained organic, but its rigid vertical stacking, frontal heads, and tall bouquet silhouette weakened the required near-lower/rear-higher high-angle depth.

## Permitted Preparation

The installed imagegen helper sampled the accepted background as `#fb02fa`. Its default despill attempt was rejected because it neutralized the required purple head, and its broad no-despill matte was rejected because it removed valid gold and green detail. Neither rejected extraction became the source file.

The admitted extraction used the helper without despill, with border-derived automatic keying, soft matte thresholds `8..80`, and a one-pixel alpha edge contraction to remove only the remaining key fringe. The RGB artwork was not repainted or recolored. The extracted full canvas received one Pillow 12.2.0 `Image.Resampling.LANCZOS` resize from `1254x1254` to `512x512`. A whole-image translation of `(0, +3)` placed the central organic crown contact at `(256, 465)`, after which RGB was cleared wherever alpha was zero.

No centered crop or padding was needed. No stretch, mirror, warp, sharpen, hand-paint, redraw, recolor, cover-up, candidate combination, shadow, or base repair was used.

## Prepared PNG Verification

- PNG format and mode: lossless straight-alpha `RGBA`
- Dimensions: exact `512x512`
- SHA-256: `6AA30424C639B34B9ACC74509B6218DEB6522C6D80011F1D98A655923A2AEBD8`
- Alpha extrema: `(0, 255)`
- Occupied alpha bounds above `0`: x=`81..427`, y=`35..468`
- Occupied alpha bounds above `8`: x=`83..425`, y=`37..466`
- Transparent margins above alpha `0`: left=`81`, top=`35`, right=`84`, bottom=`43`
- Corner alpha: `(0, 0, 0, 0)` for top-left, top-right, bottom-left, and bottom-right
- Painted pixels touching a canvas edge: `0`
- Hidden RGB channel values where alpha is zero: `0`
- Ground-contact point: `(256, 465)`, measured at the central basal crown rather than a whole-image luminance centroid or an outer leaf tip
- Meaningful alpha above `8` at y=`465` intersects the required x=`236..276` interval at x=`255..258`
- Full meaningful-alpha silhouette: exactly one 8-connected component containing `85,677` pixels; the lowest 40 painted rows remain part of that same planted silhouette, with no detached base or separate plant component
- Exact temporary `256x256` Lanczos reduction RGBA SHA-256: `6F6566190DF95EBCE30BB781F223C1F140F2D63DDE338CE280879CC48FD407D6`
- Fractional source contact in that reduction: `(128, 232.5)`; it was not rounded
- Separate shadow: none
- Baked shadow: none

## Rooted-Base Rejection Checklist

- [x] Every visible stalk narrows toward the bottom and disappears behind overlapping basal leaves.
- [x] The base reads as one continuous irregular living crown around `(256, 465)` at native size and after exact half-scale reduction.
- [x] There is no row of parallel stem bottoms and no visible circular, oval, flat, or horizontal stalk-end cross-section.
- [x] There are no blunt cut ends, tied or severed bundle, vase or bouquet base, pot-like rim, exposed roots, disconnected base, or separate root contacts.
- [x] The lowest leaf tips remain visibly attached to the single crown; none forms another plant or isolated soil contact.

## Perspective Rejection Checklist

- [x] The plant rises upward from the one bottom-center crown rather than reading as a straight-down rosette.
- [x] Lower foreground leaves and heads are larger and show readable front planes.
- [x] Central heads overlap foreground and rear forms instead of spreading evenly around a center.
- [x] Smaller rear heads sit higher and retain modest top-facing surfaces.
- [x] Overlap and foreshortening create near-lower/rear-higher depth at both `512x512` and the exact `256x256` diagnostic reduction.
- [x] The plant does not read as an overhead flower or starburst, low eye-level bouquet, pure side view, isometric or diamond arrangement, disconnected head pile, or several separate plants.

## Palette and Content Review

- [x] Six heads are sun-gold and exactly one smaller subordinate head is dusk purple.
- [x] Stalks and leaves use healthy leaf and moss greens with warm value shifts.
- [x] The outline is a subtle dark plum derived from `#3E3840`.
- [x] Form light reads from the upper left at approximately 35 degrees.
- [x] The rendering stays cozy, hand-painted, mobile-readable, and non-horror.
- [x] There is no face, binding, ribbon, pot, soil patch, exposed root, tool, scenery, glow halo, writing, watermark, background, contact shadow, or cast shadow.

## Temporary Diagnostics

- Neutral view: `topfarmer_task016_v2_neutral_512.png`, exact `512x512`, SHA-256 `5AC6D26544A38FA221E5E409C7644AE7978DC31AADDCB2080CB19DF778B05D60`
- Enlarged lowest-100-row base close-up: `topfarmer_task016_v2_base_closeup_2048x400.png`, exact `2048x400`, SHA-256 `2B810EEC81E0384B9B885F07C336BBC0F0AA2F6BFBCB5E18B924C22D8112016F`
- Portrait plot preview: `topfarmer_task016_v2_portrait_plot_540x960.png`, exact `540x960`, SHA-256 `C35FA735ABDE59A41F92D2DE4D790716A7890C1EBD8DAC90262AEEF9C106D746`
- Portrait construction: repeat the unchanged approved `128x128` meadow runtime tile, place the unchanged approved `256x256` empty soil plot at `(142, 352)`, then place one exact in-memory `256x256` Lanczos reduction of this candidate at the identical coordinate. The candidate contact lands at portrait point `(270, 584.5)`. No shadow or scene offset was added.
- All diagnostics remain outside the repository and are not game resources.

Human approval of both the high-angle relationship and naturally rooted base is required before any shadow is authored, runtime crop is replaced, FarmPlot alignment is revised, or gameplay work resumes.
