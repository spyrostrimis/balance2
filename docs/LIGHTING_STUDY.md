# Lighting and material cohesion 01 — 11 November 2026

**Authorized for mission use and integrated.** The creator requested finishing
the work and then adding it to the game on 11 November 2026. Open
`LightingStudy.bat`. It runs the actual mission in Godot Compatibility, with
all eight troops, current HUD and accepted environment assets. Simulation is
held at deployment so comparisons keep identical geometry, poses and cameras.
The normal mission now uses Lighting 01 by default. This records authorization
for integration, not a claim of final art quality or exact reference parity.

## Review controls

- **B**: previous lighting / integrated Lighting 01 at the current camera, without rebuilding.
- **L**: candidate light only / candidate light plus material adjustments.
- **1** or **R**: actual mission RTS camera, size 36, with existing HUD.
- **2–8**: Gate/canyon, waterworks, sand/paving/tree, debris, Blue, Red, Korali.
- **H**: existing mission HUD; **Tab**: review controls overlay.
- Arrows or right-drag pan; wheel zooms; **Esc** closes this review.

Close presets hide the HUD for unobstructed inspection. H can restore it.
Gameplay commands are disabled in this viewer; use the normal launcher to play.
The original water shader still animates; unit poses and simulation do not.

## Audit before changes

`battle.gd` constructs one directional light at (-42, -36, 0), warm `ffe6c6`,
energy .85, shadows enabled, range 95. The environment uses color ambient
`a3c0d8` at .48, linear tonemapping and no reflection sky. This gives the worn
metal and Korali no sky reflection, unlike the older isolated asset viewer.

Terrain/waterworks/vegetation/debris viewers duplicate those colors/energies
but use shadow range 110. The shared Korali/rock/Gate/tree stage instead uses
sun `ffdfb6` at 1.25, ambient `b1c7d6` at .3, a reflection sky and filmic
tonemapping; it requests SSAO in its Forward+ launcher. Character viewers and
HUD/story portrait viewports have separate studio rigs. Those historical
viewers/portrait rigs are preserved; this review uses the full mission as its
baseline, without inheriting the studio lighting or unsupported SSAO.

The native baseline showed peach-bright cliff faces, comparatively green-grey
worked stone, dark low-contrast metal and coarse shadow contact. Portable GLB
materials already have albedo, normal and packed surface maps. A runtime
roughness value of 1 is a **map multiplier**, not evidence of missing roughness.
Most imported normals have strength 1; vegetation already uses .45. Botanical
linear vertex tints and cutouts are part of its accepted material setup.

Sand repeats at 4 m with a rotated 13 m secondary sample; grit is 2.7 m.
Paving/debris use the same world-space sand recipe for burial. Imported stone,
wood and metal retain authored UV scales. There was no justification for
rescaling all those textures together. Flat floor relief is shading only.
Water remains its existing dark teal animated shader; accepted vegetation is
mostly static GLB geometry, not the earlier procedural foliage shader.

## Reproducible candidate recipe

`scripts/lighting_profile.gd` is the editable, opt-in source recipe. It captures
the actual original environment/light/material bindings, creates local material
copies cached per source, and restores those exact original bindings for B.
`Battle.lighting_review` defaults to true and applies the full profile after
mission construction. The review explicitly sets it false before construction
and applies its own profile once, preserving the historical before comparison.

| Component | Candidate |
| --- | --- |
| Sun | (-38, -36, 0), `fff0da`, energy .95 |
| Ambient | `adc5e3`, energy .50, explicit color ambient |
| Shadows | Bias .08, normal bias 1.5, 95 m range, blended splits |
| Reflection | Modest procedural sky, energy .45; cool upper hemisphere, muted sandy lower hemisphere; no sun disk |
| Sand | Linear RGB multiplier (1.05, 1.025, .98), normal .16 |
| Worked stone / paving | RGB (1.06, 1.035, 1.04); normal .65 / .24 |
| Cliffs | RGB (.87, .91, .94), normal .55 |
| Sandstone / rock debris | RGB (.96, .98, 1), normal .65 |
| Worn metal | Authored albedo and metallic retained; normal .65, roughness map multiplier .90 |
| Wood debris | RGB (.98, .98, 1), normal .65 |
| Vegetation, cloth, characters, Korali | Authored materials retained; respond to the shared light/environment |

The ground/paving/contact shaders gain optional tint and normal uniforms whose
defaults reproduce their previous values for historical comparisons. Sand and contact skins receive the
same candidate sand multiplier so the lighting pass does not create a new
color mismatch at burial boundaries. No mesh, UV, source PNG, GLB, texture import,
project setting, resource position or navigation footprint was edited.
No new raster generation, third-party art, Blender rebuild or dependency was
needed. All existing PBR/source provenance stays with the accepted asset studies.

Background, exposure and linear tonemapping remain unchanged. No bloom, fog,
SSAO, renderer migration, new light-emitting effect or global settings change.
The initial lower bias (.035/.65) produced diagonal shadow acne and was rejected
during native inspection; the values above are the revised candidate.

## Validation

- `tests/test_lighting.gd`: 12 isolation/restoration/integration checks pass, including all
  1,247 navigation cells, exact footprints, mesh resources/transforms, all eight
  deployments, source-material immutability and repeated before/after restoration.
- `tests/test_battle.gd`: all 30 existing checks pass.
- Native Compatibility captures inspect all eight presets before/after at the
  same cameras, including full mission RTS with HUD, both squads and Korali.
  Final review logs have no script/shader errors. Native B/L/H/preset controls
  are checked separately. Captures/logs are ignored under `artifacts/lighting/`.
- After enabling the mission default, all 30 battle checks and a brief native
  Compatibility mission run pass with no script/shader errors.

Reproduce the paired native captures:

```powershell
& C:/Godot/Godot_v4.7.2-stable_win64_console.exe --path . --rendering-method gl_compatibility res://scenes/lighting_study.tscn -- --capture-lighting
```

The review overlay is hidden in saved captures; filenames identify camera and
before/after. The normal interactive launch displays the controls.

## Honest limitations and next decision

This is a modest cohesion pass, not reference parity. Directional shadows still
have visible resolution limits at close range, particularly foliage and fine
carvings; a hemisphere reflection is not local reflected scenery or bounced GI.
Normal maps derived from color are not scanned surface geometry. Cliff module
repetition/seams, hard paving outlines, approximate contact skins, the prototype
Gate flanking rocks and pale Korali foundation remain visible. Lighting does not
repair those shapes, deferred botanical detail or the interim character likeness.
Current HUD/selection lights are also unchanged; they belong to later steps.

Mission integration was explicitly authorized by the creator after requesting
completion of the work. Step 6 effects/unit presentation is next in the recorded
plan, but has not begun. Step 7 remains later; step 3 is explicitly deferred.

## Lighting 02 — Forward+ profile (11 November 2026)

The mission migrated to Forward+ at the creator's request. The shared profile
now layers SSAO (radius 2.0, intensity 3.0), SSIL (radius 4.0, intensity .9),
a 1.1° sun with four parallel splits, additive glow (threshold 1.35, intensity
.25), contrast 1.10 / saturation 1.08, and re-exposure (sun ×1.55, ambient
×1.70) on top of Lighting 01, because Forward+ rendered the same values about
a quarter darker. Earlier "stay in Compatibility" guidance is superseded. See
`RENDERER_STUDY.md` for the comparison that drove the decision.
