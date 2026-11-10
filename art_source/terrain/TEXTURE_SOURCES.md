# Terrain 01 material sources

Original sources generated with the built-in imagegen tool on 10 November 2026.
These are generated project art, not third-party scans or CC0 assets.
The reference `D:/Downloads/balanced2_goal.png` was studied for composition,
palette and material relationships; its pixels are not used in the textures.

## sand_source.png — exact prompt

Use case: photorealistic-natural. Asset type: original production tiling base-color source for a 3D desert basin game ground, not a scene or concept render. Square 2048x2048 orthographic top-down edge-to-edge warm golden beige sandy earth. Fine granular quartz sand, subtle wind-combed shallow ripples in small intermittent patches, compacted dusty ochre silt between lighter drifts, scattered tiny irregular stone grit, restrained natural tonal variation. All details at ground material scale covering about four metres, no large rocks, no vegetation, no footprints. Sophisticated stylized realism with detailed natural surface. Uniform diffuse illumination, absolutely no directional cast shadows or highlights, no perspective, no vignette. Seamless tileable material edges. Overall medium-light honey buff, avoid orange saturation and avoid white. No text, labels, grid, borders, objects, interface.

## cliff_source.png — exact prompt

Use case: photorealistic-natural. Asset type: original production base color material source for mapped 3D eroded canyon sandstone, not a landscape painting. Square 2048x2048 flat orthographic close-up of an uninterrupted sandstone wall covering about six metres of strata. Broad irregular warm buff and muted terra-cotta sandstone beds with thin darker dusty brown sediment seams, subtly oblique bedding, eroded grain, tiny fissures, flaking mineral crust and softly wind-worn areas. Restrained stratification: irregular thickness, interruptions and diagonal fracture cracks; no evenly spaced stripes and no brickwork. Pale dry exposed mineral faces transition to muted cinnamon sediment. Detailed natural photographic material with sophisticated stylized realism. Even flat diffuse illumination, no shadows, highlights, perspective, objects, sky, plants, text or borders. Seamless-looking left and right edges. This supplies surface detail only; the separate 3D mesh supplies large ledges and fractures.

Paving reuses the project's original `art_source/gate/v2/aged_limestone_source.png`.
Its generation prompt is preserved in that directory's TEXTURE_SOURCES.md.
Blender maps these sources onto original geometry, bakes tangent normals and
roughness and exports portable PBR. Image-derived relief is artistic, not measured.
