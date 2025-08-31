extends Area3D

@export var landing_zone: Marker3D


func _on_body_entered(body: Node3D) -> void:
	print("body entered: ", body)
	
	if landing_zone and body.name == "ProtoController":
		var tp_point = landing_zone.global_position
		body.global_position = tp_point
		reset_physics_interpolation()
		
