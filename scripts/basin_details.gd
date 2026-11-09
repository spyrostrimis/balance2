extends RefCounted
## Original environmental storytelling and foliage for the Shattered Basin.
const Art = preload("res://scripts/shapes.gd")
const Scenery = preload("res://scripts/scenery.gd")
const TREE_POSITIONS := [Vector3(-18, 0, -5.8), Vector3(-18, 0, 8.5), Vector3(17.8, 0, -8.8), Vector3(18, 0, 9.8)]
const CISTERN_POSITION := Vector3(-17, 0, -10)

static func obstacle_footprints() -> Array[Vector3]:
	var footprints: Array[Vector3] = [Vector3(CISTERN_POSITION.x, 2.5, CISTERN_POSITION.z), Vector3(-20.5, 1.0, -10.5)]
	for p in TREE_POSITIONS: footprints.append(Vector3(p.x, 1.2, p.z))
	for side in [-1, 1]:
		for i in range(3): footprints.append(Vector3(side * (9.5 + i * 3.1), 1.0, -12.0))
	return footprints

static func foliage(color: Color) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/basin_foliage.gdshader")
	material.set_shader_parameter("leaf_color", color)
	return material

static func terrain(parent: Node3D, material: Material) -> void:
	var noise := FastNoiseLite.new()
	noise.seed = 1947
	noise.frequency = 0.07
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for x in range(-28, 28):
		for z in range(-25, 25):
			var points: Array[Vector3] = []
			for offset in [Vector2.ZERO, Vector2(1, 0), Vector2(0, 1), Vector2.ONE]:
				var px: float = (x + offset.x) * 2
				var pz: float = (z + offset.y) * 2
				var edge := maxf(absf(px) - 22, absf(pz) - 16)
				var height := smoothstep(0, 8, edge) * (1.0 + noise.get_noise_2d(px, pz) * 2.4)
				points.append(Vector3(px, height - 0.015, pz))
			for i in [0, 1, 2, 1, 3, 2]: surface.add_vertex(points[i])
	surface.index()
	surface.generate_normals()
	var ground := Art.mesh(parent, surface.commit(), Vector3.ZERO, material)
	ground.name = "BasinGround"

static func build(parent: Node3D) -> void:
	_water_station(parent)
	_waystation(parent)
	var rng := RandomNumberGenerator.new()
	rng.seed = 4096
	# Solid foliage and architecture are also registered by Arena.
	for p in TREE_POSITIONS:
		_tree(parent, p, rng.randf_range(2.7, 3.8), rng.randi_range(0, 100))
	for i in range(30):
		var p := Vector3(rng.randf_range(-23, 23), 0, rng.randf_range(-16.7, -14.8))
		if absf(p.x) < 7: continue
		_grass(parent, p, rng.randf_range(0.35, 0.75), i)
	for side in [-1, 1]:
		for i in range(20):
			var p := Vector3(side * rng.randf_range(20.5, 23.0), 0, rng.randf_range(-13, 14))
			_grass(parent, p, rng.randf_range(0.25, 0.6), i)

static func _branch(parent: Node3D, start: Vector3, end: Vector3, radius: float, material: Material) -> void:
	var limb := Art.cylinder(parent, (start + end) * 0.5, radius, radius * 0.58, start.distance_to(end), material, 7)
	limb.quaternion = Quaternion(Vector3.UP, start.direction_to(end))

static func _tree(parent: Node3D, pos: Vector3, height: float, seed_value: int) -> void:
	var tree := preload("res://assets/tree_study/v2/desert_tree.glb").instantiate()
	tree.name = "BasinTree"
	tree.position = pos
	tree.scale = Vector3.ONE * (height / 3.6)
	tree.rotation.y = seed_value * 0.37
	parent.add_child(tree)

static func prototype_tree(parent: Node3D, pos: Vector3, height: float, seed_value: int) -> void:
	# Retained only for the review scene's before/after comparison.
	var tree := Node3D.new()
	tree.position = pos
	tree.name = "BasinTree"
	parent.add_child(tree)
	var bark := Art.material(Color("635b4a"))
	var leaves := [foliage(Color("3d6961")), foliage(Color("598575")), foliage(Color("78917a"))]
	_branch(tree, Vector3.ZERO, Vector3(0.18, height * 0.7, 0), 0.19, bark)
	for i in range(5):
		var angle := i * TAU / 5 + seed_value
		var end := Vector3(cos(angle) * 0.95, height * (0.72 + (i % 3) * 0.10), sin(angle) * 0.85)
		_branch(tree, Vector3(0.1, height * 0.48, 0), end, 0.095, bark)
		Art.rock(tree, end + Vector3.UP * 0.16, Vector3(1.8, 0.65, 1.55), leaves[i % 3], seed_value + i)
	for side in [-1, 1]: _branch(tree, Vector3(side * 0.43, 0.03, 0.25), Vector3(0, 0.4, 0), 0.075, bark)

static func _grass(parent: Node3D, pos: Vector3, height: float, seed_value: int) -> void:
	var material := foliage(Color("8e956c") if seed_value % 3 else Color("557c70"))
	for i in range(5):
		var blade := Art.leaf(parent, pos + Vector3(i * 0.045, 0, 0), height * (0.65 + i * 0.1), height * 0.055, material)
		blade.rotation.y = i * 2.4 + seed_value

static func _water_station(parent: Node3D) -> void:
	var station := Node3D.new()
	station.name = "DamagedWaterStation"
	station.position = CISTERN_POSITION
	parent.add_child(station)
	var stone := Scenery.stone(Color("999383"))
	var metal := Art.material(Color("435d60"))
	var ivory := Art.material(Color("bbb89c"))
	var rust := Art.material(Color("8a624a"))
	Art.cylinder(station, Vector3(0, 0.08, 0), 2.1, 2.1, 0.16, stone, 32)
	for i in range(20):
		if i == 3 or i == 4: continue
		var angle := i * TAU / 20
		var wall := Art.box(station, Vector3(cos(angle) * 1.8, 0.53, sin(angle) * 1.8), Vector3(0.58, 0.9, 0.3), stone)
		wall.rotation.y = -angle + PI / 2
	var water := ShaderMaterial.new()
	water.shader = preload("res://shaders/basin_water.gdshader")
	Art.cylinder(station, Vector3(0, 0.185, 0), 1.63, 1.63, 0.02, water, 48)
	for i in range(4):
		Art.rock(station, Vector3(0.8 + i * 0.23, 0.12, 1.75 + (i % 2) * 0.25), Vector3(0.42, 0.35, 0.6), stone, i + 19)
	Art.box(station, Vector3(-1.8, 0.7, -0.5), Vector3(0.7, 1.4, 0.8), metal)
	Art.box(station, Vector3(-1.8, 0.9, -0.06), Vector3(0.52, 0.65, 0.035), ivory)
	Art.box(station, Vector3(-1.8, 1.02, -0.035), Vector3(0.31, 0.11, 0.025), Art.material(Color("c58b4d"), 0.2))
	for i in range(3):
		var pipe := Art.cylinder(station, Vector3(-2.6 - i * 1.1, 0.32, -0.5), 0.22, 0.22, 1.0, metal, 12)
		pipe.rotation.z = PI / 2
		Art.box(station, Vector3(-2.6 - i * 1.1, 0.12, -0.5), Vector3(0.35, 0.24, 0.65), rust)
	var torn := Art.cylinder(station, Vector3(-1.3, 1.1, -0.65), 0.21, 0.21, 1.2, metal, 12)
	torn.rotation.z = -0.65
	for i in range(6): _grass(station, Vector3(1 + i * 0.18, 0.02, 1.8 + sin(i) * 0.25), 0.4, i)

static func _waystation(parent: Node3D) -> void:
	var pale := Scenery.stone(Color("afa38c"))
	var dark := Scenery.stone(Color("797c70"))
	for side in [-1, 1]:
		for i in range(3):
			var x: float = side * (9.5 + i * 3.1)
			var h := 2.6 if i != 2 else 1.3
			Art.box(parent, Vector3(x, 0.16, -12.0), Vector3(1.55, 0.32, 1.6), dark)
			Art.rock(parent, Vector3(x, h * 0.5, -12.0), Vector3(0.85, h, 0.95), pale, 500 + i)
			Art.box(parent, Vector3(x, h, -12.0), Vector3(1.25, 0.3, 1.25), pale)
			if i == 0:
				var lintel := Art.rock(parent, Vector3(x + side * 1.4, h + 0.2, -12.0), Vector3(3.9, 0.48, 1.1), pale, 540 + side)
				lintel.rotation.z = side * 0.04
		Art.rock(parent, Vector3(side * 14.8, 0.18, -11.5), Vector3(1.2, 0.4, 1.2), pale, 560 + side)
