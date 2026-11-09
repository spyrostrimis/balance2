# Sandstone formation — study 01

The third asset in the agreed review sequence, after the Korali and tree with
flowers. A warm sandstone mass has irregular bedding, angled fracture faces,
a smaller broken shoulder, two fallen blocks and five scattered chips. This
candidate is isolated for visual review; the mission's rock formations have not
been replaced.

Run `RockStudy.bat` to open its Forward+ study. **1 / 2 / 3** select close,
RTS inspection and mission camera distance. **B** compares the old formation;
**L** switches warm/neutral lighting; **Space** turns it. Drag to rotate, wheel
to zoom, **R** reset, **Esc** close. The before view recreates the rock at
mission location (-8, -6), relocated onto the review stage with its small stones.

## Authoring

The original Blender recipe is `art_source/rocks/build_formation.py`. It builds
broken strata with cleavage cuts, edge bevels and small physical erosion, then
UV-bakes original procedural materials. The editable authoring material remains
in `sandstone_authoring.blend`; the GLB uses portable texture-based PBR.

```powershell
& C:\Blender\blender.exe --background --factory-startup --python art_source/rocks/build_formation.py
& C:\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --editor --import
```

Rebuilding overwrites this study's source and outputs. Preserve manual edits
separately first. No Blender dependency is needed at runtime.

The formation has **16,766 triangles**, one material and 2048-pixel albedo,
tangent-normal and roughness maps. Godot's standard importer generates mesh
LODs. No downloaded asset pack, image-generation output or add-on is involved.

## Scope and limits

Close and RTS views have been inspected in a native Godot Forward+ window. This
establishes a reviewable asset, not whole-map performance or a finished terrain
style. Bedding is deliberately exaggerated to read from the gameplay camera;
its prominence, crest shape and color are still subject to visual judgment.
No foliage, collision, gameplay mechanics or changes to surrounding terrain
are part of this candidate. The mission retains its renderer and current rocks.
