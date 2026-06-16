extends BaseCharacterResource

@export var max_mana: int = 5
var has_started_dream: bool = false
var current_mana: int

var is_skill_spelling:bool = false

func _ready() -> void:
	super()
	current_mana = max_mana
	character_name = "Charlotte"
	dream_dimension_name = "Hutan Dongeng"
	
func handle_movement() -> void:
	if is_skill_spelling:
		velocity.x = move_toward(velocity.x, 0, speed)
		return
	super()

func handle_jump() -> void:
	if is_skill_spelling:
		return
	super()
	
func handle_special_abilities(_delta: float) -> void:
	if Input.is_action_just_pressed("spell_e"):
		_healing_spell()
	#elif Input.is_action_just_pressed("spell_r"):
		#_cast_levitation_spell()
	elif Input.is_action_just_pressed("spell_t"):
		_thunder_spell()

func _healing_spell() -> void:
	if current_mana < 1:
		print("Mana tidak cukup untuk Healing!")
		return
	if current_hp == max_hp:
		print("HP maximum")
		return
	if is_skill_spelling: 
		return # Mencegah spam skill lain saat sedang merapal
	
	current_mana -= 1
	is_skill_spelling = true
	print("Healing HP")
	
	print("Current Mana : ", current_mana)
	# Tunggu bertapa selama 3 detik
	await get_tree().create_timer(3.0).timeout
	current_hp += 1
	print("Bertapa selesai! HP bertambah 1. HP saat ini: ", current_hp)
	
	is_skill_spelling = false

func _thunder_spell() -> void:
	if current_mana < 1:
		print("Mana tidak cukup untuk Thunder!")
		return
	if is_skill_spelling: 
		return
	
	current_mana -= 1
	is_skill_spelling = true
	print("Charlotte membaca mantra petir selama 2 detik...")
	
	# Membaca mantra selama 2 detik
	await get_tree().create_timer(2.0).timeout
	
	# Spawn ledakan petir di posisi koordinat Charlotte saat ini
	print("BOOM! Petir menyambar keras di posisi: ", global_position)
	
	is_skill_spelling = false

func restore_mana(amount: int) -> bool:
	if current_mana >= max_mana:
		print("Mana Maximum")
		return false
	current_mana += 1
	print("Mana berhasil dipulihkan di Altar! Mana saat ini: ", current_mana)
	return true
	
func on_character_ko() -> void:
	print("Charlotte KO. Game Over!")
