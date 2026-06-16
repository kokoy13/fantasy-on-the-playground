extends BaseCharacterResource

var has_started_dream: bool = false

func _ready() -> void:
	super()
	character_name = "Shane Leech"
	dream_dimension_name = "Kota Metropolitan"

func on_character_ko() -> void:
	print("Shane Leech KO. Game Over!")
