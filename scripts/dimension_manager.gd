extends Node

static func get_dream_y_position(character_name: String, current_x: float) -> float:
	match character_name:
		"Armstrong":
			return 200.0
		"Arthur":
			return 350.0
		_:
			return 0.0
