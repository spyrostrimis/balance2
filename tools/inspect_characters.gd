extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	for file in ["Spacesuit", "Swat", "Adventurer"]:
		var character: Node = load("res://assets/third_party/quaternius/modular_men/%s.gltf" % file).instantiate()
		root.add_child(character)
		print("CHARACTER ", file)
		inspect(character)
		character.free()
	quit()

func inspect(node: Node) -> void:
	if node is MeshInstance3D:
		print("MESH ", node.get_path(), " aabb=", node.get_aabb(), " transform=", node.transform, " skeleton=", node.skeleton)
	if node is AnimationPlayer:
		print("ANIMATIONS ", node.get_path(), " ", node.get_animation_list())
	if node is Skeleton3D:
		for i in range(node.get_bone_count()):
			if node.get_bone_name(i) in ["Head", "Chest", "Wrist.R", "Wrist.L"]:
				print("BONE ", node.get_path(), " ", i, " ", node.get_bone_name(i), " ", node.get_bone_global_rest(i))
	for child in node.get_children(): inspect(child)
