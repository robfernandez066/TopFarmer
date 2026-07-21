LOCKED FOR v1 - changes require a new PM decision

# Sunwheat Mature Angle Candidate Metadata

## Generation Metadata

- Recipe version: `TF-ART-v1.2`
- Authority: DEC-049, DEC-050, DEC-051, and DEC-052
- Approved data ID: `sunwheat`
- Asset role: source-only mature crop perspective candidate
- State or variant: harvest-ready high-angle perspective calibration candidate
- Candidate identifier: `exec-db79e404-b51a-4247-b635-fb39a37d149f.png`
- Generation tool/model identifier: OpenAI built-in `image_gen` / built-in imagegen backend; the exact backend model ID was not exposed by the tool response
- Generation date (UTC): `2026-07-21T16:18:54Z`
- Seed and reproducibility parameters: not exposed by the built-in tool
- Requested dimensions: `512x512` in the locked positive prompt
- Delivered dimensions: `1254x1254`
- Accepted delivered-source SHA-256: `29E4A05FD9F1537000734F2861FCF8A362E554ECDDAD20D980005F268974934A`
- Prepared source filename: `sunwheat_crop_ready_angle_candidate_512.png`
- Prepared source dimensions and mode: exact `512x512` lossless straight-alpha RGBA PNG
- Prepared source SHA-256: `FF766F40D5CC135557E3BE0DA86A331A55D17E2E7B6F294A3F077ED96E7C6C6A`
- Reviewer: Coder Agent
- Review date (UTC): `2026-07-21`
- Disposition: accepted as a source-only Human-review candidate; it does not replace approved source/runtime art and is not referenced by any game resource

## Exact Positive Prompt

`TopFarmer game sprite of a single mature Sunwheat crop cluster with five to seven plump sun-gold grain heads, healthy green upright stalks and leaves, one subordinate dusk-purple grain head, and all stems visibly converging into one planted base, harvest-ready high-angle perspective calibration candidate, 2D hand-painted fantasy cartoon, cozy rural warmth with a restrained mysterious undertone, top-down orthogonal square ground plane with a high-angle front-elevated farm-game sprite presentation for subjects with height, vertical forms rising upward on screen from a bottom-center ground contact, clear readable front planes with modest visible top surfaces, near elements lower and larger and rear elements higher and smaller, readable mobile silhouette, TopFarmer locked v1 palette, key light from upper left at 35 degrees, subtle dark-plum outline, tile-filling opaque square canvas for flat terrain or isolated on transparent background for object sprites, centered on a 512 by 512 canvas, no text`

## Exact Negative Prompt

`photorealism, 3D render, anime, pixel art, horror, gore, neon, glossy plastic, isometric projection, diamond tile, 30-degree isometric axes, diagonal grid movement, fisheye, straight-down view for upright subjects, flat radial rosette, low eye-level front view, pure side view, inconsistent perspective, multiple objects, scenery, background, baked cast shadow, cropped edges, text, watermark`

The locked positive and negative strings above were passed verbatim to every built-in generation attempt. No word was added to or removed from either string. They were labeled separately from the following operational chroma instruction and task-derived perspective review criteria.

## Operational Chroma-Key Instruction

`Render exactly one isolated opaque crop subject on a perfectly flat solid #ff00ff chroma-key background for lossless background removal. The background must be one uniform color with no shadows, gradients, texture, reflections, floor plane, or lighting variation. Keep the crop fully separated from the background with crisp edges and generous safe padding. Do not use #ff00ff anywhere in the crop. No cast shadow, no contact shadow, no reflection, no watermark, and no text.`

The magenta key was selected because Sunwheat requires healthy green stalks and leaves. It was an operational extraction background only, not part of the locked positive or negative prompt.

## References and Limited Purposes

No existing image was supplied to the built-in generation tool. This prevented the rejected radial mature-crop composition from leaking into the new candidate.

- `res://assets/source/ai/reference/sunwheat_crop_ready_512.png` was inspected by the reviewer only for Sunwheat species, palette, grain anatomy, material, and lighting. Its DEC-047-rejected radial composition was not used as a composition reference.
- `res://assets/source/ai/reference/flourmill_building_idle_1024.png` was inspected by the reviewer only for TopFarmer rendering quality and the relationship between clear front planes and modest visible top surfaces. Its shapes and content were not supplied or copied.
- `res://assets/source/ai/production/tilled_soil_plot_empty_512.png` was inspected only to confirm the approved flat-ground presentation and later diagnostic context. It was not supplied to generation.
- No Stardew Valley image was supplied to generation. DEC-049 informed only the abstract ground-versus-upright angle relationship; no Stardew Valley asset, pixel-art rendering, palette, crop design, layout, UI, character, building, or protected expression was copied.

## Generation Attempts

1. Rejected `exec-f1b47824-e9ee-4303-9d15-a902c0fee56d.png`, generated `2026-07-21T16:16:08Z`, delivered as `1254x1254`, SHA-256 `E7DF8B06DAC7B663BE7FC43B8365F1B7A3738113C09B661114253F57971F99D1`. It had one base and the allowed head count but read as a symmetric eye-level bouquet with long frontal stalks rather than a high-angle near-to-far crop.
2. Rejected `exec-9ed69672-89a1-4049-923a-1e9d62e6e02c.png`, generated `2026-07-21T16:17:26Z`, delivered as `1254x1254`, SHA-256 `43BF408203B2F6B8CF79F0364B28E78A2A3B55EFACD0131563EA3A751ECC123B`. Depth scaling improved slightly, but long exposed stalks and mostly frontal grain heads still formed a tall bouquet.
3. Accepted for technical preparation `exec-db79e404-b51a-4247-b635-fb39a37d149f.png`, generated `2026-07-21T16:18:54Z`, delivered as `1254x1254`, SHA-256 `29E4A05FD9F1537000734F2861FCF8A362E554ECDDAD20D980005F268974934A`. It forms one compact planted cluster with five gold heads, exactly one subordinate purple head, strong near-to-far overlap, shorter rear depth, and one visible base.

Attempts two and three repeated the task's existing perspective criteria outside the unchanged locked prompts: a camera high above and in front; a visible bottom-center base; lower/larger foreground forms with readable front planes; overlapping central heads; smaller/higher foreshortened rear heads with modest top surfaces; and a compact layered silhouette instead of a fan or bouquet.

## Permitted Preparation

The accepted `1254x1254` generated PNG used a nearly uniform magenta key sampled at median RGB `(249, 4, 248)`. The installed imagegen helper's generic soft-matte pass was rejected because the broad color-distance ramp erased valid gold/green regions and darkened the required purple head. Its hard-key retry was also rejected because it left a visible key fringe. Neither rejected extraction became the source file.

The admitted extraction used a deterministic background-only mask: key-adjacent pixels connected to the source border were removed, enclosed near-key background holes and remaining neon key pixels were cleared, and enclosed painted subject pixels were preserved without recoloring. The result then received one full-canvas Pillow 12.2.0 `Image.Resampling.LANCZOS` resize from `1254x1254` to `512x512`, without cropping, stretching, mirroring, warping, sharpening, compositing, or candidate combination. The meaningful-alpha bottom stem axis was detected at `(260, 480)` after resizing; one whole-image translation of `(-4, -15)` placed it at source point `(256, 465)`. RGB was cleared wherever final alpha was zero.

No pixel was hand-painted, redrawn, recolored, mirrored, warped, sharpened, or combined with another candidate. No shadow was authored or baked.

## Prepared PNG Verification

- PNG format and mode: lossless straight-alpha `RGBA`
- Dimensions: exact `512x512`
- SHA-256: `FF766F40D5CC135557E3BE0DA86A331A55D17E2E7B6F294A3F077ED96E7C6C6A`
- Alpha extrema: `(0, 255)`
- Occupied alpha bounds above `0`: x=`74..421`, y=`15..467`
- Occupied alpha bounds above `8`: x=`76..419`, y=`17..465`
- Transparent margins above alpha `0`: left=`74`, top=`15`, right=`90`, bottom=`44`
- Corner alpha: `(0, 0, 0, 0)` for top-left, top-right, bottom-left, and bottom-right
- Painted pixels touching a canvas edge: `0`
- Hidden RGB channel values where alpha is zero: `0`
- Planted-base point: `(256, 465)`, measured from the meaningful-alpha bottom stem axis rather than whole-image luminance
- Exact temporary `256x256` Lanczos reduction RGBA SHA-256: `93473FE64AF4BF3F153EFD5E6DA2F589360ACB0217575E100CAF8C51BC4E4DAB`
- Fractional base point in that reduction: `(128, 232.5)`; it was not rounded
- Separate shadow: none
- Baked shadow: none

## Perspective Rejection Checklist

- [x] Reads as one compact planted crop rising upward from one visible bottom-center base.
- [x] Five plump sun-gold heads and exactly one subordinate dusk-purple head remain connected to the same plant.
- [x] Lower foreground heads and leaves are larger and show readable front planes.
- [x] Central heads overlap foreground and rear forms instead of spreading evenly around a center.
- [x] Smaller rear heads sit higher and show only modest top-facing surfaces.
- [x] Overlap and foreshortening create near-lower/rear-higher depth at both `512x512` and the exact `256x256` diagnostic reduction.
- [x] Does not read as a flat circular rosette, overhead flower, evenly spread starburst, eye-level bouquet, pure side view, isometric or diamond arrangement, disconnected head pile, or several plants.
- [x] The planted base, rather than a luminance centroid or scene offset, establishes optical centering.

## Palette and Content Review

- [x] Five heads are sun-gold; exactly one head is a subordinate muted dusk purple.
- [x] Stalks and leaves use healthy moss/leaf greens with derived value shifts.
- [x] The outline is a subtle dark plum derived from `#3E3840`.
- [x] Form light reads from the upper left at approximately 35 degrees.
- [x] The rendering stays cozy, hand-painted, mobile-readable, and non-horror.
- [x] There is no face, pot, soil patch, tool, scenery, glow halo, writing, watermark, background, contact shadow, or cast shadow.

## Temporary Diagnostics

- Neutral view: `topfarmer_task016_candidate_neutral_512.png`, exact `512x512`, SHA-256 `8E6F4373EC726A0BF29FD9531C9A470B896A138DAA97627C48257DA9EC8E8478`
- Portrait preview: `topfarmer_task016_candidate_portrait_540x960.png`, exact `540x960`, SHA-256 `00B84434C631AF0E8827477AA9C3FEF4757D2F7CDF92E0D98105BAFDB600DC8E`
- Portrait construction: repeat the unchanged approved `128x128` meadow runtime tile, place the unchanged approved `256x256` empty soil plot at `(142, 352)`, then place one exact in-memory `256x256` Lanczos reduction of the candidate at the identical coordinate. The candidate base lands at portrait point `(270, 584.5)`. No shadow or scene offset was added.
- Both diagnostics remain outside the repository in the task visualization folder and are not game resources.

Human perspective approval is required before any shadow is authored, runtime crop is replaced, FarmPlot alignment is revised, or gameplay work resumes.
