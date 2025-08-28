extends Control

var target_hp_percent : float = 100
var current_hp_percent : float = 100
var previous_hp_percent : float = 100.0


@export var lerp_speed := 15.0
@export var border_thickness := 7.0
@export var border_color := Color(0, 0, 0, 0)
@onready var frame2 = $frame2

var use_temp_value := false

func _ready():
	add_to_group("framebar")

func _process(delta):
	if not use_temp_value:
		var old_value = current_hp_percent
		current_hp_percent = lerp(current_hp_percent, target_hp_percent, delta * lerp_speed)
		
		if abs(current_hp_percent - old_value) > 0.01:
			queue_redraw()
			frame2.set_hp_percent(current_hp_percent)
	else:
		queue_redraw()
	
func set_temp_percent(value: float)-> void:
	current_hp_percent = clamp(value, 0.0, 100.0)
	if frame2: frame2.enabled = false
	use_temp_value = true
	queue_redraw()
	
func set_hp_percent(value: float) -> void:
	target_hp_percent = clamp(value, 0.0, 100.0)
	use_temp_value = false
	frame2.enabled = true
	queue_redraw()

func _draw():
	print("FRAME1")
	var w := size.x
	var h := size.y
	var ratio = clamp (current_hp_percent / 100.0, 0.0, 1.0)
	
	# Top border
	if ratio > 0.33:
		draw_rect(Rect2(0, 0, w, border_thickness), border_color)
	
	# Side and bottom borders for >0.66	
	if ratio > 0.66:
		var t = (ratio - 0.66) / (1.0 - 0.66) 
		var half_width = (w / 2.0) * (1 - t)
		# Vertical sides
		draw_rect(Rect2(0, 0, border_thickness, h), border_color)
		draw_rect(Rect2(w - border_thickness, 0, border_thickness, h), border_color) 
		# Bottom
		draw_rect(Rect2(0, h - border_thickness, (w/2.0) - half_width, border_thickness), border_color) 
		draw_rect(Rect2((w/2.0) + half_width, h - border_thickness, (w/2.0) - half_width, border_thickness), border_color)

	# Side borders for 0.33 < ratio <= 0.66
	elif ratio > 0.33:
		var t = (ratio - 0.33) / (0.66 - 0.33)
		var height = h * t
		draw_rect(Rect2(0, 0, border_thickness, height), border_color) 
		draw_rect(Rect2(w - border_thickness, 0, border_thickness, height), border_color)  
		
	# Top small bar for 0.0 < ratio <= 0.33
	elif ratio > 0.0:
		var t = ratio / 0.33 
		var width_top = w * t
		
		draw_rect(Rect2((w - width_top) / 2, 0, width_top, border_thickness), border_color)
		
	
