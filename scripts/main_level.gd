# res://scenes/levels/main_level.gd
extends Node2D

@onready var state_label = $CanvasLayer/StateLabel
@onready var astronaut = $Astronaut
@onready var knight = $Knight

@onready var bg_actual = $BgActual
@onready var bg_astronaut = $BgAstronaut
@onready var bg_knight = $BgKnight

func _ready():
	# Set kondisi awal saat game baru mulai (Dunia Nyata, tidak ada yang bisa gerak)
	_switch_dimension(GameManager.State.ACTUAL, "none")

func _unhandled_input(event):
	# Tombol 1: Pindah ke Dunia Nyata (Actual World)
	if Input.is_key_pressed(KEY_1):
		_switch_dimension(GameManager.State.ACTUAL, "none")
		
	# Tombol 2: Pindah ke Mimpi Astronot (Astronaut Dream)
	elif Input.is_key_pressed(KEY_2):
		_switch_dimension(GameManager.State.ASTRONAUT_DREAM, "astronaut")
		
	# Tombol 3: Pindah ke Mimpi Ksatria (Knight Dream)
	elif Input.is_key_pressed(KEY_3):
		_switch_dimension(GameManager.State.KNIGHT_DREAM, "knight")

func _switch_dimension(new_state: GameManager.State, active_char: String):
	# 1. Update data di GameManager global
	GameManager.current_state = new_state
	GameManager.active_character = active_char
	
	# 2. Update Teks UI biar kita tahu lagi di dimensi mana
	_update_ui_text(new_state, active_char)
	_apply_visual_transition(new_state, active_char)

func _update_ui_text(state: GameManager.State, active_char: String):
	var state_name = ""
	match state:
		GameManager.State.ACTUAL: state_name = "Dunia Nyata (Anak-anak)"
		GameManager.State.ASTRONAUT_DREAM: state_name = "Mimpi Bulan (Sci-Fi)"
		GameManager.State.KNIGHT_DREAM: state_name = "Mimpi Kastil (Fantasy)"
		
	state_label.text = "Dimensi: " + state_name + "\nKontrol: " + active_char.to_upper()

func _apply_visual_transition(state: GameManager.State, active_char: String):
	# Siapkan variabel penampung nilai transparansi (Alpha) target
	var actual_bg_alpha = 0.0
	var astro_bg_alpha = 0.0
	var knight_bg_alpha = 0.0
	
	var astro_opacity = 0.3
	var knight_opacity = 0.3

	# Tentukan nilai visual berdasarkan dimensi aktif
	match state:
		GameManager.State.ACTUAL:
			actual_bg_alpha = 1.0  # Munculkan gambar dunia nyata
			astro_opacity = 1.0  # Karakter memudar samar
			knight_opacity = 1.0
		GameManager.State.ASTRONAUT_DREAM:
			astro_bg_alpha = 1.0   # Munculkan gambar luar angkasa
			astro_opacity = 1.0    # Astronaut jadi nyata/padat
			knight_opacity = 0.5   # Ksatria hampir tidak terlihat
		GameManager.State.KNIGHT_DREAM:
			knight_bg_alpha = 1.0  # Munculkan gambar kastil tua
			astro_opacity = 0.5    # Astronaut hampir tidak terlihat
			knight_opacity = 1.0   # Ksatria jadi nyata/padat

	# Eksekusi animasi transisi cross-fade mulus menggunakan Tween (Durasi: 0.5 detik)
	var tween = create_tween().set_parallel(true)
	
	# Animasikan opasitas ketiga gambar background
	tween.tween_property(bg_actual, "modulate:a", actual_bg_alpha, 0.5)
	tween.tween_property(bg_astronaut, "modulate:a", astro_bg_alpha, 0.5)
	tween.tween_property(bg_knight, "modulate:a", knight_bg_alpha, 0.5)
	
	# Animasikan opasitas kedua karakter utama
	tween.tween_property(astronaut, "modulate:a", astro_opacity, 0.5)
	tween.tween_property(knight, "modulate:a", knight_opacity, 0.5)
