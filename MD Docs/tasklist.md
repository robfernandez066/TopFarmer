TASK-010: Export the approved meadow terrain tile for runtime
Status: ready
Complexity: routine
Files: create res://assets/sprites/terrain/meadow_grass_tile_default_128.png and its Godot import sidecar
Acceptance:
- `meadow_grass_tile_default_128.png` is produced only by one high-quality Lanczos downsample of the exact approved `assets/source/ai/reference/meadow_grass_tile_default_256x256.png` whose SHA-256 is `77C4A439D50F61710FF89DEFFEE3FE2EEF8DFECDAA9BA3972F1E0C0FC43A4D8F`; the approved source remains byte-for-byte unchanged
- The runtime file is a lossless opaque PNG on an exact 128x128 square canvas; every pixel has alpha 255 and there is no border, transparent corner, diamond silhouette, diagonal grid, object, text, added paint, recolor, crop, sharpen, blur, seam repair, or other content change beyond the locked downsample
- Warm leaf-and-moss turf, sparse sun-gold dry blades, and subtle moon-blue dew flecks remain readable without a dominant repeated motif or newly introduced directional line
- A temporary 384x384 diagnostic made by direct 3x3 placement of the unchanged runtime tile shows no gap, dark seam, mismatched edge color, diagonal arrangement, or visually dominant repeated feature; the diagnostic is shown in the Coder report and is not committed
- The Coder report records the source SHA-256, exact downsampling tool and version, filter, runtime SHA-256, dimensions, alpha extrema, and direct 3x3 verification method
- The Godot import sidecar uses lossless texture import with mipmap generation disabled, no size limit, no premultiplied alpha, and no normal-map, HDR, or channel-remap alteration
- No other runtime asset is created, and no scene, script, resource, autoload, project setting, or audio file references the runtime tile yet
- The existing project boot and balance-loader checks still pass
Human check:
- In the Coder's report, inspect the 3x3 runtime-tile picture at normal size; it should look like one continuous square field with no cracks, dark seams, diagonal grid, or diamond shapes
- Open `meadow_grass_tile_default_128.png`; it should look like the approved meadow source with slightly reduced fine detail, not like a repainted or differently colored field
- In Windows, right-click `meadow_grass_tile_default_128.png`, choose Properties, then Details; it should report 128 by 128 pixels
- Confirm the Coder report says the original 256x256 source file was not changed and no scene uses the runtime tile yet
Depends on: TASK-009
Notes: see DEC-018, DEC-019, and DEC-031. This is the first controlled Phase 2 runtime admission, not bulk production and not a farm scene. Use the same high-quality Lanczos image pipeline already used for approved reference preparation, and record the exact tool/version so the result is reproducible. Do not alter the source, create a committed diagnostic preview, or begin camera, plot, interaction, or UI work in this task.
