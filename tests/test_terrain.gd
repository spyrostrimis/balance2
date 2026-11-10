extends SceneTree
## Terrain must preserve every navigation cell and avoid accidental colliders.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var baseline := preload("res://scripts/arena.gd").new()
	root.add_child(baseline)
	var candidate := preload("res://scripts/arena.gd").new()
	candidate.terrain_review = true
	root.add_child(candidate)
	assert(baseline.obstacles == candidate.obstacles, "Terrain changed obstacle footprints")
	for x in range(-21, 22):
		for z in range(-14, 15):
			assert(baseline.grid.is_point_solid(Vector2i(x,z)) == candidate.grid.is_point_solid(Vector2i(x,z)), "Terrain changed navigation")
	assert(candidate.find_children("*", "CollisionObject3D").is_empty(), "Terrain introduced colliders")
	var ground: MeshInstance3D = candidate.find_child("AuthoredSandBasin", true, false)
	var vertices: PackedVector3Array = ground.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	for v in vertices:
		if absf(v.x) <= 21 and absf(v.z) <= 14:
			assert(absf(v.y + .015) < .0001, "Playable floor is not flat")
	var normals: PackedVector3Array = ground.mesh.surface_get_arrays(0)[Mesh.ARRAY_NORMAL]
	for n in normals: assert(n.y > .5, "Ground face winding is inverted")
	var landforms := candidate.find_child("TerrainReviewLandforms", true, false)
	for child in landforms.find_children("*", "MeshInstance3D"):
		for surface in range(child.mesh.get_surface_count()):
			var points: PackedVector3Array = child.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
			for point in points:
				var world_point: Vector3 = child.global_transform * point
				assert(absf(world_point.x) > 21.5 or absf(world_point.z) > 14.5, "Raised landform intrudes into playable grid")
	print("PASS: identical 1247 navigation cells and obstacle footprints; no colliders; flat upward-facing floor; raised landforms outside grid")
	quit()
