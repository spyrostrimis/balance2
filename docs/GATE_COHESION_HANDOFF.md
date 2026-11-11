# Gate and surroundings cohesion — creator follow-up, 11 November 2026

The creator supplied Claude's two-stage review and explicitly requested a new
session to start addressing the issues, incorporating Codex's judgment and an
independent investigation. This focused request supersedes moving straight to
step 6. Begin actual work in the new session; do not stop at a plan or ask to start.
Preserve the accepted Gate design and assess a separate native revision before
substituting revised art. The previous instruction to integrate Lighting 01 was
for that pass; do not infer blanket acceptance of future Gate revisions.

## Claude's review, faithfully retained as an actionable record

Initial diagnosis: the Gate read as a clean model placed in the scene, rather
than a worn ruin belonging there. Suggested stone color/roughness variation,
chipped/uneven edges and broken/shifted blocks, crevice AO and base contact,
sand/debris against steps, irregular hanging ivy rather than panels, and correct
directional illumination/shadows. Aim at the reference's stylized read, not every
painterly detail of an AI mockup.

Blender suggestions: small bevels on blocks/pillars/steps; break regularity with
controlled offsets/rotations/chipping and a worn silhouette; bake per-block
Object Info/Geometry variation and crevice grime to portable maps; bake AO to
texture or vertex color; check consistent UV texel density, particularly steps
and lintels, considering an atlas/trim sheet; hanging/wrapping ivy strips using
alpha cards, possibly Geometry Nodes or an ivy add-on; short doorway depth
instead of a flat dark plane. Claude asked whether the mesh was Blender/Python
or Godot-generated: the answer is Blender/Python for Gate02, procedural Godot
for its large flanking rocks and cream wayside markers.

Godot suggestions: verify MeshInstance3D shadow casting and directional bias/
range; SSAO where supported, baked AO on Compatibility; soft base-contact,
sand-drift and moss decals; separate sand/debris meshes; inspect imported
albedo/normal/roughness and excessive gloss. Initial proposed order was bevels/
broken blocks, AO/color variation, then contact and base debris.

After Debris and Lighting, Claude explicitly called this a real step up:
- Actual stone texture, visible joints/weathering/subtle tones consistently
  across Gate, wings and ruined corner slabs.
- Layered arch, oculus, fluted columns, maroon banners and overhanging lintels
  give the architecture character.
- Individual ivy leaves on hanging strands improve on flat panels.
- Varying step widths and staggered joints improve on a brick grid.
- Small base rubble helps.

Remaining observations/hypotheses, to verify in the actual current mission:
- Step edges still too straight, lacking chipped/worn corners or sunken/shifted
  blocks; the most model-like part of the Gate.
- Clean step/sand boundary without sufficient drift, lower-block dirt or contact.
- Stone still reads uniformly cool grey; more block variation and dusty warm
  lower portions would relate it to sand.
- Large lintel slabs look softer/blurrier than steps; possible UV/texel-density
  mismatch, not established fact.
- Weak darkening in joints/under arch edges makes details feel applied on top.
- A thin vertical line above the oculus might be a spire or stray geometry.
- Larger style mismatch: detailed Gate textures/leaves versus smooth low-poly
  untextured boulders and cream standing stones. Cliffs fall between them.
  Consistent stylized realism matters more than independently maximizing detail.

Claude's latest priority order:
1. Rework both large boulders and cream standing stones to fit cliff materials,
   grit/cracks and grounded sand/contact.
2. Base contact and drift, plus chipped/sunken step blocks.
3. Gate AO.
4. Lintel texel density and the thin line above the oculus.
5. Stronger controlled block variation, warmer near the bottom.

## Codex's preliminary take — source facts, not a completed new visual audit

The broad priority is sound: the most obvious material/style discontinuity in
the recent native views is the two prototype flankers and markers. Improve their
geometry/material/contact deliberately while retaining framing and sigils. Do not
replace all stone with one identical cliff texture; distinguish natural rock
from worked, worn stone and preserve the Gate's approved architecture.

Source inspection already established:
- `scripts/scenery.gd::_build_temple` instantiates Gate02 at (0,0,-18.6), scale
  .78. The dark flankers are `Art.rock` at (+/-9.4,1.4,-19.5), size (4,3.5,5.8).
  Cream markers are `Art.rock` at (+/-8,1.1,-15.4), size (1.1,2.5,.85), with
  separate sigils centered at (+/-8,1.4,-14.9).
- `art_source/gate/v2/build_gate.py` is the original Blender recipe, not CSG.
  It applies a three-segment 'Worn arris' bevel, usually .035 authored metres.
- StoneAge per-block corner colors already vary from .76 to 1.02 before joining.
  Stone authoring includes AO distance .48, 16 samples, remapped .55..1 and
  multiplied into color before baking. Roughness is mapped .78..95.
  Thus 'add bevels/AO/variation' is incomplete advice: inspect the baked/exported
  result and mission-scale visibility, then improve the actual deficiency.
- Stone groups use smart UV projection and a 4096-square atlas; source stone
  uses object-space box mapping at scale .41. Compare actual pixel density,
  island packing, mipmaps, LOD and mapping before attributing blur solely to UVs.
- The center line has authored components named 'Short axial crown blade' and
  'Axial incised line' (bronze). It is not established stray geometry. Inspect
  edge-on silhouette and reference before deciding to shorten/refine/remove it.
- Gate ivy is already bent leaf cards on modeled stems/petioles. Preserve the
  improvement; do not regress to a few flat texture panels.
- This is a sealed story facade. Door depth can be visually improved if needed,
  but do not turn it into an open/enterable dungeon or add mechanics.

Do not blindly 'bevel everything', randomize every block or multiply strong black
AO over the entire facade. Deliberate wear should preserve structural logic,
recess readability and RTS silhouette. Avoid double-darkening existing baked AO.
Keep contact material tied to physical contact and sand accumulation, not a broad
painted shadow that contradicts the directional light.

Renderer-specific advice needs checking against Godot Compatibility. Do not
migrate to Forward+, add unsupported SSAO/Decal nodes, or install an add-on merely
because the review mentions them. Existing feathered sand-contact meshes and
portable PBR are available patterns. Verify any uncertain engine behavior from
the installed engine or official docs and inspect native results.

## Required continuation workflow and scope

Read AGENTS.md and ASSET_HANDOFF.md first, then this file, GATE_REVISION_02.md,
LIGHTING_STUDY.md, LIGHTING_HANDOFF.md, REFERENCE_COMPLETION_PLAN.md,
ART_DIRECTION.md and VISION.md. Open `D:/Downloads/balanced2_goal.png` with the
image viewer (copy: `artifacts/handoff-reference/balanced2_goal.png`). Inspect
actual current native mission RTS and Gate close views, including shadows,
materials, UVs and geometry; identify confirmed defects vs review hypotheses.
Do not repeat completed broad art audits. Start with the local flanking rocks
and markers, then address verified Gate/base defects coherently.

Keep editable Blender source, deterministic rebuild recipes, portable PBR and
source provenance. Prefer reusing accepted original material sources. If a new
raster source is actually needed, use approved built-in imagegen after reading
its skill and save the exact prompts. No franchise or unverified third-party art.

Build a separate native review candidate with matched before/after cameras under
the now-integrated Lighting01 in Compatibility, not the old Gate viewer's studio
light. Reuse/extend the full-mission review patterns; view alone isn't evidence
if it uses different light or scale. Native close, RTS and base-contact views
must establish improvement. Keep the main mission runnable throughout. Document
remaining limitations honestly; aesthetic acceptance belongs to the creator.

Preserve walkable x=-21..21 z=-14..14, existing footprints, placements/resources,
deployments, story, Gate scale/framing, and mechanics. Do not intrude revised
steps/drifts into walkable space. Preserve Gate02 as historical comparison and
all other integrated assets. No characters/animation work (step3 deferred),
effects (step6), HUD (step7), general canyon redesign or new enemy/guardian.

## State and workspace safeguards

Lighting01 is integrated and pushed in `0d87639` (review `56d116a`); Debris01
integration is `b79e480`. All 12 lighting checks and 30 battle checks passed;
brief native Compatibility mission run was clean. `Battle.lighting_review`
defaults true; LightingStudy disables it before applying its own profile once.
Arena terrain/waterworks/vegetation/debris flags default true; historical
comparisons explicitly disable only what they compare.

Main branch at `D:/Games/Balance2`; Blender `C:/Blender/blender.exe`, Godot
`C:/Godot/Godot_v4.7.2-stable_win64_console.exe` and GUI sibling. Sources live
under `art_source/` with .gdignore; tooling/logs/captures stay ignored `artifacts/`.

Substantial pre-existing dirty HUD work remains in battle.gd, hud.gd, unit.gd,
tests/test_battle.gd, tests/visual_smoke.gd, art_source/ui, assets/ui, and parts
of README/ASSETS/ART_DIRECTION/ASSET_HANDOFF. Preserve dirty project.godot,
export_presets.cfg, all existing .import changes and untracked UID files.
On this handoff's audit, additional Gate02 and Debris .import files are dirty
relative to the earlier snapshot: treat CURRENT contents as pre-existing, do
not blindly restore the older lighting snapshots. Snapshot imports afresh.
Stage only task-owned hunks. Ignored `artifacts/lighting/integrate_docs.py`
illustrates selective index patches; do not rerun it unchanged. Commit/push only
cohesive owned work and update durable handoff. Do not close unrelated user
editor/game windows. AGENTS.md checks apply to new art changes; avoid lengthy
completed-asset retests for simple approved substitutions.

## Status — candidate 01 ready for review (11 November 2026)

Work began in a Claude Code session (Codex out of credits), building on Codex's
unfinished untracked `art_source/gate/cohesion/` start. Read
`GATE_COHESION_STUDY.md` for confirmed vs. unconfirmed review points, changes,
verification and limits; launch `GateCohesionStudy.bat`. Notable finding: the
"blurry lintels" were global under-resolution (13% atlas fill, uniform ~41 px/m),
not a lintel UV mismatch. Codex's rectangular tread notches were replaced.
The creator approved it ("Add it to the game"); `Arena.gate_cohesion_review`
now defaults true. Gate 02 remains available as the study's B comparison.
