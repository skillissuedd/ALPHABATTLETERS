extends CustomHealthBar
class_name AllyHealthBar

func _ready():
	health_value_label.add_theme_color_override ("font_color", Color.MEDIUM_SEA_GREEN)
