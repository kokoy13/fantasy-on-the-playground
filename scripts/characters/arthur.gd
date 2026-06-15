extends BaseCharacterResource

@export var dash_cooldown_time: float = 4.0
@export var dash_speed_multiplier: float = 2.5
@export var dash_duration: float = 0.2

var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var is_dashing: bool = false
var has_weapon: bool = true
var dash_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	super()
	character_name = "Arthur"
	dream_dimension_name = "Kastil Balon"
	max_hp = 5
	speed = 400.0
	jump_velocity = -600.0
	base_gravity_multiplier = 1.0

func handle_special_abilities(delta: float) -> void:
	if not is_active_character:
		return

	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * (speed * dash_speed_multiplier)
		if dash_timer <= 0.0:
			is_dashing = false
		return

	if Input.is_action_just_pressed("charDash") and dash_cooldown_timer <= 0.0:
		execute_dash()

	if Input.is_action_just_pressed("charAttack") and has_weapon:
		execute_attack()

func execute_dash() -> void:
	var move_dir := Input.get_axis("ui_left", "ui_right")
	if move_dir == 0.0:
		move_dir = -1.0 if $Sprite2D.flip_h else 1.0
		
	is_dashing = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown_time
	dash_direction = Vector2(move_dir, 0.0).normalized()

func execute_attack() -> void:
	pass

func take_damage(amount: int) -> void:
	if is_dashing:
		return
	super(amount)

func on_character_ko() -> void:
	print("Arthur KO. Game Over!")
