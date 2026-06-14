extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -350.0
const GRAVITY = 980.0

@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var attack_area = $AttackArea

var is_carried = false
var is_attacking = false
var is_jumping = false
var carrier_node: CharacterBody2D = null

func _physics_process(delta):
	# Jika sedang diangkut Astronot, ikuti koordinatnya dan stop animasi jalan
	if is_carried and carrier_node != null:
		global_position = carrier_node.global_position + Vector2(0, -40)
		velocity = Vector2.ZERO
		sprite.flip_h = carrier_node.sprite.flip_h # Hadapnya ngikutin astronot
		anim.play("idle") 
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Logika Input Player
	if GameManager.can_move("knight") and not is_attacking:
		var direction = Input.get_axis("ui_left", "ui_right")
		
		if direction != 0:
			velocity.x = direction * SPEED
			sprite.flip_h = (direction < 0)
			# Atur posisi kotak serangan di depan karakter sesuai arah hadap
			attack_area.position.x = -abs(attack_area.position.x) if direction < 0 else abs(attack_area.position.x)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		if Input.is_action_just_pressed("ui_up") and is_on_floor() and GameManager.current_state == GameManager.State.KNIGHT_DREAM:
			velocity.y = JUMP_VELOCITY
			is_jumping = true

		# Mekanik Serang (Klik Kiri)
		if Input.is_action_just_released("attack") and GameManager.current_state == GameManager.State.KNIGHT_DREAM:
			_execute_attack()
	else:
		if not is_attacking:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	if not is_attacking:
		_update_animation()

func _update_animation():
	# 1. Jika di dunia nyata, paksa animasi diam
	if GameManager.current_state == GameManager.State.ACTUAL:
		anim.play("idle")
		return

	if is_on_floor() and velocity.y >= 0:
		is_jumping = false
			
	if is_jumping or not is_on_floor():
		if anim.has_animation("jump"):
			anim.play("jump")
		else:
			anim.play("idle")
		return # Langsung keluar fungsi agar tidak sengaja tertimpa logika jalan/diam di bawah!
		
	# 3. Jika di tanah dan bergerak
	elif velocity.x != 0:
		if anim.has_animation("walk"): 
			anim.play("walk")
		else:
			anim.play("idle")
			
	# 4. Jika di tanah dan diam
	else:
		anim.play("idle")

func _execute_attack():
	is_attacking = true
	velocity.x = 0 # Berhenti bergerak saat menebas
	anim.play("attack")
	
	# Tunggu sampai animasi tebasan selesai baru bisa gerak lagi
	await anim.animation_finished 
	is_attacking = false

	# Deteksi hancurnya rintangan asimetris
	var overlapping_bodies = attack_area.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.has_method("destroy_obstacle"):
			body.destroy_obstacle()

func set_carried_state(status: bool, carrier: CharacterBody2D):
	is_carried = status
	carrier_node = carrier
	$CollisionShape2D.disabled = status
