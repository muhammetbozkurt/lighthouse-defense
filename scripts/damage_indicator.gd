# damage_indicator.gd
extends Label3D

# This function will be called by the enemy to start the animation
func start(damage_amount: float, initial_position: Vector3, color: Color = Color(Color.RED, 0.8)) -> void:
	# Set the text and initial position
	text = str(damage_amount)
	global_position = initial_position
	modulate = color
	
	# Create a tween to handle the animation
	var tween = create_tween()

	# Set the animation properties
	var duration = 2
	var float_height = 2.0
	
	# Animate the position upwards
	tween.tween_property(self, "position:y", position.y + float_height, duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	# Animate the fade-out effect at the same time
	# We start fading after a short delay to keep the number visible initially
	tween.parallel().tween_property(self, "modulate:a", 0.0, duration * 0.7).set_delay(duration * 0.3)
	
	# When the tween is finished, delete the label
	tween.tween_callback(queue_free)
