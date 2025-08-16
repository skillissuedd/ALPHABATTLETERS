extends RichTextLabel
var draw_strikethrough = false

func _draw():
	if not draw_strikethrough:
		return
	var thickness = 4
	var outline_color = Color.BLACK
	var line_color = Color.ROYAL_BLUE
	var y = size.y / 2
	for dx in range(-2, 3):
		for dy in range(-2, 3):
			draw_line(Vector2(0, y) + Vector2(dx, dy),
				Vector2(size.x, y) + Vector2(dx, dy),
				outline_color, thickness)
	draw_line(Vector2(0, y), Vector2(size.x, y), line_color, thickness)
