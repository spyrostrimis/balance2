shader_type spatial;
render_mode diffuse_burley;
uniform vec4 stone_color : source_color = vec4(0.55, 0.34, 0.20, 1.0);
varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 p = world_position;
	float layer = sin(p.y * 7.5 + sin(p.x * 1.2 + p.z * 0.6) * 0.3);
	float fine = sin(p.y * 39.0 + sin(p.x * 2.0) * 1.5) * 0.025;
	float fleck = sin(p.x * 13.0 + p.z * 16.0) * sin(p.y * 18.0);
	float bands = smoothstep(0.72, 0.98, layer) * 0.065;
	ALBEDO = stone_color.rgb * (0.98 + fine - bands + fleck * 0.025);
	ROUGHNESS = 0.95;
}
