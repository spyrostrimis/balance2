# Ground-level debris and transitions — candidate 01 ready

## Current state — 10 November 2026

Step 4 now has a separate native review candidate. Launch `DebrisStudy.bat`;
read `DEBRIS_STUDY.md` for controls, source paths, checks and limitations. Keys
1–6 select ruin debris/paving/RTS/wreckage/roots/isolated kit; B compares the
integrated scene, V reverses. **Not accepted or integrated.** The mission default
is `Arena.debris_review = false`; all earlier accepted asset defaults remain.

Six original Blender kits, 24 placements and 28 local feathered sand contacts
cover fallen carved slabs, bedding wedges, dead branches, short exposed roots,
maintenance wreckage and shallow paving edge chips. The old random pebble
scatter is omitted only in the candidate. Existing sandstone/cistern/pier rubble
was audited and preserved rather than duplicated. Source image, exact built-in
imagegen prompt, packed editable `.blend` and deterministic recipe live under
`art_source/debris/`; six GLBs and shared portable PBR live in
`assets/debris_study/`. No third-party files or new dependencies.

30 battle checks pass. `tests/test_debris.gd` verifies all 1,247 navigation cells,
footprints, accepted asset transforms, unchanged floor, no colliders, central
radius 6 clearance, 24 placements and 29,409 mesh/transition vertices. Larger
debris stays outside navigation or within existing trunk discs. Final native
Compatibility close/RTS/kit/reverse/before views have clean logs. Captures/logs
are ignored under `artifacts/debris/`; pre-existing import state was snapshotted
there for cleanup. Shared dirty docs are staged by task-only index patch.

Limitations: repeated kit forms, stylized carving/fractures, no separate wood
end-grain atlas, approximate sand skins with possible close-angle intersections,
and subtle RTS-scale chips/roots. No claim of reference parity. Keep aesthetic
acceptance/integration with the creator. Step 3 remains deferred; step 5 follows
this review and must not be started in parallel. All pre-existing HUD/settings
work remains separate and uncommitted.

## Latest creator instruction — 10 November 2026

The creator accepted Vegetation 01 for interim use: "It will do for now. Add it
to the game and then open a new session and start the 4th step of our plan:
Ground-level debris and transitions." They explicitly defer step 3 (Characters
and animation), want step 4 now, and step 5 (Lighting and material cohesion)
afterwards. This supersedes all older next-asset lists. Start actual step 4 work
in the requested new chat; do not stop at acknowledgment or ask to begin again.

Read AGENTS.md and ASSET_HANDOFF.md first, then this file,
REFERENCE_COMPLETION_PLAN.md, VISION.md, ART_DIRECTION.md and TERRAIN_STUDY.md.
Inspect `D:/Downloads/balanced2_goal.png` with the image viewer; continuity copy:
`artifacts/handoff-reference/balanced2_goal.png`.

## Scope

Build deliberately shaped fallen slabs, loose stone, dead branches, exposed
roots and modest wreckage around existing ruins and cliff feet. Refine paving
damage, edge breakup, sand burial and contact transitions so props sit in the
landscape. Concentrate detail at the borders and existing obstacles. Keep the
central combat area quiet, readable and reachable. Study the reference's small
debris clusters and sand-to-stone transitions rather than its guardian/UI.

Audit `scripts/scenery.gd` (_build_small_details and existing pebble scatter),
`scripts/terrain_art.gd` (ground/road/landforms), `scripts/arena.gd`,
`scripts/waterworks_art.gd` and `scripts/vegetation_art.gd`. Source recipes:
`art_source/terrain/build_terrain.py`, `art_source/rocks/build_formation.py`,
`art_source/gate/v2/build_gate.py`, `art_source/waterworks/build_waterworks.py`
and `art_source/vegetation/build_vegetation.py`. Inspect existing debris included
in those accepted assets before adding duplicates. This pass is ground dressing
and transitions, not a rebuilding of the Gate, cliffs or waterworks.

Preserve the flat walkable x=-21..21, z=-14..14 grid; all registered footprints,
deployments, resources, existing story and gameplay. Cosmetic debris must not
create hidden blockers. Substantial protrusions must stay within existing solid
footprints or outside the navigation rectangle. Do not silently add obstacles.

## Accepted workflow and review

Use original built-in imagegen material sources where useful (read the imagegen
skill), deliberate Blender geometry, deliberately mapped/baked portable PBR,
and actual close/RTS Godot Compatibility inspection. Preserve exact prompts,
packed editable `.blend`, source images and reproducible recipes. Reuse accepted
project material sources where appropriate. No generic primitive stacks plus
procedural noise, no recognizable franchise or unverified third-party art, no
unnecessary dependencies or renderer migration. Pictures are not the deliverable.

Create a separate native review candidate first, open it when ready, record
honest limitations and leave aesthetic acceptance/integration to the creator.
The Vegetation/Waterworks/Terrain study pattern provides before/after and actual
basin views. Keep captures/logs/tooling ignored under `artifacts/`; sources under
`art_source/` (.gdignore). Follow AGENTS.md checks appropriate to changes; avoid
repeating lengthy checks for previously completed integrations.

## Current integrated state and deferred work

Gate02, Terrain01, Waterworks01, Vegetation01/Tree03, Korali, sandstone02 and
interim Leader02 are integrated. Vegetation is now the mission default through
`Arena.vegetation_review = true`; the study and invariant test explicitly set
false for the older comparison. It is interim acceptance, not reference parity.
Its static foliage, dense meshes, repeated plant forms and some leaf
intersections remain recorded limitations; do not resume foliage refinement.
Vegetation source/export provenance is in VEGETATION_STUDY.md.

Characters/animation are explicitly deferred. Preserve the interim leader and
all recorded likeness feedback. Do not start stone guardian/enemy work, new
mechanics, economy, campaigns or multiplayer. Step 5 follows this ground pass;
do not expand this pass into global lighting/material tuning in parallel.

## Tools and worktree hygiene

Repository `D:/Games/Balance2`, main; Blender `C:/Blender/blender.exe`;
Godot `C:/Godot/Godot_v4.7.2-stable_win64_console.exe` and GUI sibling.
Commit/push only cohesive task-owned work and update the durable handoff.

Substantial pre-existing uncommitted HUD work remains in `scripts/hud.gd`,
`battle.gd`, `unit.gd`, `tests/test_battle.gd`, `tests/visual_smoke.gd`,
`art_source/ui/`, `assets/ui/` and parts of README/ASSETS/ART_DIRECTION/ASSET_HANDOFF.
Preserve it, `project.godot`, `export_presets.cfg`, existing texture `.import`
changes and untracked `blue_leader_mission.gd.uid`. Stage only your own hunks.
Ignored `artifacts/vegetation/update_docs.py` and `integrate_docs.py` demonstrate
task-only index patches for shared dirty documents; do not rerun old scripts
unchanged. Snapshot texture import state before native checks and preserve
pre-existing changes when cleaning any new automatic importer side effects.
