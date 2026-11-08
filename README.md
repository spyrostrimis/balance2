# Balance

A small-scale science-fiction RTS with RPG ambitions, built with Godot.
Scarce **Korali**, valuable troops, biological leaders, and a future transforming
robotic harvester form the core direction.

## Play the first prototype

Open `project.godot` with **Godot 4.7.2** and press **F6** with the main scene open,
or **F5** to run the project. Click **Deploy expedition** (or press Enter).
No asset downloads, plugins, export templates, or package installs are required.

On the current Windows development machine, double-click `Play.bat`.
The launcher uses the installed Godot under `C:\Godot`; if installed elsewhere,
set the `GODOT_EXE` environment variable or launch the project from Godot.

**First Contact:** four Blue soldiers versus four Red soldiers in a desert basin.
Secure the central Korali deposit for **40 cumulative uncontested seconds**, or
defeat the opposing squad. Both sides can win. The AI advances after seven seconds.
The briefing pauses the simulation until deployment.

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
| Mouse wheel | Zoom |
| Space / Escape | Pause / resume; Escape first cancels armed attack-move |
| R while paused or after a result | Restart at the briefing |

Move orders prioritize moving; troops auto-fire when they stop. Use attack-move
to engage on the way. Healing restores up to 45 HP within 6.5 world units; cooldown
is 16 seconds. An unused heal does not consume its cooldown. A fallen Captain
cannot heal. There are no reinforcements.

## What exists, and what does not

Implemented: original 3D placeholder arena and soldiers, rock-aware grid paths,
selection and group orders, ranged combat, simple objective AI, healing,
capture and elimination outcomes, pause, restart, and a command sidebar.

Not yet implemented: harvesting, transformation, construction, repair of machines,
campaigns, hero progression, additional factions/species, wildlife, storms,
radar, fog of war, sound, multiplayer, or final art assets. Obstacles block
movement but **do not block gunfire** in this first combat model. Unit avoidance
is lightweight steering, suitable for this eight-unit prototype.

See [the design record](docs/VISION.md) and [asset provenance](docs/ASSETS.md).

## Development and checks

Use the installed console executable (or `godot` if available on PATH):

```powershell
& C:\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --editor --import --quit
& C:\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/test_battle.gd
& C:\Godot\Godot_v4.7.2-stable_win64_console.exe --path . --script res://tests/visual_smoke.gd
```

The tests exercise navigation around the deposit, healing boundaries and cooldown,
pause, contested/empty capture, both win conditions, AI capture, and a full skirmish.
They exit nonzero if a check fails. The windowed smoke test dispatches GUI and
battlefield input and saves native viewport captures under ignored `artifacts/`.
The visual interface also needs a windowed playtest after layout or input changes.

| File | Responsibility |
| --- | --- |
| `scripts/battle.gd` | Mission simulation, commands, AI, camera, outcomes |
| `scripts/unit.gd` | Soldier stats, movement, targeting, combat, placeholder mesh |
| `scripts/arena.gd` | Terrain, obstacles, AStarGrid2D paths |
| `scripts/hud.gd` | Briefing, command panel, roster, overlays, results |
| `scripts/shapes.gd` | Shared procedural mesh helpers |

Navigation uses Godot's [AStarGrid2D](https://docs.godotengine.org/en/stable/classes/class_astargrid2d.html).
No third-party game code or assets are required. No project distribution license
has been chosen yet.
