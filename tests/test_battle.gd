extends SceneTree
## Run: godot --headless --path . --script res://tests/test_battle.gd
const Battle = preload("res://scripts/battle.gd")
var failures := 0
var checks := 0
var battle: Node3D

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func fresh() -> void:
	if is_instance_valid(battle):
		battle.free()
	battle = Battle.new()
	root.add_child(battle)
	battle.set_physics_process(false)
	battle.set_process(false)

func run() -> void:
	fresh()
	check(battle.units.size() == 8 and battle.selected.size() == 4, "Four troops per side, Blue squad selected")
	check(battle.phase == "briefing", "Mission waits for deployment")
	battle.step_simulation(10)
	check(battle.elapsed == 0, "Briefing freezes simulation")
	battle.start_battle()
	var path: PackedVector3Array = battle.arena.path_between(Vector3(-10, 0, 0), Vector3(10, 0, 0))
	var avoids_ore := not path.is_empty()
	for point in path:
		avoids_ore = avoids_ore and battle.arena.walkable(point) and Vector2(point.x, point.z).length() >= 2
	check(avoids_ore, "Path crosses the arena without passing through the ore")
	var unit: Node3D = battle.units[0]
	unit.issue_move(Vector3(10, 0, 0))
	var stayed_walkable := true
	for i in range(1000):
		unit.step(1.0 / 60)
		stayed_walkable = stayed_walkable and battle.arena.walkable(unit.position)
	check(stayed_walkable and unit.position.distance_to(Vector3(10, 0, 0)) < 1, "Movement arrives on the far side of the rock")
	var inside_ore: PackedVector3Array = battle.arena.path_between(unit.position, Vector3.ZERO)
	check(not inside_ore.is_empty() and battle.arena.walkable(inside_ore[-1]), "Clicking solid ore resolves to a reachable adjacent point")

	fresh()
	battle.start_battle()
	unit = battle.units[2]
	unit.position = Vector3(-16, 0, 9)
	unit.issue_patrol(Vector3(-16, 0, 3))
	var returned := false
	var reached_end := false
	for frame in range(900):
		unit.step(1.0 / 60)
		if unit.position.distance_to(unit.patrol_end) < 1.2: reached_end = true
		if reached_end and unit.position.distance_to(unit.patrol_origin) < 1.2: returned = true
	check(reached_end and returned and unit.patrol_active, "Patrol reaches its endpoint and returns without a second order")
	unit.stop()
	check(not unit.patrol_active and unit.path.is_empty(), "Stop cancels the repeating patrol")
	unit.issue_patrol(Vector3(-16, 0, 3))
	unit.issue_move(Vector3(-18, 0, 9))
	check(not unit.patrol_active and unit.order == "move", "A new move order replaces patrol")
	battle.arm_command("patrol")
	battle.toggle_pause()
	check(not battle.has_armed_command(), "Pausing clears pending command targeting")

	fresh()
	battle.start_battle()
	check(not battle.heal() and battle.heal_cooldown == 0, "Full-health healing does not waste cooldown")
	battle.units[0].health = 100
	battle.units[1].health = 70
	battle.units[2].health = 20
	battle.units[2].position = Vector3(15, 0, 10)
	check(battle.heal(), "Injured squad can use healing")
	check(battle.units[0].health == 145 and battle.units[1].health == 110, "Healing restores 45 and clamps to max health")
	check(battle.units[2].health == 20, "Healing does not affect distant allies")
	check(not battle.heal(), "Healing cannot bypass cooldown")
	var location: Vector3 = battle.units[0].position
	battle.toggle_pause()
	battle.step_simulation(20)
	check(battle.elapsed == 0 and battle.heal_cooldown == 16 and battle.units[0].position == location, "Pause freezes time, movement, and cooldowns")
	battle.toggle_pause()
	battle.units[0].take_damage(1000)
	battle.heal_cooldown = 0
	check(not battle.heal(), "Fallen Captain cannot heal")
	check(battle.selected.size() == 3, "Dead soldiers leave selection")

	fresh()
	battle.start_battle()
	battle.units[0].position = Vector3(-3, 0, 0)
	battle._update_capture(5)
	check(battle.scores[0] == 5 and battle.scores[1] == 0, "Blue gains control time while alone inside the ring")
	battle.units[4].position = Vector3(3, 0, 0)
	battle._update_capture(8)
	check(battle.capture_state == "CONTESTED" and battle.scores[0] == 5 and battle.scores[1] == 0, "Contested presence freezes both scores")
	battle.units[0].position = Vector3(-10, 0, 0)
	battle._update_capture(4)
	check(battle.scores[0] == 5 and battle.scores[1] == 4, "Progress persists; Red also captures")
	battle.units[4].position = Vector3(12, 0, 0)
	battle._update_capture(8)
	check(battle.capture_state == "NEUTRAL" and battle.scores[1] == 4, "Empty ring does not generate control time")
	battle.units[0].position = Vector3(-3, 0, 0)
	battle._update_capture(35)
	check(battle.phase == "ended" and battle.winner == 0, "Forty cumulative seconds grants victory")
	var final_time: float = battle.elapsed
	battle.step_simulation(10)
	check(battle.elapsed == final_time, "Result screen freezes the simulation")

	fresh()
	battle.start_battle()
	for enemy in battle.living(1): enemy.take_damage(1000)
	battle.step_simulation(0.02)
	check(battle.winner == 0 and battle.phase == "ended", "Eliminating all enemies grants victory")

	fresh()
	battle.start_battle()
	for ally in battle.living(0): ally.take_damage(1000)
	battle.step_simulation(0.02)
	check(battle.winner == 1 and battle.phase == "ended", "Losing the squad causes defeat")

	fresh()
	battle.start_battle()
	for frame in range(5400):
		battle.step_simulation(1.0 / 60)
		if frame % 120 == 0: await process_frame
		if battle.phase == "ended": break
	check(battle.phase == "ended" and battle.winner == 1, "Unopposed AI reaches and captures Korali")

	fresh()
	battle.start_battle()
	battle.command_move(Vector3(-2.8, 0, 0), true)
	var shots_fired := false
	for frame in range(7200):
		battle.step_simulation(1.0 / 60)
		if frame % 60 == 0:
			if battle.units[0].health < 125: battle.heal()
			await process_frame
		if battle.units[4].health < battle.units[4].max_health: shots_fired = true
		if battle.phase == "ended": break
	check(shots_fired, "Advancing squads engage with weapons")
	check(battle.phase == "ended", "Full skirmish resolves within two minutes")
	print("SKIRMISH: winner=", battle.winner, " time=", snappedf(battle.elapsed, 0.1), " survivors=", battle.living(0).size())

	fresh()
	battle.start_battle()
	battle.command_move(Vector3(-3, 0, 0), true)
	for frame in range(7200):
		if frame % 60 == 0:
			var enemies: Array[Node3D] = battle.living(1)
			if not enemies.is_empty():
				var priority: Node3D = enemies[0]
				for enemy in enemies:
					if enemy.health < priority.health: priority = enemy
				for ally in battle.living(0): ally.issue_attack(priority)
			var missing_health := 0.0
			for ally in battle.living(0): missing_health += ally.max_health - ally.health
			if missing_health > 60: battle.heal()
			await process_frame
		battle.step_simulation(1.0 / 60)
		if battle.phase == "ended": break
	check(battle.phase == "ended" and battle.winner == 0, "Focused attacks and healing provide a winning player strategy")
	print("TACTICAL SKIRMISH: winner=", battle.winner, " time=", snappedf(battle.elapsed, 0.1), " survivors=", battle.living(0).size())
	battle.free()
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
