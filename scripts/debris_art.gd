extends RefCounted
## Separate ground-detail candidate. Cosmetic only; no collision or new footprints.
const KITS := {
	"ruin_fall": preload("res://assets/debris_study/ruin_fall.glb"),
	"cliff_spall": preload("res://assets/debris_study/cliff_spall.glb"),
	"dead_bough": preload("res://assets/debris_study/dead_bough.glb"),
	"exposed_root": preload("res://assets/debris_study/exposed_root.glb"),
	"wreckage": preload("res://assets/debris_study/wreckage.glb"),
	"paving_spall": preload("res://assets/debris_study/paving_spall.glb")
}

static func ground_height(p: Vector3) -> float:
	var edge := maxf(absf(p.x) - 22.0, absf(p.z) - 16.0)
	return smoothstep(0, 8, edge) * (1.15 + .30 * sin(p.x * .26 + p.z * .18)) - .015

static func place(parent: Node3D, key: String, p: Vector3, angle: float = 0, size: float = 1) -> Node3D:
	var node: Node3D = KITS[key].instantiate()
	node.name = "Debris_" + key
	node.position = p
	node.rotation.y = angle
	node.scale = Vector3.ONE * size
	node.set_meta("debris_candidate", true)
	node.set_meta("debris_kit", key)
	parent.add_child(node)
	return node

static func build(parent: Node3D) -> void:
	var group := Node3D.new()
	group.name = "DebrisCandidate"
	parent.add_child(group)
	# No extra rubble rings around the accepted sandstone/cistern/pier meshes.
	# These are selected negative spaces between structures and the cliff toes.
	for item in [
		["ruin_fall", Vector3(-12.4, 0, -16.5), -.32, 1.0],
		["ruin_fall", Vector3(12.9, 0, -16.8), 2.0, .85],
		["ruin_fall", Vector3(22.9, 0, 5.0), 1.3, .82],
		["cliff_spall", Vector3(-23.0, 0, .5), 1.5, 1.0],
		["cliff_spall", Vector3(23.2, 0, -5.1), -1.2, 1.1],
		["cliff_spall", Vector3(-23.1, 0, 12.3), 1.0, .8],
		["cliff_spall", Vector3(18.8, 0, -16.9), .4, .9],
		["dead_bough", Vector3(-22.8, 0, 4.1), 1.3, .9],
		["dead_bough", Vector3(22.9, 0, 11.9), -.7, 1.1],
		["dead_bough", Vector3(-18.6, 0, -16.3), .4, .8],
		["wreckage", Vector3(23.1, 0, -1.8), 1.4, 1.0],
		["wreckage", Vector3(-22.7, 0, 9.0), -1.3, .8]
	]:
		var p: Vector3 = item[1]
		p.y = ground_height(p)
		place(group, item[0], p, item[2], item[3])
		contact(group, p, Vector2(1.65, 1.05) * float(item[3]), float(item[2]), false)
	# Short ridges under the existing trunks stay inside their registered 1.2m discs.
	for p in preload("res://scripts/basin_details.gd").TREE_POSITIONS:
		place(group, "exposed_root", p, p.x * .41, 1)
		contact(group, p, Vector2(1.08, .85), p.x * .41, false)
	# Hand-selected court edges; nothing inside the central capture circle.
	for item in [Vector3(-13.8, 0, -3.1), Vector3(-7.0, 0, -7.3), Vector3(14.4, 0, -4.6), Vector3(7.7, 0, -8.0), Vector3(-12.6, 0, 9.9), Vector3(-6.9, 0, 11.0), Vector3(14.1, 0, 9.6), Vector3(7.4, 0, 11.7)]:
		var angle: float = item.x * .7
		place(group, "paving_spall", item, angle)
		contact(group, item + Vector3(.35, 0, .2), Vector2(1.45, .65), angle, true)
	# Slender wind tongues across road margins, with no new raised paving or blocks.
	for item in [Vector3(-1.65, 0, -11.8), Vector3(1.55, 0, -8.2), Vector3(-1.55, 0, 8.3), Vector3(1.65, 0, 12.0)]:
		contact(group, item, Vector2(.85, 1.5), -.48, true)

static func contact(parent: Node3D, center: Vector3, radius: Vector2, angle: float, paving: bool) -> void:
	# A tapered sand skin with explicit boundary and opacity, not a collision mound.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count := 28
	for ring in range(3):
		var inner := float(ring) / 3.0
		var outer := float(ring + 1) / 3.0
		for i in range(count):
			for corner in [Vector2(inner, i), Vector2(outer, i + 1), Vector2(outer, i), Vector2(inner, i), Vector2(inner, i + 1), Vector2(outer, i + 1)]:
				var a: float = corner.y * TAU / count
				var r: float = corner.x
				var variation := 1.0 + .12 * sin(a * 3 + angle) + .06 * cos(a * 5)
				var local := Vector2(cos(a) * radius.x, sin(a) * radius.y) * r * variation
				local = local.rotated(angle)
				var p := center + Vector3(local.x, 0, local.y)
				var rise := .063 + .004 * (1 - r) if paving else .020 + .105 * pow(1.0 - r, 1.5)
				p.y = ground_height(p) + rise
				st.set_color(Color(1, 1, 1, (1.0 - smoothstep(.35, 1.0, r)) * (.92 if paving else .7)))
				st.set_uv(Vector2(p.x, p.z) / 4)
				st.add_vertex(p)
	st.index()
	st.generate_normals()
	st.generate_tangents()
	var mesh := MeshInstance3D.new()
	mesh.name = "SandContact"
	mesh.mesh = st.commit()
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://shaders/debris_sand.gdshader")
	mat.set_shader_parameter("sand_color", preload("res://assets/terrain_study/sand_albedo.png"))
	mat.set_shader_parameter("sand_normal", preload("res://assets/terrain_study/sand_normal.png"))
	mat.set_shader_parameter("rock_color", preload("res://assets/terrain_study/cliff_albedo.png"))
	mesh.material_override = mat
	mesh.set_meta("debris_transition", true)
	parent.add_child(mesh)
