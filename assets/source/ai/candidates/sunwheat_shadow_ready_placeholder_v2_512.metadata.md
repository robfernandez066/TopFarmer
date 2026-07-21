LOCKED FOR v1 - changes require a new PM decision

# Sunwheat Mature Temporary Placeholder Shadow Metadata

## Authority and Disposition

- Authority: DEC-054 and DEC-055
- Approved data ID: `sunwheat`
- Asset role: deterministic separate contact/cast shadow for the temporary mature crop placeholder
- State or variant: harvest-ready temporary Phase 2 gameplay placeholder
- Source crop filename: `sunwheat_crop_ready_angle_candidate_v2_512.png`
- Source shadow filename: `sunwheat_shadow_ready_placeholder_v2_512.png`
- Runtime crop filename: `sunwheat_crop_ready_placeholder_256.png`
- Runtime shadow filename: `sunwheat_shadow_ready_placeholder_256.png`
- Construction tool and version: Pillow `12.2.0`
- Reviewer: Coder Agent
- Review date (UTC): `2026-07-21`
- Disposition: Coder construction, pixel, alignment, composite, and import review passed; ready for the required Human grounding check; neither runtime file is referenced by any game resource

DEC-054 rejects the selected crop as final perspective art and approves its exact bytes only as a reversible temporary Phase 2 gameplay placeholder. This crop is not approved final art, must not be used as a perspective or style precedent for another asset, and must be replaced through later geometry-guided final perspective work before Phase 2 exit approval. DEC-055 requires `placeholder` to remain in both runtime filenames and keeps this pair unreferenced until the separate Human grounding check passes.

## Source Immutability and Hashes

- Selected source crop dimensions and mode: exact `512x512` lossless straight-alpha `RGBA`
- Selected source crop SHA-256 before and after export: `6AA30424C639B34B9ACC74509B6218DEB6522C6D80011F1D98A655923A2AEBD8`
- Source shadow dimensions and mode: exact `512x512` lossless straight-alpha `RGBA`
- Source shadow SHA-256: `1367B43302D7FBA99BEBC142C84E8E732EF3AEA229769476C78EC4D9D863D6FA`
- Runtime crop dimensions and mode: exact `256x256` lossless straight-alpha `RGBA`
- Runtime crop SHA-256: `5DEFE4D9A6C0FDFDC1F3332C24ABE9BE0DB7C584203CA71E468DD1396CB5B6C2`
- Runtime shadow dimensions and mode: exact `256x256` lossless straight-alpha `RGBA`
- Runtime shadow SHA-256: `D0021B2B906ED64F3DB2CC5258D31DB80D5EBCB2DE2D372AFAB1AEBA26DA0F65`
- Shared source ground-contact point: `(256, 465)`
- Shared mapped runtime ground-contact point: `(128, 232.5)`; the fractional y coordinate is intentional

The selected crop source was read only. It was not cropped, stretched, sharpened, recolored, repainted, offset, resaved, or otherwise modified. Both rejected TASK-016 candidate histories and all pre-existing source/runtime art remain unchanged.

## Exact Deterministic Shadow Construction

Pillow `12.2.0` created the source shadow procedurally on a transparent `512x512` canvas.

1. A contact alpha mask used `ImageDraw.ellipse([174, 430, 338, 476], fill=68)` followed by `ImageFilter.GaussianBlur(10)`.
2. A connected down-right extension alpha mask used `ImageDraw.ellipse([212, 438, 380, 486], fill=32)` followed independently by `ImageFilter.GaussianBlur(10)`.
3. The two blurred masks were merged by per-pixel maximum with `ImageChops.lighter`, equivalent to a maximum-alpha merge.
4. Every final pixel with alpha above zero was assigned neutral-cool RGB `(83, 86, 101)`. Every pixel with alpha zero was assigned RGB `(0, 0, 0)`.

The blurred contact mask has alpha extrema `(0, 67)` and occupied bounds x=`153..359`, y=`407..499`. The blurred extension mask has alpha extrema `(0, 32)` and occupied bounds x=`193..399`, y=`417..507`. Pillow's radius-`10` blur reduces the nominal contact fill peak from `68` to `67`; no post-blur alpha adjustment was made. Their maximum merge has alpha extrema `(0, 67)`, occupied bounds x=`153..399`, y=`407..507`, and transparent margins left/top/right/bottom=`153/407/112/4`.

The final source shadow contains `19,588` positive-alpha pixels in exactly one 8-connected component. All positive-alpha pixels use only RGB `(83, 86, 101)`. Its four corner alphas are `(0, 0, 0, 0)`, it has zero painted edge pixels, and it has zero hidden-RGB pixels. Alpha at the shared ground contact `(256, 465)` is `59`.

The contact ellipse is centered on source x=`256` beneath the crop's single ground contact. The subordinate extension shifts modestly down-right to center x=`296`. The merged shadow overlaps the crop across `7,324` positive-alpha pixels and `5,011` pixels where both alpha values exceed `8`, placing visible contact beneath and behind the basal leaves. Native and portrait composite review finds one attached soft shape rather than a detached lobe, platform, puddle, halo, or broad floating oval.

## Runtime Export and Reconstruction

`sunwheat_crop_ready_placeholder_256.png` was created from the unchanged selected `512x512` crop with exactly one full-canvas Pillow `12.2.0` `Image.Resampling.LANCZOS` resize to `256x256`, followed only by clearing RGB wherever final alpha is zero. It was not cropped, stretched, sharpened, recolored, repainted, offset, or otherwise altered.

`sunwheat_shadow_ready_placeholder_256.png` was created from the exact source shadow with exactly one full-canvas Pillow `12.2.0` `Image.Resampling.LANCZOS` resize to `256x256`, followed only by clearing RGB wherever final alpha is zero. It was not added to, reshaped, or offset.

Fresh independent one-pass reconstructions from both `512x512` sources are pixel-identical to their committed runtime files.

### Runtime Crop Pixel Checks

- Dimensions and mode: `256x256` `RGBA`
- Alpha extrema: `(0, 255)`
- Occupied alpha bounds: x=`39..214`, y=`16..235`
- Occupied alpha bounds above `8`: x=`41..212`, y=`18..233`
- Transparent margins left/top/right/bottom: `39/16/41/20`
- Four corner alphas: `(0, 0, 0, 0)`
- Painted edge pixels: `0`
- Hidden-RGB pixels: `0`
- Alpha at mapped contact x=`128`: row `232` is `146`, row `233` is `0`

### Runtime Shadow Pixel Checks

- Dimensions and mode: `256x256` `RGBA`
- Alpha extrema: `(0, 67)`
- Occupied alpha bounds: x=`76..199`, y=`204..253`
- Occupied alpha bounds above `8`: x=`83..190`, y=`209..246`
- Transparent margins left/top/right/bottom: `76/204/56/2`
- Four corner alphas: `(0, 0, 0, 0)`
- Painted edge pixels: `0`
- Hidden-RGB pixels: `0`
- Positive-alpha pixels and connectedness: `4,894` pixels in exactly one 8-connected component
- Alpha at mapped contact x=`128`: row `232` is `59`, row `233` is `57`
- Crop-shadow overlap: `1,947` positive-alpha pixels and `1,291` pixels where both alpha values exceed `8`

The small lower margin is the exact unclipped result of the prescribed source ellipse, blur, and one-pass full-canvas reduction. No painted pixel reaches a runtime canvas edge.

## Godot Import Settings

Godot generated import sidecars for the source shadow and both runtime PNGs. All three use:

- `importer="texture"` and `compress/mode=0` for lossless texture import
- `mipmaps/generate=false`
- `process/size_limit=0`
- `process/premult_alpha=false`
- `compress/normal_map=0`
- `compress/hdr_compression=1`, `process/hdr_as_srgb=false`, and `process/hdr_clamp_exposure=false`
- identity channel mapping `red=0`, `green=1`, `blue=2`, `alpha=3`
- `compress/channel_pack=0`

These settings introduce no normal-map, HDR, premultiplied-alpha, size, mipmap, or channel-remap alteration.

## Temporary Composite Diagnostics

- Native composite: `topfarmer_task017_placeholder_pair_native_256.png`, exact `256x256` RGBA, SHA-256 `5060C3BE4F9324B332ECBFDAF18F9B514F490886851B12BD954222875031EFF5`
- Portrait preview: `topfarmer_task017_placeholder_pair_portrait_540x960.png`, exact `540x960` RGBA, SHA-256 `07B8864082403261CA72566B5F718A1E193D107064A4534240B2BE9859F960BB`

The native diagnostic directly repeats the unchanged approved `128x128` meadow runtime tile at `(0, 0)`, `(128, 0)`, `(0, 128)`, and `(128, 128)`, then places the unchanged approved `256x256` empty soil plot, placeholder shadow, and placeholder crop at identical `(0, 0)` origins in that layer order. The portrait preview repeats the same meadow across `540x960` and places the same plot-shadow-crop composite at `(142, 352)`, mapping the shared plant contact to portrait point `(270, 584.5)`. No label, frame, paint, scale, scene offset, or extra image content was added. Both diagnostics remain outside the repository.

Visual review at exact native size and in the portrait context confirms there is no magenta background. The crop is the exact TASK-016 v2 selected plant, and its small soft neutral-cool shadow is attached beneath its lowest leaves on the brown soil without a hover gap, detached lobe, dark platform, puddle, halo, or large oval.

## Isolation and Admission Checklist

- [x] DEC-054 and DEC-055 are cited, and placeholder-only disposition is explicit.
- [x] The selected source crop retains its required SHA-256 byte-for-byte.
- [x] Both rejected candidate histories and every pre-existing source/runtime asset remain unchanged.
- [x] The source shadow exactly follows the prescribed ellipse boxes, fill alphas, independent Pillow `12.2.0` radius-`10` blurs, neutral-cool RGB, and maximum merge.
- [x] The source and runtime shadows each form one attached 8-connected soft shape, overlap the crop base, retain four transparent corners, and contain zero hidden RGB.
- [x] Both runtime PNGs are exact one-pass full-canvas Lanczos derivatives plus transparent-RGB clearing only.
- [x] Both runtime filenames retain `placeholder`.
- [x] All three new PNGs import with the required lossless Godot settings.
- [x] No scene, script, test, project setting, resource, or autoload references either runtime placeholder PNG.
- [x] The game still uses neither new runtime file; integration requires a later PM task after Human review.
