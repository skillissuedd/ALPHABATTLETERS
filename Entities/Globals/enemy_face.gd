extends Node2D
class_name BookHealthBar

@export var max_pages := 10
@export var cover_health := 100.0
@export var page_health := 50.0
@onready var pages := $Pages
var current_cover := 100.0
var current_pages := 10


func _ready():
	# Set initial size (width: 100, height: 60 - adjust as needed)
	pages.custom_minimum_size = Vector2(100, 60)
	pages.size = Vector2(100, 60)
	
func update_health(percent: float):
	# 1. Update shader fill (bottom-up)
	var mat = pages.material as ShaderMaterial
	mat.set_shader_parameter("fill_color", Color(0.9, 0.9, 0.5)) # RGB 0.9, 0.9, 0.5
	
	# 2. Vertical shrink effect
	var target_height = 100 * percent # Adjust 100 to your desired max height
	var tween = create_tween()
	tween.tween_property(pages, "custom_minimum_size:y", target_height, 0.3)

func setup():
	current_cover = cover_health
	current_pages = max_pages
	update_visuals()

func take_damage(damage: float):
	if current_cover > 0:
		current_cover = max(0, current_cover - damage)
	else:
		var pages_lost = int(damage / page_health)
		current_pages = max(0, current_pages - pages_lost)
	update_visuals()

func update_visuals():
	for i in range(max_pages):
		get_node("Pages/Page%d" % (i+1)).visible = (i < current_pages)
	$BookCover.modulate = Color(0.9, 0.9, 0.5, current_cover / cover_health)


func _on_h_scroll_bar_value_changed(value: float) -> void:
	update_health(value/100)
