extends ColorRect

var target_hp_percent : float = 100
var current_hp_percent : float = 100
@export var speed := 600.0
@export var border_thickness := 4.0
@export var border_color := Color(1, 1, 1)
var enabled := true
var animating := false

func _ready():
	add_to_group("framebar")

func _process(delta):
	if not enabled:
		if current_hp_percent != target_hp_percent:
			current_hp_percent = target_hp_percent
			queue_redraw()
		return
		
	var old_value := current_hp_percent
	
	if abs(current_hp_percent - target_hp_percent) < 0.1:
		if animating:
			current_hp_percent = target_hp_percent
			queue_redraw()
			animating = false
			get_parent().animation_finished.emit()
	else:
		animating = true
		current_hp_percent = move_toward(current_hp_percent, target_hp_percent, delta * speed)
	
	if abs(current_hp_percent - old_value) > 0.01:
		queue_redraw()
	
	
func set_hp_percent(value: float) -> void:
	await get_tree().create_timer(0.5).timeout
	target_hp_percent = clamp(value, 0.0, 100.0)
	queue_redraw()
	

func _draw():
	#print("FRAME2")
	var w := size.x
	var h := size.y
	var ratio = clamp (current_hp_percent / 100.0, 0.0, 1.0)

	# Top border for 0% < ratio <= 0.33
	if ratio > 0.0 and ratio <= 0.33:
		var width_top = w * (ratio / 0.33)
		draw_rect(Rect2((w - width_top) / 2, 0, width_top, border_thickness), border_color)
	
	# Side borders for 0.33 < ratio <= 0.66
	elif ratio <= 0.66:
		var height = h * ((ratio - 0.33) / (0.66 - 0.33))
		draw_rect(Rect2(0, 0, border_thickness, height), border_color)
		draw_rect(Rect2(w - border_thickness, 0, border_thickness, height), border_color)
	
	# Full bottom + side borders for ratio > 0.66
	else:
		var t = (ratio - 0.66) / (1.0 - 0.66)
		var half_width = (w / 2.0) * (1.0 - t)
		draw_rect(Rect2(0, 0, border_thickness, h), border_color)
		draw_rect(Rect2(w - border_thickness, 0, border_thickness, h), border_color)
		draw_rect(Rect2(0, h - border_thickness, (w / 2.0) - half_width, border_thickness), border_color)
		draw_rect(Rect2((w / 2.0) + half_width, h - border_thickness, (w / 2.0) - half_width, border_thickness), border_color)
