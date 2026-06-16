extends Area2D

@export var meteor_scene: PackedScene # Tarik file meteor.tscn ke dalam slot ini di Inspector
@export var spawn_cooldown: float = 3.0 # Jeda waktu kemunculan antar meteor

var spawn_timer: float = 0.0
var is_frozen: bool = false
var area_rect: Rect2

func _ready() -> void:
	# Dapatkan ukuran area berdasarkan bentuk CollisionShape2D kotak miliknya
	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape and collision_shape.shape is RectangleShape2D:
		var size = collision_shape.shape.size
		# Buat representasi kotak area lokal
		area_rect = Rect2(collision_shape.position - size / 2, size)

func _physics_process(delta: float) -> void:
	if is_frozen or not meteor_scene:
		return

	spawn_timer += delta
	if spawn_timer >= spawn_cooldown:
		spawn_timer = 0.0
		# Acak jeda spawn berikutnya agar variatif
		spawn_cooldown = randf_range(2.0, 5.0)
		spawn_meteor()

func spawn_meteor() -> void:
	var meteor_instance = meteor_scene.instantiate()
	
	# Tentukan titik spawn di ujung kanan area, koordinat Y diacak dari batas atas hingga bawah area
	var spawn_x = global_position + area_rect.end # Sisi paling kanan area kotak
	var spawn_y = global_position.y + randf_range(area_rect.position.y, area_rect.end.y)
	var start_position = Vector2(spawn_x.x, spawn_y)
	
	# Acak skala ukuran meteor dari 0.5x hingga 3.0x
	var random_scale = randf_range(0.5, 3.0)
	
	# Khusus jika beruntung mendapatkan skala mendekati atau sama dengan 3, paksa pas di angka 3
	if random_scale >= 2.8:
		random_scale = 3.0

	# Masukkan objek ke dalam scene tree
	add_child(meteor_instance)
	
	# Inisialisasi data jalur lintasan kurva ke objek meteor
	meteor_instance.initialize(random_scale, start_position, area_rect.size.x)

# Dipanggil otomatis oleh sistem rekursif MoonEnvironment saat freeze / unfreeze
func set_process_state(is_active: bool) -> void:
	is_frozen = not is_active
