extends RefCounted
## Original procedural prototype art; no third-party asset dependencies.

static func material(color: Color, glow: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.88
	if glow > 0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = glow
	return mat

static func mesh(parent: Node3D, shape: Mesh, pos: Vector3, mat: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = shape
	instance.position = pos
	instance.material_override = mat
	parent.add_child(instance)
	return instance

static func box(parent: Node3D, pos: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
	var shape := BoxMesh.new()
	shape.size = size
	return mesh(parent, shape, pos, mat)

static func cylinder(parent: Node3D, pos: Vector3, bottom: float, top: float, height: float, mat: Material, sides: int = 8) -> MeshInstance3D:
	var shape := CylinderMesh.new()
	shape.bottom_radius = bottom
	shape.top_radius = top
	shape.height = height
	shape.radial_segments = sides
	return mesh(parent, shape, pos, mat)

static func ring(parent: Node3D, radius: float, color: Color, thickness: float = 0.035) -> MeshInstance3D:
	var shape := TorusMesh.new()
	shape.inner_radius = radius - thickness
	shape.outer_radius = radius + thickness
	shape.rings = 64
	shape.ring_segments = 6
	var mat := material(color)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return mesh(parent, shape, Vector3(0, 0.055, 0), mat)

static func rock(parent: Node3D, pos: Vector3, size: Vector3, mat: Material, seed_value: int = 1) -> MeshInstance3D:
	# Irregular beveled strata, shared by small boulders and distant mesa walls.
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)
	var sides := 9
	var rings: Array[PackedVector3Array] = []
	var radii := [0.78, 1.0, 0.93, 0.66]
	var heights := [-0.48, -0.26, 0.27, 0.5]
	var offsets: Array[float] = []
	for i in range(sides): offsets.append(rng.randf_range(0.82, 1.15))
	for tier in range(4):
		var points := PackedVector3Array()
		for i in range(sides):
			var angle := i * TAU / sides
			points.append(Vector3(cos(angle) * radii[tier] * offsets[i] * size.x * 0.5,
				(heights[tier] + rng.randf_range(-0.04, 0.04)) * size.y,
				sin(angle) * radii[tier] * offsets[i] * size.z * 0.5))
		rings.append(points)
	for tier in range(3):
		for i in range(sides):
			var j := (i + 1) % sides
			_triangle(st, rings[tier][i], rings[tier + 1][i], rings[tier][j])
			_triangle(st, rings[tier][j], rings[tier + 1][i], rings[tier + 1][j])
	for i in range(sides):
		_triangle(st, Vector3(0, size.y * 0.49, 0), rings[3][(i + 1) % sides], rings[3][i])
	st.generate_normals()
	return mesh(parent, st.commit(), pos, mat)

static func _triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	surface.add_vertex(a)
	surface.add_vertex(c)
	surface.add_vertex(b)

static func leaf(parent: Node3D, pos: Vector3, height: float, width: float, mat: Material) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)
	var base := Vector3.ZERO
	var left := Vector3(-width, height * 0.4, -height * 0.25)
	var right := Vector3(width, height * 0.4, -height * 0.25)
	var ridge := Vector3(0, height * 0.53, -height * 0.18)
	var tip := Vector3(0, height, -height * 0.7)
	_triangle(st, base, ridge, left)
	_triangle(st, base, right, ridge)
	_triangle(st, left, ridge, tip)
	_triangle(st, ridge, right, tip)
	st.generate_normals()
	return mesh(parent, st.commit(), pos, mat)

static func sphere(parent: Node3D, pos: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
	var shape := SphereMesh.new()
	shape.radius = 0.5
	shape.height = 1.0
	shape.radial_segments = 12
	shape.rings = 6
	var result := mesh(parent, shape, pos, mat)
	result.scale = size
	return result

static func paving(parent: Node3D, pos: Vector3, size: Vector2, mat: Material, seed_value: int) -> MeshInstance3D:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)
	var outline := PackedVector2Array([Vector2(-0.38, -0.5), Vector2(0.38, -0.5), Vector2(0.5, -0.38), Vector2(0.5, 0.38), Vector2(0.38, 0.5), Vector2(-0.38, 0.5), Vector2(-0.5, 0.38), Vector2(-0.5, -0.38)])
	var corners := PackedVector3Array()
	for point in outline:
		corners.append(Vector3((point.x + rng.randf_range(-0.025, 0.025)) * size.x, 0.06, (point.y + rng.randf_range(-0.025, 0.025)) * size.y))
	for i in range(corners.size()):
		var next := (i + 1) % corners.size()
		_triangle(st, Vector3(0, 0.06, 0), corners[next], corners[i])
	st.generate_normals()
	return mesh(parent, st.commit(), pos, mat)
