extends Control
## Compact, independent fantasy HUD panels. No reserved sidebar or screen strip.
const Character = preload("res://scripts/character_visual.gd")
const FRAME = preload("res://assets/ui/sanctuary_frame.png")
const ICONS = preload("res://assets/ui/command_atlas.png")
const INK := Color("eee4cf")
const MUTED := Color("a99d87")
const BLUE := Color("69c7ee")
const RED := Color("e96a54")
const MINT := Color("a4df9b")
const GOLD := Color("b3945c")
const HEALTH := Color("78c34e")
const MANA := Color("428cd7")
var game: Node3D
var font: Font
var buttons: Dictionary = {}
var card_rects: Array[Rect2] = []
var card_units: Array[Node3D] = []
var portraits: Dictionary = {}
var icons: Array[AtlasTexture] = []
var top_rect := Rect2()
var hero_rect := Rect2()
var map_rect := Rect2()
var map_content := Rect2()
var selection_rect := Rect2()
var actions_rect := Rect2()
var objective_open := false
var objective_rect := Rect2()
var tooltip := ""

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	font = ThemeDB.fallback_font
	for i in range(6):
		var icon := AtlasTexture.new()
		icon.atlas = ICONS
		icon.region = Rect2(Vector2(i % 3, floori(i / 3.0)) * Vector2(ICONS.get_width() / 3.0, ICONS.get_height() / 2.0), Vector2(ICONS.get_width() / 3.0, ICONS.get_height() / 2.0))
		icons.append(icon)
	_make_button("heal", "", func(): game.heal(), "Healing Pulse [Q]\nRestore 45 health to allies within 6.5m. Cooldown: 16s. No mana cost.")
	_make_button("select", "Squad  [1]", func(): game.select_all())
	_make_button("move", "", func(): game.arm_command("move"), "Move [M] — choose a destination.")
	_make_button("hold", "", func(): game.stop_selected(), "Stop [S / H] — stop moving and fire at enemies in range.")
	_make_button("advance", "", func(): game.arm_command("attack"), "Attack [A] — click an enemy to focus fire, or ground to attack-move.")
	_make_button("patrol", "", func(): game.arm_command("patrol"), "Patrol [P] — choose the other end of a repeating route.")
	_make_button("pause", "Menu  [Esc]", func(): game.toggle_pause())
	_make_button("objectives", "Objectives", func(): objective_open = not objective_open)
	_make_button("primary", "DEPLOY EXPEDITION   →", _primary_action)
	_make_button("restart", "RESTART MISSION", func(): game.get_tree().reload_current_scene())
	_make_button("studio", "CHARACTER STUDIO", func(): game.get_tree().change_scene_to_file("res://scenes/character_studio.tscn"))
	for pair in [["move", 0], ["hold", 1], ["advance", 2], ["patrol", 3], ["heal", 4]]:
		var texture := TextureRect.new()
		texture.texture = icons[pair[1]]
		texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		buttons[pair[0]].add_child(texture)
		texture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		texture.offset_left = 3
		texture.offset_top = 3
		texture.offset_right = -3
		texture.offset_bottom = -3
		var hotkey := Label.new()
		hotkey.text = {"move":"M", "hold":"S", "advance":"A", "patrol":"P", "heal":"Q"}[pair[0]]
		hotkey.position = Vector2(4, 0)
		hotkey.add_theme_font_size_override("font_size", 12)
		hotkey.add_theme_color_override("font_color", INK)
		hotkey.add_theme_color_override("font_outline_color", Color.BLACK)
		hotkey.add_theme_constant_override("outline_size", 5)
		hotkey.mouse_filter = Control.MOUSE_FILTER_IGNORE
		buttons[pair[0]].add_child(hotkey)
	_build_portraits()

func _make_button(key: String, title: String, action: Callable, hint: String = "") -> void:
	var button := Button.new()
	button.text = title
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", Color("fff3cd"))
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("171e22") if state == "normal" else Color("38413b")
		if state == "disabled": style.bg_color = Color("151819")
		style.border_color = GOLD if state != "hover" else INK
		style.set_border_width_all(1 if state != "hover" else 2)
		button.add_theme_stylebox_override(state, style)
	button.pressed.connect(action)
	button.mouse_entered.connect(func(): tooltip = hint)
	button.mouse_exited.connect(func(): tooltip = "")
	add_child(button)
	buttons[key] = button

func _build_portraits() -> void:
	if DisplayServer.get_name() == "headless": return
	for i in [0, 1, 2, 3, 4]:
		var unit: Node3D = game.units[i]
		var view := SubViewport.new()
		view.size = Vector2i(144, 160)
		view.own_world_3d = true
		view.render_target_update_mode = SubViewport.UPDATE_ONCE
		add_child(view)
		var environment := WorldEnvironment.new()
		environment.environment = Environment.new()
		environment.environment.background_mode = Environment.BG_COLOR
		environment.environment.background_color = Color("192b34") if unit.team == 0 else Color("382021")
		environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		environment.environment.ambient_light_color = Color("b5c9d4")
		environment.environment.ambient_light_energy = 0.7
		view.add_child(environment)
		var light := DirectionalLight3D.new()
		light.rotation_degrees = Vector3(-25, -30, 0)
		light.light_color = Color("ffe7c7")
		view.add_child(light)
		var character := Character.new()
		character.style = unit.actor.style
		character.role = unit.role
		character.rotation.y = PI + 0.15
		view.add_child(character)
		var camera := Camera3D.new()
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = 0.50 if unit.leader else 0.58
		view.add_child(camera)
		camera.position = Vector3(0, 1.56, 3)
		camera.look_at(Vector3(0, 1.54, 0))
		portraits[unit] = view.get_texture()

func _primary_action() -> void:
	match game.phase:
		"briefing": game.begin_mission()
		"paused": game.toggle_pause()
		"ended": game.get_tree().reload_current_scene()

func _layout() -> void:
	var s := get_viewport_rect().size
	top_rect = Rect2(190, -9, s.x - 380, 58)
	hero_rect = Rect2(16, 68, 66, 84)
	map_rect = Rect2(12, s.y - 198, 220, 186)
	map_content = Rect2(26, s.y - 171, 192, 144)
	selection_rect = Rect2((s.x - 610) / 2, s.y - 164, 610, 152)
	actions_rect = Rect2(s.x - 252, s.y - 132, 240, 120)
	objective_rect = Rect2(top_rect.position.x, 60, 330, 145)

func over_ui(point: Vector2) -> bool:
	_layout()
	if game.phase != "playing": return true
	for rect in [top_rect, hero_rect, map_rect, selection_rect, actions_rect, Rect2(get_viewport_rect().size.x / 2 - 32, 0, 64, 75)]:
		if rect.has_point(point): return true
	return objective_open and objective_rect.has_point(point)

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree() or game.phase != "playing": return
	if event is InputEventMouseButton and event.pressed:
		if map_content.has_point(event.position):
			var uv: Vector2 = (event.position - map_content.position) / map_content.size
			var world := Vector3(uv.x * 42 - 21, 0, uv.y * 28 - 14)
			if event.button_index == MOUSE_BUTTON_LEFT:
				if game.has_armed_command(): game.execute_command(world)
				else:
					game.camera_focus = world
					game._update_camera()
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				game.cancel_command()
				game.command_move(world)
			get_viewport().set_input_as_handled()
			return
		if event.button_index != MOUSE_BUTTON_LEFT: return
		if hero_rect.has_point(event.position):
			game.select_unit(game.units[0], event.shift_pressed)
			if event.double_click: game.focus_squad()
			get_viewport().set_input_as_handled()
			return
		for i in range(card_rects.size()):
			if card_rects[i].has_point(event.position):
				game.select_unit(card_units[i], event.shift_pressed)
				get_viewport().set_input_as_handled()
				return

func text_at(value: String, x: float, y: float, font_size: int = 16, color: Color = INK) -> void:
	draw_string(font, Vector2(x, y), value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func centered(value: String, center_x: float, y: float, font_size: int = 16, color: Color = INK) -> void:
	text_at(value, center_x - font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / 2, y, font_size, color)

func line(x: float, y: float, width: float) -> void:
	draw_line(Vector2(x, y), Vector2(x + width, y), GOLD.darkened(0.5))

func panel(rect: Rect2) -> void:
	draw_rect(rect.grow(2), Color(0, 0, 0, 0.7))
	# Fixed-size corners preserve the stone carving at every panel aspect ratio.
	var edge := 22.0 if rect.size.y > 80 else 15.0
	var dx := [0.0, edge, rect.size.x - edge, rect.size.x]
	var dy := [0.0, edge, rect.size.y - edge, rect.size.y]
	var sx := [0.0, 110.0, FRAME.get_width() - 110.0, float(FRAME.get_width())]
	var sy := [0.0, 110.0, FRAME.get_height() - 110.0, float(FRAME.get_height())]
	for row in range(3):
		for col in range(3):
			draw_texture_rect_region(FRAME, Rect2(rect.position + Vector2(dx[col], dy[row]), Vector2(dx[col + 1] - dx[col], dy[row + 1] - dy[row])), Rect2(sx[col], sy[row], sx[col + 1] - sx[col], sy[row + 1] - sy[row]))

func bar(rect: Rect2, fraction: float, color: Color, ticks: bool = false) -> void:
	draw_rect(rect.grow(1), Color("090d0e"))
	draw_rect(rect, color.darkened(0.48 if color == MANA else 0.77))
	if fraction > 0:
		var filled := Rect2(rect.position, Vector2(rect.size.x * clampf(fraction, 0, 1), rect.size.y))
		draw_rect(filled, color)
		draw_line(filled.position, filled.position + Vector2(filled.size.x, 0), color.lightened(0.32))
		if rect.size.y > 3: draw_line(filled.position + Vector2(0, filled.size.y - 1), filled.end - Vector2(0, 1), color.darkened(0.35))
	if ticks:
		for i in range(1, 5):
			var x := rect.position.x + i * rect.size.x / 5
			draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), Color(0, 0, 0, 0.45))

func portrait(unit: Node3D, rect: Rect2) -> void:
	draw_rect(rect.grow(2), GOLD if unit.selected else Color("6b6556"))
	if portraits.has(unit): draw_texture_rect(portraits[unit], rect, false, Color.WHITE if unit.alive else Color("555761"))
	else: draw_texture_rect(icons[5], rect, false)
	if not unit.alive:
		draw_line(rect.position, rect.end, RED, 2)

func _place_button(key: String, rect: Rect2, show_button: bool = true) -> void:
	buttons[key].position = rect.position
	buttons[key].size = rect.size
	buttons[key].visible = show_button

func _draw() -> void:
	_layout()
	var s := get_viewport_rect().size
	var modal: bool = game.phase != "playing"
	buttons.primary.visible = modal
	buttons.restart.visible = game.phase == "paused"
	buttons.studio.visible = game.phase == "briefing"
	buttons.heal.visible = not modal and game.selected.has(game.units[0]) and game.units[0].alive
	_draw_top(not modal)
	_draw_hero()
	_draw_map()
	_draw_selection(not modal)
	_draw_actions(not modal)
	if not modal:
		_draw_world_bars()
		if objective_open: _draw_objective()
		if game.dragging:
			var box := Rect2(game.drag_origin, game.drag_position - game.drag_origin).abs()
			draw_rect(box, Color(0.4, 0.8, 1, 0.12))
			draw_rect(box, BLUE, false, 1)
		if game.notification_timer > 0:
			var width := font.get_string_size(game.status_message, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x + 28
			var r := Rect2((s.x - width) / 2, s.y - 208, width, 28)
			draw_rect(r, Color(0.025, 0.035, 0.04, 0.88))
			centered(game.status_message, s.x / 2, r.position.y + 19, 13, INK)
		if not tooltip.is_empty():
			var lines := tooltip.split("\n")
			var width := 0.0
			for value in lines: width = maxf(width, font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x)
			var origin := Vector2(clampf(get_local_mouse_position().x - width / 2, 12, s.x - width - 36), s.y - 260)
			draw_rect(Rect2(origin, Vector2(width + 24, lines.size() * 22 + 16)), Color("111a1d"))
			draw_rect(Rect2(origin, Vector2(width + 24, lines.size() * 22 + 16)), GOLD, false)
			for i in range(lines.size()): text_at(lines[i], origin.x + 12, origin.y + 23 + i * 22, 13)
	if modal: _draw_modal(s)

func _draw_top(interactive: bool) -> void:
	panel(top_rect)
	var x := top_rect.position.x
	var cx := get_viewport_rect().size.x / 2
	_place_button("objectives", Rect2(x + 16, 9, 100, 27), interactive)
	_place_button("pause", Rect2(x + 124, 9, 108, 27), interactive)
	text_at("FIRST CONTACT", x + 250, 28, 13, INK)
	# Hanging time medallion, echoing the sanctuary's circular seal.
	draw_circle(Vector2(cx, 29), 36, Color("181e22"))
	draw_arc(Vector2(cx, 29), 33, 0, TAU, 64, GOLD.darkened(0.45), 5, true)
	draw_arc(Vector2(cx, 29), 30, 0, TAU, 64, GOLD, 1, true)
	centered("%02d:%02d" % [int(game.elapsed / 60), int(game.elapsed) % 60], cx, 33, 17)
	centered("B A L A N C E", cx, 53, 7, MUTED)
	for team in range(2):
		var bx := cx + 58 + team * 138
		text_at("%s  %02d / 40" % ["BLUE" if team == 0 else "RED", int(game.scores[team])], bx, 23, 12, BLUE if team == 0 else RED)
		bar(Rect2(bx, 30, 116, 3), game.scores[team] / 40.0, BLUE if team == 0 else RED)
	text_at("%d / 4" % game.living(0).size(), top_rect.end.x - 70, 27, 15, INK)

func _draw_hero() -> void:
	var unit: Node3D = game.units[0]
	portrait(unit, Rect2(hero_rect.position, Vector2(66, 66)))
	bar(Rect2(hero_rect.position + Vector2(0, 69), Vector2(66, 5)), unit.health / unit.max_health, HEALTH)
	bar(Rect2(hero_rect.position + Vector2(0, 77), Vector2(66, 3)), 0, MANA)
	draw_rect(Rect2(hero_rect.position + Vector2(49, 48), Vector2(17, 18)), Color("101719"))
	text_at("1", hero_rect.position.x + 54, hero_rect.position.y + 62, 12)

func _map_point(world: Vector3) -> Vector2:
	return map_content.position + Vector2((world.x + 21) / 42, (world.z + 14) / 28) * map_content.size

func _draw_map() -> void:
	panel(map_rect)
	centered("THE SHATTERED BASIN", map_rect.get_center().x, map_rect.position.y + 20, 10, MUTED)
	draw_rect(map_content, Color("514634"))
	# Quiet relief, road, obstacle footprints, objective and current unit positions.
	for i in range(12):
		var r := Rect2(map_content.position + Vector2(i * 16, 0), Vector2(16, map_content.size.y))
		draw_rect(r, Color(0.2, 0.24, 0.21, 0.12 if i % 2 == 0 else 0.04))
	draw_line(_map_point(Vector3(0, 0, -14)), _map_point(Vector3(0, 0, 14)), Color("938166"), 8)
	for obstacle in game.arena.obstacles:
		draw_circle(_map_point(obstacle), obstacle.y * map_content.size.x / 42, Color("2e3431"))
	var ring := PackedVector2Array()
	for i in range(49):
		var angle := i * TAU / 48
		ring.append(_map_point(Vector3(cos(angle) * 5.2, 0, sin(angle) * 5.2)))
	draw_polyline(ring, Color("a7c3a1"), 1, true)
	draw_circle(_map_point(Vector3.ZERO), 3, Color("67d6c3"))
	for unit in game.units:
		if not unit.alive: continue
		var p := _map_point(unit.position)
		if unit.selected: draw_circle(p, 4, INK)
		draw_circle(p, 2.6, BLUE if unit.team == 0 else RED)
	var corners := PackedVector2Array()
	var screen := get_viewport_rect().size
	for point in [Vector2(0, 54), Vector2(screen.x, 54), Vector2(screen.x, screen.y - 170), Vector2(0, screen.y - 170)]:
		var world: Variant = game.ground_at(point)
		if world != null: corners.append(_map_point(world).clamp(map_content.position, map_content.end))
	if corners.size() == 4:
		corners.append(corners[0])
		draw_polyline(corners, Color(0.95, 0.91, 0.76, 0.65), 1, true)
	draw_rect(map_content, Color("a38e62"), false)

func _draw_selection(interactive: bool) -> void:
	panel(selection_rect)
	var x := selection_rect.position.x + 16
	var y := selection_rect.position.y + 15
	card_rects.clear()
	card_units.clear()
	var unit: Node3D = game.selected[0] if not game.selected.is_empty() else null
	if unit:
		portrait(unit, Rect2(x, y, 88, 98))
		bar(Rect2(x, y + 102, 88, 8), unit.health / unit.max_health, HEALTH)
		centered("%d / %d" % [int(unit.health), int(unit.max_health)], x + 44, y + 110, 9)
		bar(Rect2(x, y + 114, 88, 5), 0, MANA)
		text_at(unit.callsign, x + 104, y + 16, 18)
		text_at("LEVEL 1  ·  LEADER" if unit.leader else unit.role, x + 104, y + 33, 10, MUTED)
		text_at("ATK %d   /   RANGE %.1f   /   SPEED %.1f" % [int(unit.damage), unit.weapon_range, unit.speed], x + 104, y + 117, 10, MUTED)
	else:
		draw_texture_rect(icons[5], Rect2(x + 2, y, 84, 120), false)
		text_at("Korali Expedition", x + 104, y + 18, 18)
		text_at("Select troops to take command", x + 104, y + 36, 11, MUTED)
	# Selected-unit grid; with no selection, show the surviving expedition.
	var group: Array = game.selected if unit else game.living(0)
	for i in range(group.size()):
		var member: Node3D = group[i]
		var r := Rect2(x + 106 + i * 50, y + 46, 42, 46)
		portrait(member, r)
		bar(Rect2(r.position + Vector2(0, 48), Vector2(42, 3)), member.health / member.max_health, HEALTH)
		card_rects.append(r.grow(3))
		card_units.append(member)
	line(x + 326, y + 8, 1)
	var leader_selected: bool = game.selected.has(game.units[0]) and game.units[0].alive
	if leader_selected:
		text_at("ABILITIES", x + 354, y + 14, 10, MUTED)
		_place_button("heal", Rect2(x + 354, y + 28, 58, 58), interactive)
		buttons.heal.disabled = game.heal_cooldown > 0
		buttons.heal.modulate = Color("777c80") if buttons.heal.disabled else Color.WHITE
		text_at("Healing", x + 425, y + 45, 14)
		text_at("Pulse", x + 425, y + 63, 14)
		text_at("%ds" % ceili(game.heal_cooldown) if game.heal_cooldown > 0 else "READY", x + 425, y + 83, 11, MINT)
		text_at("+45 HP  ·  16s cooldown", x + 354, y + 112, 11, MUTED)
	else:
		draw_texture_rect(icons[5], Rect2(x + 402, y - 2, 92, 124), false)

func _draw_actions(interactive: bool) -> void:
	panel(actions_rect)
	var x := actions_rect.position.x + 14
	var y := actions_rect.position.y
	text_at("ORDERS", x + 3, y + 23, 11, MUTED)
	_place_button("select", Rect2(x + 108, y + 9, 102, 22), interactive)
	var keys := ["move", "hold", "advance", "patrol"]
	var labels := ["Move", "Stop", "Attack", "Patrol"]
	for i in range(4):
		_place_button(keys[i], Rect2(x + i * 54, y + 38, 48, 48), interactive)
		buttons[keys[i]].disabled = game.selected.is_empty()
		buttons[keys[i]].modulate = Color("70777a") if game.selected.is_empty() else Color.WHITE
		centered(labels[i], x + i * 54 + 24, y + 102, 11, INK)

func _draw_objective() -> void:
	panel(objective_rect)
	var p := objective_rect.position + Vector2(18, 28)
	text_at("Secure the Korali", p.x, p.y, 19)
	text_at("Hold the ring for 40 uncontested seconds", p.x, p.y + 27, 13)
	text_at("or defeat the opposing patrol.", p.x, p.y + 47, 13)
	text_at(game.capture_state, p.x, p.y + 77, 12, MINT)
	text_at("%d hostiles remain" % game.living(1).size(), p.x, p.y + 98, 12, RED)

func _draw_world_bars() -> void:
	for unit in game.units:
		if not unit.alive or game.camera.is_position_behind(unit.position): continue
		# Anchor above the head, never across the torso; pixel thickness is zoom-independent.
		var p: Vector2 = game.camera.unproject_position(unit.position + Vector3.UP * (2.55 if unit.leader else 2.25))
		if not get_viewport_rect().grow(-25).has_point(p) or over_ui(p): continue
		var color := HEALTH if unit.team == 0 else RED
		if unit.leader:
			var r := Rect2(p + Vector2(-45, -5), Vector2(90, 5))
			portrait(unit, Rect2(p + Vector2(-65, -16), Vector2(17, 20)))
			draw_string_outline(font, p + Vector2(-44, -10), unit.callsign, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, 3, Color("111616"))
			text_at(unit.callsign, p.x - 44, p.y - 10, 11, INK if unit.team == 0 else Color("ffae96"))
			bar(r, unit.health / unit.max_health, color, true)
			bar(Rect2(p + Vector2(-45, 3), Vector2(90, 2)), 0, MANA)
			draw_rect(Rect2(p + Vector2(47, -6), Vector2(14, 14)), Color("111616"))
			text_at("1", p.x + 50, p.y + 5, 10, INK)
		else:
			bar(Rect2(p + Vector2(-23, 0), Vector2(46, 4)), unit.health / unit.max_health, color)

func _draw_modal(size: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.015, 0.035, 0.05, 0.76))
	var origin := (size - Vector2(760, 570)) / 2
	panel(Rect2(origin, Vector2(760, 570)))
	var x := origin.x + 38
	var y := origin.y
	var title := "First Contact"
	var kicker := "MISSION 01   /   THE SHATTERED BASIN   /   BEFORE NIGHTFALL"
	var lines: Array[String] = [
		"The storm destroyed the settlement's water regulator.",
		"Korali from this basin can help restore it before nightfall.",
		"",
		"A Red patrol offers supplies and protection—if the settlement",
		"accepts permanent military administration. Your command orders",
		"restraint. The people waiting for water cannot wait."]
	var quote := "“For as long as order requires.” — Red commander"
	var objective := "SECURE THE DEPOSIT"
	var instruction := "Hold the ring for 40 uncontested seconds, or defeat the Red patrol."
	var advice := "Q heals nearby allies. Right-click moves or attacks. Every soldier matters."
	if game.phase == "paused":
		kicker = "TACTICAL PAUSE"
		title = "Take a breath."
		lines = ["The battle is paused.", "", "Right-click ground to move; right-click an enemy to focus fire.", "A then left-click advances while engaging enemies.", "Q heals around your Captain. H holds your selected troops.", "Scroll to zoom. Arrows pan. F returns to your squad."]
		quote = ""
		advice = "Preserve your expedition. There are no reinforcements."
	elif game.phase == "ended":
		kicker = "MISSION COMPLETE" if game.winner == 0 else "MISSION FAILED"
		title = "Beneath the Korali" if game.winner == 0 else "The basin is lost."
		if game.winner == 0:
			lines = ["The deposit is secure. The recovery crew can now reach it.", "The settlement's repair is still ahead.", "", "A survey finds worked stone beneath the Korali.", "Its markings match the sealed Clergy monuments.", "Who built this place—and why was it buried?"]
			quote = "The monument remains silent."
		else:
			lines = ["The Red patrol controls the deposit.", "Your expedition could not secure the Korali for the settlement.", "", "The water system still needs repair.", "The offer of supplies still carries its price:", "permanent military administration."]
			quote = "The settlement's future remains uncertain."
		objective = "EXPEDITION REPORT  /  %d OF 4 SURVIVED" % game.living(0).size()
		instruction = game.result_reason
		advice = "Blue control: %ds   /   Red control: %ds" % [int(game.scores[0]), int(game.scores[1])]
	text_at(kicker, x, y + 43, 12, MINT)
	text_at(title, x, y + 95, 38)
	line(x, y + 119, 684)
	for i in range(lines.size()):
		text_at(lines[i], x, y + 154 + i * 29, 16, INK if i < 2 else MUTED)
	text_at(quote, x, y + 335, 15, Color("d3bc91"))
	draw_rect(Rect2(x, y + 358, 684, 84), Color("1c343e"))
	text_at(objective, x + 16, y + 380, 12, MINT)
	text_at(instruction, x + 16, y + 405, 15)
	text_at(advice, x + 16, y + 427, 13, MUTED)
	buttons.primary.text = "DEPLOY EXPEDITION   →" if game.phase == "briefing" else ("RESUME   →" if game.phase == "paused" else "REPLAY MISSION   →")
	_place_button("primary", Rect2(x, y + 460, 684 if game.phase == "ended" else 350, 52))
	if game.phase == "paused":
		_place_button("restart", Rect2(x + 365, y + 460, 319, 52))
	if game.phase == "briefing":
		_place_button("studio", Rect2(x + 365, y + 460, 319, 52))
	text_at("THE SHATTERED BASIN   ·   A STRUGGLE FOR WATER, AND SELF-DETERMINATION", x, y + 546, 10, MUTED)
