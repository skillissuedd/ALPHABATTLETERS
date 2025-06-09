extends slot_class
var is_used: bool = false
@onready var rebirth_label = $Sprite2D/Label


func letter_is_placed():
	if !is_used:
		var letter_upgrade = current_letter.get_upgrade()
		if letter_upgrade == null:
			is_used = true
			rebirth_label.queue_free()
			current_letter.current_upgrade = "Rebirth"
			var next_letter = get_next_letter(current_letter.current_letter)
			current_letter.LetterDisplay.rebirth_upgrade_animation(next_letter)
			current_letter.finish_letter_preparation(next_letter)

			Global.battle_simulator.run_simulation()
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
