LOCKED FOR v1 - changes require a new PM decision

# Meadow Grass Square Terrain Reference Metadata

## Generation Metadata

- Recipe version: `TF-ART-v1.1`
- Approved data ID: `meadow_grass`
- Asset role: `terrain tile`
- State or variant: `seamless default square farm-ground tile with no objects`
- Generation tool/model identifier: OpenAI built-in `image_gen` / built-in imagegen backend; the exact backend model ID was not exposed by the tool response
- Generation date (UTC): `2026-07-21T10:53:13Z`
- Seed and reproducibility parameters: not exposed by the built-in tool
- Approved generated candidate: `exec-e2b8a58b-8f80-479a-9604-6075ea31df16.png`
- Original delivered dimensions and mode: `1254x1254`, opaque RGB
- Style-reference source: `sunwheat_crop_ready_512.png`, approved by DEC-015; used only for palette discipline, brushwork, lighting, and restrained magical tone
- Tile filename: `meadow_grass_tile_default_256x256.png`
- Preview filename: `meadow_grass_tile_preview_768x768.png`
- Tile canvas: `256x256` pixels
- Preview canvas: `768x768` pixels
- Alpha: fully opaque PNG; alpha extrema are `(255, 255)`, including every corner and edge pixel
- Terrain pivot: not applicable to the screen-aligned square ground tile
- Tile SHA-256: `77C4A439D50F61710FF89DEFFEE3FE2EEF8DFECDAA9BA3972F1E0C0FC43A4D8F`
- Preview SHA-256: `EAF3889EC6368847C860F85D0C1087D937067CD9EE174026FFCA3619A6C94DE5`
- Reviewer: Coder Agent
- Review date (UTC): `2026-07-21`
- Disposition: accepted source reference only; not admitted as a runtime asset

## Exact Resolved Positive Prompt

`TopFarmer game sprite of meadow grass terrain tile, warm soft turf with small moss clusters, sparse sun-gold dry blades, and a few moon-blue dew flecks that almost form a pattern, seamless default square farm-ground tile with no objects, 2D hand-painted fantasy cartoon, cozy rural warmth with a restrained mysterious undertone, mostly overhead top-down farm-game view with a slight downward angle, screen-aligned orthogonal ground plane, visible top surfaces and a small front face where the subject has height, readable mobile silhouette, TopFarmer locked v1 palette, key light from upper left at 35 degrees, subtle dark-plum outline, tile-filling opaque square canvas for terrain or isolated on transparent background for object sprites, centered on a 256 by 256 canvas, bottom-center ground contact aligned where applicable, no text`

## Exact Negative Prompt

`photorealism, 3D render, anime, pixel art, horror, gore, neon, glossy plastic, isometric projection, diamond tile, 30-degree isometric axes, diagonal grid movement, fisheye, front view, side view, inconsistent perspective, multiple objects, scenery, background, baked cast shadow, cropped edges, text, watermark`

## Generation, Square Seam, and Preview Method

The built-in generator produced a full-square, mostly overhead meadow texture using the approved Sunwheat source only as a style reference. The first generated square was rejected because its bright gold clumps, blue flecks, and round leaf rosettes were too frequent and formed dominant motifs. A targeted built-in edit reduced those elements and replaced them with quieter warm moss-and-leaf turf; only the accepted edited candidate is named above.

The accepted source was center-cropped to a square and resized to a `512x512` working canvas with Lanczos filtering. Broad tile-scale lighting variation was suppressed while retaining local painted leaf, moss, blade, and dew detail, and the base was normalized toward the locked moss-and-leaf palette. Opposite left/right and top/bottom edge bands were paired through a narrow cosine crossfade, making the square texture periodic without a border or low-contrast seam band. The periodic working image was then downsampled with Lanczos to the exact opaque `256x256` master. Mean absolute mismatch between opposing final edge pixels is below `0.11` RGB levels per channel in both directions.

The `768x768` diagnostic preview was composed only by placing nine unchanged copies of the final `256x256` tile at direct square-grid offsets `(x*256, y*256)` for `x,y = 0..2`. No paint, color adjustment, overlay, seam repair, grid line, or other image content was added to the preview.

## Ready for Reference Generation Checklist Results

- [x] The `meadow_grass` data ID, terrain-tile role, default square state, and DEC-016 content direction were approved.
- [x] DEC-017 and DEC-018 approve the mostly overhead orthogonal square-grid direction and exact `256x256` terrain master.
- [x] The updated `TF-ART-v1.1` locked canvas and prompt templates were used.
- [x] Only the four permitted placeholders were substituted in the positive prompt; the updated negative prompt is unchanged.
- [x] The metadata records the available tool/model identifier, UTC date, seed status, candidate, filenames, dimensions, and construction methods.
- [x] The DEC-015 Sunwheat source was used only as the approved palette and brushwork anchor, not as copied subject geometry.

## Reference Admission Checklist Results

- [x] The tile is a lossless opaque PNG on an exact `256x256` square canvas.
- [x] Every tile pixel, edge, and corner is opaque; there is no border, diamond silhouette, or transparent corner.
- [x] The artwork uses a mostly overhead, slightly angled farm-game view on a screen-aligned orthogonal ground plane.
- [x] The tile has no isometric projection, diamond tile, 30-degree isometric axes, diagonal grid, or directional perspective lines.
- [x] The turf reads as warm leaf-and-moss grass with sparse sun-gold dry blades.
- [x] Moon-blue dew flecks remain few and subtle, almost suggesting a loose pattern without forming a symbol or rune.
- [x] The tile contains no object, scenery, flower, stone, path, text, watermark, neon effect, hard shadow, or horror imagery.
- [x] Direct square repetition was visually inspected without a gap, dark seam, mismatched edge color, or dominant repeated motif.
- [x] The preview is an exact direct `3x3` square repetition of the final tile and contains no additional image content.
- [x] The former `256x128` diamond tile, `768x384` preview, old metadata, and their import sidecars are absent.
- [x] The new filenames follow the locked lowercase snake_case naming pattern.
- [x] No file was added under `assets/sprites/`, and no game scene or code references either source image.
