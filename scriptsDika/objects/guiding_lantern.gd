extends Node2D

@export var base_radius: float = 60.0
var current_radius: float = 0.0
var is_player_inside: bool = false
var is_upgraded: bool = false

# 🔥 VARIABEL KONTROL SIKLUS AKTIF
var is_active: bool = false

@onready var interaction_area: Area2D = $InteractionArea

func _ready() -> void:
	add_to_group("lanterns")
	
	# Hubungkan sinyal area sensor
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)
		
	# 🔥 SET AWAL: Di awal game, lentera mati total dan bersembunyi
	deactivate_lantern()

# 🔥 FUNGSI DI-CALL OLEH ENVIRONMENT SAAT KABUT MUNCUL
func activate_lantern() -> void:
	is_active = true
	visible = true       # Munculkan sprite lentera di layar
	is_upgraded = false  # Reset status upgrade (biar tiap event kabut baru harus klik F lagi)
	current_radius = base_radius
	print("💡 ", name, " Mendeteksi ancaman kabut! Lentera menyala redup.")

# 🔥 FUNGSI DI-CALL OLEH ENVIRONMENT SAAT KABUT BENAR-BENAR HILANG
func deactivate_lantern() -> void:
	is_active = false
	visible = false      # Sembunyikan lentera dari pandangan player
	is_upgraded = false
	current_radius = 0.0 # Matikan lubang cahayanya di shader
	print("💤 ", name, " Kembali padam dan bersembunyi.")

func _input(event: InputEvent) -> void:
	# 🚫 VALIDASI: Jangan proses tombol F kalau lentera sedang tidak aktif/mati!
	if not is_active: return 
	
	if is_player_inside and not is_upgraded:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_F:
				trigger_upgrade_lantern()

func trigger_upgrade_lantern() -> void:
	is_upgraded = true
	current_radius = base_radius * 2.0
	print("🔥 [INTERAKSI] ", name, " Dinyalakan penuh! Radius dikali dua menjadi: ", current_radius)

func _on_body_entered(body: Node2D) -> void:
	if not is_active: return # Abaikan sensor jika lentera sedang padam
	if body.name == "Charlotte":
		is_player_inside = true
		print("👉 Charlotte berada di radius ", name, ". Tekan F!")

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Charlotte":
		is_player_inside = false
