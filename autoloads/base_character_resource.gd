class_name BaseCharacterResource
extends CharacterBody2D

@export var character_name: String = "Unknown"
@export var dream_dimension_name: String = "Unknown Dimension"
@export var max_hp: int = 5
@export var speed: float = 400.0
@export var jump_velocity: float = -600.0
@export var base_gravity_multiplier: float = 1.0

var noChar: int = 0
var current_hp: int
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_active_character: bool = false

func _ready() -> void:
	current_hp = max_hp

func _physics_process(delta: float) -> void:
	if not is_active_character:
		apply_passive_physics(delta)
		return

	apply_gravity(delta)
	handle_jump()
	handle_movement()
	handle_special_abilities(delta)
	
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * base_gravity_multiplier * delta

func apply_passive_physics(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * base_gravity_multiplier * delta
		move_and_slide()
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		move_and_slide()

func handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

func handle_movement() -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

func handle_special_abilities(_delta: float) -> void:
	pass

func take_damage(amount: int) -> void:
	current_hp -= amount
	if current_hp <= 0:
		current_hp = 0
		on_character_ko()

func on_character_ko() -> void:
	pass
