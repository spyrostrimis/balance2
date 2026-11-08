extends SceneTree
## Native viewport captures at camera positions reachable during play.
const Mission = preload("res://scenes/main.tscn")
var battle: Node3D

func _initialize() -> void:
	call_deferred("run")

func capture(name: String) -> void:
	battle._update_camera()
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
	for frame in range(20): battle.step_simulation(1.0 / 60)
	battle.notification_timer = 0
	await capture("basin-environment")
	battle.camera.size = 14
	battle.camera_focus = Vector3(-13, 0, -8.5)
	await capture("basin-water-station")
	battle.camera.size = 24
	battle.camera_focus = Vector3(3.7, 0, -10)
	await capture("basin-sanctuary")
	quit()
