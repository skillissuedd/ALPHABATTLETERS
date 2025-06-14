extends slot_class
var is_used: bool = false
@onready var vector_label = $Sprite2D/Label

func letter_is_placed():
	if !is_used and current_letter.properties.current_upgrade == "":
		is_used = true
		vector_label.queue_free()
		current_letter.properties.current_upgrade = "Vector"
		var hp = current_letter.properties.attack
		var atk = current_letter.properties.max_hp
		Global.letter_stats.update_global_stat(current_letter.properties.letter, "atk", atk)
		Global.letter_stats.update_global_stat(current_letter.properties.letter, "hp", hp)
		Global.deck_scene.update_letter_instances(current_letter.properties)
		current_letter.properties.update_stats(atk, hp)
		current_letter.LetterDisplay.vector_upgrade_animation()
		current_letter.LetterDisplay.upgrade_label.visible = true
		current_letter.LetterDisplay.upgrade_label.add_theme_color_override("font_color", Color.LIME_GREEN)
		current_letter.LetterDisplay.letter_label.add_theme_color_override("font_color", Color.LIME_GREEN)
		current_letter.frame_bar.border_color = Color.WEB_GREEN
