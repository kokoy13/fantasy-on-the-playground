class_name BaseLevelResource
extends Node2D

@onready var info_label: Label = $CanvasLayer/InfoLabel
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("char1"):
		switch_character("Tutorial 1") # Ubah sesuai info dimensi karakter 1
	elif event.is_action_pressed("char2"):
		switch_character("Dunia Mimpi")
	elif event.is_action_pressed("char3"):
		switch_character("Dunia Fantasi")
	elif event.is_action_pressed("char4"):
		switch_character("Dimensi Kosong")
	elif event.is_action_pressed("char5"):
		switch_character("Distorsi Waktu")

func setup_level_ui(levelName: String) -> void:
	if info_label:
		info_label.text = "Dimensi: " + levelName

func switch_character(target_dimension: String) -> void:
	if not color_rect:
		return
		
	var mat = color_rect.material as ShaderMaterial
	if not mat:
		return

	# Buat Tween untuk transisi cepat naik-turun intensitas glitch
	var tween = create_tween()
	
	# 1. Naikkan efek glitch ke maksimal secara instan (0.05 detik)
	tween.tween_property(mat, "shader_parameter/glitch_intensity", 0.8, 0.05)
	
	# 2. Tepat di tengah puncak glitch, ganti teks dimensi visual
	tween.tween_callback(func(): setup_level_ui(target_dimension))
	# Tempatkan kode logika pergantian karakter game Anda di bawah sini jika ada
	
	# 3. Turunkan kembali efek glitch ke nol secara halus (0.2 detik)
	tween.tween_property(mat, "shader_parameter/glitch_intensity", 0.0, 0.2)
