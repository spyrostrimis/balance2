# Character study 01

This is a playable art review room, separate from First Contact's battle roster.
It replaces abstract body-part previews with actual skinned character meshes and
authored animations. It is an intermediate asset direction, not the final fidelity
of the approved concept board.

## Open and inspect

Use `CharacterStudio.bat`, or choose **Character Studio** on the mission briefing.
In Godot, open `scenes/character_studio.tscn` and press F6.

| Control | Action |
| --- | --- |
| Left-button drag | Turn the characters |
| Mouse wheel | Zoom |
| 1 / 2 / 3 | Isolate Captain / Vanguard / Commander |
| F | Restore the full lineup |
| Idle / Walk / Fire / Fall | Preview the authored animation |
| Space / Pause | Pause or resume character animation |
| Warm light | Compare a warmer light with the studio setup |
| Return to mission / Esc | Open First Contact's briefing |

## The three studies

| Study | Assembly | Design changes |
| --- | --- | --- |
| Blue Captain | Spacesuit body and limbs + Adventurer head + SWAT weapon | Cobalt plates, bronze trim, ivory mantle and medical harness; visible human face |
| Blue Vanguard | SWAT character | Blue field uniform, charcoal protection, enclosed helmet; lighter silhouette than the leaders |
| Red Commander | Spacesuit body and limbs + Adventurer head + SWAT weapon | Crimson plates, copper trim, dark mantle, broader proportions and angular shoulder armor |

Materials are overridden per instance. Imported animations drive the shared
skeleton. The leaders' face and weapon meshes bind to that skeleton directly;
they are not separate independently animated figures. Mantles and equipment are
original additions attached to the chest bone.

## Source and license

The [Ultimate Modular Men Pack](https://quaternius.com/packs/ultimatemodularcharacters.html)
is by **Quaternius**. Its pack page identifies it as CC0, and the original
`License.txt` downloaded alongside these exact models also specifies CC0 1.0.
That pack-specific evidence is retained with the files. No inference is made that
all of the creator's other releases use the same license.

Three self-contained glTF source models total about 10.8 MB. They remain
unmodified on disk. `assets/third_party/quaternius/modular_men/PROVENANCE.json`
records the official pack URL, direct file URLs, sizes, hashes, date, and runtime
changes. No paid source tier, additional application, or account was needed.

## What this review can decide

- Whether adult proportions and this degree of low-poly stylization work as a
  production starting point, or whether we need more detailed character assets.
- Whether the Blue palette and medical equipment communicate the leader's role.
- Whether Red's broader armor creates enough visual distinction.
- Whether the regular soldier should retain an enclosed helmet or show a face.

## Still open

The leaders currently share a source face with different hair/skin colors. These
are sample male heads, not a commitment to protagonists' faces, genders, species,
or identities. Different heads, hairstyles, and custom sculpting are needed for
distinct final characters. The source weapon is a pistol; final rifles and the
Red leader's signature weapon are later art work. The approved reference calls
for richer materials and more expressive character detail than these models.

The battle retains its existing procedural soldiers while this trio is reviewed.
After the visual direction is chosen, the reusable assembly can feed the mission
roster and animation states without rewriting the combat simulation.
