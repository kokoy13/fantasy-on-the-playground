extends CharacterBody2D

@export var max_fuel: int = 100
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
var character_in_range: BaseCharacterResource = null

@onready var interaction_area: Area2D = $Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	current_fuel = max_fuel
	current_hp = max_hp
	
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta 
	else:
		velocity.y = 0.0 
		velocity.x = 0.0 

	if is_driven:
		handle_driving_logic(delta)

	apply_cosmic_storm_to_rocket()

	# BATASAN BARU: Jika di udara dan badai aktif, batasi kecepatan horizontal roket
	var parent_env = get_parent()
	if not is_on_floor() and parent_env and "is_storm_active" in parent_env and parent_env.is_storm_active:
		# Membatasi velocity.x roket maksimal di angka -500 hingga 500 (bisa Anda sesuaikan)
		velocity.x = clamp(velocity.x, -500.0, 500.0)

	move_and_slide() 
	
	if just_entered:
		just_entered = false

func apply_cosmic_storm_to_rocket() -> void:
	# Dapatkan referensi node induk/environment tempat roket diletakkan
	var parent_env = get_parent()
	if parent_env and "is_storm_active" in parent_env and parent_env.is_storm_active:
		# Dorong roket sesuai arah badai kosmik
		velocity.x += parent_env.storm_direction * parent_env.storm_force

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
		if character_in_range and character_in_range.character_name == "Armstrong" and character_in_range.is_active_character:
			enter_rocket(character_in_range)
			get_viewport().set_input_as_handled()

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

func _on_body_entered(body: Node2D) -> void:
	if body is BaseCharacterResource:
		character_in_range = body

func _on_body_exited(body: Node2D) -> void:
	if body == character_in_range:
		character_in_range = null
		
func exit_rocket() -> void:
	if not driver:
		return
		
	var spawn_position = global_position
	
	driver.is_active_character = true
	driver.visible = true
	driver.global_position = spawn_position
	driver.velocity = Vector2.ZERO 
	
	var driver_collision = driver.get_node_or_null("CollisionShape2D")
	if driver_collision:
		driver_collision.disabled = false
		# SOLUSI: Paksa mesin fisik Godot untuk langsung memproses perubahan posisi dan collision karakter saat ini juga
		driver.force_update_transform()
		
	is_driven = false
	driver = null
	rotation_degrees = 0.0
	velocity = Vector2.ZERO

func take_damage(amount: int) -> void:
	current_hp -= amount
	print("Roket terkena hit! Sisa HP: ", current_hp)
	if current_hp <= 0:
		current_hp = 0
		on_rocket_destroyed()

func on_rocket_destroyed() -> void:
	print("Mini Rocket Hancur!")
	if is_driven:
		# Keluarkan karakter terlebih dahulu sebelum roket di-queue_free
		exit_rocket()
	queue_free()
