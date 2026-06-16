extends Node2D # Jika root node ManaAltar lu adalah Node2D (ikon lingkaran biru)

@export var mana_restore_amount: int = 1

# Mengambil referensi node Area2D yang ada di bawah root secara otomatis saat game di-run
@onready var area_2d: Area2D = $Area2D

var is_used: bool = false

func _ready() -> void:
	# Hubungkan signal body_entered milik Area2D ke fungsi di bawah melalui kode
	if not area_2d.body_entered.is_connected(_on_area_2d_body_entered):
		area_2d.body_entered.connect(_on_area_2d_body_entered)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_used:
		return
		
	if body.has_method("restore_mana"):
		print("✨ Altar mendeteksi ", body.name)
		var is_success = body.restore_mana(mana_restore_amount)
		
		if is_success:
			print("sukses")
			is_used = true
			$Area2D/CollisionShape2D.set_deferred("disabled", true)
