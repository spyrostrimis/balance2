# Balance

Working design record, 8 November 2026. This separates the creator's direction
from temporary prototype choices. Names, stats, and mission rules remain tunable.

## Current creative priority

**9 November update:** pause feature expansion and prove the visual direction
one asset at a time. First: a Blender-authored Korali rock, reviewed in Godot
close-up and at the real gameplay camera distance. Next, only after visual
review: the tree with small flowers, then the rock formation. Previous prototype
art is not accepted as matching the concept or Warcraft III Reforged benchmark.
The creator subsequently approved the Korali improvement and requested its
replacement in the mission; that substitution is complete. The tree with small
flowers was also approved and now replaces the mission trees. The sandstone
rock formation is the next separate review candidate. These studies do not
migrate the mission's renderer. See `KORALI_STUDY.md`, `TREE_STUDY.md` and
`ROCK_STUDY.md`.

The creator found the first sandstone formation insufficient compared with
Korali. Revision 02 follows Korali's generated stone texture plus Blender
fracture-mesh and PBR bake workflow. The creator approved revision 02 and asked
to apply that same workflow to the tree. Tree revision 02 now uses generated
bark and leaf sources baked in Blender; it is the current review candidate.
The user subsequently requested all current revisions be integrated: sandstone
02 and tree 02 are now in the mission alongside Korali. Tree bark is acceptable;
leaf realism, orientation/attachment and bud/petal geometry remain deficient.
Further tree improvements are explicitly deferred. **Next: Gate, then Blue
Leader**, each in a focused asset chat using `ASSET_HANDOFF.md`.

The creator approved Gate study 01 ("Very nice") and requested its integration,
then the **woman Blue Leader**. The Gate is now in the mission at scale 0.78,
with its discovery shot reframed for the taller facade. The Blue Leader is the
next focused asset, following the concept portrait; animation and healing must
be preserved. Tree improvements remain deferred.

The creator rejected the first woman Blue Leader for its hollow/lifeless face,
toy-like armor and awkward movement. Revision 02 uses an anatomical MPFB base
and a staged face/shoulders checkpoint (`BlueLeaderFaceStudy.bat`) before the
final costume and motion work. See `BLUE_LEADER_REBUILD.md`. The mission leader
now uses the revision 02 bust on the existing animated body at the creator's request. Further appearance work is deferred; healing is unchanged.

The creator has played the first prototype and considers the gameplay adequate
as a starting point. Focus next on **visuals, aesthetics, and storyline**.
Develop the world's visual identity, environments, faction designs, characters,
and opening story before expanding mechanics. The next useful milestone is one
convincing, atmospheric mission scene with a narrative purpose.

The creator approved the first concept board and the opening story proposal.
The approved direction is ancient worlds with modern machinery, expressive
biological characters, branching iridescent Korali in rock, and beauty alongside
danger. The opening concerns a storm-damaged settlement's water system, a Red
offer of aid conditional on permanent military administration, and worked stone
beneath the deposit bearing markings associated with the Clergy.

See `ART_DIRECTION.md` and `STORY.md` for the production direction and opening
script. The concept board is an approved visual reference, not a screenshot or
a finished 3D asset. Exact faces, names, and newly drafted dialogue remain
editable. Select asset packs to serve this direction rather than define it.

The creator subsequently reviewed the animated character trio positively and
asked to continue. First Contact 0.3 now uses that assembly for both squads, with
role equipment and animation. This accepts it as a production starting point;
the provisional shared faces and lower detail do not replace the concept target.

At the creator's request, 0.4 next develops the environment: storm-damaged water
infrastructure, older aqueduct ruins, vegetation pockets, and terrain/material
variation. These support the existing opening story; they do not introduce a
working economy, repairs, or additional mission objectives.

The creator approved a short, skippable narrative presentation next. Version
0.5 adds the opening confrontation and a survivor-aware victory discovery,
with subtitles, existing-character portraits, and camera movement. Voice acting,
lip sync, and during-combat radio dialogue remain deferred.

## Agreed direction

- A mostly RTS game with RPG elements, made in Godot with stylized 3D art.
- Dune II and Command & Conquer inspire the economy and command experience;
  Warcraft III and DotA inspire leaders and abilities. Build an original universe.
- Small, valuable armies. Scarce resources. Preserving, healing, and repairing
  units should matter. Classic base destruction plus varied mission objectives.
- RTS missions alternate with some solo leader missions in labyrinths,
  tropical forests, and other atmospheric environments.
- Leaders and most troops are biological. Human and humanlike protagonists
  may coexist with other species; exact species and faction membership are open.
- Blue: freedom, self-determination, cooperation; vulnerable to bureaucracy,
  indecision, arrogance, and distance from ordinary people.
- Red: order and decisive authority; effective, ruthless, ends justify means.
- Green: opportunistic, commercially motivated, sneaky and lethal, less cohesive.
  Its internal loyalties and gameplay advantages still need development.
- Palatinate / the Clergy: mysterious religious power, always AI, always opposed
  to the player, sometimes allied with other enemies. A later nonhuman leader
  reveal is an idea the creator particularly likes, not yet a defined character.
- Blue and Red have the main campaigns. Green may have a short regional campaign
  or standalone missions. No player Clergy campaign is planned.
- **Korali** is the working name for the main scarce resource. It occurs in
  rocks and deposits rather than broad harvestable fields.
- The harvester is a robot: truck travel, humanoid extraction, truck return
  to a refinery. It is distinct from biological troops.
- Planet-specific creatures can threaten harvesters, troops, civilians, and
  possibly structures. Storms may interfere with radar or other systems.

## Orichalcum: proposal, not a second economy yet

Keep Korali as the one spendable resource. Orichalcum could later be a much rarer
ancient material associated with artifacts, story objectives, or special upgrades.
That offers a distinct narrative role without immediately adding another mining
and construction currency. Its existence and exact role are not yet confirmed.

## First playable: First Contact

One small arena, one central deposit, Blue versus Red, four troops each.
Each side has a leader, rifleman, scout, and heavy. These roles and anonymous
callsigns are prototype choices, not established characters or faction designs.
The Blue Captain has a healing pulse. The Red leader uses a stronger standard
weapon; a unique Red ability is deferred.

Temporary rules:

- Hold the radius uncontested for 40 cumulative seconds or eliminate the enemy.
- Either side can capture. Both sides present means no progress for either.
- Progress persists when leaving the ring. More troops do not accelerate it.
- No reinforcements. No harvesting or spending resources in this mission.
- Move orders prioritize relocation; attack-move fights along the route.
- Healing restores up to 45 HP within 6.5 world units, with a 16-second cooldown.
- No hidden species, lore, or final art decisions are implied by placeholder models.

## Development sequence

1. **Baseline complete:** a playable 4-versus-4 arena with selection, movement,
   combat, healing, capture, and mission outcomes.
2. **Current focus:** visual direction and storytelling. Explore environments,
   faction silhouettes, a compelling opening, and biological character designs;
   then select coherent verified-license art and replace placeholders deliberately.
3. **Economy slice:** one robotic harvester, Korali extraction, refinery return,
   repair, and a small production loop.
4. **RTS expansion:** a few buildings and unit types, base objectives, fog of war;
   decide whether power management actually serves this game.
5. **RPG slice:** one short solo leader mission using the same combat foundations.
6. **Campaign development:** progression, faction identity, wildlife, weather,
   and narrative reveals, informed by the slices above.

The quoted prior AI suggestions are references, not an approved feature checklist.
Inventory, loot, skill trees, overworld, destructible forests, and elaborate power
networks are not committed scope. Multiplayer is not part of the first prototype.
