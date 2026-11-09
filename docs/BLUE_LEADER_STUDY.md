# Woman Blue Leader — review candidate 01

**Rejected by the creator.** The face looked hollow and lifeless, the armor
looked like assembled toy parts, and the motion was awkward. Technical checks
below established valid playback, not acceptable art or natural movement.
Revision 02 must use a better anatomical foundation and a body-fitted rig;
see `ASSET_HANDOFF.md`. Do not integrate this candidate.

This is a separate, complete animated character study. It does not replace the
mission leader until visual acceptance. The approved concept's lower-left
portrait and Blue squad guide the palette and equipment; this candidate is a
simpler interpretation, not a claim of concept fidelity. Name and final facial
identity remain open.

## Review

Launch `BlueLeaderStudy.bat`. It opens the native Godot scene with Forward+;
the mission renderer is unchanged. The source scene is
`scenes/blue_leader_study.tscn`.

| Control | Action |
| --- | --- |
| Drag / wheel | Rotate / zoom |
| 1 / 2 / 3 | Full character / RTS inspection (18) / mission distance (36) |
| P | Portrait framing |
| Idle / Run / Aim / Fire / Fall / Interact | Preview the exported animation |
| A / Pause button | Pause/resume animation |
| Space | Turntable |
| B | Compare the current mission placeholder |
| L | Warm/neutral key light |
| R | Reset rotation and framing |
| Escape | Close the study |

The camera distances use the shared asset viewer's 18/36 orthographic sizes.
At mission distance, silhouette and faction palette are readable; facial detail
is intended for close inspection and narrative portraits.

## Construction and source

- Export: `assets/blue_leader_study/blue_leader.glb`.
- Editable packed source: `art_source/blue_leader/leader_authoring.blend`.
- Deterministic build: `art_source/blue_leader/build_leader.py`.
- Source images, exact prompts and mapping notes: `art_source/blue_leader/`.
- Runtime adapter: `scripts/blue_leader_candidate.gd`.

All visible geometry is original. It includes adult body proportions, a
continuous sculpted head with modeled nose/jaw/cheeks, inset eye surfaces,
lids and lips, swept dark hair and a three-strand braid, overlapping curved
cobalt plates, a folded ivory scarf and split coat, gloves/boots, medical
pack and wrist module, and an original compact service pistol.

The verified CC0 Quaternius 62-bone skeleton and its 24 source animation clips
are preserved. Torso, sleeves, scarf and coat use blended skin weights; armor
and equipment mostly follow their supporting bones. Hair uses Head/Chest
weights. The pistol and muzzle follow Middle1.R. Mesh weights and bone names
are exported and checked in Godot, not merely assumed compatible.

```powershell
& C:/Blender/blender.exe --background --factory-startup --python art_source/blue_leader/build_leader.py
& C:/Godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --editor --import --quit
& C:/Godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tests/test_blue_leader.gd
```

The Blender authoring file is saved with the armature in REST mode for material
editing/baking. Switch it to POSE to inspect source actions; the export uses POSE.
The build rewrites only this candidate's generated outputs. It requires Blender
and the source assets already in this repository, with no additional add-ons.

## Validation and limits

The focused Godot check inspects every exported vertex's skin slots, weight
normalization and bind indices; checks 62 bones; samples six clips at four
times; and checks that the hand-mounted muzzle moves during aiming. Native
windowed views cover front, portrait, back, running, aiming, firing, falling,
RTS and mission distances. Captures/logs stay in ignored `artifacts/blue_leader/`.

This is a review mesh, with relatively dense face/hair geometry and multiple
materials. `asset_info.json` records its actual triangle/material counts.
Production retopology, draw-call reduction and final LOD tuning are deferred
until the design is accepted. Hair and cloth are bone-skinned, not physically
simulated; contact and intersections in unreviewed poses may need refinement.
The facial expression is static: there is no facial rig, blinking or lip sync.
The generated face source retains some lighting and the mapped likeness is
provisional. Healing equipment is visual only; `Interact` is a source motion,
not an implemented healing animation. The existing mission healing is unchanged.

Before a future mission substitution, connect the adapter to the unit's -Z
facing convention and existing manual animation/muzzle contract, and verify
healing, portraits, death and renderer behavior in that integration.
