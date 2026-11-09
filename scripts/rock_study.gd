extends "res://scripts/korali_study.gd"
## The next review asset after the approved Korali and tree.

func _init() -> void:
	study_title = "S A N D S T O N E   /   0 1"
	new_label = "Fractured faces · sediment layers · fallen slabs"
	old_label = "Original mission rock formation"
	close_size = 6.5
	close_focus = 0.8

func _ready() -> void:
	super._ready()
	get_viewport().use_taa = true
	sunlight.light_angular_distance = 0.7

func _create_study() -> Node3D:
	return preload("res://assets/rock_study/sandstone_formation.glb").instantiate()

func _create_previous() -> void:
	var scenery = preload("res://scripts/scenery.gd")
	var sandstone: Material = scenery.stone(Color("a8794d"))
	var pale: Material = scenery.stone(Color("b5a489"))
	var rock := Art.rock(previous, Vector3(0, 0.72, 0), Vector3(3.06, 1.8, 2.72), sandstone, 24)
	rock.rotation.y = -8.0
	for i in range(6):
		var angle := i * TAU / 6
		var point := Vector3(cos(angle), 0, sin(angle)) * 1.3
		Art.rock(previous, point + Vector3.UP * 0.12, Vector3(0.42, 0.32, 0.5), pale, i * 7)
