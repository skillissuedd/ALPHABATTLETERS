extends Control

func _ready():
	pass


func _on_yes_button_button_up() -> void:
	get_tree().change_scene_to_file("res://prototype/tutorial/tutorial2.tscn")


func _on_no_button_button_up() -> void:
	get_tree().change_scene_to_file("res://Entities/Scenes/Rooms/MainScene.tscn")
