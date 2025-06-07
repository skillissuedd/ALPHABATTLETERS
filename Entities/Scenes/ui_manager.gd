extends Control

func _on_toggle_preview_button_down() -> void:
	if GlobalOptions.toggle_preview_animations:
		$TogglePreview.text = "Enable preview"
		GlobalOptions.toggle_preview_animations = false
		Global.battle_simulator.load_backups()
	else:
		$TogglePreview.text = "Disable preview"
		GlobalOptions.toggle_preview_animations = true
		Global.battle_simulator.run_simulation()
		
