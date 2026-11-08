# Asset provenance

The current build uses original procedural geometric meshes and materials in
`scripts/shapes.gd`, `scripts/arena.gd`, `scripts/scenery.gd`,
`scripts/basin_details.gd`, and the equipment
additions in `scripts/character_visual.gd`.
Original shaders in `shaders/` provide sand, stratified stone, Korali seams,
water ripples, wind-stirred foliage, and subtly moving cloth. The cistern,
aqueduct, desert trees, and border terrain are original procedural geometry;
no additional downloaded assets were introduced for the 0.4 environment pass.
Gameplay character meshes and animations come from the
verified CC0 pack below. No franchise assets are included.
Text uses Godot's bundled fallback font. No local proprietary fonts are copied.

These are environment and character studies, not finished stylized-realism art.
There is no sound or music yet.

## Generated concept reference

`assets/concepts/first-contact-v1.png` is the original concept board generated
with the built-in image generation tool in this project conversation and approved
by the creator. The full prompt is retained beside it. It is used in the art
direction document, not as a 3D gameplay asset or a screenshot of the build.
It is not a third-party CC0 pack, and no CC0 license is asserted for it.

The preference for future external art is free CC0 stylized 3D packs with a
consistent visual language. Before importing any pack, record:

| Pack / author | Original source URL | License / evidence | Imported files | Changes |
| --- | --- | --- | --- | --- |
| Ultimate Modular Men / Quaternius | https://quaternius.com/packs/ultimatemodularcharacters.html | Pack page + original `License.txt`: CC0 1.0; hashes in `PROVENANCE.json` | `assets/third_party/quaternius/modular_men/{Spacesuit,Swat,Adventurer}.gltf` | Original files unchanged; runtime mesh assembly, recoloring, and equipment additions in Character Studio and First Contact |

The external character models are used by Character Studio and all eight
soldiers in First Contact. See `CHARACTER_STUDY.md` for the integration and
remaining art gaps.

Do not assume “free” means CC0. Retain the license provided with each pack.
If a suitable pack has another license, discuss that choice before adoption.
The repository's own code and original art have no distribution license selected
yet; a public repository does not automatically license reuse.
