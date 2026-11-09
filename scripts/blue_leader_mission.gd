extends RefCounted
## Approved interim integration: revision 02 bust on the existing animated body.
## Preserve the reviewed face and materials; head follows Head, armor follows Chest.
const Bust = preload("res://assets/blue_leader_study/v2/leader_bust.glb")

static func attach(rig: Skeleton3D) -> void:
	# Replace the central chest/collar, retaining the source's skinned limbs
	# and waist underneath the new rigid armor. Never alter the imported mesh.
	var body: MeshInstance3D = rig.get_node("SpaceSuit_Body")
	var retained := ArrayMesh.new()
	for surface in range(body.mesh.get_surface_count()):
		var arrays := body.mesh.surface_get_arrays(surface)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		var keep := PackedInt32Array()
		for triangle in range(0, indices.size(), 3):
			var center := (vertices[indices[triangle]] + vertices[indices[triangle + 1]] + vertices[indices[triangle + 2]]) / 3.0
			if center.y > 1.19 and absf(center.x) < 0.23: continue
			keep.append_array(indices.slice(triangle, triangle + 3))
		if keep.is_empty(): continue
		arrays[Mesh.ARRAY_INDEX] = keep
		retained.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		retained.surface_set_material(retained.get_surface_count() - 1, body.get_active_material(surface))
	body.mesh = retained
	for surface in range(retained.get_surface_count()): body.set_surface_override_material(surface, null)
	var source := Bust.instantiate()
	rig.add_child(source)
	var fit := Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * 1.12), Vector3(0, -0.075, 0))
	for mesh: MeshInstance3D in source.find_children("*", "MeshInstance3D", true, false):
		var bone_name := "Head" if str(mesh.name).begins_with("Leader_") else "Chest"
		var bone := rig.find_bone(bone_name)
		var attachment := BoneAttachment3D.new()
		attachment.name = "LeaderV2_" + str(mesh.name)
		attachment.bone_name = bone_name
		rig.add_child(attachment)
		var part := MeshInstance3D.new()
		part.name = mesh.name
		part.mesh = mesh.mesh
		part.transform = rig.get_bone_global_rest(bone).affine_inverse() * fit * (source.global_transform.affine_inverse() * mesh.global_transform)
		attachment.add_child(part)
		if "Hair" in str(mesh.name) or "Eyebrows" in str(mesh.name) or "Eyelashes" in str(mesh.name):
			for slot in range(part.mesh.get_surface_count()):
				var material: StandardMaterial3D = part.mesh.surface_get_material(slot).duplicate()
				material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
				material.alpha_scissor_threshold = 0.35
				material.alpha_antialiasing_mode = BaseMaterial3D.ALPHA_ANTIALIASING_ALPHA_TO_COVERAGE
				material.alpha_antialiasing_edge = 0.2
				material.cull_mode = BaseMaterial3D.CULL_DISABLED
				if "Hair" in str(mesh.name):
					material.albedo_color = Color(0.25, 0.22, 0.20)
					material.alpha_scissor_threshold = 0.25
				part.set_surface_override_material(slot, material)
	source.free()
