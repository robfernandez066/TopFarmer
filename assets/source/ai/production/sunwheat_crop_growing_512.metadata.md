LOCKED FOR v1 - changes require a new PM decision

# Sunwheat Growing Crop Production Metadata

## Generation Metadata

- Recipe version: `TF-ART-v1.1`
- Approved data ID: `sunwheat`
- Asset role: `crop`
- State or variant: `young growing state waiting to mature`
- Generation workflow: OpenAI built-in `image_gen`
- Generation tool/model identifier: OpenAI built-in `image_gen` / built-in imagegen backend; the exact backend model ID and version were not exposed by the tool response
- Seed and reproducibility parameters: not exposed by the built-in tool
- Accepted generated candidate: `exec-f0136157-229b-48a4-a88a-f67ab8d5b0f4.png`
- Accepted-candidate generation date (UTC): `2026-07-21T14:38:54Z`
- Requested dimensions: `512x512` in the locked positive prompt; the built-in workflow exposed no separate size control
- Delivered candidate dimensions and mode: `1254x1254`, opaque RGB on a generated cyan chroma-key field
- Source crop filename: `sunwheat_crop_growing_512.png`
- Source shadow filename: `sunwheat_shadow_growing_512.png`
- Runtime crop filename: `sunwheat_crop_growing_256.png`
- Runtime shadow filename: `sunwheat_shadow_growing_256.png`
- Source canvases: `512x512`, lossless straight-alpha RGBA PNG
- Runtime canvases: `256x256`, lossless straight-alpha RGBA PNG
- Shared source ground-contact point: `(256, 465)` pixels, origin at canvas top left
- Shared runtime ground-contact point: `(128, 232.5)` pixels; the fractional y coordinate is intentional
- Source crop SHA-256: `501FF33B02792A99693A792A02E91690D53D01B450AA2CC674164EEC0560B379`
- Source shadow SHA-256: `4AA46DC9DBA7CCEEE36FE8DBDFC70BAA6A3FDEBBC2202F63ED77E04CD677C051`
- Runtime crop SHA-256: `05889B781E5F81B57EC989CAD7748136B4087B1F54086F1435F7480257E12819`
- Runtime shadow SHA-256: `3AF242C4CBEE7F6C1E7C111287D804C10614B17B6E9ECABECC5045F33AB33B8B`
- Reviewer: Coder Agent
- Review date (UTC): `2026-07-21`
- Disposition: Coder technical, pixel, palette, perspective, alignment, shadow, and native-comparison review passed; ready for the required Human check; no game screen, scene, script, resource, autoload, or project setting references either new runtime file

## Exact Positive Prompt

`TopFarmer game sprite of sunwheat growing crop cluster with five short healthy green shoots, small folded leaves, one tiny closed pale-gold seed bud, and one subtly dulled dusk-tinted leaf, young growing state waiting to mature, 2D hand-painted fantasy cartoon, cozy rural warmth with a restrained mysterious undertone, mostly overhead top-down farm-game view with a slight downward angle, screen-aligned orthogonal ground plane, visible top surfaces and a small front face where the subject has height, readable mobile silhouette, TopFarmer locked v1 palette, key light from upper left at 35 degrees, subtle dark-plum outline, tile-filling opaque square canvas for terrain or isolated on transparent background for object sprites, centered on a 512 by 512 canvas, bottom-center ground contact aligned where applicable, no text`

## Exact Negative Prompt

`photorealism, 3D render, anime, pixel art, horror, gore, neon, glossy plastic, isometric projection, diamond tile, 30-degree isometric axes, diagonal grid movement, fisheye, front view, side view, inconsistent perspective, multiple objects, scenery, background, baked cast shadow, cropped edges, text, watermark`

## Reference Inputs and Immutability

The built-in generation call supplied the approved mature crop, corrected mature shadow, and approved empty plot only as species, style, scale, palette, perspective, and alignment references. They were not edited, traced, copied, composited into the candidate, or replaced. Post-task verification records the following unchanged SHA-256 values:

- Mature source crop: `1979E084EA5929A510CA15095F814A191DBD0412C7CA2E9D40850D39DD9C25B6`
- Corrected mature source shadow: `87CDCAD89ED7DC48806C1A586D1B8EFC3558B54A59075276A96BA358977BA5D5`
- Mature runtime crop: `711D3F1CBC73B9B6031795535CBAF723C6832C03A44EB1BE0DDF45F9156019F4`
- Corrected mature runtime shadow: `311BDB3904A9B0BDED80ECEECA80939CC846DF32CF62B30BA72D18E40F6CA633`
- Empty plot source: `976B948F5B79BCB578762FF51CF7CB3B1616E586E47496857C4CD540550A41CD`
- Empty plot runtime: `1DAD2A9B2B2B8BB2F870A751E9D691FA5BE17069691BE5E465B9DF55A48B107E`

## Candidate Selection and Permitted Crop Preparation

The built-in workflow generated one candidate at a time. The first candidate was rejected because it read as several tall yellow fans with a developed grain head. A greener second candidate established the accepted species and scale direction. A third edit was rejected because it turned the crop into four flower-like rosettes. The accepted candidate is a targeted edit of the second generated candidate that reduced only the dusk leaf while retaining the compact shared-base silhouette, five readable short green shoot tips, one tiny closed pale-gold bud, and the mostly overhead slight angle. Only the accepted candidate above was used to create the source and runtime files; no candidates were combined.

The installed image-generation chroma helper sampled the candidate border as `#03FBFD`, used border auto-keying, soft matte, transparent threshold `12`, opaque threshold `220`, and despill, and wrote a `1254x1254` RGBA intermediate. Its occupied alpha bounds were `(414, 678)` through `(831, 1032)` inclusive. The accepted art was then prepared only by cropping source coordinates `(203, 266)` through `(1042, 1105)` inclusive to an `840x840` square, resizing once with Pillow `12.2.0` `Image.Resampling.LANCZOS` to the exact `512x512` master, and clearing RGB wherever alpha was zero. The crop is centered on source x=`623`, preserves aspect without stretching, maps the lower-center leaf base across `(256, 465)`, and places the required footprint inside the approved growing-state envelope. There was no repainting, geometric redraw, sharpening, recoloring, candidate compositing, or other added pixel content.

## Deterministic Growing Shadow Construction

Pillow `12.2.0` created the source shadow deterministically on a transparent `512x512` RGBA canvas. A contact alpha layer used `ImageDraw.ellipse((190, 441, 322, 473), fill=66)` followed by `ImageFilter.GaussianBlur(8)`. An attached subordinate cast alpha layer used `ImageDraw.ellipse((224, 447, 344, 477), fill=18)` followed by `ImageFilter.GaussianBlur(12)`. The two blurred layers overlap across `7,336` positive-alpha pixels and were merged by per-pixel maximum alpha with `ImageChops.lighter`.

The final source-shadow alpha extrema are `(0, 64)`: the prescribed narrow contact ellipse reaches `64` after radius-`8` filtering, while the prescribed cast ellipse reaches `14` after radius-`12` filtering. Every positive integer alpha level from `1` through `64` is present, producing a continuous fade. All occupied shadow pixels use exactly neutral cool gray RGB `(83, 86, 101)`; all transparent pixels have RGB `(0, 0, 0)`. The contact component occupies x=`174..338`, y=`423..491`; the cast component occupies x=`207..361`, y=`425..499`; their attached maximum merge occupies x=`174..361`, y=`423..499`. The source crop and merged shadow overlap across `3,889` positive-alpha pixels and `2,930` pixels above alpha `8`, placing the contact component behind the lowest leaves rather than below them.

## Runtime Export and Pixel Verification

Each runtime layer was created only by one Pillow `12.2.0` `Image.Resampling.LANCZOS` downsample directly from its corresponding `512x512` source to `256x256`, followed only by clearing RGB wherever alpha was zero. Fresh reconstructions of both committed runtime files are pixel-exact.

The source crop has mode `RGBA`, alpha extrema `(0, 255)`, occupied bounds above alpha `0` of x=`126..385`, y=`249..469`, and occupied bounds above alpha `8` of x=`128..383`, y=`251..467`. The alpha>8 footprint therefore stays within required x=`128..384`, its top is within y=`210..300`, and its bottom is within y=`450..475`. Fully transparent margins are left=`126`, top=`249`, right=`126`, and bottom=`42` pixels. It contains `233,115` fully transparent pixels and `5,459` partially transparent antialias pixels. All four corners are `(0, 0, 0, 0)`, zero transparent pixels contain hidden RGB, and alpha at `(256, 465)` is `62`.

The source shadow has mode `RGBA`, alpha extrema `(0, 64)`, occupied bounds above alpha `0` of x=`174..361`, y=`423..499`, and occupied bounds above alpha `8` of x=`185..332`, y=`432..482`. It contains `250,314` fully transparent pixels and `11,830` partially transparent pixels. All four corners are `(0, 0, 0, 0)`, zero transparent pixels contain hidden RGB, and alpha at `(256, 465)` is `56`.

The runtime crop has mode `RGBA`, alpha extrema `(0, 255)`, occupied bounds above alpha `0` of x=`62..193`, y=`123..235`, and occupied bounds above alpha `8` of x=`64..191`, y=`125..233`. It contains `57,724` fully transparent pixels and `2,531` partially transparent antialias pixels. All four corners are transparent and zero transparent pixels contain hidden RGB. At x=`128`, alpha is `158` on row `232` and `0` on row `233`, spanning the intentionally fractional ground-contact coordinate `(128, 232.5)`.

The runtime shadow has mode `RGBA`, alpha extrema `(0, 64)`, occupied bounds above alpha `0` of x=`87..180`, y=`211..249`, and occupied bounds above alpha `8` of x=`92..165`, y=`216..241`. It contains `62,599` fully transparent pixels and `2,937` continuously fading partial-alpha pixels. All four corners are transparent and zero transparent pixels contain hidden RGB. At x=`128`, alpha is `57` on row `232` and `53` on row `233`, spanning the same fractional ground-contact coordinate. Runtime crop and shadow overlap across `751` pixels above alpha `8`.

## Palette, Perspective, and Content Review

- Leaf `#7FAE59` and moss `#5E7A4A` derivatives visibly control the young crop. The outline remains derived from `#3E3840`; the single closed bud is derived from sun `#E9C46A`; exactly one smaller folded accent leaf is derived from dusk `#705B8C`. The crop is much greener and much less golden than the approved mature sprite.
- Five short shoot tips remain readable around one connected planted base with small folded leaves. One tiny closed bud suggests the same Sunwheat species without reading as a mature grain head, harvest glow, flower, or fruit. The dusk leaf is visibly subordinate at native runtime size.
- The cluster uses a mostly overhead slight angle with visible top surfaces, modest foreshortening, upper-left form light, and a subtle dark-plum outline. It reads as a low growing crop rather than a front-facing bouquet, tall fan, side view, diamond arrangement, or miniature mature cluster.
- The crop contains no face, pot, soil patch, plot, tool, text, watermark, scenery, background, baked shadow, or extra object. The separate shadow contains no color art, hard black edge, detached oval, platform, puddle, text, watermark, or extra object.

## Native Comparison Construction and Review

A temporary unlabeled `512x256` comparison was built outside the repository from two independent `256x256` panels. Each panel directly repeats the approved `128x128` meadow runtime tile at `(0, 0)`, `(128, 0)`, `(0, 128)`, and `(128, 128)`, then alpha-composites the unchanged approved empty plot at `(0, 0)`. The left panel adds the growing runtime shadow and crop at `(0, 0)`. The right panel independently adds the unchanged corrected mature runtime shadow and approved mature crop at `(0, 0)`. No labels, frames, paint, rescaling, or other image content were added, and the diagnostic is not committed.

At native size the left panel reads immediately as a small young green Sunwheat crop and the right as the full golden harvest-ready crop. Both meet the plot at the same ground position without a jump. The growing crop leaves ample visible soil and does not crowd the plot. Its shadow begins behind the lowest leaves, remains attached, and creates no hover gap, detached gray shape, oval, puddle, or platform.

## Runtime Admission Checklist Results

- [x] The exact TASK-014 positive prompt and unchanged locked negative prompt are recorded.
- [x] Available built-in tool, candidate, time, dimension, reference, processing, review, and disposition metadata is complete.
- [x] The growing crop is a distinct compact, predominantly green young state with five short shoot tips, one tiny closed bud, and one subordinate dusk leaf.
- [x] Source and runtime crop bounds, safe margins, transparent corners, zero hidden RGB, and fixed pivot checks pass.
- [x] The source shadow exactly follows the prescribed ellipse bounds, fill alphas, blur radii, neutral-gray color, and maximum-alpha merge; it is continuously fading and attached behind the leaf base.
- [x] Both runtime files are exact one-pass Pillow 12.2.0 Lanczos derivatives of their corresponding sources plus hidden-RGB clearing only.
- [x] All four Godot import sidecars use lossless texture import, disabled mipmaps, no size limit, no premultiplied alpha, and unchanged normal-map, HDR, and channel-remap settings.
- [x] The approved mature crop, corrected mature shadow, and empty plot retain their accepted hashes.
- [x] No existing asset was changed and no game content references the new growing files.
