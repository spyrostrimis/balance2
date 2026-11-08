shader_type spatial;
render_mode cull_disabled, diffuse_burley;
uniform vec4 leaf_color : source_color = vec4(0.3, 0.5, 0.4, 1.0);
void vertex() {
	float phase = TIME * 1.35 + MODEL_MATRIX[3].x * 0.7 + MODEL_MATRIX[3].z * 0.3;
	float tip = max(0.0, VERTEX.y);
	VERTEX.x += sin(phase) * tip * 0.07;
	VERTEX.z += cos(phase * 0.8) * tip * 0.035;
}
void fragment() {
	ALBEDO = leaf_color.rgb;
	ROUGHNESS = 0.92;
}
