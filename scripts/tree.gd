extends Node3D

@export var health = 10
@export var log_scene: PackedScene

func _ready() -> void:
	if log_scene == null:
		push_error("Manager: 'log_scene' is not set! Please assign an TreeLog.tscn.")
	
	add_to_group("tree")

func chop_hit(damage: int):
	health -= damage
	
	if health <= 0:
		if log_scene:
			var log = log_scene.instantiate()
			log.global_position = global_position + Vector3.UP * 2
			get_tree().current_scene.add_child(log)
		queue_free()
