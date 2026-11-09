extends "res://scripts/korali_study.gd"
## Actual skinned geometry review. No mission substitution or new gameplay.
const Candidate = preload("res://scripts/blue_leader_candidate.gd")
var character: Node3D
var paused := false
var portrait := false
var animation_caption: Label
var clip_buttons: Array[Button] = []
const CLIPS := ["Idle_Gun", "Run", "Idle_Gun_Pointing", "Idle_Gun_Shoot", "Death", "Interact"]
const CLIP_LABELS := ["Idle", "Run", "Aim", "Fire", "Fall", "Interact"]

func _ready() -> void:
	study_title = "B L U E   L E A D E R   /   0 1"
	new_label = "Woman leader · original geometry · shared animation rig"
	old_label = "Current mission placeholder"
	close_size = 2.8
	close_focus = 1.0
	super._ready()
	environment.ssao_radius = 0.12
	environment.ssao_intensity = 1.0
	# A small character needs a short shadow range and a less noisy light source
	# than the shared environment-asset stage.
	sunlight.directional_shadow_max_distance = 18.0
	sunlight.light_angular_distance = 0.25
	sunlight.shadow_bias = 0.04
	sunlight.shadow_normal_bias = 0.5
	sunlight.light_energy = 0.95
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-20, 145, 0)
	fill.light_color = Color("b7cfdf")
	fill.light_energy = 0.45
	add_child(fill)
	if "--capture-leader" in OS.get_cmdline_user_args():
		_capture_review.call_deferred()

func _create_study() -> Node3D:
	character = Candidate.new()
	return character

func _create_previous() -> void:
	var old := preload("res://scripts/character_visual.gd").new()
	old.style = "blue_leader"
	old.rotation.y = PI
	previous.add_child(old)

func _build_ui() -> void:
	super._build_ui()
	var layer := CanvasLayer.new()
	add_child(layer)
	var column := VBoxContainer.new()
	column.position = Vector2(30, 110)
	layer.add_child(column)
	animation_caption = Label.new()
	animation_caption.text = "REJECTED STUDY 01 · Retained for comparison · New anatomy study: BlueLeaderFaceStudy.bat"
	column.add_child(animation_caption)
	var row := HBoxContainer.new()
	column.add_child(row)
	for i in range(CLIPS.size()):
		var button := Button.new()
		button.text = CLIP_LABELS[i]
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_play.bind(CLIPS[i]))
		row.add_child(button)
		clip_buttons.append(button)
	for item in [["P  Portrait", _portrait], ["A  Pause", _pause]]:
		var button := Button.new()
		button.text = item[0]
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(item[1])
		row.add_child(button)

func _play(name: String) -> void:
	character.play_clip(name)
	paused = false
	animation_caption.text = "Clip: %s · Bone-skinned hair and cloth · Facial animation deferred" % name

func _pause() -> void:
	paused = not paused

func set_distance(mode: int) -> void:
	portrait = false
	distance_mode = mode
	camera.size = [close_size, 18.0, 36.0][mode]
	var target := Vector3(0, close_focus if mode == 0 else 0.0, 0)
	camera.position = target + (Vector3(0.6, 0.25, 7) if mode == 0 else Vector3(0, 33, 26))
	camera.look_at(target)
	_update_caption()

func _portrait() -> void:
	portrait = true
	camera.size = 0.78
	var target := Vector3(0, 1.60, 0)
	camera.position = target + Vector3(0.35, 0.08, 4)
	camera.look_at(target)
	caption.text = "Portrait · Modeled face, eyes, lids, hair and garment folds"

func _process(delta: float) -> void:
	super._process(delta)
	if not paused and is_instance_valid(character):
		character.advance_animation(delta)
		for old in previous.get_children(): old.advance_animation(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.size = maxf(0.45, camera.size * 0.9)
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.size = minf(45, camera.size / 0.9)
			return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_P: _portrait()
		if event.keycode == KEY_A: _pause()
	super._unhandled_input(event)

func _capture_review() -> void:
	paused = true
	var frames := [
		["front", "Idle_Gun", 0.35, 0.0, 0],
		["portrait", "Idle_Gun", 0.35, 0.0, -1],
		["back", "Idle_Gun", 0.35, PI, 0],
		["run", "Run", 0.25, 0.45, 0],
		["aim", "Idle_Gun_Pointing", 0.4, -0.45, 0],
		["fire", "Idle_Gun_Shoot", 0.15, 0.0, 0],
		["fall", "Death", 1.04, 0.0, 0],
		["rts", "Idle_Gun", 0.35, 0.0, 1],
		["mission", "Idle_Gun", 0.35, 0.0, 2]]
	for frame in frames:
		character.play_clip(frame[1], 0)
		character.animation_player.seek(frame[2], true)
		character.advance_animation(0)
		pivot.rotation.y = frame[3]
		if frame[4] == -1: _portrait()
		else: set_distance(frame[4])
		await get_tree().create_timer(0.6).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://artifacts/blue_leader/" + frame[0] + ".png")
		print("LEADER CAPTURE ", frame[0], " muzzle=", character.muzzle_position())
	get_tree().quit()
