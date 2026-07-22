# Sunwheat Ready Perspective Geometry Guide Metadata

## Purpose and Authority

- Task and authority: `TASK-026`, DEC-047 through DEC-054, and DEC-075
- Guide role: non-runtime transparent composition and perspective guide for one upright mature Sunwheat crop
- Guide filename: `sunwheat_ready_perspective_guide_512.png`
- Creation tool: Pillow `12.2.0`, using only deterministic flat geometry, labels, lines, and arrows
- Creation date (UTC): `2026-07-22`
- Dimensions and mode: exact `512x512` lossless straight-alpha `RGBA`
- SHA-256: `3A666591F5EEE7FEF32E7942085AEC22E9C85720E27203D0253B2DCBD3384785`
- Disposition: Human-approved source-only visual generation reference; it is not game art and cannot become a runtime asset

This guide contains no copied game imagery, generated plant artwork, terrain, soil, shadow, UI, or protected reference expression. Its flat diagnostic colors do not alter or extend the locked TopFarmer palette because they label composition regions rather than depict final art.

## Perspective Reading Rule

Lower screen position means nearer and larger. Higher screen position means farther and smaller. The vertical arrow runs from the exact near ground contact `(256, 465)` upward toward the far region. The guide must be interpreted as a high-angle front-elevated upright crop, never as an eye-level bouquet, pure side view, straight-down radial rosette, overhead starburst, or isometric/diamond arrangement.

## Exact Guide Geometry

The rounded safe envelope is x=`78..434`, y=`48..472`. It provides clear source-canvas margin and is diagnostic only.

Seven grain-head regions are arranged in the required near-to-far stack:

- Rear/smaller/higher `R1`: ellipse x=`180..240`, y=`106..188`
- Rear/smaller/higher `R2`: ellipse x=`242..298`, y=`82..158`
- Rear/smaller/higher `R3`: ellipse x=`302..360`, y=`122..202`
- Middle/larger overlapping `M1`: ellipse x=`138..224`, y=`210..322`
- Middle/larger overlapping `M2`: ellipse x=`214..306`, y=`178..298`
- Middle/larger overlapping `M3`: ellipse x=`296..382`, y=`220..330`
- Subordinate dusk-purple accent `P`: ellipse x=`342..390`, y=`184..248`

Seven flat stalk guides begin at the lower center of those head regions and converge behind the leaf masses into the one crown. Their source-to-crown lines are `(210,188)->(237,424)`, `(270,158)->(249,424)`, `(331,202)->(263,424)`, `(181,322)->(241,430)`, `(260,298)->(256,430)`, `(339,330)->(270,430)`, and `(366,248)->(267,424)`.

Five larger/lower foreground leaf polygons overlap those stalks and the lower edges of the middle-head layer:

1. `(250,452) (203,426) (104,342) (137,326) (225,374) (265,428)`
2. `(260,452) (305,423) (409,344) (378,329) (286,376) (247,430)`
3. `(248,446) (208,419) (154,382) (172,361) (239,392) (270,433)`
4. `(264,446) (302,416) (361,382) (344,360) (276,392) (242,433)`
5. `(256,443) (226,402) (218,338) (245,321) (271,391) (274,434)`

The single centered continuous crown is polygon `(213,414) (231,390) (256,379) (282,392) (300,418) (288,451) (256,465) (224,451)`. It terminates at the exact crosshair point `(256,465)`. Every stalk and foreground leaf overlaps this crown; there is no second crown, cut bundle, pot rim, exposed root, or alternate soil contact.

Diagnostic colors are rear blue `(74,160,205,220)`, middle gold `(233,196,106,225)`, purple accent `(112,91,140,235)`, foreground teal `(53,190,150,225)`, crown ember `(217,108,74,240)`, stalk moss `(94,122,74,230)`, outline dark plum `(62,56,64,255)`, and depth-axis moon blue `(183,201,211,255)`. Labels `R1..R3`, `M1..M3`, `P`, `F`, and `C`, the compact legend, the ground label, and the near-to-far arrow are diagnostic only and must not appear in generated art.

## PNG and Import Verification

- Alpha extrema: `(0,255)`
- Alpha>0 bounds: x=`12..434`, y=`10..496`; margins left/top/right/bottom=`12/10/77/15`
- Four corner alpha values: `(0,0,0,0)`
- Painted canvas-edge pixels: `0`
- Hidden RGB maximum where alpha is zero: `0`
- The exact contact marker occupies x=`248..264` at y=`465` and includes `(256,465)`
- Godot import: lossless texture compression, mipmaps disabled, no size limit, identity RGBA channels, no premultiplied alpha, no normal-map conversion, and no HDR conversion

## Reference Restrictions

The guide may be supplied only as a source-generation composition reference. No scene, script, test, resource, autoload, or project setting may reference it. It must not be copied into a runtime sprite, shown to the player, treated as style art, or used to modify any existing crop, shadow, plot, scene alignment, or balance value.

## Human Review

On `2026-07-22`, the Human approved the guide overlay: the candidate follows the centered crown and near/middle/far layers without clipping or visually leaning to one side. This approval permits later separate shadow/runtime-export planning but does not itself authorize integration or replacement.
