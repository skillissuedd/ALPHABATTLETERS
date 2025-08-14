extends slot_class

var is_used: bool = false
@onready var rebirth_label = $Sprite2D/Label


func letter_is_placed(letter2D: Node2D):
	if !is_used and letter2D.properties.current_upgrade == "":
		is_used = true
		rebirth_label.queue_free()
		var next_letter = get_next_letter(letter2D.properties.letter)
		for letter2Dinstance in Global.deck_scene.get_instances_of_letter(letter2D.properties.letter):
			letter2Dinstance.properties.current_upgrade = "Rebirth"
			letter2Dinstance.init_letter(next_letter, false)
			letter2Dinstance.letterDisplay.rebirth_upgrade_animation(next_letter)
			letter2Dinstance.letterDisplay.upgrade_label.add_theme_color_override("font_color", Color.LIME_GREEN)
			letter2Dinstance.letterDisplay.letter_label.add_theme_color_override("font_color", Color.LIME_GREEN)
			letter2Dinstance.frame_bar.border_color = Color.WEB_GREEN
			
func get_next_letter(letter: String) -> String:
	if letter.length() != 1:
		return ""
	var code := letter.to_ascii_buffer()[0]
	if code >= 65 and code <= 89:  # 'A' to 'Y'
		return char(code + 1)
	elif code == 90:  # 'Z' wraps to 'A'
		return "A"
	else:
		return "" 
