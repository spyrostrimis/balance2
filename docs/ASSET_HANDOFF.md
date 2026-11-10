# Asset chat handoff — 9 November 2026

## Latest decision — integrated interim leader (9 November 2026)

The creator explicitly requested keeping revision 02 and adding her to the game,
while deferring all further appearance changes. This is acceptance for interim
use, not approval of the likeness or final art quality.

Deferred feedback, compared with the generated mission Leader reference:
- Candidate still feels generic and is not the intended woman.
- Reference face is more angular, with less fullness in face and neck.
- Reference eyebrows are thicker and the nose more pointed.
- Reference ears differ.
- Eye color differs; candidate eyes have an unwanted brown/red appearance.
  The desired exact eye color has not been specified; consult the reference.

Integration uses the unchanged revision 02 bust, attached by separate head and
chest bone attachments to the existing mission skeleton. The old male head and
overlapping central chest/collar are removed. Existing arms, legs, weapon,
animations, mantle and medical equipment remain. This is an interim composite,
not a newly authored full-body character or an animation redesign. Head/hair and
armor are rigid attachments; cloth, hair and facial animation remain absent.
The shared character factory also updates story portraits and Character Studio.
Do not resume facial/costume refinement until requested. Revision 01 remains rejected.


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

**Leader candidate 01 was rejected by the creator.** The user described the
face as hollow-cheeked and zombie-like, the armor as Lego-like, and the
animations as awkward. They want the reference woman's beauty, vitality,
determination, confidence and strength. Do not call v1 accepted or merely
awaiting review. Do not integrate it. They explicitly requested a process
review and a substantially better attempt, and are open to installing a tool
if it would materially improve the result.

The audit found inappropriate analytic face topology, projected portrait
shadows and eyes sharing the skin shader, repetitive tubular hair/armor, and
proportions forced onto the old placeholder rig. Valid weights/finite bone
transforms did not establish animation quality. Keep the export/viewer tooling,
but retire those geometry and rig-fitting assumptions.

Revision 02 is testing an anatomical MakeHuman/MPFB foundation before outfit
construction. MPFB v2.0.18 at commit
`d0a32e57a7f915cb2f2b95410e2117648c7bbb7e` and its CC0 core system assets are
available in ignored `artifacts/tooling/`. The add-on runs from that isolated
checkout with Blender 5.2.3; no global install or purchase is required from
the user. `art_source/blue_leader/v2/build_foundation.py` and `build_bust.py`
produce the current static anatomy/presence checkpoint. Open
`BlueLeaderFaceStudy.bat`; use 1/2/3 for angles and C for clay. Read
`BLUE_LEADER_REBUILD.md` for source setup, licenses and limits. Packed editable
anatomy and bust source files live beside the scripts; the review GLB is in
`assets/blue_leader_study/v2/`. Renders/logs stay in `artifacts/blue_leader/v2/`.
This is a head/shoulders proof, not a full animated unit. Final hair, outfit and retargeted motion are deferred; interim integration is authorized above.

Historical candidate 01: Open
`BlueLeaderStudy.bat`; read `BLUE_LEADER_STUDY.md` before continuing. The user
rejected its appearance and has not authorized its substitution into the mission.
The next step is the redesigned leader, not another asset.
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

## Latest Gate request — 10 November 2026

The creator returned to the Gate and requested a closer match to the Gate in
`D:/Downloads/balanced2_goal.png`. A local reference copy is preserved under
`artifacts/handoff-reference/balanced2_goal.png`. This explicitly supersedes the
earlier "do not redo the Gate" instruction for this focused revision only.
Leader appearance, tree foliage and unrelated HUD changes remain outside scope.

Revision 02 is at `assets/gate_study/v2/sanctuary_gate.glb`; editable Blender
source, rebuild script, generated aged limestone and ivy sources, and exact
prompts are in `art_source/gate/v2/`. It has a compact crown, rounded layered
arch, grey weathered stone, fluted piers, broken side porticoes, small purple
banners, broad steps and attached climbing ivy. `GateStudy.bat` now reviews it;
B compares accepted revision 01 and G previews it in mission surroundings at
the existing placement/scale. See `GATE_REVISION_02.md` for controls and limits.
The creator approved revision 02 ("It's very good") and requested its integration.
It now replaces revision 01 at the same position and scale 0.78. The two flanking
rocks move to x = +/-9.4, z = -19.5 to reveal the side porticoes. The discovery
shot targets height 3.0 at size 14. Navigation, dialogue and gameplay are unchanged.
Revision 01 remains available with B in the viewer. The creator explicitly
requested **terrain next, in a new chat**. Read `TERRAIN_HANDOFF.md`; it supersedes
earlier next-asset sequencing. Do not redo the Gate, leader or tree work.

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

## Terrain candidate 01 — 10 November 2026

The requested terrain chat has produced a native review candidate. Launch
`TerrainStudy.bat`; see `TERRAIN_STUDY.md` and the updated `TERRAIN_HANDOFF.md`.
Original generated sand/cliff sources, packed Blender geometry and baked PBR are
in `art_source/terrain/` and `assets/terrain_study/`. The candidate covers ground,
buried courts, processional paving, talus and canyon borders; existing accepted
assets and mission footprints remain. Compatibility review offers close/RTS/
overview and B baseline comparison. The mission still uses baseline terrain;
visual acceptance and integration are pending. No aesthetic parity is claimed.
Repeated cliff forms and some hard shelf shadows/UV seams remain limitations.
Thirty battle checks and all 1,247 navigation-cell comparisons pass; no new
colliders, flat walkable floor, raised landforms outside the grid, clean native
review logs. The creator's existing HUD work/settings/import changes remain
uncommitted and were preserved; only this task's doc additions were staged.
