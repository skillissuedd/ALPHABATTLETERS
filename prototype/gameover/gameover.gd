extends Control

func _ready():
	if GlobalOptions.round_outcome == true:
		$gameoverLabel.text = "gameover_won"
	else:
		$gameoverLabel.text = "gameover_lost"
func _on_retry_button_button_up() -> void:
	get_tree().change_scene_to_file("res://Entities/Scenes/Rooms/MainScene.tscn")
