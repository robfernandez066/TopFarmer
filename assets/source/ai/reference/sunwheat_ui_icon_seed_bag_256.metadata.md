LOCKED FOR v1 - changes require a new PM decision

# Sunwheat Seed-Bag UI Reference Metadata

## Generation Metadata

- Recipe version: `TF-ART-v1.1`
- Approved data ID: `sunwheat`
- Asset role: `UI icon`
- State or variant: `default plant-selection symbol`
- Generation tool/model identifier: OpenAI built-in `image_gen` / built-in imagegen backend; the exact backend model ID and version were not exposed by the tool response
- Generation date (UTC): `2026-07-21T12:00:05Z`
- Seed and reproducibility parameters: not exposed by the built-in tool
- Accepted source candidate: `exec-2c276ad3-01c8-4b32-a6c5-529c421dadfd.png`
- Original delivered dimensions and mode: `1254x1254`, opaque RGB on generated flat magenta chroma key
- Style references: `sunwheat_crop_ready_512.png`, `meadow_grass_tile_default_256x256.png`, and `flourmill_building_idle_1024.png`, used only for approved palette, brushwork, outline, lighting direction, and TopFarmer presentation
- Source filename: `sunwheat_ui_icon_seed_bag_256.png`
- Diagnostic preview filename: `sunwheat_ui_icon_seed_bag_preview_512x256.png`
- Final source canvas: `256x256` pixels
- Diagnostic preview canvas: `512x256` pixels
- Alpha: lossless straight-alpha RGBA PNG; fully transparent pixels have zero RGB
- Source occupied bounds above alpha `8`: `(51, 32)` through `(204, 223)` inclusive
- Source alpha bounding box above alpha `0`: `(48, 30)` through `(207, 225)` inclusive
- Pivot and ground contact: not applicable to this UI-only icon; the icon has no ground plane or shadow
- Source SHA-256: `39CCB0D72DE061C279951E56706D948A42477667D03966F47E30B43ACC4E375D`
- Preview SHA-256: `40A29EE0D3FF29BA3B8D1FD58FC6EA24FBBE92DCCBA6725947F07E7F9299D07E`
- Reviewer: Coder Agent
- Review date (UTC): `2026-07-21`
- Disposition: Coder visual and pixel review passed; ready for Human check; source reference only, not admitted as a runtime asset

## Exact Resolved Positive Prompt

`TopFarmer game sprite of sunwheat seed bag UI icon, a compact moss-green cloth pouch tied with warm tan cord and marked by one simple sun-gold wheat-head stitch, with one tiny dusk-purple repair thread, default plant-selection symbol, 2D hand-painted fantasy cartoon, cozy rural warmth with a restrained mysterious undertone, mostly overhead top-down farm-game view with a slight downward angle, screen-aligned orthogonal ground plane, visible top surfaces and a small front face where the subject has height, readable mobile silhouette, TopFarmer locked v1 palette, key light from upper left at 35 degrees, subtle dark-plum outline, tile-filling opaque square canvas for terrain or isolated on transparent background for object sprites, centered on a 256 by 256 canvas, bottom-center ground contact aligned where applicable, no text`

## Exact Negative Prompt

`photorealism, 3D render, anime, pixel art, horror, gore, neon, glossy plastic, isometric projection, diamond tile, 30-degree isometric axes, diagonal grid movement, fisheye, front view, side view, inconsistent perspective, multiple objects, scenery, background, baked cast shadow, cropped edges, text, watermark`

## Candidate Review and Straight-Alpha Preparation

The first candidate visually passed the icon criteria, but its embedded positive-prompt block shortened one locked TF-ART-v1.1 canvas clause. It was rejected before admission and is not stored in the repository. The accepted second candidate was generated with the exact resolved positive prompt and unchanged negative prompt above, followed only by task-specific constraints for a single readable pouch and a uniform chroma-key field.

The accepted candidate used a uniform generated magenta key sampled as `#fb02fa`. The installed image-generation helper removed it with border auto-keying, soft matte, transparent threshold `12`, opaque threshold `220`, and despill. The transparent result was cropped from source coordinates `(54, 37)` through `(1193, 1176)` inclusive to a centered `1140x1140` square, then resized to the exact `256x256` source with Lanczos filtering. This preserved the candidate without stretching while providing comfortable margins. Hidden RGB was cleared wherever alpha is zero.

Pixel review found alpha extrema `(0, 255)`, four fully transparent corners, `43,447` fully transparent pixels, `2,132` partially transparent antialias pixels, zero nonzero hidden-RGB channels, and zero opaque magenta-like pixels. The compact pouch remains wholly inside the canvas with no matte, background, cast shadow, contact shadow, or glow.

## Reduction and Diagnostic Preview Construction

The exact approved `256x256` straight-alpha source was reduced in memory to `128x128` and `64x64` with Lanczos filtering. The source, tied top, tan cord, and sun-gold wheat head remain recognizable without zooming at both reductions; the dusk-purple repair thread remains intentionally subordinate.

The `512x256` diagnostic PNG was built deterministically on the locked solid highlight color `#F6E7C1` and contains only alpha-composited copies derived from the approved source: the unchanged `256x256` source at `(0, 0)`, the `128x128` Lanczos reduction at `(288, 64)`, and the `64x64` Lanczos reduction at `(432, 96)`. The source occupies x=`0..255`, the medium reduction x=`288..415` and y=`64..191`, and the small reduction x=`432..495` and y=`96..159`. Every pixel outside their alpha footprints is exactly `#F6E7C1`. Pixel comparison against a fresh reconstruction is exact. The preview contains no label, text, frame, stretch, paint-over, or additional image content.

## Ready for Reference Generation Checklist Results

- [x] The `sunwheat` data ID, UI-icon role, default plant-selection state, and DEC-023 content direction were approved.
- [x] DEC-007, DEC-008, DEC-015, DEC-017, DEC-022, DEC-023, and TF-ART-v1.1 provide the required style, palette, perspective, provenance, and UI-symbol constraints.
- [x] The locked UI master canvas `256x256` and required `512x256` diagnostic preview were selected.
- [x] Only the four permitted positive-prompt placeholders were substituted; the locked negative prompt is unchanged.
- [x] Only the approved Sunwheat, meadow, and Flourmill references were supplied as style anchors.
- [x] The metadata records the available tool/model identifier, unavailable version and seed, UTC date, accepted candidate, dimensions, files, straight-alpha preparation, preview construction, hashes, reviewer, review date, and disposition.

## Reference Admission Checklist Results

- [x] The source is a lossless straight-alpha PNG on an exact `256x256` canvas with transparent corners, comfortable margins, zeroed hidden RGB, and no opaque matte or background.
- [x] The source shows exactly one compact moss-green cloth seed pouch with a single centered mobile-readable silhouette.
- [x] The gathered open top and warm tan tied cord remain distinct at `256x256`, `128x128`, and `64x64`.
- [x] One simple sun-gold wheat-head stitched emblem remains recognizable without zooming at both required reductions.
- [x] One short dusk-purple repair thread is present and visibly subordinate to the pouch and gold wheat emblem.
- [x] Restrained hand-painted detail, a subtle dark-plum outline, and upper-left form lighting match the approved TopFarmer references.
- [x] The icon contains no text, letters, numbers, extra object, face, scenery, button frame, cast shadow, contact shadow, glow, watermark, copied Stardew Valley design, neon, gore, horror framing, isometric grid, or diamond-tile geometry.
- [x] The `128x128` and `64x64` reductions were created from the approved source in memory with Lanczos filtering and were not stored as runtime exports.
- [x] The preview is an exact `512x256` diagnostic using only the approved source and its two reductions at the prescribed coordinates on solid `#F6E7C1`; it contains no stretch or text.
- [x] All three lowercase snake_case filenames follow the locked source naming pattern.
- [x] No file was added under `assets/sprites/`, and no game scene, script, resource, or project setting references either source image.
