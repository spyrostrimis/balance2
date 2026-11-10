# Gate revision 02 — uploaded goal reference

The creator requested a closer match to the Gate in `balanced2_goal.png` on
10 November 2026. This revision concentrates on that entrance: a lower, wider
composition, aged grey limestone, rounded layered arch, compact circular seal,
short central blade, carved side piers and broken horizontal lintels, smaller
purple banners, six broad worn steps, ivy, dry grass and rubble. It does not
attempt the image's entire landscape, HUD, characters or combat effects.

The creator approved revision 02 ("It's very good") and requested integration.
It now replaces revision 01 in the mission at (0, 0, -18.6), scale 0.78. The
two flanking rocks move outward/back to reveal the porticoes. The final discovery
shot is centered at height 3.0 with orthographic size 14 for the lower crown.
Dialogue, gameplay, navigation, renderer, leader, trees and HUD are unchanged.

## Review

Run `GateStudy.bat`. The native Godot window now loads revision 02.

- **1 / 2 / 3**: close, RTS inspection, mission distance.
- **B**: compare the accepted revision 01 in the same world units.
- **G** or **Mission surroundings**: preview revision 02 at (0, 0, -18.6),
  scale 0.78, inside a disposable instance of the mission arena. Press G to return.
- **L**: neutral/warm light; **Space**: turntable in isolated view.
- Drag to rotate the isolated asset; wheel to zoom; **R** reset; **Esc** close.

The context preview uses the study's lighting and renderer. It is useful for
scale and cliff overlap, not a claim that the entire mission matches the image.
The mission's two flanking rocks are now fitted outside the porticoes. The
context preview uses the integrated arena directly, with no Gate substitution.

## Authoring and provenance

Source: `art_source/gate/v2/build_gate.py`, packed `gate_authoring_v2.blend`,
`aged_limestone_source.png` and transparent `ivy_leaf_source.png`. The existing
Gate 01 banner source is reused. Both new images use the built-in imagegen tool;
the exact prompts and mapping notes are in `art_source/gate/v2/TEXTURE_SOURCES.md`.
No third-party mesh, texture or recognizable franchise art was imported.

The user's goal image is copied to ignored
`artifacts/handoff-reference/balanced2_goal.png` for local continuity. It is a
visual reference only, not mapped onto geometry or used as a painted backdrop.

```powershell
& C:\Blender\blender.exe --background --factory-startup --python art_source/gate/v2/build_gate.py
& C:\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --editor --import --quit
```

The script preserves revision 01. It constructs original fitted masonry,
curved archivolts, fluted piers and moulded capitals. Recess shading, per-block
age variation and generated stone surface detail are baked to portable 4096²
albedo, normal and roughness maps. Cloth/door maps are 1024². Ivy uses bent
alpha-cutout leaf cards on modeled stems and petioles. The glTF material's
MASK mode is explicitly preserved for stable overlap and depth. There are seven
material groups; exact current triangle count is in `asset_info.json` beside
`assets/gate_study/v2/sanctuary_gate.glb`.

The current asset is 7.99 metres high and roughly 18 metres wide before mission
scale, with 165,342 triangles across the architecture, cloth and vegetation.
Godot's import generates mesh LODs. This is a dense review asset, not a whole-map
performance benchmark.

## Verification

Godot import succeeds. Native Forward+ inspection established the initial shape
and material read; final close/context views were checked in Compatibility, the
mission renderer. The door was brought forward for RTS visibility, the crown
depth reduced, and upper vine stems trimmed to their masonry supports.
An oversized triangle in a bent decorative strip was fixed with explicit strip
faces. Baking and exporting now use the same triangulation. The final native
views show the repaired door without the diagonal artifact, and the final
runtime log contains no script errors. Captures/logs are ignored under
`artifacts/gate-v2/`. No gameplay code changed, so the battle suite was not rerun.

## Limits

This is still a static facade with a sealed door, no usable interior or collision.
Ivy and fabric do not animate. The ivy is decorative climbing foliage for this
Gate; it does not change or repair the deferred desert-tree foliage. Most fine
relief is normal-mapped, and generated albedo is not a physically measured scan.
Surrounding prototype cliffs and terrain have substantially less material detail
than the uploaded goal. The final aesthetic judgment remains with the creator.
