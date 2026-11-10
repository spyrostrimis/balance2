# Original vegetation surface sources — 10 November 2026

`surface_atlas_source.png` is the unchanged original output of the built-in
imagegen tool, generated in this chat without input images. The complete exact
prompt is in `SURFACE_PROMPT.txt`. No CLI/API fallback, downloaded plant art,
franchise material, add-on or new dependency was used. Generated project art is
not described as a CC0 asset or physical scan.

Four opaque surface fields: top-left olive leaf, top-right dry grass, bottom-left
waxy succulent, bottom-right apricot/ivory petal. The image is a UV material
source, not a plant illustration used to stand in for geometry. UVs place each
leaf's midrib along its physical fold and each blade's fibers along its length.
All outlines are geometry. There are no alpha cards or cutout silhouettes.

Bark reuses `../tree/bark_basecolor_source.png`, generated for accepted Tree 02.
Its exact original prompt and provenance remain in `../tree/TEXTURE_SOURCES.md`.
No existing image or integrated tree export is overwritten.

`build_vegetation.py` bakes both sources in Blender into 1024px albedo,
tangent-normal and roughness maps. Relief derives from image luminance and is
not scan-derived. The glTF exporter packs roughness into green and metallic
zero into blue in the `*_surface.png` files; grayscale `*_roughness.png` files
remain the authoring bake outputs. GLBs share sibling PNGs; preserve the whole
export folder. The source images and baked maps are packed into
`vegetation_authoring.blend`. Named kit collections contain editable geometry.

Linear per-vertex colors vary shoots, blades, undersides and petals. This local
Godot 4.7.2 import retained COLOR_0 but did not enable use-as-albedo; the candidate
helper explicitly enables it. Texture `.import` files enable mipmaps to prevent
the severe surface shimmer seen in the first native inspection.

Rebuild from repository root:

```powershell
& C:/Blender/blender.exe --background --factory-startup --python art_source/vegetation/build_vegetation.py
& C:/Godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --editor --import
```

Rebuild replaces study exports and packed source. Preserve manual changes first.
The deterministic script uses seed 1101026 and writes attachment/normal summary
metadata to `asset_info.json`; full diagnostic records stay in ignored
`artifacts/vegetation/attachment_audit.json`.
`audit_original.py` reads the prior packed tree and GLB without modifying them;
its findings are retained in `original_audit.json`.
