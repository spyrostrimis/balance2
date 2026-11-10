extends Node3D
## Real mission surroundings, candidate switch, close / RTS / reverse inspection.
const Arena = preload("res://scripts/arena.gd")
var candidate: Node3D
var baseline: Node3D
var camera: Camera3D
var caption: Label
var focus := Vector3(-17, .5, -10)
var view_mode := 0
var before := false
var reverse := false
var specimens: Node3D
var specimen_tree: Node3D
var old_specimen: Node3D

func _ready() -> void:
	get_window().title = "Balance — Vegetation Study 01"
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color("858178")
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color = Color("a3c0d8")
	world.environment.ambient_light_energy = .48
	world.environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-42, -36, 0)
	light.light_color = Color("ffe6c6")
	light.light_energy = .85
	light.shadow_enabled = true
	light.directional_shadow_max_distance = 110
	add_child(light)
	candidate = Arena.new()
	candidate.vegetation_review = true
	add_child(candidate)
	candidate.capture_ring.hide()
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.far = 250
	add_child(camera)
	camera.current = true
	_build_specimens()
	_build_ui()
	set_view(0)
	if "--capture-vegetation" in OS.get_cmdline_user_args(): _capture_review()

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var top := Label.new()
	top.text = "VEGETATION / 01     •     Review candidate - not integrated"
	top.position = Vector2(24, 18)
	top.add_theme_font_size_override("font_size", 24)
	layer.add_child(top)
	var panel := PanelContainer.new()
	layer.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top = -100
	var column := VBoxContainer.new()
	panel.add_child(column)
	caption = Label.new()
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(caption)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	for item in [["1  Tree", func(): set_view(0)], ["2  Leaves", func(): set_view(1)], ["3  RTS", func(): set_view(2)], ["4  Flowers", func(): set_view(3)], ["5  Border pocket", func(): set_view(4)], ["6  Specimen", func(): set_view(5)], ["B  Before / after", toggle_before], ["V  Reverse", toggle_reverse]]:
		var button := Button.new()
		button.text = item[0]
		button.custom_minimum_size.y = 36
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(item[1])
		row.add_child(button)
	var help := Label.new()
	help.text = "Arrows / right-drag pan · wheel zoom · R reset · Esc close  |  Existing mission light, terrain and obstacle footprints"
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(help)

func set_view(mode: int) -> void:
	view_mode = mode
	if mode == 3: before = false # Botanical specimen has no corresponding legacy kit.
	reverse = false
	focus = [Vector3(-18, 1.7, 8.5), Vector3(-18, 2.85, 8.5), Vector3(0, 0, -3), Vector3(0, .43, 0), Vector3(-20.4, .4, 11.6), Vector3(0, 1.8, 0)][mode]
	camera.size = [6.3, 2.4, 36.0, 2.5, 6.3, 5.7][mode]
	_refresh_visibility()
	_update_camera()
	_update_caption()

func _update_camera() -> void:
	var offset := Vector3(0, 33, 26)
	if view_mode != 2: offset = Vector3(3, 5.5, 9)
	if view_mode == 1: offset = Vector3(2, 3.5, 7)
	if view_mode == 3: offset = Vector3(1.5, 2.6, 5)
	if reverse: offset = Vector3(-offset.x, offset.y, -offset.z)
	camera.position = focus + offset
	camera.look_at(focus)

func _update_caption() -> void:
	caption.text = "%s / %s / %s" % ["Mission Tree 02 / previous plants" if before else "Vegetation 01 / Tree 03", ["Connected layered canopy", "Leaf / petiole inspection", "RTS basin - existing placements", "Modeled buds, corollas and grass seedheads", "Cliff-toe pocket", "Isolated tree specimen"][view_mode], RenderingServer.get_current_rendering_method()]

func toggle_reverse() -> void:
	reverse = not reverse
	_update_camera()

func toggle_before() -> void:
	if view_mode == 3: return
	before = not before
	if before and not is_instance_valid(baseline):
		baseline = Arena.new()
		baseline.vegetation_review = false
		add_child(baseline)
		baseline.capture_ring.hide()
	_refresh_visibility()
	_update_caption()

func _process(delta: float) -> void:
	var pan := Vector3(Input.get_axis("ui_left", "ui_right"), 0, Input.get_axis("ui_up", "ui_down"))
	if pan.length_squared() > 0:
		focus += pan * delta * camera.size * .4
		_update_camera()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
		focus += Vector3(-event.relative.x, 0, -event.relative.y) * camera.size / get_viewport().get_visible_rect().size.x
		_update_camera()
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: camera.size = maxf(.6, camera.size * .9)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: camera.size = minf(70, camera.size / .9)
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1: set_view(0)
			KEY_2: set_view(1)
			KEY_3: set_view(2)
			KEY_4: set_view(3)
			KEY_5: set_view(4)
			KEY_6: set_view(5)
			KEY_B: toggle_before()
			KEY_V: toggle_reverse()
			KEY_R: set_view(0)
			KEY_ESCAPE: get_tree().quit()

func _capture_review() -> void:
	for mode in range(6):
		set_view(mode)
		await get_tree().create_timer(.5).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://artifacts/vegetation/review-%d.png" % mode)
	set_view(0)
	toggle_reverse()
	await get_tree().create_timer(.5).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://artifacts/vegetation/reverse.png")
	toggle_before()
	set_view(0)
	await get_tree().create_timer(.5).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://artifacts/vegetation/baseline.png")
	get_tree().quit()

func _build_specimens() -> void:
	specimens = Node3D.new()
	add_child(specimens)
	var flower: Node3D = preload("res://assets/vegetation_study/crevice_flower.glb").instantiate()
	preload("res://scripts/vegetation_art.gd").prepare_materials(flower)
	specimens.add_child(flower)
	var grass: Node3D = preload("res://assets/vegetation_study/grass_tall.glb").instantiate()
	preload("res://scripts/vegetation_art.gd").prepare_materials(grass)
	grass.position = Vector3(.85, 0, -.15)
	specimens.add_child(grass)
	specimen_tree = preload("res://assets/vegetation_study/tree.glb").instantiate()
	preload("res://scripts/vegetation_art.gd").prepare_materials(specimen_tree)
	add_child(specimen_tree)
	old_specimen = preload("res://assets/tree_study/v2/desert_tree.glb").instantiate()
	add_child(old_specimen)
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(12, 12)
	ground.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("8d8777")
	mat.roughness = .95
	ground.material_override = mat
	ground.position.y = -.025
	ground.name = "SpecimenGround"
	add_child(ground)

func _refresh_visibility() -> void:
	var isolated := view_mode == 3 or view_mode == 5
	candidate.visible = not before and not isolated
	if is_instance_valid(baseline): baseline.visible = before and not isolated
	specimens.visible = view_mode == 3
	specimen_tree.visible = view_mode == 5 and not before
	old_specimen.visible = view_mode == 5 and before
	get_node("SpecimenGround").visible = isolated
