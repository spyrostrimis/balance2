extends SceneTree
const Studio = preload("res://scenes/character_studio.tscn")
var studio: Node3D
var failures := 0
var checks := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition: failures += 1
	print("PASS: " if condition else "FAIL: ", description)

func click(button: Button) -> void:
	# Wait for draw-driven UI layout, including immediately after scene changes.
	await process_frame
	await RenderingServer.frame_post_draw
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = button.get_global_rect().get_center()
		root.push_input(event, true)
		await process_frame

func run() -> void:
	studio = Studio.instantiate()
	root.add_child(studio)
	current_scene = studio
	studio.set_process(false)
	await process_frame
	check(studio.characters.size() == 3, "Three character studies are available")
	var valid_rigs := true
	for character in studio.characters:
		valid_rigs = valid_rigs and character.rig.get_bone_count() == 62
		for clip in studio.CLIPS:
			valid_rigs = valid_rigs and character.animation_player.has_animation(clip)
	check(valid_rigs, "Each character has the shared skeleton and all review animations")
	var blue: Node3D = studio.characters[0]
	var red: Node3D = studio.characters[2]
	var blue_head: BoneAttachment3D = blue.rig.get_node("LeaderV2_Leader_anatomical_foundation")
	var blue_face: MeshInstance3D = blue_head.get_child(0)
	var red_face: MeshInstance3D = red.rig.get_node("Adventurer_Head")
	check(blue_head.bone_name == "Head" and not blue.rig.has_node("Adventurer_Head"), "Revision 02 replaces the male head and follows the animated head bone")
	check(blue_face.get_active_material(0) != red_face.get_active_material(0), "Leader retains revision 02 skin independently of faction recoloring")
	var hand: int = blue.rig.find_bone("Wrist.R")
	blue.advance_animation(0.25)
	var idle_hand: Transform3D = blue.rig.get_bone_global_pose(hand)
	studio.set_animation("Idle_Gun_Shoot")
	for frame in range(36): blue.advance_animation(1.0 / 60)
	var firing_hand: Transform3D = blue.rig.get_bone_global_pose(hand)
	check(firing_hand.origin.y > idle_hand.origin.y + 0.15, "Firing clip raises the weapon hand into an aiming pose")
	studio.set_animation("Death")
	for frame in range(180):
		for character in studio.characters: character.advance_animation(1.0 / 60)
	check(not blue.animation_player.is_playing(), "Fall animation finishes instead of looping")
	studio.set_animation("Idle_Gun")
	blue.advance_animation(0.3)
	check(blue.animation_player.is_playing(), "Returning to idle restores animation after a fall")
	await click(studio.buttons.focus0)
	check(studio.focus == 0 and not studio.stations[1].visible and studio.stations[0].visible, "Close-up button isolates the selected character")
	await click(studio.buttons.all)
	check(studio.focus == -1 and studio.stations[1].visible and studio.stations[2].visible, "Full lineup button restores all characters")
	await click(studio.buttons.clip1)
	check(studio.animation == "Walk", "Walk button switches the entire lineup")
	await click(studio.buttons.pause)
	check(studio.paused, "Pause button freezes character playback")
	await click(studio.buttons.light)
	check(studio.desert_light, "Lighting button enables the warmer palette")
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = Vector2(500, 400)
	root.push_input(press, true)
	var move := InputEventMouseMotion.new()
	move.position = Vector2(550, 400)
	move.relative = Vector2(50, 0)
	root.push_input(move, true)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.position = studio.buttons.all.get_global_rect().get_center()
	root.push_input(release, true)
	check(studio.turn_angle > 0.2 and not studio.turning, "Drag rotates models and releasing over UI ends the drag")
	await click(studio.buttons.back)
	await process_frame
	check(current_scene.phase == "briefing", "Return button opens the mission briefing")
	# Validate the reverse route, using the new mission's real GUI button.
	await click(current_scene.hud.buttons.studio)
	await process_frame
	check(current_scene.name == "CharacterStudio", "Mission briefing opens the character studio")
	print("CHARACTER STUDIO RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
