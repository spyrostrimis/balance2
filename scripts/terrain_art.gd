extends RefCounted
## Terrain review 01. All landforms are decorative; no navigation registration.
const Art = preload("res://scripts/shapes.gd")
const CLIFFS = [preload("res://assets/terrain_study/cliff_00.glb"), preload("res://assets/terrain_study/cliff_01.glb"), preload("res://assets/terrain_study/cliff_02.glb")]

static func ground(parent: Node3D) -> void:
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://shaders/terrain_sand.gdshader")
	mat.set_shader_parameter("sand_color", preload("res://assets/terrain_study/sand_albedo.png"))
	mat.set_shader_parameter("sand_normal", preload("res://assets/terrain_study/sand_normal.png"))
	mat.set_shader_parameter("rock_color", preload("res://assets/terrain_study/cliff_albedo.png"))
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for x in range(-56, 56):
		for z in range(-50, 50):
			for offset in [Vector2.ZERO, Vector2(1, 0), Vector2(0, 1), Vector2(1, 0), Vector2.ONE, Vector2(0, 1)]:
				var px: float = x + offset.x
				var pz: float = z + offset.y
				var edge := maxf(absf(px) - 22.0, absf(pz) - 16.0)
				var h := smoothstep(0, 8, edge) * (1.15 + .30 * sin(px * .26 + pz * .18)) - .015
				var compacted := 0.0
				for patch in [Vector4(-10, -4, 7, 4.8), Vector4(10, -5, 7.4, 5.0), Vector4(-9, 8, 6.2, 4.8), Vector4(10, 8.8, 6.5, 4.8), Vector4(0, 0, 7, 5)]:
					var d := Vector2((px - patch.x) / patch.z, (pz - patch.y) / patch.w).length()
					compacted = maxf(compacted, 1.0 - smoothstep(.45, 1.15, d))
				var drift := 1.0 - smoothstep(.6, 2.2, absf(px - (3.8 + sin(pz * .23) * 1.8)))
				compacted *= 1.0 - drift * .68
				var runoff := 1.0 - smoothstep(1.0, 4.1, Vector2((px + 17) * .7, pz + 9.5).length())
				var talus := smoothstep(18.5, 24.0, absf(px))
				talus = maxf(talus, smoothstep(13.8, 20.0, -pz) * smoothstep(6, 11, absf(px)))
				surface.set_color(Color(compacted, runoff, talus, 1))
				surface.set_uv(Vector2(px, pz) / 4)
				surface.add_vertex(Vector3(px, h, pz))
	surface.index()
	surface.generate_normals()
	surface.generate_tangents()
	Art.mesh(parent, surface.commit(), Vector3.ZERO, mat).name = "AuthoredSandBasin"

static func landforms(parent: Node3D) -> void:
	var root := Node3D.new()
	root.name = "TerrainReviewLandforms"
	parent.add_child(root)
	# North buttresses frame, rather than cover, the approved Gate and porticoes.
	_add_cliff(root, Vector3(-3.8, -.18, -29), 2, Vector3(1.08, 1.06, 1.0), -.08)
	_add_cliff(root, Vector3(4.1, -.18, -29.5), 0, Vector3(1.08, 1.18, 1.0), .07)
	for side in [-1, 1]:
		for i in range(4):
			_add_cliff(root, Vector3(side * (13.0 + i * 7.0), -.18, -23.6 - (i % 2) * .8), i + (1 if side > 0 else 0), Vector3(1.02, 1.0 + (i % 3) * .12, 1.0), side * .045)
		for i in range(6):
			_add_cliff(root, Vector3(side * (27.4 + (i % 2) * .5), -.18, -13.8 + i * 6.3), i + 1, Vector3(.91, .82 - i * .055, .95), -side * PI / 2)

static func _add_cliff(parent: Node3D, pos: Vector3, index: int, size: Vector3, angle: float) -> void:
	var cliff: Node3D = CLIFFS[index % CLIFFS.size()].instantiate()
	cliff.position = pos
	cliff.scale = size
	cliff.rotation.y = angle
	parent.add_child(cliff)

static func road(parent: Node3D) -> void:
	var paving := preload("res://assets/terrain_study/paving.glb").instantiate()
	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/terrain_paving.gdshader")
	material.set_shader_parameter("stone_color", preload("res://assets/terrain_study/paving_albedo.png"))
	material.set_shader_parameter("stone_normal", preload("res://assets/terrain_study/paving_normal.png"))
	material.set_shader_parameter("sand_color", preload("res://assets/terrain_study/sand_albedo.png"))
	material.set_shader_parameter("sand_normal", preload("res://assets/terrain_study/sand_normal.png"))
	for child in paving.find_children("*", "MeshInstance3D"):
		child.material_override = material
	paving.name = "BuriedRoadAndCourts"
	parent.add_child(paving)
