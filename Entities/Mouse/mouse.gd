extends Sprite2D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _physics_process(delta: float) -> void:
	global_position = lerp(global_position, get_global_mouse_position(), 42.0*delta)
	rotation_degrees = lerp(rotation_degrees, -12.5 if Input.is_action_pressed("click") else 0.0, 16.0*delta)
	scale = lerp(scale, Vector2(0.25, 0.25) if Input.is_action_pressed("click") else Vector2(0.3, 0.3), 16.0*delta)
	$shadow.position = Vector2(35, 35).rotated(rotation)
