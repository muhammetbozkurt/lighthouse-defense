extends Area3D

@export var landing_zone: Area3D


func _on_body_entered(body: Node3D) -> void:
	print("body entered: ", body)
	
	if landing_zone:
		var tp_point = landing_zone.get_node("LandPoint").global_position
		body.global_position = tp_point
		reset_physics_interpolation()
		
