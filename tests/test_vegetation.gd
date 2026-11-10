extends SceneTree
## Exercise actual imported candidate meshes and preserve mission navigation/placements.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var baseline := preload("res://scripts/arena.gd").new()
	assert(baseline.vegetation_review, "Accepted vegetation should be the mission default")
	baseline.vegetation_review = false
	root.add_child(baseline)
	var candidate := preload("res://scripts/arena.gd").new()
	candidate.vegetation_review = true
	root.add_child(candidate)
	assert(baseline.obstacles == candidate.obstacles, "Vegetation changed registered footprints")
	for x in range(-21, 22):
		for z in range(-14, 15):
			assert(baseline.grid.is_point_solid(Vector2i(x, z)) == candidate.grid.is_point_solid(Vector2i(x, z)), "Vegetation changed navigation")
	assert(candidate.find_children("*", "CollisionObject3D").is_empty(), "Cosmetic plants introduced colliders")
	var old_trees := baseline.get_children().filter(func(node: Node): return node.scene_file_path == "res://assets/tree_study/v2/desert_tree.glb")
	var new_trees := candidate.get_children().filter(func(node: Node): return node.scene_file_path == "res://assets/vegetation_study/tree.glb")
	assert(old_trees.size() == 4 and new_trees.size() == 4)
	for i in range(4):
		assert(old_trees[i].transform.is_equal_approx(new_trees[i].transform), "Tree placement, scale or rotation changed")
	var vertices := 0
	for asset in candidate.get_children():
		if not asset.has_meta("vegetation_candidate"): continue
		var is_tree: bool = asset.scene_file_path == "res://assets/vegetation_study/tree.glb"
		for mesh_node in asset.find_children("*", "MeshInstance3D"):
			for surface in range(mesh_node.mesh.get_surface_count()):
				assert(mesh_node.get_active_material(surface).vertex_color_use_as_albedo, "Godot lost authored botanical tints")
				var points: PackedVector3Array = mesh_node.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
				for point in points:
					var p: Vector3 = mesh_node.global_transform * point
					assert(p.is_finite(), "Non-finite exported vertex")
					assert(not (absf(p.x) < 6.0 and absf(p.z) < 13.5), "Vegetation entered central combat corridor")
					if is_tree and p.y > .65 and p.y < 1.25:
						assert(Vector2(p.x - asset.position.x, p.z - asset.position.z).length() < 1.2, "Low tree geometry escaped registered trunk footprint")
					vertices += 1
	print("PASS: 1247 navigation cells, identical footprints/four tree transforms, no colliders, clear central corridor; %d finite imported vertices" % vertices)
	quit()
