extends Area3D

@onready var manager = %Manager


func _on_body_entered(body: Node3D) -> void:
	if is_instance_valid(body) and body.is_in_group("logs"):
		manager.add_arrow_to_stash()
		body.queue_free()
