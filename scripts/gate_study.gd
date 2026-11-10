extends "res://scripts/korali_study.gd"
## Approved revision 02, now used in the mission; B preserves revision 01.
var context: Node3D
var context_mode := false
var stage_ground: MeshInstance3D

func _init() -> void:
	study_title = "S A N C T U A R Y   G A T E   /   0 2"
	new_label = "Aged carved stone · compact crown · ruined porticoes · climbing ivy"
	old_label = "Approved revision 01 — same world units"
	close_size = 16.4
	close_focus = 3.6

func _ready() -> void:
	super._ready()
	get_window().title = "Balance — Gate Study 02"
	get_viewport().use_taa = RenderingServer.get_current_rendering_method() == "forward_plus"
	sunlight.light_angular_distance = 0.7
	environment.ssao_radius = 0.6
	for child in get_children():
		if child is MeshInstance3D:
			stage_ground = child
			break
	var layer := CanvasLayer.new()
	add_child(layer)
	var button := Button.new()
	layer.add_child(button)
	button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	button.offset_left = -290
	button.offset_right = -30
	button.offset_top = 30
	button.offset_bottom = 68
	button.text = "G  Mission surroundings"
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(toggle_context)

func _create_study() -> Node3D:
	return preload("res://assets/gate_study/v2/sanctuary_gate.glb").instantiate()

func _create_previous() -> void:
	previous.add_child(preload("res://assets/gate_study/sanctuary_gate.glb").instantiate())

func set_distance(mode: int) -> void:
	distance_mode = mode
	camera.size = [16.4, 25.0, 36.0][mode]
	var target := Vector3(0, 3.6 if mode == 0 else 2.6, 0)
	if context_mode:
		target = Vector3(0, 2.0, -15.0)
		camera.size = [20.0, 28.0, 36.0][mode]
	camera.position = target + (Vector3(2.5, 7.5, 19) if mode == 0 else Vector3(0, 33, 26))
	camera.look_at(target)
	_update_caption()

func toggle_context() -> void:
	context_mode = not context_mode
	if context_mode and not is_instance_valid(context):
		context = preload("res://scripts/arena.gd").new()
		add_child(context)
		# Uses the mission's integrated Gate and fitted flanking rocks directly.
		context.capture_ring.hide()
	if is_instance_valid(context): context.visible = context_mode
	stage_ground.visible = not context_mode
	pivot.visible = not context_mode
	rotating = false
	set_distance(2 if context_mode else 0)

func _update_caption() -> void:
	if context_mode:
		caption.text = "Integrated revision 02 / mission surroundings / scale 0.78 / G returns"
	else:
		super._update_caption()

func toggle_previous() -> void:
	if context_mode: toggle_context()
	super.toggle_previous()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_G:
		toggle_context()
	else:
		super._unhandled_input(event)
