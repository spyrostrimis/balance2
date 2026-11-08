shader_type spatial;
render_mode diffuse_burley;
uniform vec4 stone_color : source_color = vec4(0.55, 0.34, 0.20, 1.0);
varying vec3 world_position;
float hash(vec3 p) { return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453); }
float noise(vec3 p) {
 vec3 c = floor(p), f = fract(p); f = f * f * (3.0 - 2.0 * f);
 return mix(mix(mix(hash(c), hash(c + vec3(1,0,0)), f.x), mix(hash(c + vec3(0,1,0)), hash(c + vec3(1,1,0)), f.x), f.y), mix(mix(hash(c + vec3(0,0,1)), hash(c + vec3(1,0,1)), f.x), mix(hash(c + vec3(0,1,1)), hash(c + vec3(1,1,1)), f.x), f.y), f.z);
}
void vertex() { world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
 vec3 p = world_position;
 float weather = noise(p * 0.75);
 float strata = noise(vec3(p.x * 0.19, p.y * 2.2, p.z * 0.19));
 float foot = 1.0 - smoothstep(0.0, 1.7, p.y);
 ALBEDO = stone_color.rgb * (0.85 + weather * 0.23 + strata * 0.08 + noise(p * 14.0) * 0.025 - foot * 0.07);
 ROUGHNESS = 0.96;
}
