extends Node3D
## Small, deliberately navigable arena. Decorative scenery outside the bounds
## is separate from obstacles registered in the pathfinding grid.

const Art = preload("res://scripts/shapes.gd")
const HALF_WIDTH := 21
const HALF_DEPTH := 14
const CAPTURE_RADIUS := 5.2
var grid := AStarGrid2D.new()
var capture_ring: MeshInstance3D
var obstacles: Array[Vector3] = [] # x/z = center, y = collision radius.

func _ready() -> void:
	_build_terrain()
	_build_grid()

func _build_terrain() -> void:
	var sand := ShaderMaterial.new()
	sand.shader = preload("res://shaders/sand.gdshader")
	var sandstone := Art.material(Color("776750"))
	var dark_stone := Art.material(Color("414b4c"))
	var soil := Art.material(Color("2e393b"))
	Art.box(self, Vector3(0, -1.1, 0), Vector3(47, 2.1, 34), soil)
	Art.box(self, Vector3(0, -0.16, 0), Vector3(43, 0.3, 29), sand)
	Art.cylinder(self, Vector3(0, 0.005, 0), 5.3, 5.3, 0.02, Art.material(Color("8b8065")), 64)
	capture_ring = Art.ring(self, CAPTURE_RADIUS, Color("80bca9"), 0.045)
	for i in range(12):
		var angle := i * TAU / 12
		var marker := Art.box(self, Vector3(cos(angle) * 5.65, 0.04, sin(angle) * 5.65), Vector3(0.35, 0.08, 0.13), Art.material(Color("b6c2ad")))
		marker.rotation.y = -angle
	# Ore bed and original faceted Korali crystals.
	Art.cylinder(self, Vector3(0, 0.25, 0), 1.65, 1.3, 0.5, dark_stone, 7)
	obstacles.append(Vector3(0, 1.8, 0))
	var crystal := Art.material(Color("36bba4"), 0.18)
	var ore_positions := [Vector3(-0.65, 0.9, 0.25), Vector3(0.1, 1.3, -0.2), Vector3(0.75, 0.75, 0.3), Vector3(-0.1, 0.65, 0.9)]
	for p in ore_positions:
		var shard := Art.cylinder(self, p, 0.42, 0.05, p.y * 1.7, crystal, 5)
		shard.rotation.z = p.x * -0.35
	for p in [Vector3(-8, 1.7, -6), Vector3(8, 1.7, 6), Vector3(-12, 1.5, 7), Vector3(12, 1.5, -7)]:
		obstacles.append(p)
		var rock := Art.cylinder(self, Vector3(p.x, 0.85, p.z), p.y, p.y * 0.65, 1.7, sandstone, 5)
		rock.rotation.y = p.x
		Art.cylinder(self, Vector3(p.x + 0.5, 1.8, p.z), 0.85, 0.5, 0.65, sandstone, 5)
	var rng := RandomNumberGenerator.new()
	rng.seed = 4192
	for i in range(72):
		var p := Vector3(rng.randf_range(-23, 23), 0, rng.randf_range(-16, 16))
		if absf(p.x) < 20.8 and absf(p.z) < 13.8:
			continue
		var size := rng.randf_range(0.45, 2.0)
		Art.cylinder(self, p + Vector3.UP * size * 0.25, size, size * 0.65, size * 1.7, sandstone, 5).rotation.y = rng.randf() * TAU
	# Broken surveying strips lead toward the deposit.
	for side in [-1, 1]:
		for i in range(7):
			Art.box(self, Vector3(side * (7 + i * 1.65), 0.018, 0), Vector3(0.7, 0.035, 0.06), Art.material(Color("c2b593")))
		var faction_color := Color("62baff") if side < 0 else Color("ff7666")
		for z in [-3, 3]:
			Art.cylinder(self, Vector3(side * 17, 0.55, z), 0.3, 0.2, 1.1, dark_stone)
			Art.box(self, Vector3(side * 17, 1.15, z), Vector3(0.36, 0.16, 0.36), Art.material(faction_color, 1.0))
	# Small desert plants, kept outside the traversable arena.
	for i in range(24):
		var x := rng.randf_range(-21, 21)
		var z := rng.randf_range(14.6, 15.8) * (-1 if i % 2 == 0 else 1)
		for j in range(3):
			var plant := Art.cylinder(self, Vector3(x + j * 0.12, 0.3, z), 0.15, 0.015, 0.7, Art.material(Color("5c7f79")), 4)
			plant.rotation.z = (j - 1) * 0.35

func _build_grid() -> void:
	grid.region = Rect2i(-HALF_WIDTH, -HALF_DEPTH, HALF_WIDTH * 2 + 1, HALF_DEPTH * 2 + 1)
	grid.cell_size = Vector2.ONE
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.update()
	for x in range(-HALF_WIDTH, HALF_WIDTH + 1):
		for z in range(-HALF_DEPTH, HALF_DEPTH + 1):
			for obstacle in obstacles:
				if Vector2(x, z).distance_to(Vector2(obstacle.x, obstacle.z)) < obstacle.y + 0.5:
					grid.set_point_solid(Vector2i(x, z))

func cell(point: Vector3) -> Vector2i:
	return Vector2i(clampi(roundi(point.x), -HALF_WIDTH, HALF_WIDTH), clampi(roundi(point.z), -HALF_DEPTH, HALF_DEPTH))

func nearest_open(point: Vector3) -> Vector2i:
	var start := cell(point)
	if not grid.is_point_solid(start):
		return start
	var best := start
	var distance := INF
	for x in range(-5, 6):
		for y in range(-5, 6):
			var candidate := start + Vector2i(x, y)
			if grid.is_in_boundsv(candidate) and not grid.is_point_solid(candidate):
				var d := Vector2(candidate).distance_squared_to(Vector2(point.x, point.z))
				if d < distance:
					distance = d
					best = candidate
	return best

func path_between(start: Vector3, finish: Vector3) -> PackedVector3Array:
	var path := PackedVector3Array()
	var points := grid.get_id_path(nearest_open(start), nearest_open(finish))
	for i in range(1, points.size()):
		path.append(Vector3(points[i].x, 0, points[i].y))
	if path.is_empty():
		var destination := nearest_open(finish)
		path.append(Vector3(destination.x, 0, destination.y))
	return path

func walkable(point: Vector3) -> bool:
	if absf(point.x) > HALF_WIDTH or absf(point.z) > HALF_DEPTH:
		return false
	return not grid.is_point_solid(cell(point))
