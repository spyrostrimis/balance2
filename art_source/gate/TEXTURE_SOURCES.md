# Gate material sources — 9 November 2026

Both images were generated with the built-in imagegen tool for Balance. They
are original generated project art, not scanned materials or a CC0 pack.
Geometry is original Blender construction. No external art was downloaded.

## limestone_basecolor_source.png

Exact prompt:

Use case: stylized-concept. Asset type: production base-color material source for an original 3D ancient desert sanctuary in a stylized-realism RTS. Generate one square 2048x2048 flat orthographic material swatch filling the entire image edge to edge: aged pale ivory limestone, warm muted buff mineral mottling, fine granular pores, hand-worked broad chisel traces, a few thin branching hairline fractures and subtle brown dust caught in pits, localized weathered ochre areas. Convincing rich stone detail at several scales with broad calm areas, not busy all over. This is a single continuous stone surface, NOT a wall of bricks, NOT architecture, NOT a rendered object. The stone should read pale cream-grey rather than orange sandstone. Entirely even diffuse illumination, no directional cast shadows, no specular highlights, no vignette, no perspective. No large seams, no bevels painted at the image edges, no text, no symbols, no border. Original material for a monumental carved stone gate, physically plausible but carefully art-directed.

## banner_basecolor_source.png

Exact prompt:

Use case: stylized-concept. Asset type: flat UV base-color source for a hanging ceremonial purple banner on an original ancient sanctuary 3D game asset. Make a portrait 1024x1536 image of ONLY a rectangular swatch of deep desaturated palatinate purple woven cloth, filling the canvas completely edge to edge, flat face-on orthographic with no background and no perspective, no draped silhouette and no large folds. Very detailed woven fibres and softly weathered areas, subtle dusty wear towards lower edge. Thin understated tarnished champagne-gold embroidered vertical border bands at 8% and 92% width, with restrained original geometric broken-line accents. At horizontal center, 33% down from top: a simple refined original gold embroidered symbol, a thin open circular halo intersected by a long vertical needle and a small diamond below. Rest of field mostly plain dark purple. Very narrow gold horizontal hem near bottom. No letters, words, text, real religious symbols, franchise symbols, watermark or ornament outside the textile. Diffuse even lighting, no gloss or cast shadows. For mapping onto actual modeled flowing cloth, not a finished scene.

## Mapping

Stone is projected in world-scale authoring coordinates and UV-baked to albedo,
tangent normals and roughness. The generated luminance drives fine relief;
the major joints, ribs, seal and chips are geometry. Cloth uses explicit UVs
with modeled folds and a split lower hem. Its normal and roughness maps are
baked from the generated weave. Sources are packed into gate_authoring.blend.
Generated albedo contains illustrated surface relief and is not a measured scan.
