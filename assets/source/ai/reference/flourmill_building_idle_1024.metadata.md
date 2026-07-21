LOCKED FOR v1 - changes require a new PM decision

# Flourmill Idle Building Reference Metadata

## Generation Metadata

- Recipe version: `TF-ART-v1.1`
- Approved data ID: `flourmill`
- Asset role: `building`
- State or variant: `idle newly built production building`
- Generation tool/model identifier: OpenAI built-in `image_gen` / built-in imagegen backend; the exact backend model ID and version were not exposed by the tool response
- Generation date (UTC): `2026-07-21T11:22:43Z`
- Seed and reproducibility parameters: not exposed by the built-in tool
- Accepted source candidate: `exec-06fc4658-56cb-473a-8656-b0c178de5cc6.png`
- Original delivered dimensions and mode: `1254x1254`, opaque RGB on generated flat magenta chroma key
- Style references: `sunwheat_crop_ready_512.png` and `meadow_grass_tile_default_256x256.png`, used only for approved palette, brushwork, outline, and lighting direction
- Color filename: `flourmill_building_idle_1024.png`
- Shadow filename: `flourmill_shadow_idle_1024.png`
- Final canvases: `1024x1024` pixels for both PNGs
- Alpha: lossless straight-alpha RGBA PNG; fully transparent pixels have zero RGB
- Shared bottom-center ground-contact point: `(512, 897)` pixels, origin at canvas top left
- Color occupied bounds above alpha 8: `(188, 132)` through `(833, 897)` inclusive
- Shadow occupied bounds above alpha 8: `(243, 872)` through `(795, 992)` inclusive
- Color SHA-256: `01FAAAFE6080CCC8A2FD0E87DFA6FD6F32CA7B3C10204172694A1A1DFCDA6DD4`
- Shadow SHA-256: `EB3367142B55B5BF52E1D19E479EF0083DCF079FD2165B6D6B7067697962301E`
- Reviewer: Coder Agent
- Review date (UTC): `2026-07-21`
- Disposition: accepted source reference only; not admitted as a runtime asset

## Exact Resolved Positive Prompt

`TopFarmer game sprite of flourmill building, a compact warm weathered-timber and moss-touched-stone windmill with a broad weathered shingle roof, a short four-sail wheel mounted high on its small front face, a small door and window, sun-gold grain accents, and one faint dusk-purple reflection in the window, idle newly built production building, 2D hand-painted fantasy cartoon, cozy rural warmth with a restrained mysterious undertone, mostly overhead top-down farm-game view with a slight downward angle, screen-aligned orthogonal ground plane, visible top surfaces and a small front face where the subject has height, readable mobile silhouette, TopFarmer locked v1 palette, key light from upper left at 35 degrees, subtle dark-plum outline, tile-filling opaque square canvas for terrain or isolated on transparent background for object sprites, centered on a 1024 by 1024 canvas, bottom-center ground contact aligned where applicable, no text`

## Exact Negative Prompt

`photorealism, 3D render, anime, pixel art, horror, gore, neon, glossy plastic, isometric projection, diamond tile, 30-degree isometric axes, diagonal grid movement, fisheye, front view, side view, inconsistent perspective, multiple objects, scenery, background, baked cast shadow, cropped edges, text, watermark`

## Candidate Review and Straight-Alpha Preparation

The first generated candidate was rejected because it read as a straight-on elevation and placed the wheel across the roof. The second candidate corrected the overhead view but was rejected by the user because the wheel was too small and the roof overwhelmed the rest of the building. The accepted third candidate keeps the roof as the largest overhead plane while giving the shallow façade more presence and enlarging the four-sail wheel to a primary mobile-readable feature. Neither rejected candidate is stored in the repository.

The accepted candidate used a uniform generated magenta key sampled as `#f503f2`. The installed image-generation helper removed it with border auto-keying, soft matte, transparent threshold `12`, opaque threshold `220`, and despill. The result was resized from `1254x1254` to the exact `1024x1024` master with Lanczos filtering. Hidden RGB was cleared wherever alpha is zero. Visual and pixel review found transparent corners, clean antialiased edges, no opaque matte, and no magenta-like opaque pixels.

## Separate Shadow and Alignment Method

The shadow was derived deterministically from the accepted final color alpha, not independently generated. The shared ground-contact point is `(512, 897)`. Color alpha was compressed toward that point and projected down and right, scaled to partial alpha, and softened with an `11`-pixel Gaussian blur. A low soft contact ellipse centered on the same point was added with a `10`-pixel Gaussian blur. The two alpha components were combined and rendered only in neutral cool gray RGB `(83, 86, 101)` with maximum alpha `107`.

The shadow file contains no color-sprite pixels or copied building color. Both PNGs use the same canvas and ground-contact coordinate; the color is opaque enough at `(512, 897)` to define the contact and the shadow is partially opaque there, so layering the color over the shadow does not jump or drift.

## Ready for Reference Generation Checklist Results

- [x] The `flourmill` data ID, building role, idle newly built state, and DEC-020 content direction were approved.
- [x] DEC-017 and TF-ART-v1.1 define the mostly overhead orthogonal square-grid presentation.
- [x] The locked building master canvas `1024x1024` was selected.
- [x] Only the four permitted positive-prompt placeholders were substituted; the locked negative prompt is unchanged.
- [x] The metadata captures the available tool/model identifier, unavailable version and seed, UTC date, candidate, style references, dimensions, files, and preparation settings.

## Reference Admission Checklist Results

- [x] Both files are lossless straight-alpha PNGs on exact `1024x1024` canvases with fully transparent corners and comfortable margins.
- [x] The color sprite shows one compact warm weathered-timber and moss-touched-stone Flourmill.
- [x] The broad weathered shingle roof remains the largest overhead plane without overwhelming the façade.
- [x] One enlarged short four-sail wheel is mounted high on the shallow front face and remains legible at mobile size.
- [x] The small door, small window, sparse sun-gold grain accents, and one faint dusk-purple window reflection are present.
- [x] The building reads mostly from above with a slight downward angle; the shallow front face establishes height while the footprint remains screen-aligned.
- [x] The color sprite has no isometric projection, diamond footprint, 30-degree axes, straight-on elevation, or directional grid geometry.
- [x] Upper-left form lighting, subtle dark-plum outline, locked-palette control, cozy warmth, and restrained magical tone are present.
- [x] The color sprite contains no baked cast/contact shadow, scenery, background, opaque matte, text, watermark, copied Stardew Valley design, neon, or horror framing.
- [x] The shadow contains only soft partial-alpha neutral cool gray, falls down and right, and has no building color, background, hard black edge, text, or watermark.
- [x] The color and shadow share bottom-center ground contact `(512, 897)` and remain clear of all canvas edges.
- [x] Both lowercase snake_case filenames follow the locked source naming pattern.
- [x] No file was added under `assets/sprites/`, and no game scene or code references either source image.
