extends Node3D
## Biological soldier with a shared animated character rig. Simulation is stepped
## by Battle, so pause, victory, and headless tests share the same behavior.

const Art = preload("res://scripts/shapes.gd")
const Character = preload("res://scripts/character_visual.gd")
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
var patrol_active := false
var patrol_origin := Vector3.ZERO
var patrol_end := Vector3.ZERO
var target: Node3D
var destination := Vector3.ZERO
var path := PackedVector3Array()
var repath_timer := 0.0
var actor: Node3D
var selection_ring: MeshInstance3D
var faction_ring: MeshInstance3D
var moving := false
var aiming := false
var shot_timer := 0.0

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
	var color := Color("286eac") if team == 0 else Color("a33d37")
	actor = Character.new()
	actor.style = ("blue" if team == 0 else "red") + ("_leader" if leader else "_trooper")
	actor.role = role
	add_child(actor)
	actor.scale = Vector3.ONE * (1.12 if leader else 1.0)
	selection_ring = Art.ring(self, 0.7, Color("b2efff"), 0.04)
	selection_ring.visible = false
	faction_ring = Art.ring(self, 0.46, color, 0.024)
	rotation.y = -PI / 2 if team == 0 else PI / 2

func set_selected(value: bool) -> void:
	selected = value and alive
	selection_ring.visible = selected

func issue_move(point: Vector3, attack_move: bool = false) -> void:
	if not alive:
		return
	order = "advance" if attack_move else "move"
	patrol_active = false
	target = null
	destination = point
	path = game.arena.path_between(position, point)

func issue_patrol(point: Vector3) -> void:
	if not alive: return
	patrol_origin = position
	var cell: Vector2i = game.arena.nearest_open(point)
	patrol_end = Vector3(cell.x, 0, cell.y)
	issue_move(patrol_end, true)
	patrol_active = true

func issue_attack(enemy: Node3D) -> void:
	if not alive or not is_instance_valid(enemy) or not enemy.alive:
		return
	order = "attack"
	patrol_active = false
	target = enemy
	repath_timer = 0.0
	path.clear()

func stop() -> void:
	order = "guard"
	patrol_active = false
	target = null
	path.clear()

func step(delta: float) -> void:
	moving = false
	aiming = false
	shot_timer = maxf(0, shot_timer - delta)
	_step_orders(delta)
	if alive:
		var next_clip := "Run" if moving else ("Idle_Gun_Shoot" if shot_timer > 0 else ("Idle_Gun_Pointing" if aiming else "Idle_Gun"))
		if actor.clip != next_clip: actor.play_clip(next_clip)
		actor.animation_player.speed_scale = speed / 3.1 if moving else 1.0
	actor.advance_animation(delta)

func _step_orders(delta: float) -> void:
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
				aiming = true
				_face(target.position, delta)
				if attack_timer <= 0:
					attack_timer = attack_interval
					shot_timer = 0.24
					actor.play_clip("Idle_Gun_Shoot", 0.0)
					actor.advance_animation(0)
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
		if patrol_active:
			if position.distance_to(destination) < 1.2:
				destination = patrol_origin if destination == patrol_end else patrol_end
			path = game.arena.path_between(position, destination)
		elif order == "move":
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
		# Advancing a path cursor is not a stop; keep the gait across waypoints.
		moving = not path.is_empty()
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
	moving = movement.length_squared() > 0.000001

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
		faction_ring.hide()
		actor.animation_player.speed_scale = 1.0
		actor.play_clip("Death")
		path.clear()
		game.on_unit_lost(self)
