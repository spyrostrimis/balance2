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

The 0.5 dialogue portraits are rendered at runtime from the same character
assemblies in a separate 3D viewport. Remote-link graphics are original UI
geometry. No new external or generated image assets are introduced.

## Korali study (9 November 2026)

`assets/korali_study/` contains the original Blender-authored rock and baked PBR
maps. Mesh construction, fracture planes, mineral masks, UVs and baking are
reproducible with `art_source/korali/build_korali.py`. The editable `.blend`
packs the generated stone source texture. No third-party mesh or franchise art
was imported for this study.

`art_source/korali/stone_basecolor_source.png` was generated using the built-in
image generation tool specifically for this asset. It is a base-color source,
not a game screenshot, photographed material or downloaded CC0 texture. Its
exact prompt and provenance are in `art_source/korali/TEXTURE_SOURCE.md`.
No CC0 license is asserted for generated or original project art. Blender and
Godot are authoring/runtime tools, not the source of third-party art here.

See `KORALI_STUDY.md` for baked channel meanings, regeneration, and limitations.

## Tree and flowers study (9 November 2026)

`assets/tree_study/desert_tree.glb` and its baked surface maps are original
project art, built with `art_source/tree/build_tree.py` in Blender 5.2.3 LTS.
The editable source is `art_source/tree/tree_authoring.blend`. Branches, leaves,
roots, flower geometry, bark and leaf textures are all authored procedurally in
that script. No downloaded assets, franchise art or generated images are used
for this study, and no CC0 license is asserted. The GLB embeds its textures;
Godot extracts identical copies with a `desert_tree_` prefix on import.

See `TREE_STUDY.md` for the review workflow and known limitations.

Tree revision 02 is under `assets/tree_study/v2/`, built by
`art_source/tree/build_tree_v2.py`. It uses original geometry and two generated
source images: `art_source/tree/bark_basecolor_source.png` and
`art_source/tree/leaf_basecolor_source.png`, produced with the built-in image
tool. Exact prompts and provenance are in `art_source/tree/TEXTURE_SOURCES.md`.
The root rosette texture is adapted from the leaf source in Blender. Both
sources and baked maps are packed in `tree_authoring_v2.blend`. These are
generated project materials, not a third-party CC0 pack. Revision 01 and its
entirely procedural texture workflow remain intact for the mission/comparison.

## Sandstone formation study (9 November 2026)

`assets/rock_study/sandstone_formation.glb` revision 02 uses original fracture
geometry and a generated sandstone surface image, UV-baked in Blender 5.2.3 LTS
with `art_source/rocks/build_formation.py`. The editable source is
`art_source/rocks/sandstone_authoring.blend`, with the source image packed inside.
`art_source/rocks/sandstone_basecolor_source.png` was generated with the built-in
image tool. Exact prompt and provenance: `art_source/rocks/TEXTURE_SOURCE.md`.
It is generated project art, not a CC0 pack; no CC0 license is asserted.
The rejected all-procedural first version is retained as
`assets/rock_study/previous/sandstone_v1.glb` for comparison.
Godot extracts embedded GLB textures alongside the original bake outputs.
See `ROCK_STUDY.md` for the workflow and review scope.

## Sanctuary Gate study (9 November 2026)

`assets/gate_study/sanctuary_gate.glb` is original Blender-authored architecture,
with the editable source and reproducible recipe under `art_source/gate/`.
The limestone and embroidered banner source PNGs were generated using the
built-in imagegen tool. Exact prompts and mapping notes are retained in
`art_source/gate/TEXTURE_SOURCES.md`. Blender bakes portable albedo, tangent
normal and roughness maps; the GLB embeds them. No downloaded mesh, texture,
add-on or franchise artwork was used. No CC0 license is asserted for this
generated and original project art. See `GATE_STUDY.md` for scope and limits.
The creator approved the candidate; it now replaces the mission gate at scale
0.78. Revision 01 and its editable source remain intact.

Gate revision 02 (10 November) is the approved, integrated revision under
`assets/gate_study/v2/`, built by `art_source/gate/v2/build_gate.py`. The packed
Blender source includes original architectural and plant geometry, a newly
generated aged limestone material and a transparent ivy leaf source. The banner
source from revision 01 is reused. Exact built-in imagegen prompts are in
`art_source/gate/v2/TEXTURE_SOURCES.md`. No downloaded or franchise art is used;
no CC0 claim is made. The uploaded goal image is only a visual reference and is
not mapped onto the asset. See `GATE_REVISION_02.md` for review and limitations.

## Woman Blue Leader study (9 November 2026)

`assets/blue_leader_study/blue_leader.glb` is a separate review candidate. All
visible meshes are original Blender-authored project geometry, including the
woman's head, body, hair, armor, cloth, equipment and pistol. The existing
Quaternius Spacesuit 62-bone armature and 24 animation actions are reused under
the verified CC0 pack license recorded above; its original files are unchanged.
No downloaded character, donor male head or donor armor mesh is included in
the candidate. This does not relabel the original project geometry as CC0.

The material atlas and neutral facial source were generated with built-in
imagegen. Exact prompts and provenance are preserved in
`art_source/blue_leader/TEXTURE_SOURCES.md`. The reproducible build script and
packed editable `leader_authoring.blend` are in the same directory. Blender
bakes portable albedo, normal and roughness maps and embeds them in the GLB.
See `BLUE_LEADER_STUDY.md` for actual validation and limitations. Mission
integration awaits visual acceptance; the current leader remains unchanged.

## Blue Leader revision 02 anatomical foundation

Revision 01 was rejected by the creator. Revision 02 begins with a separate
head/shoulders checkpoint using MPFB 2.0.18 and MakeHuman core assets, rather
than reusing revision 01 anatomy or its old animation-fitting assumptions.
The base mesh, morph targets, fitted default rig/weights, core skin, high-poly
eyes, eyebrow005, eyelashes01 and ponytail01 are CC0 under the official split
license and system-pack manifest. Evidence is preserved under
`art_source/blue_leader/v2/provenance/`; pinned commit, source URLs, pack SHA-256,
rebuild steps and limits are in `BLUE_LEADER_REBUILD.md` and `fetch_sources.ps1`.
These third-party inputs are acknowledged explicitly; revision 02 is not
described as wholly original geometry. Its framing armor/scarf is original
project geometry and reuses the project's generated material atlas.

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

Revision 02 is now used by the mission Blue Leader via scripts/blue_leader_mission.gd, with rigid Head/Chest attachments and the existing Quaternius limbs/animations. Original source assets and the reviewed bust are unchanged; only the overlapping old torso triangles are filtered in the runtime copy. Likeness work is deferred at the creator's request.

## Terrain candidate 01 — original generated and authored art

`assets/terrain_study/` contains three original Blender canyon buttresses,
processional paving/buried courts and portable albedo/normal/roughness textures.
Sand and sandstone sources were made with built-in imagegen, not downloaded;
paving reuses the project's generated Gate 02 limestone. These are original
project art, not CC0 scans. Exact prompts, source PNGs, deterministic authoring
recipe and packed editable `.blend` are under `art_source/terrain/`. No new
third-party assets or dependencies. See `TERRAIN_STUDY.md` for provenance,
rebuilding and limits. The creator requested integration after native review;
Terrain 01 now supplies the mission ground, paving and canyon borders.

## Waterworks candidate 01 — original generated and authored art

`assets/waterworks_study/` contains original curved cistern masonry, damaged
pipe shells/connections/supports, carved aqueduct ruins and structural rubble.
The GLBs reference shared sibling PBR PNGs; preserve the folder together.
Built-in imagegen produced the aged teal metal source; limestone reuses the
project's Gate 02 generated source. No third-party files or new dependencies.
Exact prompts, deterministic Blender/export recipes and packed editable source
are under `art_source/waterworks/`. This is original project art, not CC0 scans.
See `WATERWORKS_STUDY.md`. The creator accepted this pass for interim use and
requested integration; Waterworks 01 is now the mission default.

## Vegetation candidate 01 / Tree 03 — original authored art

`assets/vegetation_study/` contains seven original GLB kits: connected tree,
three dry grasses, woody shrub, flowering crevice plant and fleshy rosette.
The GLBs use shared sibling albedo/normal/surface PNGs; preserve the folder.
Built-in imagegen supplied one original four-field botanical surface atlas;
bark reuses the project's accepted generated Tree 02 source. No third-party
files or dependencies were introduced, and no CC0 claim is made for generated art.
Exact prompt, deterministic Blender recipe, source audits and packed editable
`.blend` are in `art_source/vegetation/`. Native review and limitations are in
`VEGETATION_STUDY.md`. Vegetation 01 is accepted for interim use and integrated,
10 November 2026.

## Debris candidate 01 — original authored art

`assets/debris_study/` contains six original GLB kits with shared sibling PBR:
ruin_fall, cliff_spall, dead_bough, exposed_root, wreckage and paving_spall.
Keep the GLBs and PNGs together. `art_source/debris/` contains the deterministic
Blender recipe, packed editable `.blend`, new generated deadwood source and exact
built-in imagegen prompt in `TEXTURE_SOURCES.md`. Stone, sand and pipe sources
reuse original project art with provenance links. Generated art is not declared
CC0; no third-party files or dependencies were added. The portable 1024px tiles
carry albedo, color-derived tangent normals and roughness/metallic surface maps.
Local sand-contact meshes use accepted terrain PBR and a Compatibility shader.
Debris 01 is approved and integrated, 11 November 2026. See
`DEBRIS_STUDY.md` for controls, preservation checks and limitations.
