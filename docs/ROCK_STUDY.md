# Sandstone formation — study 02

The third asset in the agreed review sequence, after the Korali and tree with
flowers. The creator rejected revision 01 as insufficient compared with Korali.
The first attempt's repeating strata and procedural noise lacked the Korali
asset's rich fracture texture and natural shape. Revision 02 replaces the
tiered mesh with irregular cut masses and uses the same generated stone surface
and Blender PBR bake approach that worked for Korali. A smaller broken shoulder,
two fallen blocks and five chips complete the silhouette. This
revision was approved by the creator, who requested the same workflow for the
tree. At the user's subsequent request it now replaces the four mission rock
formations, retaining their positions and navigation footprints. Redundant old
pebble rings were removed because the new asset includes its own debris.

Run `RockStudy.bat` to open its Forward+ study. **1 / 2 / 3** select close,
RTS inspection and mission camera distance. **B** compares revision 01;
**K** compares the approved Korali under the same camera and lighting.
**L** switches warm/neutral lighting; **Space** turns it. Drag to rotate, wheel
to zoom, **R** reset, **Esc** close. Revision 01 is preserved under
`assets/rock_study/previous/` for comparison.

## Authoring

The original Blender recipe is `art_source/rocks/build_formation.py`. It builds
irregular rock masses with cleavage cuts, edge bevels and small physical erosion.
A generated sandstone source texture is box-projected and UV-baked, with aligned
normal detail derived from its luminance and a restrained fine-grain contribution.
The color bake includes a muted value adjustment; roughness remains dry and high.
The editable authoring material and packed source image remain in
`sandstone_authoring.blend`; the GLB uses portable texture-based PBR. Exact
generation prompt and provenance are in `art_source/rocks/TEXTURE_SOURCE.md`.

```powershell
& C:\Blender\blender.exe --background --factory-startup --python art_source/rocks/build_formation.py
& C:\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --editor --import
```

Rebuilding overwrites this study's source and outputs. Preserve manual edits
separately first. No Blender dependency is needed at runtime.

The formation has **17,182 triangles**, one material and 2048-pixel albedo,
tangent-normal and roughness maps. Godot's standard importer generates mesh
LODs. No downloaded asset pack or Blender add-on is involved. The generated
surface image is project art; it is not a CC0 pack or a measured material scan.

## Scope and limits

Close and RTS views have been inspected in a native Godot Forward+ window. This
establishes a reviewable asset, not whole-map performance or a finished terrain
style. Shape, texture scale and color remain subject to visual judgment.
Fine relief is carried by a normal map, not deep sculpted cracks. The generated
albedo can contain some illustrated relief despite the flat-lighting prompt;
it should not be treated as physically measured base color.
No foliage, collision, gameplay mechanics or changes to surrounding terrain
are part of this asset. The mission retains its renderer and navigation rules.
