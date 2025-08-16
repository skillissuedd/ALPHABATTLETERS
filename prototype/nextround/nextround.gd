extends Control

func _ready():
	if GlobalOptions.round_outcome == true:
		$gameoverLabel.text = "gameover_won"
		$gameoverLabel.add_theme_color_override("font_color", Color.SEA_GREEN)
	else:
		$gameoverLabel.text = "gameover_lost"
		$gameoverLabel.add_theme_color_override("font_color", Color.CRIMSON)
func _on_retry_button_button_up() -> void:
	get_tree().change_scene_to_file("res://Entities/Scenes/Rooms/MainScene.tscn")
