# Basin tree and root flowers — study 02

**10 November update:** Vegetation 01 / Tree 03 is now the mission default,
accepted for interim use. `VegetationStudy.bat` retains Tree 02 comparison.
See `VEGETATION_STUDY.md` and `VEGETATION_HANDOFF.md` for the measured winding/
attachment audit, rebuilt geometry, ground-cover kits and native review results.
This supersedes the historical deferral below. Characters are deferred; step 4
(debris/transitions) is next, then step 5. See `DEBRIS_HANDOFF.md`.

After approving the textured sandstone revision, the creator requested the same
generated-source/Blender-bake workflow for this tree. Revision 02 adds detailed
weathered bark, veined green leaves and textured blue-green root rosettes while
preserving the branching silhouette and small flowers. The user requested
integration of revision 02 from `assets/tree_study/v2/`; it is now in the mission.
The bark is acceptable, but foliage still looks artificial, some leaves appear
inverted or unattached, and buds/petals need genuine geometry improvements.
These are acknowledged unfinished areas, explicitly deferred while work moves
to the Gate and then Blue Leader. See `ASSET_HANDOFF.md` for the screenshots.

Revision 01 was approved after Korali and integrated into the four mission tree
positions, with height and rotation variation. Its root flowers replaced the
old scattered prototype plants. Navigation footprints remain unchanged. That
older asset supplies the before view here; revision 02 now occupies its places.

## View

Run `TreeStudy.bat`. It uses the shared Korali review stage with Forward+,
warm/neutral lighting and an old/new comparison. The tree view enables temporal
antialiasing and uses a smaller sun angle to stabilize fine foliage shadows.

- **1:** close view, orthographic size 8.
- **2:** RTS inspection, size 18.
- **3:** mission default distance, size 36, camera offset (0, 33, 26).
- **B:** revision 01 / revision 02 (current mission).
- **L:** warm/neutral lighting.
- **Space:** turntable; drag to rotate; wheel to zoom.
- **R:** reset; **Esc:** close.

The stage is a neutral review surface, not a completed terrain scene. Both
versions use the same branching silhouette and scale for material comparison.

## Revision 02 source

Run `art_source/tree/build_tree_v2.py` with Blender to rebuild the candidate.
It writes `art_source/tree/tree_authoring_v2.blend` and
`assets/tree_study/v2/desert_tree.glb`. Both generated images are packed in the
Blend file. Exact prompts and provenance: `art_source/tree/TEXTURE_SOURCES.md`.

The bark source follows the curved trunk and branches using a dedicated source
UV layout, then bakes into a unique 2048-pixel albedo/normal atlas. The shared
leaf color and normal maps are 1024 pixels; the blue-green root rosette map is
512 pixels. The same folded leaf geometry and per-spray vertex colors remain.
Flower geometry and colors are preserved. Normal detail is derived from image
luminance, not a physical scan. Some illustrated shading may remain in the
source textures despite the flat-illumination prompts.

This revision still has **38,976 triangles, 1,320 canopy leaves and six material
groups**. The change primarily improves the surfaces, without adding geometry.
It introduces generated project art, not a CC0 asset pack. No add-on or runtime
Blender dependency is needed. Native Forward+ close and RTS views were inspected.

## Preserved revision 01 source

All geometry and maps are original and reproducible with:

```powershell
& C:\Blender\blender.exe --background --factory-startup --python art_source/tree/build_tree.py
& C:\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --editor --import
```

The script writes `art_source/tree/tree_authoring.blend`, packing the baked
maps, and exports `assets/tree_study/desert_tree.glb`. Rebuilding overwrites
these outputs; preserve any manual Blender edits before doing so.

The export contains six mesh/material groups and **38,976 triangles**, including
**1,320 individual canopy leaves**. Leaves use shaped, folded geometry instead
of transparent cards or solid canopy lumps. A shared 512-pixel leaf map supplies
small veins and color variation; vertex colors vary the leaf sprays. Bark uses
1024-pixel albedo and tangent-normal maps. glTF includes portable materials and
the vertex colors. Godot's default importer generates automatic mesh LODs.

No external asset pack, AI-generated texture, add-on, or runtime Blender
dependency is introduced. Source generation uses Blender's standard Python API.

## Current limits

Foliage is static. There is no wind animation, authored collision, seasonal
variant, billboard LOD or grove performance tuning. Leaf patterns may still
need variation after visual review. Flower stalks and leaves have simple
materials; the focus is their small-scale silhouette and color accent.
Close and RTS views have been inspected in a native Godot Forward+ window on
the development machine. A separate study does not establish whole-map
performance or the final appearance under mission lighting.
