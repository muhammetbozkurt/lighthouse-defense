extends Node3D

@export var arrow_scene: PackedScene
@export var reload_time: int = 10

var manager: Node3D


@onready var reaload_timer := $ReloadTimer
#@onready var manager := %Manager


var is_ready_to_shoot = true 


func _ready() -> void:
	if not arrow_scene:
		push_error("Crossbow needs a arrow scene")

func shoot_arrow():
	if not manager:
		push_error("MANAGERRRRRRRRRRR!!!!!!!!!!!!")

	if (not is_ready_to_shoot) and (not manager.can_shoot_arrow()):
		print("needs reload or more arrows ") 
		return
	is_ready_to_shoot = false
	
	var arrow := arrow_scene.instantiate()
	arrow.add_to_group("arrows")
	get_tree().current_scene.add_child(arrow)
	
	if arrow.has_method("start"):
		arrow.start(global_transform)
		manager.deacrease_arrow_count()
	
func reload():
	if is_ready_to_shoot:
		return

	reaload_timer.start(reload_time)


func _on_reload_timer_timeout() -> void:
	is_ready_to_shoot = true
