# Gate cohesion 01 — review candidate (11 November 2026)

Focused follow-up to Claude's two-stage Gate review (recorded in
`GATE_COHESION_HANDOFF.md`). Goal: make the integrated Gate 02 and its
immediate surroundings read as one worn ruin in the canyon, at the same
stylized-realism level, without changing the approved architecture, placement,
scale, framing, navigation or mechanics. The creator approved it ("Add it to
the game") on 11 November 2026; it is now the mission default through
`Arena.gate_cohesion_review = true`. The study keeps Gate 02 on B.

## Review

Double-click `GateCohesionStudy.bat`. It loads the actual mission (eight troops,
current HUD) under the integrated Lighting 01 in Compatibility, held at
deployment, with both Gate clusters built and one shown.

- **B**: before (integrated Gate 02 cluster) / after (candidate), same camera.
- **1–7**: RTS, Gate at mission angle, steps/base contact, left flank + marker,
  right flank + marker, crown/lintels/oculus, low oblique.
- **G**: hide/show the candidate's sand drifts and contact occlusion.
- **H** HUD, **Tab** review panel, arrows/right-drag pan, wheel zoom, **R** RTS,
  **Esc** close.

## Review points: confirmed vs. not confirmed

Inspected in native Compatibility mission views before changing anything.

| Review point | Finding | Action |
| --- | --- | --- |
| Boulders and cream standing stones mismatch | Confirmed, the worst offenders: flat-shaded, untextured procedural `Art.rock` prototypes | Replaced (below) |
| Step edges straight, no chipped/sunken blocks | Confirmed. Codex's unfinished attempt cut rectangular notches that read as toy bricks | Rebuilt treads with fractured spalls and settlement |
| Clean step/sand line, no drift/contact | Confirmed | Sand drifts + contact occlusion |
| Lintels blurrier than steps (UV mismatch?) | **Not a lintel mismatch.** Measured texel density was uniform (~41 px/authored m on lintels and steps) but the 4096 atlas was only 13% used, so the whole Gate was under-resolved; big plain faces show it most | Concave island packing: 33% fill, ~66 px/m (+60%) |
| Thin vertical line above the oculus | Authored "short axial crown blade" and bronze line crossing the seal; at RTS distance it reads as a stray sliver | Replaced by a weathered crown keystone |
| Flat cool grey, little block variation | Partly confirmed: authoring tint was blue-cool (.79/.85/.91) | Neutral-warm tint, stronger per-block value/warmth steps, sand on low faces |
| Weak AO in joints | Baked AO existed but was soft | Tighter AO (distance .30, floor .44); no extra global darkening |
| Directional light/shadows not received | Not confirmed: Gate casts and receives Lighting 01 shadows | None |
| Ivy as flat panels | Not confirmed for Gate 02: leaf cards on modeled stems | Preserved unchanged |

Decal nodes and SSAO were suggested; neither is available in the Compatibility
renderer the mission uses, so contact darkening is a thin multiply skin instead.

## What changed

**Flanking rocks** (`flanker_left/right.glb`): fractured sandstone masses built
with the accepted rock formation recipe (broad oblique fracture planes, a
separated shoulder, buried toe and fallen chips) within the old 4 × 3.5 × 5.8 m
envelope. Material uses the exact Terrain 01 cliff grade and is named
`cliff portable PBR`, so Lighting 01 treats it as cliff. Baked AO and a warm
sand dust gradient at the foot. The base is seated below its lowest (front)
ground contact so no edge floats on the rising ground.

**Wayside markers** (`marker_left/right.glb`): worked slabs with battered
shoulders, a broken corner and a foot spall, in the Gate limestone with the same
grade (`Gate II stone PBR`), keeping the existing bronze sigils and anchors.

**Gate** (`sanctuary_gate.glb`, same architecture, ivy, banners and placement):
- Each stair tread is a settled block with 1–3 fractured spalls boolean-cut from
  its nose arris and corners (flat icosahedral facets, not notches or pits); three
  lost an end piece; five sank 6–9 cm, two tilt visibly, all shift by millimetres.
- Fallen worked stones near the porticoes are chipped, tipped and half-buried
  instead of clean upright cubes.
- Baked sand settles on low, upward and occluded faces (tread backs, plinths,
  joints) with a broken patch edge, plus a dust skirt at the foot.
- Crown keystone replaces the axial blade and bronze line.
- The sealed portal sits .65 m back behind stone reveal jambs, so the opening
  has a shadowed soffit instead of a flat dark plane (post-approval follow-up).
- Stone authoring tint warmed to (.90, .86, .79) toward the reference's beige.
- Tint, AO and UV packing as in the table.

**Grounding** (`scripts/gate_cohesion_art.gd`): sand ramps lean on the bottom
risers, stair sides and portico plinths, with a varying crest so the stone/sand
line is uneven; they reuse the accepted debris sand material and terrain height.
Thin contact-occlusion strips/ellipses (`shaders/contact_occlusion.gdshader`)
darken only the physical contact edge. Front reach is capped short of z = -14.

## Constraints verified

`tests/test_gate_cohesion.gd`: all 1,247 navigation cells and registered
footprints identical, no colliders, Gate at (0, 0, -18.6) × 0.78, and every
candidate vertex (≈175k) north of the walkable edge (max z ≈ -14.08). The 30
battle, 12 lighting and debris checks still pass. Native Compatibility captures
show no script or shader errors. Integrated as the mission default; setting
`Arena.gate_cohesion_review = false` restores the Gate 02 cluster.

## Source and provenance

`art_source/gate/cohesion/build_gate.py` (Gate; derived from the Gate 02 recipe,
preserving its random stream for the accepted ivy/foliage) and
`build_neighbors.py` (flankers, markers), with packed `gate_cohesion_authoring.blend`
and `neighbors_authoring.blend`. Run each with
`C:/Blender/blender.exe --background --factory-startup --python <file>`.
`GATE_PREVIEW=1` bakes the Gate at 1024 with fewer AO samples in about a
minute, for geometry checks; the shipped asset needs the full 4096 bake.
No new raster sources: reuses the generated Gate 02 limestone/ivy, the Gate 01
banner and the Terrain 01 cliff sources. No third-party files or add-ons.

## Limitations

- Drifts and contact skins are geometry approximations of what a decal or
  terrain-blend shader would do; they read best at Gate/close distance and
  are subtle at full RTS zoom.
- The two flankers share one construction recipe with different seeds; they
  are similar in silhouette.
- The stone texture's mottled lichen pattern itself is unchanged.
- Atlas fill is 33%; more is possible with a hand-laid UV/trim sheet.
- The marker slabs are simple worked shapes; sigils remain the existing bronze strokes.
- No reference-parity claim; aesthetic acceptance belongs to the creator.
