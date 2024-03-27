shader_type spatial;
render_mode cull_disabled, unshaded;

uniform vec4 tint : source_color = vec4(vec3(0.98),1.0);
uniform sampler2D mirror_tex : source_color, repeat_disable;

void vertex() {
	UV.x = 1.0 - UV.x;
}

void fragment() {
	vec2 m_UV = UV;
	
	if (!FRONT_FACING) {
		m_UV.x = 1.0 - m_UV.x;
	}
	
	vec4 mirror_sample = texture(mirror_tex,m_UV);
	ALBEDO = tint.rgb * mirror_sample.rgb;
}
