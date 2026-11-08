extends Control
## Readable subtitles and portraits rendered from the game's own CC0 characters.
const Character = preload("res://scripts/character_visual.gd")
var story: Node
var portrait_view: SubViewport
var portrait_texture: TextureRect
var portraits: Dictionary = {}
var current_portrait := ""
var speaker: Label
var subtitle: Label
var chapter: Label
var next_button: Button
var skip_button: Button
var hold_button: Button
var font: Font

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	font = ThemeDB.fallback_font
	speaker = _label(16, Color("9ddad6"))
	subtitle = _label(23, Color("edf0e6"))
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	chapter = _label(15, Color("c6b48f"))
	next_button = _button("NEXT  /  ENTER", func(): story.next_line())
	skip_button = _button("SKIP SEQUENCE  /  ESC", func(): story.complete())
	hold_button = _button("HOLD  /  SPACE", func(): story.toggle_hold())
	_build_portraits()
	resized.connect(_layout)
	_layout()

func _label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

func _button(title: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = title
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 13)
	for state in ["normal", "hover", "pressed"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("203740") if state == "normal" else Color("365662")
		style.border_color = Color("5a7476")
		style.set_border_width_all(1)
		style.set_corner_radius_all(3)
		button.add_theme_stylebox_override(state, style)
	button.pressed.connect(action)
	add_child(button)
	return button

func _build_portraits() -> void:
	portrait_texture = TextureRect.new()
	portrait_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(portrait_texture)
	# A headless display has no portrait render target. Dialogue still runs;
	# the windowed story test covers the actual portrait rendering path.
	if DisplayServer.get_name() == "headless": return
	portrait_view = SubViewport.new()
	portrait_view.size = Vector2i(240, 260)
	portrait_view.own_world_3d = true
	portrait_view.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	add_child(portrait_view)
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color("25383d")
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color = Color("b5c9d4")
	world.environment.ambient_light_energy = 0.65
	portrait_view.add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-25, -30, 0)
	light.light_color = Color("ffe7c7")
	portrait_view.add_child(light)
	for style in ["blue_leader", "red_leader", "blue_trooper"]:
		var character := Character.new()
		character.style = style
		character.rotation.y = PI + 0.15
		portrait_view.add_child(character)
		character.hide()
		portraits[style] = character
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 0.9
	portrait_view.add_child(camera)
	camera.position = Vector3(0, 1.48, 3)
	camera.look_at(Vector3(0, 1.43, 0))
	portrait_texture.texture = portrait_view.get_texture()

func present(line: Dictionary) -> void:
	speaker.text = line.speaker
	speaker.add_theme_color_override("font_color", Color("f3aba1") if line.portrait == "red_leader" else Color("9ddad6"))
	subtitle.text = line.words
	chapter.text = line.chapter
	current_portrait = line.portrait
	for style in portraits: portraits[style].visible = style == current_portrait
	portrait_texture.visible = portraits.has(current_portrait)
	next_button.text = "TAKE COMMAND  /  ENTER" if story.kind == "opening" and story.index == story.lines.size() - 1 else ("VIEW REPORT  /  ENTER" if story.index == story.lines.size() - 1 else "NEXT  /  ENTER")
	_layout()
	queue_redraw()

func advance_portrait(delta: float) -> void:
	if portraits.has(current_portrait): portraits[current_portrait].advance_animation(delta)

func _layout() -> void:
	if not is_instance_valid(subtitle): return
	var w := size.x
	var y := size.y - 246
	chapter.position = Vector2(36, 29)
	chapter.size = Vector2(w - 330, 26)
	skip_button.position = Vector2(w - 260, 22)
	skip_button.size = Vector2(224, 38)
	portrait_texture.position = Vector2(36, y + 24)
	portrait_texture.size = Vector2(146, 158)
	speaker.position = Vector2(210, y + 25)
	speaker.size = Vector2(w - 246, 26)
	subtitle.position = Vector2(210, y + 62)
	subtitle.size = Vector2(w - 260, 103)
	hold_button.position = Vector2(w - 440, size.y - 61)
	hold_button.size = Vector2(174, 37)
	next_button.position = Vector2(w - 252, size.y - 61)
	next_button.size = Vector2(216, 37)

func _draw() -> void:
	var y := size.y - 246
	draw_rect(Rect2(0, 0, size.x, 82), Color("0b181f"))
	draw_rect(Rect2(0, y, size.x, 246), Color("101f28"))
	draw_line(Vector2(36, y), Vector2(size.x - 36, y), Color("9e8c68"), 2)
	draw_rect(Rect2(34, y + 22, 150, 162), Color("587275"), false, 1)
	if not portraits.has(current_portrait):
		var center := Vector2(109, y + 90)
		for r in [23.0, 37.0, 51.0]: draw_arc(center, r, -0.8, 0.8, 24, Color("73aaa7"), 2, true)
		draw_circle(center, 7, Color("b4ded0"))
		draw_string(font, Vector2(55, y + 159), "REMOTE LINK", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("a9c2c2"))
	if is_instance_valid(hold_button): hold_button.text = "RESUME  /  SPACE" if story.held else "HOLD  /  SPACE"
	draw_string(font, Vector2(36, size.y - 36), "%02d / %02d   ·   %s" % [story.index + 1, story.lines.size(), "HELD FOR READING" if story.held else "AUTO ADVANCE"], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("9aafb2"))
