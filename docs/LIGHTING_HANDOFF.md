# Lighting and material cohesion — step 5 integrated

**Latest follow-up:** the creator requested a new Gate/surroundings cohesion
pass based on Claude's review and independent investigation. Read
`GATE_COHESION_HANDOFF.md`; this supersedes proceeding directly to step 6.

## Current state — 11 November 2026

The creator requested: "We have credits again. Continue your work please.
Afterwards, add it to the game." Lighting 01 is now **integrated by that explicit
instruction** through `Battle.lighting_review = true`.
Open `LightingStudy.bat`; read `LIGHTING_STUDY.md` for the actual audit, recipe,
checks and limitations. B compares previous lighting and Lighting 01 at the same
camera; L separates light-only from light/material changes. 1-8 select RTS,
Gate, waterworks, ground/tree, debris, Blue, Red and Korali. H toggles HUD and
Tab hides the review overlay. Existing mission simulation is held in the viewer.

The integrated profile uses warmer sand, paler worked stone, reduced peach cliff tint,
cooler ambient fill, a restrained reflection sky and revised shadow bias.
Authored botanical/character/Korali materials and all geometry are preserved.
The reusable recipe is `scripts/lighting_profile.gd`. The mission applies it
once after construction. The review explicitly disables the mission default
and applies its own profile once to preserve the before/after comparison.
Optional uniforms on the three ground/contact shaders retain original defaults.
No new generated sources, third-party files, dependencies or renderer change.

All 12 isolation/restoration/integration checks and 30 battle checks pass. All eight native
before/after views were inspected in Compatibility; final logs are clean.
Artifacts stay under ignored `artifacts/lighting/`. The tracked import state was
snapshotted before runs; pre-existing HUD/settings/source work remains separate.

**Next in the recorded plan: step 6, combat effects and unit presentation.**
It has not begun. Step 3 remains deferred and step 7 stays later. Integration
authorization does not claim final aesthetic quality or reference parity.
Historical start instructions below record the request that produced this pass.

## Creator instruction — 11 November 2026

The creator approved Debris 01: "Add it to the game and then open a new session
and start step 5: Lighting and material cohesion". Debris 01 is now integrated
through `Arena.debris_review = true`. Begin actual step 5 work in the requested
new chat; do not stop at acknowledgement or ask to begin again.

Read AGENTS.md and ASSET_HANDOFF.md first, then this handoff,
REFERENCE_COMPLETION_PLAN.md, VISION.md, ART_DIRECTION.md, TERRAIN_STUDY.md and
DEBRIS_STUDY.md. Inspect `D:/Downloads/balanced2_goal.png` in the image viewer;
continuity copy: `artifacts/handoff-reference/balanced2_goal.png`.

## Scope

Unify warm sand, pale worked stone, sandstone, weathered metal and vegetation
with cooler shade through directional light, ambient fill, shadow and material
tuning. Preserve recognizable material differences, Blue/Red unit readability,
Korali restraint and clear combat space. Assess the actual full mission at RTS
distance plus close views, not only isolated objects or generated pictures.

Audit the actual mission environment/light setup in scenes and scripts, portable
materials and shaders, and duplicated light settings in the study viewers.
Compare color, roughness, normal strength, texture scale, shadow behavior and
contact transitions before deciding what to adjust. Use a coherent reusable
setup where useful, but keep before/after comparison at identical camera views.
Do not make every asset the same color or hide defects with darkness/bloom.

Stay in Godot Compatibility. No renderer migration, new dependency or global
project-settings overwrite. Existing `project.godot` is dirty user work. Prefer
scoped resource/script changes. Build a separate native review candidate first,
open it when ready, and leave aesthetic acceptance/integration to the creator.
Use real geometry/PBR; generated images alone are not deliverables. Reuse the
accepted original sources. If new raster sources are needed, read/apply imagegen
skill and preserve exact prompts; retain editable/reproducible source work.

## Preserve

Gate02, Terrain01, Waterworks01, Vegetation01/Tree03, Debris01, Korali,
sandstone02 and interim Leader02 are integrated. Terrain/waterworks/vegetation/
debris review flags default true; the corresponding viewers/tests explicitly
set false for historical comparison. Do not accidentally make that comparison
the mission default. Debris 01 contains 24 kit placements and 28 local contacts;
geometry and native views already passed review and creator integration approval.

Keep the flat walkable x=-21..21, z=-14..14 grid, registered footprints,
deployments, resource positions, mission/story behavior and small runnable
mission. No new mechanics, guardian/enemy, character/foliage remodeling or HUD
redesign. Step 3 characters/animation remains deferred. Step 6 effects and unit
presentation and step 7 final HUD/composition are later work, not parallel tasks.

## Workspace and checks

Repo `D:/Games/Balance2`, main. Godot binaries `C:/Godot`; Blender
`C:/Blender/blender.exe`. Sources under `art_source/` (.gdignore); logs/captures
under ignored `artifacts/`. AGENTS.md requires a windowed check for visual/input
changes, and headless battle checks for gameplay changes. Keep checks appropriate
to this new lighting pass; do not repeat lengthy art audits of completed assets.

Substantial pre-existing dirty HUD work remains in scripts/hud.gd, battle.gd,
unit.gd, tests/test_battle.gd, tests/visual_smoke.gd, art_source/ui/, assets/ui/,
and portions of README/ASSETS/ART_DIRECTION/ASSET_HANDOFF. Preserve it, dirty
project.godot, export_presets.cfg, texture .import changes and untracked
blue_leader_mission.gd.uid. Stage only task-owned changes/hunks. Snapshot current
import state before native checks. `artifacts/debris/update_docs.py` and
`integrate_docs.py` illustrate task-only shared-document index patches; do not
rerun them unchanged. Commit/push only cohesive task-owned work and update the
durable handoff. Do not close unrelated editor/game windows.
