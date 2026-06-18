extends Node2D

@onready var fog_overlay: ColorRect = $FogCanvas/FogOverlay

var is_fog_active: bool = false
var fog_timer: float = 10
var fog_opacity_current: float = 0.0
var next_fog_check_timer: float = 10.0 

func _ready():
	is_fog_active = false

func _process(delta: float) -> void:
	var level_master = get_node_or_null("../..")
	if level_master and level_master.is_in_dream_dimension:
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
			fog_timer = 10
	else:
		# Fade out Fog
		var previous_opacity = fog_opacity_current
		fog_opacity_current = move_toward(fog_opacity_current, 0.0, delta * 0.4)
		mat.set_shader_parameter("fog_opacity", fog_opacity_current)
		
		if previous_opacity > 0.0 and fog_opacity_current == 0.0:
			get_tree().call_group("lanterns", "deactivate_lantern")
		
		# Timer pengacak jalankan jika kabut benar-benar bersih
		if fog_opacity_current == 0.0:
			next_fog_check_timer -= delta
			if next_fog_check_timer <= 0.0:
				# Jeda sebelum gacha peluang kabut
				next_fog_check_timer = 15.0
				# Kondisi gacha
				if randf() < 0.4: 
					trigger_forest_fog()

func trigger_forest_fog() -> void:
	is_fog_active = true
	print("Kabut Aktif")

	get_tree().call_group("lanterns", "activate_lantern")

func update_shader_positions() -> void:
	if not fog_overlay or not fog_overlay.visible: 
		return
		
	var mat = fog_overlay.material as ShaderMaterial
	if not mat: 
		return

	var charlotte = get_node_or_null("../../CharacterManager/Charlotte")
	if charlotte:
		var screen_pos = charlotte.get_global_transform_with_canvas().origin
		mat.set_shader_parameter("player_world_pos", screen_pos)
		
	var lanterns = get_tree().get_nodes_in_group("lanterns")
	var lantern_positions = []
	var lantern_radii = []
	var active_count = 0
	
	for i in range(lanterns.size()):
		if active_count >= 10: break
		var lant = lanterns[i]

		if lant and lant.is_inside_tree() and lant.is_active:
			var lant_screen_pos = lant.get_global_transform_with_canvas().origin
			lantern_positions.append(lant_screen_pos)
			lantern_radii.append(lant.current_radius)
			active_count += 1
			
	mat.set_shader_parameter("lantern_positions", lantern_positions)
	mat.set_shader_parameter("lantern_radii", lantern_radii)
	mat.set_shader_parameter("active_lantern_count", active_count)
