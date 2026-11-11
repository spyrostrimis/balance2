extends Node3D
## Frozen actual mission, with exact camera-preserving light/material comparison.
const Profile = preload("res://scripts/lighting_profile.gd")
const FOCI := [Vector3(0, 0, -3), Vector3(0, 2.7, -18.6), Vector3(-16.2, .7, -10), Vector3(-10, .3, 7), Vector3(22.7, .3, -1.8), Vector3(-13, .9, 0), Vector3(13, .9, 0), Vector3(0, .6, 0)]
const SIZES := [36.0, 16.0, 9.0, 11.0, 5.0, 7.0, 7.0, 7.0]
const NAMES := ["Mission / RTS", "Gate and canyon", "Waterworks / metal", "Sand, paving and tree", "Debris / wood and metal", "Blue squad", "Red squad", "Korali"]
var battle: Node3D
var profile: RefCounted
var camera: Camera3D
var focus := Vector3.ZERO
var view_mode := 0
var caption: Label
var review_panel: PanelContainer
var hud_visible := true
var full_candidate := true

func _ready() -> void:
	get_window().title = "Balance — Lighting & Material Study 01"
	battle = preload("res://scenes/main.tscn").instantiate()
	add_child(battle)
	# Real mission construction and deployments; no simulation during comparison.
	battle.start_battle()
	battle.set_physics_process(false)
	battle.set_process(false)
	battle.set_process_unhandled_input(false)
	battle.set_process_input(false)
	battle.hud.set_process_input(false)
	battle.hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for control in battle.hud.find_children("*", "Control", true, false):
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	camera = battle.camera
	camera.current = true
	var world: WorldEnvironment
	var sun: DirectionalLight3D
	for child in battle.get_children():
		if child is WorldEnvironment: world = child
		if child is DirectionalLight3D: sun = child
	profile = Profile.new(battle.arena, world, sun)
	profile.set_mode(2)
	_build_ui()
	set_view(0)
	if "--capture-lighting" in OS.get_cmdline_user_args(): _capture_review()

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	var panel := PanelContainer.new()
	review_panel = panel
	panel.position = Vector2(235, 60)
	layer.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	caption = Label.new()
	caption.add_theme_font_size_override("font_size", 18)
	column.add_child(caption)
	var row := HBoxContainer.new()
	column.add_child(row)
	for item in [["B  Before / after", toggle_before], ["L  Light only / full", toggle_materials], ["H  HUD", toggle_hud], ["R  RTS", func(): set_view(0)]]:
		var button := Button.new()
		button.text = item[0]
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(item[1])
		row.add_child(button)
	var help := Label.new()
	help.text = "1 RTS · 2 Gate · 3 Water · 4 Ground · 5 Debris · 6 Blue · 7 Red · 8 Korali\nArrows / right-drag pan · wheel zoom · Tab controls · Esc close | Simulation held"
	help.add_theme_font_size_override("font_size", 14)
	column.add_child(help)

func set_view(value: int) -> void:
	view_mode = clampi(value, 0, FOCI.size() - 1)
	focus = FOCI[view_mode]
	camera.size = SIZES[view_mode]
	hud_visible = view_mode == 0
	battle.hud.visible = hud_visible
	_update_camera()
	_update_caption()

func _update_camera() -> void:
	var offset := Vector3(0, 33, 26)
	if view_mode == 1: offset = Vector3(1, 17, 27)
	if view_mode in [4, 5, 6, 7]: offset = Vector3(2, 8, 10)
	camera.position = focus + offset
	camera.look_at(focus)
	battle.hud.queue_redraw()

func _update_caption() -> void:
	caption.text = "LIGHTING 01 — %s | %s" % [["BEFORE: integrated mission", "AFTER: light only", "AFTER: light + materials"][profile.mode], NAMES[view_mode]]

func toggle_before() -> void:
	profile.set_mode((2 if full_candidate else 1) if profile.mode == 0 else 0)
	_update_caption()

func toggle_materials() -> void:
	full_candidate = not full_candidate
	profile.set_mode(2 if full_candidate else 1)
	_update_caption()

func toggle_hud() -> void:
	hud_visible = not hud_visible
	battle.hud.visible = hud_visible
	battle.hud.queue_redraw()

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
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: camera.size = maxf(3, camera.size * .9)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: camera.size = minf(60, camera.size / .9)
		battle.hud.queue_redraw()
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_8: set_view(event.keycode - KEY_1)
		match event.keycode:
			KEY_B: toggle_before()
			KEY_L: toggle_materials()
			KEY_H: toggle_hud()
			KEY_TAB: review_panel.visible = not review_panel.visible
			KEY_R: set_view(0)
			KEY_ESCAPE: get_tree().quit()

func _capture_review() -> void:
	DirAccess.make_dir_recursive_absolute("res://artifacts/lighting")
	review_panel.hide()
	for view in range(FOCI.size()):
		set_view(view)
		for setting in [0, 2]:
			profile.set_mode(setting)
			_update_caption()
			await get_tree().create_timer(.3).timeout
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("res://artifacts/lighting/view-%d-%s.png" % [view, "before" if setting == 0 else "after"])
	get_tree().quit()
