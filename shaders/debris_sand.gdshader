shader_type spatial;
render_mode diffuse_burley, depth_draw_never;
uniform sampler2D sand_color : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D sand_normal : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D rock_color : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 world_position;
void vertex() { world_position = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz; }
float court(vec2 p, vec2 center, vec2 radius) {return 1.0-smoothstep(.45,1.15,length((p-center)/radius));}
void fragment() {
    vec2 p=world_position.xz;
    // Use accepted terrain's world-space sample/grade and masks at the contact.
    vec3 sand=texture(sand_color,p/4.0).rgb;
    vec3 broad=texture(sand_color,mat2(vec2(.8,.6),vec2(-.6,.8))*p/13.0+.31).rgb;
    sand=mix(sand,broad,.24);
    sand=mix(sand,vec3(dot(sand,vec3(.299,.587,.114))),.22)*.83;
    float compacted=max(court(p,vec2(-10,-4),vec2(7,4.8)),court(p,vec2(10,-5),vec2(7.4,5)));
    compacted=max(compacted,court(p,vec2(-9,8),vec2(6.2,4.8)));
    compacted=max(compacted,court(p,vec2(10,8.8),vec2(6.5,4.8)));
    compacted=max(compacted,court(p,vec2(0),vec2(7,5)));
    float drift=1.0-smoothstep(.6,2.2,abs(p.x-(3.8+sin(p.y*.23)*1.8)));
    compacted*=1.0-drift*.68;
    float runoff=1.0-smoothstep(1.0,4.1,length(vec2((p.x+17.0)*.7,p.y+9.5)));
    float talus=max(smoothstep(18.5,24.0,abs(p.x)),smoothstep(13.8,20.0,-p.y)*smoothstep(6.0,11.0,abs(p.x)));
    vec3 color=mix(sand,sand*vec3(.63,.64,.64),compacted*.78);
    color=mix(color,texture(rock_color,p/2.7).rgb*vec3(.73,.76,.77),talus*.36);
    ALBEDO=mix(color,sand*vec3(.49,.60,.55),runoff*.45);
    NORMAL_MAP=texture(sand_normal,p/4.0).rgb;
    NORMAL_MAP_DEPTH=.20;
    ROUGHNESS=.96;
    // Feather silhouette without a decal node (Compatibility); no painted shadow.
    ALPHA=COLOR.a;
}
