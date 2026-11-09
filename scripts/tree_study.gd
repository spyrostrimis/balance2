extends "res://scripts/korali_study.gd"
## One candidate tree with small flowering root plants; no mission replacement yet.

func _init() -> void:
	study_title = "B A S I N   T R E E   /   0 1"
	new_label = "Branching trunk · layered leaves · root flowers"
	old_label = "Original mission tree + flowers"
	close_size = 8.0
	close_focus = 1.7

func _ready() -> void:
	super._ready()
	# Stabilize the fine leaf shadows while retaining gaps in the canopy.
	get_viewport().use_taa = true
	sunlight.light_angular_distance = 0.7

func _create_study() -> Node3D:
	return preload("res://assets/tree_study/desert_tree.glb").instantiate()

func _create_previous() -> void:
	var details = preload("res://scripts/basin_details.gd")
	var scenery = preload("res://scripts/scenery.gd")
	details._tree(previous, Vector3.ZERO, 3.6, 47)
	scenery.plant(previous, Vector3(-0.7, 0, 0.65), 0.65, 0)
	scenery.plant(previous, Vector3(0.35, 0, 0.9), 0.5, 3)
	scenery.plant(previous, Vector3(0.85, 0, -0.3), 0.4, 6)
