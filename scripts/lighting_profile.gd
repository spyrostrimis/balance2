extends RefCounted
## Shared Lighting 01/02. Copies materials; never edits imported/shared resources.
## Construct after the mission arena is ready. set_mode(0) restores exact inputs.
## Lighting 02: on Forward+, the same recipe adds the screen-space profile
## (SSAO, SSIL, soft sun, restrained glow) and re-exposes, since Forward+ renders
## the Lighting 01 values about a quarter darker than Compatibility did.
const SUN := {
	"rotation_degrees": Vector3(-38, -36, 0),
	"light_color": Color("fff0da"), "light_energy": .95,
	"shadow_bias": .08, "shadow_normal_bias": 1.5,
	"directional_shadow_max_distance": 95.0,
	"directional_shadow_blend_splits": true,
	"sky_mode": DirectionalLight3D.SKY_MODE_LIGHT_ONLY,
}
const FORWARD_SUN := {
	"light_energy": .95 * 1.55, "light_angular_distance": 1.1,
	"directional_shadow_mode": DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS,
	"shadow_bias": .04, "shadow_normal_bias": 1.2,
}
const FORWARD_AMBIENT_ENERGY := .50 * 1.70
const SAND_TINT := Vector3(1.05, 1.025, .98)
const STONE_TINT := Vector3(1.06, 1.035, 1.04)
var world: WorldEnvironment
var sun: DirectionalLight3D
var original_environment: Environment
var candidate_environment: Environment
var original_sun := {}
var bindings: Array[Dictionary] = []
var material_cache := {}
var mode := 0
var screen_space := false # Lighting 02 profile; only meaningful on Forward+.

func _init(arena: Node3D, environment: WorldEnvironment, light: DirectionalLight3D) -> void:
	world = environment
	sun = light
	original_environment = world.environment
	for key in SUN: original_sun[key] = sun.get(key)
	for key in FORWARD_SUN: original_sun[key] = sun.get(key)
	candidate_environment = original_environment.duplicate()
	candidate_environment.ambient_light_color = Color("adc5e3")
	candidate_environment.ambient_light_energy = .50
	# Reflection only: explicit color ambient remains separate, background unchanged.
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("6d85a5")
	sky_material.sky_horizon_color = Color("b5b9bd")
	sky_material.ground_horizon_color = Color("a99b82")
	sky_material.ground_bottom_color = Color("625447")
	sky_material.sky_energy_multiplier = .45
	sky_material.ground_energy_multiplier = .45
	sky.sky_material = sky_material
	candidate_environment.sky = sky
	candidate_environment.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	# Lighting 01 itself adds no post-processing, fog, bloom or SSAO; Lighting 02
	# layers the Forward+ screen-space profile on top when that renderer runs.
	screen_space = RenderingServer.get_current_rendering_method() == "forward_plus"
	_configure_screen_space()
	for mesh in arena.find_children("*", "MeshInstance3D", true, false):
		if mesh.material_override:
			var tuned := _material(mesh.material_override)
			if tuned != mesh.material_override:
				bindings.append({"mesh": mesh, "slot": -1, "original": mesh.material_override, "tuned": tuned})
		else:
			for slot in range(mesh.mesh.get_surface_count()):
				var source: Material = mesh.get_active_material(slot)
				var tuned := _material(source)
				if tuned != source:
					bindings.append({"mesh": mesh, "slot": slot, "original": mesh.get_surface_override_material(slot), "tuned": tuned})

func set_mode(value: int) -> void:
	# 0 = previous lighting; 1 = light only; 2 = integrated light and materials.
	mode = clampi(value, 0, 2)
	world.environment = original_environment if mode == 0 else candidate_environment
	for key in SUN: sun.set(key, original_sun[key] if mode == 0 else SUN[key])
	for key in FORWARD_SUN:
		if mode > 0 and screen_space: sun.set(key, FORWARD_SUN[key])
		elif not SUN.has(key): sun.set(key, original_sun[key])
	for binding in bindings:
		var mat: Material = binding.tuned if mode == 2 else binding.original
		if binding.slot == -1: binding.mesh.material_override = mat
		else: binding.mesh.set_surface_override_material(binding.slot, mat)

func set_screen_space(enabled: bool) -> void:
	# Review toggle: Lighting 01 values alone versus the Lighting 02 profile.
	screen_space = enabled and RenderingServer.get_current_rendering_method() == "forward_plus"
	_configure_screen_space()
	set_mode(mode)

func _configure_screen_space() -> void:
	var env := candidate_environment
	env.ambient_light_energy = FORWARD_AMBIENT_ENERGY if screen_space else .50
	# Contact occlusion in joints, under arches and at every stone/sand contact.
	env.ssao_enabled = screen_space
	env.ssao_radius = 2.0
	env.ssao_intensity = 3.0
	env.ssao_power = 1.6
	env.ssao_detail = .6
	env.ssao_horizon = .08
	env.ssao_light_affect = .15
	env.ssao_ao_channel_affect = 0.0
	# Short-range bounce: faint warm sand light under the Gate and cliff feet.
	env.ssil_enabled = screen_space
	env.ssil_radius = 4.0
	env.ssil_intensity = .9
	env.ssil_sharpness = .9
	# Restrained glow: survey lamps and Korali highlights only; no haze.
	env.glow_enabled = screen_space
	env.glow_intensity = .25
	env.glow_strength = .9
	env.glow_bloom = 0.0
	env.glow_hdr_threshold = 1.35
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	env.adjustment_enabled = screen_space
	env.adjustment_contrast = 1.10
	env.adjustment_saturation = 1.08

func _material(source: Material) -> Material:
	if not source: return source
	if material_cache.has(source): return material_cache[source]
	var result: Material = source
	if source is ShaderMaterial:
		var shader_path: String = source.shader.resource_path
		if shader_path in ["res://shaders/terrain_sand.gdshader", "res://shaders/terrain_paving.gdshader", "res://shaders/debris_sand.gdshader"]:
			result = source.duplicate()
			result.set_shader_parameter("sand_tint", SAND_TINT)
			result.set_shader_parameter("normal_strength", .24 if "paving" in shader_path else .16)
			if "paving" in shader_path: result.set_shader_parameter("stone_tint", STONE_TINT)
	elif source is StandardMaterial3D:
		var recipe := _recipe(source.resource_name)
		if not recipe.is_empty():
			result = source.duplicate()
			result.albedo_color *= recipe[0]
			result.normal_scale = recipe[1]
			# Multiplies the existing roughness map, preserving spatial wear variation.
			result.roughness *= recipe[2]
	material_cache[source] = result
	return result

func _recipe(material_name: String) -> Array:
	match material_name:
		"cliff portable PBR": return [Color(.87, .91, .94), .55, 1.0]
		"Weathered sandstone PBR", "Debris rock PBR": return [Color(.96, .98, 1.0), .65, 1.0]
		"Gate II stone PBR", "Waterworks stone PBR", "Debris stone PBR":
			return [Color(STONE_TINT.x, STONE_TINT.y, STONE_TINT.z), .65, 1.0]
		"Waterworks damp PBR": return [Color(1.02, 1.02, 1.03), .65, 1.0]
		"Waterworks metal PBR", "Waterworks iron PBR", "Debris metal PBR":
			return [Color.WHITE, .65, .90]
		"Debris wood PBR": return [Color(.98, .98, 1.0), .65, 1.0]
	# Botanical vertex tints, cloth, characters and Korali keep their authored PBR.
	return []
