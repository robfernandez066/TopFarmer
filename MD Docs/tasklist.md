TASK-006: Correct the Flourmill shadow so the building is visibly grounded
Status: ready
Complexity: routine
Files: preserve res://assets/source/ai/reference/flourmill_building_idle_1024.png unchanged, replace res://assets/source/ai/reference/flourmill_shadow_idle_1024.png and its import sidecar, update res://assets/source/ai/reference/flourmill_building_idle_1024.metadata.md
Acceptance:
- `flourmill_building_idle_1024.png` remains byte-for-byte unchanged from commit `2bf679e`, including SHA-256 `01FAAAFE6080CCC8A2FD0E87DFA6FD6F32CA7B3C10204172694A1A1DFCDA6DD4`; this rework is shadow-only
- `flourmill_shadow_idle_1024.png` is replaced with a lossless 1024x1024 straight-alpha PNG containing only neutral cool-gray shadow pixels, with fully transparent corners and no building color, background, hard black edge, text, or watermark
- The replacement has a narrow soft contact component centered at `(512, 878)`, approximately 560 pixels wide by 72 pixels high before blur, so it begins behind the mill's foundation and overlaps the visible base rather than starting below it
- The contact component spans the foundation from approximately x=232 through x=792 and remains present behind the base between y=842 and y=914; when the unchanged color sprite is placed above it at identical canvas coordinates, there is no transparent gap between the foundation and its shadow
- A softer, lighter cast component extends down and right from the contact component, but it is visually subordinate: it must not form a broad platform, puddle, detached slab, second footprint, or lobe separated from the foundation
- Shadow opacity peaks between alpha 70 and 90 at the tight contact area and fades continuously outward; the down-right extension is less opaque than the contact area, and all pixels remain partially transparent
- The color and replacement shadow retain the shared bottom-center ground-contact point `(512, 897)` without moving, scaling, cropping, or regenerating the approved color sprite
- The Coder's report includes a temporary composite made by layering the unchanged color PNG over the replacement shadow PNG at identical 1024x1024 canvas coordinates, plus a close view of the foundation; no diagnostic composite needs to be committed
- The composite visibly rests on the shadow along the foundation and does not appear to hover, while the shadow still reads as cast down and right under upper-left lighting
- The metadata marks the commit `2bf679e` shadow as Human-check rejected under DEC-021 and records the replacement shadow construction, alpha range, occupied bounds, SHA-256, shared contact coordinate, review result, and unchanged color SHA-256
- These files are source references only; no file is added under `assets/sprites/` and no game scene or code uses them yet
- The existing project boot and balance-loader checks still pass
Human check:
- In the Coder's report, inspect the combined picture where the mill is placed directly over the replacement shadow without either image being moved or resized
- Look closely along the stone foundation: the soft shadow must begin underneath it with no clear gap, so the mill looks planted on the ground rather than floating
- The shadow may trail gently toward the lower right, but it must not look like a separate gray platform, puddle, or large detached blob below the mill
- Confirm the report says both files are still 1024 by 1024 pixels, the shared ground point is `(512, 897)`, and the building file itself was not changed
Depends on: TASK-005
Notes: see DEC-007, DEC-017, DEC-020, and DEC-021. The Human check overrides the Coder's earlier technical acceptance: matching a pivot coordinate is insufficient when the visible composite floats. Preserve the approved color file exactly. Construct the replacement from a tight contact shadow under the foundation plus a restrained down-right cast extension; do not regenerate the building, reuse the rejected broad shadow, or create runtime exports.
