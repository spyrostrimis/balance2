extends SceneTree
## Gate cohesion candidate is cosmetic: identical navigation/footprints, no
## colliders, and no candidate geometry inside walkable space.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var Arena = preload("res://scripts/arena.gd")
	var baseline = Arena.new()
	baseline.gate_cohesion_review = false
	root.add_child(baseline)
	var candidate = Arena.new()
	assert(candidate.gate_cohesion_review, "Gate cohesion 01 should be the mission default")
	root.add_child(candidate)
	assert(baseline.find_child("GateCluster_previous", false, false) != null, "Baseline lost the Gate 02 cluster")
	assert(baseline.find_child("GateCluster_candidate", false, false) == null, "Candidate leaked into the baseline")
	var cluster: Node3D = candidate.find_child("GateCluster_candidate", false, false)
	assert(cluster != null and candidate.find_child("GateCluster_previous", false, false) == null)
	assert(baseline.obstacles == candidate.obstacles, "Gate cohesion changed registered footprints")
	for x in range(-21, 22):
		for z in range(-14, 15):
			assert(baseline.grid.is_point_solid(Vector2i(x, z)) == candidate.grid.is_point_solid(Vector2i(x, z)), "Gate cohesion changed navigation")
	assert(cluster.find_children("*", "CollisionObject3D").is_empty(), "Cosmetic Gate cluster added collision")
	var gate: Node3D = cluster.get_node("SanctuaryGate")
	assert(gate.position.is_equal_approx(Vector3(0, 0, -18.6)) and gate.scale.is_equal_approx(Vector3.ONE * .78), "Gate placement/scale changed")
	var vertices := 0
	var deepest := -INF
	for mesh_node in cluster.find_children("*", "MeshInstance3D", true, false):
		for surface in range(mesh_node.mesh.get_surface_count()):
			var points: PackedVector3Array = mesh_node.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
			for point in points:
				var p: Vector3 = mesh_node.global_transform * point
				assert(p.is_finite(), "Non-finite Gate cohesion geometry")
				assert(p.z < -14.0, "Gate cohesion geometry entered walkable space: %s at %s" % [mesh_node.name, p])
				deepest = maxf(deepest, p.z)
				vertices += 1
	print("PASS: 1247 navigation cells and footprints unchanged, no colliders, Gate at (0,0,-18.6) x0.78; %d vertices all north of z=-14 (max z %.3f)" % [vertices, deepest])
	quit()
