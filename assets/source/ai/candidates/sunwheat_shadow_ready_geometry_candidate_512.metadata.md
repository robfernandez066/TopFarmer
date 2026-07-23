# Sunwheat Final-Perspective Runtime Pair Metadata

## Authority and Disposition

- Authority: DEC-054 through DEC-057, DEC-077, DEC-079, and TASK-028
- Approved data ID: `sunwheat`
- Asset role: deterministic separate contact/cast shadow and one-pass runtime export for the Human-approved mature crop
- Source crop: `sunwheat_crop_ready_geometry_candidate_512.png`
- Source shadow: `sunwheat_shadow_ready_geometry_candidate_512.png`
- Runtime crop: `sunwheat_crop_ready_perspective_256.png`
- Runtime shadow: `sunwheat_shadow_ready_perspective_256.png`
- Construction and export tool: Pillow `12.2.0`
- Review date (UTC): `2026-07-22`
- Disposition: Coder construction, pixel, import, reconstruction, isolation, and composite review passed; Human grounding review approved on `2026-07-23`. Neither runtime file is integrated or referenced by the game.

This pair preserves DEC-077's approved final-perspective crop exactly. TASK-028 creates only the separately prescribed shadow, the two one-pass runtime exports, their import sidecars, this traceability record, and external diagnostics. The current READY placeholder remains live until a separate integration task.

## Source Immutability and Exact Construction

The approved `512x512` straight-alpha RGBA crop was read only and remained byte-for-byte unchanged at SHA-256 `6E0063C55F5E8CFA00F2011F39F1A496A70F57993EFC3CD914E7914556594B81`. It was not cropped, translated, rotated, mirrored, stretched, sharpened, recolored, composited, repainted, or resaved, and no shadow was added to it.

Pillow `12.2.0` constructed the separate source shadow deterministically on a transparent `512x512` canvas:

1. The contact alpha mask drew the inclusive ellipse bounding box `(204,443)..(308,469)` with fill alpha `72`, then applied `ImageFilter.GaussianBlur(8)`.
2. The attached down-right extension mask independently drew the inclusive ellipse bounding box `(214,444)..(338,480)` with fill alpha `24`, then applied `ImageFilter.GaussianBlur(12)`.
3. `ImageChops.lighter` combined the masks by per-pixel maximum alpha, never addition.
4. Every positive-alpha pixel received only neutral-cool RGB `(83,86,101)`; every zero-alpha pixel was cleared to RGB `(0,0,0)`.

The independently blurred contact and extension masks have alpha extrema `(0,65)` and `(0,21)` respectively. No blur, ellipse, lobe, centroid, or offset was adjusted after the prescribed construction.

## Source Pixel Validation

### Approved source crop

- Dimensions and mode: exact `512x512` lossless straight-alpha `RGBA`
- SHA-256: `6E0063C55F5E8CFA00F2011F39F1A496A70F57993EFC3CD914E7914556594B81`
- Alpha extrema: `(0,255)`
- Positive-alpha bounds: x=`64..447`, y=`63..477`
- Alpha-greater-than-`8` bounds: x=`66..444`, y=`65..475`
- Positive-alpha pixels: `96,492`
- Alpha-greater-than-`8` pixels and 8-connected components: `93,608` pixels in exactly `1` component
- Four corner alphas: `(0,0,0,0)`
- Painted canvas-edge pixels: `0`
- Hidden-RGB pixels / maximum where alpha is zero: `0` / `0`

### New source shadow

- Dimensions and mode: exact `512x512` lossless straight-alpha `RGBA`
- SHA-256: `6061A910B3B8CAEA76322CDF0F61DDCC85921B2646C48EE7D99F6E603842B905`
- Alpha extrema: `(0,65)`
- Positive-alpha bounds: x=`188..359`, y=`420..504`
- Alpha-greater-than-`8` bounds: x=`199..334`, y=`433..484`
- Positive-alpha pixels: `11,678`
- Alpha-greater-than-`8` pixels and 8-connected components: `5,580` pixels in exactly `1` component
- Positive-alpha RGB values: exactly one value, `(83,86,101)`
- Four corner alphas: `(0,0,0,0)`
- Painted canvas-edge pixels: `0`
- Hidden-RGB pixels / maximum where alpha is zero: `0` / `0`
- Crop-shadow overlap: `5,353` positive-alpha pixels and `2,574` pixels where both alphas exceed `8`

The meaningful shadow is one attached component and exceeds TASK-028's required `500` source-overlap pixels. Native composite inspection finds the contact area partly hidden by the lowest leaves with only a small soft down-right extension, not a detached lobe, broad oval, platform, puddle, halo, or hard edge.

## One-Pass Runtime Export and Reconstruction

Both runtime files retain the complete shared coordinate system. Their shared source ground contact `(256,465)` maps fractionally to runtime point `(128,232.5)`, so later identical placement at `(-128,-232.5)` will align the planted crown to the FarmPlot origin without centroid correction.

`sunwheat_crop_ready_perspective_256.png` is exactly one full-canvas Pillow `12.2.0` `Image.Resampling.LANCZOS` reduction of the approved source crop to `256x256`, followed only by clearing RGB where final alpha is zero. `sunwheat_shadow_ready_perspective_256.png` is independently the same single full-canvas reduction of the exact source shadow, followed only by the same transparent-RGB clearing. Neither output received another resample or any crop, translation, rotation, mirror, stretch, sharpen, recolor, composite, or repaint operation.

### Runtime crop

- Dimensions and mode: exact `256x256` lossless straight-alpha `RGBA`
- SHA-256: `2839F72C8D2671EE307F61B7142D1BDEECD502F74558BD45BC79976DDA50CDE5`
- Alpha extrema: `(0,255)`
- Positive-alpha bounds: x=`31..224`, y=`30..239`
- Alpha-greater-than-`8` bounds: x=`33..222`, y=`33..237`
- Positive-alpha pixels: `25,114`
- Alpha-greater-than-`8` pixels and 8-connected components: `23,805` pixels in exactly `1` component
- Four corner alphas: `(0,0,0,0)`
- Painted canvas-edge pixels: `0`
- Hidden-RGB pixels / maximum where alpha is zero: `0` / `0`
- Fresh one-pass reconstruction from the committed source: pixel-identical `true`

### Runtime shadow

- Dimensions and mode: exact `256x256` lossless straight-alpha `RGBA`
- SHA-256: `1DBC7F7C9BEDFB216DFF06C3CEF30619123AE87568A711FD32ECDCC66AC89751`
- Alpha extrema: `(0,65)`
- Positive-alpha bounds: x=`94..179`, y=`210..251`
- Alpha-greater-than-`8` bounds: x=`99..166`, y=`217..242`
- Positive-alpha pixels: `2,878`
- Alpha-greater-than-`8` pixels and 8-connected components: `1,399` pixels in exactly `1` component
- Four corner alphas: `(0,0,0,0)`
- Painted canvas-edge pixels: `0`
- Hidden-RGB pixels / maximum where alpha is zero: `0` / `0`
- Crop-shadow overlap: `1,407` positive-alpha pixels and `657` pixels where both alphas exceed `8`
- Fresh one-pass reconstruction from the committed source: pixel-identical `true`

The meaningful runtime overlap exceeds TASK-028's required `100` pixels. Both runtime layers have identical full-canvas coordinates and preserve the fractional ground-contact mapping without rounding or image alteration.

## Godot Import Settings

Godot `4.7.1.stable.official.a13da4feb` generated import sidecars for the source shadow and both runtime PNGs. All three use:

- `importer="texture"`, `type="CompressedTexture2D"`, and `compress/mode=0` for lossless texture import
- `mipmaps/generate=false` and `mipmaps/limit=-1`
- `process/size_limit=0`
- `process/premult_alpha=false`
- identity channel mapping `red=0`, `green=1`, `blue=2`, `alpha=3`
- `compress/normal_map=0`, `process/normal_map_invert_y=false`, and `compress/channel_pack=0`
- `compress/hdr_compression=1`, `process/hdr_as_srgb=false`, and `process/hdr_clamp_exposure=false`

No premultiplication, channel remap, normal-map conversion, HDR conversion, mipmap, size limit, or lossy compression is enabled.

## External Diagnostics

All diagnostics remain outside the repository under `C:\Users\robbi\.codex\visualizations\2026\07\21\019f8697-64ec-7101-985f-b221282805a7\topfarmer-task028\`:

- Source pair on neutral gray: `topfarmer_task028_pair_native_512.png`, exact `512x512` RGB, SHA-256 `50866A3167E60ACECB7B2E710D931D211A034FC0B2144DA16CD2D6C4A8E1AD8C`
- Runtime pair on neutral gray: `topfarmer_task028_pair_native_256.png`, exact `256x256` RGB, SHA-256 `6F620ACA2A0749500349C68E6E35D0994C603B43A9BAF1FF6786BF4150FDE911`
- Farm context: `topfarmer_task028_farm_context_540x960.png`, exact `540x960` RGB, SHA-256 `14DA2AFBD24EC263D841F5FDED92E4CAD2DD63C25F84032EEE136E6BE0F3984D`
- Machine-readable validation: `task028_validation.json`
- Deterministic construction/validation script: `build_task028.py`

The farm diagnostic repeats the unchanged approved `128x128` meadow tile, places the unchanged approved `256x256` soil plot at `(142,352)`, then places the runtime shadow and crop independently at the same top-left coordinate. Their shared contact maps to portrait point `(270,584.5)`. No label, frame, paint, scaling, scene offset, or extra image content was added.

## Isolation and Review Checklist

- [x] The approved source crop retains its exact required SHA-256.
- [x] The source shadow follows the exact prescribed boxes, alphas, independent blur radii, RGB, and maximum merge.
- [x] The source and runtime shadows each form one meaningful connected component with required crop overlap.
- [x] All three new PNGs have four transparent corners, no painted edge pixel, and zero hidden RGB.
- [x] Both runtime PNGs are fresh-reconstruction-identical one-pass full-canvas derivatives.
- [x] All three new PNGs use the required lossless Godot import settings.
- [x] No scene, script, test, resource, autoload, project setting, or existing asset was changed to reference or integrate the pair.
- [x] Human grounding review of farm context and native runtime composite.

## Human Grounding Review

On `2026-07-23`, the Human approved the `540x960` farm-context image at normal size and the native `256x256` neutral-background composite at 100%. The approved crop retains its angled near/middle/rear depth and centered natural base, sits on the soil rather than hovering, and remains the visual focus without crop or shadow clipping. The shadow touches and partly disappears beneath the lowest leaves with only a small soft down-right extension; it does not read as a separate oval, puddle, platform, halo, detached blob, or broad offset lobe.

This grounding approval permits a later task to replace the current READY placeholder. It does not integrate the pair, change FarmPlot, or authorize any gameplay/configuration change in TASK-028.
