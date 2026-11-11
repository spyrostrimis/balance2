extends Node3D
## Renderer comparison: the actual mission held at deployment. B toggles the
## shared Lighting 02 screen-space profile (SSAO, SSIL, soft sun, light glow,
## re-exposure) that the mission now applies on Forward+. Launched with
## --rendering-method gl_compatibility it shows the pre-migration mission.
const FOCI := [Vector3(0, 0, -3), Vector3(0, 2.7, -18.6), Vector3(0, .5, -15.2), Vector3(-8.8, 1.2, -17.2), Vector3(-16.2, .7, -10), Vector3(-10, .3, 7), Vector3(-13, .9, 0), Vector3(0, .6, 0)]
const SIZES := [36.0, 16.0, 7.0, 7.5, 9.0, 11.0, 7.0, 7.0]
const OFFSETS := [Vector3(0, 33, 26), Vector3(1, 17, 27), Vector3(2, 8, 10), Vector3(3, 8, 10), Vector3(2, 8, 10), Vector3(0, 33, 26), Vector3(2, 8, 10), Vector3(2, 8, 10)]
const NAMES := ["Mission / RTS", "Gate (mission angle)", "Steps and base", "Left flank", "Waterworks", "Sand, paving and tree", "Blue squad", "Korali"]
var battle: Node3D
var camera: Camera3D
var world: WorldEnvironment
var sun: DirectionalLight3D
var focus := Vector3.ZERO
var view_mode := 0
var caption: Label
var review_panel: PanelContainer
var effects := true
var renderer := ""

func _ready() -> void:
	renderer = RenderingServer.get_current_rendering_method()
	get_window().title = "Balance — Renderer Study (%s)" % renderer
	battle = preload("res://scenes/main.tscn").instantiate()
	add_child(battle)
	battle.start_battle()
	battle.set_physics_process(false)
	battle.set_process(false)
	battle.set_process_unhandled_input(false)
	battle.set_process_input(false)
	battle.hud.set_process_input(false)
	battle.hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for control in battle.hud.find_children("*", "Control", true, false):
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in battle.get_children():
		if child is WorldEnvironment: world = child
		if child is DirectionalLight3D: sun = child
	camera = battle.camera
	camera.current = true
	_build_ui()
	set_effects(true)
	set_view(1)
	if "--capture-renderer" in OS.get_cmdline_user_args(): _capture_review()

func set_effects(value: bool) -> void:
	effects = value
	battle.lighting_profile.set_screen_space(effects)
	_update_caption()

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	review_panel = PanelContainer.new()
	review_panel.position = Vector2(235, 60)
	layer.add_child(review_panel)
	var column := VBoxContainer.new()
	review_panel.add_child(column)
	caption = Label.new()
	caption.add_theme_font_size_override("font_size", 18)
	column.add_child(caption)
	var row := HBoxContainer.new()
	column.add_child(row)
	for item in [["B  Effects off / on", func(): set_effects(not effects)], ["H  HUD", toggle_hud], ["R  RTS", func(): set_view(0)]]:
		var button := Button.new()
		button.text = item[0]
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(item[1])
		row.add_child(button)
	var help := Label.new()
	help.text = "1 RTS · 2 Gate · 3 Steps · 4 Flank · 5 Water · 6 Ground · 7 Blue · 8 Korali\nArrows / right-drag pan · wheel zoom · Tab controls · Esc close | simulation held"
	help.add_theme_font_size_override("font_size", 14)
	column.add_child(help)

func set_view(value: int) -> void:
	view_mode = clampi(value, 0, FOCI.size() - 1)
	focus = FOCI[view_mode]
	camera.size = SIZES[view_mode]
	battle.hud.visible = view_mode == 0
	_update_camera()
	_update_caption()

func toggle_hud() -> void:
	battle.hud.visible = not battle.hud.visible
	battle.hud.queue_redraw()

func _update_camera() -> void:
	camera.position = focus + OFFSETS[view_mode]
	camera.look_at(focus)
	battle.hud.queue_redraw()

func _update_caption() -> void:
	if caption:
		var state := "Lighting 02 profile ON" if effects else "Lighting 01 values only (no SSAO/SSIL/glow)"
		if renderer != "forward_plus": state = "Compatibility: profile unavailable"
		caption.text = "RENDERER — %s | %s | %s" % [renderer, state, NAMES[view_mode]]

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
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: camera.size = maxf(2, camera.size * .9)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: camera.size = minf(60, camera.size / .9)
		battle.hud.queue_redraw()
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_8: set_view(event.keycode - KEY_1)
		match event.keycode:
			KEY_B: set_effects(not effects)
			KEY_H: toggle_hud()
			KEY_TAB: review_panel.visible = not review_panel.visible
			KEY_R: set_view(0)
			KEY_ESCAPE: get_tree().quit()

func _capture_review() -> void:
	DirAccess.make_dir_recursive_absolute("res://artifacts/renderer")
	review_panel.hide()
	for view in range(FOCI.size()):
		set_view(view)
		for setting in ([false, true] if renderer == "forward_plus" else [false]):
			set_effects(setting)
			await get_tree().create_timer(.4).timeout
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("res://artifacts/renderer/%s-view%d-%s.png" % [renderer, view, "fx" if setting else "plain"])
	get_tree().quit()
