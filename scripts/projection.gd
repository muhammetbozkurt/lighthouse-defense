extends Area3D

@onready var light = $SpotLight3D

var is_light_mounted = false

var current_body: CharacterBody3D


func _physics_process(delta: float) -> void:
	if is_light_mounted and current_body:
		var head = current_body.get_node("Head")
		var position = head.global_position
		
		
		# --- CORRECTION STARTS HERE ---
		# --- CORRECTION STARTS HERE ---
		light.global_transform = head.global_transform
		light.global_position = position
		# --- CORRECTION ENDS HERE ---
		


func _on_body_entered(body: Node3D) -> void:
	print("light mounted")
	is_light_mounted = true
	if body.name == "ProtoController":
		current_body = body


func _on_body_exited(body: Node3D) -> void:
	print("light unmounted")
	is_light_mounted = false
	current_body = null
