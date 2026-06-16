class_name InteractableObject
extends StaticBody2D

@export var interactable: bool = true

func update_dimension_state(is_in_dream: bool, current_character: String) -> void:
	if not interactable:
		return
		
	if is_in_dream and current_character == "Armstrong":
		$Sprite2D.modulate = Color(0.5, 0.8, 1.0, 1.0)
		$CollisionShape2D.disabled = false
	else:
		$Sprite2D.modulate = Color(1.0, 1.0, 1.0, 1.0)
		$CollisionShape2D.disabled = false
