extends ProgressBar
class_name CustomHealthBar

var change_value_tween: Tween
var opacity_tween: Tween
@export var current_health: float
@export var max_health: float
@onready var health_value_label = $HealthValueLabel


func get_damaged(value: int):
	var new_health = current_health-float(value)
	change_value(new_health)
	
func _change_max_health(max_val: float):
	max_health = max_val
	max_value = max_val
	$ProgressBar.max_value = max_val
	$ProgressBar.value = max_val
	
func _change_current_health(current_val: float):
	current_health = current_val
	value = current_val
	health_value_label.text = "%d / %d" % [current_val, max_value]
	
func _setup_health_bar(max_val: float):
	_change_max_health(max_val)
	_change_current_health(max_val)
	modulate.a = 1.0
	
func change_value(new_value: float):
	# Store old value BEFORE updating
	var old_value = value

	# Cancel existing tweens
	if change_value_tween:
		change_value_tween.kill()
	
	_change_current_health(new_value)
	
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
	
	if current_health <= 0:
		Global.battle_manager.room_cleared()
		play_death_anim()
		
func play_death_anim():
	var tween = create_tween()
	var scale_temp = scale.x
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.5) 
	tween.tween_property(self, "scale:x", 0.0, 0.5).set_trans(Tween.TRANS_BACK) 
	tween.set_parallel(false)
	await tween.finished
	visible=false
	modulate.a=1
	scale.x=scale_temp
