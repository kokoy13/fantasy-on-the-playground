class_name BaseLevelResource
extends Node2D

@export var armstrong_oxygen_duration: float = 60.0

@onready var info_label_dimension: Label = $CanvasLayer/InfoLabelDimension
@onready var info_label_character: Label = $CanvasLayer/InfoLabelCharacter
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var character_manager: Node = $CharacterManager
@onready var camera_2d: Camera2D = $Camera2D
@onready var dimension_manager: Node = $DimensionManager

var characters_dict: Dictionary = {}
var active_character: BaseCharacterResource
var is_in_dream_dimension: bool = false
const REALITY_FLOOR_Y: float = 627.0

var dream_cooldowns: Dictionary = {}
var dream_freeze_timers: Dictionary = {}

func _ready() -> void:
	initialize_characters()
	hide_all_dream_environments_instantly()
	update_dimension_mechanics()

func hide_all_dream_environments_instantly() -> void:
	var dm = get_node_or_null("DimensionManager")
	if not dm:
		return
	for child in dm.get_children():
		if child is Node2D and child.name != "RealityEnvironment":
			child.visible = false
			set_node_state_recursive(child, false, true)

func _physics_process(delta: float) -> void:
	if camera_2d and active_character:
		camera_2d.global_position = active_character.global_position
		
	process_dimension_timers(delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switchDimension"):
		toggle_dimension()
	elif event.is_action_pressed("char1"):
		switch_to_slot(1)
	elif event.is_action_pressed("char2"):
		switch_to_slot(2)

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
			dream_cooldowns[child.character_name] = 0.0
			dream_freeze_timers[child.character_name] = 0.0
			
			if child.character_name == "Armstrong":
				child.oxygen_level = armstrong_oxygen_duration
				
			slot_index += 1
			
	if characters_dict.has(1):
		active_character = characters_dict[1]
		active_character.is_active_character = true
		update_level_ui()

func process_dimension_timers(delta: float) -> void:
	for char_name in dream_cooldowns.keys():
		if dream_cooldowns[char_name] > 0.0:
			dream_cooldowns[char_name] -= delta
			
		if dream_freeze_timers[char_name] > 0.0:
			dream_freeze_timers[char_name] -= delta
			if dream_freeze_timers[char_name] <= 0.0:
				unfreeze_dream_environment(char_name)

func switch_to_slot(slot: int) -> void:
	if not characters_dict.has(slot) or characters_dict[slot] == active_character:
		return
		
	play_glitch_effect()
	
	var moon_env = dimension_manager.get_node_or_null("MoonEnvironment")
	
	if is_in_dream_dimension:
		var active_rocket: Node = null
		if moon_env:
			for child in moon_env.get_children():
				if child.has_method("handle_driving_logic") and child.is_driven and child.driver == active_character:
					active_rocket = child
					break
					
		if active_rocket:
			active_rocket.is_driven = false
			active_character.saved_dream_position = active_rocket.global_position
		else:
			active_character.saved_dream_position = active_character.global_position
			
		dream_cooldowns[active_character.character_name] = 3.0
		dream_freeze_timers[active_character.character_name] = 5.0
		
		var driver_collision = active_character.get_node_or_null("CollisionShape2D")
		if driver_collision:
			driver_collision.disabled = false
	else:
		active_character.saved_reality_x = active_character.global_position.x
		
	active_character.is_active_character = false
	active_character.velocity = Vector2.ZERO
	active_character.is_in_dream = false
	active_character.visible = true
	
	active_character = characters_dict[slot]
	active_character.is_active_character = true
	
	if is_in_dream_dimension:
		active_character.is_in_dream = true
		
		var target_position = active_character.saved_dream_position
		
		if target_position.y == -1.0:
			if active_character.character_name == "Arthur":
				target_position.y = 350.0
			elif active_character.character_name == "Armstrong":
				target_position.y = 200.0
		else:
			target_position.x = active_character.saved_dream_position.x
			
		active_character.global_position = target_position
		
		var new_moon_env = dimension_manager.get_node_or_null("MoonEnvironment")
		if active_character.character_name == "Armstrong" and new_moon_env:
			for child in new_moon_env.get_children():
				if child.has_method("handle_driving_logic") and child.driver == active_character:
					child.is_driven = true
					child.just_entered = true
					child.global_position = target_position
					
					var driver_collision = active_character.get_node_or_null("CollisionShape2D")
					if driver_collision:
						driver_collision.disabled = true
					break
	else:
		active_character.global_position = Vector2(active_character.saved_reality_x, REALITY_FLOOR_Y)
		
	update_dimension_mechanics()
	update_level_ui()

func toggle_dimension() -> void:
	if not active_character:
		return
		
	var current_x = active_character.global_position.x
	var moon_env = dimension_manager.get_node_or_null("MoonEnvironment")
	var active_rocket: Node = null
	
	if moon_env:
		for child in moon_env.get_children():
			if child.has_method("handle_driving_logic") and child.is_driven and child.driver == active_character:
				active_rocket = child
				break
	
	if is_in_dream_dimension:
		if active_rocket:
			active_rocket.is_driven = false
			active_rocket.velocity = Vector2.ZERO
			active_character.saved_dream_position = active_rocket.global_position
		else:
			active_character.saved_dream_position = active_character.global_position
			
		is_in_dream_dimension = false
		active_character.is_in_dream = false
		
		dream_cooldowns[active_character.character_name] = 3.0
		dream_freeze_timers[active_character.character_name] = 5.0
		
		active_character.is_active_character = true
		active_character.visible = true
		
		var driver_collision = active_character.get_node_or_null("CollisionShape2D")
		if driver_collision:
			driver_collision.disabled = false
			
		active_character.global_position = Vector2(current_x, REALITY_FLOOR_Y)
		active_character.velocity = Vector2.ZERO
		play_glitch_effect()
	else:
		if dream_cooldowns[active_character.character_name] > 0.0:
			return
			
		is_in_dream_dimension = true
		active_character.is_in_dream = true
		
		var target_y = active_character.saved_dream_position.y
		if active_character.character_name == "Arthur" and target_y == REALITY_FLOOR_Y:
			target_y = 350.0
			
		if active_character.character_name == "Armstrong" and moon_env:
			for child in moon_env.get_children():
				if child.has_method("handle_driving_logic") and child.driver == active_character:
					child.is_driven = true
					child.just_entered = true
					child.global_position = Vector2(current_x, target_y)
					active_character.saved_dream_position = child.global_position
					
					var driver_collision = active_character.get_node_or_null("CollisionShape2D")
					if driver_collision:
						driver_collision.disabled = true
					break
		else:
			active_character.global_position = Vector2(current_x, target_y)
					
		play_glitch_effect()
		
	update_dimension_mechanics()

func update_dimension_mechanics() -> void:
	if not dimension_manager or not character_manager:
		return
		
	var target_env_name: String = "RealityEnvironment"
	
	if is_in_dream_dimension and active_character:
		match active_character.character_name:
			"Armstrong":
				target_env_name = "MoonEnvironment"
			"Arthur":
				target_env_name = "WarzoneEnvironment"
	
	for env_node in dimension_manager.get_children():
		if env_node is Node2D:
			if env_node.name == target_env_name:
				if env_node.has_method("set_environment_state"):
					env_node.set_environment_state(true, false)
				else:
					set_node_state_recursive(env_node, true, true)
			else:
				var is_frozen_dream = false
				if env_node.name == "MoonEnvironment" and dream_freeze_timers.get("Armstrong", 0.0) <= 0.0:
					is_frozen_dream = true
				elif env_node.name == "WarzoneEnvironment" and dream_freeze_timers.get("Arthur", 0.0) <= 0.0:
					is_frozen_dream = true
				
				if env_node.has_method("set_environment_state"):
					if is_frozen_dream:
						env_node.set_environment_state(true, true)
					else:
						env_node.set_environment_state(false, false)
				else:
					if is_frozen_dream:
						set_node_state_recursive(env_node, true, false)
					else:
						set_node_state_recursive(env_node, false, true)

	for child in character_manager.get_children():
		if child is BaseCharacterResource:
			if not is_in_dream_dimension:
				child.visible = true
				child.modulate.a = 1.0
				child.set_physics_process(true)
				
				var driver_collision = child.get_node_or_null("CollisionShape2D")
				if driver_collision:
					driver_collision.disabled = false
			else:
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

	for child in character_manager.get_children():
		if child is BaseCharacterResource:
			if not is_in_dream_dimension:
				child.visible = true
				child.modulate.a = 1.0
				child.set_physics_process(true)
				
				var driver_collision = child.get_node_or_null("CollisionShape2D")
				if driver_collision:
					driver_collision.disabled = false
			else:
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

func unfreeze_dream_environment(char_name: String) -> void:
	update_dimension_mechanics()

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
