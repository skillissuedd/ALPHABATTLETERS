extends slot_class
var is_used: bool = false
@onready var label: Label = $Sprite2D/Label
@onready var label_2: Label = $Sprite2D/Label2
@onready var label_3: Label = $Sprite2D/Label3


func letter_is_placed():
	if !is_used and current_letter.properties.current_upgrade == "":
		is_used = true
		label.queue_free()
		label_2.queue_free()
		label_3.queue_free()
		current_letter.properties.current_upgrade = "Assassin"
		current_letter.letterDisplay.upgrade_label.visible = true
		current_letter.letterDisplay.upgrade_label.add_theme_color_override("font_color", Color.LIME_GREEN)
		current_letter.letterDisplay.letter_label.add_theme_color_override("font_color", Color.LIME_GREEN)
		current_letter.frame_bar.border_color = Color.WEB_GREEN
