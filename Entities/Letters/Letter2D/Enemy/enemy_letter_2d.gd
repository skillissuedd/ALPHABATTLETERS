extends letter2Dclass

func _ready():
	is_enemy = true
	add_to_group("enemyLetters")
	add_to_group("letters")

	
func _physics_process(delta: float) -> void:
	drag_logic(delta)
