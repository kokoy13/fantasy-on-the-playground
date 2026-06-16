extends BaseCharacterResource

var oxygen_level: float = 0.0
@export var oxygen_consumption_rate: float = 1.0

var has_started_dream: bool = false

func _ready() -> void:
	super()
	character_name = "Armstrong"
	dream_dimension_name = "Bulan"
	max_hp = 5
	base_gravity_multiplier = 1.0 
	speed = 400.0
	jump_velocity = -600.0

func get_gravity_multiplier() -> float:
	if is_in_dream:
		return 0.4
	return base_gravity_multiplier

func handle_special_abilities(delta: float) -> void:
	if is_in_dream:
		has_started_dream = true

	if not has_started_dream:
		return

	var main_level = get_tree().current_scene as BaseLevelResource
	if not main_level:
		return

	var is_moon_frozen = main_level.dream_freeze_timers.get("Armstrong", 0.0) > 0.0
	
	if is_in_dream or not is_moon_frozen:
		oxygen_level -= oxygen_consumption_rate * delta
		#print("Sisa Oksigen Armstrong: ", max(0.0, oxygen_level), " detik")
		
		if oxygen_level <= 0:
			oxygen_level = 0.0
			take_damage(5)

func on_character_ko() -> void:
	print("Armstrong KO. Game Over!")
