extends slot_class
var is_used: bool = false
@onready var vector_label = $Sprite2D/Label

func letter_is_placed():
	if !is_used:
		is_used = true
		vector_label.queue_free()
		var letter_upgrade = current_letter.get_upgrade()
		if letter_upgrade == null:
			current_letter.current_upgrade = "Vector"
			current_letter.current_hp = current_letter.current_atk
			current_letter.current_atk = current_letter.max_hp
			current_letter.max_hp = current_letter.current_hp
			current_letter.letter_unit.update_stats(current_letter.current_hp,current_letter.current_atk)
			current_letter.LetterDisplay.vector_upgrade_animation()
