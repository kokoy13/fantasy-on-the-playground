class_name BaseLevelResource
extends Node2D

@onready var info_label_dimension: Label = $CanvasLayer/InfoLabelDimension
@onready var info_label_character: Label = $CanvasLayer/InfoLabelCharacter
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var character_manager: Node = $CharacterManager
@onready var camera_2d: Camera2D = $Camera2D

var characters_dict: Dictionary = {}
var active_character: BaseCharacterResource
var is_in_dream_dimension: bool = false

func _ready() -> void:
	initialize_characters()

func _physics_process(_delta: float) -> void:
	if camera_2d and active_character:
		camera_2d.global_position = active_character.global_position

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switchDimension"):
		toggle_dimension()
	elif event.is_action_pressed("char1"):
		switch_to_slot(1)
	elif event.is_action_pressed("char2"):
		switch_to_slot(2)
	elif event.is_action_pressed("char3"):
		switch_to_slot(3)
	elif event.is_action_pressed("char4"):
		switch_to_slot(4)
	elif event.is_action_pressed("char5"):
		switch_to_slot(5)

func initialize_characters() -> void:
	if not character_manager:
		return
		
	var slot_index = 1
	for child in character_manager.get_children():
		if child is BaseCharacterResource:
			child.noChar = slot_index
			characters_dict[slot_index] = child
			child.is_active_character = false
			slot_index += 1
			
	if characters_dict.has(1):
		active_character = characters_dict[1]
		active_character.is_active_character = true
		update_level_ui()

func switch_to_slot(slot: int) -> void:
	if not characters_dict.has(slot) or characters_dict[slot] == active_character:
		return
		
	play_glitch_effect()
	
	active_character.is_active_character = false
	active_character.velocity = Vector2.ZERO
	
	active_character = characters_dict[slot]
	active_character.is_active_character = true
	
	update_level_ui()

func toggle_dimension() -> void:
	if not active_character:
		return
		
	is_in_dream_dimension = not is_in_dream_dimension
	play_glitch_effect()

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
