extends Node2D

func set_environment_state(is_active: bool, is_frozen: bool) -> void:
	if is_frozen:
		set_state_recursive(self, true, false)
	else:
		set_state_recursive(self, is_active, true)

func set_state_recursive(node: Node, is_active: bool, change_visibility: bool = true) -> void:
	if change_visibility and node is CanvasItem:
		node.visible = is_active
		
	node.set_process(is_active)
	node.set_physics_process(is_active)
	
	if node is CollisionShape2D or node is CollisionPolygon2D:
		node.set_deferred("disabled", not is_active)
		
	for child in node.get_children():
		set_state_recursive(child, is_active, change_visibility)
