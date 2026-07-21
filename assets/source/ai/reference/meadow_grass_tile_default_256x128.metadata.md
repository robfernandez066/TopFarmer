LOCKED FOR v1 - changes require a new PM decision

# Meadow Grass Terrain Reference Metadata

## Generation Metadata

- Recipe version: `TF-ART-v1`
- Approved data ID: `meadow_grass`
- Asset role: `terrain tile`
- State or variant: `default farm-ground diamond`
- Generation tool/model identifier: OpenAI built-in `image_gen` / built-in imagegen backend; the exact backend model ID was not exposed by the tool response
- Generation date (UTC): `2026-07-21T10:17:29Z`
- Seed and reproducibility parameters: not exposed by the built-in tool
- Original generated candidate: `exec-f73003bf-4b33-45ef-8037-7ba46d13f489.png`
- Original delivered dimensions: `1774x887`
- Style-reference source: `sunwheat_crop_ready_512.png`, approved by DEC-015
- Tile filename: `meadow_grass_tile_default_256x128.png`
- Preview filename: `meadow_grass_tile_preview_768x384.png`
- Tile canvas: `256x128` pixels
- Preview canvas: `768x384` pixels
- Alpha: straight-alpha transparent PNG; tile pixels are fully opaque inside the diamond and fully transparent outside it
- Tile pivot coordinates: `(128, 127)` pixels, origin at canvas top left
- Tile SHA-256: `C6DF036D8DC96CF05E9769E1FBFEC7778A533C36494CD0C8FE06354D12DD87E0`
- Preview SHA-256: `8BCA55F7ECF2014CF60330081667D767A5EE3DA1BEF131F7B1A09F673550ECAA`
- Reviewer: Coder Agent
- Review date (UTC): `2026-07-21`
- Disposition: accepted source reference only; not admitted as a runtime asset

## Exact Resolved Positive Prompt

`TopFarmer game sprite of meadow grass terrain tile, warm soft turf with small moss clusters, sparse sun-gold dry blades, and a few moon-blue dew flecks that almost form a pattern, seamless default farm-ground diamond with no objects, 2D hand-painted fantasy cartoon, cozy rural warmth with a restrained mysterious undertone, angled top-down three-quarter orthographic view, readable mobile silhouette, TopFarmer locked v1 palette, key light from upper left at 35 degrees, subtle dark-plum outline, isolated on transparent background, centered on a 256 by 128 canvas, bottom-center ground contact aligned, no text`

## Unchanged Negative Prompt

`photorealism, 3D render, anime, pixel art, horror, gore, neon, glossy plastic, fisheye, front view, side view, inconsistent perspective, multiple objects, scenery, background, baked cast shadow, cropped edges, text, watermark`

## Tile Construction and Seam Method

The built-in generator produced a hand-painted meadow texture candidate using the approved Sunwheat reference as the visual anchor. A centered square texture region was selected, resized with Lanczos filtering, and made periodic before diamond sampling. Opposite edge bands were paired with a cosine crossfade so the left/right and top/bottom texture values agree at their respective wrap boundaries without introducing a dominant central feature.

The periodic square was then sampled through rhombus coordinates into the exact `256x128` terrain canvas. A binary diamond matte places its four points at the canvas-edge midpoints `(128, 0)`, `(255, 64)`, `(128, 127)`, and `(0, 64)`. Boundary pixels use a one-pixel overlap where adjacent staggered diamonds meet so repetition cannot expose transparent cracks. The bottom point is the locked pivot `(128, 127)`.

The `768x384` diagnostic preview was composed only from nine unchanged copies of the final tile. For copy indices `i,j = 0..2`, each tile was placed at `(256 + (i-j)*128, (i+j)*64)`. No color, paint, background, seam repair, or overlay was added to the preview after composition.

At user review, the small leaf and blade marks were judged slightly too rough. Two built-in generative edit variants were inspected and rejected because they repainted motifs and shifted the color balance. The approved tile instead received a deterministic `0.42`-pixel Gaussian softening of RGB detail across a surrounding periodic repetition field. The original binary alpha matte was then restored byte-for-byte, transparent RGB was cleared to zero, and the preview was rebuilt from nine copies of the softened tile. This keeps the requested softening sub-pixel, preserves every motif and the crisp diamond silhouette, and prevents edge sampling from introducing a seam.

## Ready for Reference Generation Checklist Results

- [x] The `meadow_grass` subject, terrain-tile role, default state, and visual direction were approved by DEC-016.
- [x] The locked tile canvas `256x128`, preview canvas `768x384`, and pivot `(128, 127)` were used.
- [x] Only the permitted prompt fields were resolved; the locked negative prompt is unchanged.
- [x] The metadata records the available tool/model identifier, UTC date, seed status, source candidate, filenames, dimensions, pivot, and construction method.
- [x] The DEC-015 Sunwheat source reference was used as the visual anchor.

## Reference Admission Checklist Results

- [x] The tile is a lossless straight-alpha PNG on an exact `256x128` canvas.
- [x] The tile is a clean `2:1` diamond with its four points at the canvas-edge midpoints and transparent pixels outside the diamond.
- [x] The pivot pixel `(128, 127)` is opaque and aligned to the diamond's bottom point.
- [x] The turf reads as warm leaf-and-moss grass with sparse sun-gold dry blades.
- [x] Moon-blue dew flecks are present but remain sparse and only almost form a pattern; they do not read as a rune or symbol.
- [x] The tile contains no object, scenery, text, watermark, neon effect, horror treatment, or baked cast shadow.
- [x] Repetition was visually inspected without gaps, dark seams, edge mismatch, or a dominant repeated motif.
- [x] Leaf and blade micro-edges received only the approved slight softening; composition, palette, alpha silhouette, and seamless correspondence remain unchanged.
- [x] The preview is an exact staggered `3x3` repetition of the tile and contains no additional image content.
- [x] The filenames follow the locked lowercase snake_case naming pattern.
- [x] No file was added under `assets/sprites/`, and no game scene or code references either source image.
