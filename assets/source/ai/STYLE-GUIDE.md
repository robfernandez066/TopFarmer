LOCKED FOR v1 - changes require a new PM decision

# TopFarmer v1 Art Style Guide

Recipe version: `TF-ART-v1.2`

Perspective authority: DEC-049 and DEC-050.

## Tone

TopFarmer is a cozy fantasy farming world with quiet wrongness beneath its rural warmth. The default read is welcoming, soft, and handcrafted. Mystery enters through restrained details: subtly altered nighttime ambience, night-only Duskcorn, an unexplained ambient event, and gradual traces of the previous owner. The art must never frame these elements as horror.

## Perspective and Composition

- Flat terrain, paths, water, and ground-flush soil plots use a straight top-down screen-aligned orthogonal square grid. They stay flush with the ground plane and have no invented front wall.
- Crops, props, characters, and buildings use a high-angle front-elevated farm-game sprite presentation. Vertical forms rise upward on screen from a bottom-center ground contact; clear front planes carry most of the silhouette; modest top surfaces remain visible; near elements sit lower and larger; rear elements sit higher and smaller; overlaps and foreshortening establish depth.
- Preserve this ground-versus-upright angle relationship consistently across every asset family.
- The supplied Stardew Valley farm screenshot is a reference only for this ground-versus-upright angle relationship. TopFarmer must not copy Stardew Valley's assets, pixel-art rendering, palette, crop designs, layouts, user interface, characters, buildings, or other protected expression.
- Favor a clean, readable mobile silhouette with one clear primary mass.
- Keep object sprites isolated and centered on their prescribed transparent canvas; terrain fills its tile-safe square canvas.
- Never use straight-down views of upright subjects, flat radial crop rosettes, evenly spread overhead starbursts, front-facing eye-level views, pure side views, isometric projection, diamond tiles, 30-degree isometric axes, diagonal grid movement, fisheye distortion, or inconsistent perspective.

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
| Terrain | Seamless 256 x 256 square | 128 x 128 square tile |
| Crops, props, characters, and pets | Transparent 512 x 512 | 256 x 256 canvas |
| Buildings | Transparent 1024 x 1024 | 512 x 512 canvas |
| UI icons | 256 x 256 | 128 x 128 and 64 x 64 |

Downsample with a high-quality Lanczos filter and visually inspect every export at the 540 x 960 logical design resolution.

## PNG and Alpha Rules

- Runtime art uses lossless PNG with straight alpha.
- Object-sprite source and runtime canvases remain transparent outside the painted sprite; terrain tiles remain fully opaque edge to edge.
- Do not crop edges, pre-multiply alpha, add matte colors, or leave opaque background pixels.
- Keep color and shadow assets separate whenever a cast or contact shadow is required.
- Never substitute JPG, WEBP, or another lossy runtime format.

## Sprite Naming

Name runtime sprites `<data_id>_<role>_<state>_<size>.png`. Omit segments that do not apply, never use spaces, and keep the stable data ID in lowercase snake_case. Example: `sunwheat_crop_ready_256.png`.

## Asset Rejection Checklist

Reject an asset if any answer is no:

- [ ] Does it read as a 2D hand-painted fantasy cartoon with cozy rural warmth and restrained mystery?
- [ ] If it is flat terrain, a path, water, or a ground-flush soil plot, does it use a straight top-down screen-aligned orthogonal square ground plane with no invented front wall?
- [ ] If it is a crop, prop, character, or building, does it use the high-angle front-elevated upright-sprite rule: vertical forms rise from a bottom-center ground contact, front planes carry most of the silhouette, modest top surfaces remain visible, and overlaps and foreshortening place near elements lower and larger and rear elements higher and smaller?
- [ ] Does every upright crop avoid reading as a flat overhead rosette or evenly spread overhead starburst, even when its canvas and ground point are mathematically correct?
- [ ] Is it free of isometric projection, diamond tiles, 30-degree isometric axes, and diagonal grid movement?
- [ ] Does it stay within the locked nine-color palette?
- [ ] Is the dark-plum outline subtle and the mobile silhouette clear?
- [ ] Is the light from upper left at approximately 35 degrees?
- [ ] Is any soft shadow down right, partially transparent, and separate from the color sprite?
- [ ] Is the bottom-center pivot aligned to the ground-contact point across all related states?
- [ ] Does the asset use the exact master and runtime canvas sizes for its family?
- [ ] Is the runtime output a lossless straight-alpha PNG with clean transparent edges?
- [ ] Does the filename follow the locked lowercase snake_case sprite convention?
- [ ] Is it free of photorealism, 3D rendering, anime, pixel art, horror framing, text, and watermarks?
