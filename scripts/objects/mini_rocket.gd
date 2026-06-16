extends CharacterBody2D

@export var max_fuel: int = 10
@export var fuel_regen_cooldown: float = 2.0
@export var jump_force_y: float = -450.0
@export var jump_force_x: float = 200.0
@export var max_hp: int = 3
@export var lean_angle_degrees: float = 20.0

var current_fuel: int
var current_hp: int
var fuel_timer: float = 0.0

var is_driven: bool = false
var driver: BaseCharacterResource = null
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var just_entered: bool = false

@onready var interaction_area: Area2D = $Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	current_fuel = max_fuel
	current_hp = max_hp

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0
		velocity.x = 0.0

	if is_driven:
		handle_driving_logic(delta)

	move_and_slide()
	
	if just_entered:
		just_entered = false

func handle_driving_logic(delta: float) -> void:
	if driver:
		driver.global_position = global_position
		driver.visible = false

	if current_fuel < max_fuel:
		fuel_timer += delta
		if fuel_timer >= fuel_regen_cooldown:
			current_fuel = min(max_fuel, current_fuel + 1)
			fuel_timer = 0.0

	var move_dir := Input.get_axis("ui_left", "ui_right")
	if move_dir < 0:
		rotation_degrees = -lean_angle_degrees
		sprite_2d.flip_h = true
	elif move_dir > 0:
		rotation_degrees = lean_angle_degrees
		sprite_2d.flip_h = false
	else:
		rotation_degrees = 0.0

	if Input.is_action_just_pressed("ui_accept") and current_fuel > 0:
		velocity.y = jump_force_y
		
		if move_dir != 0.0:
			velocity.x = move_dir * jump_force_x
		else:
			velocity.x = 0.0
			
		current_fuel -= 1
		print("Roket Melompat! Sisa Bahan Bakar: ", current_fuel)

	if not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, 150.0 * delta)

	if Input.is_action_just_pressed("interact") and is_on_floor() and not just_entered:
		exit_rocket()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not is_driven:
		for body in interaction_area.get_overlapping_bodies():
			if body is BaseCharacterResource and body.character_name == "Armstrong" and body.is_active_character:
				enter_rocket(body)
				get_viewport().set_input_as_handled()
				break

func enter_rocket(character: BaseCharacterResource) -> void:
	is_driven = true
	just_entered = true
	driver = character
	driver.is_active_character = false
	driver.velocity = Vector2.ZERO
	
	var driver_collision = driver.get_node_or_null("CollisionShape2D")
	if driver_collision:
		driver_collision.disabled = true
		
	velocity = Vector2.ZERO
	rotation_degrees = 0.0

func exit_rocket() -> void:
	if not driver:
		return
	driver.is_active_character = true
	driver.visible = true
	driver.global_position = global_position
	
	var driver_collision = driver.get_node_or_null("CollisionShape2D")
	if driver_collision:
		driver_collision.disabled = false
		
	is_driven = false
	driver = null
	rotation_degrees = 0.0
	velocity = Vector2.ZERO
