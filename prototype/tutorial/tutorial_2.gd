extends Control
var state:int = 0

func _ready():
	Global.deck_scene = $deckNode/Deck
	$deckNode/Deck.GRID_COLUMNS = 14
	$deckNode/Deck.set_all_letters_inactive()
	$deckNode/Deck.initialize_deck()
	$deckNode/Deck.fill_deck()
	Global.ui_manager = $UiManager
	$UiManager.ally_health_bar.visible = false
	$UiManager.toggle_preview.visible = false
	$UiManager.total_energy = 99
	

func _on_ok_button_button_up() -> void:
	state+=1
	match state:
		1:
			Global.hand_scene = $handManager
			$handManager.circle_radius = 270
			$handManager.set_hand_enabled(false)
			$tutorLabel.text = "tutorial_2"
			$deckNode/Deck.position = Vector2(1000,3000)
			$handManager.visible = true
			$handManager.fill_hand()
			$handManager.max_hand_size = 52
			$UiManager.sort_button.visible = true
			$UiManager.sort_button.global_position = Vector2(100,500)
			$UiManager.draw_button.visible = true
			$UiManager.draw_button.global_position = Vector2(1300,350)
			$UiManager.energy_main.visible = true
			$UiManager.energy_main.global_position = Vector2(1500,600)
			$UiManager._refill_energy()
			
		2:
			$tutorLabel.text = "tutorial_3"
			$UiManager.queue_free()
		3:
			$tutorLabel.text = "tutorial_4"
			$okButton.text = "tutorial_start"
			$handManager.position = Vector2(1000,3000)
			$CustomHealthBar.visible = true
			$CustomHealthBar._setup_health_bar(20.0)
		4:
			get_tree().change_scene_to_file("res://Entities/Scenes/Rooms/MainScene.tscn")
