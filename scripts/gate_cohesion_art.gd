extends RefCounted
## Gate cohesion 01 review candidate: revised Gate, fractured flankers matching
## the Terrain 01 cliffs, worked wayside markers, sand drifts and contact
## occlusion. Cosmetic only; no colliders, footprints or walkable intrusion.
const Scenery = preload("res://scripts/scenery.gd")
const Debris = preload("res://scripts/debris_art.gd")
const GATE_POSITION := Vector3(0, 0, -18.6)
const GATE_SCALE := 0.78
const WALKABLE_EDGE := -14.0 # Drifts stay north of the playable boundary.

static func build(root: Node3D) -> Node3D:
	var parent := Node3D.new()
	parent.name = "GateCluster_candidate"
	root.add_child(parent)
	var gate := preload("res://assets/gate_cohesion/sanctuary_gate.glb").instantiate()
	gate.name = "SanctuaryGate"
	gate.position = GATE_POSITION
	gate.scale = Vector3.ONE * GATE_SCALE
	parent.add_child(gate)
	for side in [-1, 1]:
		var key := "left" if side < 0 else "right"
		# Same anchors as the prototype flankers/markers; bases sit into the sand.
		# The ground rises toward the cliffs; seat the fractured base below its
		# lowest (front) contact so no edge floats, burying the back naturally.
		var flank_at := Vector3(side * 9.4, 0, -19.5)
		flank_at.y = Debris.ground_height(Vector3(side * 9.4, 0, -17.0)) - .16
		_place(parent, load("res://assets/gate_cohesion/flanker_%s.glb" % key), flank_at, "GateFlanker")
		var marker_at := Vector3(side * 8, -.04, -15.4)
		_place(parent, load("res://assets/gate_cohesion/marker_%s.glb" % key), marker_at, "GateMarker")
		Scenery.sigil(parent, Vector3(side * 8, 1.4, -14.9), 0.25, true)
	_grounding(parent)
	return parent

static func _place(parent: Node3D, scene: PackedScene, at: Vector3, label: String) -> Node3D:
	var node: Node3D = scene.instantiate()
	node.name = label
	node.position = at
	parent.add_child(node)
	return node

static func _grounding(parent: Node3D) -> void:
	var group := Node3D.new()
	group.name = "GateGrounding"
	parent.add_child(group)
	# Wind-blown sand ramps against the risers and plinths. Their crests vary,
	# so the stone/sand contact is an uneven line rather than a ruled edge.
	# Front reach is capped so no sand enters walkable z > -14.
	_drift(group, Vector3(-2.95, 0, -14.80), Vector3(2.95, 0, -14.80), Vector3(0, 0, 1), .66, .28, 11)
	for side in [-1, 1]:
		_drift(group, Vector3(side * 2.86, 0, -14.70), Vector3(side * 2.86, 0, -17.3), Vector3(side, 0, 0), .95, .36, 23 + side)
		_drift(group, Vector3(side * 3.0, 0, -17.95), Vector3(side * 7.3, 0, -17.95), Vector3(0, 0, 1), .85, .26, 37 + side)
		# Flankers and markers: sand lapping the fractured toe and worked base.
		Debris.contact(group, Vector3(side * 9.25, 0, -17.55), Vector2(1.6, .70), side * .1, false)
		Debris.contact(group, Vector3(side * 8.0, 0, -14.98), Vector2(.66, .30), 0, false)
		_ring(group, Vector3(side * 8.0, 0, -15.4), Vector2(.50, .36), .32)
	# Contact occlusion: thin ambient darkening exactly at stone/sand contact.
	_strip(group, Vector3(-2.82, 0, -14.80), Vector3(2.82, 0, -14.80), Vector3(0, 0, 1), .30)
	for side in [-1, 1]:
		_strip(group, Vector3(side * 2.84, 0, -14.80), Vector3(side * 2.84, 0, -17.1), Vector3(side, 0, 0), .26)
		_strip(group, Vector3(side * 3.05, 0, -17.92), Vector3(side * 7.15, 0, -17.92), Vector3(0, 0, 1), .30)

static func _drift(parent: Node3D, a: Vector3, b: Vector3, outward: Vector3, depth: float, crest: float, seed_value: int) -> void:
	# A sand ramp leaning on a wall: starts inside the stone, peaks at the face
	# and feathers into the terrain. Uses the accepted debris sand material.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var along := 36
	var across := 7
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var phase := rng.randf() * TAU
	var length := a.distance_to(b)
	for i in range(along):
		for j in range(across):
			for corner in [Vector2(i, j), Vector2(i + 1, j + 1), Vector2(i, j + 1), Vector2(i, j), Vector2(i + 1, j), Vector2(i + 1, j + 1)]:
				var t: float = corner.x / along
				var u: float = corner.y / across
				var dist := t * length
				var wave := .55 + .45 * sin(dist * 1.9 + phase) * cos(dist * .73 + phase * .5)
				var ends := smoothstep(0.0, .12, t) * smoothstep(1.0, .88, t)
				var reach := depth * (.75 + .35 * wave) * lerpf(.6, 1.0, ends)
				var s: float = lerpf(-.15, reach, u)
				var rise := crest * wave * ends * pow(clampf(1.0 - maxf(s, 0.0) / reach, 0.0, 1.0), 1.7)
				var p := a.lerp(b, t) + outward * s
				p.y = Debris.ground_height(p) + .006 + rise
				st.set_color(Color(1, 1, 1, (1.0 - smoothstep(.55, 1.0, u)) * smoothstep(0.0, .06, t) * smoothstep(1.0, .94, t)))
				st.set_uv(Vector2(p.x, p.z) / 4)
				st.add_vertex(p)
	st.index()
	st.generate_normals()
	st.generate_tangents()
	var mesh := MeshInstance3D.new()
	mesh.name = "SandDrift"
	mesh.mesh = st.commit()
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://shaders/debris_sand.gdshader")
	mat.set_shader_parameter("sand_color", preload("res://assets/terrain_study/sand_albedo.png"))
	mat.set_shader_parameter("sand_normal", preload("res://assets/terrain_study/sand_normal.png"))
	mat.set_shader_parameter("rock_color", preload("res://assets/terrain_study/cliff_albedo.png"))
	mesh.material_override = mat
	mesh.set_meta("gate_transition", true)
	parent.add_child(mesh)

static func _material(strength: float) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://shaders/contact_occlusion.gdshader")
	mat.set_shader_parameter("strength", strength)
	mat.render_priority = 1 # After the translucent sand skins.
	return mat

static func _finish(parent: Node3D, st: SurfaceTool, label: String, strength: float) -> void:
	var mesh := MeshInstance3D.new()
	mesh.name = label
	mesh.mesh = st.commit()
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.material_override = _material(strength)
	mesh.set_meta("gate_contact", true)
	parent.add_child(mesh)

static func _strip(parent: Node3D, a: Vector3, b: Vector3, outward: Vector3, width: float) -> void:
	# Falls off away from the stone face and tapers at both ends.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var steps := 24
	var inner := -.12 # Starts under the stone so no seam shows at the contact.
	for i in range(steps):
		for corner in [Vector2(i, 0), Vector2(i + 1, 1), Vector2(i, 1), Vector2(i, 0), Vector2(i + 1, 0), Vector2(i + 1, 1)]:
			var t: float = corner.x / steps
			var across: float = lerpf(inner, width, corner.y)
			var p := a.lerp(b, t) + outward * across
			p.y = Debris.ground_height(p) + .014
			var taper := smoothstep(0.0, .08, t) * smoothstep(1.0, .92, t)
			st.set_color(Color(1, 1, 1, (1.0 - corner.y) * taper))
			st.add_vertex(p)
	_finish(parent, st, "ContactOcclusion", .5)

static func _ring(parent: Node3D, center: Vector3, radius: Vector2, width: float) -> void:
	# Filled ellipse: full under the stone, soft falloff beyond its footprint.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count := 36
	for i in range(count):
		for k in range(2):
			var r0: float = [0.0, 1.0][k]
			var r1: float = [1.0, 1.0 + width / radius.x][k]
			for corner in [Vector2(i, r0), Vector2(i + 1, r1), Vector2(i, r1), Vector2(i, r0), Vector2(i + 1, r0), Vector2(i + 1, r1)]:
				var angle: float = corner.x * TAU / count
				var p := center + Vector3(cos(angle) * radius.x * corner.y, 0, sin(angle) * radius.y * corner.y)
				p.y = Debris.ground_height(p) + .014
				st.set_color(Color(1, 1, 1, 1.0 - smoothstep(1.0, 1.0 + width / radius.x, corner.y)))
				st.add_vertex(p)
	_finish(parent, st, "ContactOcclusion", .45)
