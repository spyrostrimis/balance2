extends Node3D
## Isolated material review. Does not replace the mission deposit.
const Art = preload("res://scripts/shapes.gd")
var camera: Camera3D
var pivot := Node3D.new()
var study: Node3D
var previous := Node3D.new()
var environment: Environment
var sunlight: DirectionalLight3D
var caption: Label
var distance_mode := 0
var show_previous := false
var neutral := false
var rotating := false

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("171d22"))
	add_child(pivot)
	study = preload("res://assets/korali_study/korali_study.glb").instantiate()
	# A restrained slate tint keeps the pale source texture from washing out in sun.
	for child in study.find_children("*", "MeshInstance3D"):
		var material: StandardMaterial3D = child.get_active_material(0).duplicate()
		material.albedo_color = Color(0.72, 0.75, 0.78)
		child.material_override = material
	pivot.add_child(study)
	pivot.add_child(previous)
	var old_material := ShaderMaterial.new()
	old_material.shader = preload("res://shaders/korali.gdshader")
	Art.rock(previous, Vector3(0, 0.92, 0), Vector3(2.85, 2.15, 2.3), old_material, 47)
	Art.rock(previous, Vector3(0.95, 0.35, 0.6), Vector3(1.1, 0.8, 1), old_material, 53)
	previous.visible = false
	var ground := PlaneMesh.new()
	ground.size = Vector2(200, 200)
	var ground_mat := StandardMaterial3D.new()
	ground_mat.albedo_color = Color("786b57")
	ground_mat.roughness = 0.95
	var noise := FastNoiseLite.new()
	noise.frequency = 0.06
	var texture := NoiseTexture2D.new()
	texture.width = 512
	texture.height = 512
	texture.noise = noise
	texture.as_normal_map = true
	texture.bump_strength = 0.35
	ground_mat.normal_enabled = true
	ground_mat.normal_texture = texture
	ground_mat.normal_scale = 0.3
	ground_mat.uv1_scale = Vector3(100, 100, 100)
	Art.mesh(self, ground, Vector3(0, -0.015, 0), ground_mat)
	environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("202b33")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("b1c7d6")
	environment.ambient_light_energy = 0.3
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("748caa")
	sky_mat.sky_horizon_color = Color("c6c0af")
	sky_mat.ground_bottom_color = Color("534637")
	sky.sky_material = sky_mat
	environment.sky = sky
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.ssao_enabled = true
	environment.ssao_radius = 0.35
	environment.ssao_intensity = 1.5
	var world := WorldEnvironment.new()
	world.environment = environment
	add_child(world)
	sunlight = DirectionalLight3D.new()
	sunlight.rotation_degrees = Vector3(-48, -35, 0)
	sunlight.light_color = Color("ffdfb6")
	sunlight.light_energy = 1.25
	sunlight.shadow_enabled = true
	sunlight.light_angular_distance = 2.5
	sunlight.directional_shadow_max_distance = 70
	add_child(sunlight)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.far = 250
	add_child(camera)
	camera.current = true
	_build_ui()
	set_distance(0)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 30)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(margin)
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(column)
	var title := Label.new()
	title.text = "K O R A L I   /   0 1"
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", Color("b9e2d6"))
	column.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "BLENDER → GODOT   ·   MATERIAL & FORM STUDY"
	subtitle.add_theme_font_size_override("font_size", 13)
	column.add_child(subtitle)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(spacer)
	caption = Label.new()
	caption.add_theme_font_size_override("font_size", 17)
	column.add_child(caption)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 9)
	column.add_child(row)
	for item in [["1  Close", func(): set_distance(0)], ["2  RTS inspection", func(): set_distance(1)], ["3  Mission distance", func(): set_distance(2)], ["B  Before / after", toggle_previous], ["L  Light", toggle_light], ["Space  Turntable", toggle_rotation]]:
		var button := Button.new()
		button.text = item[0]
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size.y = 38
		button.pressed.connect(item[1])
		row.add_child(button)
	var help := Label.new()
	help.text = "Drag to turn  ·  Wheel to zoom  ·  R reset  ·  Esc close    |    Actual 3D viewport; no painted backdrop or post-edited render"
	help.add_theme_font_size_override("font_size", 13)
	column.add_child(help)

func set_distance(mode: int) -> void:
	distance_mode = mode
	camera.size = [6.3, 18.0, 36.0][mode]
	var target := Vector3(0, 0.85 if mode == 0 else 0.0, 0)
	camera.position = target + (Vector3(5, 4.5, 7) if mode == 0 else Vector3(0, 33, 26))
	camera.look_at(target)
	_update_caption()

func _update_caption() -> void:
	caption.text = "%s   /   %s   /   %s" % ["Original mission rock" if show_previous else "New baked stone + embedded Korali", ["Close inspection", "RTS inspection", "Mission distance"][distance_mode], "Neutral daylight" if neutral else "Warm desert light"]

func toggle_previous() -> void:
	show_previous = not show_previous
	previous.visible = show_previous
	study.visible = not show_previous
	_update_caption()

func toggle_light() -> void:
	neutral = not neutral
	sunlight.light_color = Color.WHITE if neutral else Color("ffdfb6")
	environment.ambient_light_color = Color("c5cbd1") if neutral else Color("b1c7d6")
	_update_caption()

func toggle_rotation() -> void:
	rotating = not rotating

func _process(delta: float) -> void:
	if rotating: pivot.rotate_y(delta * 0.22)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		pivot.rotate_y(event.relative.x * 0.008)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: camera.size = maxf(4, camera.size * 0.9)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: camera.size = minf(45, camera.size / 0.9)
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1: set_distance(0)
			KEY_2: set_distance(1)
			KEY_3: set_distance(2)
			KEY_B: toggle_previous()
			KEY_L: toggle_light()
			KEY_SPACE: toggle_rotation()
			KEY_R:
				pivot.rotation = Vector3.ZERO
				rotating = false
				set_distance(0)
			KEY_ESCAPE: get_tree().quit()
