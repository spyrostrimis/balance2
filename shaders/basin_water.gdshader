shader_type spatial;
render_mode diffuse_burley;
varying vec3 world_position;
void vertex() { world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
 vec2 p = world_position.xz;
 float wave = sin(p.x * 9.0 + p.y * 4.0 + TIME * 1.2) + sin(p.x * 5.0 + p.y * 11.0 - TIME * 0.8) * 0.4;
 ALBEDO = vec3(0.065, 0.20, 0.18) + wave * 0.009;
 ROUGHNESS = 0.3;
 METALLIC = 0.22;
}
