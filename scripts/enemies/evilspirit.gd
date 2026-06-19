extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var anim = $AnimationPlayer
@onready var char = $Sprite2D

func _ready():
	anim.play("idle")
	char.flip_h = true

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func _on_attack_area_body_entered(body):
	if body.name == "Charlotte":
		anim.play("attack")

func _on_attack_area_body_exited(body):
	if body.name == "Charlotte":
		await get_tree().create_timer(1).timeout
		anim.play("idle")
