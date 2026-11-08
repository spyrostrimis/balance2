extends Node3D

const Arena = preload("res://scripts/arena.gd")
const Soldier = preload("res://scripts/unit.gd")
const HUD = preload("res://scripts/hud.gd")
const Art = preload("res://scripts/shapes.gd")
const Story = preload("res://scripts/mission_story.gd")
const CAPTURE_SECONDS := 40.0
const HEAL_COOLDOWN := 16.0
const HEAL_RADIUS := 6.5
const HEAL_AMOUNT := 45.0
var arena: Node3D
var camera: Camera3D
var hud: Control
var story: Node
var units: Array[Node3D] = []
var selected: Array[Node3D] = []
var phase := "briefing"
var elapsed := 0.0
var scores := [0.0, 0.0]
var capture_state := "NEUTRAL"
var heal_cooldown := 0.0
var ai_timer := 0.0
var attack_armed := false
var dragging := false
var drag_origin := Vector2.ZERO
var drag_position := Vector2.ZERO
var camera_focus := Vector3(5.55, 0, -6.0)
var effects: Array[Dictionary] = []
var status_message := "Select your squad. Secure the Korali."
var notification_timer := 8.0
var winner := -1
var result_reason := ""
var shake := 0.0

func _ready() -> void:
	_setup_environment()
	arena = Arena.new()
	add_child(arena)
	for faction in range(2):
		for i in range(4):
			var soldier := Soldier.new()
			soldier.configure(self, faction, i)
			add_child(soldier)
			soldier.position = Vector3(-13 if faction == 0 else 13, 0, (i - 1.5) * 1.8)
			units.append(soldier)
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = HUD.new()
	hud.game = self
	layer.add_child(hud)
	story = Story.new()
	story.game = self
	add_child(story)
	select_all()

func _setup_environment() -> void:
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("858178")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("a3c0d8")
	environment.environment.ambient_light_energy = 0.48
	environment.environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-42, -36, 0)
	light.light_color = Color("ffe6c6")
	light.light_energy = 0.85
	light.shadow_enabled = true
	light.directional_shadow_max_distance = 95
	add_child(light)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 36
	camera.far = 180
	add_child(camera)
	_update_camera()

func _update_camera() -> void:
	camera.position = camera_focus + Vector3(0, 33, 26)
	camera.look_at(camera_focus)

func begin_mission() -> void:
	story.begin_opening()

func start_battle() -> void:
	# Simulation entry point, also used by deterministic gameplay tests.
	phase = "playing"
	notify("Red patrol approaching. Right-click to move; A + click to advance.")

func _physics_process(delta: float) -> void:
	if phase != "playing":
		return
	step_simulation(delta)

func step_simulation(delta: float) -> void:
	if phase != "playing":
		return
	elapsed += delta
	heal_cooldown = maxf(0, heal_cooldown - delta)
	notification_timer = maxf(0, notification_timer - delta)
	for unit in units:
		unit.step(delta)
	_update_ai(delta)
	_update_capture(delta)
	_update_effects(delta)
	if living(0).is_empty():
		finish(1, "Your expedition has been defeated.")
	elif living(1).is_empty():
		finish(0, "The opposing patrol has been defeated.")

func _process(delta: float) -> void:
	if is_instance_valid(story) and story.active:
		for unit in units:
			if not story.held and (phase == "intro" or not unit.alive): unit.actor.advance_animation(delta)
		story.advance(delta)
		return
	# Let a last casualty finish falling behind the result panel. No orders,
	# damage, timers, or living-unit animations continue after the mission ends.
	if phase == "ended":
		for unit in units:
			if not unit.alive: unit.actor.advance_animation(delta)
	if phase == "playing" or phase == "paused":
		var pan := Vector3.ZERO
		if Input.is_physical_key_pressed(KEY_LEFT) or Input.is_physical_key_pressed(KEY_J): pan.x -= 1
		if Input.is_physical_key_pressed(KEY_RIGHT) or Input.is_physical_key_pressed(KEY_L): pan.x += 1
		if Input.is_physical_key_pressed(KEY_UP) or Input.is_physical_key_pressed(KEY_I): pan.z -= 1
		if Input.is_physical_key_pressed(KEY_DOWN) or Input.is_physical_key_pressed(KEY_K): pan.z += 1
		camera_focus += pan * delta * 16
		camera_focus.x = clampf(camera_focus.x, -14, 10)
		camera_focus.z = clampf(camera_focus.z, -10, 10)
		_update_camera()
	if is_instance_valid(hud):
		hud.queue_redraw()

func _update_ai(delta: float) -> void:
	if elapsed < 7:
		return
	ai_timer -= delta
	if ai_timer > 0:
		return
	ai_timer = 1.8
	var index := 0
	for unit in living(1):
		if unit.order == "guard" and not is_instance_valid(unit.target):
			unit.issue_move(Vector3(3.2, 0, (index - 1.5) * 1.3), true)
		index += 1

func _update_capture(delta: float) -> void:
	var counts := [0, 0]
	for unit in units:
		if unit.alive and Vector2(unit.position.x, unit.position.z).length() <= Arena.CAPTURE_RADIUS:
			counts[unit.team] += 1
	capture_state = "NEUTRAL"
	var color := Color("80bca9")
	if counts[0] > 0 and counts[1] > 0:
		capture_state = "CONTESTED"
		color = Color("efd38a")
	elif counts[0] > 0 or counts[1] > 0:
		var owner := 0 if counts[0] > 0 else 1
		scores[owner] = minf(CAPTURE_SECONDS, scores[owner] + delta)
		capture_state = "BLUE SECURING" if owner == 0 else "RED SECURING"
		color = Color("6bbdff") if owner == 0 else Color("ff7969")
		if scores[owner] >= CAPTURE_SECONDS:
			finish(owner, "The Korali deposit has been secured.")
	arena.capture_ring.material_override.albedo_color = color
	arena.capture_ring.material_override.emission = color

func living(faction: int) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for unit in units:
		if unit.alive and unit.team == faction:
			result.append(unit)
	return result

func nearest_enemy(unit: Node3D, within: float) -> Node3D:
	var closest: Node3D = null
	var distance := within
	for candidate in units:
		if candidate.alive and candidate.team != unit.team:
			var d := unit.position.distance_to(candidate.position)
			if d < distance:
				distance = d
				closest = candidate
	return closest

func fire(shooter: Node3D, victim: Node3D) -> void:
	var start: Vector3 = shooter.actor.muzzle_position()
	var end: Vector3 = victim.position + Vector3(0, 1.0, 0)
	var color := Color("9edfff") if shooter.team == 0 else Color("ffc28c")
	var beam := Art.box(self, (start + end) / 2, Vector3(0.055, 0.055, start.distance_to(end)), Art.material(color, 1))
	beam.look_at(end)
	effects.append({"node": beam, "time": 0.09, "total": 0.09, "expand": false})
	var flash := Art.sphere(self, start, Vector3.ONE * 0.16, Art.material(color, 1.5))
	effects.append({"node": flash, "time": 0.06, "total": 0.06, "expand": false})
	victim.take_damage(shooter.damage)

func heal() -> bool:
	if phase != "playing" or heal_cooldown > 0:
		return false
	var captain := units[0]
	if not captain.alive:
		notify("Your Captain has fallen. Healing is unavailable.")
		return false
	var healed := 0
	for unit in living(0):
		if unit.position.distance_to(captain.position) <= HEAL_RADIUS and unit.health < unit.max_health:
			unit.health = minf(unit.max_health, unit.health + HEAL_AMOUNT)
			healed += 1
	if healed == 0:
		notify("No injured allies in healing range. Cooldown preserved.")
		return false
	heal_cooldown = HEAL_COOLDOWN
	var pulse := Art.ring(self, 1, Color("80ffd2"), 0.06)
	pulse.position = captain.position + Vector3.UP * 0.12
	effects.append({"node": pulse, "time": 0.85, "total": 0.85, "expand": true})
	notify("Healing pulse · restored up to 45 health to %d allies." % healed)
	return true

func _update_effects(delta: float) -> void:
	for i in range(effects.size() - 1, -1, -1):
		var effect: Dictionary = effects[i]
		effect.time -= delta
		if effect.time <= 0:
			effect.node.queue_free()
			effects.remove_at(i)
		elif effect.expand:
			var scale_factor: float = 1 + (1 - effect.time / effect.total) * 5.5
			effect.node.scale = Vector3(scale_factor, 1, scale_factor)

func notify(message: String) -> void:
	status_message = message
	notification_timer = 6

func on_unit_lost(unit: Node3D) -> void:
	selected.erase(unit)
	if unit.team == 0:
		notify("%s lost. Protect the remaining expedition." % unit.callsign)

func finish(faction: int, reason: String) -> void:
	if phase != "playing":
		return
	winner = faction
	result_reason = reason
	phase = "ended"
	dragging = false
	attack_armed = false
	if faction == 0: story.begin_discovery()

func select_all() -> void:
	selected = living(0)
	_sync_selection()

func select_unit(unit: Node3D, additive: bool = false) -> void:
	if not unit.alive or unit.team != 0:
		return
	if not additive:
		selected.clear()
	if additive and selected.has(unit):
		selected.erase(unit)
	else:
		selected.append(unit)
	_sync_selection()

func _sync_selection() -> void:
	for unit in units:
		unit.set_selected(selected.has(unit))

func ground_at(screen_point: Vector2) -> Variant:
	return Plane(Vector3.UP, 0).intersects_ray(camera.project_ray_origin(screen_point), camera.project_ray_normal(screen_point))

func unit_at(screen_point: Vector2, faction: int) -> Node3D:
	var closest: Node3D = null
	var best := 29.0
	for unit in living(faction):
		var screen := camera.unproject_position(unit.position + Vector3.UP * 0.9)
		var distance := screen.distance_to(screen_point)
		if distance < best:
			best = distance
			closest = unit
	return closest

func command_move(point: Vector3, advance: bool = false) -> void:
	if selected.is_empty():
		notify("Select a unit first, or press 1 for the whole squad.")
		return
	for i in range(selected.size()):
		var offset := Vector3.ZERO
		if selected.size() > 1:
			offset = Vector3((i % 2 - 0.5) * 1.5, 0, (floori(i / 2.0) - 0.5) * 1.5)
		selected[i].issue_move(point + offset, advance)
	var marker := Art.ring(self, 0.55, Color("ffce81") if advance else Color("b9ecff"))
	var cell: Vector2i = arena.nearest_open(point)
	marker.position = Vector3(cell.x, 0.08, cell.y)
	effects.append({"node": marker, "time": 0.6, "total": 0.6, "expand": false})
	notify("Attack-move ordered." if advance else "Move ordered. Troops return fire when they stop.")

func toggle_pause() -> void:
	if phase == "playing":
		phase = "paused"
		dragging = false
	elif phase == "paused":
		phase = "playing"

func focus_squad() -> void:
	var group := selected if not selected.is_empty() else living(0)
	if group.is_empty():
		return
	var center := Vector3.ZERO
	for unit in group:
		center += unit.position
	camera_focus = center / group.size() + Vector3(camera.size * 0.154, 0, 0)
	_update_camera()

func _unhandled_input(event: InputEvent) -> void:
	if story.active:
		story.handle_input(event)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_ENTER:
				if phase == "briefing": begin_mission()
			KEY_SPACE, KEY_ESCAPE:
				if attack_armed:
					attack_armed = false
				else:
					toggle_pause()
			KEY_R:
				if phase == "ended" or phase == "paused": get_tree().reload_current_scene()
			KEY_1:
				select_all()
			KEY_F:
				focus_squad()
			KEY_Q:
				heal()
			KEY_A:
				if phase == "playing":
					attack_armed = true
					notify("Attack-move: left-click a destination. Esc cancels.")
			KEY_H:
				if phase == "playing":
					for unit in selected: unit.stop()
					notify("Holding position. Units fire at enemies in range.")
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and dragging:
			dragging = false
			var additive: bool = event.shift_pressed
			if drag_origin.distance_to(event.position) < 8:
				var unit := unit_at(event.position, 0)
				if unit:
					select_unit(unit, additive)
				elif not additive:
					selected.clear()
			else:
				if not additive: selected.clear()
				var box := Rect2(drag_origin, event.position - drag_origin).abs()
				for unit in living(0):
					if box.has_point(camera.unproject_position(unit.position + Vector3.UP * 0.7)) and not selected.has(unit):
						selected.append(unit)
			_sync_selection()
			return
		if phase != "playing" or hud.over_ui(event.position):
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			camera.size = maxf(14, camera.size - 2)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			camera.size = minf(48, camera.size + 2)
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if attack_armed:
				var ground: Variant = ground_at(event.position)
				if ground != null: command_move(ground, true)
				attack_armed = false
			else:
				dragging = true
				drag_origin = event.position
				drag_position = event.position
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			attack_armed = false
			var enemy := unit_at(event.position, 1)
			if enemy:
				for unit in selected: unit.issue_attack(enemy)
				notify("Focus fire on the enemy %s." % enemy.callsign.to_lower())
			else:
				var ground: Variant = ground_at(event.position)
				if ground != null: command_move(ground)
	elif event is InputEventMouseMotion and dragging:
		drag_position = event.position
