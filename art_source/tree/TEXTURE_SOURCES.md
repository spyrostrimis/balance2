# Generated tree surfaces — revision 02

Two original source images generated for Balance on 9 November 2026 using the
built-in `image_gen` tool, with no input/reference images. Saved unchanged as
`bark_basecolor_source.png` and `leaf_basecolor_source.png`, and packed into
`tree_authoring_v2.blend`. These are generated project art, not a CC0 pack.
No CC0 license is asserted. Neither image is a game screenshot or a 3D asset.

## Bark — exact prompt

> Create a production-ready square seamless tileable BASE COLOR material texture for the bark of a gnarled desert shade tree in a polished stylized-realism fantasy RTS. This is a texture scan filling the whole canvas, NOT an entire tree, no branches or silhouette, no perspective. Straight-on orthographic view of weathered grey-brown bark. Rich painterly tactile detail at three scales: long irregular vertically flowing bark ribbons and chunky plates, branching narrow deep fissures, smaller peeling flakes, fine grain and rubbed edges. Vertical fibers subtly twist around occasional elongated knots, never rigid parallel stripes. Muted warm grey, desaturated walnut brown, dusty tan worn edges, occasional faint ochre deposits; rich restrained tonal variation without black holes. Mature tough bark, NOT smooth wood, NOT cut timber, NOT stone, NOT reptile scales, NOT bright orange. Flat diffuse even illumination, no cast shadows, no directional lighting, no shiny highlights, no vignette. Beautiful detailed hand-painted game texture with believable material structure, not flat low-poly colors or noisy procedural speckles. NO leaves, moss carpets, plants, insects, scenery, text, labels, frames. Seamless edges on both axes. Bark grain predominantly vertical from bottom to top. Square highest useful detail.

## Leaf — exact prompt

> Create a square BASE COLOR texture of the surface of ONE green leaf for a stylized-realism 3D fantasy RTS tree. Technical UV texture, not an illustration of a plant. The ENTIRE square is filled edge to edge with the lamina surface of one leaf: no leaf outline, NO background, no stem, no silhouette, no transparent areas. Imagine a square macro crop inside a broad leaf. One slim pale midrib runs EXACTLY vertically at x=50%, from the bottom edge to the top edge. Fine irregular branching secondary veins angle diagonally upward outward from this central midrib, with delicate tertiary veins and subtle organic mottling. The blade surface is mostly deep sage green mixed with forest jade and muted olive, with slightly warmer green near veins, gentle dusty blue-green variation and tiny sparse ochre weathering flecks. Rich readable painterly detail, soft waxy leaf texture, tasteful natural color variation, not luminous yellow-green. The midrib is narrow, not a thick stripe. Bilateral leaf structure but not perfect mirror symmetry. Flat diffuse illumination, NO cast shadows, NO directional shading, NO specular reflections, NO vignette. A finely hand-painted botanical material for an attractive game asset. NOT several leaves, NOT overlapping foliage, NOT fern fronds, NOT a photograph with depth of field, NO brown border, NO text, NO frame. Square format, highest useful detail.

Blender maps the bark along the original curved tube geometry and bakes a unique
atlas. Leaves use the generated central vein along each mesh's fold. Shallow
normal detail comes from luminance; the sources are illustrated materials, not
measured albedo/height scans. Requested flat illumination and seamless tiling
are design intentions rather than measured guarantees. Root plant color is
adapted from the same leaf source in Blender.
