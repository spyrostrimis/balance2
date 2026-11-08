extends Node3D
## Reviewable CC0 character assembly. Source meshes remain unchanged on disk.
## All three source files share the same 62-bone skeleton and bind order.
const SpaceSuit = preload("res://assets/third_party/quaternius/modular_men/Spacesuit.gltf")
const Swat = preload("res://assets/third_party/quaternius/modular_men/Swat.gltf")
const Adventurer = preload("res://assets/third_party/quaternius/modular_men/Adventurer.gltf")
const Art = preload("res://scripts/shapes.gd")
var style := "blue_leader"
var rig: Skeleton3D
var animation_player: AnimationPlayer
var model: Node3D
var clip := "Idle_Gun"

func _ready() -> void:
	model = (Swat if style == "blue_trooper" else SpaceSuit).instantiate()
	add_child(model)
	# Imported characters face +Z; game units use -Z.
	model.rotation.y = PI
	rig = find_type(model, "Skeleton3D")
	animation_player = find_type(model, "AnimationPlayer")
	if style != "blue_trooper":
		model.find_child("SpaceSuit_Head", true, false).hide()
		var donor := Adventurer.instantiate()
		_copy_part(donor, "Adventurer_Head")
		donor.free()
		var weapon_donor := Swat.instantiate()
		_copy_part(weapon_donor, "Pistol")
		weapon_donor.free()
		var mantle := BoneAttachment3D.new()
		mantle.bone_name = "Chest"
		rig.add_child(mantle)
		_build_mantle(mantle)
	_recolor(model)
	_add_faction_equipment()
	# Local libraries prevent loop settings from mutating imported shared assets.
	var library: AnimationLibrary = animation_player.get_animation_library("").duplicate(true)
	animation_player.remove_animation_library("")
	animation_player.add_animation_library("", library)
	animation_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	for name in animation_player.get_animation_list():
		animation_player.get_animation(name).loop_mode = Animation.LOOP_LINEAR if name != "Death" else Animation.LOOP_NONE
	play_clip("Idle_Gun")
	animation_player.advance(0)

func _add_faction_equipment() -> void:
	if style == "blue_trooper": return
	var harness := BoneAttachment3D.new()
	harness.bone_name = "Chest"
	rig.add_child(harness)
	if style == "blue_leader":
		var ivory := Art.material(Color("bdb093"))
		var strap := Art.box(harness, Vector3(-0.09, -0.08, 0.13), Vector3(0.065, 0.37, 0.022), ivory)
		strap.rotation.z = -0.32
		Art.box(harness, Vector3(-0.13, -0.14, 0.15), Vector3(0.11, 0.1, 0.035), Art.material(Color("344851")))
		var medical := Art.material(Color("73cfca"), 0.15)
		Art.box(harness, Vector3(-0.13, -0.14, 0.173), Vector3(0.018, 0.063, 0.01), medical)
		Art.box(harness, Vector3(-0.13, -0.14, 0.173), Vector3(0.06, 0.018, 0.01), medical)
	else:
		model.scale = Vector3(1.08, 1.025, 1.08)
		var armor := Art.material(Color("76333c"))
		var copper := Art.material(Color("97745c"))
		for side in [-1, 1]:
			var plate := Art.rock(harness, Vector3(side * 0.235, 0.1, 0.005), Vector3(0.26, 0.15, 0.29), armor, 73 + side)
			plate.rotation.z = side * -0.2
			Art.box(harness, Vector3(side * 0.235, 0.065, 0.13), Vector3(0.21, 0.025, 0.018), copper)

func _copy_part(donor: Node, part_name: String) -> void:
	var source: MeshInstance3D = donor.find_child(part_name, true, false)
	assert(source != null, "Missing modular part: " + part_name)
	var part := MeshInstance3D.new()
	part.name = part_name
	part.mesh = source.mesh
	part.skin = source.skin
	part.transform = source.transform
	part.skeleton = NodePath("..")
	rig.add_child(part)

func _recolor(node: Node) -> void:
	var primary := Color("245c8d") if style != "red_leader" else Color("8d3039")
	var secondary := Color("bfb498") if style != "red_leader" else Color("353d45")
	var trim := Color("9e8155") if style != "red_leader" else Color("a56e52")
	if node is MeshInstance3D and node.mesh:
		for i in range(node.mesh.get_surface_count()):
			var source: Material = node.mesh.surface_get_material(i)
			if not source is StandardMaterial3D: continue
			var material: StandardMaterial3D = source.duplicate()
			material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
			material.roughness = 0.72
			match source.resource_name:
				"Swat", "SciFi_Light": material.albedo_color = primary
				"SciFi_Main": material.albedo_color = Color("35434c") if style != "red_leader" else secondary
				"SciFi_Light_Accent":
					material.albedo_color = trim
					material.metallic = 0.45
					material.roughness = 0.48
				"SciFi_MainDark", "Swat_Black", "Black": material.albedo_color = Color("202b34")
				"Skin": material.albedo_color = Color("bc8b6c") if style != "red_leader" else Color("a5795c")
				"Hair", "Eyebrows": material.albedo_color = Color("342d28") if style != "red_leader" else Color("635a51")
				"Visor":
					material.albedo_color = Color("587c8d")
					material.metallic = 0.3
					material.roughness = 0.35
			node.set_surface_override_material(i, material)
	for child in node.get_children(): _recolor(child)

func _build_mantle(parent: Node3D) -> void:
	var mesh := SurfaceTool.new()
	mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in range(8):
		for column in range(6):
			var a := Vector2(column / 6.0, row / 8.0)
			var b := Vector2((column + 1) / 6.0, row / 8.0)
			var c := Vector2(column / 6.0, (row + 1) / 8.0)
			var d := Vector2((column + 1) / 6.0, (row + 1) / 8.0)
			for uv in [a, c, b, b, c, d]:
				var x: float = (uv.x - 0.5) * lerpf(0.38, 0.54, uv.y)
				var y: float = 0.15 - uv.y * (0.81 + uv.x * 0.12)
				var z: float = -0.17 - uv.y * 0.14 - cos(uv.x * PI * 6) * uv.y * 0.022
				mesh.set_uv(Vector2(uv.x, 1 - uv.y))
				mesh.add_vertex(Vector3(x, y, z))
	mesh.generate_normals()
	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/cloth.gdshader")
	material.set_shader_parameter("cloth_color", Color("c7b792") if style == "blue_leader" else Color("642631"))
	var instance := MeshInstance3D.new()
	instance.mesh = mesh.commit()
	instance.material_override = material
	parent.add_child(instance)

func play_clip(name: String) -> void:
	if not animation_player.has_animation(name): return
	clip = name
	animation_player.play(name, 0.16)

func advance_animation(delta: float) -> void:
	animation_player.advance(delta)

static func find_type(node: Node, type_name: String) -> Node:
	if node.is_class(type_name): return node
	for child in node.get_children():
		var result := find_type(child, type_name)
		if result: return result
	return null
