extends Control

func _ready() -> void:
	$VBoxContainer/PlayButton.pressed.connect(_on_play_button_pressed)
	$VBoxContainer/OptionsButton.pressed.connect(_on_options_button_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_options_button_pressed() -> void:
	print("Options button pressed")
	# TODO: Implement options menu

func _on_quit_button_pressed() -> void:
	get_tree().quit()
