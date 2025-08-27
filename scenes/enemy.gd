# enemy.gd
extends CharacterBody3D

@export var move_speed: float = 5.0
@export var attack_damage: float = 2.0
@export var attack_rate: float = 1.0
@export var health: float = 10.0

var target: Node3D = null
var can_attack: bool = true

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		find_new_target()
		
	if is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * move_speed
		move_and_slide()
		
		# Check if the enemy is close enough to attack
		if global_position.distance_to(target.global_position) < 2.0 and can_attack:
			attack_target()
			can_attack = false
			await get_tree().create_timer(1.0 / attack_rate).timeout
			can_attack = true
	else:
		velocity = Vector3.ZERO
		
func take_damage(amount: float) -> void:
	health -= amount
	print("enemy health: ", health, " amount: ", amount)
	if health <= 0:
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
	
	if closest_turret:
		target = closest_turret

func _ready() -> void:
	# Add the enemy to a group so turrets can find it
	add_to_group("enemies")
