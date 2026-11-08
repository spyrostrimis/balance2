shader_type spatial;
render_mode cull_disabled;
uniform vec4 cloth_color : source_color = vec4(0.25, 0.12, 0.31, 1.0);
void vertex() {
	float free_edge = 1.0 - UV.y;
	VERTEX.z += sin(TIME * 1.8 + VERTEX.y * 2.8 + MODEL_MATRIX[3].x) * 0.09 * free_edge;
}
void fragment() {
	float weave = sin(UV.x * 120.0) * sin(UV.y * 180.0) * 0.025;
	ALBEDO = cloth_color.rgb * (0.92 + weave);
	ROUGHNESS = 1.0;
}
