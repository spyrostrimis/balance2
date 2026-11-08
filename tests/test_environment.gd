extends SceneTree
## Environment additions must preserve a connected, navigable mission.
const Arena = preload("res://scripts/arena.gd")
var failures := 0
var checks := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition: failures += 1
	print("PASS: " if condition else "FAIL: ", description)

func run() -> void:
	var arena := Arena.new()
	root.add_child(arena)
	check(not arena.walkable(Vector3(-17, 0, -10)), "Damaged cistern blocks movement")
	check(not arena.walkable(Vector3(-18, 0, -6)) and not arena.walkable(Vector3(18, 0, 10)), "Tree trunks block movement on both sides")
	check(not arena.walkable(Vector3(10, 0, -13)) and not arena.walkable(Vector3(-13, 0, -13)), "Aqueduct supports block movement")
	var blocked_destination := arena.nearest_open(Vector3(-17, 0, -10))
	check(not arena.grid.is_point_solid(blocked_destination), "Clicking the cistern resolves to reachable ground")
	# Flood-fill the actual navigation grid, catching trapped pockets at borders.
	var visited := {Vector2i(-13, 0): true}
	var queue: Array[Vector2i] = [Vector2i(-13, 0)]
	var cursor := 0
	while cursor < queue.size():
		var current := queue[cursor]
		cursor += 1
		for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var next: Vector2i = current + offset
			if arena.grid.is_in_boundsv(next) and not arena.grid.is_point_solid(next) and not visited.has(next):
				visited[next] = true
				queue.append(next)
	var all_connected := true
	for x in range(-21, 22):
		for z in range(-14, 15):
			var cell := Vector2i(x, z)
			if not arena.grid.is_point_solid(cell) and not visited.has(cell):
				all_connected = false
				print("ISOLATED: ", cell)
	check(all_connected, "Every walkable cell remains connected to the Blue deployment")
	check(visited.has(Vector2i(13, 0)) and visited.has(Vector2i(-3, 0)) and visited.has(Vector2i(3, 0)), "Both deployments and capture approaches remain accessible")
	var ground: MeshInstance3D = arena.get_node("BasinGround")
	var vertices: PackedVector3Array = ground.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var flat_play_area := true
	var raised_border := false
	for vertex in vertices:
		if absf(vertex.x) <= 22 and absf(vertex.z) <= 16:
			flat_play_area = flat_play_area and is_equal_approx(vertex.y, -0.015)
		elif vertex.y > 0.4: raised_border = true
	check(flat_play_area and raised_border, "Raised landscape surrounds a flat gameplay surface")
	var normals: PackedVector3Array = ground.mesh.surface_get_arrays(0)[Mesh.ARRAY_NORMAL]
	var center := vertices.find(Vector3.DOWN * 0.015)
	check(center >= 0 and normals[center].y > 0.99, "Terrain faces upward for lighting and visibility")
	arena.free()
	print("ENVIRONMENT RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
