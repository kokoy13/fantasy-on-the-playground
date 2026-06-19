extends RigidBody2D

enum SpellState { IDLE, LEVITATING, SLAMMING }
var current_state: SpellState = SpellState.IDLE

@onready var slam_area: Area2D = $SlamArea

func _ready() -> void:
	add_to_group("levitable_objects")
	
	lock_rotation = true
	contact_monitor = true
	max_contacts_reported = 4

func apply_levitation() -> void:
	if current_state != SpellState.IDLE: 
		return
	
	current_state = SpellState.LEVITATING
	gravity_scale = 0.0
	
	# Berikan kecepatan konstan ke atas agar objek terbang perlahan
	linear_velocity = Vector2(0, -120) 
	await get_tree().create_timer(2.0).timeout
	
	if current_state == SpellState.LEVITATING:
		trigger_hard_slam()

func trigger_hard_slam() -> void:
	current_state = SpellState.SLAMMING
	
	gravity_scale = 5.0 
	linear_velocity = Vector2(0, 500) 

# Sinyal terpicu otomatis saat bodi fisik kotak menabrak lantai/tanah/dinding
#func _on_body_impact(_body: Node) -> void:
	## Efek ledakan damage HANYA aktif jika tabrakan terjadi di fase jatuh (SLAMMING)
	#if current_state == SpellState.SLAMMING:
		#execute_damage_impact()
#
#func execute_damage_impact() -> void:
	#current_state = SpellState.IDLE
	#gravity_scale = 1.0 # Kembalikan gravitasi bumi normal game lu
	#linear_velocity = Vector2.ZERO # Hentikan sisa momentum dorongan
	#
	#print("💥 DUARR!! ", name, " Menghantam tanah! Kalkulasi damage area dimulai...")
	#
	## Tempat menaruh efek kosmetik (opsional)
	## EfekPartikelDebu.emitting = true
	#
	## 3. DETEKSI MUSUH: Cari korban di dalam area radar SlamArea
	#if slam_area:
		#var victims = slam_area.get_overlapping_bodies()
		#for victim in victims:
			## Jangan melukai diri sendiri atau Charlotte
			#if victim != self and victim.name != "Charlotte":
				## Opsi A: Jika musuh pakai fungsi standar take_damage()
				#if victim.has_method("take_damage"):
					#victim.take_damage(4)
					#print("⚔️ ", victim.name, " Terkena dampak hantaman! -4 HP.")
				## Opsi B: Jika musuh pakai variabel darah mentah 'health'
				#elif "health" in victim:
					#victim.health -= 4
					#print("⚔️ ", victim.name, " Terkena hantaman! Sisa darah: ", victim.health)
