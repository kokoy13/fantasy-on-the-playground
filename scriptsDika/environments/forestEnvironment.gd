# forest_environtment.gd
extends Node2D

# Variabel Mekanisme Lingkungan Hutan
var is_frozen: bool = false

func _ready() -> void:
	# 🔥 TRIK TESTING: Paksa dimensi Hutan Dongeng langsung aktif dan visible
	# Kode ini akan mengaktifkan Altar dan semua objek di dalam Hutan secara otomatis
	set_environment_state(true, false)

func _physics_process(_delta: float) -> void:
	if is_frozen:
		return
		
	# Tempat menaruh update fisika khusus hutan dongeng lu nantinya

# === FUNGSI BAWAAN (SAMA SEPERTI SEBELUMNYA) ===
func set_environment_state(is_active: bool, is_env_frozen: bool) -> void:
	self.is_frozen = is_env_frozen
	
	if is_env_frozen:
		set_state_recursive(self, true, false)
	else:
		set_state_recursive(self, is_active, true)

func set_state_recursive(node: Node, is_active: bool, change_visibility: bool = true) -> void:
	if change_visibility and node is CanvasItem:
		node.visible = is_active
		
	node.set_process(is_active)
	node.set_physics_process(is_active)
	
	if node.has_method("set_process_state"):
		node.set_process_state(is_active)
	
	if node is Area2D:
		node.monitoring = is_active
		node.monitorable = is_active

	if node is CollisionShape2D or node is CollisionPolygon2D:
		node.set_deferred("disabled", not is_active)
		
	for child in node.get_children():
		set_state_recursive(child, is_active, change_visibility)
