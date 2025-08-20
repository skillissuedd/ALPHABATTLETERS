extends slot_upgrade
var is_used: bool = false
@onready var label: Label = $Sprite2D/Label
@onready var label_2: Label = $Sprite2D/Label2


func letter_is_placed(letter2D: Node2D):
	if !is_used and letter2D.properties.current_upgrade == "":
		is_used = true
		GlobalSignals.emit_upgrade_slot_is_used()
		label.queue_free()
		label_2.queue_free()
		for letter2Dinstance in Global.deck_scene.get_instances_of_letter(letter2D.properties.letter):
			letter2Dinstance.properties.current_upgrade = "Trajectory"
			letter2Dinstance.letterDisplay.upgrade_label.text = "("
			letter2Dinstance.letterDisplay.upgrade_label.rotation = -90
			letter2Dinstance.letterDisplay.generic_upgrade_animation()
			letter2Dinstance.letterDisplay.upgrade_label.add_theme_color_override("font_color", Color.ROYAL_BLUE)
			letter2Dinstance.letterDisplay.letter_label.add_theme_color_override("default_color", Color.ROYAL_BLUE)
			letter2Dinstance.frame_bar.border_color = Color.ROYAL_BLUE
			if letter2Dinstance.properties.NSAB == true:
				letter2Dinstance.properties.max_hp+=1
				letter2Dinstance.properties.attack+=1
				letter2Dinstance.letterDisplay.update_stats()
		await letter2D.letterDisplay.animation_ended
		letter_is_taken()
		GlobalSignals.emit_upgrade_completed()
		Global.hand_scene.snap_to_hand(letter2D)
