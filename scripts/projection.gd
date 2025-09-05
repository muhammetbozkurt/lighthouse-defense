extends Area3D


@export var exit_point: Marker3D = null

@onready var light = $SpotLight3D
@onready var manager: Node3D = %Manager

var is_light_mounted = false

var current_body: CharacterBody3D

func _ready():
	manager.exit_tower.connect(_on_exit_tower)


func _physics_process(delta: float) -> void:
	if is_light_mounted and current_body:
		var head = current_body.get_node("Head")
		
		
		light.global_transform = head.global_transform
		light.global_position = head.global_position
		
func _on_body_entered(body: Node3D) -> void:
	print("light mounted")
	is_light_mounted = true
	if body.name == "ProtoController":
		current_body = body


func _on_body_exited(body: Node3D) -> void:
	print("light unmounted")
	is_light_mounted = false
	current_body = null

func _on_exit_tower(player_id: int):
	if not current_body:
		return
	var current_player_id: int = current_body.get("player_id")
	
	if current_player_id == player_id and exit_point:
		is_light_mounted = false
		current_body.global_position = exit_point.global_position
