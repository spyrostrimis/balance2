extends Node3D
## Revision 02 foundation review: intentionally static, not a second full unit.
const Bust = preload("res://assets/blue_leader_study/v2/leader_bust.glb")
var bust: Node3D
var camera: Camera3D
var clay := false
var turning := false
var surfaces: Array[MeshInstance3D] = []
var clay_material := StandardMaterial3D.new()

func _ready() -> void:
	DisplayServer.window_set_title("Balance — Blue Leader / anatomy revision 02")
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("242a30")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("d6d8d9")
	env.ambient_light_energy = 0.5
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = env
	add_child(world)
	_light(Vector3(-25, -35, 0), Color("ffe9ce"), 0.85)
	_light(Vector3(-10, 145, 0), Color("b9d1eb"), 0.45)
	bust = Bust.instantiate()
	add_child(bust)
	bust.rotation.y = 0.40
	for mesh in bust.find_children("*", "MeshInstance3D", true, false):
		surfaces.append(mesh)
		if "Hair" in str(mesh.name) or "Eyebrows" in str(mesh.name) or "Eyelashes" in str(mesh.name):
			for slot in range(mesh.mesh.get_surface_count()):
				var material: StandardMaterial3D = mesh.get_active_material(slot).duplicate()
				material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
				material.alpha_scissor_threshold = 0.35
				material.alpha_antialiasing_mode = BaseMaterial3D.ALPHA_ANTIALIASING_ALPHA_TO_COVERAGE
				material.alpha_antialiasing_edge = 0.2
				material.cull_mode = BaseMaterial3D.CULL_DISABLED
				if "Hair" in str(mesh.name):
					material.albedo_color = Color(0.25, 0.22, 0.20)
					material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
					material.alpha_scissor_threshold = 0.25
				mesh.set_surface_override_material(slot, material)
	clay_material.albedo_color = Color("b6b0a3")
	clay_material.roughness = 0.85
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 0.78
	add_child(camera)
	camera.position = Vector3(0, 1.42, 3)
	camera.look_at(Vector3(0, 1.41, 0))
	_ui()
	if "--capture-face" in OS.get_cmdline_user_args(): _capture.call_deferred()

func _light(rotation: Vector3, color: Color, energy: float) -> void:
	var light := DirectionalLight3D.new()
	light.rotation_degrees = rotation
	light.light_color = color
	light.light_energy = energy
	add_child(light)

func _ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var top := VBoxContainer.new()
	top.position = Vector2(28, 22)
	layer.add_child(top)
	for text in ["BLUE LEADER  /  ANATOMY 02", "A new foundation · Face and presence review"]:
		var label := Label.new()
		label.text = text
		label.add_theme_font_size_override("font_size", 22 if top.get_child_count() == 0 else 15)
		top.add_child(label)
	var bottom := VBoxContainer.new()
	bottom.position = Vector2(28, get_viewport().get_visible_rect().size.y - 110)
	layer.add_child(bottom)
	var row := HBoxContainer.new()
	bottom.add_child(row)
	for item in [["1  Front", 0.0], ["2  Three-quarter", 0.55], ["3  Profile", 1.45]]:
		var button := Button.new()
		button.text = item[0]
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(func(): bust.rotation.y = item[1])
		row.add_child(button)
	var clay_button := Button.new()
	clay_button.text = "C  Clay / materials"
	clay_button.pressed.connect(_toggle_clay)
	row.add_child(clay_button)
	var label := Label.new()
	label.text = "Drag to rotate · Wheel to zoom · Esc close\nStatic head-and-shoulders proof. Final hair, outfit and motion remain in development."
	label.add_theme_font_size_override("font_size", 14)
	bottom.add_child(label)

func _toggle_clay() -> void:
	clay = not clay
	for mesh in surfaces:
		# Preserve alpha hair/brows so clay mode does not turn cards into slabs.
		if "Hair" in str(mesh.name) or "Eyebrows" in str(mesh.name) or "Eyelashes" in str(mesh.name): continue
		mesh.material_override = clay_material if clay else null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		bust.rotate_y(event.relative.x * 0.008)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: camera.size = maxf(0.4, camera.size * 0.9)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: camera.size = minf(1.2, camera.size / 0.9)
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: bust.rotation.y = 0
			KEY_2: bust.rotation.y = 0.55
			KEY_3: bust.rotation.y = 1.45
			KEY_C: _toggle_clay()
			KEY_ESCAPE: get_tree().quit()

func _capture() -> void:
	for mode in ["native_face", "native_clay"]:
		await get_tree().create_timer(0.5).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://artifacts/blue_leader/v2/" + mode + ".png")
		_toggle_clay()
	get_tree().quit()
