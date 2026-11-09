extends "res://scripts/korali_study.gd"
## Revision 02 is in the mission; revision 01 is retained for comparison.

func _init() -> void:
	study_title = "B A S I N   T R E E   /   0 2"
	new_label = "Weathered bark · veined leaves · root flowers"
	old_label = "Previous tree study — revision 01"
	close_size = 8.0
	close_focus = 1.7

func _ready() -> void:
	super._ready()
	# Stabilize the fine leaf shadows while retaining gaps in the canopy.
	get_viewport().use_taa = true
	sunlight.light_angular_distance = 0.7

func _create_study() -> Node3D:
	return preload("res://assets/tree_study/v2/desert_tree.glb").instantiate()

func _create_previous() -> void:
	previous.add_child(preload("res://assets/tree_study/desert_tree.glb").instantiate())
