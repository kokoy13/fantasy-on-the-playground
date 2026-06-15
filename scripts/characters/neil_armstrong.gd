extends BaseCharacterResource

var oxygen_level: float = 100.0
@export var oxygen_consumption_rate: float = 1.0

func _ready() -> void:
	super()
	character_name = "Armstrong"
	dream_dimension_name = "Bulan"
	max_hp = 5
	base_gravity_multiplier = 0.4
	speed = 400.0
	jump_velocity = -600.0

func handle_special_abilities(delta: float) -> void:
	if is_active_character:
		oxygen_level -= oxygen_consumption_rate * delta
		if oxygen_level <= 0:
			take_damage(5)

func on_character_ko() -> void:
	print("Armstrong KO. Game Over!")
