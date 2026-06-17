extends Node2D

@onready var fog_canvas: CanvasLayer = $FogCanvas
@onready var fog_overlay: ColorRect = $FogCanvas/FogOverlay

var is_fog_active: bool = false
var fog_timer: float = 0.0
var fog_opacity_current: float = 0.0
var next_fog_check_timer: float = 10.0 

func _ready() -> void:
	if fog_overlay:
		fog_overlay.position = Vector2.ZERO
		fog_overlay.size = Vector2(1280, 720)
		fog_overlay.visible = true
	print("Sistem Manajemen Kabut & Siklus Lentera Siap.")

func _process(delta: float) -> void:
	handle_fog_logic(delta)
	update_shader_positions()

func handle_fog_logic(delta: float) -> void:
	var mat = fog_overlay.material as ShaderMaterial
	if not mat: return
	
	if is_fog_active:
		fog_opacity_current = move_toward(fog_opacity_current, 1.0, delta * 0.4)
		mat.set_shader_parameter("fog_opacity", fog_opacity_current)
		
		fog_timer -= delta
		if fog_timer <= 0.0:
			is_fog_active = false
			print("Resi Kabut Habis. Memulai proses pembersihan hutan...")
	else:
		# ✨ PROSES FADE OUT KABUT
		var previous_opacity = fog_opacity_current
		fog_opacity_current = move_toward(fog_opacity_current, 0.0, delta * 0.4)
		mat.set_shader_parameter("fog_opacity", fog_opacity_current)
		
		# 🔥 KUNCI 1: Jika kabut BARU SAJA menyentuh angka 0 (bersih total), tidurkan semua lentera
		if previous_opacity > 0.0 and fog_opacity_current == 0.0:
			get_tree().call_group("lanterns", "deactivate_lantern")
			print("💡 Hutan kembali aman. Semua lentera dinonaktifkan.")
		
		# Timer pengacak jalankan jika kabut benar-benar bersih
		if fog_opacity_current == 0.0:
			next_fog_check_timer -= delta
			if next_fog_check_timer <= 0.0:
				next_fog_check_timer = 15.0
				if randf() < 0.35: 
					trigger_forest_fog()

func trigger_forest_fog() -> void:
	is_fog_active = true
	fog_timer = randf_range(65.0, 95.0) 
	print("🌫️ [EVENT KABUT] Kabut aktif selama: ", int(fog_timer), " detik.")
	
	# 🔥 KUNCI 2: Begitu kabut kepilih untuk aktif, langsung bangunkan semua lentera di map!
	get_tree().call_group("lanterns", "activate_lantern")

func update_shader_positions() -> void:
	if not fog_overlay or not fog_overlay.visible: return
	var mat = fog_overlay.material as ShaderMaterial
	if not mat: return
	
	# 1. Update Posisi Charlotte
	var charlotte = get_node_or_null("../../CharacterManager/Charlotte")
	if charlotte:
		var screen_pos = charlotte.get_global_transform_with_canvas().origin
		mat.set_shader_parameter("player_world_pos", screen_pos)
		
	# 2. Ambil Semua Node Lentera di Grup
	var lanterns = get_tree().get_nodes_in_group("lanterns")
	var lantern_positions = []
	var lantern_radii = []
	var active_count = 0
	
	for i in range(lanterns.size()):
		if active_count >= 10: break
		var lant = lanterns[i]
		
		# 🔥 KUNCI 3: Hanya proses lentera yang berstatus AKTIF (sedang bekerja)
		if lant and lant.is_inside_tree() and lant.is_active:
			var lant_screen_pos = lant.get_global_transform_with_canvas().origin
			lantern_positions.append(lant_screen_pos)
			lantern_radii.append(lant.current_radius)
			active_count += 1
			
	mat.set_shader_parameter("lantern_positions", lantern_positions)
	mat.set_shader_parameter("lantern_radii", lantern_radii)
	mat.set_shader_parameter("active_lantern_count", active_count)
