# Balance

A small-scale science-fiction RTS with RPG ambitions, built with Godot.
Scarce **Korali**, valuable troops, biological leaders, and a future transforming
robotic harvester form the core direction.

The current creative priority is **visual identity and storytelling**. The approved
[concept board and art direction](docs/ART_DIRECTION.md) guide the original
procedural environment studies. Read the [opening story and draft script](docs/STORY.md).

**First Contact 0.5** adds a short opening and victory discovery sequence, with
camera moves, subtitles, and portraits rendered from the game characters.
During a sequence: **Enter** advances, **Space** holds/resumes for reading, and
**Escape** skips it. The battle timer starts only after the opening finishes or
is skipped. If the Captain falls, a surviving soldier delivers the ending lines.
There is no voice acting yet.

The environment includes a breached cistern, damaged pipes, aqueduct ruins,
desert trees, wind-stirred grasses, softer stone weathering, and varied ground
tones. The wider opening view frames the sealed sanctuary. Deploy, then use the
arrow keys to explore and the wheel to inspect details. Space pauses combat;
camera movement remains available. The water station is scenery, not a repair
or harvesting system.

## Korali visual study

Double-click **`KoraliStudy.bat`** for the isolated Blender-to-Godot rock study.
It uses Forward+ while the mission retains its existing renderer. The approved
new Korali rock now replaces the mission's original deposit.
**1 / 2 / 3** select close, RTS inspection, and mission camera distance; **B**
compares the old rock; **L** changes lighting; **Space** turns the rock.
Drag to rotate, wheel to zoom, **R** reset, **Esc** close. Requires a device
supporting Godot Forward+. Blender is only needed to rebuild the asset.
No new gameplay is included.
See [source, workflow, and limitations](docs/KORALI_STUDY.md).

## Tree and flowers study

Double-click **`TreeStudy.bat`** to inspect revision 02: the branching desert
tree with generated bark and leaf surface textures, baked normal detail and
small orange-gold flowers at its roots. **B** compares the previous approved
tree revision; **1 / 2 / 3** changes camera distance. Revision 02 is now in the
mission. Foliage is static; leaf attachment/orientation and bud/petal shapes
remain unfinished and are deferred until after the next asset work.
See [source and limitations](docs/TREE_STUDY.md).

## Rock formation study

Double-click **`RockStudy.bat`** to review the next asset: a warm sandstone
formation with irregular fracture faces, textured stone and fallen slabs. The
second revision follows the Korali texture-and-bake workflow. **B** compares it
with the first sandstone attempt; **K** compares the approved Korali under the
same camera and lighting. Other controls match the earlier studies.
The second sandstone revision now replaces the four mission rock formations.
See [source and limitations](docs/ROCK_STUDY.md).

## Gate study

Double-click **`GateStudy.bat`** to review revision 02 against the uploaded goal:
aged grey stone, a lower crown, layered rounded arch, ruined side porticoes,
purple banners, broad steps and climbing ivy. **1 / 2 / 3** selects close, RTS
and mission distance; **B** compares approved revision 01; **G** previews the
candidate in mission surroundings. **L** switches light; **Space** turns it.
Drag to rotate, wheel to zoom, **R** reset, **Esc** close. The approved revision 02
now replaces the mission Gate at scale 0.78. Ivy and cloth are static; the facade
has no interactive interior. See [revision 02 source and limits](docs/GATE_REVISION_02.md).

## Character Studio

Gate revision 02 and the interim woman Blue Leader are integrated. Terrain is next.
New asset chats start from
[the current handoff](docs/ASSET_HANDOFF.md).

Double-click `CharacterStudio.bat`, or choose **Character Studio** on the mission
briefing. Inspect three animated CC0-based character studies: Blue Captain, Blue
Vanguard, and Red Commander. Drag to turn them, use the wheel to zoom, press
**1 / 2 / 3** for individual views, and **F** for the full lineup. Buttons preview
idle, walking, firing, and falling; **Space** pauses animation.

The same character assembly now powers all eight soldiers in First Contact,
with scout and heavy equipment variants. The studio remains available for close
inspection. See [the character study](docs/CHARACTER_STUDY.md) for license records
and remaining work toward the concept art.

## Play the first prototype

Open `project.godot` with **Godot 4.7.2** and press **F6** with the main scene open,
or **F5** to run the project. Click **Deploy expedition** (or press Enter).
No asset downloads, plugins, export templates, or package installs are required.

On the current Windows development machine, double-click `Play.bat`.
The launcher uses the installed Godot under `C:\Godot`; if installed elsewhere,
set the `GODOT_EXE` environment variable or launch the project from Godot.

**First Contact:** four Blue soldiers versus four Red soldiers in a desert basin.
The settlement's water system has been damaged by a storm. Blue needs the Korali
to help repair it; Red offers aid conditional on permanent military administration.
Secure the central Korali deposit for **40 cumulative uncontested seconds**, or
defeat the opposing squad. Both sides can win. The AI advances after seven seconds.
The briefing and opening pause the simulation until command passes to the player.

| Input | Action |
| --- | --- |
| Left-click / drag | Select a troop / select a group |
| Shift + select | Add units; Shift-click toggles one unit |
| Right-click ground | Move in a loose formation |
| Right-click enemy | Focus fire and pursue that enemy |
| A, then left-click | Attack-move toward a destination |
| Q / Healing pulse button | Captain heals nearby allies, including himself |
| H | Stop and hold position; fire at enemies in range |
| 1 | Select surviving Blue troops |
| Click a roster card | Select that soldier |
| F | Focus camera on selection |
| Arrows / IJKL | Pan camera |
| Mouse wheel | Zoom, including closer views of the animated soldiers |
| Space / Escape | Pause / resume; Escape first cancels armed attack-move |
| R while paused or after a result | Restart at the briefing |

Move orders prioritize moving; troops auto-fire when they stop. Use attack-move
to engage on the way. Healing restores up to 45 HP within 6.5 world units; cooldown
is 16 seconds. An unused heal does not consume its cooldown. A fallen Captain
cannot heal. There are no reinforcements.

## What exists, and what does not

Implemented: original 3D environment study with sandstone cliffs, a broken
processional road, a sealed Clergy entrance, desert plants, Korali veins in stone,
and animated biological soldiers with faction armor, leader mantles, scout
equipment, and heavy armor; running, aiming, firing, and falling animations;
story briefing, skippable opening and discovery sequences, and outcome text;
rock-aware grid paths, selection and group orders,
ranged combat, simple objective AI, healing, capture and elimination outcomes,
pause, restart, and a command sidebar.

Not yet implemented: harvesting, transformation, construction, repair of machines,
campaigns, hero progression, additional factions/species, wildlife, storms,
radar, fog of war, voice acting, lip sync, sound, multiplayer, or final art assets.
The concept image is a visual target, not a screenshot of implemented graphics. Obstacles block
movement but **do not block gunfire** in this first combat model. Unit avoidance
is lightweight steering, suitable for this eight-unit prototype.
The leaders still share a provisional source face, and all roles currently carry
the source pistol. Distinct rifles, heavy weapons, and final faces remain art work.

The mission Blue Leader now uses revision 02's head and armor on the existing animated body. Facial likeness improvements are deferred; arms, legs and animation remain provisional. `BlueLeaderFaceStudy.bat` opens the static head-and-shoulders source study,
using an anatomical MakeHuman/MPFB base. Use 1/2/3 for angles and C for clay.
The final outfit, hair and animations remain in development. See
[the revised workflow](docs/BLUE_LEADER_REBUILD.md).

`BlueLeaderStudy.bat` retains the **rejected** first woman Blue Leader candidate:
original geometry, generated/baked materials and the existing licensed animation
rig. Use P for a portrait, 1/2/3 for character/RTS/mission views, the motion
buttons for animation, A to pause, and drag/wheel to rotate/zoom. It awaits visual
redesign and is not substituted into the mission. See
[the study notes](docs/BLUE_LEADER_STUDY.md) for source, controls and limits.

See [the design record](docs/VISION.md) and [asset provenance](docs/ASSETS.md).

## Development and checks

Use the installed console executable (or `godot` if available on PATH):

```powershell
& C:\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --editor --import --quit
& C:\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/test_battle.gd
& C:\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/test_unit_visuals.gd
& C:\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/test_environment.gd
& C:\Godot\Godot_v4.7.2-stable_win64_console.exe --path . --script res://tests/visual_smoke.gd
& C:\Godot\Godot_v4.7.2-stable_win64_console.exe --path . --script res://tests/test_character_studio.gd
& C:\Godot\Godot_v4.7.2-stable_win64_console.exe --path . --script res://tests/test_story.gd
```

The tests exercise navigation around the deposit, healing boundaries and cooldown,
pause, contested/empty capture, both win conditions, AI capture, and a full skirmish.
They exit nonzero if a check fails. The windowed smoke test dispatches GUI and
battlefield input and saves native viewport captures under ignored `artifacts/`.
The visual interface also needs a windowed playtest after layout or input changes.

| File | Responsibility |
| --- | --- |
| `scripts/battle.gd` | Mission simulation, commands, AI, camera, outcomes |
| `scripts/unit.gd` | Soldier stats, movement, targeting, combat, animation states |
| `scripts/arena.gd` | Terrain, obstacles, AStarGrid2D paths |
| `scripts/scenery.gd` | Decorative cliffs, road, temple, plants, and field equipment |
| `scripts/basin_details.gd` | Raised border terrain, cistern, aqueduct, trees, and obstacle footprints |
| `scripts/hud.gd` | Briefing, command panel, roster, overlays, results |
| `scripts/mission_story.gd` | Dialogue, camera shots, opening/discovery lifecycle, survivor-aware ending |
| `scripts/story_panel.gd` | Subtitles, hold/next/skip controls, live 3D portraits |
| `scripts/shapes.gd` | Shared procedural mesh helpers |
| `scripts/character_visual.gd` | CC0 character assembly, faction materials, animation playback |
| `scripts/character_studio.gd` | Interactive lineup, close-ups, and animation review |

Navigation uses Godot's [AStarGrid2D](https://docs.godotengine.org/en/stable/classes/class_astargrid2d.html).
Original meshes are built with Godot's [SurfaceTool](https://docs.godotengine.org/en/stable/classes/class_surfacetool.html).
Character Studio includes three CC0 character models and animations by Quaternius;
their original license and provenance accompany them. No third-party game code or
additional downloads are required to run the project. No project distribution
license has been chosen yet.

## Terrain review 01

Open `TerrainStudy.bat` for the new sandy basin, buried stone courts and canyon
terrain in native Godot Compatibility. Keys **1–4** change views, **B** compares
the previous terrain, arrows/right-drag pan and the wheel zooms. Terrain 01 is
now integrated in the mission at the creator's request. It still has repeated cliff
forms and stylized burial edges; see [terrain study](docs/TERRAIN_STUDY.md).

## Waterworks review 01

Open `WaterworksStudy.bat` for the breached cistern, damaged pipes and ruined
aqueduct art in native Godot Compatibility. **1–4** select close/RTS views,
**B** compares the existing prototype, **V** reverses the angle; arrows/right-drag
pan and wheel zooms. Waterworks 01 is integrated for interim use at the creator's
request. See [waterworks study](docs/WATERWORKS_STUDY.md) for sources and limits.

## Vegetation review 01

Open `VegetationStudy.bat` for Tree 03, dry grasses, shrubs and crevice flowers
in native Godot Compatibility. **1–6** select tree/leaves/RTS/flowers/border/
specimen; **B** compares previous plants (except flower view); **V** reverses;
arrows/right-drag pan, wheel zoom, R resets, Esc closes. Vegetation 01 is integrated
for interim use. Foliage is static and still
uses dense meshes and repeated plant forms. See [vegetation study](docs/VEGETATION_STUDY.md).

## Ground details review 01

Open `DebrisStudy.bat` for the separate debris/transitions candidate in native
Godot Compatibility. **1-6**: ruin debris, paving, RTS basin, wreckage, roots,
isolated kit. **B** compares the integrated scene (except isolated kit); **V**
reverses; arrows/right-drag pan, wheel zooms, R resets and Esc closes. Includes
fallen slabs, loose stone, branches, roots, modest wreckage and shallow sand
burial. Repeated forms and approximate contact skins remain limitations.
Debris 01 is integrated in the mission. See [debris study](docs/DEBRIS_STUDY.md).

## Lighting review 01

Open `LightingStudy.bat` for the step 5 comparison in Compatibility.
B compares before/after at the same camera; L separates light-only and material
changes. 1-8 select RTS, Gate, waterworks, ground/tree, debris, Blue, Red and
Korali. H toggles the existing HUD, Tab the review overlay; arrows/right-drag
pan, wheel zooms, R resets and Esc closes. The actual mission is held at
deployment for comparison. Lighting 01 is now the normal mission default,
authorized by the creator; the review keeps the previous lighting on B.
Shadow resolution, repeated cliff shapes, paving/contact seams and interim
characters remain limitations. See [lighting study](docs/LIGHTING_STUDY.md).
