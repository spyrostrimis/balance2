extends SceneTree
## The art integration must follow simulation state without changing its timing.
const Battle = preload("res://scripts/battle.gd")
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition: failures += 1
	print("PASS: " if condition else "FAIL: ", description)

func run() -> void:
	var battle := Battle.new()
	root.add_child(battle)
	battle.set_process(false)
	battle.set_physics_process(false)
	var captain: Node3D = battle.units[0]
	var scout: Node3D = battle.units[2]
	var heavy: Node3D = battle.units[3]
	var enemy: Node3D = battle.units[4]
	var all_skinned := true
	for unit in battle.units:
		all_skinned = all_skinned and unit.actor.rig.get_bone_count() == 62
	check(all_skinned, "All eight mission units use the animated skeleton")
	check(battle.units[5].actor.style == "red_trooper" and not battle.units[5].actor.rig.has_node("Adventurer_Head"), "Red regular troops use the helmeted soldier assembly")
	check(heavy.actor.model.scale.x > scout.actor.model.scale.x and heavy.actor.rig.has_node("RoleEquipment"), "Heavy and scout have different silhouettes")
	var blue_material: Material = battle.units[1].actor.rig.get_node("Swat_Body").get_surface_override_material(0)
	var red_material: Material = battle.units[5].actor.rig.get_node("Swat_Body").get_surface_override_material(0)
	check(blue_material != red_material, "Opposing squads do not share editable materials")
	battle.start_battle()
	captain.issue_move(Vector3(-8, 0, -2.7))
	for frame in range(30): battle.step_simulation(1.0 / 60)
	check(captain.actor.clip == "Run", "Moving unit plays a locomotion animation")
	battle.toggle_pause()
	var pose_time: float = captain.actor.animation_player.current_animation_position
	battle.step_simulation(1)
	battle._process(0.5)
	check(is_equal_approx(pose_time, captain.actor.animation_player.current_animation_position), "Pause freezes skeletal animation as well as movement")
	battle.toggle_pause()
	captain.stop()
	captain.step(0.02)
	check(captain.actor.clip == "Idle_Gun", "Hold returns an unengaged soldier to idle")
	enemy.position = captain.position + Vector3(3, 0, 0)
	captain.issue_attack(enemy)
	captain.attack_timer = 0
	var previous_health: float = enemy.health
	captain.step(0.02)
	check(captain.actor.clip == "Idle_Gun_Shoot" and enemy.health == previous_health - captain.damage, "A real shot drives the firing pose and deals damage once")
	var shot_origin: Vector3 = captain.actor.muzzle_position()
	var hand: Vector3 = captain.actor.rig.to_global(captain.actor.rig.get_bone_global_pose(captain.actor.rig.find_bone("Wrist.R")).origin)
	check(shot_origin.distance_to(hand) < 0.5 and shot_origin.y > 1.0, "Shot originates at the raised weapon, near the animated hand")
	for frame in range(20): captain.step(1.0 / 60)
	check(captain.actor.clip == "Idle_Gun_Pointing", "Between shots the soldier keeps aiming without looping recoil")
	captain.take_damage(1000)
	check(captain.actor.clip == "Death" and not captain.selection_ring.visible and not captain.faction_ring.visible, "Fallen soldiers animate and lose their living-unit markers")
	battle.finish(1, "Visual check")
	var elapsed: float = battle.elapsed
	var living_pose: float = scout.actor.animation_player.current_animation_position
	for frame in range(180): battle._process(1.0 / 60)
	check(not captain.actor.animation_player.is_playing() and battle.elapsed == elapsed and scout.actor.animation_player.current_animation_position == living_pose, "Final casualty finishes falling while result-screen simulation stays frozen")
	battle.free()
	print("UNIT VISUAL RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
