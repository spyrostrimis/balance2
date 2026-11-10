extends Node
## Presentation only. Battle owns simulation and result state.
const StoryPanel = preload("res://scripts/story_panel.gd")
var game: Node3D
var panel: Control
var active := false
var held := false
var kind := ""
var lines: Array[Dictionary] = []
var index := 0
var line_time := 0.0
var saved_focus := Vector3.ZERO
var saved_size := 36.0
var from_position := Vector3.ZERO
var from_rotation := Quaternion.IDENTITY
var from_size := 36.0

func _line(speaker: String, words: String, portrait: String, focus: Vector3, zoom: float, chapter: String) -> Dictionary:
	var offset := Vector3(0, 8, 10)
	if portrait == "red_leader": offset = Vector3(-7, 6, 8)
	elif portrait == "blue_leader" and focus.x < -10: offset = Vector3(7, 6, 8)
	elif focus.x < -15: offset = Vector3(8, 9, 9)
	return {"speaker": speaker, "words": words, "portrait": portrait, "focus": focus,
		"zoom": zoom, "offset": offset, "chapter": chapter, "duration": maxf(3.0, words.split(" ").size() * 0.31 + 1.3)}

func opening_lines() -> Array[Dictionary]:
	return [
		_line("FIELD TECHNICIAN", "The main intake is gone. We can patch the pipes, but the regulator needs Korali. Without it, we're pumping sand.", "radio", Vector3(-17, 0.4, -10), 9.5, "01 / WATER BEFORE NIGHTFALL"),
		_line("BLUE CAPTAIN", "Then this deposit stays with the settlement.", "blue_leader", Vector3(0, 0.4, 0), 12.0, "01 / WATER BEFORE NIGHTFALL"),
		_line("RED COMMANDER", "We have water carriers on the road. Food. Engineers. Accept our administration and they'll be here before nightfall.", "red_leader", game.units[4].position + Vector3.UP, 6.0, "02 / THE PRICE OF AID"),
		_line("BLUE CAPTAIN", "For how long?", "blue_leader", game.units[0].position + Vector3.UP, 6.0, "02 / THE PRICE OF AID"),
		_line("RED COMMANDER", "For as long as order requires.", "red_leader", game.units[4].position + Vector3.UP, 6.0, "02 / THE PRICE OF AID"),
		_line("BLUE COMMAND", "Do not escalate. The Council is reviewing the settlement's status. Maintain your position until negotiations conclude.", "command", Vector3(-10, 0.5, -5), 16.0, "03 / DISTANT ORDERS"),
		_line("BLUE CAPTAIN", "Send them the reservoir readings. Again.", "blue_leader", game.units[0].position + Vector3.UP, 7.0, "03 / DISTANT ORDERS")]

func discovery_lines() -> Array[Dictionary]:
	# Select an actual survivor; no dead Captain or invented living squad member.
	var speaker := "BLUE CAPTAIN"
	var portrait := "blue_leader"
	if not game.units[0].alive:
		var survivor: Node3D = game.living(0)[0]
		speaker = survivor.callsign.to_upper()
		portrait = "blue_trooper"
	return [
		_line(speaker, "Mark a route for the recovery crew. Water systems first.", portrait, Vector3(0, 0.5, 0), 13.0, "AFTERMATH / SAFE ACCESS"),
		_line("FIELD TECHNICIAN", "There's worked stone beneath the Korali. These markings match the sealed monument.", "radio", Vector3(0.9, 0.12, 1.45), 4.4, "DISCOVERY / BENEATH THE KORALI"),
		_line(speaker, "Record it. Don't cut any deeper.", portrait, Vector3(0.9, 0.12, 1.45), 4.0, "DISCOVERY / BENEATH THE KORALI"),
		_line("FIELD TECHNICIAN", "Recorded. The monument is still sealed. We'll leave it that way.", "radio", Vector3(0, 3.0, -18.0), 14.0, "DISCOVERY / A CLOSED DOOR")]

func begin_opening() -> void:
	if active or game.phase != "briefing": return
	game.phase = "intro"
	_begin("opening", opening_lines())

func begin_discovery() -> void:
	if active or game.winner != 0 or game.living(0).is_empty(): return
	_begin("discovery", discovery_lines())

func _begin(sequence: String, dialogue: Array[Dictionary]) -> void:
	kind = sequence
	lines = dialogue
	active = true
	held = false
	index = 0
	saved_focus = game.camera_focus
	saved_size = game.camera.size
	game.dragging = false
	game.attack_armed = false
	game.hud.hide()
	for unit in game.units:
		unit.selection_ring.hide()
		unit.faction_ring.hide()
	for effect in game.effects: effect.node.hide()
	game.arena.capture_ring.hide()
	if not is_instance_valid(panel):
		panel = StoryPanel.new()
		panel.story = self
		game.hud.get_parent().add_child(panel)
	panel.show()
	_enter_line()

func _enter_line() -> void:
	line_time = 0
	from_position = game.camera.position
	from_rotation = game.camera.quaternion
	from_size = game.camera.size
	panel.present(lines[index])

func advance(delta: float) -> void:
	if not active: return
	if not held:
		line_time += delta
		var line: Dictionary = lines[index]
		# A short eased move into each shot, followed by a restrained push-in.
		var t := smoothstep(0.0, 1.5, line_time)
		var focus: Vector3 = line.focus
		var offset: Vector3 = line.offset
		var destination := focus + offset
		var basis := Basis.looking_at(-offset.normalized(), Vector3.UP)
		game.camera.position = from_position.lerp(destination, t)
		game.camera.quaternion = from_rotation.slerp(basis.get_rotation_quaternion(), t)
		game.camera.size = lerpf(from_size, float(line.zoom) - minf(line_time / float(line.duration), 1) * 0.25, t)
		panel.advance_portrait(delta)
		if line_time >= float(line.duration): next_line()
	panel.queue_redraw()

func next_line() -> void:
	if not active: return
	index += 1
	if index >= lines.size():
		complete()
	else:
		_enter_line()

func toggle_hold() -> void:
	if active: held = not held

func complete() -> void:
	if not active: return
	active = false
	panel.hide()
	game.camera_focus = saved_focus
	game.camera.size = saved_size
	game._update_camera()
	game.arena.capture_ring.show()
	for unit in game.units:
		unit.set_selected(unit.selected)
		unit.faction_ring.visible = unit.alive
	for effect in game.effects: effect.node.show()
	game.hud.show()
	game.hud.queue_redraw()
	if kind == "opening": game.start_battle()

func handle_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_ENTER: next_line()
			KEY_SPACE: toggle_hold()
			KEY_ESCAPE: complete()
