extends Control

@onready var toggle_preview: Button = $TogglePreview
@onready var add_letter: Button = $AddLetter
@onready var fight_button: Button = $FightButton

func _on_toggle_preview_button_down() -> void:
	disable_preview()
	$TogglePreview.text = "Enable preview"
	$TogglePreview.text = "Disable preview"
	
func disable_preview():
	if GlobalOptions.toggle_preview_animations:
		GlobalOptions.toggle_preview_animations = false
		Global.battle_simulator.load_backups()
	else:
		GlobalOptions.toggle_preview_animations = true
		Global.battle_simulator.run_simulation()
		


func _on_add_letter_pressed() -> void:
	Global.hand_scene.max_hand_size+=1
	Global.hand_scene.snap_to_hand(Global.deck_scene.get_random_letter_instance())


func _on_fight_button_pressed() -> void:
	Global.battle_manager.round_start()
	set_ui_enabled(false)

func set_ui_enabled(enabled: bool):
	toggle_preview.disabled = not enabled
	add_letter.disabled = not enabled
	fight_button.disabled = not enabled
