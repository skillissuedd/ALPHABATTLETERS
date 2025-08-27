extends slot_upgrade
var is_used: bool = false
@onready var vector_label = $Sprite2D/Label

func _ready():
	slot_upgrade_type = "Vector"

func letter_is_placed(letter2D: Node2D):
	if !is_used and letter2D.properties.current_upgrade == "":
		is_used = true
		GlobalSignals.emit_upgrade_slot_is_used()
		vector_label.queue_free()
		var hp = letter2D.properties.attack
		var atk = letter2D.properties.max_hp
		Global.letter_stats.update_global_stat(letter2D.properties.letter, "atk", atk)
		Global.letter_stats.update_global_stat(letter2D.properties.letter, "hp", hp)
		for letter2Dinstance in Global.deck_scene.get_instances_of_letter(letter2D.properties.letter):
			letter2Dinstance.properties.current_upgrade = "Vector"
			letter2Dinstance.properties.update_stats(atk, hp)
			letter2Dinstance.letterDisplay.vector_upgrade_animation()
			letter2Dinstance.letterDisplay.upgrade_label.add_theme_color_override("font_color", Color.WEB_GREEN)
			letter2Dinstance.letterDisplay.letter_label.add_theme_color_override("default_color", Color.WEB_GREEN)
			letter2Dinstance.frame_bar.border_color = Color.WEB_GREEN
			if letter2Dinstance.properties.NSAB == true:
				letter2Dinstance.properties.max_hp+=1
				letter2Dinstance.properties.attack+=1
				letter2Dinstance.letterDisplay.update_stats()
		await letter2D.letterDisplay.animation_ended
		letter_is_taken()
		GlobalSignals.emit_upgrade_completed()
		Global.hand_scene.snap_to_hand(letter2D)
