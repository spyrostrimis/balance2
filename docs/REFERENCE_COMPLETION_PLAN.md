# Reference completion plan — agreed 10 November 2026

The creator asked what remains after the Gate and terrain/canyon, ordered by
impact on the whole uploaded reference image, then agreed: "Record the plan,
open a new session and start with the first step."

Reference: `D:/Downloads/balanced2_goal.png`; local continuity copy:
`artifacts/handoff-reference/balanced2_goal.png`. Study it with the image viewer.
Gate 02 and Terrain 01 are approved for use and integrated. Terrain integration
was pushed as `4418c6c`; Gate integration as `1b37be3`.

Latest decision: Vegetation 01 / Tree 03 is accepted for interim use and
integrated. The creator explicitly defers **step 3: Characters and animation**.
**Step 4: Ground-level debris and transitions is approved and integrated,
11 November 2026. Step 5: Lighting and material cohesion is also integrated
following the creator's explicit request to finish the work and add it to the game.**
Open `LightingStudy.bat` and read `LIGHTING_HANDOFF.md` / `LIGHTING_STUDY.md`.
This supersedes earlier sequencing; preserve the interim characters.

## Agreed order of visual impact

1. **Waterworks and ruined stone structures — integrated for interim use.**
   Replace the prototype cistern, pipes, aqueduct supports and architectural
   remnants. Model broken masonry, damaged connections and convincing wear,
   bringing these assets up to the Gate's material/detail standard. See
   `WATERWORKS_HANDOFF.md` for the concrete starting task.
2. **Trees and ground vegetation — integrated for interim use.** Tree 03,
   rebuilt flowers and ground-cover kits are in the mission. See
   `VEGETATION_STUDY.md` for the accepted interim state and remaining limits.
3. **Characters and animation — explicitly deferred for now.** Finish the woman Blue Leader's likeness and
   full-body outfit, then the Blue/Red roster's silhouettes, gear and movement.
   Existing leader remains an interim composite. Consult the recorded likeness
   feedback when this step begins; do not resume character work during step 1.
4. **Ground-level debris and transitions — integrated.** Deliberate fallen slabs, loose stone,
   dead branches, roots and wreckage around ruins/cliff feet; refine paving
   damage and sand burial. Keep central combat space readable and reachable.
5. **Lighting and material cohesion — integrated.** Unify warm sand, pale worked stone and
   cooler shade through light, ambient fill, shadow and material tuning. Stay
   with the existing renderer; no renderer migration is implied.
6. **Combat effects and unit presentation.** Improve muzzle flashes, projectile
   trails, impacts, healing, selection indicators and overhead bars for clarity
   and energy. Preserve current gameplay unless separately authorized.
7. **Final HUD and composition polish.** Review the existing framed HUD,
   portraits, icons, spacing and minimap at playing resolutions. This is a
   finishing pass, not a new HUD redesign. Finish with cliff variation and
   whole-scene composition checks.

## Scope and workflow

Proceed one focused pass at a time, using original generated material sources,
deliberate Blender geometry, portable mapped/baked PBR and native Godot close/RTS
inspection. Retain exact prompts, packed editable sources and reproducible
recipes. Generated pictures alone are not deliverables. Maintain the small
runnable mission, navigation footprints, deployment/resource placements and
existing story behavior. Bring new assets to visual review before substituting
them into the mission, following the accepted study/integration workflow.

The reference's large stone guardian is **not** authorized by this plan. Adding
an enemy requires a separate character/gameplay decision. Its exact labels,
names, counters and UI text are not automatic requirements either. No economy,
campaign, multiplayer, new mechanics or additional dependency follows from this
art plan. Acceptance for integration does not claim exact reference parity.

Pre-existing HUD work, settings, exports and texture import modifications remain
uncommitted; preserve them and stage only each focused pass's own changes.
