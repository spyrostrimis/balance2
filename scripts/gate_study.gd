extends "res://scripts/korali_study.gd"
## Standalone review only. Mission scenery remains unchanged until acceptance.

func _init() -> void:
	study_title = "S A N C T U A R Y   G A T E   /   0 1"
	new_label = "Carved limestone · recessed seal and portal · embroidered palatinate cloth"
	old_label = "Current mission gate — original scale"
	close_size = 18.7
	close_focus = 5.5

func _ready() -> void:
	super._ready()
	get_window().title = "Balance — Gate Study 01"
	get_viewport().use_taa = true
	sunlight.light_angular_distance = 0.7
	environment.ssao_radius = 0.6

func _create_study() -> Node3D:
	return preload("res://assets/gate_study/sanctuary_gate.glb").instantiate()

func _create_previous() -> void:
	var pale := Art.material(Color("d3c2a0"))
	var dark := Art.material(Color("8c7962"))
	preload("res://scripts/scenery.gd")._build_temple(previous, pale, dark)
	previous.position.z = 18.6

func set_distance(mode: int) -> void:
	distance_mode = mode
	camera.size = [18.7, 25.0, 36.0][mode]
	var target := Vector3(0, 5.1 if mode == 0 else 3.5, 0)
	camera.position = target + (Vector3(4.0, 2.8, 19) if mode == 0 else Vector3(0, 33, 26))
	camera.look_at(target)
	_update_caption()
