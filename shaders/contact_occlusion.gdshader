shader_type spatial;
// Compatibility-safe contact occlusion: a thin multiply skin where stone meets
// sand. Stands in for Decal/SSAO (unavailable in Compatibility). Vertex alpha
// carries the falloff, so it stays tied to the physical contact edge.
render_mode unshaded, blend_mul, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;
uniform vec3 occlusion_tint = vec3(.56, .50, .44);
uniform float strength = .55;
void fragment() {
	ALBEDO = mix(vec3(1.0), occlusion_tint, clamp(COLOR.a * strength, 0.0, 1.0));
}
