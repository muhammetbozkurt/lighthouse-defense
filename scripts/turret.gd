# turret.gd
extends StaticBody3D

@export var attack_damage: float = 1.0
@export var attack_rate: float = 5.0 # Attacks per second
@export var health: float = 20.0

@onready var timer: Timer = $Timer

var can_attack: bool = true
var target: CharacterBody3D = null

func _ready() -> void:
	# Connect signals from the Area3D
	$AttackRange.body_entered.connect(_on_attack_range_body_entered)
	$AttackRange.body_exited.connect(_on_attack_range_body_exited)
	
	# Start a timer for the attack rate
	#attack_timer.wait_time = 1.0 / attack_rate
	#attack_timer.one_shot = false
	#attack_timer.autostart = true
	#attack_timer.connect("timeout", _on_attack_timer_timeout)
	timer.connect("timeout", _on_attack_timer_timeout)

func _process(delta: float) -> void:
	if is_instance_valid(target):
		# Point the turret towards the target
		look_at(target.global_position, Vector3.UP)
	#else:
		# If the current target is invalid, find a new one
		#find_new_target()

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		queue_free()

func _on_attack_range_body_entered(body: Node3D) -> void:
	timer.start()
	print(body.name)
	if body.name == "Enemy" and not is_instance_valid(target):
		print(body.name, " enemy set")
		target = body
		
func _on_attack_range_body_exited(body: Node3D) -> void:
	timer.stop()
	if body == target:
		target = null

func find_new_target() -> void:
	var bodies_in_range = $AttackRange.get_overlapping_bodies()
	for body in bodies_in_range:
		if body.name == "Enemy":
			target = body
			return

func _on_attack_timer_timeout() -> void:
	print("_on_attack_timer_timeout")
	if is_instance_valid(target):
		print("-------", target)
		# Check if the target has a 'take_damage' method
		if target.has_method("take_damage"):
			target.take_damage(attack_damage)
			print("Turret attacking enemy!")
