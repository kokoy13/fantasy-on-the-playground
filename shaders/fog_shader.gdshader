shader_type canvas_item;

uniform vec4 fog_color : source_color = vec4(0.15, 0.2, 0.2, 0.95);
uniform vec2 player_world_pos; 
uniform float hole_radius : hint_range(0.0, 500.0) = 70.0;
uniform float blur_amount : hint_range(0.0, 300.0) = 40.0;
uniform float fog_opacity : hint_range(0.0, 1.0) = 0.0; 

// 🔥 UNIFORM BARU: Sistem Array untuk Lentera
const int MAX_LANTERNS = 10;
uniform vec2 lantern_positions[10];
uniform float lantern_radii[10];
uniform int active_lantern_count = 0;

void fragment() {
    // 1. Hitung lubang pandang bawaan milik Charlotte
    float dist_player = distance(FRAGCOORD.xy, player_world_pos);
    float player_mask = smoothstep(hole_radius, hole_radius + blur_amount, dist_player);
    
    // Tampung hasil masking awal dari player
    float final_mask = player_mask;
    
    // 2. LOOPING: Tembus kabut di setiap titik koordinat lentera yang aktif
    for (int i = 0; i < active_lantern_count; i++) {
        float dist_lantern = distance(FRAGCOORD.xy, lantern_positions[i]);
        float lantern_mask = smoothstep(lantern_radii[i], lantern_radii[i] + blur_amount, dist_lantern);
        
        // Menggunakan min() artinya jika daerah tersebut sudah dibuka oleh lentera / player, 
        // kabutnya akan otomatis mengalah dan ikut bolong (Transparan = 0.0)
        final_mask = min(final_mask, lantern_mask);
    }
    
    // 3. Aplikasikan ketebalan kabut global
    vec4 final_color = fog_color;
    final_color.a *= final_mask * fog_opacity; 
    
    COLOR = final_color;
}