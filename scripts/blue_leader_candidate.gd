extends Node3D
## Independent review candidate. Mission CharacterVisual remains unchanged.
const Asset = preload("res://assets/blue_leader_study/blue_leader.glb")
var model: Node3D
var rig: Skeleton3D
var animation_player: AnimationPlayer
var clip := "Idle_Gun"
var muzzle_bone := -1
var muzzle_local := Vector3.ZERO

func _ready() -> void:
	model = Asset.instantiate()
	add_child(model)
	rig = _find_type(model, "Skeleton3D")
	animation_player = _find_type(model, "AnimationPlayer")
	assert(rig != null and animation_player != null)
	var library: AnimationLibrary = animation_player.get_animation_library("").duplicate(true)
	animation_player.remove_animation_library("")
	animation_player.add_animation_library("", library)
	animation_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	for name in animation_player.get_animation_list():
		animation_player.get_animation(name).loop_mode = Animation.LOOP_NONE if name == "Death" else Animation.LOOP_LINEAR
	muzzle_bone = rig.find_bone("Middle1.R")
	muzzle_local = rig.get_bone_global_rest(muzzle_bone).affine_inverse() * Vector3(-0.964, 1.465, 0.149)
	play_clip("Idle_Gun", 0)
	advance_animation(0)

func play_clip(name: String, blend: float = 0.16) -> void:
	assert(animation_player.has_animation(name), "Missing candidate clip: " + name)
	clip = name
	animation_player.play(name, blend)

func advance_animation(delta: float) -> void:
	animation_player.advance(delta)

func muzzle_position() -> Vector3:
	return rig.to_global(rig.get_bone_global_pose(muzzle_bone) * muzzle_local)

static func _find_type(node: Node, type_name: String) -> Node:
	if node.is_class(type_name): return node
	for child in node.get_children():
		var result := _find_type(child, type_name)
		if result: return result
	return null
