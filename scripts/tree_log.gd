extends RigidBody3D


var is_active := true

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	add_to_group("portable")
	add_to_group("logs")


# New function to handle being picked up
func pickup() -> void:
	collision_shape.disabled = true
	freeze = true
	print("Turret picked up")

# New function to handle being placed down
func place() -> void:
	collision_shape.disabled = false
	# The turret will find a new target automatically via _process -> find_new_target
	
	freeze = false
	print("Turret placed")
