extends RefCounted
## Original environment study. Large scenery stays outside the playable bounds.
const Art = preload("res://scripts/shapes.gd")

static func stone(color: Color) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/sandstone.gdshader")
	material.set_shader_parameter("stone_color", color)
	return material

static func build(parent: Node3D) -> void:
	var sandstone := stone(Color("a17d62"))
	var pale := stone(Color("b5a489"))
	var dark := stone(Color("766454"))
	var rng := RandomNumberGenerator.new()
	rng.seed = 19921994
	# A continuous landscape beyond the navigable basin, with overlapping mesas.
	for i in range(14):
		var x := -37.0 + i * 5.5
		if absf(x) < 7: continue
		var z := rng.randf_range(-23, -21)
		var height := rng.randf_range(5.5, 9.5)
		Art.rock(parent, Vector3(x, height * 0.38, z), Vector3(10, height, 10), sandstone, 200 + i)
		Art.rock(parent, Vector3(x + 1, height * 0.75, z - 2), Vector3(8, height * 0.55, 8), pale, 240 + i)
		Art.rock(parent, Vector3(x - 1.2, 0.8, z + 4.5), Vector3(6, 2.8, 5), dark, 270 + i)
		for tier in range(3):
			var ledge := Art.rock(parent, Vector3(x + sin(i + tier) * 0.7, height * (0.22 + tier * 0.22), z + 0.5), Vector3(10.0 - tier * 0.7, 0.45, 8.8 - tier * 0.6), sandstone, 810 + i * 3 + tier)
			ledge.rotation.z = sin(i) * 0.035
	for side in [-1, 1]:
		for i in range(6):
			var z := -15.0 + i * 6.0
			var height := rng.randf_range(3.2, 6.5)
			Art.rock(parent, Vector3(side * rng.randf_range(27, 29), height * 0.35, z), Vector3(8, height, 8), sandstone, 300 + i + (side + 1) * 20)
			Art.rock(parent, Vector3(side * 23.5, 0.4, z + 2), Vector3(3.5, 1.8, 3.6), pale, 340 + i)
	_build_road(parent, pale, dark, rng)
	_build_temple(parent, pale, dark)
	# Pebbles and small plants reinforce existing rock silhouettes, not paths.
	for obstacle in [Vector3(-8, 0, -6), Vector3(8, 0, 6), Vector3(-12, 0, 7), Vector3(12, 0, -7)]:
		for i in range(6):
			var angle := i * TAU / 6
			var p: Vector3 = obstacle + Vector3(cos(angle), 0, sin(angle)) * 1.3
			Art.rock(parent, p + Vector3.UP * 0.12, Vector3(0.42, 0.32, 0.5), pale, i * 7)
		plant(parent, obstacle + Vector3(0.8, 0, 0.5), 0.9, int(absf(obstacle.x)))
	for i in range(42):
		var x := rng.randf_range(-24, 24)
		var z := rng.randf_range(14.9, 19.5) * (-1 if i % 2 == 0 else 1)
		if absf(x) < 6 and z < 0: continue
		plant(parent, Vector3(x, 0, z), rng.randf_range(0.5, 1.25), i)
	for i in range(60):
		var p := Vector3(rng.randf_range(-21, 21), 0.03, rng.randf_range(-14, 14))
		if p.length() < 6: continue
		Art.rock(parent, p, Vector3(0.12, 0.08, 0.2) * rng.randf_range(0.6, 1.5), dark, i)
	_build_field_equipment(parent)

static func _build_road(parent: Node3D, pale: Material, dark: Material, rng: RandomNumberGenerator) -> void:
	var paving := stone(Color("9e967e"))
	for row in range(23):
		var z := -16.0 + row * 1.45
		for column in range(3):
			if rng.randf() < 0.27 or (absf(z) < 2 and column == 1): continue
			var x := (column - 1) * 1.35 + sin(z * 0.18) * 0.35
			var slab := Art.paving(parent, Vector3(x, -0.04, z), Vector2(rng.randf_range(1.05, 1.3), rng.randf_range(1.1, 1.4)), paving, row * 3 + column)
			slab.rotation.y = rng.randf_range(-0.13, 0.13)
	# Broken surveying marks suggest a modern expedition using an ancient site.
	for side in [-1, 1]:
		for z in [-11.0, 10.5]:
			Art.rock(parent, Vector3(side * 2.3, 0.02, z), Vector3(0.45, 0.18, 1.8), dark, int(absf(z)))
	# A worked foundation appears below the ore; a repeated symbol foreshadows the ending.
	Art.cylinder(parent, Vector3(0, -0.025, 0), 2.1, 2.1, 0.12, pale, 12)
	sigil(parent, Vector3(0.9, 0.045, 1.45), 0.32, false)

static func _build_temple(parent: Node3D, pale: Material, dark: Material) -> void:
	var temple := Node3D.new()
	temple.position = Vector3(0, 0, -18.6)
	parent.add_child(temple)
	var recess := Art.material(Color("292c31"))
	var metal := Art.material(Color("947653"))
	for i in range(5):
		Art.box(temple, Vector3(0, i * 0.12, 2.4 - i * 0.33), Vector3(9.5 - i * 0.3, 0.22, 3.4 - i * 0.3), pale)
	Art.box(temple, Vector3(0, 3.0, 0), Vector3(13, 6.2, 2.3), dark)
	Art.box(temple, Vector3(0, 2.8, 1.23), Vector3(4.1, 4.8, 0.18), recess)
	for side in [-1, 1]:
		# Closed twin doors and a nested tapered frame.
		Art.box(temple, Vector3(side * 0.93, 2.65, 1.4), Vector3(1.82, 4.1, 0.25), dark)
		for i in range(3):
			var x: float = side * (2.4 + i * 1.1)
			var pillar := Art.rock(temple, Vector3(x, 2.7, 1.2 - i * 0.1), Vector3(1.0, 5.7 - i * 0.4, 1.25), pale, 700 + i)
			pillar.rotation.z = side * -0.06
			var rib := Art.box(temple, Vector3(side * (1.25 + i * 0.9), 5.3 - i * 0.15, 1.4), Vector3(0.72, 3.2 + i * 0.2, 0.9), pale)
			rib.rotation.z = side * 0.85
		Art.box(temple, Vector3(side * 5.7, 3.8, 1.35), Vector3(0.15, 2.8, 0.17), metal)
		banner(temple, Vector3(side * 4.9, 3.8, 1.82), Vector2(0.85, 2.6), Color("53365e"))
		Art.rock(temple, Vector3(side * 6.8, 1.7, 0), Vector3(5, 4.5, 6), dark, 780 + side)
	Art.box(temple, Vector3(0, 2.6, 1.57), Vector3(0.045, 3.9, 0.04), Art.material(Color("8c78ac"), 0.3))
	sigil(temple, Vector3(0, 4.6, 1.9), 0.7, true)
	# Short carved wayside markers stay beyond the navigable north boundary.
	for side in [-1, 1]:
		Art.rock(parent, Vector3(side * 8, 1.1, -15.4), Vector3(1.1, 2.5, 0.85), pale, 791 + side)
		sigil(parent, Vector3(side * 8, 1.4, -14.9), 0.25, true)

static func sigil(parent: Node3D, pos: Vector3, radius: float, vertical: bool) -> void:
	var mark := Node3D.new()
	mark.position = pos
	parent.add_child(mark)
	if vertical: mark.rotation.x = PI / 2
	var bronze := Art.material(Color("a88a57"))
	for i in range(22):
		if i == 5 or i == 6 or i == 16 or i == 17: continue
		var angle := i * TAU / 22
		var stroke := Art.box(mark, Vector3(cos(angle) * radius, 0, sin(angle) * radius), Vector3(radius * 0.29, 0.025, radius * 0.08), bronze)
		stroke.rotation.y = -angle + PI / 2
	Art.box(mark, Vector3.ZERO, Vector3(radius * 0.09, 0.03, radius * 2.5), bronze)

static func banner(parent: Node3D, pos: Vector3, size: Vector2, color: Color) -> void:
	var shape := PlaneMesh.new()
	shape.orientation = PlaneMesh.FACE_Z
	shape.size = size
	shape.subdivide_width = 4
	shape.subdivide_depth = 8
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://shaders/cloth.gdshader")
	mat.set_shader_parameter("cloth_color", color)
	Art.mesh(parent, shape, pos, mat)

static func plant(parent: Node3D, pos: Vector3, height: float, seed_value: int) -> void:
	var leaf_mat := Art.material(Color("427e75") if seed_value % 2 == 0 else Color("627856"))
	leaf_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	for i in range(7):
		var leaf := Art.leaf(parent, pos, height * (0.8 + (i % 3) * 0.15), height * 0.12, leaf_mat)
		leaf.rotation.y = i * TAU / 7 + seed_value
	if seed_value % 3 == 0:
		var stem := Art.material(Color("61734a"))
		var flower := Art.material(Color("dca263"))
		Art.cylinder(parent, pos + Vector3.UP * height * 0.65, 0.035, 0.02, height * 1.3, stem, 5)
		for i in range(3):
			Art.sphere(parent, pos + Vector3(0, height * (1.05 + i * 0.12), 0), Vector3(0.13, 0.18, 0.13), flower)

static func _build_field_equipment(parent: Node3D) -> void:
	var charcoal := Art.material(Color("2e414a"))
	var ivory := Art.material(Color("c2b692"))
	# A torn conduit and survey cases along the safe western approach.
	for i in range(5):
		var pipe := Art.cylinder(parent, Vector3(-20.7, 0.23, 7.5 + i * 1.25), 0.2, 0.2, 1.15, charcoal)
		pipe.rotation.x = PI / 2
	for i in range(2):
		Art.box(parent, Vector3(-20.5, 0.25, 5.2 + i * 0.8), Vector3(0.55, 0.5, 0.6), ivory)
		Art.box(parent, Vector3(-20.2, 0.3, 5.2 + i * 0.8), Vector3(0.025, 0.16, 0.25), Art.material(Color("4183ac")))
