extends Node3D
## A close-up review room for actual imported, skinned 3D characters.
const Character = preload("res://scripts/character_visual.gd")
const Art = preload("res://scripts/shapes.gd")
var characters: Array[Node3D] = []
var stations: Array[Node3D] = []
var camera: Camera3D
var ui: Control
var buttons: Dictionary = {}
var focus := -1
var animation := "Idle_Gun"
var paused := false
var turning := false
var turn_angle := 0.18
var clock := 0.0
var lights: Array[Light3D] = []
var desert_light := false
var font: Font
const TITLES := ["THE CAPTAIN", "THE VANGUARD", "THE COMMANDER"]
const DESCRIPTIONS := ["Cobalt · ivory · bronze", "Field armor · enclosed helmet", "Crimson · charcoal · copper"]
const CLIPS := ["Idle_Gun", "Walk", "Idle_Gun_Shoot", "Death"]
const CLIP_LABELS := ["IDLE", "WALK", "FIRE", "FALL"]

func _ready() -> void:
	font = ThemeDB.fallback_font
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color("14232b")
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color = Color("aabfce")
	world.environment.ambient_light_energy = 0.45
	add_child(world)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-40, -35, 0)
	key.light_color = Color("fff0d5")
	key.light_energy = 0.85
	key.shadow_enabled = true
	add_child(key)
	lights.append(key)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-20, 150, 0)
	fill.light_color = Color("87b1d1")
	fill.light_energy = 0.45
	add_child(fill)
	lights.append(fill)
	Art.box(self, Vector3(0, -0.16, 0), Vector3(200, 0.3, 200), Art.material(Color("24343a")))
	for i in range(3):
		var x := (i - 1) * 2.35
		var station := Node3D.new()
		add_child(station)
		stations.append(station)
		var color := Color("589bc2") if i < 2 else Color("be695f")
		Art.cylinder(station, Vector3(x, 0.015, 0), 0.78, 0.78, 0.05, Art.material(Color("31444a")), 64)
		var marker := Art.ring(station, 0.77, color, 0.009)
		marker.position.x = x
		var character := Character.new()
		character.style = ["blue_leader", "blue_trooper", "red_leader"][i]
		character.position = Vector3(x, 0.045, 0)
		character.rotation.y = PI + turn_angle
		station.add_child(character)
		characters.append(character)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 4.5
	add_child(camera)
	_frame()
	var canvas := CanvasLayer.new()
	add_child(canvas)
	ui = Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(ui)
	ui.draw.connect(_draw_ui)
	for i in range(3):
		var index := i
		_button("focus%d" % i, "%d  %s" % [i + 1, TITLES[i]], func(): focus_character(index))
	for i in range(CLIPS.size()):
		var index := i
		_button("clip%d" % i, CLIP_LABELS[i], func(): set_animation(CLIPS[index]))
	_button("all", "F  FULL LINEUP", func(): focus_character(-1))
	_button("pause", "PAUSE", func(): paused = not paused)
	_button("light", "WARM LIGHT", toggle_light)
	_button("back", "RETURN TO MISSION", func(): get_tree().change_scene_to_file("res://scenes/main.tscn"))

func _button(key: String, title: String, action: Callable) -> void:
	var button := Button.new()
	button.text = title
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 13)
	for state in ["normal", "hover", "pressed"]:
		var box := StyleBoxFlat.new()
		box.bg_color = Color("1b303c") if state == "normal" else Color("355666")
		box.border_color = Color("45606a")
		box.set_border_width_all(1)
		box.set_corner_radius_all(3)
		button.add_theme_stylebox_override(state, box)
	button.pressed.connect(action)
	ui.add_child(button)
	buttons[key] = button

func _process(delta: float) -> void:
	if not paused:
		clock += delta
		for character in characters: character.advance_animation(delta)
	ui.queue_redraw()

func _frame() -> void:
	var x := 0.0 if focus < 0 else characters[focus].position.x
	camera.position = Vector3(x, 2.2, 8)
	camera.look_at(Vector3(x, 0.95, 0))

func focus_character(index: int) -> void:
	focus = index
	camera.size = 4.5 if index < 0 else 3.6
	for i in range(stations.size()): stations[i].visible = index < 0 or i == index
	_frame()

func set_animation(name: String) -> void:
	animation = name
	paused = false
	for character in characters: character.play_clip(name)

func toggle_light() -> void:
	desert_light = not desert_light
	lights[0].light_color = Color("ffd3a0") if desert_light else Color("fff0d5")
	lights[1].light_energy = 0.3 if desert_light else 0.45
	buttons.light.text = "STUDIO LIGHT" if desert_light else "WARM LIGHT"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_1: focus_character(0)
			KEY_2: focus_character(1)
			KEY_3: focus_character(2)
			KEY_F: focus_character(-1)
			KEY_SPACE: paused = not paused
			KEY_ESCAPE: get_tree().change_scene_to_file("res://scenes/main.tscn")
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT: turning = event.pressed
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed: camera.size = maxf(2.1, camera.size - 0.2)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed: camera.size = minf(6, camera.size + 0.2)
	if event is InputEventMouseMotion and turning:
		turn_angle += event.relative.x * 0.009
		for character in characters: character.rotation.y = PI + turn_angle

func _input(event: InputEvent) -> void:
	# Releasing over a button must also end a viewport drag.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		turning = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT: turning = false

func _text(value: String, pos: Vector2, size: int = 16, color: Color = Color("e1e8df")) -> void:
	ui.draw_string(font, pos, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _place(key: String, rect: Rect2) -> void:
	buttons[key].position = rect.position
	buttons[key].size = rect.size

func _draw_ui() -> void:
	var size := get_viewport().get_visible_rect().size
	ui.draw_rect(Rect2(0, 0, size.x, 114), Color("101d25"))
	_text("B A L A N C E", Vector2(32, 41), 24)
	_text("CHARACTER STUDY  /  01", Vector2(32, 70), 12, Color("a2b4bd"))
	_text("People behind the armor", Vector2(320, 43), 25)
	_text("Three silhouettes for the same world. Faces and identities are still open.", Vector2(320, 73), 14, Color("9eafb5"))
	_place("back", Rect2(size.x - 228, 29, 196, 42))
	var bottom := size.y - 220
	ui.draw_rect(Rect2(0, bottom, size.x, 220), Color("101d25"))
	for i in range(3):
		var x := 32 + i * ((size.x - 64) / 3)
		var width := (size.x - 96) / 3
		_place("focus%d" % i, Rect2(x, bottom + 18, width, 38))
		_text(DESCRIPTIONS[i], Vector2(x + 8, bottom + 82), 14, Color("a4b6bb"))
		var color := Color("6eb4d8") if i < 2 else Color("d18a80")
		ui.draw_rect(Rect2(x, bottom + 102, width, 2), color)
	var center := size.x / 2
	for i in range(CLIPS.size()):
		_place("clip%d" % i, Rect2(center - 244 + i * 97, bottom + 126, 88, 38))
		buttons["clip%d" % i].modulate = Color("afd5e1") if animation == CLIPS[i] else Color.WHITE
	_place("pause", Rect2(center + 153, bottom + 126, 90, 38))
	buttons.pause.text = "RESUME" if paused else "PAUSE"
	_place("all", Rect2(32, bottom + 126, 168, 38))
	_place("light", Rect2(size.x - 200, bottom + 126, 168, 38))
	_text("Drag to turn  ·  Wheel to zoom  ·  1 / 2 / 3 close-up  ·  F full lineup  ·  Space pause", Vector2(32, size.y - 21), 13, Color("99aeb6"))
	_text("EARLY CHARACTER DIRECTION", Vector2(size.x - 241, size.y - 21), 11, Color("bdab84"))
