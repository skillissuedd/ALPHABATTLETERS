extends RichTextLabel
var draw_strikethrough = false

func _draw():
	if not draw_strikethrough:
		return
	var thickness = 4
	var outline_color = Color.BLACK
	var line_color = Color.WEB_GREEN
	var y = size.y / 2
	var half_width = size.x / 2
	var quarter_width = size.x / 4
	var start_x = quarter_width
	var end_x = size.x - quarter_width
	
	
	for dx in range(-2, 3):
		for dy in range(-2, 3):
			draw_line(Vector2(start_x, y) + Vector2(dx, dy),
				Vector2(end_x, y) + Vector2(dx, dy),
				outline_color, thickness)
	draw_line(Vector2(start_x, y), Vector2(end_x, y), line_color, thickness)
