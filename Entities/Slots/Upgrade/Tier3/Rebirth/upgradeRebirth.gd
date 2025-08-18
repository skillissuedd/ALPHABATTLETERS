extends slot_upgrade
var is_used: bool = false
@onready var rebirth_label = $Sprite2D/Label


func letter_is_placed(letter2D: Node2D):
	if !is_used and letter2D.properties.current_upgrade == "":
		is_used = true
		GlobalSignals.emit_upgrade_slot_is_used()
		rebirth_label.queue_free()
		var next_letter = get_next_letter(letter2D.properties.letter)
		for letter2Dinstance in Global.deck_scene.get_instances_of_letter(letter2D.properties.letter):
			letter2Dinstance.properties.current_upgrade = "Rebirth"
			letter2Dinstance.letterDisplay.rebirth_upgrade_animation(next_letter)
		await letter2D.letterDisplay.animation_ended
		letter_is_taken()
		GlobalSignals.emit_upgrade_completed()
		Global.hand_scene.snap_to_hand(letter2D)
	
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
