# Working on Balance

- Read `docs/VISION.md` before changing game direction. Distinguish agreed
  design from proposed features and temporary prototype mechanics.
- This is a Godot 4.7 GDScript project. Keep a runnable small mission at all times.
- Use original placeholders or verified-license assets; update `docs/ASSETS.md`
  whenever introducing third-party files. Do not import recognizable franchise art.
- Keep generated `.godot` caches, logs, builds, and playtest artifacts out of Git.
- For gameplay changes, run `tests/test_battle.gd` with headless Godot and check
  the logs for script errors. For visual/input changes, also run a windowed check.
- Keep the README controls and known limitations accurate.
- Prefer small cohesive changes. Do not add economy, campaigns, multiplayer,
  or dependencies merely because the long-term vision mentions them.
