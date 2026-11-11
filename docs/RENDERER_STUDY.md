# Renderer study — Compatibility vs Forward+ (11 November 2026)

Decision record. The creator chose the migration on 11 November 2026; the
mission now runs on Forward+ with this profile as Lighting 02. At the time of
the study the mission shipped on Godot's Compatibility renderer. The reference image's depth comes largely from contact occlusion,
soft shadows and short-range bounce, none of which Compatibility can do; every
cohesion pass so far has hand-built approximations (baked AO, contact skins,
sand drifts). This study shows what the same mission looks like under Forward+
with a screen-space profile, so the creator can decide whether to migrate.

## Review

Double-click `RendererStudy.bat` (Forward+). It loads the actual mission with
Lighting 01 and Gate cohesion 01, held at deployment.

- **B**: plain Forward+ (mission values as-is) / Forward+ profile.
- **1–8**: RTS, Gate, steps, left flank, waterworks, ground/paving/tree, Blue
  squad, Korali. **H** HUD, **Tab** panel, arrows/right-drag pan, wheel zoom,
  **R** RTS, **Esc** close.
- The Compatibility baseline is the normal game (`Play.bat`), or the same scene
  launched with `--rendering-method gl_compatibility`.

`--capture-renderer` writes matched captures to ignored `artifacts/renderer/`;
`renderer_sheet.jpg` there is a three-column comparison.

## Findings

- **Forward+ renders the Lighting 01 values about 25% darker** and flatter than
  Compatibility (mean luminance 132 vs 173 on the Gate view). The two renderers
  light differently; a migration needs its own exposure pass. The profile
  re-exposes (sun ×1.55, ambient ×1.70, contrast 1.10) to match the shipped
  mission's means within a few percent.
- **The profile adds what the hand-built passes approximate:** SSAO in step
  joints, under the arch and lintels and at every stone/sand contact; soft
  penumbrae on long shadows (tree and cliff shadows no longer razor-edged);
  SSIL for faint warm bounce under the Gate; a restrained glow on survey lamps
  and Korali only.
- **No shader or script errors** under Forward+. All existing materials, the
  Compatibility-targeted contact/sand shaders included, render correctly.
- **Cost:** Forward+ needs Vulkan-capable hardware; the mission's eight-unit
  scene is light, and the studies already run on this machine. No measurement of
  low-end devices was made.

## Recommendation

If the target remains the reference's look, migrate the mission to Forward+ and
make this profile part of Lighting 02, then stop building per-asset occlusion
workarounds. If broad hardware reach matters more, stay on Compatibility and
continue the hand-built approach. This is the creator's call; nothing in the
mission changed.

## Limitations

- SSAO/SSIL are screen-space: they fade at screen edges and under the HUD.
- The profile values were tuned by eye and by matching mean luminance, not by a
  full lighting pass; sky/ambient colour and shadow atlas sizes would need
  revisiting in a real migration.
- No SDFGI or volumetric fog was tried; both are poor fits for a fixed
  orthographic RTS camera.
