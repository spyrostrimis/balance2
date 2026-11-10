# Vegetation — next focused chat, 10 November 2026

## Authorization and immediate task

The creator accepted Waterworks 01 for interim use: "It will do for now. Add it
to the game and then open a new session and start the next step of our plan."
Waterworks is now integrated through `Arena.waterworks_review = true`; the
study explicitly uses false for the old comparison. This new chat should begin
actual step 2 asset work now, not stop at a plan or ask for reconfirmation.

Read AGENTS.md, ASSET_HANDOFF.md, this handoff, REFERENCE_COMPLETION_PLAN.md,
VISION.md, ART_DIRECTION.md and TREE_STUDY.md. This sequence supersedes historical
next-asset lists and the earlier deferral of foliage/flowers. Character refinement
remains step 3; do not begin it in parallel.

Open `D:/Downloads/balanced2_goal.png` with the image viewer; local copy is
`artifacts/handoff-reference/balanced2_goal.png`. Also inspect the recorded
`artifacts/handoff-reference/tree-leaf-attachment-feedback.png` if present.
Target natural leaf shapes, credible attachment, denser varied canopies and
proper small buds/flowers, plus varied dry grasses, shrubs and crevice plants
in the existing border pockets. Keep the central battlefield readable.

## Feedback reopened for this step

Tree 02 bark was accepted as okay. Leaves still looked artificial; some appeared
upside down or floating/unattached. Orientation was the creator's suspicion,
not a verified diagnosis. Inspect petiole endpoints, branch connectivity,
upper/lower face orientation, winding/normals, growth direction and canopy layers.
Bud and petal geometry remained unsatisfactory. Revision 02 mainly recolored
them; it was not a flower redesign. Do deliberate botanical shape work now.

Study `art_source/tree/build_tree_v2.py`, `TEXTURE_SOURCES.md` and packed
`tree_authoring_v2.blend`. Runtime tree is `assets/tree_study/v2/desert_tree.glb`.
Inspect `scripts/basin_details.gd` for `_tree`, `_grass`, foliage materials and
TREE_POSITIONS; `scripts/scenery.gd` for `plant` and border placement. Keep tree
trunks at their registered footprints, with current placements and scale rules.
New ground cover is cosmetic and must not create hidden navigation blockers.

## Accepted production workflow

Built-in imagegen for original surface sources/cutouts when useful (read imagegen
skill), deliberate Blender geometry, deliberate UV mapping/portable baked PBR,
then real close and RTS inspection in Godot Compatibility. Preserve exact prompts,
packed editable `.blend` and reproducible recipes under `art_source/` (.gdignore).
Study the successful Gate 02, Korali, rocks and terrain recipes as needed. Generated
pictures alone are not the deliverable. No franchise art, unverified third-party
assets, generic primitive stacks plus noise, renderer migration or unnecessary
dependencies. A texture cannot fix leaf attachment or botanical shape.

Create a separate native review candidate first and open it when ready. Leave
visual acceptance/integration to the creator. Be honest about cutout geometry,
foliage density, animation and remaining visual limits. No new mechanics, guardian,
enemy, repair objectives, economy, campaigns or multiplayer.

## Preserve and validate

Gate 02, Terrain 01, Waterworks 01, Korali, sandstone02 and interim Leader02 are
integrated. Preserve them. Waterworks acceptance is interim, not final aesthetic
parity. Do not redo those assets or leader likeness now. Preserve the flat
walkable grid x=-21..21, z=-14..14, existing obstacle lists, deployment/resource
placements, story and runnable mission. Follow AGENTS.md for checks appropriate
to changes; new art needs native visual inspection. Avoid repeating lengthy
completed-integration checks.

Blender `C:/Blender/blender.exe`; Godot binaries under `C:/Godot`; repository
`D:/Games/Balance2`, main. Logs/captures/tooling belong in ignored `artifacts/`.
Commit/push cohesive task-owned work and update this handoff.

Substantial pre-existing uncommitted HUD work remains in scripts/hud.gd,
battle.gd, unit.gd, tests/test_battle.gd, tests/visual_smoke.gd, art_source/ui/,
assets/ui/ and parts of README/ASSETS/ART_DIRECTION/ASSET_HANDOFF. Preserve it,
plus project.godot, export_presets.cfg, existing texture .import changes and
untracked blue_leader_mission.gd.uid. Stage only your own hunks. Shared-doc index
patch examples: ignored `artifacts/waterworks/update_docs.py` and
`integrate_docs.py`. Read them for technique; do not rerun historical scripts.
