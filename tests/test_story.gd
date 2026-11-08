extends SceneTree
## Windowed story lifecycle, input, and native renderer checks.
const Mission = preload("res://scenes/main.tscn")
var battle: Node3D
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition: failures += 1
	print("PASS: " if condition else "FAIL: ", description)

func key(code: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = code
		event.pressed = pressed
		root.push_input(event, true)
		await process_frame

func click(button: Button) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = button.get_global_rect().get_center()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		root.push_input(event, true)
		await process_frame

func advance(seconds: float) -> void:
	for frame in range(ceili(seconds * 60)): battle._process(1.0 / 60)

func capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/%s.png" % name)

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://artifacts")
	var ignore := FileAccess.open("res://artifacts/.gdignore", FileAccess.WRITE)
	ignore.close()
	battle = Mission.instantiate()
	root.add_child(battle)
	current_scene = battle
	battle.set_process(false)
	battle.set_physics_process(false)
	var saved_position: Vector3 = battle.camera.position
	var saved_zoom: float = battle.camera.size
	battle.begin_mission()
	check(battle.phase == "intro" and battle.story.active and not battle.hud.visible, "Opening owns presentation before simulation starts")
	var location: Vector3 = battle.units[4].position
	battle.step_simulation(20)
	check(battle.elapsed == 0 and battle.scores == [0.0, 0.0] and battle.units[4].position == location, "Opening does not spend battle time, capture progress, or AI movement")
	advance(2)
	await capture("story-water-intake")
	check(battle.camera.position.distance_to(saved_position) > 1 and battle.camera.size < saved_zoom, "Opening moves the camera to the water installation")
	await click(battle.story.panel.hold_button)
	var held_time: float = battle.story.line_time
	var held_camera: Vector3 = battle.camera.position
	advance(10)
	check(battle.story.held and battle.story.line_time == held_time and battle.camera.position == held_camera, "Hold freezes automatic dialogue and camera motion")
	await key(KEY_SPACE)
	check(not battle.story.held, "Space resumes the held sequence")
	await key(KEY_F)
	await key(KEY_A)
	await key(KEY_Q)
	await key(KEY_R)
	check(battle.story.active and not battle.attack_armed and battle.heal_cooldown == 0 and battle.camera.position == held_camera, "Combat and focus shortcuts do not leak into cinematics")
	await click(battle.story.panel.next_button)
	advance(1.7)
	check(battle.story.panel.current_portrait == "blue_leader" and battle.story.panel.portrait_texture.visible, "Captain dialogue displays his in-engine portrait")
	await capture("story-blue-captain")
	await key(KEY_ENTER)
	advance(2)
	check(battle.story.index == 2 and battle.story.panel.current_portrait == "red_leader", "Enter advances to the Red commander")
	await capture("story-red-commander")
	# Longest subtitle wraps inside its reserved area instead of overlapping buttons.
	var label: Label = battle.story.panel.subtitle
	check(label.get_line_count() <= 3 and label.get_rect().end.y < battle.story.panel.next_button.position.y, "Subtitle fits above the controls")
	advance(50)
	check(battle.phase == "playing" and not battle.story.active and battle.elapsed == 0, "Automatic opening completion hands over command at time zero")
	check(battle.camera.position.is_equal_approx(saved_position) and battle.camera.size == saved_zoom and battle.hud.visible, "Normal completion restores the gameplay camera and HUD")
	check(battle.units[0].selection_ring.visible and battle.arena.capture_ring.visible, "Tactical selection and objective markers return")
	# A victory with the Captain alive uses the Captain; the alternate must not.
	battle.finish(0, "The Korali deposit has been secured.")
	check(battle.story.active and battle.story.kind == "discovery" and battle.story.lines[0].speaker == "BLUE CAPTAIN", "Victory begins discovery with the living Captain")
	advance(1.7)
	await key(KEY_ENTER)
	advance(1.7)
	await capture("story-discovery")
	await click(battle.story.panel.skip_button)
	check(not battle.story.active and battle.phase == "ended" and battle.winner == 0 and battle.hud.visible, "Skipping discovery preserves the victory report")
	# Exercise the same outcome builder after a real unit death.
	battle.phase = "playing"
	battle.units[0].take_damage(1000)
	battle.finish(0, "The Korali deposit has been secured.")
	var no_dead_speaker := true
	for line in battle.story.lines:
		no_dead_speaker = no_dead_speaker and line.speaker != "BLUE CAPTAIN" and line.portrait != "blue_leader"
	check(no_dead_speaker and battle.story.lines[0].speaker == "VANGUARD", "A surviving Vanguard replaces the fallen Captain in all ending dialogue")
	advance(1.7)
	await capture("story-survivor")
	advance(30)
	check(not battle.story.active and battle.phase == "ended", "Discovery also completes automatically")
	battle.phase = "briefing"
	battle.begin_mission()
	await key(KEY_ESCAPE)
	check(battle.phase == "playing" and not battle.story.active and battle.hud.visible, "Escape skips the entire opening")
	battle.finish(1, "The basin is lost.")
	check(not battle.story.active and battle.winner == 1, "Defeat goes directly to its report without a false discovery")
	print("STORY RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
