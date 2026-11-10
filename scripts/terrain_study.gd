extends Node3D
## Native terrain review, using the mission's Compatibility lighting and placements.
const Arena = preload("res://scripts/arena.gd")
var candidate: Node3D
var baseline: Node3D
var camera: Camera3D
var caption: Label
var focus := Vector3(0, 0, -3)
var view_mode := 0
var before := false

func _ready() -> void:
	get_window().title = "Balance — Terrain Study 01"
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
	candidate.terrain_review = true
	add_child(candidate)
	candidate.capture_ring.hide()
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.far = 250
	add_child(camera)
	camera.current = true
	_build_ui()
	set_view(0)
	if "--capture-terrain" in OS.get_cmdline_user_args(): _capture_review()

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var top := Label.new()
	top.text = "TERRAIN / 01     •     Native review candidate"
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
	for item in [["1  Basin / RTS", func(): set_view(0)], ["2  Cliff & Gate", func(): set_view(1)], ["3  Ground close", func(): set_view(2)], ["4  Overview", func(): set_view(3)], ["B  Before / after", toggle_before]]:
		var button := Button.new()
		button.text = item[0]
		button.custom_minimum_size.y = 36
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(item[1])
		row.add_child(button)
	var help := Label.new()
	help.text = "Arrows / right-drag pan · wheel zoom · R reset · Esc close  |  Cosmetic terrain; existing navigation and Gate retained"
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(help)

func set_view(mode: int) -> void:
	view_mode = mode
	focus = [Vector3(0, 0, -3), Vector3(8, 3, -19), Vector3(-7, 0, 5), Vector3(0, 0, -2)][mode]
	camera.size = [36.0, 22.0, 13.0, 56.0][mode]
	_update_camera()
	_update_caption()

func _update_camera() -> void:
	var offset := Vector3(0, 33, 26)
	if view_mode == 1: offset = Vector3(4, 18, 27)
	if view_mode == 2: offset = Vector3(4, 14, 12)
	camera.position = focus + offset
	camera.look_at(focus)

func _update_caption() -> void:
	caption.text = "%s  /  %s  /  Mission light · %s" % ["Baseline terrain" if before else "Terrain candidate 01", ["RTS basin", "Canyon and sanctuary", "Sand and buried stone", "Whole basin"][view_mode], RenderingServer.get_current_rendering_method()]

func toggle_before() -> void:
	before = not before
	if before and not is_instance_valid(baseline):
		baseline = Arena.new()
		add_child(baseline)
		baseline.capture_ring.hide()
	if is_instance_valid(baseline): baseline.visible = before
	candidate.visible = not before
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
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: camera.size = maxf(6, camera.size * .9)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: camera.size = minf(70, camera.size / .9)
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1: set_view(0)
			KEY_2: set_view(1)
			KEY_3: set_view(2)
			KEY_4: set_view(3)
			KEY_B: toggle_before()
			KEY_R: set_view(0)
			KEY_ESCAPE: get_tree().quit()

func _capture_review() -> void:
	for mode in range(4):
		set_view(mode)
		await get_tree().create_timer(.5).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://artifacts/terrain/review-%d.png" % mode)
	toggle_before()
	set_view(0)
	await get_tree().create_timer(.5).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://artifacts/terrain/baseline.png")
	get_tree().quit()
