extends Control
## Resolution-aware HUD, tactical overlays, and accessible mouse commands.
## The battlefield remains interactive outside explicitly defined panels.

const INK := Color("e3ede9")
const MUTED := Color("91a7ad")
const BLUE := Color("71c4ff")
const RED := Color("f58170")
const MINT := Color("96e6ca")
const PANEL := Color("101f28")
var game: Node3D
var font: Font
var sidebar := 304.0
var buttons: Dictionary = {}
var card_rects: Array[Rect2] = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	font = ThemeDB.fallback_font
	_make_button("heal", "Q   HEALING PULSE", func(): game.heal())
	_make_button("select", "1   SELECT SQUAD", func(): game.select_all())
	_make_button("advance", "A   ATTACK-MOVE", func():
		game.attack_armed = true
		game.notify("Attack-move: left-click a destination. Esc cancels."))
	_make_button("hold", "H   HOLD POSITION", func():
		for unit in game.selected: unit.stop())
	_make_button("pause", "II", func(): game.toggle_pause())
	_make_button("primary", "DEPLOY EXPEDITION   →", _primary_action)
	_make_button("restart", "RESTART MISSION", func(): game.get_tree().reload_current_scene())

func _make_button(key: String, title: String, action: Callable) -> void:
	var button := Button.new()
	button.text = title
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", INK)
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("203946") if state == "normal" else Color("345562")
		if state == "disabled": style.bg_color = Color("192a32")
		style.border_color = Color("375664")
		style.set_border_width_all(1)
		style.set_corner_radius_all(4)
		button.add_theme_stylebox_override(state, style)
	button.pressed.connect(action)
	add_child(button)
	buttons[key] = button

func _primary_action() -> void:
	match game.phase:
		"briefing": game.start_battle()
		"paused": game.toggle_pause()
		"ended": game.get_tree().reload_current_scene()

func over_ui(point: Vector2) -> bool:
	var size := get_viewport_rect().size
	return point.x >= size.x - sidebar or point.y <= 78 or point.y >= size.y - 58

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and game.phase == "playing":
		for i in range(card_rects.size()):
			if card_rects[i].has_point(event.position):
				game.select_unit(game.units[i], event.shift_pressed)
				get_viewport().set_input_as_handled()
				return

func text_at(value: String, x: float, y: float, size: int = 16, color: Color = INK) -> void:
	draw_string(font, Vector2(x, y), value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func line(x: float, y: float, width: float) -> void:
	draw_line(Vector2(x, y), Vector2(x + width, y), Color("2a414c"), 1)

func bar(rect: Rect2, fraction: float, color: Color) -> void:
	draw_rect(rect, Color("293c44"))
	if fraction > 0:
		draw_rect(Rect2(rect.position, Vector2(rect.size.x * clampf(fraction, 0, 1), rect.size.y)), color)

func _place_button(key: String, rect: Rect2, show_button: bool = true) -> void:
	buttons[key].position = rect.position
	buttons[key].size = rect.size
	buttons[key].visible = show_button

func _draw() -> void:
	var size := get_viewport_rect().size
	var x := size.x - sidebar
	var modal: bool = game.phase != "playing"
	# Global frame.
	draw_rect(Rect2(0, 0, size.x, 78), Color("101e27"))
	draw_rect(Rect2(0, 77, size.x, 1), Color("3b555f"))
	text_at("B A L A N C E", 28, 38, 25)
	text_at("TACTICAL PROTOTYPE  /  0.1", 30, 60, 11, MUTED)
	text_at("01   /   FIRST CONTACT", 300, 34, 17)
	text_at("KORALI EXPEDITION     ·     THE SHATTERED BASIN", 300, 56, 11, MUTED)
	var minutes := int(game.elapsed / 60)
	var seconds := int(game.elapsed) % 60
	text_at("%02d:%02d" % [minutes, seconds], x - 100, 46, 22, INK)
	_place_button("pause", Rect2(size.x - 60, 21, 36, 35), not modal)
	text_at("COMMAND", x + 24, 45, 13, MINT)
	# Right command panel.
	draw_rect(Rect2(x, 78, sidebar, size.y - 78), PANEL)
	draw_line(Vector2(x, 78), Vector2(x, size.y), Color("3b555f"))
	text_at("MISSION OBJECTIVE", x + 24, 112, 11, MUTED)
	text_at("Secure the Korali", x + 24, 144, 23)
	text_at("Hold the ring for 40 seconds.", x + 24, 173, 14, MUTED)
	text_at("Or defeat the opposing patrol.", x + 24, 194, 14, MUTED)
	var state_color := MINT
	if game.capture_state == "CONTESTED": state_color = Color("f0d690")
	if game.capture_state == "RED SECURING": state_color = RED
	text_at(game.capture_state, x + 24, 226, 13, state_color)
	for team in range(2):
		var y := 249.0 + team * 36
		text_at("BLUE" if team == 0 else "RED", x + 24, y, 11, BLUE if team == 0 else RED)
		text_at("%02d / 40s" % int(game.scores[team]), x + 208, y, 11, MUTED)
		bar(Rect2(x + 24, y + 8, 256, 5), game.scores[team] / 40.0, BLUE if team == 0 else RED)
	line(x + 24, 315, 256)
	text_at("EXPEDITION", x + 24, 341, 11, MUTED)
	text_at("%d / 4 ACTIVE" % game.living(0).size(), x + 185, 341, 11, BLUE)
	card_rects.clear()
	for i in range(4):
		var unit: Node3D = game.units[i]
		var rect := Rect2(x + 16, 356 + i * 67, 272, 59)
		card_rects.append(rect)
		draw_rect(rect, Color("243e4c") if unit.selected else Color("172b35"))
		if unit.selected: draw_rect(Rect2(rect.position, Vector2(3, rect.size.y)), BLUE)
		var c := BLUE if unit.alive else MUTED
		draw_circle(rect.position + Vector2(23, 26), 10, Color("34576a") if unit.alive else Color("29363b"))
		text_at("+" if unit.leader else str(i + 1), x + 33, rect.position.y + 31, 16, c)
		text_at(unit.callsign, x + 57, rect.position.y + 23, 15, INK if unit.alive else MUTED)
		text_at(unit.role if unit.alive else "FALLEN", x + 57, rect.position.y + 40, 10, MUTED)
		text_at("%d" % int(unit.health), x + 243, rect.position.y + 26, 14, c)
		bar(Rect2(x + 57, rect.position.y + 48, 210, 3), unit.health / unit.max_health, c)
	var y := 635.0
	_place_button("heal", Rect2(x + 24, y, 256, 43), not modal)
	buttons.heal.disabled = game.heal_cooldown > 0 or not game.units[0].alive
	buttons.heal.text = "Q   HEALING PULSE" if game.heal_cooldown <= 0 else "HEALING   ·   %ds" % ceili(game.heal_cooldown)
	if not game.units[0].alive: buttons.heal.text = "CAPTAIN FALLEN"
	text_at("+45 HP nearby  /  16s cooldown", x + 30, y + 63, 12, MUTED)
	_place_button("select", Rect2(x + 24, y + 82, 256, 35), not modal)
	_place_button("advance", Rect2(x + 24, y + 126, 158, 35), not modal)
	_place_button("hold", Rect2(x + 190, y + 126, 90, 35), not modal)
	buttons.hold.text = "H   HOLD"
	text_at("%d SELECTED" % game.selected.size(), x + 24, size.y - 29, 12, BLUE)
	text_at("%d HOSTILES" % game.living(1).size(), x + 186, size.y - 29, 12, RED)
	# Bottom instruction strip.
	draw_rect(Rect2(0, size.y - 58, x, 58), Color("101e27"))
	text_at("LMB  Select / drag     SHIFT  Add     RMB  Move / attack     A + click  Attack-move", 25, size.y - 34, 13)
	text_at("1  Squad     Q  Heal     H  Hold     F  Focus     Arrows / IJKL  Pan     Wheel  Zoom     Space  Pause", 25, size.y - 13, 12, MUTED)
	# World health bars and selection marquee.
	if not modal:
		for unit in game.units:
			if not unit.alive: continue
			var screen: Vector2 = game.camera.unproject_position(unit.position + Vector3.UP * 2.35)
			if screen.x < 28 or screen.x > x - 28 or screen.y < 100 or screen.y > size.y - 100: continue
			var width := 46.0 if not unit.leader else 56.0
			draw_rect(Rect2(screen.x - width / 2 - 2, screen.y - 2, width + 4, 8), Color("0c1a20"))
			bar(Rect2(screen.x - width / 2, screen.y, width, 4), unit.health / unit.max_health, BLUE if unit.team == 0 else RED)
			if unit.leader: text_at("LEADER", screen.x - 22, screen.y - 8, 10, INK)
		if game.dragging:
			var box := Rect2(game.drag_origin, game.drag_position - game.drag_origin).abs()
			draw_rect(box, Color(0.4, 0.8, 1, 0.12))
			draw_rect(box, BLUE, false, 1)
		if game.notification_timer > 0:
			var width := minf(x - 48, font.get_string_size(game.status_message, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x + 32)
			draw_rect(Rect2(24, 96, width, 36), Color(0.055, 0.105, 0.13, 0.94))
			text_at(game.status_message, 40, 120, 15, MINT if not game.attack_armed else Color("f0d690"))
	# Briefing, pause, and result all use the same readable mission panel.
	buttons.primary.visible = modal
	buttons.restart.visible = game.phase == "paused"
	if modal:
		_draw_modal(size)

func _draw_modal(size: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.015, 0.035, 0.05, 0.76))
	var origin := (size - Vector2(650, 482)) / 2
	draw_rect(Rect2(origin, Vector2(650, 482)), Color("142832"))
	draw_rect(Rect2(origin, Vector2(650, 3)), MINT)
	var x := origin.x + 38
	var y := origin.y
	var title := "First Contact"
	var kicker := "MISSION 01   /   THE SHATTERED BASIN"
	var lines: Array[String] = [
		"A Korali deposit has surfaced in the basin. A Red patrol",
		"is approaching. Lead your four-person expedition to secure it.",
		"Hold the marked ring uncontested for 40 cumulative seconds,",
		"or defeat the enemy squad. Contested time does not count.",
		"Keep your Captain close. Q heals injured allies nearby.",
		"Every soldier matters. There are no reinforcements."]
	if game.phase == "paused":
		kicker = "TACTICAL PAUSE"
		title = "Take a breath."
		lines = ["The battle is paused.", "", "Right-click ground to move; right-click an enemy to focus fire.", "A then left-click advances while engaging enemies.", "Q heals around your Captain. H holds your selected troops.", "Scroll to zoom. Arrows pan. F returns to your squad."]
	elif game.phase == "ended":
		kicker = "MISSION COMPLETE" if game.winner == 0 else "MISSION FAILED"
		title = "The basin is yours." if game.winner == 0 else "The expedition fell."
		lines = [game.result_reason, "", "Expedition survivors: %d / 4" % game.living(0).size(), "Blue control: %ds     /     Red control: %ds" % [int(game.scores[0]), int(game.scores[1])], "", "Try a different approach. Keep wounded troops behind the line."]
	text_at(kicker, x, y + 43, 12, MINT)
	text_at(title, x, y + 95, 38)
	line(x, y + 119, 574)
	for i in range(lines.size()):
		text_at(lines[i], x, y + 154 + i * 29, 16, INK if i < 2 else MUTED)
	text_at("SELECT → MOVE → ENGAGE → PRESERVE", x, y + 356, 12, MINT)
	buttons.primary.text = "DEPLOY EXPEDITION   →" if game.phase == "briefing" else ("RESUME   →" if game.phase == "paused" else "REPLAY MISSION   →")
	_place_button("primary", Rect2(x, y + 386, 574 if game.phase != "paused" else 300, 52))
	if game.phase == "paused":
		_place_button("restart", Rect2(x + 315, y + 386, 259, 52))
	text_at("ORIGINAL PLACEHOLDER ART  ·  EARLY GAMEPLAY BUILD", x, y + 462, 10, MUTED)
