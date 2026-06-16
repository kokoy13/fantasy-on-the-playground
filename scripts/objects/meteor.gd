extends Area2D

var scale_factor: float = 1.0
var base_speed: float = 200.0
var current_speed: float = 0.0

var start_x: float = 0.0
var area_width: float = 0.0
var peak_height: float = 100.0 
var start_y: float = 0.0

var is_frozen: bool = false

@onready var static_body_2d: AnimatableBody2D = $AnimatableBody2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func initialize(p_scale: float, p_start_pos: Vector2, p_width: float) -> void:
	scale_factor = p_scale
	global_position = p_start_pos
	start_x = p_start_pos.x
	start_y = p_start_pos.y
	area_width = p_width
	
	scale = Vector2(scale_factor, scale_factor)
	
	# Ambil node collision dari StaticBody2D penyangga
	var static_collision = static_body_2d.get_node_or_null("CollisionShape2D") if static_body_2d else null
	
	if scale_factor >= 3.0:
		base_speed = 40.0
		# Aktifkan lantai padat untuk meteor besar
		if static_collision:
			static_collision.set_deferred("disabled", false)
	else:
		base_speed = 400.0 / scale_factor
		# Nonaktifkan lantai padat untuk meteor kecil agar tidak menabrak objek lain
		if static_collision:
			static_collision.set_deferred("disabled", true)

func _physics_process(delta: float) -> void:
	if is_frozen:
		return

	current_speed = base_speed
	var moon_env = get_node_or_null("../../../") 
	if moon_env and "is_storm_active" in moon_env and moon_env.is_storm_active:
		current_speed *= 2.0

	global_position.x -= current_speed * delta

	var distance_traveled = start_x - global_position.x
	var progress = clamp(distance_traveled / area_width, 0.0, 1.0)

	var curve_offset = sin(progress * PI) * peak_height
	global_position.y = start_y - curve_offset

	if progress >= 1.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("handle_driving_logic"):
		if "current_hp" in body:
			body.take_damage(1)
		
		# KONDISI BARU: Jika meteor berukuran kecil, hancurkan meteor setelah menabrak.
		# Jika meteor berukuran 3x, JANGAN hancurkan meteornya agar roket bisa mendarat di atasnya.
		if scale_factor < 3.0:
			queue_free() 

func set_process_state(is_active: bool) -> void:
	is_frozen = not is_active
