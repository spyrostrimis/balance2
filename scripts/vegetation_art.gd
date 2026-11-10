extends RefCounted
## Review-only original vegetation. No colliders or navigation changes.
const TREE = preload("res://assets/vegetation_study/tree.glb")
const GRASSES = [preload("res://assets/vegetation_study/grass_tall.glb"), preload("res://assets/vegetation_study/grass_low.glb"), preload("res://assets/vegetation_study/grass_arching.glb")]
const PLANTS = [preload("res://assets/vegetation_study/crevice_flower.glb"), preload("res://assets/vegetation_study/rosette.glb"), preload("res://assets/vegetation_study/shrub.glb")]

static func _place(parent: Node3D, packed: PackedScene, pos: Vector3, size: float, angle: float, label: String) -> Node3D:
	var node: Node3D = packed.instantiate()
	node.name = label
	node.position = pos
	node.scale = Vector3.ONE * size
	node.rotation.y = angle
	node.set_meta("vegetation_candidate", true)
	prepare_materials(node)
	parent.add_child(node)
	return node

static func prepare_materials(node: Node3D) -> void:
	# This Godot import retains COLOR_0 but leaves use-as-albedo disabled.
	# Explicitly enable the authored linear botanical tints on candidate materials.
	for child in node.find_children("*", "MeshInstance3D"):
		for surface in range(child.mesh.get_surface_count()):
			var mat := child.get_active_material(surface) as StandardMaterial3D
			if mat:
				mat.vertex_color_use_as_albedo = true
				mat.vertex_color_is_srgb = false

static func tree(parent: Node3D, pos: Vector3, height: float, seed_value: int) -> void:
	# Preserve the exact four registered trunk placements, RNG sequence, scale and yaw rules.
	_place(parent, TREE, pos, height / 3.6, seed_value * .37, "BasinTreeCandidate")

static func _ground(pos: Vector3) -> Vector3:
	# Same continuous border elevation as Terrain 01. Walkable grid remains flat.
	var edge := maxf(absf(pos.x) - 22.0, absf(pos.z) - 16.0)
	pos.y = smoothstep(0, 8, edge) * (1.15 + .30 * sin(pos.x * .26 + pos.z * .18)) - .012
	return pos

static func grass(parent: Node3D, pos: Vector3, height: float, seed_value: int) -> void:
	var variant := posmod(seed_value, 3)
	_place(parent, GRASSES[variant], _ground(pos), height / (.42 if variant == 1 else .96), seed_value * 2.39996, "VegetationGrass")

static func plant(parent: Node3D, pos: Vector3, height: float, seed_value: int) -> void:
	# Low crevice plants by registered rock formations; shrubs restricted to outer pockets.
	var variant := posmod(seed_value, 3)
	if absf(pos.x) < 19 and absf(pos.z) < 14: variant = posmod(seed_value, 2)
	_place(parent, PLANTS[variant], _ground(pos), height * .82, seed_value * 2.39996, "VegetationPocketPlant")

static func border_pockets(parent: Node3D) -> void:
	# Hand-composed clusters at cliff toes and ruin edges, never in central combat lanes.
	var pockets := [Vector3(-20.6, 0, -13.2), Vector3(-21.1, 0, -3.7), Vector3(-21.3, 0, 11.8), Vector3(21.5, 0, -10.8), Vector3(21.3, 0, 3.8), Vector3(20.8, 0, 12.4), Vector3(-12.5, 0, -15.4), Vector3(12.2, 0, -15.6)]
	for index in range(pockets.size()):
		var pos: Vector3 = pockets[index]
		for j in range(7):
			var angle := j * 2.39996 + index
			var offset := Vector3(cos(angle), 0, sin(angle)) * (.26 + .17 * j)
			grass(parent, pos + offset, .34 + .055 * (j % 4), j + index)
		plant(parent, pos, .62, index % 2)
	# Two woody shrubs remain beyond the playable rectangle.
	_place(parent, PLANTS[2], _ground(Vector3(-22, 0, 2.2)), .86, .8, "VegetationBorderShrub")
	_place(parent, PLANTS[2], _ground(Vector3(22, 0, -5.6)), .78, 2.3, "VegetationBorderShrub")
