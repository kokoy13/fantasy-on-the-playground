extends Node2D

# Variabel Mekanisme Cosmic Storm
var is_storm_active: bool = false
var storm_direction: float = 1.0 # 1.0 = Kanan (X+), -1.0 = Kiri (X-)
var storm_force: float = 300.0 # Kekuatan dorongan badai
var storm_duration: float = 0.0
var storm_chance: int = 1 # Peluang dasar 1% (1/100)

var check_timer: float = 0.0
var is_frozen: bool = false

func _physics_process(delta: float) -> void:
	# Jika dimensi dibekukan (frozen) karena pergantian karakter, hentikan semua kalkulasi badai
	if is_frozen:
		return

	if is_storm_active:
		process_storm(delta)
	else:
		process_storm_spawn_logic(delta)

# Logika penghitungan peluang munculnya badai setiap 1 detik
func process_storm_spawn_logic(delta: float) -> void:
	check_timer += delta
	if check_timer >= 1.0:
		check_timer = 0.0
		
		# Mengacak nilai dari 1 sampai 100
		var roll = randi() % 100 + 1
		if roll <= storm_chance:
			trigger_cosmic_storm()
		else:
			# Jika gagal, peluang naik di detik berikutnya (pasti muncul dalam maksimal 100 detik)
			storm_chance = min(100, storm_chance + 1)

# Logika saat badai aktif berjalan
func process_storm(delta: float) -> void:
	storm_duration -= delta
	if storm_duration <= 0.0:
		stop_cosmic_storm()

func trigger_cosmic_storm() -> void:
	is_storm_active = true
	storm_chance = 1 # Reset peluang kembali ke 1%
	storm_direction = 1.0 if randf() > 0.5 else -1.0
	storm_duration = randf_range(3.0, 7.0)
	print("🚨 COSMIC STORM MEMULAI! Arah: ", "Kanan (X+)" if storm_direction > 0 else "Kiri (X-)", " Durasi: ", storm_duration, " detik.")

func stop_cosmic_storm() -> void:
	is_storm_active = false
	print("🌤️ Cosmic Storm telah mereda.")

# Mengelola status environment (Aktif/Membeku/Nonaktif) dari BaseLevelResource
func set_environment_state(is_active: bool, is_env_frozen: bool) -> void:
	self.is_frozen = is_env_frozen
	
	if is_env_frozen:
		# Mode Freeze: Biarkan objek terlihat tetapi hentikan simulasi fisika rekursifnya
		set_state_recursive(self, true, false)
	else:
		# Mode Normal Aktif / Nonaktif
		set_state_recursive(self, is_active, true)
		if not is_active:
			# Jika dimensi Moon benar-benar ditinggalkan (kembali ke realita), redakan badai secara paksa
			stop_cosmic_storm()

func set_state_recursive(node: Node, is_active: bool, change_visibility: bool = true) -> void:
	if change_visibility and node is CanvasItem:
		node.visible = is_active
		
	node.set_process(is_active)
	node.set_physics_process(is_active)
	
	# Pemicu mekanisme freeze khusus untuk objek Meteor dan area pembuatnya
	if node.has_method("set_process_state"):
		node.set_process_state(is_active)
	
	if node is Area2D:
		node.monitoring = is_active
		node.monitorable = is_active

	if node is CollisionShape2D or node is CollisionPolygon2D:
		node.set_deferred("disabled", not is_active)
		
	for child in node.get_children():
		set_state_recursive(child, is_active, change_visibility)
