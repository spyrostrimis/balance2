extends SceneTree
## Windowed integration check. Saves native viewport captures to ignored artifacts/.
## Run with Godot --path . --script res://tests/visual_smoke.gd (not --headless).
const Mission = preload("res://scenes/main.tscn")
var battle: Node3D
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	print("PASS: " if condition else "FAIL: ", description)
	if not condition: failures += 1

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	root.push_input(event, true)
	await process_frame
	event = InputEventKey.new()
	event.physical_keycode = code
	event.pressed = false
	root.push_input(event, true)
	await process_frame

func click(point: Vector2, button: MouseButton) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = button
	event.pressed = true
	root.push_input(event, true)
	await process_frame
	event = InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = button
	root.push_input(event, true)
	await process_frame

func capture(filename: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/" + filename + ".png")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://artifacts")
	var ignore := FileAccess.open("res://artifacts/.gdignore", FileAccess.WRITE)
	ignore.close()
	battle = Mission.instantiate()
	root.add_child(battle)
	current_scene = battle
	battle.set_physics_process(false)
	await process_frame
	await capture("briefing")
	# Real GUI event dispatch, rather than directly invoking button callbacks.
	var deploy: Button = battle.hud.buttons.primary
	await click(deploy.get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	check(battle.phase == "playing", "Deploy button starts mission through GUI input")
	await click(battle.hud.card_rects[1].get_center(), MOUSE_BUTTON_LEFT)
	check(battle.selected.size() == 1 and battle.selected[0] == battle.units[1], "Roster card selects the intended soldier")
	await key(KEY_1)
	check(battle.selected.size() == 4, "Squad hotkey selects all four")
	await key(KEY_A)
	check(battle.attack_armed, "Attack-move hotkey arms command")
	var point: Vector2 = battle.camera.unproject_position(Vector3(-3, 0, 0))
	await click(point, MOUSE_BUTTON_LEFT)
	check(not battle.attack_armed and battle.units[0].order == "advance", "Attack-move click issues battlefield order")
	for frame in range(600):
		battle.step_simulation(1.0 / 60)
		if frame % 60 == 0: await process_frame
	await capture("battlefield")
	await key(KEY_SPACE)
	check(battle.phase == "paused", "Space pauses through input dispatch")
	await capture("paused")
	await key(KEY_SPACE)
	check(battle.phase == "playing", "Space resumes through input dispatch")
	# Pick the visible troop using a world-space projection.
	point = battle.camera.unproject_position(battle.units[1].position + Vector3.UP * 0.9)
	await click(point, MOUSE_BUTTON_LEFT)
	check(battle.selected.size() == 1 and battle.selected[0] == battle.units[1], "Battlefield click selects a soldier")
	point = battle.camera.unproject_position(Vector3(-9, 0, 0))
	await click(point, MOUSE_BUTTON_RIGHT)
	check(battle.units[1].order == "move", "Right-click ground issues move")
	await key(KEY_H)
	check(battle.units[1].order == "guard", "Hold hotkey stops movement")
	point = battle.camera.unproject_position(battle.units[4].position + Vector3.UP * 0.9)
	await click(point, MOUSE_BUTTON_RIGHT)
	check(battle.units[1].order == "attack" and battle.units[1].target == battle.units[4], "Right-click enemy issues focus fire")
	# Drag a screen-space rectangle around the entire Blue squad.
	var selection_box := Rect2(battle.camera.unproject_position(battle.units[0].position + Vector3.UP * 0.7), Vector2.ZERO)
	for ally in battle.living(0):
		selection_box = selection_box.expand(battle.camera.unproject_position(ally.position + Vector3.UP * 0.7))
	selection_box = selection_box.grow(25)
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = selection_box.position
	root.push_input(press, true)
	var motion := InputEventMouseMotion.new()
	motion.position = selection_box.end
	root.push_input(motion, true)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.position = selection_box.end
	root.push_input(release, true)
	await process_frame
	check(battle.selected.size() == 4, "Drag selection includes all enclosed friendly troops")
	battle.units[0].health -= 30
	await click(battle.hud.buttons.heal.get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	check(battle.units[0].health == battle.units[0].max_health and battle.heal_cooldown > 0, "Healing button restores health and starts cooldown")
	for enemy in battle.living(1): enemy.take_damage(1000)
	battle.step_simulation(0.02)
	await capture("victory")
	await click(battle.hud.buttons.primary.get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	await process_frame
	check(current_scene.phase == "briefing" and current_scene.living(0).size() == 4 and current_scene.scores[0] == 0, "Replay creates a fresh mission at the briefing")
	print("VISUAL INPUT RESULT: ", failures, " failures")
	quit(1 if failures else 0)
