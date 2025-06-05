extends letter2Dclass

func _ready():
	is_enemy = true
	add_to_group("enemyLetters")
	add_to_group("letters")
	frame_bar.set_hp_percent(100)
	frame_bar.border_color = Color.DARK_RED
	
func _physics_process(delta: float) -> void:
	drag_logic(delta)
