# turret.gd
extends StaticBody3D

@export var attack_damage: float = 1.0
@export var attack_rate: float = 5.0 # Attacks per second
@export var health: float = 20.0

@onready var timer: Timer = $Timer
@onready var attack_range: Area3D = $AttackRange
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@export var damage_indicator_scene: PackedScene 


var can_attack: bool = true
var target: CharacterBody3D = null
var is_active: bool = true # New flag to control turret state

func _ready() -> void:
	# Connect signals from the Area3D
	attack_range.body_entered.connect(_on_attack_range_body_entered)
	attack_range.body_exited.connect(_on_attack_range_body_exited)
	
	timer.connect("timeout", _on_attack_timer_timeout)

func _process(delta: float) -> void:
	# Only run logic if the turret is active
	if not is_active:
		return
		
	if is_instance_valid(target):
		look_at(target.global_position, Vector3.UP)
	else:
		find_new_target()

# New function to handle being picked up
func pickup() -> void:
	is_active = false
	collision_shape.disabled = true
	target = null # Clear the target
	timer.stop() # Stop the attack timer
	print("Turret picked up")

# New function to handle being placed down
func place() -> void:
	is_active = true
	collision_shape.disabled = false
	# The turret will find a new target automatically via _process -> find_new_target
	print("Turret placed")

func take_damage(amount: float) -> void:
	health -= amount
	if damage_indicator_scene:
		var indicator = damage_indicator_scene.instantiate()
		# Add it to the main scene tree so it doesn't move with the enemy
		get_tree().current_scene.add_child(indicator)
		# Call the start function to begin the animation
		indicator.start(amount, global_position + Vector3.UP*1.2, Color(Color.ORANGE, 0.8)) #
	
	if health <= 0:
		queue_free()

func _on_attack_range_body_entered(body: Node3D) -> void:
	if not is_active: return # Guard against running when inactive

	timer.start()
	print(body.name)
	
	if body.is_in_group("enemy") and not is_instance_valid(target):
		print(body.name, " enemy set")
		target = body
		
func _on_attack_range_body_exited(body: Node3D) -> void:
	if not is_active: return # Guard against running when inactive

	timer.stop()
	if body == target:
		target = null

func find_new_target() -> void:
	var bodies_in_range = attack_range.get_overlapping_bodies()

	for body in bodies_in_range:
		if body.is_in_group("enemy"):
			target = body
			timer.start()
			return

func _on_attack_timer_timeout() -> void:
	if not is_active: return # Guard against running when inactive

	print("_on_attack_timer_timeout")
	if is_instance_valid(target):
		print("-------", target)
		if target.has_method("take_damage"):
			target.take_damage(attack_damage)
			print("Turret attacking enemy!")
