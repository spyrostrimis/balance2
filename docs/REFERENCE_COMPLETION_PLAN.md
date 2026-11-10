# Reference completion plan — agreed 10 November 2026

The creator asked what remains after the Gate and terrain/canyon, ordered by
impact on the whole uploaded reference image, then agreed: "Record the plan,
open a new session and start with the first step."

Reference: `D:/Downloads/balanced2_goal.png`; local continuity copy:
`artifacts/handoff-reference/balanced2_goal.png`. Study it with the image viewer.
Gate 02 and Terrain 01 are approved for use and integrated. Terrain integration
was pushed as `4418c6c`; Gate integration as `1b37be3`.

Latest decision: the creator accepted Waterworks 01 for interim use ("It will do
for now"), requested integration, then a new chat to start step 2. Waterworks is
now the mission default. **Next: trees and ground vegetation**, with the recorded
leaf/flower feedback reopened for this step. Read `VEGETATION_HANDOFF.md`.

## Agreed order of visual impact

1. **Waterworks and ruined stone structures — integrated for interim use.**
   Replace the prototype cistern, pipes, aqueduct supports and architectural
   remnants. Model broken masonry, damaged connections and convincing wear,
   bringing these assets up to the Gate's material/detail standard. See
   `WATERWORKS_HANDOFF.md` for the concrete starting task.
2. **Trees and ground vegetation — separate candidate ready for review.** Open
   `VegetationStudy.bat`; read `VEGETATION_STUDY.md`. Mission integration awaits
   the creator's acceptance. Improve leaf shapes/attachment, canopy
   density and flower geometry; add varied dry grasses, shrubs and crevice plants.
   Resolve the recorded foliage/flower feedback when this step begins. It is
   now part of the agreed sequence, but do not work on it during step 1.
3. **Characters and animation.** Finish the woman Blue Leader's likeness and
   full-body outfit, then the Blue/Red roster's silhouettes, gear and movement.
   Existing leader remains an interim composite. Consult the recorded likeness
   feedback when this step begins; do not resume character work during step 1.
4. **Ground-level debris and transitions.** Deliberate fallen slabs, loose stone,
   dead branches, roots and wreckage around ruins/cliff feet; refine paving
   damage and sand burial. Keep central combat space readable and reachable.
5. **Lighting and material cohesion.** Unify warm sand, pale worked stone and
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
