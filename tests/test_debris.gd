extends SceneTree
## Validate actual imported geometry against existing navigation, not just placements.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var baseline := preload("res://scripts/arena.gd").new()
	assert(not baseline.debris_review, "Unaccepted candidate became mission default")
	root.add_child(baseline)
	var candidate := preload("res://scripts/arena.gd").new()
	candidate.debris_review = true
	root.add_child(candidate)
	assert(candidate.terrain_review and candidate.waterworks_review and candidate.vegetation_review)
	assert(baseline.obstacles == candidate.obstacles, "Debris changed registered footprints")
	for x in range(-21, 22):
		for z in range(-14, 15):
			assert(baseline.grid.is_point_solid(Vector2i(x, z)) == candidate.grid.is_point_solid(Vector2i(x, z)), "Debris changed navigation")
	assert(candidate.find_children("*", "CollisionObject3D").is_empty(), "Cosmetic debris added collision")
	var old_assets := baseline.get_children().filter(func(n: Node): return not n.scene_file_path.is_empty())
	var new_assets := candidate.get_children().filter(func(n: Node): return not n.scene_file_path.is_empty())
	assert(old_assets.size() == new_assets.size())
	for i in range(old_assets.size()):
		assert(old_assets[i].scene_file_path == new_assets[i].scene_file_path)
		assert(old_assets[i].transform.is_equal_approx(new_assets[i].transform), "Accepted asset moved")
	var floor_before: MeshInstance3D = baseline.get_node("AuthoredSandBasin")
	var floor_after: MeshInstance3D = candidate.get_node("AuthoredSandBasin")
	assert(floor_before.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] == floor_after.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX], "Ground geometry changed")
	var group := candidate.get_node("DebrisCandidate")
	var vertices := 0
	var pieces := 0
	for asset in group.get_children():
		var meshes: Array[Node] = asset.find_children("*", "MeshInstance3D")
		if asset is MeshInstance3D: meshes.append(asset)
		if asset.has_meta("debris_candidate"): pieces += 1
		for mesh_node in meshes:
			for surface in range(mesh_node.mesh.get_surface_count()):
				var points: PackedVector3Array = mesh_node.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
				for point in points:
					var p: Vector3 = mesh_node.global_transform * point
					assert(p.is_finite(), "Non-finite debris geometry")
					assert(Vector2(p.x, p.z).length() > 6, "Debris entered the central combat circle")
					var outside := absf(p.x) > 21.15 or absf(p.z) > 14.15
					if not outside and p.y > .06:
						var within_footprint := false
						for obstacle in candidate.obstacles:
							if Vector2(p.x - obstacle.x, p.z - obstacle.z).length() < obstacle.y:
								within_footprint = true
						assert(within_footprint, "Raised debris outside footprint: %s at %s" % [asset.name, p])
					vertices += 1
	assert(pieces == 24, "Missing candidate placements")
	print("PASS: 1247 navigation cells, identical footprints/accepted transforms/floor, no colliders, clear combat circle; %d placements, %d imported/transition vertices checked" % [pieces, vertices])
	quit()
