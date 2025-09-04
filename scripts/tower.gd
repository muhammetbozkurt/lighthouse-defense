extends StaticBody3D


@onready var manager: Node3D = %Manager
@export var max_health: float = 100.0
var current_health: float

func _ready() -> void:
	current_health = max_health
	# Emit the signal once at the start to set the initial UI state
	manager.health_changed.emit(current_health, max_health)

func take_damage(amount: float) -> void:
	print("---- tower take damage ----")
	current_health -= amount
	current_health = max(0, current_health) # Prevent health from going below zero
	
	# Emit the signal to notify any connected nodes (like our UI)
	manager.health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		print("Tower has been destroyed! Game Over.")
		get_tree().reload_current_scene()
