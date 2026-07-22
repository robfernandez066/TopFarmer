# Sunwheat Mature Geometry-Guided Candidate Metadata

## Generation Metadata

- Recipe version: `TF-ART-v1.2`
- Authority: DEC-047 through DEC-054 and DEC-075
- Approved data ID: `sunwheat`
- Asset role: source-only mature crop final-perspective candidate
- State or variant: harvest-ready geometry-guided final-perspective candidate
- Mandatory guide reference: `res://assets/source/ai/guides/sunwheat_ready_perspective_guide_512.png`
- Accepted candidate identifier: `exec-296d06fa-6382-4d27-b744-77bbf2c75051.png`
- Generation tool/model identifier: OpenAI built-in `image_gen` / built-in imagegen backend; exact backend model ID and version were not exposed
- Generation date (UTC): `2026-07-22T12:24:40Z`
- Seed and reproducibility parameters: not exposed by the built-in tool
- Requested dimensions: `512x512` in the locked positive prompt
- Delivered dimensions and mode: `1254x1254` RGB
- Accepted delivered-source SHA-256: `7AD66CAE94E614F48D75160A931F98E080C9254F55BF9F98714104556E83E7A7`
- Prepared source filename: `sunwheat_crop_ready_geometry_candidate_512.png`
- Prepared dimensions and mode: exact `512x512` lossless straight-alpha RGBA PNG
- Prepared SHA-256: `6E0063C55F5E8CFA00F2011F39F1A496A70F57993EFC3CD914E7914556594B81`
- Reviewers: Coder Agent and Human
- Review date (UTC): `2026-07-22`
- Disposition: Human-approved source-only final-perspective candidate; it does not replace, re-export, modify, or reference any existing source/runtime art

## Exact Locked Positive Prompt

`TopFarmer game sprite of a single naturally rooted mature Sunwheat plant with five to seven plump sun-gold grain heads, healthy green upright stalks and overlapping basal leaves, exactly one subordinate dusk-purple grain head, and stems that taper and disappear together behind the basal leaves into one continuous organic soil contact with no exposed cut stalk ends, harvest-ready geometry-guided final-perspective candidate, 2D hand-painted fantasy cartoon, cozy rural warmth with a restrained mysterious undertone, top-down orthogonal square ground plane with a high-angle front-elevated farm-game sprite presentation for subjects with height, vertical forms rising upward on screen from a bottom-center ground contact, clear readable front planes with modest visible top surfaces, near elements lower and larger and rear elements higher and smaller, readable mobile silhouette, TopFarmer locked v1 palette, key light from upper left at 35 degrees, subtle dark-plum outline, tile-filling opaque square canvas for flat terrain or isolated on transparent background for object sprites, centered on a 512 by 512 canvas, no text`

Only the four allowed recipe placeholders were substituted. No word was added to or removed from the locked template.

## Exact Locked Negative Prompt

`photorealism, 3D render, anime, pixel art, horror, gore, neon, glossy plastic, isometric projection, diamond tile, 30-degree isometric axes, diagonal grid movement, fisheye, straight-down view for upright subjects, flat radial rosette, low eye-level front view, pure side view, inconsistent perspective, multiple objects, scenery, background, baked cast shadow, cropped edges, text, watermark`

The locked negative string was passed verbatim and unchanged.

## Accepted Generation Inputs

The accepted revision used two actual visual inputs:

1. Edit target: rejected first guided attempt `exec-0b35a424-49b9-4f6c-bc4c-e57ba3b6a9e4.png`
2. Mandatory composition reference: `res://assets/source/ai/guides/sunwheat_ready_perspective_guide_512.png`

The exact accepted operational request, outside the unchanged locked positive and negative strings above, was:

`Change only the perspective, foreshortening, and overlap so the crop reads as a high-angle front-elevated farm-game sprite instead of an eye-level botanical bouquet. Compress the vertical stalk presentation. Tilt and foreshorten every grain head so modest top surfaces are clearly visible. Make the lower foreground leaves and lower central heads visibly larger and nearer, with short front planes; keep the rear heads smaller and higher, visibly behind the middle layer. Follow Image 2's foreground/middle/rear layout and centered contact. Preserve the same hand-painted materials and one organic crown.`

The exact accepted invariants were:

`Keep exactly six sun-gold grain heads and exactly one smaller subordinate dusk-purple grain head. Keep healthy green overlapping leaves, subtle dark-plum outlines, upper-left lighting, and one continuous leaf-covered bottom-center crown. Keep every stem tapered or hidden into that crown. No cut ends, binding, pot, roots, soil, face, shadow, scenery, labels, guide marks, or text. Do not shift the planted axis away from center.`

The exact accepted operational chroma instruction was:

`Render exactly one isolated opaque crop subject on a perfectly flat solid #ff00ff chroma-key background for lossless background removal. The background must be one uniform color with no shadows, gradients, texture, reflections, floor plane, or lighting variation. Keep the crop fully separated from the background with crisp edges and generous safe padding. Do not use #ff00ff anywhere in the crop. No cast shadow, no contact shadow, no reflection, no watermark, and no text.`

The exact accepted task-derived rejection instruction was:

`Eye-level bouquet, tall floral arrangement, upright unforeshortened head columns, pure side view, straight-down radial rosette, starburst, disconnected head pile, several plants, cut stalk ends, or multiple ground contacts.`

The tool was also told that Image 1 was the edit target and Image 2 was the strict geometry/perspective guide. The guide's centered ground contact, converging crown, foreground/middle/rear regions, relative sizes, vertical positions, and overlap order were used as composition authority. Its letters, labels, arrows, safe envelope, diagnostic colors, and exact geometric outlines were excluded from the generated artwork.

## Generation Attempts

1. Rejected `exec-0b35a424-49b9-4f6c-bc4c-e57ba3b6a9e4.png`, generated `2026-07-22T12:22:39Z`, delivered `1254x1254` RGB, SHA-256 `CE4D354B9B1CB6196A6CADEAB363DE30E11EC390B985828BC8144155B571BCDA`. It used the guide directly and correctly produced six gold heads, one purple head, and one organic crown, but its tall unforeshortened head columns remained too eye-level and bouquet-like, with insufficient top-plane visibility.
2. Accepted `exec-296d06fa-6382-4d27-b744-77bbf2c75051.png`, generated `2026-07-22T12:24:40Z`, delivered `1254x1254` RGB, SHA-256 `7AD66CAE94E614F48D75160A931F98E080C9254F55BF9F98714104556E83E7A7`. It retained the guide as an actual reference and corrected only perspective/foreshortening: larger lower foreground leaves, overlapping central heads, and smaller higher rear heads with visible top surfaces now form a compact bottom-to-top depth stack.

## Permitted Preparation

The installed imagegen chroma helper sampled the generated border as `#f902f5`. A default `12..220` despill extraction was rejected because it turned the required dusk-purple head gray. A no-despill `8..80` comparison was also not admitted. The accepted extraction used border-derived automatic keying, a soft matte with thresholds `12..120`, no despill, and one-pixel alpha edge contraction; this preserved the purple head while removing the magenta field and visible fringe.

The full `1254x1254` extracted transparent canvas received exactly one Pillow `12.2.0` `Image.Resampling.LANCZOS` resize to `512x512`. The central generated crown contact measured `(636,1134)` in the delivered canvas. One whole-image translation `(-4,+2)` placed that contact at `(256,465)`, after which RGB was cleared only where alpha was zero.

No crop, per-part move, stretch, warp, mirror, rotate, sharpen, hand-paint, redraw, recolor, composite-candidate repair, shadow, or base repair was used. The rejected extraction comparisons and generated chroma source remain outside the repository.

## Prepared PNG Verification

- PNG format and mode: lossless straight-alpha `RGBA`
- Dimensions: exact `512x512`
- SHA-256: `6E0063C55F5E8CFA00F2011F39F1A496A70F57993EFC3CD914E7914556594B81`
- Alpha extrema: `(0,255)`
- Occupied alpha bounds above `0`: x=`64..447`, y=`63..477`; margins left/top/right/bottom=`64/63/64/34`
- Occupied alpha bounds above `8`: x=`66..444`, y=`65..475`; margins left/top/right/bottom=`66/65/67/36`
- Four corner alpha values: `(0,0,0,0)`
- Painted canvas-edge pixels: `0`
- Hidden RGB maximum where alpha is zero: `0`
- Ground contact: exact `(256,465)` at the central leaf-covered crown; meaningful-alpha row y=`465` intersects the central axis at x=`255..256`
- Meaningful alpha above `8`: exactly one 8-connected component containing `93,608` pixels
- Exact temporary one-pass `256x256` Lanczos reduction PNG SHA-256: `F586A13F5858D028B79BEBB3E8969F3A7E20CDDDC7881A9659493ECB9AF7063C`
- Fractional contact in the reduction: `(128,232.5)`; it was not rounded or used to alter the candidate
- Separate shadow: none
- Baked shadow: none

Godot import is lossless with mipmaps disabled, no size limit, identity RGBA channel mapping, no premultiplied alpha, and no normal-map or HDR conversion.

## Guide and Perspective Rejection Checklist

- [x] Six sun-gold heads and exactly one smaller subordinate dusk-purple head follow the seven guide regions.
- [x] Larger/lower foreground leaves overlap stalks and the lower edges of the middle heads.
- [x] Middle heads carry the primary mass and overlap both foreground and rear layers.
- [x] Smaller/higher rear heads show modest top-facing surfaces and sit visibly behind the middle layer.
- [x] Stalks taper or disappear behind overlapping leaves into one continuous centered crown at `(256,465)`.
- [x] The silhouette remains one connected plant at `512x512` and in the exact `256x256` diagnostic reduction.
- [x] The crop does not read as an eye-level bouquet, pure side view, straight-down radial rosette/starburst, isometric/diamond arrangement, disconnected head pile, or several separate plants.
- [x] There is no cut stalk end, tie, pot rim, exposed root, soil patch, multiple contact, face, text, background, contact shadow, or cast shadow.
- [x] Form lighting reads from upper left, with a subtle dark-plum outline and healthy TopFarmer-derived greens/golds.

## External Diagnostics

All diagnostics remain outside the repository under `C:\Users\robbi\.codex\visualizations\2026\07\21\019f8697-64ec-7101-985f-b221282805a7\topfarmer-task026\`:

- Native neutral view: `topfarmer_task026_candidate_neutral_512.png`, `512x512` RGB, SHA-256 `7C4AE7172E3739394E3DE789695A8F525E39EA6C60CF1EAC25D0AE9489A0DA8E`
- Partial-opacity guide overlay: `topfarmer_task026_guide_overlay_512.png`, `512x512` RGB, SHA-256 `DF6FCD4FC40C3B41B28A6EB5FFD171F2CF0A4B1B6680B838953AC2109D768FBC`
- Farm context: `topfarmer_task026_farm_context_540x960.png`, `540x960` RGB, SHA-256 `DBCC7E6F215DF0D572B627E4BA97A5C2548DC91913DAFC4A998FFDA6DE735C40`

The farm diagnostic repeats the unchanged approved `128x128` meadow tile, places the unchanged approved `256x256` empty soil plot at `(142,352)`, and places one exact in-memory `256x256` Lanczos reduction of this candidate at the identical coordinate. The candidate contact lands at portrait point `(270,584.5)`. No runtime crop, shadow, scene offset, or project asset was created or changed.

## Human Review

On `2026-07-22`, the Human approved the `540x960` farm-context and partial-opacity guide-overlay diagnostics. The crop reads as one plant rising from one natural base rather than a bouquet, flat rosette, or several plants; its larger/lower foreground leaves, overlapping middle heads, and smaller/higher rear heads provide the required bottom-to-top depth; exactly one purple head remains subordinate; and the candidate follows the guide's centered crown and near/middle/far regions without clipping or visual lean.

This approval permits a later task to author the separate shadow and runtime export. It does not integrate the candidate, replace the current placeholder, revise FarmPlot alignment, or authorize any gameplay/configuration change.
