extends SceneTree
## Protect opt-in review isolation and exact restoration, not aesthetic acceptance.
const Profile = preload("res://scripts/lighting_profile.gd")
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	print("PASS: " if condition else "FAIL: ", label)
	if not condition: failures += 1

func material_state(mat: Material) -> Array:
	if mat is StandardMaterial3D:
		return [mat.albedo_color, mat.roughness, mat.normal_scale, mat.metallic, mat.albedo_texture, mat.normal_texture, mat.roughness_texture, mat.emission, mat.emission_energy_multiplier, mat.uv1_scale]
	if mat is ShaderMaterial:
		var result: Array = [mat.shader]
		for uniform in mat.shader.get_shader_uniform_list():
			result.append(mat.get_shader_parameter(uniform.name))
		return result
	return []

func run() -> void:
	var battle := preload("res://scenes/main.tscn").instantiate()
	check(battle.lighting_review, "Lighting 01 is enabled by default for the mission")
	battle.lighting_review = false # Audit exact original bindings, as the review viewer does.
	root.add_child(battle)
	battle.set_physics_process(false)
	battle.set_process(false)
	var world: WorldEnvironment
	var sun: DirectionalLight3D
	for child in battle.get_children():
		if child is WorldEnvironment: world = child
		if child is DirectionalLight3D: sun = child
	var env := world.environment
	var old_sun := {}
	for key in Profile.SUN: old_sun[key] = sun.get(key)
	var footprints: Array = battle.arena.obstacles.duplicate()
	var grid: Array[bool] = []
	for x in range(-21, 22):
		for z in range(-14, 15): grid.append(battle.arena.grid.is_point_solid(Vector2i(x, z)))
	var geometry := {}
	var materials := {}
	for mesh in battle.find_children("*", "MeshInstance3D", true, false):
		geometry[mesh] = [mesh.mesh, mesh.transform]
		for slot in range(mesh.mesh.get_surface_count()):
			var mat: Material = mesh.get_active_material(slot)
			if mat: materials[mat] = material_state(mat)
	var transforms: Array = []
	for unit in battle.units: transforms.append(unit.transform)
	var profile := Profile.new(battle.arena, world, sun)
	check(world.environment == env and profile.mode == 0, "Creating review profile leaves mission lighting untouched")
	check(battle.arena.terrain_review and battle.arena.waterworks_review and battle.arena.vegetation_review and battle.arena.debris_review, "All accepted integrations remain enabled")
	check(profile.bindings.size() > 30, "Runtime and imported arena meshes are both included")
	profile.set_mode(2)
	check(world.environment != env and world.environment.sky != null, "Candidate supplies its own reflection environment")
	check(not world.environment.glow_enabled and not world.environment.ssao_enabled and not world.environment.fog_enabled, "No masking post-processing or unsupported SSAO")
	var unchanged := true
	for mat in materials: unchanged = unchanged and materials[mat] == material_state(mat)
	check(unchanged, "Original materials, texture references, UV scales and emission stay unchanged")
	var intact := true
	for mesh in geometry: intact = intact and geometry[mesh] == [mesh.mesh, mesh.transform]
	for i in range(battle.units.size()): intact = intact and transforms[i] == battle.units[i].transform
	check(intact, "Every mesh resource/transform and all eight deployments stay unchanged")
	var nav_same: bool = footprints == battle.arena.obstacles
	var index := 0
	for x in range(-21, 22):
		for z in range(-14, 15):
			nav_same = nav_same and grid[index] == battle.arena.grid.is_point_solid(Vector2i(x, z))
			index += 1
	check(nav_same, "All 1247 navigation cells and registered footprints stay unchanged")
	profile.set_mode(1)
	var restored := true
	for binding in profile.bindings:
		var active: Material = binding.mesh.material_override if binding.slot == -1 else binding.mesh.get_surface_override_material(binding.slot)
		restored = restored and active == binding.original
	check(restored and world.environment == profile.candidate_environment, "Light-only comparison restores exact original material bindings")
	for i in range(3):
		profile.set_mode(2)
		profile.set_mode(0)
	for key in old_sun: restored = restored and sun.get(key) == old_sun[key]
	check(restored and world.environment == env, "Repeated before/after restores exact environment and sunlight")
	var integrated := preload("res://scenes/main.tscn").instantiate()
	root.add_child(integrated)
	integrated.set_physics_process(false)
	check(integrated.lighting_profile != null and integrated.lighting_profile.mode == 2, "Normal mission constructs and applies the full profile")
	print("Lighting isolation: %d failures" % failures)
	quit(1 if failures else 0)
