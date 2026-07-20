LOCKED FOR v1 - changes require a new PM decision

# TopFarmer v1 Art Style Guide

Recipe version: `TF-ART-v1`

## Tone

TopFarmer is a cozy fantasy farming world with quiet wrongness beneath its rural warmth. The default read is welcoming, soft, and handcrafted. Mystery enters through restrained details: subtly altered nighttime ambience, night-only Duskcorn, an unexplained ambient event, and gradual traces of the previous owner. The art must never frame these elements as horror.

## Perspective and Composition

- Use an angled top-down three-quarter orthographic view.
- Preserve a consistent ground plane and object angle across every asset family.
- Favor a clean, readable mobile silhouette with one clear primary mass.
- Keep sprites isolated and centered on their prescribed transparent canvas.
- Never use fisheye distortion, front view, side view, or inconsistent perspective.

## Locked Nine-Color Palette

| Role | Color |
|---|---|
| Outline | `#3E3840` |
| Soil | `#7A4E3A` |
| Moss | `#5E7A4A` |
| Leaf | `#7FAE59` |
| Sun | `#E9C46A` |
| Ember | `#D96C4A` |
| Dusk | `#705B8C` |
| Moon | `#B7C9D3` |
| Highlight | `#F6E7C1` |

Use these colors as the controlling palette. Value and saturation shifts may support painted form, but must remain visibly derived from the locked colors rather than introducing a competing palette.

## Outline and Shape Language

- Use a subtle dark-plum outline derived from Outline `#3E3840`.
- Prefer rounded, sturdy, asymmetrical shapes with readable hand-painted planes.
- Keep small details subordinate to the mobile silhouette.
- Use gentle wear and organic irregularity; avoid glossy plastic, mechanical precision, or busy surface noise.
- Convey restrained unease through small visual discrepancies, never gore, menace, or horror imagery.

## Light and Shadow

- Use **light from upper left** at approximately 35 degrees above the ground plane.
- Paint form lighting consistently with that global key direction.
- Place every soft contact or cast **shadow down right** on a separate sprite layer beneath the object.
- Use a neutral cool gray with partial alpha for shadows.
- Never bake a cast shadow or hard black halo into the color sprite.

## Pivots

- Use a bottom-center pivot at the object's ground-contact point.
- Keep the pivot at the same normalized location across all states, variants, and flips of an object.
- Align multi-state sprites so state changes do not make the object jump on the ground plane.

## Master and Runtime Sizes

| Asset family | Master canvas | Runtime output |
|---|---:|---:|
| Terrain | Transparent or tile-safe 256 x 128 diamond | 128 x 64 tile |
| Crops, props, characters, and pets | Transparent 512 x 512 | 256 x 256 canvas |
| Buildings | Transparent 1024 x 1024 | 512 x 512 canvas |
| UI icons | 256 x 256 | 128 x 128 and 64 x 64 |

Downsample with a high-quality Lanczos filter and visually inspect every export at the 540 x 960 logical design resolution.

## PNG and Alpha Rules

- Runtime art uses lossless PNG with straight alpha.
- Source and runtime canvases remain transparent outside the painted sprite.
- Do not crop edges, pre-multiply alpha, add matte colors, or leave opaque background pixels.
- Keep color and shadow assets separate whenever a cast or contact shadow is required.
- Never substitute JPG, WEBP, or another lossy runtime format.

## Sprite Naming

Name runtime sprites `<data_id>_<role>_<state>_<size>.png`. Omit segments that do not apply, never use spaces, and keep the stable data ID in lowercase snake_case. Example: `sunwheat_crop_ready_256.png`.

## Asset Rejection Checklist

Reject an asset if any answer is no:

- [ ] Does it read as a 2D hand-painted fantasy cartoon with cozy rural warmth and restrained mystery?
- [ ] Does it use the angled top-down three-quarter orthographic perspective?
- [ ] Does it stay within the locked nine-color palette?
- [ ] Is the dark-plum outline subtle and the mobile silhouette clear?
- [ ] Is the light from upper left at approximately 35 degrees?
- [ ] Is any soft shadow down right, partially transparent, and separate from the color sprite?
- [ ] Is the bottom-center pivot aligned to the ground-contact point across all related states?
- [ ] Does the asset use the exact master and runtime canvas sizes for its family?
- [ ] Is the runtime output a lossless straight-alpha PNG with clean transparent edges?
- [ ] Does the filename follow the locked lowercase snake_case sprite convention?
- [ ] Is it free of photorealism, 3D rendering, anime, pixel art, horror framing, text, and watermarks?
