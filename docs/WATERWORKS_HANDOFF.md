# Waterworks and ruins — next focused chat, 10 November 2026

## Latest state — candidate 01 ready for review

The authorized pass is complete as a separate native candidate. Open
`WaterworksStudy.bat`; read `WATERWORKS_STUDY.md` for controls, sources and limits.
Keys 1–4 select cistern/aqueduct/RTS/conduit, B compares the existing prototype,
V reverses the angle. The mission still uses its original waterworks: visual
acceptance and substitution await the creator. Do not integrate automatically
or begin vegetation/characters before their next direction.

Original curved cistern masonry, breached coping, lined interior, torn hollow
pipes, flanges/bolts/saddles/valve, carved aqueduct piers and broken watercourse,
contained rubble and two low conduit variants are under `assets/waterworks_study/`.
GLBs use shared external PNGs: retain the folder together. Exact built-in imagegen
prompt, generated metal source, Blender build/repacking scripts and packed editable
`waterworks_authoring.blend` are under `art_source/waterworks/`. Limestone reuses
the original Gate 02 source. No new third-party assets or dependencies.

Native Compatibility close/RTS/reverse inspection is complete, with clean final
review/import logs. Thirty battle checks pass. A focused check verifies all
1,247 navigation cells, unchanged footprint lists, no colliders and 78,775 mesh
vertices against the old clearance constraints. Logs/captures are ignored in
`artifacts/waterworks/`. Gate, terrain and earlier assets remain intact.

Limits: regular modular masonry and closely related aqueduct variants; static
machinery and simple water surface; no reference-parity claim. The existing tree
obscures part of the cistern from one angle. Keep the recorded later plan order.
Pre-existing HUD/settings/import edits were preserved; shared documentation was
staged with a task-only index patch in `artifacts/waterworks/update_docs.py`.

## Authorization and objective

The creator agreed to `REFERENCE_COMPLETION_PLAN.md` and explicitly requested
a new session to start step 1. Begin actual waterworks/ruins asset work now;
do not stop at acknowledgment or ask for reconfirmation. Carry a cohesive
candidate through to native Godot review, then leave visual acceptance to the
creator before mission substitution.

Read AGENTS.md, this handoff and ASSET_HANDOFF.md first, then VISION.md,
ART_DIRECTION.md and REFERENCE_COMPLETION_PLAN.md. This is the newest sequence
and overrides historical next-asset lists. Open `D:/Downloads/balanced2_goal.png`
with the image viewer (copy under `artifacts/handoff-reference/`).

## Art scope

Replace the simple waterworks and ruined stone props with original detailed
models: breached circular cistern, water-retaining interior/rim, broken pipe
connections and supports, ruined aqueduct piers/lintels, fallen architectural
masonry and small related structural remnants. Study the reference's pale worn
stone and dark aged metal, and fit them to the already integrated Gate and sand.
The water infrastructure must still convey storm damage and scarce settlement
water. These are scenery assets, not a repair system or new objective.

Read `scripts/basin_details.gd::_water_station`, `_waystation`,
`obstacle_footprints`, and `scripts/scenery.gd::_build_field_equipment`.
The cistern is at (-17, 0, -10). Existing registered footprints include its radius
2.5, the nearby (-20.5, -10.5) radius 1 prop, and aqueduct supports at
x=+/- (9.5 + i*3.1), z=-12, radius 1 for i=0..2. Preserve those footprints and
keep the walkable grid x=-21..21, z=-14..14 reachable. Fallen cosmetic pieces
must not create unregistered blockers. Keep resource/deployment positions and
story behavior. The trees and other accepted assets remain in place.

## Accepted workflow and retained assets

Use built-in imagegen for original detailed surface sources (read its skill),
deliberately authored Blender geometry, mapped/baked portable PBR, then actual
Godot close and RTS inspection. Study `art_source/gate/v2/build_gate.py` and
TEXTURE_SOURCES.md, `art_source/terrain/build_terrain.py`, and the successful
rocks/Korali recipes. Reuse original project materials when appropriate.
Do not substitute generic primitive stacks plus procedural noise. Explicit
stable faces/triangulation avoid folded-strip artifacts. Preserve exact prompts,
packed editable .blend and deterministic source scripts. No unverified third-party
art, recognizable franchise assets, unnecessary dependencies or renderer change.

Gate 02 is integrated at (0,0,-18.6), scale .78, with flanking rocks at
x=+/-9.4, z=-19.5. Terrain 01 is integrated (`4418c6c`) with
`Arena.terrain_review=true`. Keep both. TerrainStudy B explicitly selects the
old terrain. Korali, sandstone02, tree02 and interim woman Leader02 are also
integrated. Tree/flower and leader likeness work are later agreed steps; do not
start them in parallel. Do not add the reference's stone guardian.

## Workspace and review

Repo `D:/Games/Balance2`, main. Blender `C:/Blender/blender.exe` (5.2.3).
Godot `C:/Godot/Godot_v4.7.2-stable_win64_console.exe` and GUI sibling.
Mission remains Compatibility; inspect candidate in that renderer as well as
any optional study renderer. Keep logs/captures/tooling under ignored artifacts/;
sources under art_source/ (.gdignore). Maintain a runnable mission. Follow
AGENTS.md checks appropriate to changes; new art requires actual native visual
inspection. Avoid long repeated testing/capture rituals for completed integrations.
Commit/push cohesive completed work and open the actual review window.

Substantial pre-existing uncommitted HUD work is in scripts/hud.gd, battle.gd,
unit.gd, tests/test_battle.gd, tests/visual_smoke.gd, art_source/ui/, assets/ui/ and
parts of README/ASSETS/ART_DIRECTION/ASSET_HANDOFF. Preserve it. Also preserve
project.godot, export_presets.cfg, existing texture .import edits and untracked
blue_leader_mission.gd.uid. Stage only your own hunks. Prior doc-only index patch
examples are ignored `artifacts/terrain/update_docs.py` and integrate_docs.py;
they read HEAD and add only task-owned changes to the index while retaining
the dirty working copy. Do not rerun those historical scripts unchanged.
