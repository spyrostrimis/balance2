# Ground details 01 — 10 November 2026

Separate review candidate for step 4. **Not accepted or integrated.** Launch
`DebrisStudy.bat` for actual Godot Compatibility views in the existing basin.
The mission keeps its current dressing (`Arena.debris_review = false`).

## Review controls

- **1**: carved fallen lintel in the northern ruin pocket.
- **2**: thin court-edge fragments and feathered sand burial.
- **3**: RTS basin at the mission's camera size 36.
- **4**: collapsed maintenance pallet and torn cover at the east cliff foot.
- **5**: short exposed roots under an existing tree.
- **6**: isolated six-piece kit, for inspecting geometry without occlusion.
- **B**: before/after at the same camera and light (unavailable in isolated kit).
- **V**: reverse angle. Arrows/right-drag pan; wheel zooms; R resets; Esc closes.

The viewer retains the mission light values and integrated Gate02, Terrain01,
Waterworks01, Vegetation01/Tree03, Korali and sandstone02. It omits units/HUD like
the earlier environment studies. This pass does not tune global lighting,
foliage, character appearance or mechanics. Step 5 remains subsequent work.

## What changed

Six deliberately modeled original kits provide a broken lintel with interrupted
mouldings, loose bedding wedges, a forked dead bough with split tips, short root
ridges, a collapsed maintenance pallet with torn metal cover, and thin paving
fragments. There are 24 placed kits and 28 local sand-contact meshes. Sand skins
use the accepted world-space terrain sources, feathered boundaries and shallow
height profiles; they are not colliders or simulated sand.

Large pieces sit outside the navigation rectangle; roots remain inside existing
trunk footprints. Court chips are less than 3 cm high. Road/court sand skins top
out at about 5.2 cm above world zero and leave the central radius 6 clear. The
candidate omits the old random tiny pebble scatter, preserving its RNG calls.
It does not stack new rubble around the accepted rock formations or cistern.

Audit before authoring: sandstone02 already has a fallen foreground slab,
detached block and chips; terrain cliffs include talus and the courts already
have broken perimeters/sand shading; Gate02 has broken porticoes and steps;
Waterworks01 includes fallen coping, breach chips, broken pier masonry and flush
spalls; Tree03 has radial roots. Those accepted assets remain unchanged. New
pieces fill selected border gaps; the root additions are short secondary ridges,
not a second complete root system. `scenery.gd` retains its baseline equipment.

## Source and rebuild

- `art_source/debris/build_debris.py`: deterministic Blender geometry and bake.
- `art_source/debris/debris_authoring.blend`: packed editable components, source
  images and portable PBR, arranged in named collections at 5 m intervals.
- `art_source/debris/TEXTURE_SOURCES.md`: exact built-in imagegen wood prompt and
  provenance links to reused original limestone, cliff, sand and pipe sources.
- `assets/debris_study/`: six GLBs and shared sibling PBR PNGs; keep together.
- `scripts/debris_art.gd`: selected placements and local contact geometry.
- `shaders/debris_sand.gdshader`: Compatibility material for feathered contacts.

```powershell
& C:/Blender/blender.exe --background --factory-startup --python art_source/debris/build_debris.py
& C:/Godot/Godot_v4.7.2-stable_win64_console.exe --headless --editor --path . --import
```

The builder reuses the repository's `art_source/waterworks/share_pbr.py` exporter
helper, with no additional dependency. Texture tiles bake in Blender at 1024
square; the original new wood image is 1254 square. Normal relief derives from
source color. Meshes are triangulated before GLB export, wood UVs follow branch
length, stone uses dominant-face mapping, and mipmaps are enabled for RTS views.
The six unique kits total 10,176 triangles before Godot LODs. Authoring sources
are excluded from Godot by the existing `art_source/.gdignore`.

## Validation and limits

`tests/test_debris.gd` checks 1,247 navigation cells, the exact registered
footprints, accepted asset transforms, unchanged floor vertices, no collision
objects, all 24 placements and 29,409 imported/contact vertices. Raised geometry
must lie beyond a .15 m navigation margin or inside an existing footprint; the
central radius 6 stays clear. `tests/test_battle.gd` passes all 30 checks.
Native Compatibility close, RTS, isolated-kit, reverse and before views were
inspected. Final logs contain no script/shader errors. Captures and logs remain
ignored in `artifacts/debris/`.

This is a restrained first detail pass, not reference parity. Repeated kit
silhouettes can be recognized, especially the three lintels and two pallets.
Carving and fracture forms remain stylized; wood split ends have no separate
end-grain atlas. Contact skins approximate burial and do not conform to every
stone face; close low angles can reveal small intersections or seams. Thin
chips and roots are intentionally subtle at RTS scale. Existing large paving
cells, cliffs and all deferred foliage/character issues remain unchanged. No
dynamic debris, destruction, wind or new interaction was introduced. Aesthetic
acceptance and mission integration belong to the creator.
