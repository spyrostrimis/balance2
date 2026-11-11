shader_type spatial;
render_mode diffuse_burley;
uniform vec3 sand_tint = vec3(1.0);
uniform float normal_strength = .20;
uniform sampler2D sand_color : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D sand_normal : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D rock_color : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 ground_position;
void vertex() { ground_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
    vec2 p = ground_position.xz;
    vec2 uv = p / 4.0;
    vec3 sand = texture(sand_color, uv).rgb;
    // A second, offset scale softens repeated source features. Broad distribution
    // is deliberately authored per vertex, not filled with procedural noise.
    vec3 broad = texture(sand_color, mat2(vec2(.8,.6),vec2(-.6,.8)) * p / 13.0 + .31).rgb;
    sand = mix(sand, broad, .24);
    sand = mix(sand, vec3(dot(sand, vec3(.299,.587,.114))), .22) * .83;
    sand *= sand_tint;
    vec3 compacted = sand * vec3(.63,.64,.64);
    vec3 grit = texture(rock_color, p / 2.7).rgb * vec3(.73,.76,.77);
    ALBEDO = mix(sand, compacted, COLOR.r * .78);
    ALBEDO = mix(ALBEDO, grit, COLOR.b * .36);
    ALBEDO = mix(ALBEDO, sand * vec3(.49,.60,.55), COLOR.g * .45);
    NORMAL_MAP = texture(sand_normal, uv).rgb;
    NORMAL_MAP_DEPTH = normal_strength;
    ROUGHNESS = .96;
}
