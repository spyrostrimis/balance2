# Blue Leader source record

Created 9 November 2026 with the built-in imagegen tool. These are generated
original project sources, not photographs, downloaded textures or CC0 assets.
No real person's identity or franchise artwork was supplied.

| Source | Exact prompt | Use |
| --- | --- | --- |
| `material_source.png` | `material_source.prompt.txt` | Four material quadrants: cobalt paint, ivory linen, leather and skin |
| `face_source.png` | `face_source.prompt.txt` | Neutral frontal adult woman facial detail and modeling reference |

The first output was generated at
`exec-3cbdb9c5-d5fc-470b-83cc-f141d8587fdb.png`; the facial source at
`exec-6ad9edc3-3d2e-459e-b6ab-3d6067304b80.png`. Copies are preserved here.
Prompts are verbatim in the companion text files. No fallback API was used.

The four material quadrants are sampled with a fractional SourceUV followed by
an inset quadrant transform. This prevents repeat UVs from reaching another
material. The face is projected with explicit eye, nose, mouth and chin
landmarks, blending into plain skin toward the sides/back. Source lighting is
not perfectly neutral; some subtle shading remains in the generated facial
albedo. It is not a substitute for the modeled facial profile.

All visible geometry is original: shaped body sections, sculpted cranium and
face, separate orbital/lip surfaces, hair cap and swept locks, interwoven braid,
curved armor plates, cloth surfaces, gloves, boots, equipment and pistol.
There is no donor male head or donor armor mesh in this candidate.

Blender bakes source materials into portable albedo, tangent normal and
roughness maps on a separate BakeUV. The original SourceUV and packed images
remain editable in `leader_authoring.blend`. Normal maps represent fine surface
grain; face, hair, armor and folds obtain their major depth from geometry.

The existing Quaternius Spacesuit armature and animation actions are reused
under the pack's verified CC0 license. Original files are unchanged. The
pack-specific license, provenance and SHA-256 record remain under
`assets/third_party/quaternius/modular_men/`; see `docs/ASSETS.md`.
