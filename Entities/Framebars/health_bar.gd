extends ProgressBar
class_name CustomHealthBar

var change_value_tween: Tween
var opacity_tween: Tween
var Health: float

func _setup_health_bar(max_val: float):
	max_value = max_val
	value = max_val
	$ProgressBar.max_value = max_val
	$ProgressBar.value = max_val
	modulate.a = 1.0
	
func change_value(new_value: float):
	# Store old value BEFORE updating
	var old_value = value
	 
	# Cancel existing tweens
	if change_value_tween:
		change_value_tween.kill()
	
	# Update actual value immediately
	value = new_value

	# Animate the visual bar
	change_value_tween = create_tween()
	change_value_tween.tween_property($ProgressBar, "value", new_value, 0.35)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	# Flash effect
	if new_value < old_value:  # Damage
		$ProgressBar.modulate = Color(1, 0.3, 0.3)
		var reset_tween = create_tween()
		reset_tween.tween_property($ProgressBar, "modulate", Color.WHITE, 0.3)
	elif new_value > old_value:  # Heal
		$ProgressBar.modulate = Color(0.3, 1, 0.3)
		var reset_tween = create_tween()
		reset_tween.tween_property($ProgressBar, "modulate", Color.WHITE, 0.3)
