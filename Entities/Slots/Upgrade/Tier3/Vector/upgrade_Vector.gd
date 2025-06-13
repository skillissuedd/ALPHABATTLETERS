extends slot_class
var is_used: bool = false
@onready var vector_label = $Sprite2D/Label

func letter_is_placed():
	if !is_used:
		is_used = true
		vector_label.queue_free()
		var letter_upgrade = current_letter.properties.current_upgrade
		if letter_upgrade == "":
			var hp = current_letter.properties.attack
			var atk = current_letter.properties.max_hp
			Global.letter_stats.update_global_stat(current_letter.properties.letter, "atk", atk)
			Global.letter_stats.update_global_stat(current_letter.properties.letter, "hp", hp)
			Global.deck_scene.update_letter_instances(current_letter.properties)
			current_letter.properties.update_stats(atk, hp)
			current_letter.LetterDisplay.vector_upgrade_animation()
			current_letter.properties.current_upgrade = "Vector"
