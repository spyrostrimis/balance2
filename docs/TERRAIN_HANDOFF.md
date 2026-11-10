# Terrain — next focused chat, 10 November 2026

The creator approved Gate revision 02: "It's very good. Add it to the game.
Next, do the same for the terrain - in a new session you'll open".
The Gate integration is complete. Begin the terrain work now; no reconfirmation
is needed. This request supersedes earlier next-asset lists in the handoff.

## Reference and intended result

Open `D:/Downloads/balanced2_goal.png` with the image viewer. A local copy is at
`artifacts/handoff-reference/balanced2_goal.png`. The user wants the same quality
improvement for the terrain as for the Gate. Read `VISION.md` and
`ART_DIRECTION.md` for the established original stylized-realism direction.

Focus on the uploaded image's warm sandy basin, natural colour/material
variation, worn stone ground patches and processional paving, rocky transitions,
and convincingly eroded layered canyon cliffs. Treat terrain as ground plus its
border landforms; use judgment to keep the pass cohesive. Improve actual 3D
geometry/materials, not just lighting or a painted background. Match the visual
relationship between pale worked stone, warm cliff rock and sandy floor.
Ground cover can support transitions, but desert-tree foliage/flowers and leader
appearance remain explicitly deferred. Do not expand the HUD, units or gameplay.

## Current implementation

- `scripts/basin_details.gd::terrain` builds the basin mesh and raised borders.
- `shaders/sand.gdshader` supplies the ground material.
- `scripts/scenery.gd::build` constructs prototype canyon rocks/ledges;
  `_build_road` constructs the paving and markers.
- `scripts/arena.gd` owns terrain assembly and AStarGrid2D navigation.
- The walkable grid spans x = -21..21, z = -14..14. Keep the play area flat and
  reachable; retain the deposit, deployment positions and existing obstacle
  footprints. Cosmetic cracks/stone patches must not silently create new blockers.
- The approved Gate 02 GLB is at (0, 0, -18.6), scale 0.78. Preserve it and
  fit the terrain around its steps/porticoes. The flanking rocks were moved to
  x = +/-9.4, z = -19.5; final discovery focus is (0, 3.0, -18), size 14.
- Korali, sandstone 02, tree 02 and interim woman Leader 02 are already integrated.

## Required working approach

Use the successful art workflow: built-in imagegen material sources, deliberate
original Blender geometry where needed, mapped/baked portable PBR, actual Godot
close and RTS review. Ground materials may need tiling textures and authored
blend masks; use appropriate scale rather than stretching one image over the map.
Avoid generic primitive stacks plus procedural noise: the creator rejected that.
Preserve exact prompts, editable packed .blend files and reproducible scripts.
No third-party file without verified license/provenance. No renderer migration.
No new economy, missions, dependencies or mechanics simply for this art task.

Study `art_source/gate/v2/build_gate.py`, `TEXTURE_SOURCES.md`,
`art_source/rocks/build_formation.py` and the Korali source. Gate 02's carved
strips use explicit faces and stable triangulation before baking to avoid folded
triangles. New art needs actual visual inspection, with lightweight checks.
Follow AGENTS.md for gameplay changes, if any become necessary.

Use the existing accepted mission as the baseline. Develop a reviewable terrain
pass and open its native review when ready; don't stop at a plan or new concept
image. Record candid limitations and let the user judge the aesthetic match.

## Workspace and preservation

Repo: `D:/Games/Balance2`, branch main. Blender: `C:/Blender/blender.exe`.
Godot: `C:/Godot/Godot_v4.7.2-stable_win64_console.exe` and GUI sibling.
Mission renderer remains Compatibility; asset studies can launch Forward+.
Keep logs/captures/tooling under ignored `artifacts/`; sources have `.gdignore`.

There is substantial pre-existing uncommitted HUD work in `scripts/hud.gd`,
`battle.gd`, `unit.gd`, battle/visual tests, `art_source/ui/`, `assets/ui/`, and
parts of README, ASSETS, ART_DIRECTION and ASSET_HANDOFF. Preserve it. Also
preserve project.godot, export_presets.cfg, texture .import changes and the
untracked blue_leader_mission.gd.uid. Do not stage unrelated changes. For shared
docs, stage only your own hunks. Gate commits used a baseline snapshot and a
separate LF-only patch applied to the index to preserve the HUD work unstaged.
Continue the established commit/push workflow for completed cohesive art changes.
