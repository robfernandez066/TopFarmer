LOCKED FOR v1 - changes require a new PM decision

# Empty Tilled-Soil Plot Production Metadata

## Generation Metadata

- Recipe version: `TF-ART-v1.1`
- Approved data ID: `tilled_soil`
- Asset role: `farm-plot prop`
- State or variant: `empty prepared plot ready for planting`
- Generation workflow: OpenAI built-in `image_gen`
- Generation tool/model identifier: OpenAI built-in `image_gen` / built-in imagegen backend; the exact backend model ID and version were not exposed by the tool response
- Seed and reproducibility parameters: not exposed by the built-in tool
- Content candidate preceding the background-only edit: `exec-a4f3b335-4e6d-4c97-8328-e11dabc70cfc.png`
- Accepted generated candidate: `exec-a813f37d-d4d0-4a23-b9cc-d4db3b70dd53.png`
- Accepted-candidate generation date (UTC): `2026-07-21T14:01:32Z`
- Requested dimensions: `512x512` in the locked positive prompt; the built-in workflow exposed no separate size control
- Delivered candidate dimensions and mode: `1254x1254`, opaque RGB on a generated cyan chroma-key field
- Source filename: `tilled_soil_plot_empty_512.png`
- Runtime filename: `tilled_soil_plot_empty_256.png`
- Source canvas: `512x512`, lossless straight-alpha RGBA PNG
- Runtime canvas: `256x256`, lossless straight-alpha RGBA PNG
- Separate shadow: none; this flat ground-level plot has no baked, contact, or cast shadow
- Shared source ground-contact point: `(256, 465)` pixels, origin at canvas top left
- Shared runtime ground-contact point: `(128, 232.5)` pixels; the fractional y coordinate is intentional
- Source SHA-256: `976B948F5B79BCB578762FF51CF7CB3B1616E586E47496857C4CD540550A41CD`
- Runtime SHA-256: `1DAD2A9B2B2B8BB2F870A751E9D691FA5BE17069691BE5E465B9DF55A48B107E`
- Reviewer: Coder Agent
- Review date (UTC): `2026-07-21`
- Disposition: Coder technical, pixel, palette, perspective, and native-composite review passed; ready for the required Human check; neither PNG is referenced by a game screen, scene, script, resource, or project setting

## Exact Positive Prompt

`TopFarmer game sprite of tilled_soil farm-plot prop with one screen-aligned rounded-square patch of warm rich brown earth, five broad shallow horizontal furrows, softly irregular moss-touched edges, a few sun-gold dry crumbs, and one tiny dusk-purple pebble, empty prepared plot ready for planting, 2D hand-painted fantasy cartoon, cozy rural warmth with a restrained mysterious undertone, mostly overhead top-down farm-game view with a slight downward angle, screen-aligned orthogonal ground plane, visible top surfaces and a small front face where the subject has height, readable mobile silhouette, TopFarmer locked v1 palette, key light from upper left at 35 degrees, subtle dark-plum outline, tile-filling opaque square canvas for terrain or isolated on transparent background for object sprites, centered on a 512 by 512 canvas, bottom-center ground contact aligned where applicable, no text`

## Exact Negative Prompt

`photorealism, 3D render, anime, pixel art, horror, gore, neon, glossy plastic, isometric projection, diamond tile, 30-degree isometric axes, diagonal grid movement, fisheye, front view, side view, inconsistent perspective, multiple objects, scenery, background, baked cast shadow, cropped edges, text, watermark`

## Candidate Selection and Permitted Preparation

The built-in workflow generated one candidate at a time. Early candidates were rejected because they read as a raised bed or showed only four grooves. The accepted content candidate showed one flat, screen-aligned rounded-square footprint with exactly five shallow horizontal grooves. A final built-in background-only edit changed its removal field from magenta to cyan so chroma removal would preserve the required dusk-purple pebble; the accepted edited candidate above is the only candidate used to make the source and runtime files. No candidates were combined.

The installed image-generation chroma helper sampled the accepted candidate border as `#0CF7FD`, used border auto-keying, soft matte, transparent threshold `12`, opaque threshold `220`, and despill, and wrote an RGBA intermediate. The intermediate measured `1254x1254`, with alpha extrema `(0, 255)` and occupied alpha bounds `(116, 147)` through `(1135, 1108)` inclusive. The accepted artwork was then prepared only by cropping source coordinates `(65, 88)` through `(1184, 1207)` inclusive to a `1120x1120` square, resizing once with Pillow `12.2.0` `Image.Resampling.LANCZOS` to the exact `512x512` master, and clearing RGB wherever alpha was zero. The crop is horizontally centered on the generated footprint, provides the required transparent margins, and maps the lower center edge to the shared ground-contact area without stretching.

The runtime file was created only by one Pillow `12.2.0` `Image.Resampling.LANCZOS` downsample directly from the accepted `512x512` source to `256x256`, followed only by clearing RGB wherever alpha was zero. A fresh reconstruction from the committed source is pixel-exact with the committed runtime file. There was no sharpening, recoloring, repainting, geometric redraw, extra shift, candidate compositing, or added pixel content.

## Pixel and Alpha Verification

The `512x512` source has mode `RGBA`, alpha extrema `(0, 255)`, occupied bounds above alpha `0` of x=`21..491`, y=`24..468`, and occupied bounds above alpha `8` of x=`23..489`, y=`27..466`. Its fully transparent margins above alpha `0` are left=`21`, top=`24`, right=`20`, and bottom=`43` pixels. It contains `59,989` fully transparent pixels and `5,870` partially transparent antialias pixels. All four corners are `(0, 0, 0, 0)`, and zero fully transparent pixels contain hidden RGB. Alpha at the shared source ground-contact point `(256, 465)` is `8`, placing the lower center edge at the pivot area while keeping the canvas edge clear.

The `256x256` runtime has mode `RGBA`, alpha extrema `(0, 255)`, occupied bounds above alpha `0` of x=`9..246`, y=`11..235`, and occupied bounds above alpha `8` of x=`11..244`, y=`13..233`. It contains `14,222` fully transparent pixels and `3,013` partially transparent antialias pixels. All four corners are `(0, 0, 0, 0)`, and zero fully transparent pixels contain hidden RGB. At x=`128`, alpha is `118` on row `232` and `0` on row `233`, so the lower edge spans the intentionally fractional shared runtime ground-contact coordinate `(128, 232.5)`.

## Palette, Perspective, and Content Review

- Soil derived from `#7A4E3A` is the controlling and visibly dominant color. A subtle outline is derived from `#3E3840`; moss-derived edge touches, restrained sun-derived crumbs, and one subordinate dusk-derived pebble remain secondary. No competing palette dominates.
- The single footprint reads as a mostly overhead, flat, screen-aligned rounded square with all four sides parallel to the canvas edges. It does not read as a diamond, isometric rhombus, diagonal tile, perspective trapezoid, oval mound, raised box, platform, hole, or puddle.
- Exactly five broad shallow furrows run left to right and remain screen-horizontal. They remain countable at `256x256` without forming a grid, rune, text, face, diagonal grooves, or a separate cast shadow.
- Form light reads from the upper left with a restrained dark-plum outline. The sprite contains no baked halo or down-right cast shadow and requires no separate shadow sprite because the plot lies flush with the meadow.
- The sprite contains no crop, seed bag, plant, tool, character, building, button, scenery, writing, watermark, background, or extra object.

## Native Diagnostic Construction and Review

Two temporary `256x256` native-coordinate diagnostics were built outside the repository. Each directly repeats the approved `128x128` meadow runtime tile at `(0, 0)`, `(128, 0)`, `(0, 128)`, and `(128, 128)`, then alpha-composites the unchanged plot runtime at `(0, 0)`. The planted diagnostic additionally alpha-composites the corrected accepted Sunwheat runtime shadow at `(0, 0)` and the accepted Sunwheat runtime crop at `(0, 0)`, in that order. Neither diagnostic is committed.

Native-size review found that the empty plot lies flat on the meadow, remains visibly screen-aligned and rounded-square, and retains five readable furrows. In the planted diagnostic the corrected shadow contacts the lower leaves without a hover gap, while enough brown soil, border, and furrow detail remains visible around the crop to identify the prepared plot. The tiny dusk-purple pebble remains a quiet subordinate detail.

## Runtime Admission Checklist Results

- [x] The positive prompt is the exact TASK-013 locked prompt.
- [x] The negative prompt is the exact locked TF-ART-v1.1 negative prompt without additions or removals.
- [x] Complete available tool, candidate, time, dimension, processing, review, and disposition metadata is recorded.
- [x] The source and runtime are exact-size lossless straight-alpha RGBA PNGs with zero hidden RGB and four transparent corners.
- [x] Source margins exceed 16 fully transparent pixels on every canvas edge.
- [x] Palette, perspective, furrow count, lighting, outline, prohibited-content, alpha, and pivot checks pass.
- [x] The runtime is an exact one-pass Pillow 12.2.0 Lanczos derivative of the accepted source plus hidden-RGB clearing only.
- [x] Both Godot import sidecars use lossless texture import, disabled mipmaps, no size limit, no premultiplied alpha, and unchanged normal-map, HDR, and channel-remap settings.
- [x] No existing source or runtime asset was changed, no shadow sprite was created, and no game content references either new plot PNG.
