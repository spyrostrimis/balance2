extends "res://scripts/korali_study.gd"
## The next review asset after the approved Korali and tree.
var korali_reference: Node3D
var reference_mode := false

func _init() -> void:
	study_title = "S A N D S T O N E   /   0 2"
	new_label = "Fractured stone · baked surface detail · irregular silhouette"
	old_label = "Previous sandstone study — revision 01"
	close_size = 6.5
	close_focus = 0.8

func _ready() -> void:
	super._ready()
	get_viewport().use_taa = true
	sunlight.light_angular_distance = 0.7
	korali_reference = preload("res://assets/korali_study/korali_study.glb").instantiate()
	for child in korali_reference.find_children("*", "MeshInstance3D"):
		var material: StandardMaterial3D = child.get_active_material(0).duplicate()
		material.albedo_color = Color(0.72, 0.75, 0.78)
		child.material_override = material
	pivot.add_child(korali_reference)
	korali_reference.visible = false
	var layer := CanvasLayer.new()
	add_child(layer)
	var button := Button.new()
	layer.add_child(button)
	button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	button.offset_left = -260
	button.offset_right = -30
	button.offset_top = 30
	button.offset_bottom = 68
	button.text = "K  Compare approved Korali"
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(toggle_reference)

func _create_study() -> Node3D:
	return preload("res://assets/rock_study/sandstone_formation.glb").instantiate()

func _create_previous() -> void:
	previous.add_child(preload("res://assets/rock_study/previous/sandstone_v1.glb").instantiate())

func toggle_reference() -> void:
	reference_mode = not reference_mode
	show_previous = false
	previous.visible = false
	study.visible = not reference_mode
	korali_reference.visible = reference_mode
	_update_caption()

func toggle_previous() -> void:
	if reference_mode:
		reference_mode = false
		korali_reference.visible = false
	super.toggle_previous()

func _update_caption() -> void:
	if reference_mode:
		caption.text = "Approved Korali reference / same camera and light / K returns to sandstone"
	else:
		super._update_caption()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_K:
		toggle_reference()
	else:
		super._unhandled_input(event)
