# game_ui.gd
extends CanvasLayer

# Get references to our UI nodes
@onready var health_bar: ProgressBar = $HealthBar
@onready var arrow_label: Label = $ArrowCountLabel
@onready var manager: Node3D = %Manager
func _ready() -> void:
	# Check if the tower was found before connecting
	if manager:
		# Connect this script's 'update_health_ui' function to the tower's 'health_changed' signal.
		# Now, whenever the tower emits the signal, our function will automatically run.
		manager.health_changed.connect(update_health_ui)
		#manager.arrow_count_change(current_count: int, max_count: int)
		manager.arrow_count_change.connect(update_arrow_count)

# This function updates the visuals of the health bar and label.
func update_health_ui(current_health: float, max_health: float) -> void:
	# Update the ProgressBar value
	health_bar.max_value = max_health
	health_bar.value = current_health
	
	print("max_health: ", max_health, " current_health: ", current_health)
	
	## Update the Label text
	#health_label.text = "%d / %d" % [current_health, max_health]

func update_arrow_count(current_count: int, max_count: int):
	arrow_label.text = "Arrow Count: %d / %d" % [current_count, max_count]
