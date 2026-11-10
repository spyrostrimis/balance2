# Gate revision 02 — 10 November 2026

Target: the Gate in the user-provided `D:/Downloads/balanced2_goal.png`, also
preserved locally in ignored `artifacts/handoff-reference/balanced2_goal.png`.
The image is a visual reference, not a runtime texture or proof of provenance
for any depicted external assets. Original geometry and newly generated surface
sources recreate its proportions/material character without copying its pixels.

The following two sources were generated with the built-in imagegen tool.
They are original generated project art, not CC0 or scanned materials.
The banner source from Gate 01 is reused; its exact prompt remains one level up.

## aged_limestone_source.png — exact prompt

Use case: stylized-concept. Asset type: production base-color texture source for an original 3D weathered sanctuary gate, not a finished render. Square 2048x2048 flat orthographic edge-to-edge continuous worked limestone surface, richly aged grey-beige limestone with desaturated olive-grey mineral staining, tiny lichen flecks, pits, worn chisel marks, fine hairline fissures, broad mottled light taupe patches, darker weathering in thin fissures, a little muted warm sand dust. The stone should look centuries old but not crumbling mud. Sophisticated stylized realism, fine photographic surface detail with calm broad variation. Overall medium-light greige, substantially less cream/yellow than clean ivory. Uniform diffuse illumination, no directional shadows, no highlights, no perspective. No brick pattern, no large geometric seams, no architecture, no text, no ornament, no border. A seamless-looking single material swatch suitable for box projection and baking onto separately modeled carved pillars and arches.

## ivy_leaf_source.png — exact prompt

Use case: photorealistic-natural. Asset type: one botanical texture cutout for an original 3D climbing vine on ancient stone ruins. A SINGLE healthy small mature ivy leaf, five gently pointed lobes, rich muted olive forest green with natural lighter branching veins and fine surface texture, a few subtle dusty and yellowed edge spots. Straight-on orthographic view of the upper face of the leaf, flat but naturally shaped, the blade centered, its tip pointing straight up. Blade occupies 85% width and 80% height, short thin petiole at bottom center ending at 94% of image height; no other stems or leaves. Even diffuse illumination, no cast shadow, no strong highlight, no depth of field. Square 1024x1024. Genuine transparent background around the entire isolated leaf and petiole, no white matte, no border, no text, no labels. Detailed realistic organic leaf suitable for UV mapping onto gently curved leaf cards, not a logo or illustration.

Stone is box-projected and UV-baked to portable albedo, tangent normal and
roughness. Ambient occlusion adds restrained recess shading to the color bake.
Cloth uses explicit UVs. Ivy uses curved, alpha-clipped cards with petioles
attached to actual branching stems; the generated transparent PNG supplies its
surface and silhouette. Fine image-derived relief is not a measured scan.
