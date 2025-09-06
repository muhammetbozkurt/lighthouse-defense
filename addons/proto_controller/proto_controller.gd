# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D

@export var can_move_turrets : bool = true
@export var player_id : int = 1

## Can we move around?
@export var can_move : bool = true
## Are we affected by gravity?
@export var has_gravity : bool = true
## Can we press to jump?
@export var can_jump : bool = true
## Can we hold to run?
@export var can_sprint : bool = false
## Can we press to enter freefly mode (noclip)?
@export var can_freefly : bool = false

@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.002
## Gamepad look sensitivity multiplier.
@export var joy_look_sensitivity : float = 10.0
## Normal speed.
@export var base_speed : float = 7.0
## Speed of jump.
@export var jump_velocity : float = 4.5
## How fast do we run?
@export var sprint_speed : float = 10.0
## How fast do we freefly?
@export var freefly_speed : float = 25.0

@export_group("Input Actions")
## Base name of Input Action to move Left.
@export var input_left : String = "left"
## Base name of Input Action to move Right.
@export var input_right : String = "right"
## Base name of Input Action to move Forward.
@export var input_forward : String = "forward"
## Base name of Input Action to move Backward.
@export var input_back : String = "back"
## Base name of Input Action to Jump.
@export var input_jump : String = "jump"
## Base name of Input Action to Sprint.
@export var input_sprint : String = "sprint"
## Base name of Input Action to deploy a turret.
@export var input_deploy : String = "deploy_turret"
## Base name of Input Action to move a turret.
@export var input_move_turret : String = "move_turret"
@export var input_tower_exit : String = "tower_exit"
@export var input_punch : String = "punch"

#we might want to use enums instead of these mess of bools
var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false
var held_turret: Node3D = null
var is_punch_jab = true
var is_attacking: bool = false
var possible_target: Node3D = null
var possible_decomposable: Node3D = null
var damage: int = 5

var can_use_crosbow: bool = false

@export_group("Interaction")
@export var interaction_ray_length : float = 10.0

## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var collider: CollisionShape3D = $Collider
@onready var manager: Node3D = %Manager
@onready var deploy_point: Marker3D = $DeployPoint
@onready var animation_player: AnimationPlayer = $Appearance/AnimationPlayer
@onready var punchArea: Area3D = $PunchArea
@onready var crossbow: Node3D = $Head/Camera3D/Crossbow


func get_player_action(base_name: String) -> String:
	return "p%d_%s" % [player_id, base_name]


func _ready() -> void:
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x
	
	crossbow.manager = manager
	# Only Player 1 captures the mouse
	if player_id == 1:
		capture_mouse()


func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if player_id == 1:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			capture_mouse()
		if Input.is_key_pressed(KEY_ESCAPE):
			release_mouse()
		if mouse_captured and event is InputEventMouseMotion:
			rotate_look(event.relative)
	
	if can_move_turrets and Input.is_action_just_pressed(get_player_action(input_move_turret)):
		if held_turret:
			place_held()
		else:
			pickup()

func _update_animations() -> void:
	# Guard clause in case you forgot to assign the AnimationPlayer
	if not animation_player:
		return
	
	if is_attacking:
		return


	var horizontal_velocity = velocity
	horizontal_velocity.y = 0 # We only care about movement on the ground plane

	var is_moving: bool = horizontal_velocity.length() > 0.1


	if is_moving:
		# Play the "sprint" animation if it's not already the current one
		if animation_player.current_animation != "Walk":
			animation_player.play("Walk")
	else:
		# Play the "idle" animation if it's not already the current one
		if animation_player.current_animation != "Idle":
			animation_player.play("Idle")

func _physics_process(delta: float) -> void:
	# Gamepad look handling (for all players)
	handle_gamepad_look()
	
	if Input.is_action_just_pressed(get_player_action(input_deploy)):
		var position = deploy_point.global_position
		manager.deploy_turret(position)
	
	# ... (freefly logic is unchanged)
	if can_freefly and freeflying:
		return
	
	if has_gravity and not is_on_floor():
		#velocity += get_gravity() * delta
		velocity.y += -9.8 * delta

	if can_jump and Input.is_action_just_pressed(get_player_action(input_jump)) and is_on_floor():
		velocity.y = jump_velocity

	if can_sprint and Input.is_action_pressed(get_player_action(input_sprint)):
		move_speed = sprint_speed
	else:
		move_speed = base_speed
		
	if Input.is_action_just_pressed(get_player_action(input_tower_exit)):
		exit_tower()

	if can_move:
		var input_dir := Input.get_vector(
			get_player_action(input_left), 
			get_player_action(input_right), 
			get_player_action(input_forward), 
			get_player_action(input_back)
		)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.z = 0
		
	
	
	
	move_and_slide()
	
	_update_animations()
	
	if Input.is_action_just_pressed(get_player_action(input_punch)):
		
		if can_use_crosbow:
			crossbow.shoot_arrow()
		else:
			punch_attack()


func _on_animation_player_animation_finished(anim_name: String):
	if anim_name.contains("Punch"):
		is_attacking = false

## Handles gamepad right-stick look
func handle_gamepad_look():
	var look_right_action = "p%d_look_right" % player_id
	if not InputMap.has_action(look_right_action): return # Skip if no gamepad look actions exist for this player
	
	var h_look = Input.get_axis(get_player_action("look_left"), get_player_action("look_right"))
	var v_look = Input.get_axis(get_player_action("look_up"), get_player_action("look_down"))
	
	if abs(h_look) > 0.1 or abs(v_look) > 0.1:
		var joy_input = Vector2(h_look, v_look) * joy_look_sensitivity
		rotate_look(joy_input)

## Rotate us to look around.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func pickup():
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		camera.global_position, 
		camera.global_position - camera.global_transform.basis.z * interaction_ray_length
	)
	query.exclude = [self] # Exclude the player from the raycast
	var result = space_state.intersect_ray(query)
	
	if result:
		var body = result.collider
		# Check if we hit a turret that can be picked up
		if body.is_in_group("portable") and body.has_method("pickup"):
			held_turret = body
			held_turret.remove_from_group("portable") # Temporarily remove from group
			held_turret.pickup()
			
			# Reparent the turret to the DeployPoint to carry it
			held_turret.reparent(deploy_point)
			held_turret.position = Vector3.ZERO
			held_turret.rotation = Vector3.ZERO
			print("Picked up: ", held_turret.name)

## Places the currently held turret.
func place_held():
	if not is_instance_valid(held_turret):
		return
	
	var turret_to_place = held_turret
	held_turret = null
	
	# Reparent the turret back to the main scene
	turret_to_place.reparent(get_tree().current_scene)
	
	if turret_to_place.has_method("place"):
		turret_to_place.place()
		turret_to_place.add_to_group("portable") # Add back to turrets group
		print("Placed turret: ", turret_to_place.name)
		
func exit_tower():
	manager.exit_tower.emit(player_id)

func punch_attack():
	if is_attacking:
		return
		
	is_attacking = true
	if is_punch_jab:
		animation_player.play("Punch_Cross")
	else:
		animation_player.play("Punch_Jab")
		
	is_punch_jab = not is_punch_jab
	
	if is_instance_valid(possible_target) and possible_target.has_method("take_damage"):
		possible_target.take_damage(damage)
		
	if is_instance_valid(possible_decomposable) and possible_decomposable.has_method("chop_hit"):
		possible_decomposable.chop_hit(damage)

"""
this approach must be updated
"""
func _on_punch_area_body_entered(body: Node3D) -> void:
	if body in get_tree().get_nodes_in_group("enemy") and is_instance_valid(body):
		possible_target = body


func _on_punch_area_body_exited(body: Node3D) -> void:
	if body == possible_target:
		possible_target = null


func _on_punch_area_area_entered(area: Area3D) -> void:
	var body = area.get_parent_node_3d()
	if body in get_tree().get_nodes_in_group("tree") and is_instance_valid(body):
		possible_decomposable = body


func _on_punch_area_area_exited(area: Area3D) -> void:
	var body = area.get_parent_node_3d()
	if body == possible_decomposable:
		possible_decomposable = null
		
