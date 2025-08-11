extends Control
var state:int = 0

func _ready():
	Global.deck_scene = $deckNode/Deck
	$deckNode/Deck.GRID_COLUMNS = 8
	$deckNode/Deck.set_all_letters_inactive()
	$deckNode/Deck.initialize_deck()
	$deckNode/Deck.fill_deck()


func _on_ok_button_button_up() -> void:
	state+=1
	match state:
		1:
			$handManager.circle_radius = 200
			$handManager.set_hand_enabled(false)
			$tutorLabel.text = "tutorial_2"
			$deckNode/Deck.position = Vector2(1000,3000)
			$handManager.visible = true
			$handManager.fill_hand()
		2:
			$tutorLabel.text = "tutorial_3"
		3:
			$tutorLabel.text = "tutorial_4"
			$okButton.text = "tutorial_start"
			$handManager.position = Vector2(1000,3000)
			$CustomHealthBar.visible = true
			$CustomHealthBar._setup_health_bar(20.0)
		4:
			get_tree().change_scene_to_file("res://Entities/Scenes/Rooms/MainScene.tscn")
