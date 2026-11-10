# Terrain study 01 — 10 November 2026

Native review candidate for the terrain request following approved Gate 02.
Launch `TerrainStudy.bat`. It uses Compatibility and the mission's actual
lighting, assets and placements. This candidate is not yet visually accepted
and does not replace the playable mission terrain.

## Review

- **1**: RTS basin, camera size 36 (the mission's starting size).
- **2**: closer canyon / Gate relationship.
- **3**: sand and buried paving close-up.
- **4**: full landscape overview.
- **B**: baseline / candidate at the same camera and lighting.
- Arrows or right-drag pan; wheel zooms; **R** resets; **Esc** closes.

There is no painted background. The sandy floor, raised outer ground, cliff
buttresses, detached shoulders, talus, road and surviving stone courts are 3D.
The Gate, Korali, trees, obstacle rocks, cistern and aqueduct props are the
existing mission assets. Troops and HUD are omitted from this terrain viewer.

## Art and source

- `art_source/terrain/build_terrain.py`: deterministic original Blender recipe.
- `art_source/terrain/terrain_authoring.blend`: editable meshes, packed source
  textures and portable materials (Blender 5.2.3).
- `art_source/terrain/TEXTURE_SOURCES.md`: exact built-in imagegen prompts and
  provenance; sand and stratified cliff source PNGs are beside it. The generated
  source files are 1254 square; runtime PBR tiles are baked at 1024 square.
- Paving reuses the original generated Gate 02 limestone source. No new
  third-party art, add-ons, dependencies or franchise imagery were introduced.
- `assets/terrain_study/`: three cliff GLBs, paving GLB, albedo / tangent normal /
  roughness maps, import settings and triangle counts in `asset_info.json`.
- `scripts/terrain_art.gd`: landscape assembly and authored vertex blend masks.
- `shaders/terrain_sand.gdshader` and `terrain_paving.gdshader`: world-scale
  material blending and sand accumulation at the edges of stone courts.

Rebuild from the repository root:

```powershell
& C:/Blender/blender.exe --background --factory-startup --python art_source/terrain/build_terrain.py
& C:/Godot/Godot_v4.7.2-stable_win64_console.exe --headless --editor --path . --import
```

Blender bakes generated image detail to portable PBR tiles and maps the meshes
at metre scale. Explicit triangles precede export. The cliff beds are connected
fracture meshes with asymmetric setbacks and detached shoulder masses, rather
than stacks of rock primitives. Sand tiles span four metres, with a second
thirteen-metre sample reducing obvious repetition. Vertex masks place compacted
earth, a winding drift, cistern runoff and edge grit. Texture imports enable
mipmaps for close and RTS inspection. Preserve these import settings on rebuild.

## Preservation and validation

`Arena.terrain_review` defaults to false. The standalone viewer opts in; the
mission and existing studies continue using the baseline. Shared scenery
construction was split without changing the baseline's RNG call order.
Gate 02 remains at (0, 0, -18.6), scale .78; its flanking rocks and markers are
preserved. Resource/deployment positions, story and obstacle footprints remain.

`tests/test_terrain.gd` passes: all 1,247 navigation cells and the obstacle list
match; no collision objects are introduced; every playable floor vertex remains
at y=-.015 and faces upward; all raised cliff vertices stay outside a half-metre
margin around the navigation rectangle. `tests/test_battle.gd`: 30 checks pass.
Native Compatibility review was inspected at RTS, cliff, ground and overview
distances and with baseline comparison; final logs contain no script/shader
errors. Temporary captures and logs are under ignored `artifacts/terrain/`.

## Honest limitations

This is a first terrain candidate, not claimed parity with the reference.
The three repeated cliff modules and their related bed profiles remain visible,
especially in overview; they are less varied than a fully sculpted canyon.
Some cliff UV seams and hard shelf shadows can be found close up. Ground relief
inside the playable grid is intentionally shading only. Court outlines and their
burial transitions are stylized; there is no displacement or simulated sand.
Normal relief is derived artistically from color, not scanned geometry.
The candidate has about 0.5 million terrain triangles before Godot LODs; it is
review art rather than a profiled final production budget. Existing low-detail
aqueduct/cistern props, Gate flanking rocks, tree feedback and character likeness
are outside this pass. Aesthetic acceptance and integration remain with the user.
