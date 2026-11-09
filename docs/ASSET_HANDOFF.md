# Asset chat handoff — 9 November 2026

Read this first in a new asset chat, then `VISION.md`, `ART_DIRECTION.md`, and
the relevant asset study. Update this handoff at the end of each asset's work.

## Current request and sequence

The user requested all completed new art be put in the game, then moving on.
Korali, sandstone revision 02, tree revision 02 and Gate study 01 are now integrated.
**Next: the woman Blue Leader.** The user approved the Gate ("Very nice") and
asked to add it to the game, then continue the woman Blue Leader in this or a
new chat at our discretion. A focused new character chat is authorized to begin.
Work one asset at a time. Tree foliage/flower improvements are explicitly deferred; do not resume
them while working on the Gate or Leader.

**Leader candidate 01 is now authored as a separate review asset.** Open
`BlueLeaderStudy.bat`; read `BLUE_LEADER_STUDY.md` before continuing. The user
has not accepted its appearance or authorized its substitution into the mission.
The next step is visual feedback on this candidate, not another asset.
All visible geometry is original; only the verified CC0 62-bone skeleton and
24 actions are reused. Exact built-in imagegen prompts, two source images,
packed authoring `.blend` and rebuild script are under `art_source/blue_leader/`.
The GLB and PBR maps are under `assets/blue_leader_study/`.

The candidate includes a modeled woman head with projected generated facial
detail, swept dark hair/braid, curved cobalt armor, folded ivory scarf/split
coat, original pistol and medical equipment. It is visibly simpler than the
approved concept and must not be described as concept parity. No facial rig,
blink/lip sync, cloth/hair simulation or healing animation has been added.
It is a dense review mesh; optimize only after design acceptance.
The source rig's 62 bones, all exported skin weights and six clips across 24
poses are checked by `tests/test_blue_leader.gd`. The native review provides
portrait, full-body, RTS/mission distance and motion buttons. Existing mission
code, healing, scenery and accepted integrations remain unchanged.

The user authorized opening a new Gate chat with this handoff and beginning
work. Do not ask them to re-explain the project or repeat approval to start.
Create a separate review asset first, as with previous studies. A finished
review candidate is not automatically approval to substitute future assets.

## What this game is

Balance is a small-scale Godot RTS with occasional solo-hero RPG missions:
Dune II/C&C gameplay inspiration, stylized-realism art aspiration like Warcraft
III Reforged. Original universe and designs, not franchise assets. Biological
leaders and troops; a transforming robotic harvester is a future concept.
Scarce Korali resource. Blue: freedom/self-determination but fallible;
Red: authoritarian order; Green: opportunists; purple Clergy: mysterious enemy.
Current playable: four Blue vs four Red contesting one deposit. Gameplay is
adequate for now; prioritize art, aesthetics and story, not new mechanics.
Full agreed lore, provisional names and deferred features are in `VISION.md`
and `STORY.md`. Do not treat earlier AI proposals as approved requirements.

## What worked — required quality reference

The user strongly approved Korali and sandstone **revision 02**. Their workflow:
1. Generate a detailed material source image with built-in image generation.
   Read the imagegen skill when using it. This is a real asset texture, not a
   concept painting presented as a finished game screenshot.
2. Author original geometry in Blender with meaningful silhouettes, planes,
   chipped edges, and enough shape detail for the gameplay camera.
3. Map the texture deliberately and bake portable albedo/normal/surface maps.
4. Export GLB, inspect actual Godot views close and at RTS distance; iterate.
5. Keep editable source, reproducible build script and exact texture prompts.

The first sandstone's stacked rings, stripes and procedural noise were rejected.
Do not fall back to generic primitive geometry plus noise or claim adding more
geometry alone solves art quality. Generated texture detail cannot fix bad
anatomy, leaf attachment, silhouette or animation. Do not overpromise parity
with the concept; visual acceptance belongs to the user.

Successful source recipes:
- `art_source/korali/build_korali.py`, `TEXTURE_SOURCE.md` and packed `.blend`.
- `art_source/rocks/build_formation.py`, `TEXTURE_SOURCE.md` and packed `.blend`.
- `art_source/tree/build_tree_v2.py`, `TEXTURE_SOURCES.md`, `tree_authoring_v2.blend`.
Generated textures are original project art; do not label them CC0. Downloaded
assets need verified licenses recorded in `ASSETS.md`. Existing characters are
from the recorded Quaternius CC0 pack; they are placeholders for final design.

## Current integrations and deferred tree feedback

- `scripts/arena.gd`: Korali at center, four sandstone GLB formations at the
  old obstacle positions; existing navigation footprints preserved.
- `scripts/basin_details.gd`: four `assets/tree_study/v2/desert_tree.glb` trees,
  same placements and scale/rotation rules. Flowers are part of each GLB.
- `scripts/scenery.gd`: redundant old pebble rings around the four formations
  removed; their nearby plants preserved. Distant cliffs remain prototypes.
- Tree bark is accepted as okay. Leaves are still too artificial, some appear
  upside down or floating/unattached. The user suspects orientation errors;
  this is recorded feedback, not a verified diagnosis. Later inspect stems,
  attachment endpoints, winding/normals, growth direction and canopy layering.
- Buds and petals remain unsatisfactory. Revision 02 preserved their geometry;
  recoloring and leaf texturing were not a flower redesign. Later do real
  botanical bud/petal shape work. User explicitly says postpone it now.

## Gate — approved and integrated

Gate study 01 is built as a separate Blender-to-Godot review asset. Launch
`GateStudy.bat`; source, controls and limits are in `GATE_STUDY.md`. The export
is `assets/gate_study/sanctuary_gate.glb`; editable packed authoring source,
rebuild script and exact built-in imagegen prompts are under `art_source/gate/`.
It uses generated limestone and embroidered purple cloth sources, mapped/baked
PBR, original swept stone ribs, nested pointed arches, a circular seal, tall
split crown, steps and draped banners. The top masonry follows the curved
silhouette after a first native-view correction. No downloaded art was used.

The user approved it and explicitly requested integration. `_build_temple`
now instantiates the GLB at (0, 0, -18.6), scale 0.78: about 9.6 metres high,
13.1 wide, with the lowest step beyond the walkable z = -14 edge. Two side
rocks overlap the outer wing ends. The final discovery shot is centered at
height 4.2, size 15; dialogue, gameplay, navigation and renderer are unchanged.
The old geometry remains in `_build_temple_previous` for the viewer only.
A brief native mission check passed in Compatibility with no script errors.
The viewer shows the candidate at full authored size, not its mission scale.
Banners are static;
interior exploration, opening animation and collision are not part of the asset.
Tree work remains deferred. Do not begin the Blue Leader in parallel.

The reference is the tall, ancient sanctuary entrance embedded in warm desert
rock in `assets/concepts/first-contact-v1.png`, especially the lower-right panel
and upper battlefield background. Read that image with the image viewer.
Look for its strong vertical silhouette, layered stone ribs/arch, recessed
dark door, carved circular emblem, worn pale stone, steps, purple banners and
restrained violet interior light. These are visual references; no new gate
interaction, dungeon, building economy or story mechanics are requested.

Do not redo the Gate or earlier integrations. Surrounding distant cliffs remain
prototype art and are not the next task. No engine migration was requested.

## Blue Leader — following asset, not parallel work

The user explicitly requested a **woman** Blue Leader. The concept's lower-left
portrait and Blue squad are the visual reference:
biological woman, dark hair, expressive face, cobalt armor, weathered ivory
cloth, muted bronze details, practical weapon/medical equipment. Current
model proportions, face, materials and equipment are provisional. Preserve
character animation and existing healing/gameplay when later integrating.
Relevant files: `scripts/character_visual.gd`, `scripts/unit.gd`,
`scripts/character_studio.gd`, `docs/CHARACTER_STUDY.md`, `docs/ART_DIRECTION.md`.
Character work requires modeling/rigging/animation decisions beyond texture
generation; be candid about limits and prove one character first.

Rig inspection: `character_visual.gd` assembles the CC0 Spacesuit body/limbs,
Adventurer male placeholder head and SWAT pistol on a shared 62-bone skeleton.
All imported originals stay unchanged. Runtime mantle/equipment attach to Chest.
Current clips include Idle_Gun, running/aim/fire and Death; the animation player
advances manually. Muzzle location derives from the pistol's Middle1.R bind.
Create a separately reviewable woman character with credible face/anatomy/hair,
armor, ivory cloth and practical equipment, preserving an animation-compatible
route. A texture-painted male head or new face pasted on the old low-detail body
does not meet the requested concept direction. Review actual geometry/animation,
not just a generated character illustration. Integrate the future character only
after visual acceptance, as with previous asset studies.

## User reference images

The concept is tracked at `assets/concepts/first-contact-v1.png`. User-supplied
current-game screenshots are copied locally for continuity, without adding
playtest artifacts to Git:
- `artifacts/handoff-reference/gate-before.png`
- `artifacts/handoff-reference/leader-distant.png`
- `artifacts/handoff-reference/leader-front.png`
- `artifacts/handoff-reference/leader-back.png`
- `artifacts/handoff-reference/tree-leaf-attachment-feedback.png`
These files are on the shared local workspace, not guaranteed on another host.
The user's original concept also exists at
`D:/Downloads/ChatGPT Image Nov 8, 2026, 11_23_56 PM.png`.

## Tools, workspace and working preferences

- Repo `D:/Games/Balance2`, GitHub `spyrostrimis/balance2`, branch main.
- Godot `C:/Godot/Godot_v4.7.2-stable_win64_console.exe` and GUI sibling.
- Blender `C:/Blender/blender.exe` (5.2.3 LTS).
- Studies launch with CLI `--rendering-method forward_plus`; mission project
  settings are not migrated. Shared viewer: `scripts/korali_study.gd`.
- Art sources are in `art_source/` with `.gdignore`; exports under `assets/`.
  Keep caches/builds/logs/review captures under ignored locations.
- Prior workflow commits and pushes completed cohesive changes, and launches
  a review window. Do not stage unrelated local modifications: `project.godot`,
  `export_presets.cfg`, and existing Korali/tree texture `.import` changes.
- User dislikes redundant confirmations and lengthy testing/screenshot rituals
  for straightforward approved substitutions. Their explicit request for the
  Korali swap was: "No tests, no screenshots ... Just replace one with the other."
  Apply that preference to equivalent simple swaps; new art still needs actual
  visual inspection to establish that it renders and looks coherent.
- Keep chat updates concise. Avoid generating many concepts instead of making
  a real asset. Preserve source provenance and report actual limitations.
