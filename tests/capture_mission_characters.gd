extends SceneTree
## Native renderer captures at actual mission positions and reachable zoom levels.
const Mission = preload("res://scenes/main.tscn")
var battle: Node3D

func _initialize() -> void:
	call_deferred("run")

func capture(name: String) -> void:
	battle.hud.queue_redraw()
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
	battle.start_battle()
	for frame in range(30): battle.step_simulation(1.0 / 60)
	await capture("animated-mission-overview")
	battle.camera.size = 14
	battle.focus_squad()
	await capture("animated-blue-squad")
	battle.camera_focus = Vector3(15.15, 0, 0)
	battle._update_camera()
	await capture("animated-red-squad")
	battle.camera.size = 20
	battle.camera_focus = Vector3(3.08, 0, 0)
	battle._update_camera()
	battle.command_move(Vector3(-2.8, 0, 0), true)
	for frame in range(650):
		battle.step_simulation(1.0 / 60)
		if frame % 60 == 0: await process_frame
	await capture("animated-first-contact")
	quit()
