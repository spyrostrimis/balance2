shader_type spatial;
render_mode diffuse_burley;
uniform sampler2D stone_color : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D stone_normal : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D sand_color : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D sand_normal : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 position_world;
void vertex() { position_world = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz; }
float court(vec2 p, vec2 center, vec2 radius) {
    return 1.0 - smoothstep(.52, 1.02, length((p-center)/radius));
}
void fragment() {
    vec2 p=position_world.xz;
    float exposed=max(court(p,vec2(-10,-4),vec2(5.1,3.5)),court(p,vec2(10,-5),vec2(5.5,3.6)));
    exposed=max(exposed,court(p,vec2(-9,8),vec2(4.8,3.3)));
    exposed=max(exposed,court(p,vec2(10,8.8),vec2(5.3,3.4)));
    exposed=max(exposed,1.0-smoothstep(.9,1.8,abs(p.x)));
    vec3 sand=texture(sand_color,p/4.0).rgb;
    vec3 broad=texture(sand_color,mat2(vec2(.8,.6),vec2(-.6,.8))*p/13.0+.31).rgb;
    sand=mix(sand,broad,.24);
    sand=mix(sand,vec3(dot(sand,vec3(.299,.587,.114))),.22)*.83;
    // Shallow windblown burial across the perimeter of each surviving court.
    float grit=texture(sand_color,p/1.3).r;
    exposed=smoothstep(.08,.73,exposed+(grit-.5)*.50);
    ALBEDO=mix(sand*.86,texture(stone_color,UV).rgb,exposed*.96);
    NORMAL_MAP=mix(texture(sand_normal,p/4.0).rgb,texture(stone_normal,UV).rgb,exposed);
    NORMAL_MAP_DEPTH=.35;
    ROUGHNESS=.92;
}
