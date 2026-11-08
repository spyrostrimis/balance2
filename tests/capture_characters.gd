extends SceneTree
const Studio = preload("res://scenes/character_studio.tscn")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://artifacts")
	var ignore := FileAccess.open("res://artifacts/.gdignore", FileAccess.WRITE)
	ignore.close()
	var studio := Studio.instantiate()
	root.add_child(studio)
	current_scene = studio
	studio.set_process(false)
	settle(studio, 0.6)
	await capture(studio, "character-lineup")
	studio.focus_character(0)
	await capture(studio, "blue-captain")
	studio.focus_character(2)
	await capture(studio, "red-commander")
	studio.focus_character(-1)
	studio.set_animation("Idle_Gun_Shoot")
	settle(studio, 0.6)
	await capture(studio, "character-firing")
	studio.set_animation("Walk")
	settle(studio, 0.6)
	await capture(studio, "character-walking")
	studio.set_animation("Death")
	settle(studio, 3.0)
	await capture(studio, "character-fallen")
	quit()

func settle(studio: Node, seconds: float) -> void:
	# Cross-fades are temporal: evaluate intermediate frames before capturing.
	for i in range(ceili(seconds * 60)):
		for character in studio.characters: character.advance_animation(1.0 / 60)

func capture(studio: Node, name: String) -> void:
	studio.ui.queue_redraw()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/%s.png" % name)
