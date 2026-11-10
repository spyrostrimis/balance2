extends SceneTree
## Candidate must preserve routes and keep substantial masonry inside old footprints.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var baseline := preload("res://scripts/arena.gd").new()
	assert(not baseline.waterworks_review, "Unaccepted candidate became mission default")
	root.add_child(baseline)
	var candidate := preload("res://scripts/arena.gd").new()
	candidate.waterworks_review = true
	root.add_child(candidate)
	assert(baseline.obstacles == candidate.obstacles, "Waterworks changed obstacle footprints")
	for x in range(-21, 22):
		for z in range(-14, 15):
			assert(baseline.grid.is_point_solid(Vector2i(x,z)) == candidate.grid.is_point_solid(Vector2i(x,z)), "Waterworks changed navigation")
	assert(candidate.find_children("*", "CollisionObject3D").is_empty(), "Waterworks introduced colliders")
	var checked := 0
	for asset in candidate.get_children():
		if not str(asset.name).begins_with("WaterworksCandidate"): continue
		for child in asset.find_children("*", "MeshInstance3D"):
			for surface in range(child.mesh.get_surface_count()):
				var points: PackedVector3Array = child.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
				for point in points:
					var p: Vector3 = child.global_transform * point
					checked += 1
					# Low conduit/rubble and overhead lintels preserve pre-existing clearances.
					if p.y <= .70 or p.y >= 2.40 or absf(p.x) > 21 or absf(p.z) > 14: continue
					var covered := false
					for footprint in candidate.obstacles:
						if Vector2(p.x,p.z).distance_to(Vector2(footprint.x,footprint.z)) <= footprint.y:
							covered = true
							break
					assert(covered, "Substantial masonry extends beyond existing footprint at %s" % p)
	print("PASS: identical 1247 navigation cells, footprints and no colliders; checked %d mesh vertices for clearance; mission default unchanged" % checked)
	quit()
