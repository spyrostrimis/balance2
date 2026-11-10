# Vegetation candidate 01 / Tree 03

Separate native review candidate, 10 November 2026. **Not integrated or accepted.**
The playable mission retains Tree 02 and its existing ground plants. Open
`VegetationStudy.bat` for native Godot Compatibility review.

## Review controls

- **1:** southwest tree in the actual basin.
- **2:** close leaf/petiole view.
- **3:** RTS basin composition.
- **4:** isolated flowers, closed buds, rosette and dry seed grass.
- **5:** border pocket beside the existing conduit.
- **6:** isolated full tree.
- **B:** Tree 02/old plants comparison (arena and full-tree views; not view 4).
- **V:** reverse camera; arrows/right-drag pan; wheel zoom; R reset; Esc close.

The viewer uses the existing warm light setup and accepted environment assets.
It is an asset review without combatants or HUD; it does not claim final mission
composition or reference parity. The study's `Arena.vegetation_review` switch is
true; the mission default is false. Gate 02, Terrain 01, Waterworks 01, Korali,
sandstone02 and interim Leader02 remain unchanged.

## What changed

Original smaller elliptic leaves have a curved lamina, asymmetric margins and
individual petioles. Every shoot and petiole begins on the exact sampled path
used to construct its parent branch. Five irregular canopy lobes carry 1,680
canopy leaves on 120 curved shoots; lower gaps expose the branching structure.
The accepted bark source and bowed trunk/root character are retained.

Tree 02's packed-source audit verified that all 21,120 canopy triangles pointed
downward in Blender Z, with double-sided rendering concealing their front/back
orientation. Its leaf-base-to-nearest-wood distance reaches 10.8 mm (17 origins
over 10 mm). That distance alone includes embedded points; the source also
confirms that leaves followed a different curve from their twigs. These are
measured/source findings, not a claim that orientation alone caused every
reported visual defect. Tree 03 reverses the upper winding, gives every leaf a
real petiole, and shares attachment paths. Its 2,236 recorded shoot/branch/
petiole attachments have zero centerline gaps. All tested upper lamina normals
have a positive dot product with their intended local upper direction.

Flowers are rebuilt with flared corollas, five cupped petals oriented around the
blossom axis, sepals, fine stamens/anthers and closed ribbed buds. Rosettes have
fleshy sealed undersides. Three grass variants use curved tapered blades and
modeled seedheads; woody shrubs and low crevice plants populate existing border
positions and eight additional edge pockets. Central combat space remains open.
Cosmetic vegetation has no colliders and does not change registered obstacles.

## Sources and checks

Editable packed source: `art_source/vegetation/vegetation_authoring.blend`.
Reproducible recipe, exact built-in imagegen prompt and source/audit records are
in that directory. Exports and shared mapped/baked PBR are in
`assets/vegetation_study/`. All art is original project work, with no third-party
files. See `art_source/vegetation/TEXTURE_SOURCES.md`.

Full authored triangle counts: tree 117,198; tall/arching grass 6,192 each;
low grass 1,776; shrub 23,078; flowering crevice plant 8,826; rosette 2,016.
Godot imports automatic LODs. The tree includes root flowers and 1,902 total
lamina/petal shapes, not 1,902 canopy leaves.

Native Compatibility close, leaf, flower, border, RTS, isolated and reverse
views were inspected. Initial shimmer was corrected with mipmaps; missing
vertex tint use was corrected in `vegetation_art.gd`. Final windowed/import logs
are clean. `tests/test_vegetation.gd` verifies all 1,247 grid cells, identical
footprints and four tree transforms, no colliders, clear central corridor,
authored tint activation and 1,249,259 finite instanced vertices. The existing
headless battle suite passes 30 checks. Logs/captures stay ignored under
`artifacts/vegetation/`.

## Limits awaiting creator review

Foliage is static; the old whole-mesh wind shader is not applied because it would
move attachment geometry inconsistently. No wind rig, billboard LOD, authored
seasonal variants or whole-mission performance tuning is included. This is a
dense geometry candidate; broad leaf arrangement and repeated grass/shrub forms
remain visible. Small flower surfaces simplify at RTS distance; the root
rosettes remain stylized. Canopies still have some leaf intersections. Material
microdetail is generated and mip-filtered, not photogrammetry. The reference's
denser, naturally blended ground cover is not fully matched. Aesthetic acceptance
and any mission substitution belong to the creator; step 3 has not started.
