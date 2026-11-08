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
