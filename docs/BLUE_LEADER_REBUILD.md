# Blue Leader revision 02 — anatomy checkpoint

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


The creator rejected revision 01: hollow/lifeless face, toy-like armor and
awkward animation. The approved reference communicates beauty, vitality,
strength, determination and confidence. Those are the target, not merely
female anatomy and blue equipment.

## Process correction

The previous analytic head lacked coherent facial topology. A projected portrait
introduced baked shadows, and skin shading on the eye surfaces weakened gaze.
Repeated swept tubes made hair/armor mechanical. Fitting the body to an old
placeholder skeleton imposed its proportions; checking finite bone transforms
was never evidence of attractive or natural motion.

The revised workflow starts with a verified-license anatomical mesh and
customizable face/body targets. Fit a rig to the resulting person. Establish
face, neck, shoulders and expression before a full costume; evaluate front,
three-quarter and profile in clay as well as materials. Outfit and continuous
motion review follow that checkpoint, with explicit ground contact, weight
shift, joint deformation and weapon-grip checks.

## What is actually available

`BlueLeaderFaceStudy.bat` opens the **static head-and-shoulders proof**, not a
finished second character. Keys 1/2/3 select front/three-quarter/profile, C
compares clay/materials, drag rotates, wheel zooms and Escape closes.

The customized head/body uses MakeHuman/MPFB core topology. Cheek, jaw, nose,
neck and brow parameters are retained in the source. Eyes have separate fitted
geometry/materials. The tied-back stock hair is provisional. Original cobalt
shoulder shells and an ivory scarf provide palette/context, but are not the
final costume design. No old placeholder animations are attached to this proof.
No new full-body animation quality or mission readiness is claimed.

The exported proof has been opened and visually checked in native Godot
Forward+, in materials and clay. Hair/brow alpha handling is explicit in its
viewer. The final windowed startup check has no script errors. This validates
the static checkpoint only; it does not establish final likeness or animation.

- `art_source/blue_leader/v2/anatomy_authoring.blend`: packed full anatomical
  foundation, editable shape keys and fitted source rig.
- `art_source/blue_leader/v2/leader_bust_authoring.blend`: packed clothed bust.
- `assets/blue_leader_study/v2/leader_bust.glb`: native review export.
- `build_foundation.py` and `build_bust.py`: reproducible construction.
- `provenance/`: preserved core license and asset-pack manifest.

## Authoring tool and license

MPFB is loaded from an isolated checkout under ignored `artifacts/tooling/`.
It was exercised with the already installed Blender 5.2.3. No purchase or
global extension install is needed from the creator. Game runtime still needs
only Godot and the export; MPFB is an authoring dependency.

MPFB version: 2.0.18; source commit:
`d0a32e57a7f915cb2f2b95410e2117648c7bbb7e`.
Official repository: https://github.com/makehumancommunity/mpfb2
Core-asset license: https://www.makehumancommunity.org/about/license.html
System pack listing:
https://static.makehumancommunity.org/assets/assetpacks/makehuman_system_assets.html

The software is GPL; its core mesh, morph targets, rigs and listed system
assets are separately CC0. Only verified core assets are used here: base mesh,
targets, default rig/weights, young_caucasian_female skin, high-poly brown eyes,
eyebrow005, eyelashes01 and ponytail01. Stock asset names identify source files,
not a final identity declaration for the character. The original project
material atlas is reused for cloth/cobalt; its exact built-in imagegen prompt
remains in `art_source/blue_leader/material_source.prompt.txt`.

```powershell
& art_source/blue_leader/v2/fetch_sources.ps1
& C:/Blender/blender.exe --background --factory-startup --python art_source/blue_leader/v2/build_foundation.py
& C:/Blender/blender.exe --background --factory-startup --python art_source/blue_leader/v2/build_bust.py
```

The system pack is SHA-256 verified by the setup script. All evaluation logs and
renders stay under ignored `artifacts/blue_leader/v2/`. Source images remain
packed in the Blender files. Derived source and export can be stored in this
repository under the core-assets license.

## Alternative considered

Character Creator 5 with Headshot 3 is a potential paid anatomical/facial
authoring route. It would not supply the final costume or acting automatically.
The official Headshot trial excludes saving/export, and Reallusion's content
terms restrict standalone raw asset redistribution, unlike this repository's
current source-art workflow. No purchase is recommended at this checkpoint.

Official references:
https://www.reallusion.com/character-creator/headshot/photo-to-3d-head.html
https://www.reallusion.com/character-creator/headshot/download.html
https://cdn-www.reallusion.com/Content/EULA/EULA.htm
