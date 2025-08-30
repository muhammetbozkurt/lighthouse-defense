extends StaticBody3D

@export var health = 100

func take_damage(attack_damage: float):
	health -= attack_damage
	print("tower health: ", health)
	if health <= 0:
		get_tree().reload_current_scene()
