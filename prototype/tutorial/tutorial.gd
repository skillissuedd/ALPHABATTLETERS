extends Control

func _ready():
	pass


func _on_yes_button_button_up() -> void:
	get_tree().change_scene_to_file("res://prototype/tutorial/tutorial2.tscn")


func _on_no_button_button_up() -> void:
	get_tree().change_scene_to_file("res://Entities/Scenes/Rooms/MainScene.tscn")

func _process(delta):
	var hue = fmod(Time.get_ticks_msec() / 10000.0, 1.0)
	$logo.add_theme_color_override("font_color", Color.from_hsv(hue, 1, 1))
