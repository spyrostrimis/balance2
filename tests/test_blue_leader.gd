extends SceneTree
## Verify the exported candidate, not Blender-only source data.
const Candidate = preload("res://scripts/blue_leader_candidate.gd")
var failures: Array[String] = []

func check(condition: bool, message: String) -> void:
	if not condition: failures.append(message)

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var candidate := Candidate.new()
	root.add_child(candidate)
	await process_frame
	check(candidate.rig.get_bone_count() == 62, "Source rig must retain 62 bones")
	var meshes := candidate.model.find_children("*", "MeshInstance3D", true, false)
	var vertex_count := 0
	for mesh: MeshInstance3D in meshes:
		check(mesh.skin != null, "%s has no skin" % mesh.name)
		for surface in range(mesh.mesh.get_surface_count()):
			var arrays := mesh.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
			var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
			vertex_count += vertices.size()
			check(weights.size() == vertices.size() * 4, "%s must export four skin slots per vertex" % mesh.name)
			for i in range(vertices.size()):
				var total := 0.0
				for j in range(4):
					var weight := weights[i * 4 + j]
					total += weight
					check(weight >= 0 and is_finite(weight), "%s invalid weight" % mesh.name)
					check(bones[i * 4 + j] < mesh.skin.get_bind_count(), "%s invalid skin bind" % mesh.name)
				check(absf(total - 1.0) < 0.002, "%s unweighted or unnormalized vertex" % mesh.name)
	var muzzle_samples: Array[Vector3] = []
	for clip in ["Idle_Gun", "Run", "Idle_Gun_Pointing", "Idle_Gun_Shoot", "Death", "Interact"]:
		check(candidate.animation_player.has_animation(clip), "Missing clip: " + clip)
		candidate.play_clip(clip, 0)
		var duration: float = candidate.animation_player.get_animation(clip).length
		for fraction in [0.0, 0.25, 0.5, 0.9]:
			candidate.animation_player.seek(duration * fraction, true)
			candidate.advance_animation(0)
			var muzzle: Vector3 = candidate.muzzle_position()
			check(muzzle.is_finite() and muzzle.length() < 4, "Invalid muzzle during " + clip)
			muzzle_samples.append(muzzle)
			for bone in range(candidate.rig.get_bone_count()):
				var pose: Transform3D = candidate.rig.get_bone_global_pose(bone)
				check(pose.is_finite() and pose.origin.length() < 4, "Invalid bone during " + clip)
		print("VERIFIED CLIP ", clip, " duration=", duration)
	check(muzzle_samples[0].distance_to(muzzle_samples[10]) > 0.25, "Aim must move the hand-mounted muzzle")
	print("VERIFIED LEADER: ", meshes.size(), " skinned meshes; ", vertex_count, " vertices; 62 bones; 6 clips / 24 poses")
	candidate.queue_free()
	await process_frame
	for failure in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)
