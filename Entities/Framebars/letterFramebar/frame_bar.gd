extends Control

var target_hp_percent : float = 100
var current_hp_percent : float = 100
var previous_hp_percent : float = 100.0


@export var lerp_speed := 5.0
@export var border_thickness := 7.0
@export var border_color := Color(0, 0, 0, 0)
@onready var frame2 = $frame2

var use_temp_value := false  # NEW

func _ready():
	add_to_group("framebar")

func _process(delta):
	if not use_temp_value:
		current_hp_percent = lerp(current_hp_percent, target_hp_percent, delta * lerp_speed)
		frame2.set_hp_percent(current_hp_percent)  # Smooth update only for frame2
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
	var w := size.x
	var h := size.y
	var ratio = clamp (current_hp_percent / 100.0, 0.0, 1.0)
	
	if ratio > 0.33:
		draw_rect(Rect2(0, 0, w, border_thickness), border_color)
		
	if ratio > 0.66:
		var t = (ratio - 0.66) / (1.0 - 0.66) 
		var half_width = (w / 2.0) * (1 - t)
		draw_rect(Rect2(0, 0, border_thickness, h), border_color)
		draw_rect(Rect2(w - border_thickness, 0, border_thickness, h), border_color) 
		draw_rect(Rect2(0, h - border_thickness, (w/2.0) - half_width, border_thickness), border_color) 
		draw_rect(Rect2((w/2.0) + half_width, h - border_thickness, (w/2.0) - half_width, border_thickness), border_color)

	elif ratio > 0.33 and ratio <= 0.66:
		var t = (ratio - 0.33) / (0.66 - 0.33)
		var height = h * t

		draw_rect(Rect2(0, 0, border_thickness, height), border_color) 
		draw_rect(Rect2(w - border_thickness, 0, border_thickness, height), border_color)  
		

	if ratio > 0.0 and ratio <= 0.33:
		var t = ratio / 0.33 
		var width_top = w * t
		
		draw_rect(Rect2((w - width_top) / 2, 0, width_top, border_thickness), border_color)
		
	
