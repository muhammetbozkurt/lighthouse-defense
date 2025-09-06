extends RigidBody3D

var damage: int = 10
var direction: Vector3 =Vector3.FORWARD
var speed: float = 60.0

@onready var existance_timer: Timer = $ExistanceTimer


func  start(start_transform: Transform3D) -> void:
	global_transform = start_transform
	direction = -start_transform.basis.z # -z is forward


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_existance_timer_timeout() -> void:
	queue_free()



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
