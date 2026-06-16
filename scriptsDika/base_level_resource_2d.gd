class_name BaseLevelResource2D
extends Node2D

# ==============================================================================
# CONFIGURASI LANTAI (Y-AXIS) - Silakan sesuaikan dengan kemiringan map lu
# ==============================================================================
const REALITY_FLOOR_Y: float = 627.0        # Lantai Dimensi Realita
const CHARLOTTE_DREAM_Y: float = 500.0     # Lantai Dimensi Hutan Dongeng (ForestEnvironment)
const SHANE_DREAM_Y: float = 500.0         # Lantai Dimensi Kota (MetropolitanEnviron)

# --- Node References ---
@onready var info_label_dimension: Label = $CanvasLayer/InfoLabelDimension
@onready var info_label_character: Label = $CanvasLayer/InfoLabelCharacter
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var character_manager: Node = $CharacterManager
@onready var camera_2d: Camera2D = $Camera2D
@onready var dimension_manager: Node = $DimensionManager

# --- Core System Variables ---
var characters_dict: Dictionary = {}
var active_character: BaseCharacterResource
var is_in_dream_dimension: bool = false

var dream_cooldowns: Dictionary = {}
var dream_freeze_timers: Dictionary = {}

# ==============================================================================
# BUILT-IN FUNCTIONS
# ==============================================================================
func _ready() -> void:
	initialize_characters()
	hide_all_dream_environments_instantly()
	update_dimension_mechanics()

func _physics_process(delta: float) -> void:
	# Kamera otomatis mengikuti karakter yang sedang aktif
	if camera_2d and active_character:
		camera_2d.global_position = active_character.global_position
		
	process_dimension_timers(delta)

func _input(event: InputEvent) -> void:
	# Tombol Spasi / Switch Dimension
	if event.is_action_pressed("switchDimension"):
		toggle_dimension()
	# Tombol Angka 1 (Charlotte)
	elif event.is_action_pressed("char1"):
		switch_to_slot(1)
	# Tombol Angka 2 (Shane Leech)
	elif event.is_action_pressed("char2"):
		switch_to_slot(2)

# ==============================================================================
# INITIALIZATION SYSTEM
# ==============================================================================
func initialize_characters() -> void:
	if not character_manager:
		return
		
	var slot_index = 1
	for child in character_manager.get_children():
		if child is BaseCharacterResource:
			child.noChar = slot_index
			characters_dict[slot_index] = child
			child.is_active_character = false
			child.saved_reality_x = child.global_position.x
			child.saved_dream_position = Vector2(child.global_position.x, -1.0)
			
			# Setup data timer awal untuk karakter
			dream_cooldowns[child.character_name] = 0.0
			dream_freeze_timers[child.character_name] = 0.0
			
			slot_index += 1
			
	# Pasang karakter di Slot 1 sebagai karakter utama saat game mulai
	if characters_dict.has(1):
		active_character = characters_dict[1]
		active_character.is_active_character = true
		update_level_ui()

func hide_all_dream_environments_instantly() -> void:
	if not dimension_manager:
		return
	for child in dimension_manager.get_children():
		if child is Node2D and child.name != "RealityEnvironment":
			child.visible = false
			set_node_state_recursive(child, false, true)

# ==============================================================================
# DIMENSION & CHARACTER SWITCHING LOGIC
# ==============================================================================
func switch_to_slot(slot: int) -> void:
	if not characters_dict.has(slot) or characters_dict[slot] == active_character:
		return
		
	play_glitch_effect()
	
	# 1. SIMPAN KOORDINAT KARAKTER LAMA SEBELUM DITINGGAL
	if is_in_dream_dimension:
		active_character.saved_dream_position = active_character.global_position
		dream_cooldowns[active_character.character_name] = 3.0
		dream_freeze_timers[active_character.character_name] = 5.0
	else:
		active_character.saved_reality_x = active_character.global_position.x
		
	# Nonaktifkan karakter lama
	active_character.is_active_character = false
	active_character.velocity = Vector2.ZERO
	active_character.is_in_dream = false
	active_character.visible = true
	
	# 2. AKTIFKAN KARAKTER BARU
	active_character = characters_dict[slot]
	active_character.is_active_character = true
	
	# 3. SET INDEKS POSITION BERDASARKAN DIMENSI SEKARANG
	if is_in_dream_dimension:
		active_character.is_in_dream = true
		var target_position = active_character.saved_dream_position
		
		# Jika karakter baru belum pernah masuk dimensi mimpi, atur tinggi defaultnya
		if target_position.y == -1.0:
			if active_character.character_name == "Charlotte":
				target_position.y = CHARLOTTE_DREAM_Y
			elif active_character.character_name == "ShaneLeech":
				target_position.y = SHANE_DREAM_Y
		else:
			target_position.x = active_character.saved_dream_position.x
			
		active_character.global_position = target_position
	else:
		# Jika di realita, taruh di lantai realita
		active_character.global_position = Vector2(active_character.saved_reality_x, REALITY_FLOOR_Y)
		
	update_dimension_mechanics()
	update_level_ui()

func toggle_dimension() -> void:
	if not active_character:
		return
		
	var current_x = active_character.global_position.x
	
	if is_in_dream_dimension:
		# KELUAR DARI DIMENSI MIMPI -> KEMBALI KE REALITA
		active_character.saved_dream_position = active_character.global_position
		is_in_dream_dimension = false
		active_character.is_in_dream = false
		
		# Berikan cooldown pusing setelah pindah dimensi
		dream_cooldowns[active_character.character_name] = 3.0
		dream_freeze_timers[active_character.character_name] = 5.0
		
		active_character.is_active_character = true
		active_character.visible = true
		active_character.global_position = Vector2(current_x, REALITY_FLOOR_Y)
		active_character.velocity = Vector2.ZERO
		play_glitch_effect()
	else:
		# MASUK KE DIMENSI MIMPI
		if dream_cooldowns[active_character.character_name] > 0.0:
			return # Gagalkan jika masih cooldown
			
		is_in_dream_dimension = true
		active_character.is_in_dream = true
		
		var target_y = active_character.saved_dream_position.y
		
		# Jika baru pertama kali pindah dimensi, panggil konstanta Y
		if target_y == REALITY_FLOOR_Y or target_y == -1.0:
			if active_character.character_name == "Charlotte":
				target_y = CHARLOTTE_DREAM_Y
			elif active_character.character_name == "ShaneLeech":
				target_y = SHANE_DREAM_Y
				
		active_character.global_position = Vector2(current_x, target_y)
		play_glitch_effect()
		
	update_dimension_mechanics()

# ==============================================================================
# CORE MECHANICS & ENVIRONMENT MANAGER
# ==============================================================================
func update_dimension_mechanics() -> void:
	if not dimension_manager or not character_manager:
		return
		
	# Secara default, dimensi yang aktif adalah Realita
	var target_env_name: String = "RealityEnvironment"
	
	# Tentukan nama map target berdasarkan karakter siapa yang sedang masuk mimpi
	if is_in_dream_dimension and active_character:
		match active_character.character_name:
			"Charlotte":
				target_env_name = "ForestEnvironment"
			"ShaneLeech":
				target_env_name = "MetropolitanEnviron"
	
	# --- Loop 1: Atur Hidup/Mati Environment Map ---
	for env_node in dimension_manager.get_children():
		if env_node is Node2D:
			if env_node.name == target_env_name:
				# Nyalakan dimensi tujuan secara penuh
				if env_node.has_method("set_environment_state"):
					env_node.set_environment_state(true, false)
				else:
					set_node_state_recursive(env_node, true, true)
			else:
				# Logika Pembekuan Dunia (Freeze) saat ditinggal ke dimensi lain
				var is_frozen_dream = false
				if env_node.name == "ForestEnvironment" and dream_freeze_timers.get("Charlotte", 0.0) <= 0.0:
					is_frozen_dream = true
				elif env_node.name == "MetropolitanEnviron" and dream_freeze_timers.get("ShaneLeech", 0.0) <= 0.0:
					is_frozen_dream = true
				
				if env_node.has_method("set_environment_state"):
					if is_frozen_dream:
						env_node.set_environment_state(true, true) # Freeze aktif
					else:
						env_node.set_environment_state(false, false) # Mati total
				else:
					if is_frozen_dream:
						set_node_state_recursive(env_node, true, false)
					else:
						set_node_state_recursive(env_node, false, true)

	# --- Loop 2: Atur Visibilitas Karakter ---
	for child in character_manager.get_children():
		if child is BaseCharacterResource:
			if not is_in_dream_dimension:
				# Jika di realita, semua karakter kelihatan di map
				child.visible = true
				child.modulate.a = 1.0
				child.set_physics_process(true)
				var driver_collision = child.get_node_or_null("CollisionShape2D")
				if driver_collision:
					driver_collision.disabled = false
			else:
				# Jika di dimensi mimpi, HANYA karakter aktif yang boleh kelihatan
				if child == active_character:
					child.visible = true
					child.modulate.a = 1.0
					child.set_physics_process(true)
					var driver_collision = child.get_node_or_null("CollisionShape2D")
					if driver_collision:
						driver_collision.disabled = false
				else:
					child.visible = false
					child.set_physics_process(false)

# ==============================================================================
# HELPER & UTILITY FUNCTIONS
# ==============================================================================
func process_dimension_timers(delta: float) -> void:
	for char_name in dream_cooldowns.keys():
		if dream_cooldowns[char_name] > 0.0:
			dream_cooldowns[char_name] -= delta
			
		if dream_freeze_timers[char_name] > 0.0:
			dream_freeze_timers[char_name] -= delta
			if dream_freeze_timers[char_name] <= 0.0:
				update_dimension_mechanics() # Refresh saat timer pembekuan habis

func play_glitch_effect() -> void:
	if not color_rect:
		return
		
	var mat = color_rect.material as ShaderMaterial
	if mat:
		var tween = create_tween()
		tween.tween_property(mat, "shader_parameter/glitch_intensity", 0.8, 0.05)
		tween.tween_callback(func(): update_level_ui())
		tween.tween_property(mat, "shader_parameter/glitch_intensity", 0.0, 0.2)
	else:
		update_level_ui()

func update_level_ui() -> void:
	if not active_character:
		return
		
	if info_label_character:
		info_label_character.text = "Character : " + active_character.character_name
		
	if info_label_dimension:
		if is_in_dream_dimension:
			# Memanggil nama dimensi khusus milik karakter (diatur di script karakter masing-masing)
			info_label_dimension.text = "Dimensi: " + active_character.dream_dimension_name
		else:
			info_label_dimension.text = "Dimensi: Realita"
			
func set_node_state_recursive(node: Node, is_active: bool, change_visibility: bool = true) -> void:
	if change_visibility and node is CanvasItem:
		node.visible = is_active
		
	node.set_process(is_active)
	node.set_physics_process(is_active)
	
	if node is CollisionShape2D or node is CollisionPolygon2D:
		node.set_deferred("disabled", not is_active)
		
	for child in node.get_children():
		set_node_state_recursive(child, is_active, change_visibility)
