extends CharacterBody2D

const SPEED = 200.0
const FLY_SPEED = -250.0
const GRAVITY_DREAM = 400.0
const GRAVITY_NORMAL = 980.0

@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var pickup_area = $PickupArea

var is_carrying_knight = false
var knight_reference: CharacterBody2D = null

func _ready():
	pickup_area.body_entered.connect(_on_pickup_area_entered)
	pickup_area.body_exited.connect(_on_pickup_area_exited)

func _physics_process(delta):
	# 1. Sistem Gravitasi
	if GameManager.current_state == GameManager.State.ASTRONAUT_DREAM:
		velocity.y += GRAVITY_DREAM * delta
	else:
		velocity.y += GRAVITY_NORMAL * delta

	# 2. Logika Input & Pergerakan
	if GameManager.can_move("astronaut"):
		var direction = Input.get_axis("ui_left", "ui_right")
		
		# Balik arah sprite berdasarkan arah jalan
		if direction != 0:
			velocity.x = direction * SPEED
			sprite.flip_h = (direction < 0)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		# Mekanik Terbang (Tahan Spacebar)
		if GameManager.current_state == GameManager.State.ASTRONAUT_DREAM and Input.is_action_pressed("ui_accept"):
			velocity.y = FLY_SPEED
			
		# Mekanik Angkut Ksatria (Tombol E)
		#if Input.is_action_just_pressed("interact") and knight_reference != null:
			#is_carrying_knight = !is_carrying_knight
			#knight_reference.set_carried_state(is_carrying_knight, self)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	_update_animation()

# Fungsi khusus untuk mengatur perputaran animasi dummy
func _update_animation():
	# Jika dunia actual, paksa animasi diam (melamun)
	if GameManager.current_state == GameManager.State.ACTUAL:
		anim.play("idle")
		return

	# Logika animasi di dalam mimpi
	if not is_on_floor() and velocity.y < 0:
		if anim.has_animation("fly"): 
			anim.play("fly") # Animasi roket menyala
	elif velocity.x != 0:
		anim.play("walk") # Animasi jalan
	else:
		anim.play("idle") # Animasi diam

func _on_pickup_area_entered(body):
	if body.name == "Knight":
		knight_reference = body

func _on_pickup_area_exited(body):
	if body.name == "Knight" and not is_carrying_knight:
		knight_reference = null
