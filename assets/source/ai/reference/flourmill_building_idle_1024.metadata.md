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
- Replacement shadow occupied bounds above alpha 8: `(225, 832)` through `(802, 954)` inclusive
- Color SHA-256: `01FAAAFE6080CCC8A2FD0E87DFA6FD6F32CA7B3C10204172694A1A1DFCDA6DD4`
- Replacement shadow SHA-256: `4B8B3448B91B8D802052E52329BB30A11D45BE697E6E0A937E69F6D59EF0316B`
- Superseded commit `2bf679e` shadow SHA-256: `EB3367142B55B5BF52E1D19E479EF0083DCF079FD2165B6D6B7067697962301E`; Human-check rejected under DEC-021 because its broad lower slab made the building appear to float
- Reviewer: Coder Agent
- Review date (UTC): `2026-07-21`
- Disposition: approved color preserved; DEC-021 replacement shadow passes Coder composite review and is ready for Human check; source reference only, not admitted as a runtime asset

## Exact Resolved Positive Prompt

`TopFarmer game sprite of flourmill building, a compact warm weathered-timber and moss-touched-stone windmill with a broad weathered shingle roof, a short four-sail wheel mounted high on its small front face, a small door and window, sun-gold grain accents, and one faint dusk-purple reflection in the window, idle newly built production building, 2D hand-painted fantasy cartoon, cozy rural warmth with a restrained mysterious undertone, mostly overhead top-down farm-game view with a slight downward angle, screen-aligned orthogonal ground plane, visible top surfaces and a small front face where the subject has height, readable mobile silhouette, TopFarmer locked v1 palette, key light from upper left at 35 degrees, subtle dark-plum outline, tile-filling opaque square canvas for terrain or isolated on transparent background for object sprites, centered on a 1024 by 1024 canvas, bottom-center ground contact aligned where applicable, no text`

## Exact Negative Prompt

`photorealism, 3D render, anime, pixel art, horror, gore, neon, glossy plastic, isometric projection, diamond tile, 30-degree isometric axes, diagonal grid movement, fisheye, front view, side view, inconsistent perspective, multiple objects, scenery, background, baked cast shadow, cropped edges, text, watermark`

## Candidate Review and Straight-Alpha Preparation

The first generated candidate was rejected because it read as a straight-on elevation and placed the wheel across the roof. The second candidate corrected the overhead view but was rejected by the user because the wheel was too small and the roof overwhelmed the rest of the building. The accepted third candidate keeps the roof as the largest overhead plane while giving the shallow façade more presence and enlarging the four-sail wheel to a primary mobile-readable feature. Neither rejected candidate is stored in the repository.

The accepted candidate used a uniform generated magenta key sampled as `#f503f2`. The installed image-generation helper removed it with border auto-keying, soft matte, transparent threshold `12`, opaque threshold `220`, and despill. The result was resized from `1254x1254` to the exact `1024x1024` master with Lanczos filtering. Hidden RGB was cleared wherever alpha is zero. Visual and pixel review found transparent corners, clean antialiased edges, no opaque matte, and no magenta-like opaque pixels.

## Separate Shadow and Alignment Method

The broad projected shadow committed in `2bf679e` was rejected by the Human check and DEC-021 because it read as a detached lower slab. It is not retained in the replacement PNG.

The replacement was constructed deterministically without changing, moving, scaling, cropping, or regenerating the approved color sprite. Its tight contact component is an approximately `560x72` ellipse spanning pre-blur coordinates x=`232..792`, y=`842..914`, centered at `(512, 878)`, filled to alpha `84`, and softened with an `8`-pixel Gaussian blur. This begins behind and overlaps the stone foundation instead of starting below it. The shared bottom-center ground-contact point remains `(512, 897)`, where replacement shadow alpha is `83`.

A subordinate cast component uses a lighter alpha `28` ellipse at x=`352..806`, y=`864..944`, softened with an `18`-pixel Gaussian blur. It overlaps the contact component continuously while shifting its centroid down and right to approximately `(579, 904)`, so it cannot become a detached lobe. The components are combined by maximum alpha and rendered only in neutral cool gray RGB `(83, 86, 101)`. Nontransparent alpha fades continuously from `1` through a peak of `84`; every pixel remains partially transparent.

The shadow file contains no color-sprite pixels or copied building color. A temporary review composite placed the unchanged color over the replacement shadow at identical `1024x1024` coordinates on the approved meadow. The contact remained visible beneath the foundation with no transparent gap, while the lighter attached extension read down and right without forming a platform or puddle.

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
- [x] The original `2bf679e` broad shadow is marked Human-check rejected under DEC-021 and is absent from the replacement file.
- [x] The replacement contact is centered at `(512, 878)`, overlaps the foundation across its prescribed pre-blur bounds, peaks at alpha `84`, and fades continuously.
- [x] The lighter cast remains attached and subordinate; it does not form a platform, puddle, second footprint, or detached lobe.
- [x] The color and shadow share bottom-center ground contact `(512, 897)` and remain clear of all canvas edges.
- [x] The unchanged color SHA-256 remains `01FAAAFE6080CCC8A2FD0E87DFA6FD6F32CA7B3C10204172694A1A1DFCDA6DD4`.
- [x] Both lowercase snake_case filenames follow the locked source naming pattern.
- [x] No file was added under `assets/sprites/`, and no game scene or code references either source image.
