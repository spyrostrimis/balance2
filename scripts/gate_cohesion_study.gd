extends Node3D
## Actual mission under integrated Lighting 01, held at deployment. B swaps the
## integrated Gate cluster with the cohesion candidate at an identical camera.
const Arena = preload("res://scripts/arena.gd")
const FOCI := [Vector3(0, 0, -3), Vector3(0, 2.7, -18.6), Vector3(0, .5, -15.2), Vector3(-8.8, 1.2, -17.2), Vector3(8.8, 1.2, -17.2), Vector3(0, 5.8, -18.4), Vector3(0, 2.4, -17.0)]
const SIZES := [36.0, 16.0, 7.0, 7.5, 7.5, 5.5, 13.0]
const OFFSETS := [Vector3(0, 33, 26), Vector3(1, 17, 27), Vector3(2, 8, 10), Vector3(3, 8, 10), Vector3(-3, 8, 10), Vector3(0, 6, 16), Vector3(-15, 9, 15)]
const NAMES := ["Mission / RTS", "Gate (mission angle)", "Steps and base contact", "Left flank and marker", "Right flank and marker", "Crown, lintels and oculus", "Low oblique"]
var battle: Node3D
var camera: Camera3D
var focus := Vector3.ZERO
var view_mode := 0
var caption: Label
var review_panel: PanelContainer
var candidate := true
var previous_cluster: Node3D
var candidate_cluster: Node3D

func _ready() -> void:
	get_window().title = "Balance â€” Gate Cohesion Study 01"
	Arena.gate_compare = true
	battle = preload("res://scenes/main.tscn").instantiate()
	add_child(battle)
	Arena.gate_compare = false
	battle.start_battle()
	battle.set_physics_process(false)
	battle.set_process(false)
	battle.set_process_unhandled_input(false)
	battle.set_process_input(false)
	battle.hud.set_process_input(false)
	battle.hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for control in battle.hud.find_children("*", "Control", true, false):
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	previous_cluster = battle.arena.find_child("GateCluster_previous", false, false)
	candidate_cluster = battle.arena.find_child("GateCluster_candidate", false, false)
	camera = battle.camera
	camera.current = true
	_build_ui()
	set_candidate(true)
	set_view(1)
	if "--capture-gate" in OS.get_cmdline_user_args(): _capture_review()

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
	for item in [["B  Before / after", func(): set_candidate(not candidate)], ["G  Grounding", toggle_grounding], ["H  HUD", toggle_hud], ["R  RTS", func(): set_view(0)]]:
		var button := Button.new()
		button.text = item[0]
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(item[1])
		row.add_child(button)
	var help := Label.new()
	help.text = "1 RTS · 2 Gate · 3 Steps/base · 4 Left flank · 5 Right flank · 6 Crown · 7 Oblique\nG grounding · Arrows / right-drag pan · wheel zoom · Tab controls · Esc close | Lighting 01, simulation held"
	help.add_theme_font_size_override("font_size", 14)
	column.add_child(help)

func set_candidate(value: bool) -> void:
	candidate = value
	previous_cluster.visible = not candidate
	candidate_cluster.visible = candidate
	_update_caption()

func set_view(value: int) -> void:
	view_mode = clampi(value, 0, FOCI.size() - 1)
	focus = FOCI[view_mode]
	camera.size = SIZES[view_mode]
	battle.hud.visible = view_mode == 0
	_update_camera()
	_update_caption()

func toggle_grounding() -> void:
	var grounding := candidate_cluster.find_child("GateGrounding", false, false)
	grounding.visible = not grounding.visible

func toggle_hud() -> void:
	battle.hud.visible = not battle.hud.visible
	battle.hud.queue_redraw()

func _update_camera() -> void:
	camera.position = focus + OFFSETS[view_mode]
	camera.look_at(focus)
	battle.hud.queue_redraw()

func _update_caption() -> void:
	if caption: caption.text = "GATE COHESION 01 â€” %s | %s" % ["AFTER: candidate" if candidate else "BEFORE: integrated Gate 02", NAMES[view_mode]]

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
		if event.keycode >= KEY_1 and event.keycode <= KEY_7: set_view(event.keycode - KEY_1)
		match event.keycode:
			KEY_B: set_candidate(not candidate)
			KEY_G: toggle_grounding()
			KEY_H: toggle_hud()
			KEY_TAB: review_panel.visible = not review_panel.visible
			KEY_R: set_view(0)
			KEY_ESCAPE: get_tree().quit()

func _capture_review() -> void:
	var tag := "run"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--tag="): tag = arg.substr(6)
	DirAccess.make_dir_recursive_absolute("res://artifacts/gate_cohesion")
	review_panel.hide()
	if "--grounding-test" in OS.get_cmdline_user_args():
		for view in [2, 3]:
			set_view(view)
			for shown in [false, true]:
				candidate_cluster.find_child("GateGrounding", false, false).visible = shown
				await get_tree().create_timer(.3).timeout
				await RenderingServer.frame_post_draw
				get_viewport().get_texture().get_image().save_png("res://artifacts/gate_cohesion/%s-view%d-ground%d.png" % [tag, view, int(shown)])
		get_tree().quit()
		return
	for view in range(FOCI.size()):
		set_view(view)
		for setting in [false, true]:
			set_candidate(setting)
			await get_tree().create_timer(.3).timeout
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("res://artifacts/gate_cohesion/%s-view%d-%s.png" % [tag, view, "after" if setting else "before"])
	get_tree().quit()
