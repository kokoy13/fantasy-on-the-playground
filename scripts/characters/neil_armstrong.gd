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

func _physics_process(delta: float) -> void:
	if not is_active_character:
		apply_passive_physics(delta)
		return

	apply_gravity(delta)
	handle_jump()
	handle_movement()
	
	# Tambahkan manipulasi gaya dorong Cosmic Storm ke mekanika pergerakan utama sebelum move_and_slide()
	apply_cosmic_storm_force()
	
	handle_special_abilities(delta)
	
	move_and_slide()

func apply_cosmic_storm_force() -> void:
	if not is_in_dream:
		return
		
	var moon_env = get_parent().get_node_or_null("../DimensionManager/MoonEnvironment")
	if moon_env and moon_env.is_storm_active:
		# Karakter terhembus perlahan menuju arah badai kosmik
		velocity.x += moon_env.storm_direction * moon_env.storm_force

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
		# Modifikasi laju oksigen: Jika badai aktif, konsumsi oksigen dikalikan 2
		var current_rate = oxygen_consumption_rate
		var moon_env = get_parent().get_node_or_null("../DimensionManager/MoonEnvironment")
		if is_in_dream and moon_env and moon_env.is_storm_active:
			current_rate *= 2.0
			
		oxygen_level -= current_rate * delta
		
		if oxygen_level <= 0:
			oxygen_level = 0.0
			take_damage(5)

func on_character_ko() -> void:
	print("Armstrong KO. Game Over!")
