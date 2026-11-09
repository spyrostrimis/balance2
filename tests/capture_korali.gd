extends SceneTree
var study: Node3D

func _initialize() -> void:
	call_deferred("run")

func capture(label: String) -> void:
	for frame in range(15): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/korali-" + label + ".png")

func run() -> void:
	study = load("res://scenes/korali_study.tscn").instantiate()
	root.add_child(study)
	var meshes: Array[Node] = study.study.find_children("*", "MeshInstance3D")
	assert(not meshes.is_empty(), "Imported GLB must contain a mesh")
	for mesh in meshes:
		var material: StandardMaterial3D = mesh.get_active_material(0)
		assert(material.albedo_texture != null, "Missing albedo")
		assert(material.normal_enabled and material.normal_texture != null, "Missing normal map")
		assert(material.roughness_texture != null and material.metallic_texture != null, "Missing packed surface map")
	await capture("close")
	var input := InputEventKey.new()
	input.keycode = KEY_B
	input.pressed = true
	study._unhandled_input(input)
	assert(study.previous.visible and not study.study.visible, "B must show original rock")
	await capture("before")
	study.toggle_previous()
	study.toggle_light()
	study.pivot.rotation.y = 1.4
	await capture("reverse-neutral")
	study.pivot.rotation.y = 0
	study.set_distance(1)
	await capture("rts")
	study.set_distance(2)
	assert(is_equal_approx(study.camera.size, 36.0), "Match the mission's default orthographic size")
	await capture("mission-distance")
	study.toggle_rotation()
	var rotation_before: float = study.pivot.rotation.y
	study._process(0.5)
	assert(study.pivot.rotation.y != rotation_before, "Turntable must rotate mesh")
	input.keycode = KEY_R
	study._unhandled_input(input)
	assert(not study.rotating and study.pivot.rotation == Vector3.ZERO, "Reset must stop and restore turntable")
	print("Korali: imported PBR maps, comparison shortcut, mission scale, turntable and reset checked; five native Forward+ views captured.")
	quit()
