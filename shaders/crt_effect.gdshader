shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float curvature : hint_range(0.0, 1.0) = 0.1;
uniform float scanline_count : hint_range(100.0, 1000.0) = 300.0; //
uniform float scanline_opacity : hint_range(0.0, 1.0) = 0.25;
uniform float grille_opacity : hint_range(0.0, 1.0) = 0.1; //

// Parameter baru untuk efek glitch transisi
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0;

vec2 distort(vec2 uv) {
	vec2 delta = uv - vec2(0.5);
	float dist = dot(delta, delta); //
	return vec2(0.5) + delta * (1.0 + dist * curvature * (1.0 + dist * curvature)); //
}

// Fungsi pembantu untuk menghasilkan nilai acak berdasarkan koordinat
float rand(vec2 co) {
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
	vec2 distorted_uv = distort(SCREEN_UV);
	
	// Efek Glitch Gelombang Horizontal
	if (glitch_intensity > 0.0) {
		float dynamic_glitch = glitch_intensity * 0.1;
		distorted_uv.x += sin(distorted_uv.y * 50.0 + TIME * 40.0) * dynamic_glitch * rand(vec2(TIME));
		distorted_uv.y += cos(distorted_uv.x * 50.0 + TIME * 40.0) * dynamic_glitch * 0.2 * rand(vec2(TIME));
	}
	
	vec4 screen_color = texture(SCREEN_TEXTURE, distorted_uv);
	
	float scanline = sin(distorted_uv.y * scanline_count * PI * 2.0); //
	scanline = (scanline + 1.0) / 2.0;
	scanline = mix(1.0, scanline, scanline_opacity); //
	screen_color.rgb *= scanline;
	
	float grille = sin(distorted_uv.x * (scanline_count * 1.33) * PI * 2.0);
	grille = (grille + 1.0) / 2.0; //
	grille = mix(1.0, grille, grille_opacity);
	screen_color.rgb *= grille;
	
	COLOR = screen_color;
}