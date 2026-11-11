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

func _ready() -> void:
	get_window().title = "Balance — Debris Study 01"
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
	candidate.debris_review = true
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
	if "--capture-debris" in OS.get_cmdline_user_args(): _capture_review()

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var top := Label.new()
	top.text = "GROUND DETAILS / 01     |     Separate review candidate"
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
	for item in [["1  Ruin debris", func(): set_view(0)], ["2  Paving", func(): set_view(1)], ["3  RTS", func(): set_view(2)], ["4  Wreckage", func(): set_view(3)], ["5  Roots", func(): set_view(4)], ["6  Kit", func(): set_view(5)], ["B  Before / after", toggle_before], ["V  Reverse", toggle_reverse]]:
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
	if mode == 5: before = false # The isolated kit has no legacy counterpart.
	reverse = false
	focus = [Vector3(-12.4, .2, -16.5), Vector3(-12.9, .0, 9.8), Vector3(0, 0, -3), Vector3(23.1, .15, -1.8), Vector3(-18, .05, 8.5), Vector3(0, .1, 0)][mode]
	camera.size = [5.5, 5.6, 36.0, 4.5, 3.3, 11.0][mode]
	_refresh_visibility()
	_update_camera()
	_update_caption()

func _update_camera() -> void:
	var offset := Vector3(0, 33, 26)
	if view_mode != 2: offset = Vector3(1, 7, 5)
	if view_mode == 1: offset = Vector3(1, 8, 5)
	if view_mode == 3: offset = Vector3(-5, 7, 2)
	if view_mode == 4: offset = Vector3(1, 1.7, 3)
	if reverse: offset = Vector3(-offset.x, offset.y, -offset.z)
	camera.position = focus + offset
	camera.look_at(focus)

func _update_caption() -> void:
	caption.text = "%s / %s / %s" % ["Integrated scene before debris" if before else "Debris 01 candidate", ["Fallen carved stone at northern ruin", "Paving edge fragments and sand burial", "RTS basin - combat space preserved", "Modest maintenance wreckage at cliff foot", "Exposed roots inside existing trunk footprint", "Six original modeled pieces"][view_mode], RenderingServer.get_current_rendering_method()]

func toggle_reverse() -> void:
	reverse = not reverse
	_update_camera()

func toggle_before() -> void:
	if view_mode == 5: return
	before = not before
	if before and not is_instance_valid(baseline):
		baseline = Arena.new()
		baseline.debris_review = false
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
		get_viewport().get_texture().get_image().save_png("res://artifacts/debris/review-%d.png" % mode)
	set_view(0)
	toggle_reverse()
	await get_tree().create_timer(.5).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://artifacts/debris/reverse.png")
	toggle_before()
	set_view(0)
	await get_tree().create_timer(.5).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://artifacts/debris/baseline.png")
	get_tree().quit()

func _build_specimens() -> void:
	specimens = Node3D.new()
	add_child(specimens)
	var debris := preload("res://scripts/debris_art.gd")
	var i := 0
	for key in debris.KITS:
		debris.place(specimens, key, Vector3((i % 3 - 1) * 3.8, 0, (i / 3) * 3.1 - 1.6))
		i += 1
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(20, 20)
	ground.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("8d8777")
	mat.roughness = .95
	ground.material_override = mat
	ground.position.y = -.035
	specimens.add_child(ground)

func _refresh_visibility() -> void:
	var isolated := view_mode == 5
	candidate.visible = not before and not isolated
	if is_instance_valid(baseline): baseline.visible = before and not isolated
	specimens.visible = isolated
