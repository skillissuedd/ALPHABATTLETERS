extends Sprite2D

var is_rotating := false
var previous_angle := 0.0

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_rotating = event.pressed
			if is_rotating:
				previous_angle = (get_global_mouse_position() - global_position).angle()
	
	if is_rotating and event is InputEventMouseMotion:
		var current_angle = (get_global_mouse_position() - global_position).angle()
		rotation += current_angle - previous_angle
		previous_angle = current_angle
