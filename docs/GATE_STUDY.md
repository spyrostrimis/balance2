# Sanctuary Gate — study 01

Separate review candidate based on the sanctuary in the approved concept board,
especially its lower-right panel. The mission still uses its previous gate at
(0, 0, -18.6). Visual acceptance is required before replacing that assembly.

The facade has a tall split central spire, three sweeping ribs on each wing,
flared buttresses, coursed limestone, four nested pointed archivolts, recessed
sealed doors, a carved circular seal with bronze inlay, nine stone steps and
two suspended embroidered purple banners. The cloth has actual folds and a
split hem. A narrow violet seam is the only emissive surface.

Run `GateStudy.bat` for the native Godot Forward+ review scene:

- **1** close view; **2** RTS inspection; **3** mission camera distance.
- **B** current mission gate comparison, at its original scale.
- **L** warm/neutral light; **Space** turntable; drag to rotate; wheel to zoom.
- **R** reset; **Esc** close.

The new facade is about 16.8 metres wide and 12.3 metres tall. It deliberately
recovers the concept's vertical silhouette; the old prototype is about 6 metres
tall. Both use the same world units. Future integration must review cliff fit,
the opening camera and the approach footprint; no mission transforms or
navigation are changed by this study.

## Source and rebuild

`art_source/gate/build_gate.py` constructs the original geometry and maps/bakes
the generated material sources. `gate_authoring.blend` preserves editable mesh,
UVs, authoring shaders and packed source images. The GLB has portable PBR
materials and embedded maps; no Blender dependency is needed at runtime.

```powershell
& C:\Blender\blender.exe --background --factory-startup --python art_source/gate/build_gate.py
& C:\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --editor --import --quit
```

Rebuilding overwrites this study's outputs. Save manual edits separately first.
Stone maps are 4096 square; door and cloth maps are 1024 square. Fine stone
relief and weave derive from generated source luminance; large joints, bevels,
arch ribs, worn corners, folds and seal are geometry. Bronze uses constant PBR
values. Exact generation prompts are in `art_source/gate/TEXTURE_SOURCES.md`.
Export statistics are in `assets/gate_study/asset_info.json`.
The current export contains 109,908 triangles across five material groups;
Godot generates mesh LODs on import.

## Limits

Validation: Godot import completed and the native Forward+ window was inspected
close-up and at RTS distance. The first build was also checked at mission
distance and against the old gate. Sloping top courses and staggered step joints
were corrected after inspection, then the revised asset was reimported and
viewed again. Import and runtime logs contained no script errors. No gameplay
code changed, so the gameplay suite was not rerun for this isolated art study.

This is a facade asset, with a closed rear and sealed door, not an explorable
interior. The ring and needle are visual motifs drawn from the approved
reference, not newly established lore. Banners are static. There is no collision,
door interaction, animated opening or new gameplay. Cliff blending, accumulated
sand and the wider sanctuary environment belong to a later integration pass.
Generated albedo has some illustrated relief; these are not measured material
scans. The isolated Forward+ review does not establish mission-renderer parity
or whole-map performance.
