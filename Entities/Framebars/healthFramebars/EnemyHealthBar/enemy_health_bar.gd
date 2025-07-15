extends CustomHealthBar
class_name EnemyHealthBar

func _ready():
	health_value_label.add_theme_color_override ("font_color", Color.INDIAN_RED)
