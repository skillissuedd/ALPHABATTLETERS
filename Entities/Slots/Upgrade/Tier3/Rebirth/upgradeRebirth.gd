extends slot_class
var is_used: bool = false
@onready var rebirth_label = $Sprite2D/Label


func letter_is_placed():
	if !is_used and current_letter.properties.current_upgrade == "":
		is_used = true
		rebirth_label.queue_free()
		current_letter.properties.current_upgrade = "Rebirth"
		var next_letter = get_next_letter(current_letter.properties.letter)
		current_letter.init_letter(next_letter, false)
		current_letter.letterDisplay.rebirth_upgrade_animation(next_letter)
		current_letter.letterDisplay.upgrade_label.visible = true
		current_letter.letterDisplay.upgrade_label.add_theme_color_override("font_color", Color.LIME_GREEN)
		current_letter.letterDisplay.letter_label.add_theme_color_override("font_color", Color.LIME_GREEN)
		current_letter.frame_bar.border_color = Color.WEB_GREEN
			
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
