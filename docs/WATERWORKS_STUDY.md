# Waterworks study 01 — 10 November 2026

Step 1 of REFERENCE_COMPLETION_PLAN.md is accepted for interim use and integrated.
The creator said: "It will do for now. Add it to the game and then open a new
session and start the next step of our plan." This is interim acceptance,
not a claim of final quality or reference parity. Launch `WaterworksStudy.bat`
(Godot 4.7.2, Compatibility) to inspect the integrated art. Gate 02, Terrain 01
and other accepted assets remain. Next: vegetation; see VEGETATION_HANDOFF.md.

## Review controls

- **1** cistern, **2** east aqueduct, **3** RTS basin, **4** southern conduit.
- **B** switches previous prototype / integrated art, with the same surroundings.
- **V** reverses the camera; useful for seeing the inlet behind the existing tree.
- Arrows or right-drag pan; wheel zooms; **R** resets; **Esc** closes.

The scene uses the mission environment palette, light direction and Compatibility
renderer. It contains scenery, not combat units or the HUD. The approved Gate,
terrain, Korali, rock and tree assets are instantiated unchanged.

## Authored assets

- Breached cistern: fitted radial foundation and staggered curved ashlar courses,
  overhanging coping, lowered broken rim, dark mineral liner and contained rubble.
  Existing animated water shader remains at height 0.185, below the vessel wall.
- Dark aged metal: open double-wall pipe bores, torn ends, separated flange,
  bolted joints, supported feed pipe, buckled riser, inspection cover and handwheel.
- Two aqueduct assemblies: moulded plinths/capitals, recessed framed pier faces,
  channel lintel with open trough, broken outer end and fractured third pier.
  Local variations are modest; these are related architectural modules.
- Intact and damaged low conduit modules for the existing southern line.

No repair objectives, interactions, new enemies or simulation changes. Substantial
stone fits the registered cistern and six pier footprints. The lintel starts
above 2.4 metres; outlying spalls are nearly flush. Low pipe clearances retain
the existing scenery convention. No collision objects are introduced.

## Sources and reproduction

`art_source/waterworks/build_waterworks.py` is the deterministic Blender recipe.
Run from the repository root:

```powershell
& C:/Blender/blender.exe --background --factory-startup --python art_source/waterworks/build_waterworks.py
& C:/Godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --editor --import --quit
```

`waterworks_authoring.blend` retains separately editable named components and
packed source images, arranged in collections across the X axis for inspection.
The script assembles and unwraps each material group, fixes triangulation before
baking, and bakes albedo, tangent normals and roughness. Stone uses a 4096 atlas,
metal 2048, damp liner and iron fasteners 512. Recess AO is baked conservatively;
fine relief is image-derived and is not a measured scan.

`TEXTURE_SOURCES.md` preserves the exact built-in imagegen metal prompt and
links the reused Gate 02 generated limestone prompt. No third-party files or
new dependencies were introduced. Generated project art is not labeled CC0.

Runtime assets are in `assets/waterworks_study/`. The GLBs reference shared PNGs
in that same folder: **copy the folder together**, not an individual GLB alone.
`share_pbr.py` repacks image bufferViews into shared files after export, avoiding
duplicate material atlases. `_surface.png` stores the glTF metallic/roughness
channels; `_roughness.png` retains the original scalar bake. Godot generates LODs.

Export triangles: cistern 43,628; each aqueduct 50,312; each conduit variant 928.
These are review meshes; texture density and repeated fine moulding remain
candidates for optimization after visual acceptance.

## Native inspection and validation

Inspected close cistern, aqueduct, conduit, reverse cistern and RTS captures from
the running Compatibility scene. First inspection prompted quieter coping
edges, visibly fractured channel ends and less repetitive conduit damage.
Final native review and final import logs contain no errors or warnings.
Intermediate import had stale texture UIDs while duplicate extracted images
were removed; reimport resolved them. Logs and captures stay ignored under
`artifacts/waterworks/`.

`tests/test_waterworks.gd`: identical 1,247 navigation cells and footprint lists,
no collision objects, accepted waterworks is the mission default, and 78,775 mesh
vertices checked for the old footprint / low detail / overhead clearances.
`tests/test_battle.gd`: 30 checks, zero failures. Shared HUD tests and gameplay
files were not edited by this pass.

## Honest limits

This first pass is accepted for interim use, not a claim of final quality.
The two aqueducts share much of their form. Stone remains quite regular away
from breaks, and close views can expose UV seams and stylized chipped corners.
The existing tree partly obscures the cistern from the default angle; V provides
an unobstructed inspection angle without moving the tree. Water has no depth,
flow or drainage simulation; machinery is static. Broader debris, vegetation,
character and lighting work remain later plan steps. Existing prototype survey
cases and unrelated stone markers are retained.
