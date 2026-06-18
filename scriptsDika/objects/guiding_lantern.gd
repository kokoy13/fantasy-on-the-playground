extends Node2D

@export var base_radius: float = 70.0
@export var radius_speed: float = 500.0  # Kecepatan membesar/mengecilnya lubang cahaya
@export var fade_speed: float = 2.0      # Kecepatan fade in/out sprite lentera (alpha)

var current_radius: float = 0.0
var is_player_inside: bool = false
var is_upgraded: bool = false
var is_active: bool = false

@onready var interaction_area: Area2D = $InteractionArea

func _ready() -> void:
	add_to_group("lanterns")
	# Set kondisi awal mati total tanpa transisi saat pertama kali game jalan
	is_active = false
	is_upgraded = false
	current_radius = 0.0
	modulate.a = 0.0
	visible = false

func _process(delta: float) -> void:
	# 1. TENTUKAN TARGET RADIUS & ALPHA
	var target_radius = 0.0
	if is_active:
		target_radius = base_radius * 5.0 if is_upgraded else base_radius
		
	var target_alpha = 1.0 if is_active else 0.0
	
	# 2. JALANKAN TRANSISI SECARA BERTAHAP (Smooth)
	current_radius = move_toward(current_radius, target_radius, delta * radius_speed)
	modulate.a = move_toward(modulate.a, target_alpha, delta * fade_speed)
	
	# 3. ANTI-TABRAKAN MASTER SCRIPT (Penjaga Visibilitas)
	if is_active:
		visible = true
	else:
		# Jika sedang proses fade out (menghilang), biarkan tetap visible 
		# sampai radius benar-benar 0 dan sprite benar-benar transparan
		if current_radius == 0.0 and modulate.a == 0.0:
			visible = false
		else:
			visible = true

func activate_lantern() -> void:
	is_active = true
	is_upgraded = false
	visible = true # Aktifkan visibilitas agar _process langsung menghitung fade-in

func deactivate_lantern() -> void:
	is_active = false
	# Kita TIDAK LANGSUNG mengubah current_radius dan visible ke false di sini, 
	# biar fungsi _process di atas yang menyusutkan kodenya sampai habis secara sinematik!

func _input(event: InputEvent) -> void:
	if not is_active: return 
	
	if is_player_inside and not is_upgraded:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_F:
				trigger_upgrade_lantern()

func trigger_upgrade_lantern() -> void:
	is_upgraded = true
	print("Lentera dinyalakan (Upgraded ke Radius Jumbo)")

func _on_body_entered(body: Node2D) -> void:
	if not is_active: return
	if body.name == "Charlotte":
		is_player_inside = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Charlotte":
		is_player_inside = false
