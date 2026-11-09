# Basin tree and root flowers — study 01

The next asset after the approved Korali rock: a desert shade tree with a bowed,
tapering trunk, visible branching structure and roots, a layered sage canopy,
and three blue-green succulent rosettes carrying small orange-gold flowers.
The creator approved the improvement and requested integration. The four mission
trees now use this asset, with height and rotation variation at their existing
positions. The root flowers replace the previous scattered prototype plants
around each tree. Navigation footprints remain unchanged. The old tree generator
is retained only for the review scene's comparison.

## View

Run `TreeStudy.bat`. It uses the shared Korali review stage with Forward+,
warm/neutral lighting and an old/new comparison. The tree view enables temporal
antialiasing and uses a smaller sun angle to stabilize fine foliage shadows.

- **1:** close view, orthographic size 8.
- **2:** RTS inspection, size 18.
- **3:** mission default distance, size 36, camera offset (0, 33, 26).
- **B:** old/new tree and flowering plants.
- **L:** warm/neutral lighting.
- **Space:** turntable; drag to rotate; wheel to zoom.
- **R:** reset; **Esc:** close.

The stage is a neutral review surface, not a completed terrain scene. The old
tree uses the existing mission generator, height 3.6 and seed 47. Its scale and
shape vary slightly among instances in the mission.

## Source

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
