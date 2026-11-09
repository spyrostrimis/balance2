# Korali study 01

This isolated art test follows the creator's request to pause feature work and
evaluate one rock before the tree/flowers and rock formation. The creator
approved the improvement and asked to put it in the game. First Contact now uses
the new deposit with its slate tint; the mission renderer remains unchanged.
The original rock remains available for comparison in this review scene.

## Inspect

Run `KoraliStudy.bat` on the configured Windows machine, or:

```powershell
& C:\Godot\Godot_v4.7.2-stable_win64.exe --path . --rendering-method forward_plus res://scenes/korali_study.tscn
```

The launcher overrides rendering for this process only. Vulkan Forward+ was
checked on the development machine's RTX 4060 Ti. No Blender installation is
needed to view the exported asset. Other hardware has not been profiled.

| Input | Purpose |
| --- | --- |
| 1 | Close view, orthographic size 6.3 |
| 2 | RTS inspection, size 18 |
| 3 | Mission default distance, size 36 and camera offset (0, 33, 26) |
| B | Old/new asset comparison, same stage, light and camera |
| L | Warm / neutral light |
| Space | Start/stop turntable |
| Drag | Turn the rock |
| Wheel | Zoom |
| R | Stop rotation, restore orientation and close view |
| Escape | Close study |

These are actual viewport images. The ground is a simple review surface;
terrain art, vegetation, story and gameplay are outside this study's scope.
The mission-distance view reproduces camera scale and angle, not mission
lighting, terrain, UI or an entire integrated scene.

## Asset construction

Blender 5.2.3 LTS builds an asymmetric fractured main mass, a smaller shoulder
and two chips. Scripted plane cuts, bevels and small erosion displacement shape
the mesh; the source is editable rather than a flattened render. The current
export has **17,824 triangles / 8,920 source vertices**. glTF can split vertices
at UV seams. This is a single review asset, without collision or authored LODs;
Godot's importer has automatic mesh LOD generation enabled.

A generated slate source image provides stone color and some surface relief.
Original warped, branching mineral masks control turquoise color, warm edge
deposits, metallic response, roughness and restrained emission. All are UV-baked
to 2048-pixel textures. The Godot review duplicates the imported material and
applies an RGB (0.72, 0.75, 0.78) slate tint; the GLB itself retains the untinted
maps. No bloom is enabled to disguise the mineral surface.

| File | Content |
| --- | --- |
| `korali_albedo.png` | sRGB stone and mineral base color |
| `korali_normal.png` | Tangent-space normal, linear data |
| `korali_orm.png` | R = 1 (no baked AO), G = roughness, B = metallic |
| `korali_emission.png` | Restrained mineral emission color |
| `korali_study.glb` | Mesh, portable PBR material, embedded maps |

Godot extracts embedded textures beside the GLB with a `korali_study_` prefix;
these match the bake outputs. The editable source is under `art_source/korali/`,
excluded from Godot's asset scanner by `art_source/.gdignore`. The packed
`.blend` preserves the procedural authoring material before export. The Python
script is the reproducible build recipe; rerunning it overwrites that study's
source and outputs, so preserve hand edits separately before rebuilding.

```powershell
& C:\Blender\blender.exe --background --factory-startup --python art_source/korali/build_korali.py
& C:\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --editor --import
```

## Review and limits

Judge silhouette, stone/mineral separation and readability at both distances.
The wide view deliberately exposes how much small texture detail disappears.
The veins are predominantly material relief rather than deeply carved geometry;
the shoulder and cut planes may still need artistic refinement. There is no
claim of matching the concept's iridescence, richer fractures or final quality.
Further changes should follow the creator's visual review before expanding to
other environment assets. No whole-game performance conclusion follows from
this small scene.

`tests/capture_korali.gd` checks imported PBR maps, before/after shortcut,
mission camera scale, rotation and reset, and captures five windowed Forward+
views under `artifacts/`. Use a real rendering window, not headless, for it.
The existing battle test remains the check that First Contact is runnable.
