extends Node3D
## Biological soldier under removable prototype armor. Simulation is stepped
## by Battle, so pause, victory, and headless tests share the same behavior.

const Art = preload("res://scripts/shapes.gd")
var game: Node3D
var team := 0
var leader := false
var callsign := "Rifleman"
var role := "RIFLEMAN"
var max_health := 110.0
var health := 110.0
var damage := 12.0
var weapon_range := 5.6
var speed := 3.1
var attack_interval := 0.95
var attack_timer := 0.0
var alive := true
var selected := false
var order := "guard"
var target: Node3D
var destination := Vector3.ZERO
var path := PackedVector3Array()
var repath_timer := 0.0
var actor: Node3D
var selection_ring: MeshInstance3D
var legs: Array[MeshInstance3D] = []
var stride := 0.0
var flash_timer := 0.0

func configure(battle: Node3D, faction: int, index: int) -> void:
	game = battle
	team = faction
	leader = index == 0
	callsign = ["Captain", "Vanguard", "Ranger", "Sentinel"][index] if team == 0 else ["Commander", "Raider", "Stalker", "Enforcer"][index]
	role = ["LEADER", "RIFLEMAN", "SCOUT", "HEAVY"][index]
	max_health = [170.0, 110.0, 95.0, 145.0][index]
	health = max_health
	damage = [15.0, 12.0, 10.0, 18.0][index]
	weapon_range = [5.8, 5.6, 6.8, 5.0][index]
	speed = [3.0, 3.1, 3.8, 2.6][index]
	attack_interval = [1.0, 0.95, 0.8, 1.35][index]
	attack_timer = index * 0.17

func _ready() -> void:
	var color := Color("499ce0") if team == 0 else Color("c94f49")
	var armor := Art.material(color)
	var dark := Art.material(Color("283c49"))
	var skin := Art.material(Color("c89471"))
	var accent := Art.material(Color("b5ebff") if team == 0 else Color("ffdba3"), 0.5)
	actor = Node3D.new()
	add_child(actor)
	var bulk := 1.17 if role == "HEAVY" else 1.0
	Art.box(actor, Vector3(0, 0.97, 0), Vector3(0.57 * bulk, 0.65, 0.36), armor)
	Art.box(actor, Vector3(0, 0.87, 0.22), Vector3(0.38, 0.47, 0.18), dark)
	Art.box(actor, Vector3(0, 1.47, 0), Vector3(0.36, 0.36, 0.34), skin)
	Art.box(actor, Vector3(0, 1.65, 0.02), Vector3(0.42, 0.14, 0.4), armor)
	Art.box(actor, Vector3(0, 1.5, -0.18), Vector3(0.32, 0.1, 0.04), dark)
	for side in [-1, 1]:
		Art.box(actor, Vector3(side * 0.4 * bulk, 1.14, 0), Vector3(0.25, 0.3, 0.4), armor)
		Art.box(actor, Vector3(side * 0.4 * bulk, 0.88, -0.13), Vector3(0.19, 0.36, 0.21), dark)
		legs.append(Art.box(actor, Vector3(side * 0.18, 0.39, 0), Vector3(0.23, 0.65, 0.25), dark))
		Art.box(actor, Vector3(side * 0.18, 0.12, -0.08), Vector3(0.27, 0.2, 0.43), armor)
	Art.box(actor, Vector3(0.38, 0.93, -0.5), Vector3(0.15 if role != "HEAVY" else 0.25, 0.18, 0.75), dark)
	Art.box(actor, Vector3(0.38, 0.93, -0.9), Vector3(0.1, 0.1, 0.08), accent)
	Art.box(actor, Vector3(0, 1.12, -0.2), Vector3(0.19, 0.12, 0.04), accent)
	if leader:
		Art.box(actor, Vector3(-0.2, 1.35, 0.24), Vector3(0.12, 0.72, 0.08), accent)
		Art.box(actor, Vector3(0, 0.75, 0.29), Vector3(0.5, 0.7, 0.06), armor)
		actor.scale = Vector3.ONE * 1.12
	selection_ring = Art.ring(self, 0.7, Color("b2efff"), 0.04)
	selection_ring.visible = false
	# Ground faction badge remains visible without selection.
	Art.ring(self, 0.46, color, 0.024)
	rotation.y = -PI / 2 if team == 0 else PI / 2

func set_selected(value: bool) -> void:
	selected = value and alive
	selection_ring.visible = selected

func issue_move(point: Vector3, attack_move: bool = false) -> void:
	if not alive:
		return
	order = "advance" if attack_move else "move"
	target = null
	destination = point
	path = game.arena.path_between(position, point)

func issue_attack(enemy: Node3D) -> void:
	if not alive or not is_instance_valid(enemy) or not enemy.alive:
		return
	order = "attack"
	target = enemy
	repath_timer = 0.0
	path.clear()

func stop() -> void:
	order = "guard"
	target = null
	path.clear()

func step(delta: float) -> void:
	if not alive:
		return
	attack_timer = maxf(0, attack_timer - delta)
	repath_timer -= delta
	if is_instance_valid(target) and not target.alive:
		target = null
		if order == "attack":
			stop()
	if order != "move":
		if not is_instance_valid(target):
			target = game.nearest_enemy(self, weapon_range + (1.5 if order == "advance" else 0.0))
		if is_instance_valid(target):
			var distance := position.distance_to(target.position)
			if distance <= weapon_range:
				_face(target.position, delta)
				if attack_timer <= 0:
					attack_timer = attack_interval
					game.fire(self, target)
				return
			elif order == "attack" or order == "advance":
				if repath_timer <= 0:
					path = game.arena.path_between(position, target.position)
					repath_timer = 0.6
			else:
				target = null
	if order == "guard":
		return
	if path.is_empty():
		if order == "move":
			stop()
		elif order == "advance" and not is_instance_valid(target):
			if position.distance_to(destination) > 1.2:
				path = game.arena.path_between(position, destination)
			else:
				stop()
		return
	var waypoint := path[0]
	if position.distance_to(waypoint) < 0.2:
		path.remove_at(0)
		return
	var direction := position.direction_to(waypoint)
	var separation := Vector3.ZERO
	for other in game.units:
		if other == self or not other.alive:
			continue
		var offset: Vector3 = position - other.position
		offset.y = 0
		var distance: float = offset.length()
		if distance > 0.01 and distance < 0.85:
			separation += offset.normalized() * (0.85 - distance) * 2.0
	var movement := (direction + separation).limit_length() * minf(speed * delta, position.distance_to(waypoint))
	var next := position + movement
	if game.arena.walkable(next):
		position = next
	else:
		position = position.move_toward(waypoint, speed * delta)
	_face(waypoint, delta)
	stride += delta * speed * 3.5
	actor.position.y = absf(sin(stride)) * 0.045
	for i in range(legs.size()):
		legs[i].rotation.x = sin(stride + i * PI) * 0.35

func _face(point: Vector3, delta: float) -> void:
	var difference := point - position
	if difference.length_squared() > 0.01:
		rotation.y = lerp_angle(rotation.y, atan2(-difference.x, -difference.z), delta * 12)

func take_damage(amount: float) -> void:
	if not alive:
		return
	health = maxf(0, health - amount)
	if health <= 0:
		alive = false
		set_selected(false)
		actor.rotation.z = PI * 0.48
		actor.position.y = 0.15
		path.clear()
		game.on_unit_lost(self)
