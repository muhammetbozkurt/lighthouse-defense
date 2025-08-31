extends Node3D

@onready var sun: DirectionalLight3D = $Sun
@onready var tower: StaticBody3D = $"../Tower"

@export var turret_scene: PackedScene
@export_group("Enemy Settings")
@export var enemy_scene: PackedScene
@export var initial_wave_size: int = 3
@export var wave_size_increment: int = 1
#@export var min_spawn_distance: float = 50.0
@export var max_spawn_distance: float = 10.0

@export var turret_limit = 6


var is_day: bool = true
var target_energy: float = 1.0
var current_wave: int = 0
var enemies_alive: int = 0
var wave_in_progress: bool = false
var wave_delay_timer: Timer = null
var current_turrets: Array[Node3D] = []

func _ready() -> void:
	if enemy_scene == null:
		push_error("Manager: 'enemy_scene' is not set! Please assign an Enemy.tscn.")
	if turret_scene == null:
		push_error("Manager: 'turret_scene' is not set! Please assign a Turret.tscn.")

	# Set up a timer for the wave delay
	wave_delay_timer = Timer.new()
	add_child(wave_delay_timer)
	wave_delay_timer.connect("timeout", _on_wave_delay_timer_timeout)

func _process(delta: float) -> void:
	if check_wave_end():
		wave_in_progress = false
		turret_limit += 1
	
	if Input.is_key_pressed(KEY_1):
		is_day = not is_day
		target_energy = 1.0 if is_day else 0.06
	
	# Smoothly transition the light_energy towards the target_energy
	sun.light_energy = lerp(sun.light_energy, target_energy, delta * 2.0)
	
	
	if not is_day and enemies_alive <= 0 and Input.is_key_pressed(KEY_2):
		start_next_wave()


func generate_position(seed: Vector3) -> Vector3:
	var spawn_direction = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized()
	var spawn_distance = randf_range(50, 60)
	
	return seed + spawn_direction * spawn_distance

func death_utils():
	enemies_alive -= 1
	
	if enemies_alive <= 0:
		enemies_alive = 0
		wave_in_progress = false 
	
	

func start_next_wave() -> void:
	wave_in_progress = true
	current_wave += 1
	enemies_alive = 0
	
	var enemies_to_spawn = initial_wave_size + (current_wave - 1) * wave_size_increment
	print("--- Starting Wave %d with %d enemies ---" % [current_wave, enemies_to_spawn])
	
	var spawn_center = generate_position(global_position)
	for i in range(enemies_to_spawn):
		spawn_enemy(spawn_center)
	
	wave_delay_timer.start(5.0) # Start the timer for the next wave
	wave_in_progress = false

func spawn_enemy(spawn_center: Vector3) -> void:
	if enemy_scene == null: return
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.add_to_group("enemy")
	if enemy_instance:
		enemy_instance.manager = self
		enemy_instance.tower = tower
		var spawn_direction = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized()
		var spawn_distance = randf_range(0, max_spawn_distance)
		enemy_instance.global_position = spawn_center + spawn_direction * spawn_distance
		get_tree().current_scene.add_child(enemy_instance)
		enemies_alive += 1

func check_wave_end() -> bool:
	return wave_in_progress and enemies_alive == 0

func deploy_turret(position: Vector3) -> void:
	if turret_scene == null: return
	var size = get_tree().get_node_count_in_group("turrets")
	if turret_limit <= size: return
	
	var turret_instance = turret_scene.instantiate()
	if turret_instance:
		# Place the turret in front of the manager's position for this example
		turret_instance.global_position = position
		get_tree().current_scene.add_child(turret_instance)
		# Add the turret to a group so enemies can find it
		turret_instance.add_to_group("turrets")
		print("Turret deployed!")

func _on_wave_delay_timer_timeout() -> void:
	# This function is now the trigger for starting the next wave
	pass
