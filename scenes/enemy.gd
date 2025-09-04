# enemy.gd
extends CharacterBody3D

@export var move_speed: float = 5.0
@export var attack_damage: float = 2.0
@export var attack_rate: float = 1.0
@export var health: float = 10.0
@export var damage_indicator_scene: PackedScene 


@onready var attack_timer: Timer = $AttackTimer


var manager: Node3D = null
var tower: StaticBody3D = null
var target: Node3D = null
var can_attack: bool = true

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		find_new_target()
		
	if is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * move_speed
		velocity.y = -9.8 * delta
		
		look_at(target.global_position)

		move_and_slide()
		
		# Check if the enemy is close enough to attack
		var target_vector = target.global_position
		target_vector.y = global_position.y
		if global_position.distance_to(target_vector) < 4.0 and can_attack:
			attack_target()
			can_attack = false
			# Start the timer instead of awaiting
			attack_timer.start(1.0 / attack_rate)
	else:
		velocity = Vector3.ZERO
		
func take_damage(amount: float) -> void:
	health -= amount
	print("enemy health: ", health, " amount: ", amount)
	
	if damage_indicator_scene:
		var indicator = damage_indicator_scene.instantiate()
		# Add it to the main scene tree so it doesn't move with the enemy
		get_tree().current_scene.add_child(indicator)
		# Call the start function to begin the animation
		indicator.start(amount, global_position + Vector3.UP*1.2) # Spawn slightly above the enemy
	
	if health <= 0:
		manager.death_utils()
		queue_free()

func attack_target() -> void:
	if is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(attack_damage)
		print("Enemy attacking a turret!")
		
func find_new_target() -> void:
	# Find the closest turret to attack
	var closest_turret: Node3D = null
	var min_distance: float = INF
	
	for node in get_tree().get_nodes_in_group("turrets"):
		var distance = global_position.distance_to(node.global_position)
		if distance < min_distance:
			min_distance = distance
			closest_turret = node
	
	if min_distance > global_position.distance_to(tower.global_position):
		closest_turret = tower
	
	if closest_turret:
		target = closest_turret

func _ready() -> void:
	# Add the enemy to a group so turrets can find it
	add_to_group("enemies")


func _on_attack_timer_timeout() -> void:
	can_attack = true
