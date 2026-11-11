# Debris 01 — original material sources

Generated with the built-in imagegen tool on 10 November 2026. This is original
project art, not a downloaded texture and not declared CC0. No new dependencies.

`deadwood_source.png` is the selected 1254 square source. Exact prompt:

```text
Use case: stylized-concept
Asset type: original game PBR base-color texture source, square seamless weathered deadwood grain tile for Blender mapping.
Primary request: a straight-on orthographic macro material swatch of sun-bleached desert deadwood. Fill the entire image edge to edge with longitudinal grey-taupe and warm muted brown exposed wood fibers running vertically. Long irregular split fibers, layered splinters, small knots and fine age checks; a few thin surviving bark strips, no full log silhouette. Rich specific natural grain, restrained contrast, believable stylized realism suitable for a high camera RTS ancient desert ruin.
Lighting: flat diffuse neutral albedo, no directional cast shadows, no glossy highlights, no ambient vignette.
Constraints: no perspective, no objects, no border, no lettering, no watermark, no painted lighting, no franchise imagery; continuous repeat-friendly grain. This will be wrapped along actual modeled branches and splintered boards, not used as an illustration.
```

Reused original project sources: `../gate/v2/aged_limestone_source.png`
(exact prompt in that folder's TEXTURE_SOURCES.md), `../terrain/cliff_source.png`
and the terrain's sand PBR (../terrain/TEXTURE_SOURCES.md), and
`../waterworks/aged_pipe_source.png` (../waterworks/TEXTURE_SOURCES.md).
The builder bakes 1024 square albedo/normal/roughness tiles, maps wood along each
branch, and uses metre-scale stone mapping. Relief is artistic color-derived
bump, not a scanned or sculpted high-poly normal bake. Sand transitions use the
accepted terrain textures in a Compatibility shader. Editable meshes and images
are packed in debris_authoring.blend; build_debris.py deterministically rebuilds.
