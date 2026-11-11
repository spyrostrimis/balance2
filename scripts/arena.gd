extends Node3D
## Small, deliberately navigable arena. Decorative scenery outside the bounds
## is separate from obstacles registered in the pathfinding grid.

const Art = preload("res://scripts/shapes.gd")
const Scenery = preload("res://scripts/scenery.gd")
const Details = preload("res://scripts/basin_details.gd")
const HALF_WIDTH := 21
const HALF_DEPTH := 14
const CAPTURE_RADIUS := 5.2
var grid := AStarGrid2D.new()
var capture_ring: MeshInstance3D
var obstacles: Array[Vector3] = [] # x/z = center, y = collision radius.
var terrain_review := true # Approved Terrain 01; false retains the old study comparison.
var waterworks_review := true # Accepted for interim use; false retains the old comparison.
var vegetation_review := true # Vegetation 01 accepted for interim use; false retains Tree 02 comparison.
var debris_review := true # Debris 01 approved for mission use; false retains the old comparison.
var gate_cohesion_review := true # Gate cohesion 01 approved for mission use; false retains the Gate 02 cluster.
static var gate_compare := false # Gate cohesion study builds both clusters for B comparison.

func _ready() -> void:
	_build_terrain()
	_build_grid()

func _build_terrain() -> void:
	var sand := ShaderMaterial.new()
	sand.shader = preload("res://shaders/sand.gdshader")
	var dark_stone := Art.material(Color("414b4c"))
	if terrain_review:
		load("res://scripts/terrain_art.gd").ground(self)
	else:
		Details.terrain(self, sand)
	Scenery.build(self, terrain_review, waterworks_review, vegetation_review, debris_review, gate_cohesion_review or gate_compare, gate_compare)
	Details.build(self, waterworks_review, vegetation_review)
	# Register all substantial new props before building the navigation grid.
	obstacles.append_array(Details.obstacle_footprints())
	capture_ring = Art.ring(self, CAPTURE_RADIUS, Color("80bca9"), 0.025)
	for i in range(12):
		var angle := i * TAU / 12
		var marker := Art.box(self, Vector3(cos(angle) * 5.65, 0.04, sin(angle) * 5.65), Vector3(0.35, 0.08, 0.13), Art.material(Color("b6c2ad")))
		marker.rotation.y = -angle
	# Korali is metal in stone, rather than exposed crystal spikes.
	var deposit := preload("res://assets/korali_study/korali_study.glb").instantiate()
	for child in deposit.find_children("*", "MeshInstance3D"):
		var material: StandardMaterial3D = child.get_active_material(0).duplicate()
		material.albedo_color = Color(0.72, 0.75, 0.78)
		child.material_override = material
	add_child(deposit)
	obstacles.append(Vector3(0, 1.8, 0))
	for p in [Vector3(-8, 1.7, -6), Vector3(8, 1.7, 6), Vector3(-12, 1.5, 7), Vector3(12, 1.5, -7)]:
		obstacles.append(p)
		var rock := preload("res://assets/rock_study/sandstone_formation.glb").instantiate()
		rock.position = Vector3(p.x, 0, p.z)
		rock.scale = Vector3.ONE * (0.9 * p.y / 1.7)
		rock.rotation.y = p.x
		add_child(rock)
	# Faction survey lamps make the deployment zones readable.
	for side in [-1, 1]:
		var faction_color := Color("62baff") if side < 0 else Color("ff7666")
		for z in [-3, 3]:
			Art.cylinder(self, Vector3(side * 17, 0.55, z), 0.3, 0.2, 1.1, dark_stone)
			Art.box(self, Vector3(side * 17, 1.15, z), Vector3(0.36, 0.16, 0.36), Art.material(faction_color, 0.35))
	if debris_review:
		load("res://scripts/debris_art.gd").build(self)

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
