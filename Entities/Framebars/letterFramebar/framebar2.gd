extends ColorRect

var target_hp_percent : float = 100
var current_hp_percent : float = 100
@export var lerp_speed := 5.0
@export var border_thickness := 4.0
@export var border_color := Color(1, 1, 1)
var enabled := true

func _ready():
	add_to_group("framebar")

func _process(delta):
	if not enabled:
		return
	current_hp_percent = lerp(current_hp_percent, target_hp_percent, delta * lerp_speed)
	queue_redraw()
	
	
func set_hp_percent(value: float) -> void:
	await get_tree().create_timer(0.5).timeout
	target_hp_percent = clamp(value, 0.0, 100.0)
	queue_redraw()
	

func _draw():
	var w := size.x
	var h := size.y
	var ratio = clamp (current_hp_percent / 100.0, 0.0, 1.0)

	if ratio > 0.66:
		# Нижняя линия исчезает от центра к краям (инвертируем t)
		var t = (ratio - 0.66) / (1.0 - 0.66)  # [0..1]
		# теперь ширина — это ширина минус сужение к центру
		var half_width = (w / 2.0) * (1 - t)
		# рисуем две части: слева от 0 до center - half_width, справа от center + half_width до w
		draw_rect(Rect2(0, h - border_thickness, (w/2.0) - half_width, border_thickness), border_color)  # Левая часть
		draw_rect(Rect2((w/2.0) + half_width, h - border_thickness, (w/2.0) - half_width, border_thickness), border_color)  # Правая часть
	else:
		# Если ratio <= 0.66, нижняя линия исчезла, ничего не рисуем
		pass

	# --- Боковые линии ---
	if ratio > 0.33 and ratio <= 0.66:
		var t = (ratio - 0.33) / (0.66 - 0.33)  # [0..1]
		var height = h * t
		# Рисуем боковые линии сверху вниз, чтобы они уменьшались снизу вверх
		draw_rect(Rect2(0, 0, border_thickness, height), border_color)  # Левая
		draw_rect(Rect2(w - border_thickness, 0, border_thickness, height), border_color)  # Правая
	elif ratio > 0.66:
		# Полностью отображаем боковые линии
		draw_rect(Rect2(0, 0, border_thickness, h), border_color)  # Левая
		draw_rect(Rect2(w - border_thickness, 0, border_thickness, h), border_color)  # Правая

	# Верхняя линия
	if ratio > 0.0 and ratio <= 0.33:
		var t = ratio / 0.33  # [0..1]
		var width_top = w * t
		# Верхняя линия движется к центру (уменьшается от краёв к середине)
		draw_rect(Rect2((w - width_top) / 2, 0, width_top, border_thickness), border_color)
	elif ratio > 0.33:
		# Полностью отображаем верхнюю линию
		draw_rect(Rect2(0, 0, w, border_thickness), border_color)
